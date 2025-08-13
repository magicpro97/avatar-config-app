import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../providers/avatar_provider.dart';
import '../../dialogs/confirmation_dialog.dart';
import '../../../data/models/avatar_configuration_model.dart';
import '../../../data/services/backup_service.dart';
import '../../widgets/common/copyable_error_widget.dart';

/// Configuration details and edit screen with usage analytics
class ConfigurationDetailsScreen extends StatefulWidget {
  final AvatarConfigurationModel configuration;

  const ConfigurationDetailsScreen({
    super.key,
    required this.configuration,
  });

  @override
  State<ConfigurationDetailsScreen> createState() => _ConfigurationDetailsScreenState();
}

class _ConfigurationDetailsScreenState extends State<ConfigurationDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AvatarConfigurationModel _currentConfig;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentConfig = widget.configuration;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentConfig.name),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: Icon(_currentConfig.isFavorite ? Icons.favorite : Icons.favorite_border),
              onPressed: _toggleFavorite,
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Chỉnh sửa'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.content_copy),
                    title: Text('Sao chép'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.file_download),
                    title: Text('Xuất'),
                  ),
                ),
                if (!_currentConfig.isActive)
                  const PopupMenuItem(
                    value: 'activate',
                    child: ListTile(
                      leading: Icon(Icons.play_arrow),
                      title: Text('Kích hoạt'),
                    ),
                  ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Xóa', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: _cancelEdit,
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: _saveChanges,
              child: const Text('Lưu'),
            ),
          ],
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng quan', icon: Icon(Icons.info_outline)),
            Tab(text: 'Thống kê', icon: Icon(Icons.analytics_outlined)),
            Tab(text: 'Giọng nói', icon: Icon(Icons.record_voice_over)),
            Tab(text: 'Cài đặt', icon: Icon(Icons.settings_outlined)),
          ],
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(context),
          _buildAnalyticsTab(context),
          _buildVoiceTab(context),
          _buildSettingsTab(context),
        ],
      ),
      
      floatingActionButton: _currentConfig.isActive ? null : FloatingActionButton(
        onPressed: _activateConfiguration,
        tooltip: 'Kích hoạt cấu hình',
        child: const Icon(Icons.play_arrow),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getPersonalityColor(theme),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _getPersonalityIcon(),
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: _currentConfig.name));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Đã sao chép tên cấu hình'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.content_copy,
                                        size: 16,
                                        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _currentConfig.name,
                                        style: theme.textTheme.headlineSmall?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (_currentConfig.isActive)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'HOẠT ĐỘNG',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentConfig.personalityDisplayName,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Description
          if (_currentConfig.description?.isNotEmpty == true) ...[
            Text(
              'Mô tả',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: _currentConfig.description!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép mô tả'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_currentConfig.description!),
                        ),
                        Icon(
                          Icons.content_copy,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Basic info
          Text(
            'Thông tin cơ bản',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildInfoRow('Ngày tạo', _formatDate(_currentConfig.createdAt), true),
                  const Divider(),
                  _buildInfoRow('Cập nhật cuối', _formatDate(_currentConfig.lastModified), true),
                  if (_currentConfig.lastUsedDate != null) ...[
                    const Divider(),
                    _buildInfoRow('Lần dùng cuối', _formatDate(_currentConfig.lastUsedDate!), true),
                  ],
                  const Divider(),
                  _buildInfoRow('Lượt sử dụng', '${_currentConfig.usageCount} lần', false),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Tags
          if (_currentConfig.tags.isNotEmpty) ...[
            Text(
              'Thẻ',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _currentConfig.tags.map((tag) => Chip(
                    label: Text(tag),
                    deleteIcon: _isEditing ? const Icon(Icons.close, size: 18) : null,
                    onDeleted: _isEditing ? () => _removeTag(tag) : null,
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Voice preview
          Text(
            'Giọng nói',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentConfig.voiceConfiguration.name,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${_currentConfig.voiceConfiguration.gender.name} • ${_currentConfig.voiceConfiguration.language}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: _previewVoice,
                        tooltip: 'Nghe thử',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Usage statistics
          Text(
            'Thống kê sử dụng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Tổng lượt dùng',
                  '${_currentConfig.usageCount}',
                  Icons.trending_up,
                  theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Tuổi cấu hình',
                  '${_currentConfig.age.inDays} ngày',
                  Icons.schedule,
                  theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Lần cập nhật',
                  _currentConfig.isRecentlyModified ? 'Gần đây' : 'Lâu rồi',
                  Icons.update,
                  _currentConfig.isRecentlyModified 
                    ? Colors.green 
                    : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Trạng thái',
                  _currentConfig.isActive ? 'Hoạt động' : 'Không hoạt động',
                  _currentConfig.isActive ? Icons.check_circle : Icons.radio_button_unchecked,
                  _currentConfig.isActive 
                    ? Colors.green 
                    : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Usage frequency chart (placeholder)
          Text(
            'Biểu đồ sử dụng',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Container(
              height: 200,
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bar_chart,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Biểu đồ thống kê sẽ sớm có',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTab(BuildContext context) {
    final theme = Theme.of(context);
    final voiceConfig = _currentConfig.voiceConfiguration;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          voiceConfig.name,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: _previewVoice,
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildVoiceInfoChip('Giới tính', voiceConfig.gender.name, theme),
                      const SizedBox(width: 8),
                      _buildVoiceInfoChip('Ngôn ngữ', voiceConfig.language, theme),
                      const SizedBox(width: 8),
                      _buildVoiceInfoChip('Giọng', voiceConfig.accent, theme),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice parameters
          Text(
            'Thông số giọng nói',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildParameterSlider(
                    'Stability',
                    voiceConfig.settings.stability,
                    0.0,
                    1.0,
                    (value) {},
                  ),
                  _buildParameterSlider(
                    'Similarity Boost',
                    voiceConfig.settings.similarityBoost,
                    0.0,
                    1.0,
                    (value) {},
                  ),
                  _buildParameterSlider(
                    'Style',
                    voiceConfig.settings.style,
                    0.0,
                    1.0,
                    (value) {},
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Voice test
          Text(
            'Thử giọng nói',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    decoration: const InputDecoration(
                      hintText: 'Nhập văn bản để thử giọng nói...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: _previewVoice,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Phát'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.stop),
                        label: const Text('Dừng'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick actions
          Text(
            'Thao tác nhanh',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(_currentConfig.isFavorite ? Icons.favorite : Icons.favorite_border),
                  title: Text(_currentConfig.isFavorite ? 'Bỏ khỏi yêu thích' : 'Thêm vào yêu thích'),
                  onTap: _toggleFavorite,
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: const Text('Sao chép cấu hình'),
                  onTap: () => _handleMenuAction('duplicate'),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.file_download),
                  title: const Text('Xuất cấu hình'),
                  onTap: () => _handleMenuAction('export'),
                ),
                if (!_currentConfig.isActive) ...[
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.play_arrow),
                    title: const Text('Kích hoạt cấu hình'),
                    onTap: _activateConfiguration,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Danger zone
          Text(
            'Vùng nguy hiểm',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.red.withValues(alpha: 0.1),
            child: ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Xóa cấu hình', style: TextStyle(color: Colors.red)),
              subtitle: const Text('Hành động này không thể hoàn tác'),
              onTap: () => _handleMenuAction('delete'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, [bool isCopyable = false]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w400),
                ),
              ),
              if (isCopyable)
                IconButton(
                  icon: Icon(
                    Icons.content_copy,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Đã sao chép'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceInfoChip(String label, String value, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildParameterSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(value.toStringAsFixed(2)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: _isEditing ? onChanged : null,
        ),
      ],
    );
  }

  // Action handlers
  void _handleMenuAction(String action) async {
    switch (action) {
      case 'edit':
        setState(() => _isEditing = true);
        break;
      case 'duplicate':
        final confirmed = await ConfirmationDialog.showDuplicateDialog(
          context,
          originalName: _currentConfig.name,
        );
        if (confirmed && mounted) {
          try {
            // Don't use BuildContext across async gaps - use context.read() instead
            final provider = context.read<AvatarProvider>();
            final newId = 'config_${DateTime.now().millisecondsSinceEpoch}';
            final duplicatedConfig = _currentConfig.duplicate(newId);
            await provider.createConfiguration(duplicatedConfig.toDomain());
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã sao chép: ${duplicatedConfig.name}')),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Lỗi sao chép: Nhấn "Chi tiết" để xem và sao chép')),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          CopyableErrorDialog.show(
                            context,
                            errorMessage: e.toString(),
                            title: 'Lỗi sao chép cấu hình',
                            icon: Icons.content_copy,
                          );
                        },
                        child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        break;
      case 'export':
        try {
          final backupService = BackupService(avatarRepository: context.read<AvatarProvider>().repository);
          final result = await backupService.exportSingleConfiguration(_currentConfig.id);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Đã xuất cấu hình đến: $result')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Lỗi xuất cấu hình: Nhấn "Chi tiết" để xem và sao chép')),
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        CopyableErrorDialog.show(
                          context,
                          errorMessage: e.toString(),
                          title: 'Lỗi xuất cấu hình',
                          icon: Icons.error,
                        );
                      },
                      child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
        break;
      case 'activate':
        _activateConfiguration();
        break;
      case 'delete':
        final confirmed = await ConfirmationDialog.showDeleteDialog(
          context,
          itemName: _currentConfig.name,
        );
        if (confirmed) {
          if (mounted) {
            final provider = context.read<AvatarProvider>();
            provider.deleteConfiguration(_currentConfig.id);
            Navigator.pop(context);
          }
        }
        break;
    }
  }

  void _toggleFavorite() async {
    try {
      final provider = context.read<AvatarProvider>();
      final updatedModel = _currentConfig.copyWith(isFavorite: !_currentConfig.isFavorite);
      final updatedConfig = updatedModel.toDomain();
      
      await provider.updateConfiguration(updatedConfig);
      
      setState(() {
        _currentConfig = updatedModel;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_currentConfig.isFavorite
              ? 'Đã thêm vào yêu thích'
              : 'Đã bỏ khỏi yêu thích'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi cập nhật yêu thích: Nhấn "Chi tiết" để xem và sao chép')),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    CopyableErrorDialog.show(
                      context,
                      errorMessage: e.toString(),
                      title: 'Lỗi cập nhật yêu thích',
                      icon: Icons.favorite,
                    );
                  },
                  child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _activateConfiguration() {
    final provider = context.read<AvatarProvider>();
    provider.activateConfiguration(_currentConfig.id);
    setState(() {
      _currentConfig = _currentConfig.copyWith(isActive: true);
    });
  }

  void _previewVoice() async {
    try {
      // For now, simulate voice preview functionality
      // In a real implementation, this would:
      // 1. Call ElevenLabs API to synthesize text
      // 2. Download the audio file
      // 3. Play the audio using the audio player
      
      // Provider variable is not used - remove to fix unused variable warning
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đang tạo âm thanh với giọng "${_currentConfig.voiceConfiguration.name}"...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
      
      // Simulate more processing time
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Âm thanh đã tạo thành công! (Tính năng phát âm thanh sẽ được triển khai trong bản cập nhật tiếp theo)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi tạo âm thanh: Nhấn "Chi tiết" để xem và sao chép')),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    CopyableErrorDialog.show(
                      context,
                      errorMessage: e.toString(),
                      title: 'Lỗi tạo âm thanh',
                      icon: Icons.error,
                    );
                  },
                  child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _removeTag(String tag) {
    setState(() {
      final newTags = List<String>.from(_currentConfig.tags);
      newTags.remove(tag);
      _currentConfig = _currentConfig.copyWith(tags: newTags);
    });
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      // Reset to original configuration if needed
      _currentConfig = widget.configuration;
    });
  }

  void _saveChanges() async {
    try {
      final provider = context.read<AvatarProvider>();
      
      // Convert the current model to domain entity
      final updatedConfig = _currentConfig.toDomain();
      
      // Save to repository
      await provider.updateConfiguration(updatedConfig);
      
      // Update the state to exit editing mode
      setState(() {
        _isEditing = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thay đổi đã được lưu thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Lỗi lưu thay đổi: Nhấn "Chi tiết" để xem và sao chép')),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    CopyableErrorDialog.show(
                      context,
                      errorMessage: e.toString(),
                      title: 'Lỗi lưu thay đổi',
                      icon: Icons.save,
                    );
                  },
                  child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getPersonalityColor(ThemeData theme) {
    // You can implement personality-specific colors here
    return theme.colorScheme.primary;
  }

  IconData _getPersonalityIcon() {
    // You can implement personality-specific icons here
    return Icons.person;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hôm nay';
    } else if (difference.inDays == 1) {
      return 'Hôm qua';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} tuần trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}