import 'package:flutter/material.dart';

import 'setting_tile.dart';

/// A selector widget for choosing storage limit
class StorageLimitSelector extends StatelessWidget {
  final int currentLimit;
  final ValueChanged<int> onLimitChanged;
  final String? title;
  final String? subtitle;

  const StorageLimitSelector({
    super.key,
    required this.currentLimit,
    required this.onLimitChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title ?? 'Giới hạn lưu trữ',
      subtitle: subtitle ?? _getLimitDescription(currentLimit),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => _showLimitSelector(context),
    );
  }

  String _getLimitDescription(int limit) {
    if (limit <= 0) {
      return 'Không giới hạn';
    } else {
      return 'Tối đa $limit cấu hình';
    }
  }

  List<StorageLimit> _getAvailableLimits() {
    return [
      const StorageLimit(
        limit: 0,
        title: 'Không giới hạn',
        subtitle: 'Lưu trữ không giới hạn số lượng cấu hình',
        icon: Icons.all_inclusive,
        warning: 'Có thể làm chậm ứng dụng với dữ liệu lớn',
      ),
      const StorageLimit(
        limit: 50,
        title: '50 cấu hình',
        subtitle: 'Phù hợp cho việc sử dụng cá nhân',
        icon: Icons.folder,
      ),
      const StorageLimit(
        limit: 100,
        title: '100 cấu hình',
        subtitle: 'Cân bằng tốt giữa dung lượng và hiệu suất',
        icon: Icons.folder_copy,
        recommended: true,
      ),
      const StorageLimit(
        limit: 250,
        title: '250 cấu hình',
        subtitle: 'Phù hợp cho việc sử dụng chuyên nghiệp',
        icon: Icons.folder_special,
      ),
      const StorageLimit(
        limit: 500,
        title: '500 cấu hình',
        subtitle: 'Dung lượng lưu trữ lớn',
        icon: Icons.storage,
        warning: 'Có thể ảnh hưởng đến hiệu suất',
      ),
      const StorageLimit(
        limit: 1000,
        title: '1000 cấu hình',
        subtitle: 'Dung lượng lưu trữ rất lớn',
        icon: Icons.cloud_queue,
        warning: 'Khuyến nghị chỉ cho thiết bị mạnh',
      ),
    ];
  }

  void _showLimitSelector(BuildContext context) {
    final limits = _getAvailableLimits();
    
    showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chọn giới hạn lưu trữ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Khi đạt giới hạn, các cấu hình cũ nhất sẽ được xóa tự động',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: limits.map((limit) => _LimitOption(
                    limit: limit,
                    isSelected: currentLimit == limit.limit,
                    onTap: () {
                      onLimitChanged(limit.limit);
                      Navigator.of(context).pop();
                    },
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class StorageLimit {
  final int limit;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool recommended;
  final String? warning;

  const StorageLimit({
    required this.limit,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.recommended = false,
    this.warning,
  });
}

class _LimitOption extends StatelessWidget {
  final StorageLimit limit;
  final bool isSelected;
  final VoidCallback onTap;

  const _LimitOption({
    required this.limit,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : null,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    limit.icon,
                    color: isSelected 
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            limit.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: isSelected 
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          if (limit.recommended) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Khuyến nghị',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        limit.subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            if (limit.warning != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      size: 16,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        limit.warning!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A widget showing current storage usage
class StorageUsageWidget extends StatelessWidget {
  final int currentCount;
  final int maxCount;
  final int? totalSize;

  const StorageUsageWidget({
    super.key,
    required this.currentCount,
    required this.maxCount,
    this.totalSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlimited = maxCount <= 0;
    final usagePercent = isUnlimited ? 0.0 : (currentCount / maxCount).clamp(0.0, 1.0);
    final isNearLimit = usagePercent > 0.8;
    
    Color progressColor;
    if (isNearLimit) {
      progressColor = theme.colorScheme.error;
    } else if (usagePercent > 0.6) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sử dụng lưu trữ',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalSize != null)
                Text(
                  _formatSize(totalSize!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isUnlimited 
                ? '$currentCount cấu hình (không giới hạn)'
                : '$currentCount / $maxCount cấu hình',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: progressColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!isUnlimited) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: usagePercent,
              backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
            if (isNearLimit) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.warning,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Gần đạt giới hạn lưu trữ',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
}