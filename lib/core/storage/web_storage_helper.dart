// Web-compatible Storage Helper using SharedPreferences
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart' as app_exceptions;

class WebStorageHelper {
  static WebStorageHelper? _instance;
  SharedPreferences? _prefs;

  WebStorageHelper._internal();

  factory WebStorageHelper() {
    _instance ??= WebStorageHelper._internal();
    return _instance!;
  }

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Avatar Configuration operations
  Future<List<Map<String, dynamic>>> queryAvatarConfigurations({
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
  }) async {
    try {
      final preferences = await prefs;
      final configurationsJson = preferences.getString(_getConfigurationsKey()) ?? '[]';
      List<dynamic> configurations = jsonDecode(configurationsJson);
      
      List<Map<String, dynamic>> results = configurations.cast<Map<String, dynamic>>();
      
      // Apply basic filtering if where clause is provided
      if (where != null && whereArgs != null) {
        results = _applyWhereFilter(results, where, whereArgs);
      }
      
      // Apply basic ordering
      if (orderBy != null) {
        results = _applyOrderBy(results, orderBy);
      }
      
      // Apply limit
      if (limit != null && limit > 0) {
        results = results.take(limit).toList();
      }
      
      return results;
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to query configurations: $e');
    }
  }

  Future<void> insertAvatarConfiguration(Map<String, dynamic> configuration) async {
    try {
      final preferences = await prefs;
      final configurationsJson = preferences.getString(_getConfigurationsKey()) ?? '[]';
      List<dynamic> configurations = jsonDecode(configurationsJson);
      
      // Remove existing configuration with same ID
      configurations.removeWhere((config) => config['id'] == configuration['id']);
      
      // Add new configuration
      configurations.add(configuration);
      
      await preferences.setString(_getConfigurationsKey(), jsonEncode(configurations));
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to insert configuration: $e');
    }
  }

  Future<int> updateAvatarConfiguration(
    Map<String, dynamic> values,
    String where,
    List<dynamic> whereArgs,
  ) async {
    try {
      final preferences = await prefs;
      final configurationsJson = preferences.getString(_getConfigurationsKey()) ?? '[]';
      List<dynamic> configurations = jsonDecode(configurationsJson);
      
      int updatedCount = 0;
      for (int i = 0; i < configurations.length; i++) {
        if (_matchesWhereClause(configurations[i], where, whereArgs)) {
          configurations[i] = {...configurations[i], ...values};
          updatedCount++;
        }
      }
      
      await preferences.setString(_getConfigurationsKey(), jsonEncode(configurations));
      return updatedCount;
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to update configuration: $e');
    }
  }

  Future<int> deleteAvatarConfiguration(String where, List<dynamic> whereArgs) async {
    try {
      final preferences = await prefs;
      final configurationsJson = preferences.getString(_getConfigurationsKey()) ?? '[]';
      List<dynamic> configurations = jsonDecode(configurationsJson);
      
      final int originalLength = configurations.length;
      configurations.removeWhere((config) => _matchesWhereClause(config, where, whereArgs));
      final int deletedCount = originalLength - configurations.length;
      
      await preferences.setString(_getConfigurationsKey(), jsonEncode(configurations));
      return deletedCount;
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to delete configuration: $e');
    }
  }

  Future<void> clearAllAvatarConfigurations() async {
    try {
      final preferences = await prefs;
      await preferences.setString(_getConfigurationsKey(), '[]');
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to clear configurations: $e');
    }
  }

