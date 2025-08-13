// Backup and Export Service for Avatar Configurations
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/repositories/avatar_repository.dart';
import '../../core/errors/exceptions.dart' as app_exceptions;
import '../../core/utils/platform_utils.dart';
import '../models/avatar_configuration_model.dart';

class BackupService {
  final AvatarRepository _avatarRepository;

  BackupService({required AvatarRepository avatarRepository})
      : _avatarRepository = avatarRepository;

  /// Create a backup file with all configurations
  Future<String> createBackup({String? customPath}) async {
    try {
      final exportData = await _avatarRepository.exportConfigurations();
      
      // Generate backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final filename = 'avatar_configs_backup_$timestamp.json';
      
      // On web, return the JSON string directly as it cannot write to filesystem
      if (PlatformUtils.isWeb) {
        final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
        // For web, we return the JSON content as a download URL or trigger download
        // The caller needs to handle the download mechanism
        return jsonString;
      }
      
      // Determine backup path for mobile/desktop
      final String backupPath;
      if (customPath != null) {
        backupPath = customPath.endsWith('.json') ? customPath : '$customPath/$filename';
      } else {
        final appDir = await getApplicationDocumentsDirectory();
        backupPath = '${appDir.path}/$filename';
      }

      // Write backup file
      final backupFile = File(backupPath);
      await backupFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(exportData),
        encoding: utf8,
      );

      return backupPath;
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to create backup: $e',
      );
    }
  }

  /// Restore configurations from backup file
  Future<RestoreResult> restoreFromBackup(String backupPath, {
    bool replaceExisting = false,
    bool skipDuplicates = true,
  }) async {
    try {
      String content;
      
      if (PlatformUtils.isWeb) {
        // On web, backupPath is actually the JSON content string
        content = backupPath;
      } else {
        final backupFile = File(backupPath);
        if (!await backupFile.exists()) {
          throw app_exceptions.StorageException(
            message: 'Backup file not found: $backupPath',
          );
        }
        // Read and parse backup file
        content = await backupFile.readAsString(encoding: utf8);
      }
      
      final backupData = jsonDecode(content) as Map<String, dynamic>;

      // Validate backup format
      if (!_isValidBackupFormat(backupData)) {
        throw app_exceptions.ValidationException(
          message: 'Invalid backup file format',
        );
      }

      final configurations = backupData['configurations'] as List<dynamic>;
      int imported = 0;
      int skipped = 0;
      int errors = 0;
      final List<String> errorMessages = [];

      // Get existing configuration names for duplicate checking
      Set<String> existingNames = {};
      if (skipDuplicates) {
        final existing = await _avatarRepository.getAllConfigurations();
        existingNames = existing.map((config) => config.name.toLowerCase()).toSet();
      }

      // Clear existing configurations if requested
      if (replaceExisting) {
        await _avatarRepository.clearAllConfigurations();
        existingNames.clear();
      }

      // Import each configuration
      for (final configData in configurations) {
        try {
          final model = AvatarConfigurationModel.fromExportData(
            configData as Map<String, dynamic>,
          );

          // Check for duplicates
          if (skipDuplicates && existingNames.contains(model.name.toLowerCase())) {
            skipped++;
            continue;
          }

          // Create new configuration
          await _avatarRepository.createConfiguration(model.toDomain());
          imported++;
          
          if (skipDuplicates) {
            existingNames.add(model.name.toLowerCase());
          }
        } catch (e) {
          errors++;
          errorMessages.add('Failed to import configuration: $e');
        }
      }

      return RestoreResult(
        totalConfigurations: configurations.length,
        importedCount: imported,
        skippedCount: skipped,
        errorCount: errors,
        errorMessages: errorMessages,
      );
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to restore from backup: $e',
      );
    }
  }

  /// Share backup file (simplified - returns path for manual sharing)
  Future<String> prepareBackupForSharing() async {
    try {
      final backupPath = await createBackup();
      return backupPath;
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to prepare backup for sharing: $e',
      );
    }
  }

  /// Restore from backup file path (simplified - no file picker)
  Future<RestoreResult> restoreFromBackupPath(
    String backupPath, {
    bool replaceExisting = false,
    bool skipDuplicates = true,
  }) async {
    return await restoreFromBackup(
      backupPath,
      replaceExisting: replaceExisting,
      skipDuplicates: skipDuplicates,
    );
  }

  /// Export single configuration
  Future<String> exportSingleConfiguration(String configId) async {
    try {
      final config = await _avatarRepository.getConfigurationById(configId);
      if (config == null) {
        throw app_exceptions.ValidationException(
          message: 'Configuration not found: $configId',
        );
      }

      final model = AvatarConfigurationModel.fromDomain(config);
      final exportData = {
        'export_version': '2.0',
        'exported_at': DateTime.now().toIso8601String(),
        'single_configuration': true,
        'configuration': model.toExportData(),
      };

      // Generate filename
      final safeConfigName = config.name.replaceAll(RegExp(r'[^\w\s-]'), '');
      final timestamp = DateTime.now().toIso8601String().substring(0, 10);
      final filename = 'avatar_config_${safeConfigName}_$timestamp.json';

      if (PlatformUtils.isWeb) {
        // On web, return JSON content directly
        return const JsonEncoder.withIndent('  ').convert(exportData);
      }
      
      // Write to app documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/$filename';
      
      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(exportData),
        encoding: utf8,
      );

      return filePath;
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to export single configuration: $e',
      );
    }
  }

  /// Import single configuration from file
  Future<String> importSingleConfiguration(String filePath) async {
    try {
      String content;
      
      if (PlatformUtils.isWeb) {
        // On web, filePath is actually the JSON content string
        content = filePath;
      } else {
        final file = File(filePath);
        if (!await file.exists()) {
          throw app_exceptions.StorageException(
            message: 'Import file not found: $filePath',
          );
        }
        content = await file.readAsString(encoding: utf8);
      }
      
      final importData = jsonDecode(content) as Map<String, dynamic>;

      // Check if it's a single configuration export
      if (importData['single_configuration'] != true) {
        throw app_exceptions.ValidationException(
          message: 'File does not contain a single configuration export',
        );
      }

      final configData = importData['configuration'] as Map<String, dynamic>;
      final model = AvatarConfigurationModel.fromExportData(configData);

      // Generate unique ID to avoid conflicts
      final newId = 'imported_${DateTime.now().millisecondsSinceEpoch}';
      final importedModel = model.copyWith(
        id: newId,
        name: await _generateUniqueName(model.name),
        isActive: false, // Imported configs start as inactive
      );

      await _avatarRepository.createConfiguration(importedModel.toDomain());
      return importedModel.id;
    } catch (e) {
      throw app_exceptions.StorageException(
        message: 'Failed to import single configuration: $e',
      );
    }
  }

  /// Get backup file info
  Future<BackupInfo?> getBackupInfo(String backupPath) async {
    try {
      if (PlatformUtils.isWeb) {
        // On web, limited backup info functionality
        try {
          final data = jsonDecode(backupPath) as Map<String, dynamic>;
          return BackupInfo(
            filePath: 'web_backup.json',
            fileName: 'web_backup.json',
            fileSize: backupPath.length,
            createdDate: DateTime.now(),
            exportedDate: DateTime.tryParse(data['exported_at'] as String? ?? ''),
            configurationCount: (data['configurations'] as List?)?.length ?? 0,
            version: data['export_version'] as String? ?? '1.0',
            isValid: _isValidBackupFormat(data),
          );
        } catch (e) {
          return null;
        }
      }
      
      final file = File(backupPath);
      if (!await file.exists()) {
        return null;
      }

      final stat = await file.stat();
      final content = await file.readAsString(encoding: utf8);
      final data = jsonDecode(content) as Map<String, dynamic>;

      return BackupInfo(
        filePath: backupPath,
        fileName: backupPath.split('/').last,
        fileSize: stat.size,
        createdDate: stat.modified,
        exportedDate: DateTime.tryParse(data['exported_at'] as String? ?? ''),
        configurationCount: (data['configurations'] as List?)?.length ?? 0,
        version: data['export_version'] as String? ?? '1.0',
        isValid: _isValidBackupFormat(data),
      );
    } catch (e) {
      return null;
    }
  }

  /// List available backup files in app directory
  Future<List<BackupInfo>> listAvailableBackups() async {
    // On web, backup file listing is not supported due to security restrictions
    if (PlatformUtils.isWeb) {
      return [];
    }
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final directory = Directory(appDir.path);
      
      if (!await directory.exists()) {
        return [];
      }

      final files = await directory
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.json'))
          .cast<File>()
          .toList();

      final List<BackupInfo> backups = [];
      
      for (final file in files) {
        final info = await getBackupInfo(file.path);
        if (info != null && info.isValid) {
          backups.add(info);
        }
      }

      // Sort by creation date (newest first)
      backups.sort((a, b) => (b.exportedDate ?? b.createdDate)
          .compareTo(a.exportedDate ?? a.createdDate));

      return backups;
    } catch (e) {
      return [];
    }
  }

  /// Validate backup file format
  bool _isValidBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('export_version') &&
           data.containsKey('exported_at') &&
           data.containsKey('configurations') &&
           data['configurations'] is List;
  }

  /// Generate unique name for imported configuration
  Future<String> _generateUniqueName(String baseName) async {
    String newName = baseName;
    int counter = 1;

    while (await _avatarRepository.configurationNameExists(newName)) {
      newName = '$baseName ($counter)';
      counter++;
    }

    return newName;
  }

  /// Clean up old backup files (keep only last N backups)
  Future<int> cleanupOldBackups({int keepCount = 10}) async {
    // On web, backup cleanup is not supported
    if (PlatformUtils.isWeb) {
      return 0;
    }
    
    try {
      final backups = await listAvailableBackups();
      if (backups.length <= keepCount) {
        return 0; // Nothing to clean up
      }

      final toDelete = backups.skip(keepCount).toList();
      int deletedCount = 0;

      for (final backup in toDelete) {
        try {
          final file = File(backup.filePath);
          if (await file.exists()) {
            await file.delete();
            deletedCount++;
          }
        } catch (e) {
          // Skip files that can't be deleted
        }
      }

      return deletedCount;
    } catch (e) {
      return 0;
    }
  }

  /// Get backup statistics
  Future<BackupStats> getBackupStats() async {
    try {
      final backups = await listAvailableBackups();
      final totalSize = backups.fold<int>(0, (sum, backup) => sum + backup.fileSize);
      final totalConfigs = backups.fold<int>(0, (sum, backup) => sum + backup.configurationCount);
      
      DateTime? oldestBackup;
      DateTime? newestBackup;
      
      if (backups.isNotEmpty) {
        final sortedByDate = List<BackupInfo>.from(backups)
          ..sort((a, b) => (a.exportedDate ?? a.createdDate)
              .compareTo(b.exportedDate ?? b.createdDate));
        
        oldestBackup = sortedByDate.first.exportedDate ?? sortedByDate.first.createdDate;
        newestBackup = sortedByDate.last.exportedDate ?? sortedByDate.last.createdDate;
      }

      return BackupStats(
        totalBackups: backups.length,
        totalSizeBytes: totalSize,
        totalConfigurations: totalConfigs,
        oldestBackupDate: oldestBackup,
        newestBackupDate: newestBackup,
      );
    } catch (e) {
      return BackupStats(
        totalBackups: 0,
        totalSizeBytes: 0,
        totalConfigurations: 0,
      );
    }
  }
}

