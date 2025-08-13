import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../widgets/settings/settings_section.dart';
import '../../widgets/settings/setting_tile.dart';
import '../../widgets/settings/theme_selector.dart';
import '../../widgets/settings/language_selector.dart';
import '../../widgets/settings/volume_slider.dart';
import '../../widgets/settings/backup_interval_selector.dart';
import '../../widgets/settings/storage_limit_selector.dart';
import '../../dialogs/confirmation_dialog.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/repositories/settings_repository_impl.dart';

/// Comprehensive settings screen with Vietnamese localization
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepositoryImpl _settingsRepository = SettingsRepositoryImpl();
  AppSettingsModel? _currentSettings;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await _settingsRepository.getSettings();
      setState(() {
        _currentSettings = settings as AppSettingsModel;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải cài đặt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateSetting<T>(String key, T value) async {
    try {
      await _settingsRepository.updateSetting(key, value);
      await _loadSettings(); // Reload to update UI
      
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu cài đặt'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lưu cài đặt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Đặt lại cài đặt',
        content: 'Bạn có chắc chắn muốn đặt lại tất cả cài đặt về mặc định? Thao tác này không thể hoàn tác.',
        confirmText: 'Đặt lại',
        cancelText: 'Hủy',
        isDestructive: true,
      ),
    );

    if (confirmed == true) {
      try {
        await _settingsRepository.resetSettings();
        await _loadSettings();
        
        if (mounted) {
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã đặt lại cài đặt về mặc định'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đặt lại cài đặt: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _exportSettings() async {
    try {
      // await _settingsRepository.exportSettings();
      
      if (mounted) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xuất cài đặt thành công'),
            backgroundColor: Colors.green,
          ),
        );
        
        // In a real app, you would save to file or share
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Xuất cài đặt'),
            content: const Text('Cài đặt đã được xuất. Trong ứng dụng thực tế, dữ liệu sẽ được lưu vào tệp.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xuất cài đặt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cài đặt'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentSettings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Cài đặt'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              const Text(
                'Không thể tải cài đặt',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadSettings,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'export':
                  _exportSettings();
                  break;
                case 'reset':
                  _resetSettings();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.file_download),
                  title: Text('Xuất cài đặt'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.restore, color: Colors.red),
                  title: Text('Đặt lại', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            SettingsSection(
              title: 'Giao diện',
              icon: Icons.palette,
              children: [
                ThemeSelector(
                  currentTheme: _currentSettings!.themeMode,
                  onThemeChanged: (theme) => _updateSetting('themeMode', theme),
                ),
                LanguageSelector(
                  currentLanguage: _currentSettings!.language,
                  onLanguageChanged: (language) => _updateSetting('language', language),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Audio & Haptics Section
            SettingsSection(
              title: 'Âm thanh & Rung',
              icon: Icons.volume_up,
              children: [
                SettingTile(
                  title: 'Hiệu ứng âm thanh',
                  subtitle: 'Phát âm thanh khi tương tác',
                  trailing: Switch(
                    value: _currentSettings!.enableSoundEffects,
                    onChanged: (value) => _updateSetting('enableSoundEffects', value),
                  ),
                ),
                if (_currentSettings!.enableSoundEffects)
                  VolumeSlider(
                    currentVolume: _currentSettings!.soundVolume,
                    onVolumeChanged: (volume) => _updateSetting('soundVolume', volume),
                  ),
                SettingTile(
                  title: 'Phản hồi haptic',
                  subtitle: 'Rung nhẹ khi tương tác',
                  trailing: Switch(
                    value: _currentSettings!.enableHapticFeedback,
                    onChanged: (value) => _updateSetting('enableHapticFeedback', value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Data & Storage Section
            SettingsSection(
              title: 'Dữ liệu & Lưu trữ',
              icon: Icons.storage,
              children: [
                SettingTile(
                  title: 'Tự động lưu',
                  subtitle: 'Tự động lưu các thay đổi',
                  trailing: Switch(
                    value: _currentSettings!.autoSave,
                    onChanged: (value) => _updateSetting('autoSave', value),
                  ),
                ),
                BackupIntervalSelector(
                  currentInterval: _currentSettings!.autoBackupInterval,
                  onIntervalChanged: (interval) => _updateSetting('autoBackupInterval', interval),
                ),
                StorageLimitSelector(
                  currentLimit: _currentSettings!.maxStoredConfigurations,
                  onLimitChanged: (limit) => _updateSetting('maxStoredConfigurations', limit),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Privacy & Analytics Section
            SettingsSection(
              title: 'Riêng tư & Phân tích',
              icon: Icons.privacy_tip,
              children: [
                SettingTile(
                  title: 'Thông báo',
                  subtitle: 'Nhận thông báo từ ứng dụng',
                  trailing: Switch(
                    value: _currentSettings!.enableNotifications,
                    onChanged: (value) => _updateSetting('enableNotifications', value),
                  ),
                ),
                SettingTile(
                  title: 'Phân tích sử dụng',
                  subtitle: 'Giúp cải thiện ứng dụng',
                  trailing: Switch(
                    value: _currentSettings!.enableAnalytics,
                    onChanged: (value) => _updateSetting('enableAnalytics', value),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Advanced Section
            SettingsSection(
              title: 'Nâng cao',
              icon: Icons.tune,
              children: [
                SettingTile(
                  title: 'Tùy chọn nâng cao',
                  subtitle: 'Hiển thị các cài đặt nâng cao',
                  trailing: Switch(
                    value: _currentSettings!.showAdvancedOptions,
                    onChanged: (value) => _updateSetting('showAdvancedOptions', value),
                  ),
                ),
                SettingTile(
                  title: 'Truy cập nhanh',
                  subtitle: 'Hiển thị menu truy cập nhanh',
                  trailing: Switch(
                    value: _currentSettings!.enableQuickAccess,
                    onChanged: (value) => _updateSetting('enableQuickAccess', value),
                  ),
                ),
                SettingTile(
                  title: 'Hướng dẫn sử dụng',
                  subtitle: 'Hiển thị hướng dẫn cho người dùng mới',
                  trailing: Switch(
                    value: _currentSettings!.showTutorials,
                    onChanged: (value) => _updateSetting('showTutorials', value),
                  ),
                ),
                LanguageSelector(
                  title: 'Ngôn ngữ giọng nói mặc định',
                  subtitle: 'Ngôn ngữ mặc định cho tổng hợp giọng nói',
                  currentLanguage: _currentSettings!.defaultVoiceLanguage,
                  onLanguageChanged: (language) => _updateSetting('defaultVoiceLanguage', language),
                  showOnlyVoiceLanguages: true,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Info Section
            SettingsSection(
              title: 'Thông tin ứng dụng',
              icon: Icons.info,
              children: [
                SettingTile(
                  title: 'Phiên bản',
                  subtitle: _currentSettings!.appVersion,
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Thông tin phiên bản'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Phiên bản: ${_currentSettings!.appVersion}'),
                            const SizedBox(height: 8),
                            Text('Sao lưu lần cuối: ${_formatDateTime(_currentSettings!.lastBackupTime)}'),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Đóng'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SettingTile(
                  title: 'Giấy phép',
                  subtitle: 'Xem thông tin giấy phép mã nguồn mở',
                  trailing: const Icon(Icons.keyboard_arrow_right),
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Avatar Configuration App',
                      applicationVersion: _currentSettings!.appVersion,
                      applicationLegalese: '© 2024 Avatar Configuration App',
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}