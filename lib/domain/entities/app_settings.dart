import 'package:flutter/material.dart';

/// Abstract base class for application settings
abstract class AppSettings {
  String get language;
  ThemeMode get themeMode;
  bool get enableNotifications;
  bool get autoSave;
  bool get enableSoundEffects;
  double get soundVolume;
  bool get enableHapticFeedback;
  int get autoBackupInterval;
  int get maxStoredConfigurations;
  bool get enableAnalytics;
  bool get showAdvancedOptions;
  String get defaultVoiceLanguage;
  bool get enableQuickAccess;
  bool get showTutorials;
  DateTime get lastBackupTime;
  String get appVersion;
  bool get useWebSpeechFallback;

  /// Create a copy with updated values
  AppSettings copyWith({
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
    bool? useWebSpeechFallback,
  });

  /// Convert to JSON representation
  Map<String, dynamic> toJson();
}