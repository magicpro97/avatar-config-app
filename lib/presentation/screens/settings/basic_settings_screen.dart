import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/app_state_provider.dart';
import '../../widgets/common/copyable_error_widget.dart';
import 'api_settings_screen.dart';

/// Functional settings screen with interactive buttons
class BasicSettingsScreen extends StatefulWidget {
  const BasicSettingsScreen({super.key});

  @override
  State<BasicSettingsScreen> createState() => _BasicSettingsScreenState();
}

class _BasicSettingsScreenState extends State<BasicSettingsScreen> {
  bool _soundEffectsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadExistingApiKey();
  }

  Future<void> _loadExistingApiKey() async {
    // Force reload the API key from persistent storage
    final appState = context.read<AppStateProvider>();
    await appState.initialize(); // Reload settings to ensure API key is current
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn giao diện'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_7),
                title: const Text('Sáng'),
                onTap: () {
                  context.read<AppStateProvider>().setTheme(AppTheme.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_4),
                title: const Text('Tối'),
                onTap: () {
                  context.read<AppStateProvider>().setTheme(AppTheme.dark);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('Tự động'),
                onTap: () {
                  context.read<AppStateProvider>().setTheme(AppTheme.system);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quản lý lưu trữ'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dữ liệu đã lưu:'),
              SizedBox(height: 8),
              Text('• Cấu hình avatar: 5 MB'),
              Text('• Giọng nói: 12 MB'),
              Text('• Cache: 3 MB'),
              SizedBox(height: 16),
              Text('Tổng cộng: 20 MB'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Xóa cache'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }


  void _showAppInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Thông tin ứng dụng'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Avatar Config App'),
              SizedBox(height: 8),
              Text('Phiên bản: 1.0.0'),
              Text('Build: 2024.12.01'),
              SizedBox(height: 16),
              Text('Nhà phát triển: Avatar Team'),
              Text('Email: support@avatar.app'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Màn hình cài đặt',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // API Key Configuration - Navigate to dedicated API Settings screen
            Consumer<AppStateProvider>(
              builder: (context, appState, child) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: const Text('Cấu hình API'),
                    subtitle: Text(
                      appState.hasValidApiKey
                        ? 'API Key đã được cấu hình'
                        : 'Cấu hình OpenAI và ElevenLabs API Keys'
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (appState.hasValidApiKey)
                          Icon(
                            Icons.check_circle,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_ios),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ApiSettingsScreen(),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            
            // Theme Settings
            Card(
              child: ListTile(
                leading: const Icon(Icons.palette),
                title: const Text('Giao diện'),
                subtitle: const Text('Chủ đề và ngôn ngữ'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showThemeDialog,
              ),
            ),
            const SizedBox(height: 10),
            
            // Sound Settings
            Card(
              child: ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Âm thanh'),
                subtitle: const Text('Hiệu ứng âm thanh'),
                trailing: Switch(
                  value: _soundEffectsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      _soundEffectsEnabled = value;
                    });
                    
                    // Show feedback
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            value
                              ? 'Đã bật hiệu ứng âm thanh'
                              : 'Đã tắt hiệu ứng âm thanh'
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // Storage Settings
            Card(
              child: ListTile(
                leading: const Icon(Icons.storage),
                title: const Text('Lưu trữ'),
                subtitle: const Text('Quản lý dữ liệu'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showStorageDialog,
              ),
            ),
            const SizedBox(height: 10),
            
            // App Info
            Card(
              child: ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Thông tin ứng dụng'),
                subtitle: const Text('Phiên bản 1.0.0'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: _showAppInfoDialog,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Error handling methods for API key functionality
  void _showApiKeyValidationError(String errorMessage) {
    CopyableErrorDialog.show(
      context,
      errorMessage: errorMessage,
      title: 'Lỗi xác thực API Key',
      icon: Icons.vpn_key_off,
    );
  }

  void _showApiKeySaveError(String error) {
    final detailedError = '''
Lỗi khi lưu API Key:

Chi tiết lỗi:
$error

Các bước khắc phục:
1. Kiểm tra kết nối internet
2. Đảm bảo API key đúng định dạng
3. Thử lại sau vài phút
4. Liên hệ hỗ trợ nếu lỗi tiếp diễn
    ''';
    
    CopyableErrorDialog.show(
      context,
      errorMessage: detailedError,
      title: 'Lỗi lưu API Key',
      icon: Icons.save_alt,
    );
  }
}