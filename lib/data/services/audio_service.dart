// Audio Service for managing audio playback functionality
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../models/voice_model.dart';
import 'elevenlabs_service.dart';

enum AudioState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ElevenLabsService _elevenLabsService;
  final Map<String, String> _audioCache = {};
  final Map<String, Uint8List> _audioDataCache = {}; // For web platform
  final Map<String, AudioState> _audioStates = {};
  final Map<String, Duration> _audioDurations = {};
  final Map<String, Duration> _audioPositions = {};
  final Map<String, Function(AudioState)> _stateListeners = {};
  final Map<String, Function(Duration)> _positionListeners = {};
  final Map<String, Function(Duration)> _durationListeners = {};
  final Map<String, Function(String)> _errorListeners = {};

  AudioService({required ElevenLabsService elevenLabsService})
      : _elevenLabsService = elevenLabsService;

  // Audio playback methods
  Future<String> playAudio(String audioId, {String? source}) async {
    try {
      _setState(audioId, AudioState.loading);

      String audioSource;
      if (source != null) {
        audioSource = source;
      } else if (_audioCache.containsKey(audioId)) {
        audioSource = _audioCache[audioId]!;
      } else {
        throw const AudioException(message: 'Audio source not found');
      }

      // Set up event listeners
      _audioPlayer.onPositionChanged.listen((position) {
        _setPosition(audioId, position);
        _positionListeners[audioId]?.call(position);
      });

      _audioPlayer.onDurationChanged.listen((duration) {
        _setDuration(audioId, duration);
        _durationListeners[audioId]?.call(duration);
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        switch (state) {
          case PlayerState.playing:
            _setState(audioId, AudioState.playing);
            break;
          case PlayerState.paused:
            _setState(audioId, AudioState.paused);
            break;
          case PlayerState.completed:
            _setState(audioId, AudioState.completed);
            break;
          case PlayerState.stopped:
            _setState(audioId, AudioState.idle);
            break;
          case PlayerState.disposed:
            _setState(audioId, AudioState.idle);
            break;
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        _setState(audioId, AudioState.completed);
      });

      // Handle web vs native platforms differently
      if (kIsWeb && audioSource.startsWith('web_audio_')) {
        // For web audio, use the cached audio data to create a data URL
        final audioData = _audioDataCache[audioId];
        if (audioData != null) {
          final audioBlob = Uri.dataFromBytes(audioData, mimeType: 'audio/mp3');
          await _audioPlayer.play(UrlSource(audioBlob.toString()));
        } else {
          throw const AudioException(message: 'Web audio data not found');
        }
      } else {
        // For native platforms or file paths, use DeviceFileSource
        await _audioPlayer.play(DeviceFileSource(audioSource));
      }
      
      _setState(audioId, AudioState.playing);

      // Cache the audio source
      _audioCache[audioId] = audioSource;

      return audioId;
    } catch (e) {
      _setError(audioId, 'Failed to play audio: $e');
      _setState(audioId, AudioState.error);
      rethrow;
    }
  }

  Future<void> pauseAudio(String audioId) async {
    try {
      await _audioPlayer.pause();
      _setState(audioId, AudioState.paused);
    } catch (e) {
      _setError(audioId, 'Failed to pause audio: $e');
      _setState(audioId, AudioState.error);
      rethrow;
    }
  }

  Future<void> stopAudio(String audioId) async {
    try {
      await _audioPlayer.stop();
      _setState(audioId, AudioState.idle);
      _setPosition(audioId, Duration.zero);
    } catch (e) {
      _setError(audioId, 'Failed to stop audio: $e');
      _setState(audioId, AudioState.error);
      rethrow;
    }
  }

  Future<void> resumeAudio(String audioId) async {
    try {
      await _audioPlayer.resume();
      _setState(audioId, AudioState.playing);
    } catch (e) {
      _setError(audioId, 'Failed to resume audio: $e');
      _setState(audioId, AudioState.error);
      rethrow;
    }
  }

  Future<void> seekAudio(String audioId, Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _setError(audioId, 'Failed to seek audio: $e');
      _setState(audioId, AudioState.error);
      rethrow;
    }
  }

  // Audio synthesis methods
  Future<String> synthesizeAndPlay({
    required String text,
    required String voiceId,
    VoiceSettingsModel? settings,
    String? modelId,
  }) async {
    try {
      final audioId = const Uuid().v4();
      _setState(audioId, AudioState.loading);

      // Generate audio using ElevenLabs service
      final audioData = await _elevenLabsService.synthesizeText(
        text: text,
        voiceId: voiceId,
        settings: settings,
        modelId: modelId,
      );

      // Handle web vs native platforms differently
      if (kIsWeb) {
        // For web, store audio data directly in memory
        _audioCache[audioId] = 'web_audio_$audioId';
        _audioDataCache[audioId] = audioData;
      } else {
        // For native platforms, save to temporary file
        final tempDir = await getTemporaryDirectory();
        final audioFile = File('${tempDir.path}/$audioId.mp3');
        await audioFile.writeAsBytes(audioData);
        _audioCache[audioId] = audioFile.path;
      }

      // Play the audio
      await playAudio(audioId);

      return audioId;
    } catch (e) {
      _setState(const Uuid().v4(), AudioState.error);
      rethrow;
    }
  }

  // Audio caching methods
  Future<String> cacheAudio(Uint8List audioData, {String? customId}) async {
    try {
      final audioId = customId ?? const Uuid().v4();
      
      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/$audioId.mp3');
      await audioFile.writeAsBytes(audioData);

      // Cache the file path
      _audioCache[audioId] = audioFile.path;

      return audioId;
    } catch (e) {
      throw AudioException(message: 'Failed to cache audio: $e');
    }
  }

  Future<String?> getCachedAudioPath(String audioId) async {
    return _audioCache[audioId];
  }

  Future<bool> isAudioCached(String audioId) async {
    return _audioCache.containsKey(audioId);
  }

  Future<void> clearCache() async {
    try {
      // Delete all cached audio files (only for native platforms)
      for (final audioPath in _audioCache.values) {
        try {
          // Only try to delete if it's a file path (not web audio)
          if (!audioPath.startsWith('web_audio_')) {
            final file = File(audioPath);
            if (await file.exists()) {
              await file.delete();
            }
          }
        } catch (e) {
          // Ignore individual file deletion errors
        }
      }

      // Clear cache maps
      _audioCache.clear();
      _audioDataCache.clear(); // Clear web audio data cache
      _audioStates.clear();
      _audioDurations.clear();
      _audioPositions.clear();
    } catch (e) {
      throw AudioException(message: 'Failed to clear audio cache: $e');
    }
  }

  // State management methods
  AudioState getAudioState(String audioId) {
    return _audioStates[audioId] ?? AudioState.idle;
  }

  Duration getAudioDuration(String audioId) {
    return _audioDurations[audioId] ?? Duration.zero;
  }

  Duration getAudioPosition(String audioId) {
    return _audioPositions[audioId] ?? Duration.zero;
  }

  double getAudioProgress(String audioId) {
    final duration = getAudioDuration(audioId);
    final position = getAudioPosition(audioId);
    
    if (duration.inMilliseconds == 0) return 0.0;
    return position.inMilliseconds / duration.inMilliseconds;
  }

  // Listener management methods
  void addStateListener(String audioId, Function(AudioState) listener) {
    _stateListeners[audioId] = listener;
  }

  void removeStateListener(String audioId) {
    _stateListeners.remove(audioId);
  }

  void addPositionListener(String audioId, Function(Duration) listener) {
    _positionListeners[audioId] = listener;
  }

  void removePositionListener(String audioId) {
    _positionListeners.remove(audioId);
  }

  void addDurationListener(String audioId, Function(Duration) listener) {
    _durationListeners[audioId] = listener;
  }

  void removeDurationListener(String audioId) {
    _durationListeners.remove(audioId);
  }

  void addErrorListener(String audioId, Function(String) listener) {
    _errorListeners[audioId] = listener;
  }

  void removeErrorListener(String audioId) {
    _errorListeners.remove(audioId);
  }

  // Private helper methods
  void _setState(String audioId, AudioState state) {
    _audioStates[audioId] = state;
    _stateListeners[audioId]?.call(state);
  }

  void _setPosition(String audioId, Duration position) {
    _audioPositions[audioId] = position;
    _positionListeners[audioId]?.call(position);
  }

  void _setDuration(String audioId, Duration duration) {
    _audioDurations[audioId] = duration;
    _durationListeners[audioId]?.call(duration);
  }

  void _setError(String audioId, String error) {
    _errorListeners[audioId]?.call(error);
  }

  // Cleanup method
  void dispose() {
    _audioPlayer.dispose();
    
    // Clear all listeners
    _stateListeners.clear();
    _positionListeners.clear();
    _durationListeners.clear();
    _errorListeners.clear();
    
    // Clear cache
    clearCache();
  }
}

// Custom exception for audio-related errors
class AudioException implements Exception {
  final String message;
  
  const AudioException({required this.message});
  
  @override
  String toString() => 'AudioException: $message';
}