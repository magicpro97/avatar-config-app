import 'package:flutter/material.dart';
import '../../data/models/avatar_configuration_model.dart';
import '../dialogs/confirmation_dialog.dart';

/// Batch operations bar for multi-select configuration management
class BatchOperationsBar extends StatelessWidget {
  final Set<String> selectedIds;
  final List<AvatarConfigurationModel> allConfigurations;
  final VoidCallback? onSelectAll;
  final VoidCallback? onSelectNone;
  final VoidCallback? onCancel;
  final ValueChanged<Set<String>>? onDelete;
  final ValueChanged<Set<String>>? onExport;
  final ValueChanged<Set<String>>? onAddToFavorites;
  final ValueChanged<Set<String>>? onRemoveFromFavorites;
  final ValueChanged<Set<String>>? onAddTags;

  const BatchOperationsBar({
    super.key,
    required this.selectedIds,
    required this.allConfigurations,
    this.onSelectAll,
    this.onSelectNone,
    this.onCancel,
    this.onDelete,
    this.onExport,
    this.onAddToFavorites,
    this.onRemoveFromFavorites,
    this.onAddTags,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedIds.isEmpty) return const SizedBox.shrink();
    
    final theme = Theme.of(context);
    final selectedConfigurations = allConfigurations
        .where((config) => selectedIds.contains(config.id))
        .toList();
    
    final favoriteCount = selectedConfigurations
        .where((config) => config.isFavorite)
        .length;
    final nonFavoriteCount = selectedConfigurations.length - favoriteCount;
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row with count and cancel
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${selectedIds.length} mục đã chọn',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Hủy'),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Selection controls
              Row(
                children: [
                  TextButton.icon(
                    onPressed: selectedIds.length < allConfigurations.length
                        ? onSelectAll
                        : null,
                    icon: const Icon(Icons.select_all, size: 18),
                    label: const Text('Chọn tất cả'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onSelectNone,
                    icon: const Icon(Icons.deselect, size: 18),
                    label: const Text('Bỏ chọn'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Action buttons
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Favorite actions
                    if (nonFavoriteCount > 0)
                      _ActionButton(
                        icon: Icons.favorite_border,
                        label: 'Yêu thích ($nonFavoriteCount)',
                        onPressed: () => onAddToFavorites?.call(
                          selectedConfigurations
                              .where((c) => !c.isFavorite)
                              .map((c) => c.id)
                              .toSet(),
                        ),
                      ),
                    
                    if (favoriteCount > 0) ...[
                      if (nonFavoriteCount > 0) const SizedBox(width: 8),
                      _ActionButton(
                        icon: Icons.favorite,
                        label: 'Bỏ yêu thích ($favoriteCount)',
                        onPressed: () => onRemoveFromFavorites?.call(
                          selectedConfigurations
                              .where((c) => c.isFavorite)
                              .map((c) => c.id)
                              .toSet(),
                        ),
                        color: Colors.red,
                      ),
                    ],
                    
                    const SizedBox(width: 8),
                    
                    // Add tags
                    _ActionButton(
                      icon: Icons.label_outline,
                      label: 'Thêm thẻ',
                      onPressed: () => _showAddTagsDialog(context),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Export
                    _ActionButton(
                      icon: Icons.file_download_outlined,
                      label: 'Xuất',
                      onPressed: () => _handleExport(context),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Delete
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: 'Xóa',
                      onPressed: () => _handleDelete(context),
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleDelete(BuildContext context) async {
    final confirmed = await ConfirmationDialog.showBatchDeleteDialog(
      context,
      count: selectedIds.length,
    );
    
    if (confirmed) {
      onDelete?.call(selectedIds);
    }
  }

  void _handleExport(BuildContext context) async {
    final confirmed = await ConfirmationDialog.showExportDialog(
      context,
      destinationPath: 'Thư mục tải xuống',
      count: selectedIds.length,
    );
    
    if (confirmed) {
      onExport?.call(selectedIds);
    }
  }

  void _showAddTagsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddTagsDialog(
        onAddTags: (tags) {
          onAddTags?.call(selectedIds);
          Navigator.pop(context);
        },
      ),
    );
  }
}

/// Individual action button for batch operations
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    
    return FilledButton.tonalIcon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: FilledButton.styleFrom(
        backgroundColor: buttonColor.withValues(alpha: 0.1),
        foregroundColor: buttonColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Dialog for adding tags to multiple configurations
class AddTagsDialog extends StatefulWidget {
  final ValueChanged<List<String>> onAddTags;

  const AddTagsDialog({
    super.key,
    required this.onAddTags,
  });

  @override
  State<AddTagsDialog> createState() => _AddTagsDialogState();
}

class _AddTagsDialogState extends State<AddTagsDialog> {
  final _controller = TextEditingController();
  final _tags = <String>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _controller.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _controller.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: const Text('Thêm thẻ'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Nhập tên thẻ...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addTag,
                ),
              ),
              onSubmitted: (_) => _addTag(),
            ),
            
            const SizedBox(height: 16),
            
            // Current tags
            if (_tags.isNotEmpty) ...[
              Text(
                'Thẻ sẽ thêm:',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) => Chip(
                  label: Text(tag),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeTag(tag),
                )).toList(),
              ),
            ],
            
            // Suggested tags
            const SizedBox(height: 16),
            Text(
              'Thẻ phổ biến:',
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Công việc',
                'Cá nhân',
                'Giải trí',
                'Học tập',
                'Gia đình',
                'Bạn bè',
              ].map((tag) => ActionChip(
                label: Text(tag),
                onPressed: () {
                  if (!_tags.contains(tag)) {
                    setState(() => _tags.add(tag));
                  }
                },
              )).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _tags.isNotEmpty 
            ? () => widget.onAddTags(_tags)
            : null,
          child: const Text('Thêm'),
        ),
      ],
    );
  }
}

/// Progress indicator for batch operations
class BatchOperationProgress extends StatelessWidget {
  final String operation;
  final int current;
  final int total;
  final VoidCallback? onCancel;

  const BatchOperationProgress({
    super.key,
    required this.operation,
    required this.current,
    required this.total,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = total > 0 ? current / total : 0.0;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        operation,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$current / $total',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onCancel != null)
                  TextButton(
                    onPressed: onCancel,
                    child: const Text('Hủy'),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ],
        ),
      ),
    );
  }
}

/// Summary widget for batch operations results
class BatchOperationSummary extends StatelessWidget {
  final String operation;
  final int successCount;
  final int failureCount;
  final List<String> errors;
  final VoidCallback onDismiss;

  const BatchOperationSummary({
    super.key,
    required this.operation,
    required this.successCount,
    required this.failureCount,
    required this.errors,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSuccess = failureCount == 0;
    
    return Card(
      color: isSuccess 
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.error,
                  color: isSuccess 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$operation hoàn thành',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSuccess 
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thành công: $successCount${failureCount > 0 ? ' • Lỗi: $failureCount' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isSuccess 
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Đóng'),
                ),
              ],
            ),
            
            // Show errors if any
            if (errors.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lỗi chi tiết:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...errors.take(3).map((error) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '• $error',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  )),
                  if (errors.length > 3)
                    Text(
                      '... và ${errors.length - 3} lỗi khác',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}