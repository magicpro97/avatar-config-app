// Personality Card Widget
import 'package:flutter/material.dart';
import '../../domain/entities/personality.dart';
import '../theme/colors.dart';

class PersonalityCard extends StatelessWidget {
  final Personality personality;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showDescription;
  final double? width;
  final double? height;

  const PersonalityCard({
    super.key,
    required this.personality,
    this.isSelected = false,
    this.onTap,
    this.showDescription = true,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personalityColor = AppColors.getPersonalityColor(
      personality.type.name,
    );
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: Card(
        elevation: isSelected ? 8 : 2,
        shadowColor: isSelected
            ? personalityColor.withValues(alpha: 0.3)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isSelected
              ? BorderSide(color: personalityColor, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        personalityColor.withValues(alpha: 0.1),
                        personalityColor.withValues(alpha: 0.05),
                      ],
                    )
                  : null,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Personality Icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: personalityColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: personalityColor, width: 2)
                          : null,
                    ),
                    child: Icon(
                      _getPersonalityIcon(personality.type),
                      size: 28,
                      color: personalityColor,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Personality Name
                  Text(
                    personality.displayName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? personalityColor
                          : colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (showDescription) ...[
                    const SizedBox(height: 8),

                    // Personality Description
                    Text(
                      personality.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Selected indicator
                  if (isSelected) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: personalityColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check,
                            size: 14,
                            color: _getContrastColor(personalityColor),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Selected',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getContrastColor(personalityColor),
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPersonalityIcon(PersonalityType type) {
    switch (type) {
      case PersonalityType.happy:
        return Icons.sentiment_very_satisfied;
      case PersonalityType.romantic:
        return Icons.favorite;
      case PersonalityType.funny:
        return Icons.emoji_emotions;
      case PersonalityType.professional:
        return Icons.business_center;
      case PersonalityType.casual:
        return Icons.sentiment_satisfied;
      case PersonalityType.energetic:
        return Icons.bolt;
      case PersonalityType.calm:
        return Icons.spa;
      case PersonalityType.mysterious:
        return Icons.psychology;
    }
  }

  Color _getContrastColor(Color backgroundColor) {
    // Calculate luminance to determine if we should use dark or light text
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

// Compact version for grid layouts
class CompactPersonalityCard extends StatelessWidget {
  final Personality personality;
  final bool isSelected;
  final VoidCallback? onTap;

  const CompactPersonalityCard({
    super.key,
    required this.personality,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personalityColor = AppColors.getPersonalityColor(
      personality.type.name,
    );
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 6 : 2,
      margin: const EdgeInsets.all(4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? BorderSide(color: personalityColor, width: 2.5)
            : BorderSide(color: colorScheme.outline.withOpacity(0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      personalityColor.withOpacity(0.1),
                      personalityColor.withOpacity(0.05),
                    ],
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: personalityColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: personalityColor, width: 2.5)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: personalityColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    _getPersonalityIcon(personality.type),
                    size: 28,
                    color: personalityColor,
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  personality.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? personalityColor
                        : colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // Description (compact)
                Text(
                  personality.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? personalityColor
                        : colorScheme.outline.withOpacity(0.3),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPersonalityIcon(PersonalityType type) {
    switch (type) {
      case PersonalityType.happy:
        return Icons.sentiment_very_satisfied;
      case PersonalityType.romantic:
        return Icons.favorite;
      case PersonalityType.funny:
        return Icons.emoji_emotions;
      case PersonalityType.professional:
        return Icons.business_center;
      case PersonalityType.casual:
        return Icons.sentiment_satisfied;
      case PersonalityType.energetic:
        return Icons.bolt;
      case PersonalityType.calm:
        return Icons.spa;
      case PersonalityType.mysterious:
        return Icons.psychology;
    }
  }
}

// List item version for list layouts
class PersonalityListItem extends StatelessWidget {
  final Personality personality;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? trailing;

  const PersonalityListItem({
    super.key,
    required this.personality,
    this.isSelected = false,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final personalityColor = AppColors.getPersonalityColor(
      personality.type.name,
    );
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: isSelected ? 4 : 1,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: personalityColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? personalityColor.withValues(alpha: 0.08) : null,
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: personalityColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: personalityColor, width: 2)
                    : null,
              ),
              child: Icon(
                _getPersonalityIcon(personality.type),
                size: 24,
                color: personalityColor,
              ),
            ),
            title: Text(
              personality.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? personalityColor : colorScheme.onSurface,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  personality.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: personalityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPersonalityTypeLabel(personality.type),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: personalityColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing:
                trailing ??
                (isSelected
                    ? Icon(Icons.check_circle, color: personalityColor)
                    : Icon(
                        Icons.radio_button_unchecked,
                        color: colorScheme.outline,
                      )),
          ),
        ),
      ),
    );
  }

  IconData _getPersonalityIcon(PersonalityType type) {
    switch (type) {
      case PersonalityType.happy:
        return Icons.sentiment_very_satisfied;
      case PersonalityType.romantic:
        return Icons.favorite;
      case PersonalityType.funny:
        return Icons.emoji_emotions;
      case PersonalityType.professional:
        return Icons.business_center;
      case PersonalityType.casual:
        return Icons.sentiment_satisfied;
      case PersonalityType.energetic:
        return Icons.bolt;
      case PersonalityType.calm:
        return Icons.spa;
      case PersonalityType.mysterious:
        return Icons.psychology;
    }
  }

  String _getPersonalityTypeLabel(PersonalityType type) {
    switch (type) {
      case PersonalityType.happy:
        return 'Vui vẻ';
      case PersonalityType.romantic:
        return 'Lãng mạn';
      case PersonalityType.funny:
        return 'Hài hước';
      case PersonalityType.professional:
        return 'Chuyên nghiệp';
      case PersonalityType.casual:
        return 'Thân thiện';
      case PersonalityType.energetic:
        return 'Năng động';
      case PersonalityType.calm:
        return 'Bình tĩnh';
      case PersonalityType.mysterious:
        return 'Bí ẩn';
    }
  }
}
