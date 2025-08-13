import 'package:flutter/material.dart';

class VoiceLanguageSelector extends StatelessWidget {
  final List<String> availableLanguages;
  final String? selectedLanguage;
  final ValueChanged<String?> onLanguageChanged;
  final bool allowNull;
  final String? title;
  final EdgeInsetsGeometry? padding;

  const VoiceLanguageSelector({
    super.key,
    required this.availableLanguages,
    required this.selectedLanguage,
    required this.onLanguageChanged,
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
            title ?? 'Ngôn ngữ (Language)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn ngôn ngữ cho giọng nói của avatar',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          
          // Language selection grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              if (allowNull)
                _LanguageCard(
                  language: null,
                  displayName: 'Tất cả',
                  nativeName: 'All Languages',
                  flagIcon: Icons.translate,
                  isSelected: selectedLanguage == null,
                  onTap: () => onLanguageChanged(null),
                  theme: theme,
                ),
              ...availableLanguages.map(
                (language) => _LanguageCard(
                  language: language,
                  displayName: _getLanguageDisplayName(language),
                  nativeName: _getLanguageNativeName(language),
                  flagIcon: _getLanguageIcon(language),
                  isSelected: selectedLanguage == language,
                  onTap: () => onLanguageChanged(language),
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String language) {
    const languageMap = {
      'English': 'Tiếng Anh',
      'Vietnamese': 'Tiếng Việt',
      'Spanish': 'Tiếng Tây Ban Nha',
      'French': 'Tiếng Pháp',
      'German': 'Tiếng Đức',
      'Italian': 'Tiếng Ý',
      'Portuguese': 'Tiếng Bồ Đào Nha',
      'Russian': 'Tiếng Nga',
      'Japanese': 'Tiếng Nhật',
      'Korean': 'Tiếng Hàn',
      'Chinese': 'Tiếng Trung',
      'Mandarin': 'Tiếng Trung Quan Thoại',
      'Cantonese': 'Tiếng Quảng Đông',
      'Hindi': 'Tiếng Hindi',
      'Arabic': 'Tiếng Ả Rập',
      'Dutch': 'Tiếng Hà Lan',
      'Polish': 'Tiếng Ba Lan',
      'Turkish': 'Tiếng Thổ Nhĩ Kỳ',
      'Swedish': 'Tiếng Thụy Điển',
      'Norwegian': 'Tiếng Na Uy',
      'Danish': 'Tiếng Đan Mạch',
      'Finnish': 'Tiếng Phần Lan',
      'Greek': 'Tiếng Hy Lạp',
      'Hebrew': 'Tiếng Do Thái',
      'Thai': 'Tiếng Thái',
      'Indonesian': 'Tiếng Indonesia',
      'Malay': 'Tiếng Malaysia',
      'Tagalog': 'Tiếng Philippines',
    };
    
    return languageMap[language] ?? language;
  }

  String _getLanguageNativeName(String language) {
    const nativeNameMap = {
      'English': 'English',
      'Vietnamese': 'Tiếng Việt',
      'Spanish': 'Español',
      'French': 'Français',
      'German': 'Deutsch',
      'Italian': 'Italiano',
      'Portuguese': 'Português',
      'Russian': 'Русский',
      'Japanese': '日本語',
      'Korean': '한국어',
      'Chinese': '中文',
      'Mandarin': '普通话',
      'Cantonese': '廣東話',
      'Hindi': 'हिन्दी',
      'Arabic': 'العربية',
      'Dutch': 'Nederlands',
      'Polish': 'Polski',
      'Turkish': 'Türkçe',
      'Swedish': 'Svenska',
      'Norwegian': 'Norsk',
      'Danish': 'Dansk',
      'Finnish': 'Suomi',
      'Greek': 'Ελληνικά',
      'Hebrew': 'עברית',
      'Thai': 'ไทย',
      'Indonesian': 'Bahasa Indonesia',
      'Malay': 'Bahasa Melayu',
      'Tagalog': 'Tagalog',
    };
    
    return nativeNameMap[language] ?? language;
  }

  IconData _getLanguageIcon(String language) {
    const iconMap = {
      'English': Icons.language,
      'Vietnamese': Icons.location_on,
      'Spanish': Icons.language,
      'French': Icons.language,
      'German': Icons.language,
      'Italian': Icons.language,
      'Portuguese': Icons.language,
      'Russian': Icons.language,
      'Japanese': Icons.language,
      'Korean': Icons.language,
      'Chinese': Icons.language,
      'Mandarin': Icons.language,
      'Cantonese': Icons.language,
      'Hindi': Icons.language,
      'Arabic': Icons.language,
      'Dutch': Icons.language,
      'Polish': Icons.language,
      'Turkish': Icons.language,
      'Swedish': Icons.language,
      'Norwegian': Icons.language,
      'Danish': Icons.language,
      'Finnish': Icons.language,
      'Greek': Icons.language,
      'Hebrew': Icons.language,
      'Thai': Icons.language,
      'Indonesian': Icons.language,
      'Malay': Icons.language,
      'Tagalog': Icons.language,
    };
    
    return iconMap[language] ?? Icons.translate;
  }
}

class _LanguageCard extends StatelessWidget {
  final String? language;
  final String displayName;
  final String nativeName;
  final IconData flagIcon;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _LanguageCard({
    required this.language,
    required this.displayName,
    required this.nativeName,
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
          minWidth: 120,
          minHeight: 90,
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
            const SizedBox(height: 2),
            Text(
              nativeName,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary.withValues(alpha: 0.7)
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact dropdown version
class CompactVoiceLanguageSelector extends StatelessWidget {
  final List<String> availableLanguages;
  final String? selectedLanguage;
  final ValueChanged<String?> onLanguageChanged;
  final bool allowNull;
  final String? hint;

  const CompactVoiceLanguageSelector({
    super.key,
    required this.availableLanguages,
    required this.selectedLanguage,
    required this.onLanguageChanged,
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
                Icons.translate,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 8),
              Text(
                'Ngôn ngữ',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: selectedLanguage,
            hint: Text(hint ?? 'Chọn ngôn ngữ'),
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
              ...availableLanguages.map(
                (language) => DropdownMenuItem<String?>(
                  value: language,
                  child: Row(
                    children: [
                      Icon(
                        _getLanguageIcon(language),
                        size: 16,
                        color: colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getLanguageDisplayName(language),
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              _getLanguageNativeName(language),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: onLanguageChanged,
            isExpanded: true,
          ),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(String language) {
    const languageMap = {
      'English': 'Tiếng Anh',
      'Vietnamese': 'Tiếng Việt',
      'Spanish': 'Tiếng Tây Ban Nha',
      'French': 'Tiếng Pháp',
      'German': 'Tiếng Đức',
      'Italian': 'Tiếng Ý',
      'Portuguese': 'Tiếng Bồ Đào Nha',
      'Russian': 'Tiếng Nga',
      'Japanese': 'Tiếng Nhật',
      'Korean': 'Tiếng Hàn',
      'Chinese': 'Tiếng Trung',
    };
    
    return languageMap[language] ?? language;
  }

  String _getLanguageNativeName(String language) {
    const nativeNameMap = {
      'English': 'English',
      'Vietnamese': 'Tiếng Việt',
      'Spanish': 'Español',
      'French': 'Français',
      'German': 'Deutsch',
      'Italian': 'Italiano',
      'Portuguese': 'Português',
      'Russian': 'Русский',
      'Japanese': '日本語',
      'Korean': '한국어',
      'Chinese': '中文',
    };
    
    return nativeNameMap[language] ?? language;
  }

  IconData _getLanguageIcon(String language) {
    return Icons.language;
  }
}

// Popular languages widget for quick selection
class PopularLanguagesSelector extends StatelessWidget {
  final String? selectedLanguage;
  final ValueChanged<String> onLanguageSelected;
  final List<String>? customLanguages;

  const PopularLanguagesSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
    this.customLanguages,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final popularLanguages = customLanguages ?? [
      'English',
      'Vietnamese',
      'Spanish',
      'French',
      'German',
      'Japanese',
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
            'Ngôn ngữ phổ biến',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularLanguages.map(
              (language) => _PopularLanguageChip(
                language: language,
                isSelected: selectedLanguage == language,
                onTap: () => onLanguageSelected(language),
                theme: theme,
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _PopularLanguageChip extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _PopularLanguageChip({
    required this.language,
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
              Icons.language,
              size: 14,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              _getLanguageDisplayName(language),
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

  String _getLanguageDisplayName(String language) {
    const languageMap = {
      'English': 'Tiếng Anh',
      'Vietnamese': 'Tiếng Việt',
      'Spanish': 'Tây Ban Nha',
      'French': 'Pháp',
      'German': 'Đức',
      'Japanese': 'Nhật',
    };
    
    return languageMap[language] ?? language;
  }
}

// Language statistics widget
class VoiceLanguageStats extends StatelessWidget {
  final Map<String, int> languageCounts;
  final String? selectedLanguage;

  const VoiceLanguageStats({
    super.key,
    required this.languageCounts,
    this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final totalVoices = languageCounts.values.fold(0, (sum, count) => sum + count);

    if (totalVoices == 0) {
      return const SizedBox.shrink();
    }

    final sortedLanguages = languageCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

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
            'Thống kê ngôn ngữ',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sortedLanguages.take(6).map(
              (entry) => _LanguageStatChip(
                language: entry.key,
                count: entry.value,
                total: totalVoices,
                isHighlighted: selectedLanguage == entry.key,
                theme: theme,
              ),
            ).toList(),
          ),
        ],
      ),
    );
  }
}

class _LanguageStatChip extends StatelessWidget {
  final String language;
  final int count;
  final int total;
  final bool isHighlighted;
  final ThemeData theme;

  const _LanguageStatChip({
    required this.language,
    required this.count,
    required this.total,
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
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surface.withValues(alpha: 0.5),
        border: isHighlighted
            ? Border.all(color: colorScheme.primary, width: 1)
            : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.language,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(
            '${_getShortLanguageName(language)} $count ($percentage%)',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  String _getShortLanguageName(String language) {
    const shortNames = {
      'English': 'EN',
      'Vietnamese': 'VI',
      'Spanish': 'ES',
      'French': 'FR',
      'German': 'DE',
      'Japanese': 'JA',
      'Korean': 'KO',
      'Chinese': 'ZH',
    };
    
    return shortNames[language] ?? language.substring(0, 2).toUpperCase();
  }
}