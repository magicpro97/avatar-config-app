// App State Provider for Global State Management
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/storage/secure_storage.dart';

enum AppTheme {
  light,
  dark,
  system,
}

class AppStateProvider extends ChangeNotifier {
  final SecureStorage _secureStorage = SecureStorage();
  SharedPreferences? _sharedPreferences;
  
  // Theme management
  AppTheme _selectedTheme = AppTheme.system;
  ThemeMode _themeMode = ThemeMode.system;

  // API Key management
  String? _apiKey;
  bool _hasValidApiKey = false;

  // App settings
  bool _isFirstLaunch = true;
  bool _notificationsEnabled = true;
  bool _autoSaveEnabled = true;
  double _audioQuality = 1.0; // 0.0 to 1.0

  // Navigation state
  int _currentBottomNavIndex = 0;
  
  // Loading states
  bool _isInitializing = false;
  bool _isSaving = false;

  // Error handling
  String? _globalError;

  // Getters
  AppTheme get selectedTheme => _selectedTheme;
  ThemeMode get themeMode => _themeMode;
  String? get apiKey => _apiKey;
  bool get hasValidApiKey => _hasValidApiKey;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;
  double get audioQuality => _audioQuality;
  int get currentBottomNavIndex => _currentBottomNavIndex;
  bool get isInitializing => _isInitializing;
  bool get isSaving => _isSaving;
  String? get globalError => _globalError;
  bool get hasError => _globalError != null;

  // Theme management
  void setTheme(AppTheme theme) {
    _selectedTheme = theme;
    _updateThemeMode();
    notifyListeners();
    _saveSettings();
  }

  void _updateThemeMode() {
    switch (_selectedTheme) {
      case AppTheme.light:
        _themeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        _themeMode = ThemeMode.dark;
        break;
      case AppTheme.system:
        _themeMode = ThemeMode.system;
        break;
    }
  }

  // API Key management
  void setApiKey(String? apiKey) {
    _apiKey = apiKey;
    _hasValidApiKey = apiKey != null && apiKey.isNotEmpty;
    notifyListeners();
    _saveSettings();
  }

  void clearApiKey() {
    _apiKey = null;
    _hasValidApiKey = false;
    notifyListeners();
    _saveSettings();
  }

  // App settings
  void setFirstLaunch(bool isFirstLaunch) {
    _isFirstLaunch = isFirstLaunch;
    notifyListeners();
    _saveSettings();
  }