/// Result of a backup restore operation
class RestoreResult {
  final int totalConfigurations;
  final int importedCount;
  final int skippedCount;
  final int errorCount;
  final List<String> errorMessages;

  const RestoreResult({
    required this.totalConfigurations,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
    required this.errorMessages,
  });

  bool get hasErrors => errorCount > 0;
  bool get hasSkipped => skippedCount > 0;
  bool get isSuccessful => importedCount > 0;
  
  @override
  String toString() {
    return 'RestoreResult(total: $totalConfigurations, imported: $importedCount, skipped: $skippedCount, errors: $errorCount)';
  }
}

/// Information about a backup file
class BackupInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final DateTime createdDate;
  final DateTime? exportedDate;
  final int configurationCount;
  final String version;
  final bool isValid;

  const BackupInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.createdDate,
    this.exportedDate,
    required this.configurationCount,
    required this.version,
    required this.isValid,
  });

  String get formattedFileSize {
    if (fileSize < 1024) return '${fileSize}B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String get formattedDate {
    final date = exportedDate ?? createdDate;
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Statistics about backup files
class BackupStats {
  final int totalBackups;
  final int totalSizeBytes;
  final int totalConfigurations;
  final DateTime? oldestBackupDate;
  final DateTime? newestBackupDate;

  const BackupStats({
    required this.totalBackups,
    required this.totalSizeBytes,
    required this.totalConfigurations,
    this.oldestBackupDate,
    this.newestBackupDate,
  });

  String get formattedTotalSize {
    if (totalSizeBytes < 1024) return '${totalSizeBytes}B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  double get averageConfigsPerBackup => totalBackups > 0 ? totalConfigurations / totalBackups : 0;
}