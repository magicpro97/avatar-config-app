// Service for managing API configurations
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiConfigService {
  static const _storage = FlutterSecureStorage();
  
  // Storage keys
  static const String _elevenLabsApiKeyKey = 'elevenlabs_api_key';
  static const String _openAiApiKeyKey = 'openai_api_key';
  
  /// Get ElevenLabs API key
  static Future<String?> getElevenLabsApiKey() async {
    return await _storage.read(key: _elevenLabsApiKeyKey);
  }
  
  /// Set ElevenLabs API key
  static Future<void> setElevenLabsApiKey(String apiKey) async {
    await _storage.write(key: _elevenLabsApiKeyKey, value: apiKey);
  }
  
  /// Get OpenAI API key
  static Future<String?> getOpenAiApiKey() async {
    return await _storage.read(key: _openAiApiKeyKey);
  }
  
  /// Set OpenAI API key
  static Future<void> setOpenAiApiKey(String apiKey) async {
    await _storage.write(key: _openAiApiKeyKey, value: apiKey);
  }
  
  /// Remove ElevenLabs API key
  static Future<void> removeElevenLabsApiKey() async {
    await _storage.delete(key: _elevenLabsApiKeyKey);
  }
  
  /// Remove OpenAI API key
  static Future<void> removeOpenAiApiKey() async {
    await _storage.delete(key: _openAiApiKeyKey);
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
}