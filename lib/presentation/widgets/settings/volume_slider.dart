import 'package:flutter/material.dart';

import 'setting_tile.dart';

/// A slider widget for controlling audio volume
class VolumeSlider extends StatelessWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;
  final String? title;
  final String? subtitle;

  const VolumeSlider({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
    this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SliderSettingTile(
      title: title ?? 'Âm lượng',
      subtitle: subtitle ?? 'Điều chỉnh âm lượng hiệu ứng âm thanh',
      leading: Icon(
        _getVolumeIcon(currentVolume),
        color: Theme.of(context).colorScheme.primary,
      ),
      value: currentVolume,
      min: 0.0,
      max: 1.0,
      divisions: 20,
      labelBuilder: (value) => '${(value * 100).round()}%',
      onChanged: onVolumeChanged,
    );
  }

  IconData _getVolumeIcon(double volume) {
    if (volume == 0) {
      return Icons.volume_off;
    } else if (volume < 0.3) {
      return Icons.volume_mute;
    } else if (volume < 0.7) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }
}

/// A compact volume control widget for quick access
class CompactVolumeControl extends StatefulWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;
  final bool enabled;

  const CompactVolumeControl({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
    this.enabled = true,
  });

  @override
  State<CompactVolumeControl> createState() => _CompactVolumeControlState();
}

class _CompactVolumeControlState extends State<CompactVolumeControl> {
  late double _currentVolume;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _currentVolume = widget.currentVolume;
  }

  @override
  void didUpdateWidget(CompactVolumeControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentVolume != widget.currentVolume) {
      _currentVolume = widget.currentVolume;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        InkWell(
          onTap: widget.enabled ? () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          } : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getVolumeIcon(_currentVolume),
                  color: widget.enabled
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(_currentVolume * 100).round()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: widget.enabled
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                Icon(
                  _isExpanded 
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 16,
                  color: widget.enabled
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: _isExpanded ? 60 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _isExpanded ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.volume_mute,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: _currentVolume,
                        min: 0.0,
                        max: 1.0,
                        divisions: 20,
                        onChanged: widget.enabled ? (value) {
                          setState(() {
                            _currentVolume = value;
                          });
                          widget.onVolumeChanged(value);
                        } : null,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.volume_up,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getVolumeIcon(double volume) {
    if (volume == 0) {
      return Icons.volume_off;
    } else if (volume < 0.3) {
      return Icons.volume_mute;
    } else if (volume < 0.7) {
      return Icons.volume_down;
    } else {
      return Icons.volume_up;
    }
  }
}

/// A volume control with preset buttons
class PresetVolumeControl extends StatelessWidget {
  final double currentVolume;
  final ValueChanged<double> onVolumeChanged;
  final bool enabled;

  const PresetVolumeControl({
    super.key,
    required this.currentVolume,
    required this.onVolumeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final presets = [
      const VolumePreset(label: 'Tắt', value: 0.0, icon: Icons.volume_off),
      const VolumePreset(label: 'Nhỏ', value: 0.3, icon: Icons.volume_mute),
      const VolumePreset(label: 'Vừa', value: 0.7, icon: Icons.volume_down),
      const VolumePreset(label: 'Lớn', value: 1.0, icon: Icons.volume_up),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mức âm lượng đặt sẵn',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: presets.map((preset) {
              final isSelected = (currentVolume - preset.value).abs() < 0.01;
              
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: enabled ? () => onVolumeChanged(preset.value) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected 
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline.withValues(alpha: 0.3),
                        ),
                        color: isSelected 
                            ? theme.colorScheme.primary.withValues(alpha: 0.1)
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            preset.icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (enabled
                                    ? theme.colorScheme.onSurface
                                    : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            preset.label,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : (enabled
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class VolumePreset {
  final String label;
  final double value;
  final IconData icon;

  const VolumePreset({
    required this.label,
    required this.value,
    required this.icon,
  });
}