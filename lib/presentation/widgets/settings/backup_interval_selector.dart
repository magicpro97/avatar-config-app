import 'package:flutter/material.dart';

import 'setting_tile.dart';

/// A selector widget for choosing backup interval
class BackupIntervalSelector extends StatelessWidget {
  final int currentInterval;
  final ValueChanged<int> onIntervalChanged;
  final String? title;
  final String? subtitle;

  const BackupIntervalSelector({
    super.key,
    required this.currentInterval,
    required this.onIntervalChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title ?? 'Tần suất sao lưu tự động',
      subtitle: subtitle ?? _getIntervalDescription(currentInterval),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => _showIntervalSelector(context),
    );
  }

  String _getIntervalDescription(int hours) {
    if (hours == 0) {
      return 'Tắt sao lưu tự động';
    } else if (hours == 1) {
      return 'Mỗi giờ';
    } else if (hours < 24) {
      return 'Mỗi $hours giờ';
    } else if (hours == 24) {
      return 'Hàng ngày';
    } else if (hours == 168) { // 7 * 24
      return 'Hàng tuần';
    } else if (hours == 720) { // 30 * 24
      return 'Hàng tháng';
    } else {
      final days = (hours / 24).round();
      return 'Mỗi $days ngày';
    }
  }

  List<BackupInterval> _getAvailableIntervals() {
    return [
      const BackupInterval(
        hours: 0,
        title: 'Tắt sao lưu tự động',
        subtitle: 'Không tự động sao lưu',
        icon: Icons.backup_outlined,
      ),
      const BackupInterval(
        hours: 1,
        title: 'Mỗi giờ',
        subtitle: 'Sao lưu tự động mỗi giờ',
        icon: Icons.schedule,
      ),
      const BackupInterval(
        hours: 6,
        title: 'Mỗi 6 giờ',
        subtitle: 'Sao lưu tự động 4 lần/ngày',
        icon: Icons.access_time,
      ),
      const BackupInterval(
        hours: 12,
        title: 'Mỗi 12 giờ',
        subtitle: 'Sao lưu tự động 2 lần/ngày',
        icon: Icons.hourglass_empty,
      ),
      const BackupInterval(
        hours: 24,
        title: 'Hàng ngày',
        subtitle: 'Sao lưu tự động mỗi ngày',
        icon: Icons.today,
        recommended: true,
      ),
      const BackupInterval(
        hours: 168, // 7 * 24
        title: 'Hàng tuần',
        subtitle: 'Sao lưu tự động mỗi tuần',
        icon: Icons.date_range,
      ),
      const BackupInterval(
        hours: 720, // 30 * 24
        title: 'Hàng tháng',
        subtitle: 'Sao lưu tự động mỗi tháng',
        icon: Icons.calendar_month,
      ),
    ];
  }

  void _showIntervalSelector(BuildContext context) {
    final intervals = _getAvailableIntervals();
    
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
              'Chọn tần suất sao lưu',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dữ liệu sẽ được sao lưu tự động theo tần suất bạn chọn',
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
                  children: intervals.map((interval) => _IntervalOption(
                    interval: interval,
                    isSelected: currentInterval == interval.hours,
                    onTap: () {
                      onIntervalChanged(interval.hours);
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

class BackupInterval {
  final int hours;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool recommended;

  const BackupInterval({
    required this.hours,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.recommended = false,
  });
}

class _IntervalOption extends StatelessWidget {
  final BackupInterval interval;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntervalOption({
    required this.interval,
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
        child: Row(
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
                interval.icon,
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
                        interval.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (interval.recommended) ...[
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
                    interval.subtitle,
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
      ),
    );
  }
}

/// A compact backup status widget
class BackupStatusWidget extends StatelessWidget {
  final DateTime? lastBackupTime;
  final int intervalHours;
  final bool isBackingUp;
  final VoidCallback? onManualBackup;

  const BackupStatusWidget({
    super.key,
    this.lastBackupTime,
    required this.intervalHours,
    this.isBackingUp = false,
    this.onManualBackup,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    
    String statusText;
    Color statusColor;
    IconData statusIcon;
    
    if (isBackingUp) {
      statusText = 'Đang sao lưu...';
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.backup;
    } else if (lastBackupTime == null) {
      statusText = 'Chưa có sao lưu';
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.warning;
    } else if (intervalHours == 0) {
      statusText = 'Sao lưu tự động đã tắt';
      statusColor = theme.colorScheme.outline;
      statusIcon = Icons.backup_outlined;
    } else {
      final timeSinceBackup = now.difference(lastBackupTime!);
      final intervalDuration = Duration(hours: intervalHours);
      
      if (timeSinceBackup < intervalDuration) {
        statusText = 'Đã sao lưu ${_formatDuration(timeSinceBackup)} trước';
        statusColor = theme.colorScheme.primary;
        statusIcon = Icons.check_circle;
      } else {
        statusText = 'Sao lưu đã quá hạn ${_formatDuration(timeSinceBackup - intervalDuration)}';
        statusColor = theme.colorScheme.error;
        statusIcon = Icons.warning;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            statusIcon,
            color: statusColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isBackingUp && onManualBackup != null)
            TextButton(
              onPressed: onManualBackup,
              child: const Text('Sao lưu ngay'),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} ngày';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} giờ';
    } else {
      return '${duration.inMinutes} phút';
    }
  }
}