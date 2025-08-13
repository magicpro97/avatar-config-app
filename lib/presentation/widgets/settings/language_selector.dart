import 'package:flutter/material.dart';

import 'setting_tile.dart';

/// A selector widget for choosing app language
class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;
  final String? title;
  final String? subtitle;
  final bool showOnlyVoiceLanguages;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    this.title,
    this.subtitle,
    this.showOnlyVoiceLanguages = false,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title ?? 'Ngôn ngữ',
      subtitle: subtitle ?? _getLanguageDescription(currentLanguage),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => _showLanguageSelector(context),
    );
  }

  String _getLanguageDescription(String languageCode) {
    final languages = _getAvailableLanguages();
    return languages[languageCode]?.name ?? 'Không xác định';
  }

  Map<String, LanguageInfo> _getAvailableLanguages() {
    if (showOnlyVoiceLanguages) {
      return {
        'vi': const LanguageInfo(
          name: 'Tiếng Việt',
          nativeName: 'Tiếng Việt',
          flag: '🇻🇳',
          description: 'Ngôn ngữ tiếng Việt cho tổng hợp giọng nói',
        ),
        'en': const LanguageInfo(
          name: 'English',
          nativeName: 'English',
          flag: '🇺🇸',
          description: 'English for voice synthesis',
        ),
        'zh': const LanguageInfo(
          name: 'Chinese',
          nativeName: '中文',
          flag: '🇨🇳',
          description: 'Chinese for voice synthesis',
        ),
        'ja': const LanguageInfo(
          name: 'Japanese',
          nativeName: '日本語',
          flag: '🇯🇵',
          description: 'Japanese for voice synthesis',
        ),
        'ko': const LanguageInfo(
          name: 'Korean',
          nativeName: '한국어',
          flag: '🇰🇷',
          description: 'Korean for voice synthesis',
        ),
      };
    }

    return {
      'vi': const LanguageInfo(
        name: 'Tiếng Việt',
        nativeName: 'Tiếng Việt',
        flag: '🇻🇳',
        description: 'Giao diện và nội dung bằng tiếng Việt',
      ),
      'en': const LanguageInfo(
        name: 'English',
        nativeName: 'English',
        flag: '🇺🇸',
        description: 'Interface and content in English',
      ),
    };
  }

  void _showLanguageSelector(BuildContext context) {
    final languages = _getAvailableLanguages();
    
    showModalBottomSheet<String>(
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
              showOnlyVoiceLanguages 
                  ? 'Chọn ngôn ngữ giọng nói'
                  : 'Chọn ngôn ngữ',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...languages.entries.map((entry) => _LanguageOption(
              code: entry.key,
              info: entry.value,
              isSelected: currentLanguage == entry.key,
              onTap: () {
                onLanguageChanged(entry.key);
                Navigator.of(context).pop();
              },
            )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class LanguageInfo {
  final String name;
  final String nativeName;
  final String flag;
  final String description;

  const LanguageInfo({
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.description,
  });
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final LanguageInfo info;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.info,
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
              child: Text(
                info.flag,
                style: const TextStyle(fontSize: 20),
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
                        info.name,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      if (info.name != info.nativeName) ...[
                        const SizedBox(width: 8),
                        Text(
                          '(${info.nativeName})',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    info.description,
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