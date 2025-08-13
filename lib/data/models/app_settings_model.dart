import 'package:flutter/material.dart';

import '../../domain/entities/app_settings.dart';

/// Data model for application settings
class AppSettingsModel extends AppSettings {
  @override
  final String language;
  @override
  final ThemeMode themeMode;
  @override
  final bool enableNotifications;
  @override
  final bool autoSave;
  @override
  final bool enableSoundEffects;
  @override
  final double soundVolume;
  @override
  final bool enableHapticFeedback;
  @override
  final int autoBackupInterval; // in hours, 0 = disabled
  @override
  final int maxStoredConfigurations;
  @override
  final bool enableAnalytics;
  @override
  final bool showAdvancedOptions;
  @override
  final String defaultVoiceLanguage;
  @override
  final bool enableQuickAccess;
  @override
  final bool showTutorials;
  @override
  final DateTime lastBackupTime;
  @override
  final String appVersion;

  AppSettingsModel({
    this.language = 'vi',
    this.themeMode = ThemeMode.system,
    this.enableNotifications = true,
    this.autoSave = true,
    this.enableSoundEffects = true,
    this.soundVolume = 0.7,
    this.enableHapticFeedback = true,
    this.autoBackupInterval = 24,
    this.maxStoredConfigurations = 100,
    this.enableAnalytics = false,
    this.showAdvancedOptions = false,
    this.defaultVoiceLanguage = 'vi',
    this.enableQuickAccess = true,
    this.showTutorials = true,
    required this.lastBackupTime,
    required this.appVersion,
  });

  /// Create default settings
  factory AppSettingsModel.defaultSettings() {
    return AppSettingsModel(
      lastBackupTime: DateTime.now(),
      appVersion: '1.0.0',
    );
  }

  /// Create settings from JSON
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      language: json['language'] ?? 'vi',
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == (json['themeMode'] ?? 'system'),
        orElse: () => ThemeMode.system,
      ),
      enableNotifications: json['enableNotifications'] ?? true,
      autoSave: json['autoSave'] ?? true,
      enableSoundEffects: json['enableSoundEffects'] ?? true,
      soundVolume: (json['soundVolume'] ?? 0.7).toDouble(),
      enableHapticFeedback: json['enableHapticFeedback'] ?? true,
      autoBackupInterval: json['autoBackupInterval'] ?? 24,
      maxStoredConfigurations: json['maxStoredConfigurations'] ?? 100,
      enableAnalytics: json['enableAnalytics'] ?? false,
      showAdvancedOptions: json['showAdvancedOptions'] ?? false,
      defaultVoiceLanguage: json['defaultVoiceLanguage'] ?? 'vi',
      enableQuickAccess: json['enableQuickAccess'] ?? true,
      showTutorials: json['showTutorials'] ?? true,
      lastBackupTime: DateTime.parse(
        json['lastBackupTime'] ?? DateTime.now().toIso8601String(),
      ),
      appVersion: json['appVersion'] ?? '1.0.0',
    );
  }

  /// Convert settings to JSON
  @override
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'themeMode': themeMode.name,
      'enableNotifications': enableNotifications,
      'autoSave': autoSave,
      'enableSoundEffects': enableSoundEffects,
      'soundVolume': soundVolume,
      'enableHapticFeedback': enableHapticFeedback,
      'autoBackupInterval': autoBackupInterval,
      'maxStoredConfigurations': maxStoredConfigurations,
      'enableAnalytics': enableAnalytics,
      'showAdvancedOptions': showAdvancedOptions,
      'defaultVoiceLanguage': defaultVoiceLanguage,
      'enableQuickAccess': enableQuickAccess,
      'showTutorials': showTutorials,
      'lastBackupTime': lastBackupTime.toIso8601String(),
      'appVersion': appVersion,
    };
  }

  /// Create a copy with updated values
  @override
  AppSettingsModel copyWith({
    String? language,
    ThemeMode? themeMode,
    bool? enableNotifications,
    bool? autoSave,
    bool? enableSoundEffects,
    double? soundVolume,
    bool? enableHapticFeedback,
    int? autoBackupInterval,
    int? maxStoredConfigurations,
    bool? enableAnalytics,
    bool? showAdvancedOptions,
    String? defaultVoiceLanguage,
    bool? enableQuickAccess,
    bool? showTutorials,
    DateTime? lastBackupTime,
    String? appVersion,
  }) {
    return AppSettingsModel(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoSave: autoSave ?? this.autoSave,
      enableSoundEffects: enableSoundEffects ?? this.enableSoundEffects,
      soundVolume: soundVolume ?? this.soundVolume,
      enableHapticFeedback: enableHapticFeedback ?? this.enableHapticFeedback,
      autoBackupInterval: autoBackupInterval ?? this.autoBackupInterval,
      maxStoredConfigurations: maxStoredConfigurations ?? this.maxStoredConfigurations,
      enableAnalytics: enableAnalytics ?? this.enableAnalytics,
      showAdvancedOptions: showAdvancedOptions ?? this.showAdvancedOptions,
      defaultVoiceLanguage: defaultVoiceLanguage ?? this.defaultVoiceLanguage,
      enableQuickAccess: enableQuickAccess ?? this.enableQuickAccess,
      showTutorials: showTutorials ?? this.showTutorials,
      lastBackupTime: lastBackupTime ?? this.lastBackupTime,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsModel &&
          runtimeType == other.runtimeType &&
          language == other.language &&
          themeMode == other.themeMode &&
          enableNotifications == other.enableNotifications &&
          autoSave == other.autoSave &&
          enableSoundEffects == other.enableSoundEffects &&
          soundVolume == other.soundVolume &&
          enableHapticFeedback == other.enableHapticFeedback &&
          autoBackupInterval == other.autoBackupInterval &&
          maxStoredConfigurations == other.maxStoredConfigurations &&
          enableAnalytics == other.enableAnalytics &&
          showAdvancedOptions == other.showAdvancedOptions &&
          defaultVoiceLanguage == other.defaultVoiceLanguage &&
          enableQuickAccess == other.enableQuickAccess &&
          showTutorials == other.showTutorials &&
          lastBackupTime == other.lastBackupTime &&
          appVersion == other.appVersion;

  @override
  int get hashCode => Object.hash(
        language,
        themeMode,
        enableNotifications,
        autoSave,
        enableSoundEffects,
        soundVolume,
        enableHapticFeedback,
        autoBackupInterval,
        maxStoredConfigurations,
        enableAnalytics,
        showAdvancedOptions,
        defaultVoiceLanguage,
        enableQuickAccess,
        showTutorials,
        lastBackupTime,
        appVersion,
      );

  @override
  String toString() {
    return 'AppSettingsModel('
        'language: $language, '
        'themeMode: $themeMode, '
        'enableNotifications: $enableNotifications, '
        'autoSave: $autoSave, '
        'enableSoundEffects: $enableSoundEffects, '
        'soundVolume: $soundVolume, '
        'enableHapticFeedback: $enableHapticFeedback, '
        'autoBackupInterval: $autoBackupInterval, '
        'maxStoredConfigurations: $maxStoredConfigurations, '
        'enableAnalytics: $enableAnalytics, '
        'showAdvancedOptions: $showAdvancedOptions, '
        'defaultVoiceLanguage: $defaultVoiceLanguage, '
        'enableQuickAccess: $enableQuickAccess, '
        'showTutorials: $showTutorials, '
        'lastBackupTime: $lastBackupTime, '
        'appVersion: $appVersion'
        ')';
  }
}