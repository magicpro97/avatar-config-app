// Speech-to-Text Service for handling voice recognition functionality
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';

enum SpeechRecognitionState {
  idle,
  listening,
  processing,
  completed,
  error,
}

class SpeechToTextService {
  final SpeechToText _speechToText = SpeechToText();
  SpeechRecognitionState _state = SpeechRecognitionState.idle;
  String? _lastRecognizedText;
  String? _errorMessage;
  Function(SpeechRecognitionState)? _onStateChanged;
  Function(String)? _onTextRecognized;
  Function(String)? _onPartialTextRecognized; // For real-time partial results
  Function(String)? _onError;
  double _currentVolume = 0.0;
  bool _isListening = false;
  bool _enableRealTimeResults = true; // Flag to enable/disable real-time updates
  String? _partialText; // For partial recognition results
  // Web fallback mode to avoid platform plugin issues (can be overridden by settings)
  bool _useWebFallback = false; // Disable web fallback by default to enable real speech recognition
  Timer? _fallbackTimer;
  bool _isOperationInProgress = false; // Prevent concurrent start/stop/cancel
  DateTime? _lastStateChangeAt;

  bool _canTransition(SpeechRecognitionState from, SpeechRecognitionState to) {
    switch (from) {
      case SpeechRecognitionState.idle:
        return to == SpeechRecognitionState.listening || to == SpeechRecognitionState.idle || to == SpeechRecognitionState.error;
      case SpeechRecognitionState.listening:
        return to == SpeechRecognitionState.processing || to == SpeechRecognitionState.completed || to == SpeechRecognitionState.error || to == SpeechRecognitionState.idle;
      case SpeechRecognitionState.processing:
        return to == SpeechRecognitionState.completed || to == SpeechRecognitionState.error || to == SpeechRecognitionState.idle;
      case SpeechRecognitionState.completed:
        return to == SpeechRecognitionState.idle || to == SpeechRecognitionState.listening || to == SpeechRecognitionState.error;
      case SpeechRecognitionState.error:
        return to == SpeechRecognitionState.idle || to == SpeechRecognitionState.listening || to == SpeechRecognitionState.error;
    }
  }

  // Getters
  SpeechRecognitionState get state => _state;
  String? get lastRecognizedText => _lastRecognizedText;
  String? get errorMessage => _errorMessage;
  bool get isListening => _isListening;
  double get currentVolume => _currentVolume;
  bool get hasError => _state == SpeechRecognitionState.error;

  // Set listeners
  void setStateListener(Function(SpeechRecognitionState) listener) {
    _onStateChanged = listener;
  }

  void setTextRecognizedListener(Function(String) listener) {
    _onTextRecognized = listener;
  }

  void setPartialTextRecognizedListener(Function(String) listener) {
    _onPartialTextRecognized = listener;
  }

  void setErrorListener(Function(String) listener) {
    _onError = listener;
  }

  void setSoundLevelListener(Function(double) listener) {
    // No-op: sound level callbacks disabled in current implementation
  }

  // Enable or disable real-time partial results
  void setRealTimeResultsEnabled(bool enabled) {
    _enableRealTimeResults = enabled;
  }

  // Check if real-time results are enabled
  bool get isRealTimeResultsEnabled => _enableRealTimeResults;

  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      if (_state != SpeechRecognitionState.idle) {
        _setError('Speech recognition is already initialized or in use');
        return false;
      }

      // On web, use a safe fallback that simulates listening to avoid plugin cast errors
      if (_useWebFallback) {
        _setState(SpeechRecognitionState.idle);
        _clearError();
        return true;
      }

      // Proactively release any dangling engine resources (especially after widget toggles)
      await _forceReleaseResources();

      // Try to initialize with proper error handling
      bool isAvailable = false;
      try {
        isAvailable = await _speechToText.initialize(
          onStatus: _handleStatusChange,
          onError: (error) {
            final message = _extractErrorMessage(error);
            _handleError(message);
          },
        );
      } catch (initError) {
        // If initialization fails, try without error callback for web
        if (kIsWeb) {
          try {
            isAvailable = await _speechToText.initialize(
              onStatus: _handleStatusChange,
              onError: null,
            );
          } catch (webInitError) {
            _setError('Failed to initialize speech recognition on web: $webInitError');
            return false;
          }
        } else {
          _setError('Failed to initialize speech recognition: $initError');
          return false;
        }
      }

