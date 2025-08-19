// Avatar Display Widget with Personality-Based Visual Representations
import 'package:flutter/material.dart';
import '../../../domain/entities/avatar_configuration.dart';
import '../../../domain/entities/personality.dart';
import '../../../presentation/theme/colors.dart';

/// Widget for displaying avatars based on personality type
class AvatarDisplayWidget extends StatefulWidget {
  final AvatarConfiguration? avatarConfig;
  final double? size;
  final bool showAnimation;
  final VoidCallback? onTap;

  const AvatarDisplayWidget({
    super.key,
    this.avatarConfig,
    this.size,
    this.showAnimation = true,
    this.onTap,
  });

  @override
  State<AvatarDisplayWidget> createState() => _AvatarDisplayWidgetState();
}

class _AvatarDisplayWidgetState extends State<AvatarDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(AvatarDisplayWidget oldWidget) {
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
    final size = widget.size ?? 48.0;
    
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
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _getPersonalityColor(),
            borderRadius: BorderRadius.circular(size / 2),
            border: Border.all(
              color: _getPersonalityBorderColor(),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getPersonalityColor().withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _buildAvatarContent(size),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(double size) {
    if (widget.avatarConfig == null) {
      return Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.white,
      );
    }

    final personalityType = widget.avatarConfig!.personalityType;
    
    switch (personalityType) {
      case PersonalityType.happy:
        return _buildHappyAvatar(size);
      case PersonalityType.romantic:
        return _buildRomanticAvatar(size);
      case PersonalityType.funny:
        return _buildFunnyAvatar(size);
      case PersonalityType.professional:
        return _buildProfessionalAvatar(size);
      case PersonalityType.casual:
        return _buildCasualAvatar(size);
      case PersonalityType.energetic:
        return _buildEnergeticAvatar(size);
      case PersonalityType.calm:
        return _buildCalmAvatar(size);
      case PersonalityType.mysterious:
        return _buildMysteriousAvatar(size);
    }
  }

  Widget _buildHappyAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.sentiment_very_satisfied,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          bottom: size * 0.1,
          child: Icon(
            Icons.star,
            size: size * 0.15,
            color: Colors.yellow[200],
          ),
        ),
      ],
    );
  }

  Widget _buildRomanticAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.favorite,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          top: size * 0.1,
          child: Icon(
            Icons.auto_awesome,
            size: size * 0.12,
            color: Colors.pink[200],
          ),
        ),
      ],
    );
  }

  Widget _buildFunnyAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.theater_comedy,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          right: size * 0.05,
          top: size * 0.05,
          child: Icon(
            Icons.emoji_emotions,
            size: size * 0.15,
            color: Colors.orange[200],
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.business_center,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          bottom: size * 0.05,
          child: Icon(
            Icons.check_circle,
            size: size * 0.12,
            color: Colors.blue[200],
          ),
        ),
      ],
    );
  }

  Widget _buildCasualAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.person_outline,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          bottom: size * 0.05,
          child: Icon(
            Icons.thumb_up,
            size: size * 0.12,
            color: Colors.green[200],
          ),
        ),
      ],
    );
  }

  Widget _buildEnergeticAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.flash_on,
          size: size * 0.6,
          color: Colors.white,
        ),
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
      ],
    );
  }

  Widget _buildCalmAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.self_improvement,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          top: size * 0.05,
          child: Icon(
            Icons.water_drop,
            size: size * 0.12,
            color: Colors.cyan[200],
          ),
        ),
      ],
    );
  }

  Widget _buildMysteriousAvatar(double size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.visibility_off,
          size: size * 0.6,
          color: Colors.white,
        ),
        Positioned(
          top: size * 0.05,
          child: Icon(
            Icons.nightlight_round,
            size: size * 0.12,
            color: Colors.purple[200],
          ),
        ),
      ],
    );
  }

  Color _getPersonalityColor() {
    if (widget.avatarConfig == null) {
      return AppColors.primaryBlue;
    }
    
    return AppColors.getPersonalityColor(widget.avatarConfig!.personalityType.name);
  }

  Color _getPersonalityBorderColor() {
    if (widget.avatarConfig == null) {
      return AppColors.primaryBlueDark;
    }
    
    final color = AppColors.getPersonalityColor(widget.avatarConfig!.personalityType.name);
    return color.withValues(alpha: 0.8);
  }
}

/// Widget for displaying large avatar with personality details
class LargeAvatarDisplayWidget extends StatelessWidget {
  final AvatarConfiguration? avatarConfig;
  final VoidCallback? onTap;

  const LargeAvatarDisplayWidget({
    super.key,
    this.avatarConfig,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AvatarDisplayWidget(
            avatarConfig: avatarConfig,
            size: 80,
            showAnimation: false,
          ),
          const SizedBox(height: 8),
          if (avatarConfig != null)
            Text(
              avatarConfig!.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (avatarConfig != null)
            Text(
              avatarConfig!.personalityDisplayName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget for displaying avatar with animation effects
class AnimatedAvatarDisplayWidget extends StatefulWidget {
  final AvatarConfiguration? avatarConfig;
  final double? size;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedAvatarDisplayWidget({
    super.key,
    this.avatarConfig,
    this.size,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.elasticOut,
  });

  @override
  State<AnimatedAvatarDisplayWidget> createState() => _AnimatedAvatarDisplayWidgetState();
}

class _AnimatedAvatarDisplayWidgetState extends State<AnimatedAvatarDisplayWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.animationCurve,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: ScaleTransition(
        scale: _animation,
        child: AvatarDisplayWidget(
          avatarConfig: widget.avatarConfig,
          size: widget.size,
          showAnimation: false,
        ),
      ),
    );
  }
}