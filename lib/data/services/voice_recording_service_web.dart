// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
// Web implementation: real recording via MediaRecorder, keeping API parity.
// No dart:io used. Uses JS interop to access MediaRecorder.
import 'dart:async';
import 'dart:html' as html;
import 'package:js/js.dart';
import 'package:js/js_util.dart' as jsu;

enum RecordingState { idle, recording, paused, processing, completed, error }

class VoiceRecordingService {
  // Internal state
  RecordingState _state = RecordingState.idle;
  String? _currentRecordingId;
  String? _currentRecordingPath; // object URL
  Duration _currentDuration = Duration.zero;
  String? _errorMessage;

  // Listeners
  Function(RecordingState)? _onStateChanged;
  Function(Duration)? _onDurationChanged;

  // MediaRecorder members
  dynamic _recorder; // JS MediaRecorder
  html.MediaStream? _stream;
  final List<html.Blob> _chunks = <html.Blob>[];
  Timer? _ticker;
  DateTime? _startedAt;
  
  // Audio stream for visualization
  StreamController<List<int>>? _audioStreamController;
  Stream<List<int>>? _audioStream;

  // Getters
  RecordingState get state => _state;
  String? get currentRecordingPath => _currentRecordingPath;
  String? get currentRecordingId => _currentRecordingId;
  Duration get currentDuration => _currentDuration;
  String? get errorMessage => _errorMessage;
  bool get isRecording => _state == RecordingState.recording;
  bool get isPaused => _state == RecordingState.paused;
  bool get isProcessing => _state == RecordingState.processing;
  
  // Audio stream getter for visualization
  Stream<List<int>>? getAudioStream() {
    return _audioStream;
  }

  // Listeners setters
  void setStateListener(Function(RecordingState) listener) {
    _onStateChanged = listener;
    _onStateChanged?.call(_state);
  }

  void setDurationListener(Function(Duration) listener) {
    _onDurationChanged = listener;
    _onDurationChanged?.call(_currentDuration);
  }

  Future<bool> initialize() async {
    // Nothing to pre-initialize; defer to start
    _setState(RecordingState.idle);
    return true;
  }

  Future<void> dispose() async {
    try {
      await _stopTicker();
      _stopRecorderSilently();
      _stopStreamTracks();
      _revokeObjectUrl();
      _audioStreamController?.close();
      _audioStreamController = null;
      _audioStream = null;
    } catch (_) {}
  }

  // Permissions
  Future<bool> hasRecordingPermission() async {
    // Try to check with minimal interaction. On web, best effort only.
    try {
      final devices = html.window.navigator.mediaDevices;
      if (devices == null) return false;
      // Avoid prompting user here; assume permission can be requested.
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkMicrophonePermission() async {
    // Alias for parity with IO service
    return await hasRecordingPermission();
  }

  // Recording controls
  Future<bool> startRecording() async {
    try {
      if (_state != RecordingState.idle && _state != RecordingState.completed) {
        _setError('Cannot start recording. Current state: $_state');
        return false;
      }

      // Initialize audio stream for visualization BEFORE starting recording
      _audioStreamController = StreamController<List<int>>.broadcast();
      _audioStream = _audioStreamController!.stream;

      final devices = html.window.navigator.mediaDevices;
      if (devices == null) {
        _setError('MediaDevices API is not available');
        return false;
      }

      // Request audio stream (prompts user)
      _stream = await devices.getUserMedia({'audio': true});

      // Prepare options
      final options = jsu.newObject();
      // Prefer opus in webm; fallback to browser default if unsupported
      jsu.setProperty(options, 'mimeType', 'audio/webm;codecs=opus');

      // Check MediaRecorder support
      final ctor = jsu.getProperty(html.window, 'MediaRecorder');
      if (ctor == null) {
        _setError('MediaRecorder is not supported in this browser');
        _stopStreamTracks();
        return false;
      }

      _recorder = jsu.callConstructor(ctor, [_stream, options]);

      // Add event listeners
      jsu.callMethod(_recorder, 'addEventListener', [
        'dataavailable',
        allowInterop((dynamic e) {
          final blob = jsu.getProperty(e, 'data') as html.Blob?;
          if (blob != null && blob.size > 0) {
            _chunks.add(blob);
          }
        })
      ]);

      jsu.callMethod(_recorder, 'addEventListener', [
        'stop',
        allowInterop((dynamic e) {
          // stopping handled in stopRecording
        })
      ]);

      // Reset state
      _chunks.clear();
      _revokeObjectUrl();

      // Start
      jsu.callMethod(_recorder, 'start', []); // optional: timeslice
      _startedAt = DateTime.now();
      _currentDuration = Duration.zero;
      _startTicker();
      _setState(RecordingState.recording);
      _clearError();
      
      // Start sending simulated audio data for visualization
      _startAudioDataSimulation();
      
      return true;
    } catch (e) {
      _setError('Failed to start recording: $e');
      _stopRecorderSilently();
      _stopStreamTracks();
      return false;
    }
  }

  // Simulate audio data for visualization
  void _startAudioDataSimulation() {
    if (_audioStreamController == null) return;
    
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (_state != RecordingState.recording) {
        timer.cancel();
        return;
      }
      
      // Generate simulated audio data (random bytes for visualization)
      final randomData = List<int>.generate(50, (i) => (i * 10 + DateTime.now().millisecond) % 256);
      _audioStreamController?.add(randomData);
    });
  }

