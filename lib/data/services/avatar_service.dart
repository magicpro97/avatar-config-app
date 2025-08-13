// Avatar Service for Managing Avatar Rendering Logic
import 'package:flutter/material.dart';
import '../../domain/entities/avatar_configuration.dart';
import '../../domain/entities/personality.dart';
import '../../presentation/theme/colors.dart';

/// Service for managing avatar rendering logic and state
class AvatarService {
  static final AvatarService _instance = AvatarService._internal();
  factory AvatarService() => _instance;
  AvatarService._internal();

  // Cache for avatar assets
  final Map<String, Widget> _avatarCache = {};
  final Map<String, Color> _personalityColorCache = {};

  /// Get avatar widget based on personality type
  Widget getAvatarWidget({
    required AvatarConfiguration avatarConfig,
    double size = 48.0,
    bool showAnimation = true,
    VoidCallback? onTap,
  }) {
    final cacheKey = '${avatarConfig.personalityType.name}_${size.toInt()}_$showAnimation';
    
    if (_avatarCache.containsKey(cacheKey)) {
      return _avatarCache[cacheKey]!;
    }

    final widget = _buildAvatarWidget(
      avatarConfig: avatarConfig,
      size: size,
      showAnimation: showAnimation,
      onTap: onTap,
    );

    _avatarCache[cacheKey] = widget;
    return widget;
  }

  /// Build avatar widget with personality-specific styling
  Widget _buildAvatarWidget({
    required AvatarConfiguration avatarConfig,
    required double size,
    required bool showAnimation,
    VoidCallback? onTap,
  }) {
    return _PersonalityAvatar(
      avatarConfig: avatarConfig,
      size: size,
      showAnimation: showAnimation,
      onTap: onTap,
    );
  }

  /// Get personality-specific color
  Color getPersonalityColor(PersonalityType personalityType) {
    if (_personalityColorCache.containsKey(personalityType.name)) {
      return _personalityColorCache[personalityType.name]!;
    }

    final color = _getPersonalityColorByType(personalityType);
    _personalityColorCache[personalityType.name] = color;
    return color;
  }

  /// Get personality-specific border color
  Color getPersonalityBorderColor(PersonalityType personalityType) {
    final color = getPersonalityColor(personalityType);
    return color.withOpacity(0.8);
  }

  /// Get personality-specific icon
  IconData getPersonalityIcon(PersonalityType personalityType) {
    switch (personalityType) {
      case PersonalityType.happy:
        return Icons.sentiment_very_satisfied;
      case PersonalityType.romantic:
        return Icons.favorite;
      case PersonalityType.funny:
        return Icons.theater_comedy;
      case PersonalityType.professional:
        return Icons.business_center;
      case PersonalityType.casual:
        return Icons.person_outline;
      case PersonalityType.energetic:
        return Icons.flash_on;
      case PersonalityType.calm:
        return Icons.self_improvement;
      case PersonalityType.mysterious:
        return Icons.visibility_off;
    }
  }

  /// Get personality-specific decorations
  List<Widget> getPersonalityDecorations(PersonalityType personalityType, double size) {
    switch (personalityType) {
      case PersonalityType.happy:
        return [
          Positioned(
            bottom: size * 0.1,
            child: Icon(
              Icons.star,
              size: size * 0.15,
              color: Colors.yellow[200],
            ),
          ),
        ];
      case PersonalityType.romantic:
        return [
          Positioned(
            top: size * 0.1,
            child: Icon(
              Icons.auto_awesome,
              size: size * 0.12,
              color: Colors.pink[200],
            ),
          ),
        ];
      case PersonalityType.funny:
        return [
          Positioned(
            right: size * 0.05,
            top: size * 0.05,
            child: Icon(
              Icons.emoji_emotions,
              size: size * 0.15,
              color: Colors.orange[200],
            ),
          ),
        ];
      case PersonalityType.professional:
        return [
          Positioned(
            bottom: size * 0.05,
            child: Icon(
              Icons.check_circle,
              size: size * 0.12,
              color: Colors.blue[200],
            ),
          ),
        ];
      case PersonalityType.casual:
        return [
          Positioned(
            bottom: size * 0.05,
            child: Icon(
              Icons.thumb_up,
              size: size * 0.12,
              color: Colors.green[200],
            ),
          ),
        ];
      case PersonalityType.energetic:
        return [
          Positioned(
            top: size * 0.05,
            left: size * 0.05,
            child: Icon(
              Icons.bolt,
              size: size * 0.12,
              color: Colors.red[200],
            ),
          ),
          Positioned(
            bottom: size * 0.05,
            right: size * 0.05,
            child: Icon(
              Icons.bolt,
              size: size * 0.12,
              color: Colors.red[200],
            ),
          ),
        ];
      case PersonalityType.calm:
        return [
          Positioned(
            top: size * 0.05,
            child: Icon(
              Icons.water_drop,
              size: size * 0.12,
              color: Colors.cyan[200],
            ),
          ),
        ];
      case PersonalityType.mysterious:
        return [
          Positioned(
            top: size * 0.05,
            child: Icon(
              Icons.nightlight_round,
              size: size * 0.12,
              color: Colors.purple[200],
            ),
          ),
        ];
    }
  }

