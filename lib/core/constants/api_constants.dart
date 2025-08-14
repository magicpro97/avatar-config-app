// API Constants for the Avatar Configuration App
class ApiConstants {
  // ElevenLabs API endpoints
  static const String elevenLabsBaseUrl = 'https://api.elevenlabs.io';
  static const String voicesEndpoint = '/v1/voices';
  static const String textToSpeechEndpoint = '/v1/text-to-speech';
  static const String voiceSettingsEndpoint = '/v1/voices/{voice_id}/settings';
  
  // OpenAI API endpoints for personality responses
  static const String openAiBaseUrl = 'https://api.openai.com';
  static const String chatCompletionsEndpoint = '/v1/chat/completions';
  
  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  
  // Headers
  static const String contentType = 'application/json';
  static const String elevenLabsAuthHeader = 'xi-api-key';
  static const String openAiAuthHeader = 'Authorization';
  
  // Default models
  static const String defaultChatModel = 'gpt-3.5-turbo';
  static const String fallbackChatModel = 'gpt-4o-mini';
}