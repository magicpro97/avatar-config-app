import 'package:flutter/material.dart';
import '../../data/models/avatar_configuration_model.dart';
import '../../presentation/dialogs/confirmation_dialog.dart';

/// Configuration card widget for displaying avatar configurations
class ConfigurationCard extends StatefulWidget {
  final AvatarConfigurationModel configuration;
  final bool isSelected;
  final bool isSelectionMode;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onDelete;
  final VoidCallback? onExport;
  final VoidCallback? onActivate;
  final ValueChanged<bool>? onFavoriteChanged;
  final ConfigurationCardStyle style;

  const ConfigurationCard({
    super.key,
    required this.configuration,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onSelectionChanged,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onDelete,
    this.onExport,
    this.onActivate,
    this.onFavoriteChanged,
    this.style = ConfigurationCardStyle.standard,
  });

  @override
  State<ConfigurationCard> createState() => _ConfigurationCardState();
}

class _ConfigurationCardState extends State<ConfigurationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.style) {
      case ConfigurationCardStyle.standard:
        return _buildStandardCard(context);
      case ConfigurationCardStyle.compact:
        return _buildCompactCard(context);
      case ConfigurationCardStyle.list:
        return _buildListCard(context);
    }
  }

  Widget _buildStandardCard(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.configuration.isActive;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isSelectionMode 
          ? () => widget.onSelectionChanged?.call(!widget.isSelected)
          : widget.onTap,
        child: Card(
          elevation: _isPressed ? 8 : 2,
          color: widget.isSelected
            ? theme.colorScheme.primaryContainer
            : isActive
              ? theme.colorScheme.secondaryContainer
              : null,
          child: Stack(
            children: [
              // Main content
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row with selection checkbox and favorite
                    Row(
                      children: [
                        if (widget.isSelectionMode) ...[
                          Checkbox(
                            value: widget.isSelected,
                            onChanged: (value) => 
                              widget.onSelectionChanged?.call(value ?? false),
                          ),
                          const SizedBox(width: 8),
                        ],
                        
                        // Configuration icon
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getPersonalityColor(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            _getPersonalityIcon(),
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Name and status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      widget.configuration.name,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (isActive) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Hoạt động',
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPersonalityName(),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Favorite button
                        IconButton(
                          icon: Icon(
                            widget.configuration.isFavorite 
                              ? Icons.favorite 
                              : Icons.favorite_border,
                            color: widget.configuration.isFavorite 
                              ? Colors.red 
                              : null,
                          ),
                          onPressed: () => widget.onFavoriteChanged?.call(
                            !widget.configuration.isFavorite
                          ),
                        ),
                        
                        // Context menu
                        if (!widget.isSelectionMode)
                          PopupMenuButton<String>(
                            onSelected: _handleMenuAction,
                            itemBuilder: (context) => [
                              if (!isActive)
                                const PopupMenuItem(
                                  value: 'activate',
                                  child: ListTile(
                                    leading: Icon(Icons.play_arrow),
                                    title: Text('Kích hoạt'),
                                  ),
                                ),
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
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Description
                    if (widget.configuration.description?.isNotEmpty == true) ...[
                      Text(
                        widget.configuration.description!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    // Voice info
                    ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.record_voice_over,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _getVoiceInfo(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                    
                    // Statistics row
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.configuration.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        
                        const Spacer(),
                        
                        if (widget.configuration.usageCount > 0) ...[
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.configuration.usageCount} lần',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    
                    // Tags
                    if (widget.configuration.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: widget.configuration.tags.take(3).map((tag) =>
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outline.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.configuration.isActive;
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isSelectionMode 
          ? () => widget.onSelectionChanged?.call(!widget.isSelected)
          : widget.onTap,
        child: Card(
          elevation: _isPressed ? 4 : 1,
          color: widget.isSelected
            ? theme.colorScheme.primaryContainer
            : isActive
              ? theme.colorScheme.secondaryContainer
              : null,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.isSelectionMode) ...[
                      Checkbox(
                        value: widget.isSelected,
                        onChanged: (value) => 
                          widget.onSelectionChanged?.call(value ?? false),
                      ),
                    ] else ...[
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _getPersonalityColor(context),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          _getPersonalityIcon(),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ],
                    
                    const SizedBox(width: 8),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.configuration.name,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            _getPersonalityName(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    if (widget.configuration.isFavorite)
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16,
                      ),
                    
                    if (isActive) ...[
                      const SizedBox(width: 4),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.configuration.usageCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    Text(
                      _formatDate(widget.configuration.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = widget.configuration.isActive;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: widget.isSelected
        ? theme.colorScheme.primaryContainer
        : isActive
          ? theme.colorScheme.secondaryContainer
          : null,
      child: ListTile(
        leading: widget.isSelectionMode
          ? Checkbox(
              value: widget.isSelected,
              onChanged: (value) => 
                widget.onSelectionChanged?.call(value ?? false),
            )
          : Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getPersonalityColor(context),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getPersonalityIcon(),
                color: Colors.white,
                size: 20,
              ),
            ),
        
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.configuration.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Hoạt động',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
          ],
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_getPersonalityName()),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(_formatDate(widget.configuration.createdAt)),
                const Spacer(),
                if (widget.configuration.usageCount > 0)
                  Text('${widget.configuration.usageCount} lần sử dụng'),
              ],
            ),
          ],
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.configuration.isFavorite)
              Icon(
                Icons.favorite,
                color: Colors.red,
                size: 20,
              ),
            
            if (!widget.isSelectionMode)
              PopupMenuButton<String>(
                onSelected: _handleMenuAction,
                itemBuilder: (context) => [
                  if (!isActive)
                    const PopupMenuItem(
                      value: 'activate',
                      child: ListTile(
                        leading: Icon(Icons.play_arrow),
                        title: Text('Kích hoạt'),
                      ),
                    ),
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
          ],
        ),
        
        onTap: widget.isSelectionMode 
          ? () => widget.onSelectionChanged?.call(!widget.isSelected)
          : widget.onTap,
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'activate':
        widget.onActivate?.call();
        break;
      case 'edit':
        widget.onEdit?.call();
        break;
      case 'duplicate':
        widget.onDuplicate?.call();
        break;
      case 'export':
        widget.onExport?.call();
        break;
      case 'delete':
        _handleDelete();
        break;
    }
  }

  void _handleDelete() async {
    final confirmed = await ConfirmationDialog.showDeleteDialog(
      context,
      itemName: widget.configuration.name,
    );
    
    if (confirmed) {
      widget.onDelete?.call();
    }
  }

  Color _getPersonalityColor(BuildContext context) {
    // You can implement personality-specific colors here
    // For now, using theme colors
    final theme = Theme.of(context);
    return theme.colorScheme.primary;
  }

  IconData _getPersonalityIcon() {
    // You can implement personality-specific icons here
    return Icons.person;
  }

  String _getPersonalityName() {
    return widget.configuration.personalityDisplayName;
  }

  String _getVoiceInfo() {
    final voice = widget.configuration.voiceConfiguration;
    
    return '${voice.gender} • ${voice.language}';
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

/// Configuration card display styles
enum ConfigurationCardStyle {
  standard,  // Full-featured card with all details
  compact,   // Smaller card for grid layouts
  list,      // List tile style for dense lists
}