  Future<bool> pauseRecording() async {
    try {
      if (_recorder == null || _state != RecordingState.recording) {
        _setError('Cannot pause recording. Not currently recording.');
        return false;
      }
      jsu.callMethod(_recorder, 'pause', []);
      _setState(RecordingState.paused);
      return true;
    } catch (e) {
      _setError('Failed to pause recording: $e');
      return false;
    }
  }

  Future<bool> resumeRecording() async {
    try {
      if (_recorder == null || _state != RecordingState.paused) {
        _setError('Cannot resume recording. Not currently paused.');
        return false;
      }
      jsu.callMethod(_recorder, 'resume', []);
      _setState(RecordingState.recording);
      return true;
    } catch (e) {
      _setError('Failed to resume recording: $e');
      return false;
    }
  }

  Future<String?> stopRecording() async {
    try {
      if (_recorder == null || (_state != RecordingState.recording && _state != RecordingState.paused)) {
        _setError('Cannot stop recording. Not currently recording or paused.');
        return null;
      }

      _setState(RecordingState.processing);
      await _stopTicker();

      // Stop recorder and wait a microtask for final chunk
      jsu.callMethod(_recorder, 'stop', []);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Build blob
      final blob = html.Blob(_chunks, 'audio/webm;codecs=opus');
      _chunks.clear();

      // Create object URL
      _revokeObjectUrl();
      _currentRecordingPath = html.Url.createObjectUrlFromBlob(blob);

      // Stop tracks
      _stopStreamTracks();
      _recorder = null;

      _setState(RecordingState.completed);
      _clearError();
      
      // Close audio stream controller
      _audioStreamController?.close();
      _audioStreamController = null;
      _audioStream = null;
      
      return _currentRecordingPath;
    } catch (e) {
      _setError('Failed to stop recording: $e');
      _stopRecorderSilently();
      _stopStreamTracks();
      return null;
    }
  }

  // Ticker for duration updates
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_startedAt != null && (isRecording || isPaused)) {
        final now = DateTime.now();
        final base = _startedAt!;
        final d = now.difference(base);
        _currentDuration = d;
        _onDurationChanged?.call(_currentDuration);
      }
    });
  }

  Future<void> _stopTicker() async {
    _ticker?.cancel();
    _ticker = null;
  }

  // Helpers
  void _stopStreamTracks() {
    try {
      final s = _stream;
      if (s != null) {
        for (final t in s.getTracks()) {
          t.stop();
        }
      }
      _stream = null;
    } catch (_) {}
  }

  void _stopRecorderSilently() {
    try {
      if (_recorder != null) {
        try { jsu.callMethod(_recorder, 'stop', []); } catch (_) {}
      }
    } catch (_) {}
    _recorder = null;
  }

  void _revokeObjectUrl() {
    try {
      final url = _currentRecordingPath;
      if (url != null) {
        html.Url.revokeObjectUrl(url);
      }
    } catch (_) {}
    _currentRecordingPath = null;
  }

  void _setState(RecordingState newState) {
    _state = newState;
    final cb = _onStateChanged;
    if (cb != null) {
      try { cb(newState); } catch (_) {}
    }
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  // Reset service with improved error handling
  Future<void> reset() async {
    try {
      // Stop any ongoing recording with retry logic
      if (_state == RecordingState.recording || _state == RecordingState.paused) {
        int maxRetries = 2;
        int retryCount = 0;
        
        while (retryCount < maxRetries) {
          try {
            await _stopTicker();
            _stopRecorderSilently();
            _stopStreamTracks();
            break; // Success, exit retry loop
          } catch (e) {
            retryCount++;
            if (retryCount >= maxRetries) {
              // If we can't stop gracefully, continue with cleanup
              _setError('Failed to stop recording: $e');
              break;
            }
            // Wait before retrying
            await Future.delayed(const Duration(milliseconds: 100));
          }
        }
      }

      // Delete recording file if it exists (revoke object URL)
      _revokeObjectUrl();

      // Reset state
      _currentDuration = Duration.zero;
      _setState(RecordingState.idle);
      _clearError();
    } catch (e) {
      _setError('Failed to reset recording service: $e');
    }
  }
}
