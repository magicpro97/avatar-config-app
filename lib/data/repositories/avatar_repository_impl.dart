// Real Avatar Repository Implementation with SQLite
import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import '../../domain/repositories/avatar_repository.dart';
import '../../domain/entities/avatar_configuration.dart';
import '../../core/storage/database_helper.dart';
import '../../core/constants/storage_keys.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;
import '../../core/utils/platform_utils.dart';
import '../models/avatar_configuration_model.dart';

class AvatarRepositoryImpl implements AvatarRepository {
  final DatabaseHelper _databaseHelper;

  AvatarRepositoryImpl({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  @override
  Future<List<AvatarConfiguration>> getAllConfigurations() async {
    try {
      print('DEBUG: AvatarRepositoryImpl.getAllConfigurations() called');
      final startTime = DateTime.now();
      
      List<Map<String, dynamic>> maps;
      
      if (PlatformUtils.isWeb) {
        print('DEBUG: Using web storage for query');
        maps = await _databaseHelper.webStorage.queryAvatarConfigurations(
          orderBy: 'updated_date DESC',
        );
      } else {
        print('DEBUG: Using SQLite database for query');
        final db = await _databaseHelper.database;
        maps = await db.query(
          StorageKeys.avatarConfigurationsTable,
          orderBy: 'updated_date DESC',
        );
      }

      print('DEBUG: Found ${maps.length} configurations in database');
      print('DEBUG: Database query took ${DateTime.now().difference(startTime).inMilliseconds}ms');
      
      final conversionStartTime = DateTime.now();
      final result = maps.map((map) {
        print('DEBUG: Processing configuration map: $map');
        try {
          final model = AvatarConfigurationModel.fromMap(map);
          print('DEBUG: Successfully created model from map');
          final domain = model.toDomain();
          print('DEBUG: Successfully converted to domain: $domain');
          return domain;
        } catch (e, stackTrace) {
          print('ERROR: Failed to process configuration map: $e');
          print('ERROR: Stack trace: $stackTrace');
          print('ERROR: Problematic map: $map');
          rethrow;
        }
      }).toList();
      
      print('DEBUG: Domain conversion took ${DateTime.now().difference(conversionStartTime).inMilliseconds}ms');
      print('DEBUG: Total getAllConfigurations operation took ${DateTime.now().difference(startTime).inMilliseconds}ms');
      
      return result;
    } catch (e, stackTrace) {
      print('ERROR: Failed to load configurations: $e');
      print('ERROR: Stack trace: $stackTrace');
      throw app_exceptions.DatabaseException(
        message: 'Failed to load configurations: $e',
      );
    }
  }

  @override
  Future<AvatarConfiguration?> getConfigurationById(String id) async {
    try {
      print('DEBUG: AvatarRepositoryImpl.getConfigurationById() called with id: $id');
      final startTime = DateTime.now();
      
      List<Map<String, dynamic>> maps;
      
      if (PlatformUtils.isWeb) {
        maps = await _databaseHelper.webStorage.queryAvatarConfigurations(
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
      } else {
        final db = await _databaseHelper.database;
        maps = await db.query(
          StorageKeys.avatarConfigurationsTable,
          where: 'id = ?',
          whereArgs: [id],
          limit: 1,
        );
      }

      print('DEBUG: Database query took ${DateTime.now().difference(startTime).inMilliseconds}ms');
      
      if (maps.isEmpty) {
        print('DEBUG: No configuration found with id: $id');
        return null;
      }

      print('DEBUG: Found configuration with id: $id');
      final conversionStartTime = DateTime.now();
      final model = AvatarConfigurationModel.fromMap(maps.first);
      final domain = model.toDomain();
      print('DEBUG: Domain conversion took ${DateTime.now().difference(conversionStartTime).inMilliseconds}ms');
      print('DEBUG: Total getConfigurationById operation took ${DateTime.now().difference(startTime).inMilliseconds}ms');
      
      return domain;
    } catch (e) {
      print('ERROR: Failed to get configuration by ID: $e');
      throw app_exceptions.DatabaseException(
        message: 'Failed to get configuration by ID: $e',
      );
    }
  }

  @override
  Future<AvatarConfiguration?> getActiveConfiguration() async {
    try {
      List<Map<String, dynamic>> maps;
      
      if (PlatformUtils.isWeb) {
        maps = await _databaseHelper.webStorage.queryAvatarConfigurations(
          where: 'is_active = ?',
          whereArgs: [1],
          limit: 1,
        );
      } else {
        final db = await _databaseHelper.database;
        maps = await db.query(
          StorageKeys.avatarConfigurationsTable,
          where: 'is_active = ?',
          whereArgs: [1],
          limit: 1,
        );
      }

      if (maps.isEmpty) return null;

      final model = AvatarConfigurationModel.fromMap(maps.first);
      return model.toDomain();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get active configuration: $e',
      );
    }
  }

  @override
  Future<void> createConfiguration(AvatarConfiguration configuration) async {
    try {
      print('DEBUG: AvatarRepositoryImpl.createConfiguration() called with id: ${configuration.id}');
      final startTime = DateTime.now();
      
      // Convert domain entity to model for storage
      final model = AvatarConfigurationModel.fromDomain(configuration);
      print('DEBUG: Converted domain to model: ${model.name}');
      
      if (PlatformUtils.isWeb) {
        print('DEBUG: Inserting into web storage');
        await _databaseHelper.webStorage.insertAvatarConfiguration(model.toMap());
      } else {
        print('DEBUG: Inserting into SQLite database');
        final db = await _databaseHelper.database;
        await db.insert(
          StorageKeys.avatarConfigurationsTable,
          model.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      
      print('DEBUG: Successfully created configuration: ${configuration.id}');
      print('DEBUG: Total createConfiguration operation took ${DateTime.now().difference(startTime).inMilliseconds}ms');
    } catch (e) {
      print('ERROR: Failed to create configuration: $e');
      throw app_exceptions.DatabaseException(
        message: 'Failed to create configuration: $e',
      );
    }
  }

  @override
  Future<void> updateConfiguration(AvatarConfiguration configuration) async {
    try {
      print('DEBUG: AvatarRepositoryImpl.updateConfiguration() called with id: ${configuration.id}');
      final startTime = DateTime.now();
      
      // Convert domain entity to model
      final model = AvatarConfigurationModel.fromDomain(configuration);
      final updatedModel = model.copyWith(lastModified: DateTime.now());
      print('DEBUG: Converted domain to model for update: ${updatedModel.name}');
      
      int result;
      if (PlatformUtils.isWeb) {
        print('DEBUG: Updating web storage');
        result = await _databaseHelper.webStorage.updateAvatarConfiguration(
          updatedModel.toMap(),
          'id = ?',
          [configuration.id],
        );
      } else {
        print('DEBUG: Updating SQLite database');
        final db = await _databaseHelper.database;
        result = await db.update(
          StorageKeys.avatarConfigurationsTable,
          updatedModel.toMap(),
          where: 'id = ?',
          whereArgs: [configuration.id],
        );
      }

      print('DEBUG: Update result: $result rows affected');
      
      if (result == 0) {
        print('ERROR: Configuration not found for update: ${configuration.id}');
        throw app_exceptions.DatabaseException(
          message: 'Configuration not found for update: ${configuration.id}',
        );
      }
      
      print('DEBUG: Successfully updated configuration: ${configuration.id}');
      print('DEBUG: Total updateConfiguration operation took ${DateTime.now().difference(startTime).inMilliseconds}ms');
    } catch (e) {
      print('ERROR: Failed to update configuration: $e');
      throw app_exceptions.DatabaseException(
        message: 'Failed to update configuration: $e',
      );
    }
  }

  @override
  Future<void> deleteConfiguration(String id) async {
    try {
      int result;
      
      if (PlatformUtils.isWeb) {
        result = await _databaseHelper.webStorage.deleteAvatarConfiguration(
          'id = ?',
          [id],
        );
      } else {
        final db = await _databaseHelper.database;
        result = await db.delete(
          StorageKeys.avatarConfigurationsTable,
          where: 'id = ?',
          whereArgs: [id],
        );
      }

      if (result == 0) {
        throw app_exceptions.DatabaseException(
          message: 'Configuration not found for deletion: $id',
        );
      }
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to delete configuration: $e',
      );
    }
  }

  @override
  Future<void> activateConfiguration(String id) async {
    try {
      if (PlatformUtils.isWeb) {
        // Web storage transaction simulation
        await _databaseHelper.webStorage.transaction(() async {
          // First, deactivate all configurations
          await _databaseHelper.webStorage.updateAvatarConfiguration(
            {
              'is_active': 0,
              'updated_date': DateTime.now().millisecondsSinceEpoch,
            },
            'is_active = ?',
            [1],
          );

          // Then activate the specified configuration
          final result = await _databaseHelper.webStorage.updateAvatarConfiguration(
            {
              'is_active': 1,
              'last_used_date': DateTime.now().millisecondsSinceEpoch,
              'updated_date': DateTime.now().millisecondsSinceEpoch,
            },
            'id = ?',
            [id],
          );

          if (result == 0) {
            throw app_exceptions.DatabaseException(
              message: 'Configuration not found for activation: $id',
            );
          }

          // Increment usage count (simulated)
          final configs = await _databaseHelper.webStorage.queryAvatarConfigurations(
            where: 'id = ?',
            whereArgs: [id],
          );
          if (configs.isNotEmpty) {
            final config = configs.first;
            await _databaseHelper.webStorage.updateAvatarConfiguration(
              {
                'usage_count': (config['usage_count'] ?? 0) + 1,
              },
              'id = ?',
              [id],
            );
          }
        });
      } else {
        final db = await _databaseHelper.database;
        
        await db.transaction((txn) async {
          // First, deactivate all configurations
          await txn.update(
            StorageKeys.avatarConfigurationsTable,
            {
              'is_active': 0,
              'updated_date': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'is_active = ?',
            whereArgs: [1],
          );

          // Then activate the specified configuration
          final result = await txn.update(
            StorageKeys.avatarConfigurationsTable,
            {
              'is_active': 1,
              'last_used_date': DateTime.now().millisecondsSinceEpoch,
              'updated_date': DateTime.now().millisecondsSinceEpoch,
            },
            where: 'id = ?',
            whereArgs: [id],
          );

          if (result == 0) {
            throw app_exceptions.DatabaseException(
              message: 'Configuration not found for activation: $id',
            );
          }

          // Increment usage count
          await txn.rawUpdate(
            'UPDATE ${StorageKeys.avatarConfigurationsTable} SET usage_count = usage_count + 1 WHERE id = ?',
            [id],
          );
        });
      }
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to activate configuration: $e',
      );
    }
  }

  @override
  Future<void> deactivateConfiguration(String id) async {
    try {
      int result;
      
      if (PlatformUtils.isWeb) {
        result = await _databaseHelper.webStorage.updateAvatarConfiguration(
          {
            'is_active': 0,
            'updated_date': DateTime.now().millisecondsSinceEpoch,
          },
          'id = ?',
          [id],
        );
      } else {
        final db = await _databaseHelper.database;
        result = await db.update(
          StorageKeys.avatarConfigurationsTable,
          {
            'is_active': 0,
            'updated_date': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
      }

      if (result == 0) {
        throw app_exceptions.DatabaseException(
          message: 'Configuration not found for deactivation: $id',
        );
      }
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to deactivate configuration: $e',
      );
    }
  }

  @override
  Future<List<AvatarConfiguration>> searchConfigurations(String query) async {
    try {
      final db = await _databaseHelper.database;
      
      // Search by name, description, and tags
      final List<Map<String, dynamic>> maps = await db.query(
        StorageKeys.avatarConfigurationsTable,
        where: '''
          name LIKE ? OR 
          description LIKE ? OR 
          tags LIKE ? OR
          personality_data LIKE ?
        ''',
        whereArgs: [
          '%$query%',
          '%$query%',
          '%$query%',
          '%$query%',
        ],
        orderBy: 'updated_date DESC',
      );

      return maps.map((map) {
        final model = AvatarConfigurationModel.fromMap(map);
        return model.toDomain();
      }).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to search configurations: $e',
      );
    }
  }

  @override
  Future<List<AvatarConfiguration>> getConfigurationsByPersonality(String personalityType) async {
    try {
      final db = await _databaseHelper.database;
      
      final List<Map<String, dynamic>> maps = await db.query(
        StorageKeys.avatarConfigurationsTable,
        where: 'personality_data LIKE ?',
        whereArgs: ['%"type":"$personalityType"%'],
        orderBy: 'updated_date DESC',
      );

      return maps.map((map) {
        final model = AvatarConfigurationModel.fromMap(map);
        return model.toDomain();
      }).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get configurations by personality: $e',
      );
    }
  }

  @override
  Future<List<AvatarConfiguration>> getRecentConfigurations(int days) async {
    try {
      final db = await _databaseHelper.database;
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      final List<Map<String, dynamic>> maps = await db.query(
        StorageKeys.avatarConfigurationsTable,
        where: 'updated_date >= ?',
        whereArgs: [cutoffDate.millisecondsSinceEpoch],
        orderBy: 'updated_date DESC',
      );

      return maps.map((map) {
        final model = AvatarConfigurationModel.fromMap(map);
        return model.toDomain();
      }).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get recent configurations: $e',
      );
    }
  }

  @override
  Future<bool> configurationNameExists(String name, {String? excludeId}) async {
    try {
      final db = await _databaseHelper.database;
      
      String whereClause = 'LOWER(name) = LOWER(?)';
      List<dynamic> whereArgs = [name];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final List<Map<String, dynamic>> result = await db.query(
        StorageKeys.avatarConfigurationsTable,
        where: whereClause,
        whereArgs: whereArgs,
        limit: 1,
      );

      return result.isNotEmpty;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to check configuration name existence: $e',
      );
    }
  }

