// API Settings Screen for ElevenLabs API Key Management
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voice_provider.dart';
import '../../../core/storage/secure_storage.dart';
import '../../widgets/common/copyable_error_widget.dart';

class ApiSettingsScreen extends StatefulWidget {
  const ApiSettingsScreen({super.key});

  @override
  State<ApiSettingsScreen> createState() => _ApiSettingsScreenState();
}

class _ApiSettingsScreenState extends State<ApiSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  final _secureStorage = SecureStorage();
  
  bool _isLoading = false;
  bool _isValidating = false;
  bool _hasApiKey = false;
  bool _showApiKey = false;
  String? _validationError;
  String? _apiKeyPreview;
  Map<String, dynamic>? _apiUsageInfo;

  @override
  void initState() {
    super.initState();
    _loadApiKeyInfo();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadApiKeyInfo() async {
    setState(() => _isLoading = true);
    
    try {
      final apiKey = await _secureStorage.getApiKey();
      if (apiKey != null && apiKey.isNotEmpty) {
        setState(() {
          _hasApiKey = true;
          _apiKeyPreview = '${apiKey.substring(0, 8)}${'*' * (apiKey.length - 8)}';
        });
        
        // Load API usage information
        await _loadApiUsage();
      }
    } catch (e) {
      CopyableErrorDialog.show(
        context,
        errorMessage: 'Failed to load API key information',
        title: 'Lỗi tải thông tin API key',
        icon: Icons.error,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadApiUsage() async {
    try {
      final voiceProvider = context.read<VoiceProvider>();
      final usage = await voiceProvider.getApiUsage();
      setState(() => _apiUsageInfo = usage);
    } catch (e) {
      // Ignore usage loading errors
    }
  }

  Future<void> _validateAndSaveApiKey() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isValidating = true;
      _validationError = null;
    });

    try {
      final apiKey = _apiKeyController.text.trim();
      final voiceProvider = context.read<VoiceProvider>();
      
      // Validate API key
      final isValid = await voiceProvider.validateApiKey(apiKey);
      
      if (isValid) {
        // Save API key
        await _secureStorage.storeApiKey(apiKey);
        
        // Update state
        setState(() {
          _hasApiKey = true;
          _apiKeyPreview = '${apiKey.substring(0, 8)}${'*' * (apiKey.length - 8)}';
          _showApiKey = false;
        });
        
        // Clear the input
        _apiKeyController.clear();
        
        // Load usage information
        await _loadApiUsage();
        
        // Refresh voices
        await voiceProvider.refresh();
        
        _showSuccessSnackBar('API key saved successfully');
      } else {
        setState(() => _validationError = 'Invalid API key. Please check and try again.');
      }
    } catch (e) {
      setState(() => _validationError = 'Failed to validate API key: ${e.toString()}');
    } finally {
      setState(() => _isValidating = false);
    }
  }

  Future<void> _removeApiKey() async {
    final confirmed = await _showConfirmDialog(
      'Remove API Key',
      'Are you sure you want to remove the API key? This will disable voice synthesis features.',
    );
    
    if (confirmed == true) {
      try {
        await _secureStorage.clearAll();
        
        setState(() {
          _hasApiKey = false;
          _apiKeyPreview = null;
          _apiUsageInfo = null;
        });
        
        _showSuccessSnackBar('API key removed successfully');
      } catch (e) {
        CopyableErrorDialog.show(
          context,
          errorMessage: 'Failed to remove API key',
          title: 'Lỗi xóa API key',
          icon: Icons.error,
        );
      }
    }
  }

  Future<void> _testApiKey() async {
    if (!_hasApiKey) return;
    
    setState(() => _isValidating = true);
    
    try {
      final voiceProvider = context.read<VoiceProvider>();
      final success = await voiceProvider.testVoiceSynthesis();
      
      if (success) {
        _showSuccessSnackBar('API key is working correctly');
        await _loadApiUsage();
      } else {
        CopyableErrorDialog.show(
          context,
          errorMessage: 'API key test failed',
          title: 'Lỗi kiểm tra API',
          icon: Icons.error,
        );
      }
    } catch (e) {
      CopyableErrorDialog.show(
        context,
        errorMessage: 'API test failed: ${e.toString()}',
        title: 'Lỗi kiểm tra API',
        icon: Icons.error,
      );
    } finally {
      setState(() => _isValidating = false);
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('API Settings')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Settings'),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Key Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _hasApiKey ? Icons.check_circle : Icons.warning,
                          color: _hasApiKey ? Colors.green : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _hasApiKey ? 'API Key Configured' : 'No API Key',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: _hasApiKey ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_hasApiKey) ...[
                      Text(
                        'Key: $_apiKeyPreview',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ] else ...[
                      Text(
                        'Add your ElevenLabs API key to enable voice synthesis features.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // API Usage Information
            if (_apiUsageInfo != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.analytics),
                          const SizedBox(width: 8),
                          Text(
                            'API Usage',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildUsageRow('Tier', _apiUsageInfo!['tier']?.toString() ?? 'Unknown'),
                      _buildUsageRow('Status', _apiUsageInfo!['status']?.toString() ?? 'Unknown'),
                      _buildUsageRow(
                        'Characters Used', 
                        '${_apiUsageInfo!['character_count'] ?? 0} / ${_apiUsageInfo!['character_limit'] ?? 0}',
                      ),
                      _buildUsageRow(
                        'Remaining', 
                        '${_apiUsageInfo!['remaining_characters'] ?? 0} characters',
                      ),
                      if (_apiUsageInfo!['next_reset'] != null)
                        _buildUsageRow(
                          'Next Reset', 
                          _formatDateTime(_apiUsageInfo!['next_reset'] as DateTime),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // API Key Management
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.vpn_key),
                        const SizedBox(width: 8),
                        Text(
                          _hasApiKey ? 'Update API Key' : 'Add API Key',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    if (!_hasApiKey || _showApiKey) ...[
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _apiKeyController,
                              decoration: InputDecoration(
                                labelText: 'ElevenLabs API Key',
                                hintText: 'sk-...',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: Icon(_showApiKey ? Icons.visibility_off : Icons.visibility),
                                  onPressed: () => setState(() => _showApiKey = !_showApiKey),
                                ),
                                errorText: _validationError,
                              ),
                              obscureText: !_showApiKey,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your API key';
                                }
                                if (!value.startsWith('sk-')) {
                                  return 'API key should start with "sk-"';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isValidating ? null : _validateAndSaveApiKey,
                                    child: _isValidating
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text('Save & Validate'),
                                  ),
                                ),
                                if (_hasApiKey) ...[
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      _showApiKey = false;
                                      _apiKeyController.clear();
                                      _validationError = null;
                                    }),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // API Key Actions
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isValidating ? null : _testApiKey,
                            icon: _isValidating 
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.play_arrow),
                            label: const Text('Test API'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () => setState(() => _showApiKey = true),
                            icon: const Icon(Icons.edit),
                            label: const Text('Update'),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: _removeApiKey,
                            icon: const Icon(Icons.delete),
                            label: const Text('Remove'),
                            style: TextButton.styleFrom(foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info),
                        const SizedBox(width: 8),
                        Text(
                          'How to get your API key',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '1. Visit elevenlabs.io and create an account\n'
                      '2. Go to your Profile Settings\n'
                      '3. Copy your API key from the API Key section\n'
                      '4. Paste it here to enable voice synthesis\n\n'
                      'Your API key is stored securely on your device.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}