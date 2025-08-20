// Service for managing API configurations
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfigService {
  static const _storage = FlutterSecureStorage();
  static SharedPreferences? _webStorage;
  
  // Storage keys
  static const String _elevenLabsApiKeyKey = 'elevenlabs_api_key';
  static const String _openAiApiKeyKey = 'openai_api_key';
  
  // Web storage fallback
  static Future<SharedPreferences> get _webPrefs async {
    _webStorage ??= await SharedPreferences.getInstance();
    return _webStorage!;
  }
  
  /// Get ElevenLabs API key
  static Future<String?> getElevenLabsApiKey() async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        return prefs.getString(_elevenLabsApiKeyKey);
      }
      return await _storage.read(key: _elevenLabsApiKeyKey);
    } catch (e) {
      // Fallback to web storage if secure storage fails
      if (!kIsWeb) {
        try {
          final prefs = await _webPrefs;
          return prefs.getString(_elevenLabsApiKeyKey);
        } catch (_) {}
      }
      return null;
    }
  }
  
  /// Set ElevenLabs API key
  static Future<void> setElevenLabsApiKey(String apiKey) async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        await prefs.setString(_elevenLabsApiKeyKey, apiKey);
        return;
      }
      await _storage.write(key: _elevenLabsApiKeyKey, value: apiKey);
    } catch (e) {
      // Fallback to web storage if secure storage fails
      if (!kIsWeb) {
        try {
          final prefs = await _webPrefs;
          await prefs.setString(_elevenLabsApiKeyKey, apiKey);
        } catch (_) {}
      }
    }
  }
  
  /// Get OpenAI API key
  static Future<String?> getOpenAiApiKey() async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        return prefs.getString(_openAiApiKeyKey);
      }
      return await _storage.read(key: _openAiApiKeyKey);
    } catch (e) {
      // Fallback to web storage if secure storage fails
      if (!kIsWeb) {
        try {
          final prefs = await _webPrefs;
          return prefs.getString(_openAiApiKeyKey);
        } catch (_) {}
      }
      return null;
    }
  }
  
  /// Set OpenAI API key
  static Future<void> setOpenAiApiKey(String apiKey) async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        await prefs.setString(_openAiApiKeyKey, apiKey);
        return;
      }
      await _storage.write(key: _openAiApiKeyKey, value: apiKey);
    } catch (e) {
      // Fallback to web storage if secure storage fails
      if (!kIsWeb) {
        try {
          final prefs = await _webPrefs;
          await prefs.setString(_openAiApiKeyKey, apiKey);
        } catch (_) {}
      }
    }
  }
  
  /// Remove ElevenLabs API key
  static Future<void> removeElevenLabsApiKey() async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        await prefs.remove(_elevenLabsApiKeyKey);
        return;
      }
      await _storage.delete(key: _elevenLabsApiKeyKey);
    } catch (e) {
      // Fallback to web storage if secure storage fails
      if (!kIsWeb) {
        try {
          final prefs = await _webPrefs;
          await prefs.remove(_elevenLabsApiKeyKey);
        } catch (_) {}
      }
    }
  }
  
  /// Remove OpenAI API key
  static Future<void> removeOpenAiApiKey() async {
    try {
      if (kIsWeb) {
        final prefs = await _webPrefs;
        await prefs.remove(_openAiApiKeyKey);
        return;
      }
      await _storage.delete(key: _openAiApiKeyKey);
    } catch (e) {
      // Fallback to web storage if secure storage fails
      if (!kIsWeb) {
        try {
          final prefs = await _webPrefs;
          await prefs.remove(_openAiApiKeyKey);
        } catch (_) {}
      }
    }
  }
  
  /// Check if ElevenLabs API key is configured
  static Future<bool> hasElevenLabsApiKey() async {
    final key = await getElevenLabsApiKey();
    return key != null && key.isNotEmpty;
  }
  
  /// Check if OpenAI API key is configured
  static Future<bool> hasOpenAiApiKey() async {
    final key = await getOpenAiApiKey();
    return key != null && key.isNotEmpty;
  }
  
  /// Validate OpenAI API key format (basic validation)
  static bool isValidOpenAiApiKey(String apiKey) {
    return apiKey.startsWith('sk-') && apiKey.length > 20;
  }
  
  /// Validate ElevenLabs API key format (basic validation)
  static bool isValidElevenLabsApiKey(String apiKey) {
    return apiKey.length > 10; // Basic length check
  }
  
  /// Debug method to check API key status
  static Future<Map<String, dynamic>> debugApiKeys() async {
    try {
      final openAiKey = await getOpenAiApiKey();
      final elevenLabsKey = await getElevenLabsApiKey();
      
      return {
        'openai_has_key': openAiKey != null && openAiKey.isNotEmpty,
        'openai_key_length': openAiKey?.length ?? 0,
        'openai_key_preview': openAiKey != null ? '${openAiKey.substring(0, 7)}...' : null,
        'elevenlabs_has_key': elevenLabsKey != null && elevenLabsKey.isNotEmpty,
        'elevenlabs_key_length': elevenLabsKey?.length ?? 0,
        'elevenlabs_key_preview': elevenLabsKey != null ? '${elevenLabsKey.substring(0, 7)}...' : null,
        'platform': kIsWeb ? 'web' : 'native',
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'platform': kIsWeb ? 'web' : 'native',
      };
    }
  }
}