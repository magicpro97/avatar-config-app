import 'package:flutter/material.dart';
import '../../../data/services/api_config_service.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final TextEditingController _openAiController = TextEditingController();
  final TextEditingController _elevenLabsController = TextEditingController();
  
  bool _isLoading = false;
  bool _hasOpenAiKey = false;
  bool _hasElevenLabsKey = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentKeys();
  }

  @override
  void dispose() {
    _openAiController.dispose();
    _elevenLabsController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentKeys() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final hasOpenAi = await ApiConfigService.hasOpenAiApiKey();
      final hasElevenLabs = await ApiConfigService.hasElevenLabsApiKey();
      
      setState(() {
        _hasOpenAiKey = hasOpenAi;
        _hasElevenLabsKey = hasElevenLabs;
        _isLoading = false;
      });

      // Load actual keys for editing (masked)
      if (_hasOpenAiKey) {
        final key = await ApiConfigService.getOpenAiApiKey();
        _openAiController.text = _maskApiKey(key ?? '');
      }
      
      if (_hasElevenLabsKey) {
        final key = await ApiConfigService.getElevenLabsApiKey();
        _elevenLabsController.text = _maskApiKey(key ?? '');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải cấu hình API: $e')),
        );
      }
    }
  }

  String _maskApiKey(String key) {
    if (key.isEmpty) return '';
    if (key.length <= 8) return key;
    
    final start = key.substring(0, 4);
    final end = key.substring(key.length - 4);
    final middle = '*' * (key.length - 8);
    
    return '$start$middle$end';
  }

  Future<void> _saveOpenAiKey() async {
    final key = _openAiController.text.trim();
    
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập API key')),
      );
      return;
    }

    // Skip validation if the key is masked (already saved)
    if (!key.contains('*') && !ApiConfigService.isValidOpenAiApiKey(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key không hợp lệ. Phải bắt đầu bằng "sk-"')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Only save if it's not a masked key
      if (!key.contains('*')) {
        await ApiConfigService.setOpenAiApiKey(key);
      }
      
      await _loadCurrentKeys();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu API key OpenAI thành công!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu API key: $e')),
        );
      }
    }
  }

  Future<void> _saveElevenLabsKey() async {
    final key = _elevenLabsController.text.trim();
    
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập API key')),
      );
      return;
    }

    // Skip validation if the key is masked (already saved)
    if (!key.contains('*') && !ApiConfigService.isValidElevenLabsApiKey(key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API key không hợp lệ')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Only save if it's not a masked key
      if (!key.contains('*')) {
        await ApiConfigService.setElevenLabsApiKey(key);
      }
      
      await _loadCurrentKeys();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu API key ElevenLabs thành công!')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi lưu API key: $e')),
        );
      }
    }
  }

  Future<void> _removeOpenAiKey() async {
    final confirmed = await _showConfirmDialog(
      'Xóa API Key OpenAI',
      'Bạn có chắc chắn muốn xóa API key OpenAI? Tính năng trò chuyện thông minh sẽ không hoạt động.',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiConfigService.removeOpenAiApiKey();
      _openAiController.clear();
      await _loadCurrentKeys();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa API key OpenAI')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa API key: $e')),
        );
      }
    }
  }

  Future<void> _removeElevenLabsKey() async {
    final confirmed = await _showConfirmDialog(
      'Xóa API Key ElevenLabs',
      'Bạn có chắc chắn muốn xóa API key ElevenLabs? Tính năng tổng hợp giọng nói sẽ không hoạt động.',
    );

    if (!confirmed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiConfigService.removeElevenLabsApiKey();
      _elevenLabsController.clear();
      await _loadCurrentKeys();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa API key ElevenLabs')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi xóa API key: $e')),
        );
      }
    }
  }

  Future<bool> _showConfirmDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cấu hình API'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // OpenAI Configuration Card
              _buildApiKeyCard(
                title: 'OpenAI API Key',
                subtitle: 'Cho tính năng trò chuyện thông minh với avatar',
                controller: _openAiController,
                hasKey: _hasOpenAiKey,
                onSave: _saveOpenAiKey,
                onRemove: _removeOpenAiKey,
                helpText: 'API key phải bắt đầu bằng "sk-". Bạn có thể lấy từ https://platform.openai.com/api-keys',
                icon: Icons.psychology,
                color: Colors.green,
              ),
              
              const SizedBox(height: 20),
              
              // ElevenLabs Configuration Card
              _buildApiKeyCard(
                title: 'ElevenLabs API Key',
                subtitle: 'Cho tính năng tổng hợp giọng nói chất lượng cao',
                controller: _elevenLabsController,
                hasKey: _hasElevenLabsKey,
                onSave: _saveElevenLabsKey,
                onRemove: _removeElevenLabsKey,
                helpText: 'Bạn có thể lấy API key từ https://elevenlabs.io/app/settings/api-keys',
                icon: Icons.record_voice_over,
                color: Colors.blue,
              ),
              
              const SizedBox(height: 30),
              
              // Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Thông tin quan trọng',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '• OpenAI API key: Bắt buộc để sử dụng tính năng trò chuyện thông minh. Không có key sẽ sử dụng phản hồi có sẵn.\n'
                        '• ElevenLabs API key: Tùy chọn cho tổng hợp giọng nói chất lượng cao.\n'
                        '• API keys được lưu trữ bảo mật trên thiết bị của bạn.\n'
                        '• Bạn chịu trách nhiệm về chi phí sử dụng API.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildApiKeyCard({
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required bool hasKey,
    required VoidCallback onSave,
    required VoidCallback onRemove,
    required String helpText,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasKey ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: hasKey ? Colors.green : Colors.orange,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    hasKey ? 'Đã cấu hình' : 'Chưa cấu hình',
                    style: TextStyle(
                      color: hasKey ? Colors.green : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'API Key',
                hintText: hasKey ? 'Key đã được lưu (được mã hóa)' : 'Nhập API key của bạn',
                border: const OutlineInputBorder(),
                suffixIcon: hasKey ? Icon(Icons.check_circle, color: Colors.green) : null,
              ),
              obscureText: !controller.text.contains('*'), // Show plain text for masked keys
              maxLines: 1,
            ),
            
            const SizedBox(height: 8),
            
            Text(
              helpText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : onSave,
                    icon: const Icon(Icons.save),
                    label: const Text('Lưu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                if (hasKey) ...[
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : onRemove,
                    icon: const Icon(Icons.delete),
                    label: const Text('Xóa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}