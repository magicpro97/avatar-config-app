// Speech-to-Text Service for handling voice recognition functionality
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
  Function(String)? _onError;
  double _currentVolume = 0.0;
  bool _isListening = false;

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

  void setErrorListener(Function(String) listener) {
    _onError = listener;
  }

  // Initialize speech recognition
  Future<bool> initialize() async {
    try {
      if (_state != SpeechRecognitionState.idle) {
        _setError('Speech recognition is already initialized or in use');
        return false;
      }

      final isAvailable = await _speechToText.initialize(
        onStatus: _handleStatusChange,
        onError: (error) => _handleError(error.toString()),
      );

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
      return await _speechToText.initialize(
        onStatus: _handleStatusChange,
        onError: (error) => _handleError(error.toString()),
      );
    } catch (e) {
      return false;
    }
  }

  // Start listening for speech
  Future<bool> startListening() async {
    try {
      if (_state != SpeechRecognitionState.idle) {
        _setError('Cannot start listening. Speech recognition is already in use');
        return false;
      }

      if (!_speechToText.isAvailable) {
        _setError('Speech recognition is not available');
        return false;
      }

      _setState(SpeechRecognitionState.listening);
      _isListening = true;
      _clearError();

      final success = await _speechToText.listen(
        onResult: _handleRecognitionResult,
        onSoundLevelChange: _handleSoundLevel,
      );

      if (success) {
        return true;
      } else {
        _setState(SpeechRecognitionState.error);
        _isListening = false;
        _setError('Failed to start listening');
        return false;
      }
    } catch (e) {
      _setState(SpeechRecognitionState.error);
      _isListening = false;
      _setError('Failed to start listening: $e');
      return false;
    }
  }

  // Stop listening
  Future<String?> stopListening() async {
    try {
      if (_state != SpeechRecognitionState.listening) {
        _setError('Cannot stop listening. Not currently listening');
        return null;
      }

      _setState(SpeechRecognitionState.processing);
      _isListening = false;

      await _speechToText.stop();

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
  }

  // Cancel listening
  Future<bool> cancelListening() async {
    try {
      if (_state != SpeechRecognitionState.listening) {
        _setError('Cannot cancel listening. Not currently listening');
        return false;
      }

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
      return await _speechToText.initialize(
        onStatus: _handleStatusChange,
        onError: (error) => _handleError(error.toString()),
      );
    } catch (e) {
      return false;
    }
  }

  // Clear recognized text
  void clearRecognizedText() {
    _lastRecognizedText = null;
  }

  // Reset service
  Future<void> reset() async {
    try {
      // Stop listening if active
      if (_isListening) {
        await _speechToText.stop();
      }

      // Reset state
      _state = SpeechRecognitionState.idle;
      _isListening = false;
      _lastRecognizedText = null;
      _currentVolume = 0.0;
      _clearError();

      _onStateChanged?.call(_state);
    } catch (e) {
      _setError('Failed to reset speech recognition: $e');
    }
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
        _lastRecognizedText = result.recognizedWords;
        _setState(SpeechRecognitionState.completed);
        _isListening = false;
        _onTextRecognized?.call(_lastRecognizedText!);
      } else {
        // Partial result
        _lastRecognizedText = result.recognizedWords;
        _onTextRecognized?.call(_lastRecognizedText!);
      }
    } catch (e) {
      _setError('Failed to process recognition result: $e');
    }
  }

  void _handleError(String error) {
    _setError(error);
    _setState(SpeechRecognitionState.error);
    _isListening = false;
    _onError?.call(error);
  }

  void _handleSoundLevel(double level) {
    _currentVolume = level;
  }

  void _setState(SpeechRecognitionState newState) {
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
    if (_isListening) {
      _speechToText.stop();
    }
    _onStateChanged = null;
    _onTextRecognized = null;
    _onError = null;
  }
}