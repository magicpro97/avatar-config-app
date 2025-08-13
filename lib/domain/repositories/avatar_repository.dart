// Avatar Repository Interface (Domain Layer)
import '../entities/avatar_configuration.dart';

abstract class AvatarRepository {
  /// Get all avatar configurations
  Future<List<AvatarConfiguration>> getAllConfigurations();

  /// Get a specific configuration by ID
  Future<AvatarConfiguration?> getConfigurationById(String id);

  /// Get the currently active configuration
  Future<AvatarConfiguration?> getActiveConfiguration();

  /// Create a new avatar configuration
  Future<void> createConfiguration(AvatarConfiguration configuration);

  /// Update an existing configuration
  Future<void> updateConfiguration(AvatarConfiguration configuration);

  /// Delete a configuration by ID
  Future<void> deleteConfiguration(String id);

  /// Activate a configuration (and deactivate others)
  Future<void> activateConfiguration(String id);

  /// Deactivate a configuration
  Future<void> deactivateConfiguration(String id);

  /// Search configurations by name or personality
  Future<List<AvatarConfiguration>> searchConfigurations(String query);

  /// Get configurations by personality type
  Future<List<AvatarConfiguration>> getConfigurationsByPersonality(String personalityType);

  /// Get recent configurations (modified in last N days)
  Future<List<AvatarConfiguration>> getRecentConfigurations(int days);

  /// Check if a configuration name already exists
  Future<bool> configurationNameExists(String name, {String? excludeId});

  /// Get configuration count
  Future<int> getConfigurationCount();

  /// Export configurations as JSON
  Future<Map<String, dynamic>> exportConfigurations();

  /// Import configurations from JSON
  Future<void> importConfigurations(Map<String, dynamic> data);

  /// Backup configurations to external storage
  Future<void> backupConfigurations(String filePath);

  /// Restore configurations from backup
  Future<void> restoreConfigurations(String filePath);

  /// Clear all configurations (with confirmation)
  Future<void> clearAllConfigurations();

  /// Get configuration statistics
  Future<Map<String, dynamic>> getConfigurationStats();
}