  // Voice cache operations
  Future<List<Map<String, dynamic>>> queryCachedVoices({
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    try {
      final preferences = await prefs;
      final voicesJson = preferences.getString(_getVoicesKey()) ?? '[]';
      List<dynamic> voices = jsonDecode(voicesJson);
      
      List<Map<String, dynamic>> results = voices.cast<Map<String, dynamic>>();
      
      // Apply basic filtering if where clause is provided
      if (where != null && whereArgs != null) {
        results = _applyWhereFilter(results, where, whereArgs);
      }
      
      return results;
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to query cached voices: $e');
    }
  }

  Future<void> insertCachedVoice(Map<String, dynamic> voice) async {
    try {
      final preferences = await prefs;
      final voicesJson = preferences.getString(_getVoicesKey()) ?? '[]';
      List<dynamic> voices = jsonDecode(voicesJson);
      
      // Remove existing voice with same ID
      voices.removeWhere((v) => v['voice_id'] == voice['voice_id']);
      
      // Add new voice
      voices.add(voice);
      
      await preferences.setString(_getVoicesKey(), jsonEncode(voices));
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to insert cached voice: $e');
    }
  }

  Future<void> clearCachedVoices() async {
    try {
      final preferences = await prefs;
      await preferences.setString(_getVoicesKey(), '[]');
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Failed to clear cached voices: $e');
    }
  }

  // Raw query simulation
  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? arguments]) async {
    // Simulate basic SQL queries for web compatibility
    try {
      if (sql.contains('COUNT(*)')) {
        if (sql.contains(StorageKeys.avatarConfigurationsTable)) {
          final configs = await queryAvatarConfigurations();
          return [{'count': configs.length}];
        } else if (sql.contains('cached_voices')) {
          final voices = await queryCachedVoices();
          return [{'count': voices.length}];
        }
      }
      return [];
    } catch (e) {
      throw app_exceptions.DatabaseException(message: 'Raw query not supported on web: $e');
    }
  }

  // Utility methods
  String _getConfigurationsKey() => '${StorageKeys.avatarConfigurationsTable}_data';
  String _getVoicesKey() => 'cached_voices_data';

  List<Map<String, dynamic>> _applyWhereFilter(
    List<Map<String, dynamic>> data,
    String where,
    List<dynamic> whereArgs,
  ) {
    // Simple where clause parsing - basic implementation
    if (where.contains('id = ?') && whereArgs.isNotEmpty) {
      return data.where((item) => item['id'] == whereArgs[0]).toList();
    }
    
    if (where.contains('is_active = ?') && whereArgs.isNotEmpty) {
      return data.where((item) => item['is_active'] == whereArgs[0]).toList();
    }
    
    if (where.contains('is_favorite = ?') && whereArgs.isNotEmpty) {
      return data.where((item) => item['is_favorite'] == whereArgs[0]).toList();
    }
    
    if (where.contains('LIKE')) {
      // Handle simple LIKE queries
      final searchTerm = whereArgs.isNotEmpty ? whereArgs[0].toString() : '';
      if (searchTerm.isNotEmpty) {
        final cleanTerm = searchTerm.replaceAll('%', '').toLowerCase();
        return data.where((item) {
          final name = (item['name'] ?? '').toString().toLowerCase();
          final description = (item['description'] ?? '').toString().toLowerCase();
          return name.contains(cleanTerm) || description.contains(cleanTerm);
        }).toList();
      }
    }
    
    return data;
  }

  List<Map<String, dynamic>> _applyOrderBy(
    List<Map<String, dynamic>> data,
    String orderBy,
  ) {
    if (orderBy.contains('updated_date DESC')) {
      data.sort((a, b) {
        final aDate = a['updated_date'] ?? 0;
        final bDate = b['updated_date'] ?? 0;
        return (bDate as int).compareTo(aDate as int);
      });
    } else if (orderBy.contains('created_date DESC')) {
      data.sort((a, b) {
        final aDate = a['created_date'] ?? 0;
        final bDate = b['created_date'] ?? 0;
        return (bDate as int).compareTo(aDate as int);
      });
    } else if (orderBy.contains('usage_count DESC')) {
      data.sort((a, b) {
        final aCount = a['usage_count'] ?? 0;
        final bCount = b['usage_count'] ?? 0;
        return (bCount as int).compareTo(aCount as int);
      });
    }
    
    return data;
  }

  bool _matchesWhereClause(Map<String, dynamic> item, String where, List<dynamic> whereArgs) {
    if (where.contains('id = ?') && whereArgs.isNotEmpty) {
      return item['id'] == whereArgs[0];
    }
    
    if (where.contains('is_active = ?') && whereArgs.isNotEmpty) {
      return item['is_active'] == whereArgs[0];
    }
    
    return false;
  }

  // Transaction simulation
  Future<T> transaction<T>(Future<T> Function() action) async {
    // For web storage, we don't have real transactions, just execute the action
    return await action();
  }

  // Database maintenance (no-op on web)
  Future<void> vacuum() async {
    // No-op for web storage
  }

  Future<void> analyze() async {
    // No-op for web storage  
  }

  Future<int> getDatabaseSize() async {
    // Estimate size based on stored JSON strings
    try {
      final preferences = await prefs;
      final configurationsJson = preferences.getString(_getConfigurationsKey()) ?? '[]';
      final voicesJson = preferences.getString(_getVoicesKey()) ?? '[]';
      return configurationsJson.length + voicesJson.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> close() async {
    // No-op for SharedPreferences
  }
}