// API Constants for the Avatar Configuration App
class ApiConstants {
  // ElevenLabs API endpoints
  static const String baseUrl = 'https://api.elevenlabs.io';
  static const String voicesEndpoint = '/v1/voices';
  static const String textToSpeechEndpoint = '/v1/text-to-speech';
  static const String voiceSettingsEndpoint = '/v1/voices/{voice_id}/settings';
  
  // Request timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 60000; // 60 seconds
  
  // Headers
  static const String contentType = 'application/json';
  static const String authorizationHeader = 'xi-api-key';
}