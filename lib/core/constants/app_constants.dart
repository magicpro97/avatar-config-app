// Application Constants
class AppConstants {
  // App Information
  static const String appName = 'Avatar Config App';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'avatar_config.db';
  static const int databaseVersion = 2;
  
  // Cache Settings
  static const int maxCachedVoices = 50;
  static const int maxAudioCacheSize = 100 * 1024 * 1024; // 100MB
  static const Duration cacheExpiry = Duration(days: 7);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double cardElevation = 4.0;
  static const double borderRadius = 12.0;
  
  // Audio Settings
  static const int sampleRate = 44100;
  static const String audioFormat = 'mp3';
  
  // Personality Types
  static const List<String> personalityTypes = [
    'happy',
    'romantic',
    'funny',
    'professional',
    'casual',
    'energetic',
    'calm',
    'mysterious',
  ];
}