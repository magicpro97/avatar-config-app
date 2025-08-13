// Database Migration Management System
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import '../constants/storage_keys.dart';

class DatabaseMigrations {
  static const int initialVersion = 1;
  static const int currentVersion = 2;

  static Future<void> migrate(Database db, int oldVersion, int newVersion) async {
    for (int version = oldVersion + 1; version <= newVersion; version++) {
      await _executeMigration(db, version);
    }
  }

  static Future<void> _executeMigration(Database db, int version) async {
    switch (version) {
      case 2:
        await _migrateToVersion2(db);
        break;
      default:
        throw Exception('Unknown migration version: $version');
    }
  }

  static Future<void> _migrateToVersion2(Database db) async {
    // Enhanced avatar configurations with advanced features
    try {
      // Check if columns already exist to avoid errors
      final tableInfo = await db.rawQuery('PRAGMA table_info(${StorageKeys.avatarConfigurationsTable})');
      final existingColumns = tableInfo.map((row) => row['name'] as String).toSet();

      // Add new columns only if they don't exist
      if (!existingColumns.contains('description')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN description TEXT');
      }
      if (!existingColumns.contains('personality_data')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN personality_data TEXT');
      }
      if (!existingColumns.contains('voice_data')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN voice_data TEXT');
      }
      if (!existingColumns.contains('created_date')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN created_date INTEGER');
      }
      if (!existingColumns.contains('updated_date')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN updated_date INTEGER');
      }
      if (!existingColumns.contains('last_used_date')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN last_used_date INTEGER');
      }
      if (!existingColumns.contains('usage_count')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN usage_count INTEGER DEFAULT 0');
      }
      if (!existingColumns.contains('is_favorite')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN is_favorite INTEGER DEFAULT 0');
      }
      if (!existingColumns.contains('tags')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN tags TEXT');
      }
      if (!existingColumns.contains('export_data')) {
        await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN export_data TEXT');
      }

      // Migrate existing data
      await _migrateExistingData(db);

      // Create performance indexes
      await _createPerformanceIndexes(db);

      // Add voice caching improvements
      await _enhanceVoiceCaching(db);

    } catch (e) {
      throw Exception('Failed to migrate to version 2: $e');
    }
  }

  static Future<void> _migrateExistingData(Database db) async {
    // Get all existing configurations
    final List<Map<String, dynamic>> existingConfigs = await db.query(
      StorageKeys.avatarConfigurationsTable,
    );

    for (final config in existingConfigs) {
      final now = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> updateData = {};

      // Migrate personality data
      if (config['personality_data'] == null && config['personality_type'] != null) {
        updateData['personality_data'] = jsonEncode({
          'type': config['personality_type'],
          'parameters': {}
        });
      }

      // Migrate voice data
      if (config['voice_data'] == null) {
        updateData['voice_data'] = jsonEncode({
          'voiceId': config['voice_id'] ?? '',
          'name': 'Default Voice',
          'gender': 'neutral',
          'language': 'en',
          'accent': 'american',
          'settings': config['voice_settings'] != null 
              ? jsonDecode(config['voice_settings']) 
              : {}
        });
      }

      // Set timestamps
      if (config['created_date'] == null) {
        updateData['created_date'] = config['created_at'] ?? now;
      }
      if (config['updated_date'] == null) {
        updateData['updated_date'] = config['last_modified'] ?? now;
      }

      // Set default values
      if (config['usage_count'] == null) {
        updateData['usage_count'] = 0;
      }
      if (config['is_favorite'] == null) {
        updateData['is_favorite'] = 0;
      }

      // Update the record if there's data to update
      if (updateData.isNotEmpty) {
        await db.update(
          StorageKeys.avatarConfigurationsTable,
          updateData,
          where: 'id = ?',
          whereArgs: [config['id']],
        );
      }
    }
  }

  static Future<void> _createPerformanceIndexes(Database db) async {
    // Create indexes for better query performance
    final indexes = [
      'CREATE INDEX IF NOT EXISTS idx_avatar_name ON ${StorageKeys.avatarConfigurationsTable} (name)',
      'CREATE INDEX IF NOT EXISTS idx_avatar_created_date ON ${StorageKeys.avatarConfigurationsTable} (created_date DESC)',
      'CREATE INDEX IF NOT EXISTS idx_avatar_updated_date ON ${StorageKeys.avatarConfigurationsTable} (updated_date DESC)',
      'CREATE INDEX IF NOT EXISTS idx_avatar_usage_count ON ${StorageKeys.avatarConfigurationsTable} (usage_count DESC)',
      'CREATE INDEX IF NOT EXISTS idx_avatar_is_favorite ON ${StorageKeys.avatarConfigurationsTable} (is_favorite DESC)',
      'CREATE INDEX IF NOT EXISTS idx_avatar_is_active ON ${StorageKeys.avatarConfigurationsTable} (is_active DESC)',
      'CREATE INDEX IF NOT EXISTS idx_avatar_last_used ON ${StorageKeys.avatarConfigurationsTable} (last_used_date DESC)',
    ];

    for (final indexSql in indexes) {
      await db.execute(indexSql);
    }
  }

  static Future<void> _enhanceVoiceCaching(Database db) async {
    // Check if voice caching columns exist and add them if needed
    final voiceTableInfo = await db.rawQuery('PRAGMA table_info(cached_voices)');
    final existingVoiceColumns = voiceTableInfo.map((row) => row['name'] as String).toSet();

    if (!existingVoiceColumns.contains('settings')) {
      await db.execute('ALTER TABLE cached_voices ADD COLUMN settings TEXT');
    }
    if (!existingVoiceColumns.contains('available')) {
      await db.execute('ALTER TABLE cached_voices ADD COLUMN available INTEGER DEFAULT 1');
    }
    if (!existingVoiceColumns.contains('expires_at')) {
      await db.execute('ALTER TABLE cached_voices ADD COLUMN expires_at INTEGER DEFAULT 0');
    }
  }

  // Utility method to check current database version
  static Future<int> getCurrentVersion(Database db) async {
    final result = await db.rawQuery('PRAGMA user_version');
    return result.first['user_version'] as int;
  }

  // Utility method to set database version
  static Future<void> setVersion(Database db, int version) async {
    await db.rawQuery('PRAGMA user_version = $version');
  }

  // Rollback capability for development
  static Future<void> rollbackToVersion(Database db, int targetVersion) async {
    if (targetVersion >= currentVersion) {
      throw Exception('Cannot rollback to current or higher version');
    }

    // This is a simplified rollback - in production, you'd want more sophisticated rollback logic
    switch (targetVersion) {
      case 1:
        await _rollbackToVersion1(db);
        break;
      default:
        throw Exception('Rollback to version $targetVersion not supported');
    }
  }

  static Future<void> _rollbackToVersion1(Database db) async {
    // Remove columns added in version 2 (SQLite doesn't support DROP COLUMN easily)
    // For now, we'll just mark the data as legacy
    await db.execute('UPDATE ${StorageKeys.avatarConfigurationsTable} SET description = NULL WHERE description IS NOT NULL');
    await setVersion(db, 1);
  }

  // Database integrity check
  static Future<bool> checkIntegrity(Database db) async {
    final result = await db.rawQuery('PRAGMA integrity_check');
    return result.first['integrity_check'] == 'ok';
  }

  // Database optimization
  static Future<void> optimize(Database db) async {
    await db.execute('VACUUM');
    await db.execute('ANALYZE');
  }
}