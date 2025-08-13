// Storage Keys for SharedPreferences and Secure Storage
class StorageKeys {
  // Secure Storage Keys (for sensitive data)
  static const String elevenlabsApiKey = 'elevenlabs_api_key';
  static const String userToken = 'user_token';
  
  // SharedPreferences Keys
  static const String isFirstLaunch = 'is_first_launch';
  static const String selectedTheme = 'selected_theme';
  static const String audioQuality = 'audio_quality';
  static const String autoSaveEnabled = 'auto_save_enabled';
  static const String notificationsEnabled = 'notifications_enabled';
  static const String lastSyncTime = 'last_sync_time';
  static const String activeConfigurationId = 'active_configuration_id';
  
  // Cache Keys
  static const String voicesCacheKey = 'cached_voices';
  static const String lastVoiceUpdateTime = 'last_voice_update_time';
  static const String audioCacheDirectory = 'audio_cache';
  
  // Database Table Names
  static const String avatarConfigurationsTable = 'avatar_configurations';
  static const String cachedVoicesTable = 'cached_voices';
  static const String audioCacheTable = 'audio_cache';
}