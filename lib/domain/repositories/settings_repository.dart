import '../entities/app_settings.dart';

/// Repository interface for managing application settings
abstract class SettingsRepository {
  /// Load current settings from storage
  Future<AppSettings> getSettings();

  /// Save settings to storage
  Future<void> saveSettings(AppSettings settings);

  /// Reset settings to default values
  Future<void> resetSettings();

  /// Update a specific setting by key
  Future<void> updateSetting<T>(String key, T value);

  /// Get a specific setting value by key
  Future<T?> getSetting<T>(String key);

  /// Export all settings to a map for backup
  Future<Map<String, dynamic>> exportSettings();

  /// Import settings from a backup map
  Future<void> importSettings(Map<String, dynamic> settingsData);

  /// Validate settings data structure
  Future<bool> validateSettings(Map<String, dynamic> settingsData);
}