import 'package:flutter/material.dart';

/// A customizable tile for individual settings
class SettingTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: contentPadding ?? const EdgeInsets.all(16),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: enabled
                            ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A specialized setting tile for switch controls
class SwitchSettingTile extends SettingTile {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SwitchSettingTile({
    super.key,
    required super.title,
    super.subtitle,
    super.leading,
    required this.value,
    required this.onChanged,
    super.enabled,
    super.contentPadding,
  }) : super(
          trailing: null,
          onTap: null,
        );

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      enabled: enabled && onChanged != null,
      contentPadding: contentPadding,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
      onTap: enabled && onChanged != null 
          ? () => onChanged!(!value)
          : null,
    );
  }
}

/// A specialized setting tile for slider controls
class SliderSettingTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String Function(double)? labelBuilder;
  final ValueChanged<double>? onChanged;
  final bool enabled;
  final EdgeInsetsGeometry? contentPadding;

  const SliderSettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    required this.value,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.labelBuilder,
    required this.onChanged,
    this.enabled = true,
    this.contentPadding,
  });

  @override
  State<SliderSettingTile> createState() => _SliderSettingTileState();
}

class _SliderSettingTileState extends State<SliderSettingTile> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(SliderSettingTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: widget.contentPadding ?? const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (widget.leading != null) ...[
                widget.leading!,
                const SizedBox(width: 16),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: widget.enabled
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: widget.enabled
                              ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                              : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (widget.labelBuilder != null)
                Text(
                  widget.labelBuilder!(_currentValue),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.enabled 
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: _currentValue,
              min: widget.min,
              max: widget.max,
              divisions: widget.divisions,
              onChanged: widget.enabled ? (value) {
                setState(() {
                  _currentValue = value;
                });
                widget.onChanged?.call(value);
              } : null,
            ),
          ),
        ],
      ),
    );
  }
}