  void setNotificationsEnabled(bool enabled) {
    _notificationsEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setAutoSaveEnabled(bool enabled) {
    _autoSaveEnabled = enabled;
    notifyListeners();
    _saveSettings();
  }

  void setAudioQuality(double quality) {
    _audioQuality = quality.clamp(0.0, 1.0);
    notifyListeners();
    _saveSettings();
  }

  // Navigation management
  void setBottomNavIndex(int index) {
    _currentBottomNavIndex = index;
    notifyListeners();
  }

  // Loading states
  void setInitializing(bool initializing) {
    _isInitializing = initializing;
    notifyListeners();
  }

  void setSaving(bool saving) {
    _isSaving = saving;
    notifyListeners();
  }

  // Error handling
  void setGlobalError(String? error) {
    _globalError = error;
    notifyListeners();
  }

  void clearGlobalError() {
    _globalError = null;
    notifyListeners();
  }

  // Show global error with auto-dismiss
  void showGlobalError(String error, {Duration? duration}) {
    setGlobalError(error);
    
    if (duration != null) {
      Future.delayed(duration, () {
        if (_globalError == error) {
          clearGlobalError();
        }
      });
    }
  }

  // Initialize app state (load saved settings)
  Future<void> initialize() async {
    setInitializing(true);
    
    try {
      // Initialize SharedPreferences
      _sharedPreferences = await SharedPreferences.getInstance();
      
      // Load settings from persistent storage
      await _loadSettings();
      
    } catch (e) {
      setGlobalError('Failed to initialize app: $e');
    } finally {
      setInitializing(false);
    }
  }

  // Save settings to persistent storage
  Future<void> _saveSettings() async {
    if (_isSaving || _sharedPreferences == null) return; // Prevent multiple simultaneous saves
    
    setSaving(true);
    
    try {
      // Save to SharedPreferences
      await _sharedPreferences!.setString('selected_theme', _selectedTheme.name);
      await _sharedPreferences!.setBool('is_first_launch', _isFirstLaunch);
      await _sharedPreferences!.setBool('notifications_enabled', _notificationsEnabled);
      await _sharedPreferences!.setBool('auto_save_enabled', _autoSaveEnabled);
      await _sharedPreferences!.setDouble('audio_quality', _audioQuality);
      
      // Save API key to secure storage
      if (_apiKey != null && _apiKey!.isNotEmpty) {
        await _secureStorage.storeApiKey(_apiKey!);
      } else {
        try {
          await _secureStorage.delete('elevenlabs_api_key');
        } catch (e) {
          // Ignore error if key doesn't exist
        }
      }
      
    } catch (e) {
      setGlobalError('Failed to save settings: $e');
    } finally {
      setSaving(false);
    }
  }

  // Load settings from persistent storage
  Future<void> _loadSettings() async {
    try {
      if (_sharedPreferences == null) return;
      
      // Load from SharedPreferences
      final themeString = _sharedPreferences!.getString('selected_theme');
      if (themeString != null) {
        _selectedTheme = AppTheme.values.firstWhere(
          (theme) => theme.name == themeString,
          orElse: () => AppTheme.system,
        );
      }
      
      _isFirstLaunch = _sharedPreferences!.getBool('is_first_launch') ?? true;
      _notificationsEnabled = _sharedPreferences!.getBool('notifications_enabled') ?? true;
      _autoSaveEnabled = _sharedPreferences!.getBool('auto_save_enabled') ?? true;
      _audioQuality = _sharedPreferences!.getDouble('audio_quality') ?? 1.0;
      
      // Load API key from secure storage
      try {
        _apiKey = await _secureStorage.getApiKey();
        _hasValidApiKey = _apiKey != null && _apiKey!.isNotEmpty;
      } catch (e) {
        // If secure storage fails, assume no API key
        _apiKey = null;
        _hasValidApiKey = false;
      }
      
      _updateThemeMode();
    } catch (e) {
      setGlobalError('Failed to load settings: $e');
    }
  }

  // Reset all settings to defaults
  Future<void> resetSettings() async {
    _selectedTheme = AppTheme.system;
    _updateThemeMode();
    _isFirstLaunch = true;
    _notificationsEnabled = true;
    _autoSaveEnabled = true;
    _audioQuality = 1.0;
    _currentBottomNavIndex = 0;
    
    notifyListeners();
    await _saveSettings();
  }

  // Export app settings
  Map<String, dynamic> exportSettings() {
    return {
      'theme': _selectedTheme.name,
      'notifications_enabled': _notificationsEnabled,
      'auto_save_enabled': _autoSaveEnabled,
      'audio_quality': _audioQuality,
    };
  }

  // Import app settings
  Future<void> importSettings(Map<String, dynamic> settings) async {
    try {
      final themeString = settings['theme'] as String?;
      if (themeString != null) {
        _selectedTheme = AppTheme.values.firstWhere(
          (theme) => theme.name == themeString,
          orElse: () => AppTheme.system,
        );
        _updateThemeMode();
      }
      
      _notificationsEnabled = settings['notifications_enabled'] as bool? ?? true;
      _autoSaveEnabled = settings['auto_save_enabled'] as bool? ?? true;
      _audioQuality = (settings['audio_quality'] as double?)?.clamp(0.0, 1.0) ?? 1.0;
      
      notifyListeners();
      await _saveSettings();
    } catch (e) {
      setGlobalError('Failed to import settings: $e');
    }
  }

  // Utility methods
  String get audioQualityLabel {
    if (_audioQuality >= 0.8) return 'High';
    if (_audioQuality >= 0.5) return 'Medium';
    return 'Low';
  }

  String get themeLabel {
    switch (_selectedTheme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }

}