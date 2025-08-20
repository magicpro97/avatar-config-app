import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/app_settings_model.dart';
import '../../../data/repositories/settings_repository_impl.dart';
import '../../widgets/common/copyable_error_widget.dart';
import '../../../data/services/api_config_service.dart';

/// Simple settings screen for testing
class SimpleSettingsScreen extends StatefulWidget {
  const SimpleSettingsScreen({super.key});

  @override
  State<SimpleSettingsScreen> createState() => _SimpleSettingsScreenState();
}

class _SimpleSettingsScreenState extends State<SimpleSettingsScreen> {
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
      if (mounted) {
        setState(() {
          _currentSettings = settings as AppSettingsModel;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CopyableErrorDialog.show(
          context,
          errorMessage: 'Lỗi tải cài đặt: $e',
          title: 'Lỗi tải cài đặt',
          icon: Icons.error,
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
        CopyableErrorDialog.show(
          context,
          errorMessage: 'Lỗi lưu cài đặt: $e',
          title: 'Lỗi lưu cài đặt',
          icon: Icons.error,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.palette),
                    title: const Text('Giao diện'),
                    subtitle: const Text('Chủ đề và ngôn ngữ'),
                    trailing: const Icon(Icons.expand_more),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Chủ đề'),
                    subtitle: Text(_getThemeDescription(_currentSettings!.themeMode)),
                    trailing: DropdownButton<ThemeMode>(
                      value: _currentSettings!.themeMode,
                      onChanged: (value) {
                        if (value != null) {
                          _updateSetting('themeMode', value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('Hệ thống'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Sáng'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('Tối'),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: const Text('Ngôn ngữ'),
                    subtitle: Text(_getLanguageDescription(_currentSettings!.language)),
                    trailing: DropdownButton<String>(
                      value: _currentSettings!.language,
                      onChanged: (value) {
                        if (value != null) {
                          _updateSetting('language', value);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'vi',
                          child: Text('Tiếng Việt'),
                        ),
                        DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Audio & Haptics Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.volume_up),
                    title: const Text('Âm thanh & Rung'),
                    subtitle: const Text('Hiệu ứng và phản hồi'),
                    trailing: const Icon(Icons.expand_more),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Hiệu ứng âm thanh'),
                    subtitle: const Text('Phát âm thanh khi tương tác'),
                    value: _currentSettings!.enableSoundEffects,
                    onChanged: (value) => _updateSetting('enableSoundEffects', value),
                  ),
                  if (_currentSettings!.enableSoundEffects)
                    ListTile(
                      title: const Text('Âm lượng'),
                      subtitle: Slider(
                        value: _currentSettings!.soundVolume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 10,
                        label: '${(_currentSettings!.soundVolume * 100).round()}%',
                        onChanged: (value) => _updateSetting('soundVolume', value),
                      ),
                    ),
                  SwitchListTile(
                    title: const Text('Phản hồi haptic'),
                    subtitle: const Text('Rung nhẹ khi tương tác'),
                    value: _currentSettings!.enableHapticFeedback,
                    onChanged: (value) => _updateSetting('enableHapticFeedback', value),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Web Speech fallback (Web)'),
                    subtitle: const Text('Dùng cơ chế mô phỏng ổn định khi plugin web không ổn định'),
                    value: _currentSettings!.useWebSpeechFallback,
                    onChanged: (value) => _updateSetting('useWebSpeechFallback', value),
                  ),
                  SwitchListTile(
                    title: const Text('Tự động tổng hợp giọng nói'),
                    subtitle: const Text('Tự động phát âm thanh khi avatar trả lời'),
                    value: _currentSettings!.autoVoiceSynthesis,
                    onChanged: (value) => _updateSetting('autoVoiceSynthesis', value),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Storage Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storage),
                    title: const Text('Lưu trữ'),
                    subtitle: const Text('Quản lý dữ liệu'),
                    trailing: const Icon(Icons.expand_more),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Tự động lưu'),
                    subtitle: const Text('Tự động lưu các thay đổi'),
                    value: _currentSettings!.autoSave,
                    onChanged: (value) => _updateSetting('autoSave', value),
                  ),
                  ListTile(
                    title: const Text('Giới hạn cấu hình'),
                    subtitle: Text(_currentSettings!.maxStoredConfigurations > 0 
                        ? '${_currentSettings!.maxStoredConfigurations} cấu hình'
                        : 'Không giới hạn'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // App Info Section
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Thông tin ứng dụng'),
                    trailing: const Icon(Icons.expand_more),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Phiên bản'),
                    subtitle: Text(_currentSettings!.appVersion),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Thông tin phiên bản'),
                          content: Text('Phiên bản: ${_currentSettings!.appVersion}'),
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
                  ListTile(
                    title: const Text('Giấy phép'),
                    subtitle: const Text('Thông tin giấy phép mã nguồn mở'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: 'Avatar Configuration App',
                        applicationVersion: _currentSettings!.appVersion,
                      );
                    },
                  ),
                  ListTile(
                    title: const Text('Debug API Keys'),
                    subtitle: const Text('Kiểm tra trạng thái API keys'),
                    trailing: const Icon(Icons.bug_report),
                    onTap: () async {
                      try {
                        final debugInfo = await ApiConfigService.debugApiKeys();
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('API Keys Debug Info'),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('Platform: ${debugInfo['platform']}'),
                                    const SizedBox(height: 8),
                                    Text('OpenAI Key: ${debugInfo['openai_has_key'] ? '✅ Found' : '❌ Missing'}'),
                                    if (debugInfo['openai_key_preview'] != null)
                                      Text('Preview: ${debugInfo['openai_key_preview']}'),
                                    const SizedBox(height: 8),
                                    Text('ElevenLabs Key: ${debugInfo['elevenlabs_has_key'] ? '✅ Found' : '❌ Missing'}'),
                                    if (debugInfo['elevenlabs_key_preview'] != null)
                                      Text('Preview: ${debugInfo['elevenlabs_key_preview']}'),
                                    if (debugInfo['error'] != null) ...[
                                      const SizedBox(height: 8),
                                      Text('Error: ${debugInfo['error']}', style: const TextStyle(color: Colors.red)),
                                    ],
                                  ],
                                ),
                              ),
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
                            SnackBar(content: Text('Lỗi debug: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String _getThemeDescription(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return 'Theo hệ thống';
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
    }
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return 'Không xác định';
    }
  }
}