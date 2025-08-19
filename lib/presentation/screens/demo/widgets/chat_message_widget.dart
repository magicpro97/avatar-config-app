import 'package:flutter/material.dart';
import '../../../../domain/entities/avatar_configuration.dart';
import '../../../../domain/entities/voice.dart';
import '../../../../presentation/widgets/avatar/avatar_display_widget.dart';
import '../../../../presentation/widgets/audio/voice_player_widget.dart';

/// Widget for displaying individual chat messages in the conversation
class ChatMessageWidget extends StatelessWidget {
  final String message;
  final bool isUserMessage;
  final DateTime timestamp;
  final AvatarConfiguration? avatarConfig;
  final VoiceConfiguration? voiceConfig;
  final String? audioId;
  final Function()? onPlayAudio;
  final Function()? onPauseAudio;
  final Function()? onStopAudio;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.isUserMessage,
    required this.timestamp,
    this.avatarConfig,
    this.voiceConfig,
    this.audioId,
    this.onPlayAudio,
    this.onPauseAudio,
    this.onStopAudio,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar or user icon
            if (!isUserMessage) ...[
              _buildAvatarPlaceholder(context),
              const SizedBox(width: 12),
            ] else
              const SizedBox(width: 48), // Space for avatar alignment
            // Message content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message bubble
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isUserMessage
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Message text
                        SelectableText(
                          message,
                          style: TextStyle(
                            color: isUserMessage
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),

                        // Voice player widget (for avatar messages)
                        if (!isUserMessage && audioId != null) ...[
                          const SizedBox(height: 8),
                          VoicePlayerWidget(
                            audioId: audioId!,
                            audioText: message,
                            height: 60,
                          ),
                        ],

                        // Voice configuration info (for avatar messages without audio)
                        if (!isUserMessage &&
                            voiceConfig != null &&
                            audioId == null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.record_voice_over,
                                size: 14,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${voiceConfig!.name} • ${voiceConfig!.gender.name}',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      _formatTimestamp(timestamp),
                      style: TextStyle(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // User avatar space (for user messages)
            if (isUserMessage) ...[
              const SizedBox(width: 12),
              _buildUserAvatarPlaceholder(context),
            ] else
              const SizedBox(width: 48), // Space for user avatar alignment
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(BuildContext context) {
    if (avatarConfig != null) {
      return AvatarDisplayWidget(
        avatarConfig: avatarConfig,
        size: 40,
        showAnimation: false,
      );
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person,
        size: 24,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildUserAvatarPlaceholder(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Icon(
        Icons.person_outline,
        size: 24,
        color: Theme.of(context).colorScheme.onSecondaryContainer,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'vài giây trước';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else {
      return '${difference.inDays} ngày trước';
    }
  }
}

/// Widget for displaying avatar configuration info
class AvatarInfoWidget extends StatelessWidget {
  final AvatarConfiguration avatarConfig;

  const AvatarInfoWidget({super.key, required this.avatarConfig});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          AvatarDisplayWidget(
            avatarConfig: avatarConfig,
            size: 48,
            showAnimation: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  avatarConfig.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${avatarConfig.personalityDisplayName} • ${avatarConfig.voiceName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
