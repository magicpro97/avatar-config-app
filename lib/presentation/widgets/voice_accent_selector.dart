import 'package:flutter/material.dart';

class VoiceAccentSelector extends StatelessWidget {
  final List<String> availableAccents;
  final String? selectedAccent;
  final ValueChanged<String?> onAccentChanged;
  final bool allowNull;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const VoiceAccentSelector({
    super.key,
    required this.availableAccents,
    required this.selectedAccent,
    required this.onAccentChanged,
    this.allowNull = true,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title ?? 'Giọng địa phương (Accent)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn giọng địa phương phù hợp với nhu cầu',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Accent selection grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (allowNull)
                _AccentCard(
                  accent: null,
                  displayName: 'Tất cả',
                  flagIcon: Icons.public,
                  isSelected: selectedAccent == null,
                  onTap: () => onAccentChanged(null),
                  theme: theme,
                ),
              ...availableAccents.map(
                (accent) => _AccentCard(
                  accent: accent,
                  displayName: _getAccentDisplayName(accent),
                  flagIcon: _getAccentIcon(accent),
                  isSelected: selectedAccent == accent,
                  onTap: () => onAccentChanged(accent),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getAccentDisplayName(String accent) {
    const accentMap = {
      'American': 'Mỹ',
      'British': 'Anh',
      'Australian': 'Úc',
      'Canadian': 'Canada',
      'Irish': 'Ireland',
      'Scottish': 'Scotland',
      'South African': 'Nam Phi',
      'Indian': 'Ấn Độ',
      'Nigerian': 'Nigeria',
      'Jamaican': 'Jamaica',
      'New Zealand': 'New Zealand',
      'Welsh': 'Wales',
      'Northern': 'Bắc Bộ',
      'Southern': 'Nam Bộ',
      'Central': 'Trung Bộ',
      'Saigon': 'Sài Gòn',
      'Hanoi': 'Hà Nội',
      'Hue': 'Huế',
    };
    
    return accentMap[accent] ?? accent;
  }

  IconData _getAccentIcon(String accent) {
    const iconMap = {
      'American': Icons.flag,
      'British': Icons.flag_outlined,
      'Australian': Icons.flag,
      'Canadian': Icons.flag,
      'Irish': Icons.flag,
      'Scottish': Icons.flag,
      'South African': Icons.flag,
      'Indian': Icons.flag,
      'Nigerian': Icons.flag,
      'Jamaican': Icons.flag,
      'New Zealand': Icons.flag,
      'Welsh': Icons.flag,
      'Northern': Icons.location_on,
      'Southern': Icons.location_on,
      'Central': Icons.location_on,
      'Saigon': Icons.location_city,
      'Hanoi': Icons.location_city,
      'Hue': Icons.location_city,
    };
    
    return iconMap[accent] ?? Icons.language;
  }
}

class _AccentCard extends StatelessWidget {
  final String? accent;
  final String displayName;
  final IconData flagIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _AccentCard({
    required this.accent,
    required this.displayName,
    required this.flagIcon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        constraints: const BoxConstraints(
          minWidth: 100,
          minHeight: 80,
        ),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
               : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              flagIcon,
              size: 24,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 8),
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact dropdown version
class CompactVoiceAccentSelector extends StatelessWidget {
  final List<String> availableAccents;
  final String? selectedAccent;
  final ValueChanged<String?> onAccentChanged;
  final bool allowNull;
  final String? hint;

  const CompactVoiceAccentSelector({
    super.key,
    required this.availableAccents,
    required this.selectedAccent,
    required this.onAccentChanged,
    this.allowNull = true,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.language,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Giọng địa phương',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: selectedAccent,
            hint: Text(hint ?? 'Chọn giọng địa phương'),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surface.withValues(alpha: 0.5),
            ),
            items: [
              if (allowNull)
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('Tất cả'),
                ),
              ...availableAccents.map(
                (accent) => DropdownMenuItem<String?>(
                  value: accent,
                  child: Row(
                    children: [
                      Icon(
                        _getAccentIcon(accent),
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Text(_getAccentDisplayName(accent)),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: onAccentChanged,
          ),
        ],
      ),
    );
  }

  String _getAccentDisplayName(String accent) {
    const accentMap = {
      'American': 'Mỹ',
      'British': 'Anh',
      'Australian': 'Úc',
      'Canadian': 'Canada',
      'Irish': 'Ireland',
      'Scottish': 'Scotland',
      'South African': 'Nam Phi',
      'Indian': 'Ấn Độ',
      'Nigerian': 'Nigeria',
      'Jamaican': 'Jamaica',
      'New Zealand': 'New Zealand',
      'Welsh': 'Wales',
      'Northern': 'Bắc Bộ',
      'Southern': 'Nam Bộ',
      'Central': 'Trung Bộ',
      'Saigon': 'Sài Gòn',
      'Hanoi': 'Hà Nội',
      'Hue': 'Huế',
    };
    
    return accentMap[accent] ?? accent;
  }

  IconData _getAccentIcon(String accent) {
    const iconMap = {
      'American': Icons.flag,
      'British': Icons.flag_outlined,
      'Australian': Icons.flag,
      'Canadian': Icons.flag,
      'Irish': Icons.flag,
      'Scottish': Icons.flag,
      'South African': Icons.flag,
      'Indian': Icons.flag,
      'Nigerian': Icons.flag,
      'Jamaican': Icons.flag,
      'New Zealand': Icons.flag,
      'Welsh': Icons.flag,
      'Northern': Icons.location_on,
      'Southern': Icons.location_on,
      'Central': Icons.location_on,
      'Saigon': Icons.location_city,
      'Hanoi': Icons.location_city,
      'Hue': Icons.location_city,
    };
    
    return iconMap[accent] ?? Icons.language;
  }
}

// Popular accents widget for quick selection
class PopularAccentsSelector extends StatelessWidget {
  final String? selectedAccent;
  final ValueChanged<String> onAccentSelected;
  final List<String>? customAccents;

  const PopularAccentsSelector({
    super.key,
    required this.selectedAccent,
    required this.onAccentSelected,
    this.customAccents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final popularAccents = customAccents ?? [
      'American',
      'British',
      'Australian',
      'Canadian',
      'Irish',
      'Scottish',
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Giọng phổ biến',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularAccents.map(
              (accent) => _PopularAccentChip(
                accent: accent,
                isSelected: selectedAccent == accent,
                onTap: () => onAccentSelected(accent),
                theme: theme,
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _PopularAccentChip extends StatelessWidget {
  final String accent;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PopularAccentChip({
    required this.accent,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withValues(alpha: 0.1)
              : colorScheme.surface.withValues(alpha: 0.5),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getAccentIcon(accent),
              size: 14,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              _getAccentDisplayName(accent),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getAccentDisplayName(String accent) {
    const accentMap = {
      'American': 'Mỹ',
      'British': 'Anh',
      'Australian': 'Úc',
      'Canadian': 'Canada',
      'Irish': 'Ireland',
      'Scottish': 'Scotland',
    };
    
    return accentMap[accent] ?? accent;
  }

  IconData _getAccentIcon(String accent) {
    const iconMap = {
      'American': Icons.flag,
      'British': Icons.flag_outlined,
      'Australian': Icons.flag,
      'Canadian': Icons.flag,
      'Irish': Icons.flag,
      'Scottish': Icons.flag,
    };
    
    return iconMap[accent] ?? Icons.language;
  }
}