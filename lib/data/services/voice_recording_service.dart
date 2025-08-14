// Voice Recording Service for handling audio recording functionality
import 'dart:io';
import 'dart:typed_data';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

enum RecordingState {
  idle,
  recording,
  paused,
  processing,
  completed,
  error,
}

class VoiceRecordingService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  RecordingState _state = RecordingState.idle;
  String? _currentRecordingPath;
  String? _currentRecordingId;
  Duration _currentDuration = Duration.zero;
  Function(RecordingState)? _onStateChanged;
  String? _errorMessage;

  // Getters
  RecordingState get state => _state;
  String? get currentRecordingPath => _currentRecordingPath;
  String? get currentRecordingId => _currentRecordingId;
  Duration get currentDuration => _currentDuration;
  String? get errorMessage => _errorMessage;
  bool get isRecording => _state == RecordingState.recording;
  bool get isPaused => _state == RecordingState.paused;
  bool get isProcessing => _state == RecordingState.processing;

  // Set listeners
  void setStateListener(Function(RecordingState) listener) {
    _onStateChanged = listener;
  }

  void setDurationListener(Function(Duration) listener) {
    // Duration listener not currently implemented
    listener(Duration.zero); // Call once with zero duration
  }

  // Start recording
  Future<bool> startRecording() async {
    try {
      if (_state != RecordingState.idle && _state != RecordingState.completed) {
        _setError('Cannot start recording. Current state: $_state');
        return false;
      }

      // Generate recording ID and path
      _currentRecordingId = const Uuid().v4();
      final tempDir = await getTemporaryDirectory();
      _currentRecordingPath = '${tempDir.path}/$_currentRecordingId.m4a';

      // Configure recording parameters
      const RecordConfig config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      // Start recording
      await _audioRecorder.start(
        config,
        path: _currentRecordingPath!,
      );

      _setState(RecordingState.recording);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to start recording: $e');
      return false;
    }
  }

  // Pause recording
  Future<bool> pauseRecording() async {
    try {
      if (_state != RecordingState.recording) {
        _setError('Cannot pause recording. Not currently recording.');
        return false;
      }

      await _audioRecorder.pause();
      _setState(RecordingState.paused);
      return true;
    } catch (e) {
      _setError('Failed to pause recording: $e');
      return false;
    }
  }

  // Resume recording
  Future<bool> resumeRecording() async {
    try {
      if (_state != RecordingState.paused) {
        _setError('Cannot resume recording. Not currently paused.');
        return false;
      }

      await _audioRecorder.resume();
      _setState(RecordingState.recording);
      return true;
    } catch (e) {
      _setError('Failed to resume recording: $e');
      return false;
    }
  }

  // Stop recording
  Future<String?> stopRecording() async {
    try {
      if (_state != RecordingState.recording && _state != RecordingState.paused) {
        _setError('Cannot stop recording. Not currently recording or paused.');
        return null;
      }

      _setState(RecordingState.processing);

      // Stop recording
      final path = await _audioRecorder.stop();

      if (path != null && path.isNotEmpty) {
        _currentRecordingPath = path;
        _setState(RecordingState.completed);
        _clearError();
        return _currentRecordingPath;
      } else {
        _setError('Failed to stop recording');
        _setState(RecordingState.error);
        return null;
      }
    } catch (e) {
      _setError('Failed to stop recording: $e');
      _setState(RecordingState.error);
      return null;
    }
  }

  // Cancel recording
  Future<bool> cancelRecording() async {
    try {
      if (_state == RecordingState.idle || _state == RecordingState.completed) {
        _setError('Cannot cancel recording. Not currently recording.');
        return false;
      }

      // Stop recording without saving
      await _audioRecorder.stop();

      // Delete the temporary file if it exists
      if (_currentRecordingPath != null) {
        try {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // Ignore file deletion errors
        }
      }

      // Reset state
      _currentRecordingPath = null;
      _currentRecordingId = null;
      _currentDuration = Duration.zero;
      _setState(RecordingState.idle);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to cancel recording: $e');
      return false;
    }
  }

  // Get recording duration
  Future<Duration> getRecordingDuration() async {
    try {
      if (_state == RecordingState.idle) {
        return Duration.zero;
      }

      // The record package doesn't have a duration method, so we'll track it manually
      return _currentDuration;
    } catch (e) {
      _setError('Failed to get recording duration: $e');
      return Duration.zero;
    }
  }

  // Get recording as bytes
  Future<Uint8List?> getRecordingAsBytes() async {
    try {
      if (_currentRecordingPath == null || _state != RecordingState.completed) {
        _setError('No recording available or recording not completed');
        return null;
      }

      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        return await file.readAsBytes();
      } else {
        _setError('Recording file not found');
        return null;
      }
    } catch (e) {
      _setError('Failed to read recording file: $e');
      return null;
    }
  }

  // Check if recording file exists
  Future<bool> recordingFileExists() async {
    if (_currentRecordingPath == null) return false;
    
    try {
      final file = File(_currentRecordingPath!);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Delete recording file
  Future<bool> deleteRecordingFile() async {
    if (_currentRecordingPath == null) return true;
    
    try {
      final file = File(_currentRecordingPath!);
      if (await file.exists()) {
        await file.delete();
      }
      _currentRecordingPath = null;
      _currentRecordingId = null;
      return true;
    } catch (e) {
      _setError('Failed to delete recording file: $e');
      return false;
    }
  }

  // Reset service
  Future<void> reset() async {
    try {
      // Stop any ongoing recording
      if (_state == RecordingState.recording || _state == RecordingState.paused) {
        await _audioRecorder.stop();
      }

      // Delete recording file if it exists
      await deleteRecordingFile();

      // Reset state
      _currentDuration = Duration.zero;
      _setState(RecordingState.idle);
      _clearError();
    } catch (e) {
      _setError('Failed to reset recording service: $e');
    }
  }

  // Check recording permissions
  Future<bool> hasRecordingPermission() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      return hasPermission;
    } catch (e) {
      _setError('Failed to check recording permissions: $e');
      return false;
    }
  }

  // Private helper methods
  void _setState(RecordingState newState) {
    _state = newState;
    _onStateChanged?.call(newState);
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Cleanup
  void dispose() {
    _audioRecorder.dispose();
    _onStateChanged = null;
  }
}