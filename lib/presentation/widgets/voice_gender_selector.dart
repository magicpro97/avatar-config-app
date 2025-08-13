import 'package:flutter/material.dart';
import '../../domain/entities/voice.dart';

class VoiceGenderSelector extends StatelessWidget {
  final Gender? selectedGender;
  final ValueChanged<Gender?> onGenderChanged;
  final bool allowNull;
  final EdgeInsetsGeometry? padding;

  const VoiceGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.allowNull = true,
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
            'Giới tính (Gender)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn giới tính cho giọng nói của avatar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Gender selection chips
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (allowNull)
                _GenderChip(
                  label: 'Tất cả',
                  icon: Icons.person,
                  isSelected: selectedGender == null,
                  onTap: () => onGenderChanged(null),
                  theme: theme,
                ),
              _GenderChip(
                label: 'Nam',
                icon: Icons.male,
                isSelected: selectedGender == Gender.male,
                onTap: () => onGenderChanged(Gender.male),
                theme: theme,
                color: Colors.blue,
              ),
              _GenderChip(
                label: 'Nữ',
                icon: Icons.female,
                isSelected: selectedGender == Gender.female,
                onTap: () => onGenderChanged(Gender.female),
                theme: theme,
                color: Colors.pink,
              ),
              _GenderChip(
                label: 'Trung tính',
                icon: Icons.person_outline,
                isSelected: selectedGender == Gender.neutral,
                onTap: () => onGenderChanged(Gender.neutral),
                theme: theme,
                color: Colors.grey,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final Color? color;

  const _GenderChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.1)
              : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: Border.all(
            color: isSelected
                ? effectiveColor
                : colorScheme.outline.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? effectiveColor
                  : colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? effectiveColor
                    : colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact version for smaller spaces
class CompactVoiceGenderSelector extends StatelessWidget {
  final Gender? selectedGender;
  final ValueChanged<Gender?> onGenderChanged;
  final bool allowNull;

  const CompactVoiceGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
    this.allowNull = true,
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
                Icons.wc,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Giới tính',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (allowNull) ...[
                _CompactGenderButton(
                  icon: Icons.person,
                  isSelected: selectedGender == null,
                  onTap: () => onGenderChanged(null),
                  theme: theme,
                  tooltip: 'Tất cả',
                ),
                const SizedBox(width: 8),
              ],
              _CompactGenderButton(
                icon: Icons.male,
                isSelected: selectedGender == Gender.male,
                onTap: () => onGenderChanged(Gender.male),
                theme: theme,
                color: Colors.blue,
                tooltip: 'Nam',
              ),
              const SizedBox(width: 8),
              _CompactGenderButton(
                icon: Icons.female,
                isSelected: selectedGender == Gender.female,
                onTap: () => onGenderChanged(Gender.female),
                theme: theme,
                color: Colors.pink,
                tooltip: 'Nữ',
              ),
              const SizedBox(width: 8),
              _CompactGenderButton(
                icon: Icons.person_outline,
                isSelected: selectedGender == Gender.neutral,
                onTap: () => onGenderChanged(Gender.neutral),
                theme: theme,
                color: Colors.grey,
                tooltip: 'Trung tính',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactGenderButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;
  final Color? color;
  final String? tooltip;

  const _CompactGenderButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    this.color,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.primary;

    final button = GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected
              ? effectiveColor.withValues(alpha: 0.15)
              : colorScheme.surface,
          border: Border.all(
            color: isSelected
                ? effectiveColor
                : colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected
              ? effectiveColor
              : colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

// Gender statistics widget for showing voice distribution
class VoiceGenderStats extends StatelessWidget {
  final Map<Gender, int> genderCounts;
  final Gender? selectedGender;

  const VoiceGenderStats({
    super.key,
    required this.genderCounts,
    this.selectedGender,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalVoices = genderCounts.values.fold(0, (sum, count) => sum + count);

    if (totalVoices == 0) {
      return const SizedBox.shrink();
    }

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
            'Thống kê giọng nói',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatChip(
                icon: Icons.male,
                label: 'Nam',
                count: genderCounts[Gender.male] ?? 0,
                total: totalVoices,
                color: Colors.blue,
                isHighlighted: selectedGender == Gender.male,
                theme: theme,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.female,
                label: 'Nữ',
                count: genderCounts[Gender.female] ?? 0,
                total: totalVoices,
                color: Colors.pink,
                isHighlighted: selectedGender == Gender.female,
                theme: theme,
              ),
              const SizedBox(width: 8),
              _StatChip(
                icon: Icons.person_outline,
                label: 'Khác',
                count: genderCounts[Gender.neutral] ?? 0,
                total: totalVoices,
                color: Colors.grey,
                isHighlighted: selectedGender == Gender.neutral,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final int total;
  final Color color;
  final bool isHighlighted;
  final ThemeData theme;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.isHighlighted,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted
            ? color.withValues(alpha: 0.1)
            : colorScheme.surface.withValues(alpha: 0.5),
        border: isHighlighted
            ? Border.all(color: color, width: 1)
            : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            '$count ($percentage%)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}