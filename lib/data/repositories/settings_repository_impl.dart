import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../models/app_settings_model.dart';

/// Implementation of settings repository
class SettingsRepositoryImpl implements SettingsRepository {
  static const String _settingsKey = 'app_settings';
  
  SharedPreferences? _prefs;

  /// Initialize shared preferences
  Future<SharedPreferences> get _sharedPreferences async {
    return _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<AppSettings> getSettings() async {
    try {
      final prefs = await _sharedPreferences;
      final settingsJson = prefs.getString(_settingsKey);
      
      if (settingsJson == null) {
        // Return default settings if none exist
        final defaultSettings = AppSettingsModel.defaultSettings();
        await saveSettings(defaultSettings);
        return defaultSettings;
      }
      
      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      return AppSettingsModel.fromJson(settingsMap);
    } catch (e) {
      throw Exception('Failed to load settings: $e');
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await _sharedPreferences;
      final settingsModel = settings is AppSettingsModel 
          ? settings 
          : AppSettingsModel(
              language: settings.language,
              themeMode: settings.themeMode,
              enableNotifications: settings.enableNotifications,
              autoSave: settings.autoSave,
              enableSoundEffects: settings.enableSoundEffects,
              soundVolume: settings.soundVolume,
              enableHapticFeedback: settings.enableHapticFeedback,
              autoBackupInterval: settings.autoBackupInterval,
              maxStoredConfigurations: settings.maxStoredConfigurations,
              enableAnalytics: settings.enableAnalytics,
              showAdvancedOptions: settings.showAdvancedOptions,
              defaultVoiceLanguage: settings.defaultVoiceLanguage,
              enableQuickAccess: settings.enableQuickAccess,
              showTutorials: settings.showTutorials,
              lastBackupTime: settings.lastBackupTime,
              appVersion: settings.appVersion,
            );

      final settingsJson = json.encode(settingsModel.toJson());
      final success = await prefs.setString(_settingsKey, settingsJson);
      
      if (!success) {
        throw Exception('Failed to save settings to storage');
      }
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  @override
  Future<void> resetSettings() async {
    try {
      final prefs = await _sharedPreferences;
      await prefs.remove(_settingsKey);
      
      // Save default settings
      final defaultSettings = AppSettingsModel.defaultSettings();
      await saveSettings(defaultSettings);
    } catch (e) {
      throw Exception('Failed to reset settings: $e');
    }
  }

  @override
  Future<void> updateSetting<T>(String key, T value) async {
    try {
      final currentSettings = await getSettings() as AppSettingsModel;
      AppSettingsModel updatedSettings;

      switch (key) {
        case 'language':
          updatedSettings = currentSettings.copyWith(language: value as String);
          break;
        case 'themeMode':
          updatedSettings = currentSettings.copyWith(themeMode: value as ThemeMode);
          break;
        case 'enableNotifications':
          updatedSettings = currentSettings.copyWith(enableNotifications: value as bool);
          break;
        case 'autoSave':
          updatedSettings = currentSettings.copyWith(autoSave: value as bool);
          break;
        case 'enableSoundEffects':
          updatedSettings = currentSettings.copyWith(enableSoundEffects: value as bool);
          break;
        case 'soundVolume':
          updatedSettings = currentSettings.copyWith(soundVolume: value as double);
          break;
        case 'enableHapticFeedback':
          updatedSettings = currentSettings.copyWith(enableHapticFeedback: value as bool);
          break;
        case 'autoBackupInterval':
          updatedSettings = currentSettings.copyWith(autoBackupInterval: value as int);
          break;
        case 'maxStoredConfigurations':
          updatedSettings = currentSettings.copyWith(maxStoredConfigurations: value as int);
          break;
        case 'enableAnalytics':
          updatedSettings = currentSettings.copyWith(enableAnalytics: value as bool);
          break;
        case 'showAdvancedOptions':
          updatedSettings = currentSettings.copyWith(showAdvancedOptions: value as bool);
          break;
        case 'defaultVoiceLanguage':
          updatedSettings = currentSettings.copyWith(defaultVoiceLanguage: value as String);
          break;
        case 'enableQuickAccess':
          updatedSettings = currentSettings.copyWith(enableQuickAccess: value as bool);
          break;
        case 'showTutorials':
          updatedSettings = currentSettings.copyWith(showTutorials: value as bool);
          break;
        case 'lastBackupTime':
          updatedSettings = currentSettings.copyWith(lastBackupTime: value as DateTime);
          break;
        case 'appVersion':
          updatedSettings = currentSettings.copyWith(appVersion: value as String);
          break;
        default:
          throw ArgumentError('Unknown setting key: $key');
      }

      await saveSettings(updatedSettings);
    } catch (e) {
      throw Exception('Failed to update setting $key: $e');
    }
  }

  @override
  Future<T?> getSetting<T>(String key) async {
    try {
      final settings = await getSettings() as AppSettingsModel;

      switch (key) {
        case 'language':
          return settings.language as T;
        case 'themeMode':
          return settings.themeMode as T;
        case 'enableNotifications':
          return settings.enableNotifications as T;
        case 'autoSave':
          return settings.autoSave as T;
        case 'enableSoundEffects':
          return settings.enableSoundEffects as T;
        case 'soundVolume':
          return settings.soundVolume as T;
        case 'enableHapticFeedback':
          return settings.enableHapticFeedback as T;
        case 'autoBackupInterval':
          return settings.autoBackupInterval as T;
        case 'maxStoredConfigurations':
          return settings.maxStoredConfigurations as T;
        case 'enableAnalytics':
          return settings.enableAnalytics as T;
        case 'showAdvancedOptions':
          return settings.showAdvancedOptions as T;
        case 'defaultVoiceLanguage':
          return settings.defaultVoiceLanguage as T;
        case 'enableQuickAccess':
          return settings.enableQuickAccess as T;
        case 'showTutorials':
          return settings.showTutorials as T;
        case 'lastBackupTime':
          return settings.lastBackupTime as T;
        case 'appVersion':
          return settings.appVersion as T;
        default:
          return null;
      }
    } catch (e) {
      throw Exception('Failed to get setting $key: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      final settings = await getSettings() as AppSettingsModel;
      return {
        'settings': settings.toJson(),
        'exportTime': DateTime.now().toIso8601String(),
        'platform': _getCurrentPlatform(),
        'version': settings.appVersion,
      };
    } catch (e) {
      throw Exception('Failed to export settings: $e');
    }
  }

  @override
  Future<void> importSettings(Map<String, dynamic> settingsData) async {
    try {
      final settingsJson = settingsData['settings'] as Map<String, dynamic>;
      final settings = AppSettingsModel.fromJson(settingsJson);
      await saveSettings(settings);
    } catch (e) {
      throw Exception('Failed to import settings: $e');
    }
  }

  @override
  Future<bool> validateSettings(Map<String, dynamic> settingsData) async {
    try {
      AppSettingsModel.fromJson(settingsData);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Clear all settings data (for testing)
  Future<void> clearAll() async {
    try {
      final prefs = await _sharedPreferences;
      await prefs.clear();
    } catch (e) {
      throw Exception('Failed to clear settings: $e');
    }
  }

  /// Get current platform as string
  String _getCurrentPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    }
    return 'unknown';
  }
}