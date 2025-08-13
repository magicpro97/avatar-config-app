import 'package:flutter/material.dart';

import 'setting_tile.dart';

/// A selector widget for choosing app themes
class ThemeSelector extends StatelessWidget {
  final ThemeMode currentTheme;
  final ValueChanged<ThemeMode> onThemeChanged;
  final String? title;
  final String? subtitle;

  const ThemeSelector({
    super.key,
    required this.currentTheme,
    required this.onThemeChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title ?? 'Chủ đề',
      subtitle: subtitle ?? _getThemeDescription(currentTheme),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => _showThemeSelector(context),
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

  IconData _getThemeIcon(ThemeMode theme) {
    switch (theme) {
      case ThemeMode.system:
        return Icons.brightness_auto;
      case ThemeMode.light:
        return Icons.brightness_7;
      case ThemeMode.dark:
        return Icons.brightness_2;
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet<ThemeMode>(
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
              'Chọn chủ đề',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _ThemeOption(
              theme: ThemeMode.system,
              title: 'Theo hệ thống',
              subtitle: 'Tự động thay đổi theo cài đặt thiết bị',
              icon: _getThemeIcon(ThemeMode.system),
              isSelected: currentTheme == ThemeMode.system,
              onTap: () {
                onThemeChanged(ThemeMode.system);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              theme: ThemeMode.light,
              title: 'Chủ đề sáng',
              subtitle: 'Hiển thị giao diện sáng',
              icon: _getThemeIcon(ThemeMode.light),
              isSelected: currentTheme == ThemeMode.light,
              onTap: () {
                onThemeChanged(ThemeMode.light);
                Navigator.of(context).pop();
              },
            ),
            _ThemeOption(
              theme: ThemeMode.dark,
              title: 'Chủ đề tối',
              subtitle: 'Hiển thị giao diện tối',
              icon: _getThemeIcon(ThemeMode.dark),
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () {
                onThemeChanged(ThemeMode.dark);
                Navigator.of(context).pop();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final ThemeMode theme;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.theme,
    required this.title,
    required this.subtitle,
    required this.icon,
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
                icon,
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
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: isSelected 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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