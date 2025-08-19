// Platform-aware Database Helper
import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart' as app_exceptions;
import '../utils/platform_utils.dart';
import 'web_storage_helper.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;
  static WebStorageHelper? _webStorage;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    _instance ??= DatabaseHelper._internal();
    return _instance!;
  }

  Future<Database> get database async {
    if (PlatformUtils.isWeb) {
      throw app_exceptions.DatabaseException(
        message: 'SQLite database not available on web. Use web storage methods instead.',
      );
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  WebStorageHelper get webStorage {
    _webStorage ??= WebStorageHelper();
    return _webStorage!;
  }

  Future<Database> _initDatabase() async {
    if (PlatformUtils.isWeb) {
      throw app_exceptions.DatabaseException(
        message: 'SQLite database not supported on web platform',
      );
    }
    
    try {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, AppConstants.databaseName);

      return await openDatabase(
        path,
        version: AppConstants.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to initialize database: $e');
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${StorageKeys.avatarConfigurationsTable} (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        personality_data TEXT NOT NULL,
        voice_data TEXT NOT NULL,
        created_date INTEGER NOT NULL,
        updated_date INTEGER NOT NULL,
        last_used_date INTEGER,
        usage_count INTEGER DEFAULT 0,
        is_favorite INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 0,
        tags TEXT,
        export_data TEXT
      )
    ''');

    // Create indexes for performance
    await db.execute('CREATE INDEX idx_avatar_name ON ${StorageKeys.avatarConfigurationsTable} (name)');
    await db.execute('CREATE INDEX idx_avatar_created_date ON ${StorageKeys.avatarConfigurationsTable} (created_date DESC)');
    await db.execute('CREATE INDEX idx_avatar_updated_date ON ${StorageKeys.avatarConfigurationsTable} (updated_date DESC)');
    await db.execute('CREATE INDEX idx_avatar_usage_count ON ${StorageKeys.avatarConfigurationsTable} (usage_count DESC)');
    await db.execute('CREATE INDEX idx_avatar_is_favorite ON ${StorageKeys.avatarConfigurationsTable} (is_favorite DESC)');
    await db.execute('CREATE INDEX idx_avatar_is_active ON ${StorageKeys.avatarConfigurationsTable} (is_active DESC)');

    await db.execute('''
      CREATE TABLE cached_voices (
        voice_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        gender TEXT,
        language TEXT,
        accent TEXT,
        labels TEXT,
        preview_url TEXT,
        settings TEXT,
        available INTEGER DEFAULT 1,
        cached_at INTEGER NOT NULL,
        expires_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${StorageKeys.audioCacheTable} (
        id TEXT PRIMARY KEY,
        text_hash TEXT NOT NULL,
        voice_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        file_size INTEGER
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Voice caching improvements
      await db.execute('ALTER TABLE cached_voices ADD COLUMN settings TEXT');
      await db.execute('ALTER TABLE cached_voices ADD COLUMN available INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE cached_voices ADD COLUMN expires_at INTEGER NOT NULL DEFAULT 0');
      
      // Update avatar configurations table for enhanced features
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN description TEXT');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN personality_data TEXT');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN voice_data TEXT');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN created_date INTEGER');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN updated_date INTEGER');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN last_used_date INTEGER');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN usage_count INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN is_favorite INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN tags TEXT');
      await db.execute('ALTER TABLE ${StorageKeys.avatarConfigurationsTable} ADD COLUMN export_data TEXT');
      
      // Migrate existing data if any
      await _migrateAvatarConfigurationsData(db);
      
      // Create new indexes
      await db.execute('CREATE INDEX IF NOT EXISTS idx_avatar_name ON ${StorageKeys.avatarConfigurationsTable} (name)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_avatar_created_date ON ${StorageKeys.avatarConfigurationsTable} (created_date DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_avatar_updated_date ON ${StorageKeys.avatarConfigurationsTable} (updated_date DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_avatar_usage_count ON ${StorageKeys.avatarConfigurationsTable} (usage_count DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_avatar_is_favorite ON ${StorageKeys.avatarConfigurationsTable} (is_favorite DESC)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_avatar_is_active ON ${StorageKeys.avatarConfigurationsTable} (is_active DESC)');
    }
  }

  Future<void> _migrateAvatarConfigurationsData(Database db) async {
    // Migrate existing avatar configurations to new schema
    final List<Map<String, dynamic>> existingConfigs = await db.query(
      StorageKeys.avatarConfigurationsTable,
    );

    debugPrint('Migrating ${existingConfigs.length} existing configurations');

    int successfulMigrations = 0;
    int failedMigrations = 0;

    for (final config in existingConfigs) {
      try {
        final now = DateTime.now().millisecondsSinceEpoch;
        
        // Enhanced personality type migration with comprehensive error handling
        String personalityType = 'casual'; // Default
        if (config['personality_type'] != null) {
          final oldPersonalityType = config['personality_type'] as String;
          debugPrint('Migrating personality type: $oldPersonalityType');
          
          // Enhanced validation and mapping of personality types
          final validTypes = ['happy', 'romantic', 'funny', 'professional', 'casual', 'energetic', 'calm', 'mysterious'];
          if (validTypes.contains(oldPersonalityType)) {
            personalityType = oldPersonalityType;
            debugPrint('Valid personality type mapped: $personalityType');
          } else {
            debugPrint('WARNING: Unknown personality type $oldPersonalityType, defaulting to casual');
            // Log the unknown type for future analysis
            debugPrint('Unknown personality type encountered: $oldPersonalityType in config: ${config['id']}');
          }
        } else {
          debugPrint('No personality_type found in config: ${config['id']}, using default casual');
        }
        
        debugPrint('Using personality type: $personalityType');

        // Enhanced voice data migration with fallback handling
        final voiceData = {
          'voiceId': config['voice_id'] ?? '',
          'name': config['voice_name'] ?? 'Default Voice',
          'gender': config['voice_gender'] ?? 'neutral',
          'language': config['voice_language'] ?? 'en',
          'accent': config['voice_accent'] ?? 'american',
          'settings': config['voice_settings'] ?? jsonEncode({})
        };

        // Validate voice data
        if (voiceData['voiceId'].isEmpty) {
          debugPrint('WARNING: Empty voiceId for config: ${config['id']}, using default');
          voiceData['voiceId'] = 'default';
        }

        // Update records with new field values
        final updateData = {
          'personality_data': jsonEncode({
            'type': personalityType,
            'parameters': {}
          }),
          'voice_data': jsonEncode(voiceData),
          'created_date': config['created_at'] ?? now,
          'updated_date': config['last_modified'] ?? now,
          'usage_count': config['usage_count'] ?? 0,
          'is_favorite': config['is_favorite'] ?? 0,
        };

        // Only update if the record exists
        final updateResult = await db.update(
          StorageKeys.avatarConfigurationsTable,
          updateData,
          where: 'id = ?',
          whereArgs: [config['id']],
        );
        
        if (updateResult > 0) {
          debugPrint('Successfully migrated configuration: ${config['id']}');
          successfulMigrations++;
        } else {
          debugPrint('WARNING: No rows updated for configuration: ${config['id']}');
          failedMigrations++;
        }
      } catch (e, stackTrace) {
        debugPrint('ERROR: Failed to migrate configuration ${config['id']}: $e');
        debugPrint('ERROR: Stack trace: $stackTrace');
        debugPrint('ERROR: Config data: $config');
        failedMigrations++;
        // Continue with other configurations to avoid blocking the entire migration
      }
    }
    
    debugPrint('Migration completed. Successful: $successfulMigrations, Failed: $failedMigrations');
    
    if (failedMigrations > 0) {
      debugPrint('WARNING: $failedMigrations configurations failed to migrate. Check logs for details.');
    }
  }

  Future<void> close() async {
    if (PlatformUtils.isWeb) {
      await webStorage.close();
      return;
    }
    
    final db = await database;
    await db.close();
    _database = null;
  }

  // Platform-aware database utility methods
  Future<void> vacuum() async {
    if (PlatformUtils.isWeb) {
      await webStorage.vacuum();
      return;
    }
    
    final db = await database;
    await db.execute('VACUUM');
  }

  Future<void> analyze() async {
    if (PlatformUtils.isWeb) {
      await webStorage.analyze();
      return;
    }
    
    final db = await database;
    await db.execute('ANALYZE');
  }

  Future<int> getDatabaseSize() async {
    if (PlatformUtils.isWeb) {
      return await webStorage.getDatabaseSize();
    }
    
    final db = await database;
    final result = await db.rawQuery('PRAGMA page_count');
    final pageCount = result.first['page_count'] as int;
    final pageSizeResult = await db.rawQuery('PRAGMA page_size');
    final pageSize = pageSizeResult.first['page_size'] as int;
    return pageCount * pageSize;
  }

  Future<Map<String, int>> getTableCounts() async {
    if (PlatformUtils.isWeb) {
      final Map<String, int> counts = {};
      
      // Get avatar configurations count
      final avatarResult = await webStorage.rawQuery('SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable}');
      counts['avatar_configurations'] = avatarResult.isNotEmpty ? avatarResult.first['count'] as int : 0;
      
      // Get cached voices count
      final voicesResult = await webStorage.rawQuery('SELECT COUNT(*) as count FROM cached_voices');
      counts['cached_voices'] = voicesResult.isNotEmpty ? voicesResult.first['count'] as int : 0;
      
      // Audio cache not supported on web
      counts['audio_cache'] = 0;
      
      return counts;
    }
    
    final db = await database;
    final Map<String, int> counts = {};
    
    // Get avatar configurations count
    final avatarResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable}');
    counts['avatar_configurations'] = avatarResult.first['count'] as int;
    
    // Get cached voices count
    final voicesResult = await db.rawQuery('SELECT COUNT(*) as count FROM cached_voices');
    counts['cached_voices'] = voicesResult.first['count'] as int;
    
    // Get audio cache count
    final audioResult = await db.rawQuery('SELECT COUNT(*) as count FROM ${StorageKeys.audioCacheTable}');
    counts['audio_cache'] = audioResult.first['count'] as int;
    
    return counts;
  }
}