  @override
  Future<int> getConfigurationCount() async {
    try {
      List<Map<String, dynamic>> result;
      
      if (PlatformUtils.isWeb) {
        result = await _databaseHelper.webStorage.rawQuery(
          'SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable}',
        );
      } else {
        final db = await _databaseHelper.database;
        result = await db.rawQuery(
          'SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable}',
        );
      }
      
      return result.isNotEmpty ? result.first['count'] as int : 0;
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get configuration count: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> exportConfigurations() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        StorageKeys.avatarConfigurationsTable,
        orderBy: 'created_date ASC',
      );

      final configurations = maps.map((map) {
        final model = AvatarConfigurationModel.fromMap(map);
        return model.toExportData();
      }).toList();

      return {
        'export_version': '2.0',
        'exported_at': DateTime.now().toIso8601String(),
        'configuration_count': configurations.length,
        'configurations': configurations,
        'metadata': {
          'database_version': 2,
          'app_version': '1.0.0',
        },
      };
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to export configurations: $e',
      );
    }
  }

  @override
  Future<void> importConfigurations(Map<String, dynamic> data) async {
    try {
      final db = await _databaseHelper.database;
      final configurations = data['configurations'] as List<dynamic>;
      
      await db.transaction((txn) async {
        for (final configData in configurations) {
          final model = AvatarConfigurationModel.fromExportData(
            configData as Map<String, dynamic>,
          );
          
          await txn.insert(
            StorageKeys.avatarConfigurationsTable,
            model.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to import configurations: $e',
      );
    }
  }

  @override
  Future<void> backupConfigurations(String filePath) async {
    try {
      final exportData = await exportConfigurations();
      
      if (PlatformUtils.isWeb) {
        // On web, we can't write to arbitrary file paths
        // The caller should handle the download mechanism
        throw app_exceptions.StorageException(
          message: 'File system backup not supported on web. Use export functionality instead.',
        );
      }
      
      final file = File(filePath);
      await file.writeAsString(
        jsonEncode(exportData),
        encoding: utf8,
      );
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to backup configurations: $e',
      );
    }
  }

  @override
  Future<void> restoreConfigurations(String filePath) async {
    try {
      String content;
      
      if (PlatformUtils.isWeb) {
        // On web, filePath is actually the JSON content string
        content = filePath;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          throw app_exceptions.StorageException(
            message: 'Backup file not found: $filePath',
          );
        }
        content = await file.readAsString(encoding: utf8);
      }

      final data = jsonDecode(content) as Map<String, dynamic>;
      await importConfigurations(data);
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to restore configurations: $e',
      );
    }
  }

  @override
  Future<void> clearAllConfigurations() async {
    try {
      if (PlatformUtils.isWeb) {
        await _databaseHelper.webStorage.clearAllAvatarConfigurations();
      } else {
        final db = await _databaseHelper.database;
        await db.delete(StorageKeys.avatarConfigurationsTable);
      }
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to clear all configurations: $e',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getConfigurationStats() async {
    try {
      final db = await _databaseHelper.database;
      
      // Get total count
      final totalResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable}',
      );
      final totalCount = totalResult.first['count'] as int;

      // Get active count
      final activeResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable} WHERE is_active = 1',
      );
      final activeCount = activeResult.first['count'] as int;

      // Get favorite count
      final favoriteResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable} WHERE is_favorite = 1',
      );
      final favoriteCount = favoriteResult.first['count'] as int;

      // Get most used configuration
      final mostUsedResult = await db.query(
        StorageKeys.avatarConfigurationsTable,
        orderBy: 'usage_count DESC',
        limit: 1,
      );

      // Get recent activity (last 7 days)
      final recentCutoff = DateTime.now().subtract(const Duration(days: 7));
      final recentResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${StorageKeys.avatarConfigurationsTable} WHERE updated_date >= ?',
        [recentCutoff.millisecondsSinceEpoch],
      );
      final recentActivity = recentResult.first['count'] as int;

      // Get personality distribution
      final personalityResult = await db.rawQuery('''
        SELECT personality_data, COUNT(*) as count 
        FROM ${StorageKeys.avatarConfigurationsTable} 
        GROUP BY personality_data
      ''');
      
      final personalityDistribution = <String, int>{};
      for (final row in personalityResult) {
        try {
          final personalityData = jsonDecode(row['personality_data'] as String);
          final type = personalityData['type'] as String;
          personalityDistribution[type] = row['count'] as int;
        } catch (e) {
          // Skip malformed data
        }
      }

      return {
        'total_configurations': totalCount,
        'active_configurations': activeCount,
        'favorite_configurations': favoriteCount,
        'recent_activity_7days': recentActivity,
        'personality_distribution': personalityDistribution,
        'most_used_configuration': mostUsedResult.isNotEmpty 
            ? AvatarConfigurationModel.fromMap(mostUsedResult.first).toJson()
            : null,
        'database_size_bytes': await _databaseHelper.getDatabaseSize(),
        'last_updated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get configuration statistics: $e',
      );
    }
  }

  // Additional helper methods for enhanced functionality

  /// Get favorite configurations
  Future<List<AvatarConfiguration>> getFavoriteConfigurations() async {
    try {
      final db = await _databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        StorageKeys.avatarConfigurationsTable,
        where: 'is_favorite = ?',
        whereArgs: [1],
        orderBy: 'updated_date DESC',
      );

      return maps.map((map) {
        final model = AvatarConfigurationModel.fromMap(map);
        return model.toDomain();
      }).toList();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to get favorite configurations: $e',
      );
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(String id) async {
    try {
      final db = await _databaseHelper.database;
      
      // Get current status
      final result = await db.query(
        StorageKeys.avatarConfigurationsTable,
        columns: ['is_favorite'],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );

      if (result.isEmpty) {
        throw app_exceptions.DatabaseException(
          message: 'Configuration not found: $id',
        );
      }

      final currentStatus = (result.first['is_favorite'] as int) == 1;
      
      await db.update(
        StorageKeys.avatarConfigurationsTable,
        {
          'is_favorite': currentStatus ? 0 : 1,
          'updated_date': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to toggle favorite status: $e',
      );
    }
  }

  /// Duplicate configuration
  Future<AvatarConfiguration> duplicateConfiguration(String sourceId, String newId) async {
    try {
      final db = await _databaseHelper.database;
      
      // Get source configuration
      final sourceResult = await db.query(
        StorageKeys.avatarConfigurationsTable,
        where: 'id = ?',
        whereArgs: [sourceId],
        limit: 1,
      );

      if (sourceResult.isEmpty) {
        throw app_exceptions.DatabaseException(
          message: 'Source configuration not found: $sourceId',
        );
      }

      final sourceModel = AvatarConfigurationModel.fromMap(sourceResult.first);
      final duplicatedModel = sourceModel.duplicate(newId);
      
      await db.insert(
        StorageKeys.avatarConfigurationsTable,
        duplicatedModel.toMap(),
      );

      return duplicatedModel.toDomain();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to duplicate configuration: $e',
      );
    }
  }

  /// Optimize database
  Future<void> optimizeDatabase() async {
    try {
      await _databaseHelper.vacuum();
      await _databaseHelper.analyze();
    } catch (e) {
      throw app_exceptions.DatabaseException(
        message: 'Failed to optimize database: $e',
      );
    }
  }
}