      if (isAvailable) {
        _setState(SpeechRecognitionState.idle);
        _clearError();
        return true;
      } else {
        _setError('Speech recognition is not available on this device');
        return false;
      }
    } catch (e) {
      _setError('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  // Check if speech recognition is available
  Future<bool> isAvailable() async {
    try {
      if (_useWebFallback) return true;
      // Proactively release before re-initializing to avoid busy mic states
      await _forceReleaseResources();
      return await _speechToText.initialize(
        onStatus: _handleStatusChange,
        onError: kIsWeb
            ? null
            : (error) {
                final message = _extractErrorMessage(error);
                _handleError(message);
              },
      );
    } catch (e) {
      return false;
    }
  }

  // Start listening for speech
  Future<bool> startListening() async {
    try {
      if (_isOperationInProgress) {
        _setError('Speech recognition is busy');
        return false;
      }
      _isOperationInProgress = true;
      // Ensure proper cleanup before starting
      await _ensureCleanState();

      if (_useWebFallback) {
        _setState(SpeechRecognitionState.listening);
        _isListening = true;
        _clearError();
        // Simulate partial updates
        _partialText = '';
        _fallbackTimer?.cancel();
        _fallbackTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
          if (!_isListening) {
            timer.cancel();
            return;
          }
          // Append a simple dot sequence to indicate activity
          _partialText = (_partialText!.length >= 10) ? '' : ('${_partialText!}.');
          if (_enableRealTimeResults) {
            _onPartialTextRecognized?.call(_partialText!);
          }
        });
        return true;
      }

      // On web, always re-initialize right before listening to avoid stale engine state
      if (kIsWeb) {
        await _forceReleaseResources();
        final ok = await _speechToText.initialize(
          onStatus: _handleStatusChange,
          onError: null,
        );
        if (!ok) {
          _setError('Speech recognition is not available');
          return false;
        }
      } else {
        if (!_speechToText.isAvailable) {
          _setError('Speech recognition is not available');
          return false;
        }
      }

      // Only mark listening after initialization succeeds
      _setState(SpeechRecognitionState.listening);
      _isListening = true;
      _clearError();

      // Wrap speech_to_text calls in additional error handling for web platform
      bool success = false;
      try {
        // Use newer options API; avoid sound level callback which is unstable on web
        final options = SpeechListenOptions(
          partialResults: _enableRealTimeResults,
          cancelOnError: true,
        );
        // Handle case where listen() might return null on web platform
        final result = await _speechToText.listen(
          onResult: _handleRecognitionResultSafely,
          listenOptions: options,
        );
        
        // Safely handle nullable return value
        success = result == true;
      } catch (e) {
        // Handle speech_to_text package internal errors (especially on web)
        debugPrint('Speech recognition internal error: $e');
        _setState(SpeechRecognitionState.error);
        _isListening = false;
        _setError('Speech recognition internal error');
        return false;
      }

      if (success) {
        return true;
      } else {
        _setState(SpeechRecognitionState.error);
        _isListening = false;
        _setError('Failed to start listening - microphone may be in use');
        return false;
      }
    } catch (e) {
      _setState(SpeechRecognitionState.error);
      _isListening = false;
      _setError('Failed to start listening: $e');
      return false;
    }
    finally {
      _isOperationInProgress = false;
    }
  }

  // Stop listening
  Future<String?> stopListening() async {
    try {
      if (_isOperationInProgress) {
        _setError('Speech recognition is busy');
        return null;
      }
      _isOperationInProgress = true;
      if (_useWebFallback) {
        // Complete simulated session
        _fallbackTimer?.cancel();
        _fallbackTimer = null;
        _isListening = false;
        _lastRecognizedText = _partialText ?? _lastRecognizedText ?? '';
        _setState(SpeechRecognitionState.completed);
        return _lastRecognizedText;
      }

      if (_state != SpeechRecognitionState.listening) {
        _setError('Cannot stop listening. Not currently listening');
        return null;
      }

      _setState(SpeechRecognitionState.processing);
      _isListening = false;

      try {
        await _speechToText.stop().timeout(const Duration(milliseconds: 700));
      } on TimeoutException {
        // Fallback to cancel for a faster stop on web/timeouts
        try {
          await _speechToText.cancel();
        } catch (_) {}
      }

      // Return the last recognized text
      final recognizedText = _lastRecognizedText;
      _setState(SpeechRecognitionState.completed);
      return recognizedText;
    } catch (e) {
      _setState(SpeechRecognitionState.error);
      _isListening = false;
      _setError('Failed to stop listening: $e');
      return null;
    }
    finally {
      _isOperationInProgress = false;
    }
  }

  // Cancel listening
  Future<bool> cancelListening() async {
    try {
      if (_isOperationInProgress) {
        // Try to still force idle without hitting engine
        _isListening = false;
        _setState(SpeechRecognitionState.idle);
        return true;
      }
      _isOperationInProgress = true;
      if (_useWebFallback) {
        _fallbackTimer?.cancel();
        _fallbackTimer = null;
        _isListening = false;
        _partialText = null;
        _lastRecognizedText = null;
        _setState(SpeechRecognitionState.idle);
        _clearError();
        return true;
      }

      // Try cancel regardless of tracked state to ensure engine cleanup
      await _speechToText.cancel();
      _setState(SpeechRecognitionState.idle);
      _isListening = false;
      _clearError();
      return true;
    } catch (e) {
      _setState(SpeechRecognitionState.error);
      _isListening = false;
      _setError('Failed to cancel listening: $e');
      return false;
    }
    finally {
      _isOperationInProgress = false;
    }
  }

  // Get available locales
  List<String> getAvailableLocales() {
    return [
      'vi_VN', // Vietnamese
      'en_US', // English (US)
      'en_GB', // English (UK)
      'es_ES', // Spanish
      'fr_FR', // French
      'de_DE', // German
      'ja_JP', // Japanese
      'ko_KR', // Korean
      'zh_CN', // Chinese (Simplified)
      'zh_TW', // Chinese (Traditional)
    ];
  }

  // Set locale
  Future<bool> setLocale(String localeId) async {
    try {
      if (!_speechToText.isAvailable) {
        _setError('Speech recognition is not available');
        return false;
      }

      // Check if locale is supported
      final supportedLocales = getAvailableLocales();
      if (!supportedLocales.contains(localeId)) {
        _setError('Locale $localeId is not supported');
        return false;
      }

      // Stop current listening if active
      if (_isListening) {
        await _speechToText.stop();
      }

      // Update locale
      _setState(SpeechRecognitionState.idle);
      _clearError();
      return true;
    } catch (e) {
      _setError('Failed to set locale: $e');
      return false;
    }
  }

  // Get current locale
  String? getCurrentLocale() {
    return 'vi_VN'; // Default to Vietnamese
  }

  // Check if microphone is available
  Future<bool> isMicrophoneAvailable() async {
    try {
      return await _speechToText.hasPermission;
    } catch (e) {
      return false;
    }
  }

  // Request microphone permission
  Future<bool> requestPermission() async {
    try {
      await _forceReleaseResources();
      return await _speechToText.initialize(
        onStatus: _handleStatusChange,
        onError: kIsWeb
            ? null
            : (error) {
                final message = _extractErrorMessage(error);
                _handleError(message);
              },
      );
    } catch (e) {
      return false;
    }
  }

  // Clear recognized text
  void clearRecognizedText() {
    _lastRecognizedText = null;
  }

  // Ensure clean state before starting new session
  Future<void> _ensureCleanState() async {
    try {
      // Force stop and cancel any existing session
      if (_isListening || _state != SpeechRecognitionState.idle) {
        debugPrint('Speech recognition cleaning state: $_state, listening: $_isListening');
        
        // Try to stop first
        try {
          await _speechToText.stop();
          await Future.delayed(const Duration(milliseconds: 150));
        } catch (e) {
          debugPrint('Error during speech stop: $e');
        }
        
        // Then cancel to ensure complete cleanup
        try {
          await _speechToText.cancel();
          await Future.delayed(const Duration(milliseconds: 200));
        } catch (e) {
          debugPrint('Error during speech cancel: $e');
        }
      }
      
      // Reset all internal state variables
      _isListening = false;
      _lastRecognizedText = null;
      _partialText = null;
      _currentVolume = 0.0;
      _state = SpeechRecognitionState.idle;
      _clearError();
      
      // Notify state change
      _onStateChanged?.call(_state);
      
      debugPrint('Speech recognition state cleaned to: $_state');
    } catch (e) {
      debugPrint('Error ensuring clean state: $e');
      // Force reset even if there were errors
      _isListening = false;
      _state = SpeechRecognitionState.idle;
      _clearError();
    }
  }

  // Reset service
  Future<void> reset() async {
    try {
      if (_isOperationInProgress) return;
      _isOperationInProgress = true;
      await _ensureCleanState();
    } catch (e) {
      _setError('Failed to reset speech recognition: $e');
    }
    finally {
      _isOperationInProgress = false;
    }
  }

  // Allow external config to control fallback behavior
  void setUseWebFallback(bool value) {
    _useWebFallback = value;
  }

  // Private helper methods
  void _handleStatusChange(String status) {
    switch (status) {
      case 'listening':
        _setState(SpeechRecognitionState.listening);
        _isListening = true;
        break;
      case 'notListening':
        _setState(SpeechRecognitionState.idle);
        _isListening = false;
        break;
      case 'done':
        _setState(SpeechRecognitionState.completed);
        _isListening = false;
        break;
      case 'error':
        _setState(SpeechRecognitionState.error);
        _isListening = false;
        break;
    }
  }

  void _handleRecognitionResult(SpeechRecognitionResult result) {
    try {
      if (result.finalResult) {
        // Final result - speech recognition completed
        _lastRecognizedText = result.recognizedWords;
        _setState(SpeechRecognitionState.completed);
        _isListening = false;
        _onTextRecognized?.call(_lastRecognizedText!);
        _onPartialTextRecognized?.call(''); // Clear partial text
      } else {
        // Partial result - real-time transcription
        _lastRecognizedText = result.recognizedWords;
        if (_enableRealTimeResults) {
          _onPartialTextRecognized?.call(_lastRecognizedText!);
        }
        _onTextRecognized?.call(_lastRecognizedText!);
      }
    } catch (e) {
      _setError('Failed to process recognition result: $e');
    }
  }

  // Safe wrapper for handling recognition results to catch web platform errors
  void _handleRecognitionResultSafely(SpeechRecognitionResult result) {
    try {
      _handleRecognitionResult(result);
    } catch (e) {
      // Handle any unexpected errors from speech_to_text package
      debugPrint('Error in recognition result handler: $e');
      try {
        _setError('Speech recognition processing error');
        _setState(SpeechRecognitionState.error);
        _isListening = false;
      } catch (e2) {
        debugPrint('Critical error in error handling: $e2');
      }
    }
  }

  void _handleError(String error) {
    _setError(error);
    _setState(SpeechRecognitionState.error);
    _isListening = false;
    _onError?.call(error);
  }

  // (sound level handler removed; not used)

  void _setState(SpeechRecognitionState newState) {
    if (_canTransition(_state, newState)) {
      _state = newState;
      _lastStateChangeAt = DateTime.now();
      _onStateChanged?.call(newState);
    } else {
      debugPrint('Ignored invalid state transition: $_state -> $newState');
    }
  }

  void _setError(String message) {
    _errorMessage = message;
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Extract error message safely from different error types
  String _extractErrorMessage(dynamic error) {
    try {
      if (error == null) {
        return 'Unknown speech recognition error';
      }
      
      // Handle different error types
      String errorStr = error.toString();
      
      // Try to extract meaningful error message from various formats
      if (errorStr.contains('errorMsg:')) {
        try {
          final parts = errorStr.split('errorMsg:');
          if (parts.length > 1) {
            final msgPart = parts[1].split('}')[0].trim();
            if (msgPart.isNotEmpty) {
              return msgPart;
            }
          }
        } catch (e) {
          // Continue to fallback
        }
      }
      
      // Check for common error patterns
      if (errorStr.contains('network') || errorStr.contains('connection')) {
        return 'Network connection error';
      } else if (errorStr.contains('permission') || errorStr.contains('denied')) {
        return 'Microphone permission denied';
      } else if (errorStr.contains('not-supported')) {
        return 'Speech recognition not supported';
      } else if (errorStr.contains('busy') || errorStr.contains('in use')) {
        return 'Microphone is busy or in use';
      }
      
      // Return the raw error string if no specific pattern matched
      return errorStr.isNotEmpty ? errorStr : 'Speech recognition error occurred';
    } catch (e) {
      return 'Speech recognition error occurred';
    }
  }

  // Cleanup
  void dispose() {
    try {
      if (_isListening || _state != SpeechRecognitionState.idle) {
        // Try a fast stop first, then cancel; ignore errors
        _speechToText
            .stop()
            .timeout(const Duration(milliseconds: 400))
            .catchError((_) {})
            .whenComplete(() => _speechToText.cancel().catchError((_) {}));
      }
    } catch (e) {
      debugPrint('Error during speech service disposal: $e');
    }
    
    _isListening = false;
    _state = SpeechRecognitionState.idle;
    _onStateChanged = null;
    _onTextRecognized = null;
    _onPartialTextRecognized = null;
    _onError = null;
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  // Force-release underlying engine resources regardless of state
  Future<void> _forceReleaseResources() async {
    try {
      // Try stop with timeout, then cancel
      try {
        await _speechToText.stop().timeout(const Duration(milliseconds: 300));
      } catch (_) {}
      try {
        await _speechToText.cancel().timeout(const Duration(milliseconds: 300));
      } catch (_) {}
    } catch (_) {
      // Ignore
    }
  }
}