  /// Get personality-specific animation properties
  Duration getPersonalityAnimationDuration(PersonalityType personalityType) {
    switch (personalityType) {
      case PersonalityType.energetic:
        return const Duration(milliseconds: 200);
      case PersonalityType.calm:
        return const Duration(milliseconds: 800);
      case PersonalityType.mysterious:
        return const Duration(milliseconds: 600);
      default:
        return const Duration(milliseconds: 400);
    }
  }

  /// Get personality-specific animation curve
  Curve getPersonalityAnimationCurve(PersonalityType personalityType) {
    switch (personalityType) {
      case PersonalityType.happy:
        return Curves.elasticOut;
      case PersonalityType.energetic:
        return Curves.bounceOut;
      case PersonalityType.calm:
        return Curves.easeInOut;
      case PersonalityType.mysterious:
        return Curves.easeInOutBack;
      default:
        return Curves.easeOut;
    }
  }

  /// Clear avatar cache
  void clearCache() {
    _avatarCache.clear();
    _personalityColorCache.clear();
  }

  /// Get personality color by type
  Color _getPersonalityColorByType(PersonalityType personalityType) {
    switch (personalityType) {
      case PersonalityType.happy:
        return AppColors.happyColor;
      case PersonalityType.romantic:
        return AppColors.romanticColor;
      case PersonalityType.funny:
        return AppColors.funnyColor;
      case PersonalityType.professional:
        return AppColors.professionalColor;
      case PersonalityType.casual:
        return AppColors.casualColor;
      case PersonalityType.energetic:
        return AppColors.energeticColor;
      case PersonalityType.calm:
        return AppColors.calmColor;
      case PersonalityType.mysterious:
        return AppColors.mysteriousColor;
    }
  }

  /// Get avatar size based on context
  double getAvatarSize(BuildContext context, {double? customSize}) {
    if (customSize != null) return customSize;
    
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) {
      return 40.0;
    } else if (screenWidth < 600) {
      return 48.0;
    } else {
      return 56.0;
    }
  }

  /// Get avatar shadow based on personality
  List<BoxShadow> getPersonalityShadow(PersonalityType personalityType) {
    final color = getPersonalityColor(personalityType);
    return [
      BoxShadow(
        color: color.withValues(alpha: 0.3),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }
}

/// Internal widget for rendering personality-specific avatars
class _PersonalityAvatar extends StatefulWidget {
  final AvatarConfiguration avatarConfig;
  final double size;
  final bool showAnimation;
  final VoidCallback? onTap;

  const _PersonalityAvatar({
    required this.avatarConfig,
    required this.size,
    required this.showAnimation,
    this.onTap,
  });

  @override
  State<_PersonalityAvatar> createState() => _PersonalityAvatarState();
}

class _PersonalityAvatarState extends State<_PersonalityAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AvatarService().getPersonalityAnimationDuration(widget.avatarConfig.personalityType),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AvatarService().getPersonalityAnimationCurve(widget.avatarConfig.personalityType),
    ));

    if (widget.showAnimation) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(_PersonalityAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showAnimation && oldWidget.showAnimation != widget.showAnimation) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap ?? () => _startAnimation(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: AvatarService().getPersonalityColor(widget.avatarConfig.personalityType),
            borderRadius: BorderRadius.circular(widget.size / 2),
            border: Border.all(
              color: AvatarService().getPersonalityBorderColor(widget.avatarConfig.personalityType),
              width: 2,
            ),
            boxShadow: AvatarService().getPersonalityShadow(widget.avatarConfig.personalityType),
          ),
          child: _buildAvatarContent(),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    final size = widget.size;
    final personalityType = widget.avatarConfig.personalityType;
    final icon = AvatarService().getPersonalityIcon(personalityType);
    final decorations = AvatarService().getPersonalityDecorations(personalityType, size);

    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          icon,
          size: size * 0.6,
          color: Colors.white,
        ),
        ...decorations,
      ],
    );
  }
}