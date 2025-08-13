import 'package:flutter/material.dart';

class VoiceParameterSlider extends StatelessWidget {
  final String label;
  final String? description;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String? unit;
  final ValueChanged<double> onChanged;
  final Color? activeColor;
  final IconData? icon;
  final bool showValue;
  final String Function(double)? valueFormatter;

  const VoiceParameterSlider({
    super.key,
    required this.label,
    this.description,
    required this.value,
    required this.min,
    required this.max,
    this.divisions = 10,
    this.unit,
    required this.onChanged,
    this.activeColor,
    this.icon,
    this.showValue = true,
    this.valueFormatter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with label and value
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: activeColor ?? colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                if (showValue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: activeColor?.withValues(alpha: 0.1) ?? 
                             colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _formatValue(value),
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: activeColor ?? colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (description != null) ...[
              const SizedBox(height: 4),
              Text(
                description!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
            
            const SizedBox(height: 8),
            
            // Slider
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: activeColor ?? colorScheme.primary,
                inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.3),
                thumbColor: activeColor ?? colorScheme.primary,
                overlayColor: (activeColor ?? colorScheme.primary).withValues(alpha: 0.1),
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 12,
                ),
                overlayShape: const RoundSliderOverlayShape(
                  overlayRadius: 20,
                ),
                trackHeight: 4,
                activeTickMarkColor: Colors.transparent,
                inactiveTickMarkColor: Colors.transparent,
              ),
              child: Slider(
                value: value.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: onChanged,
              ),
            ),
            
            // Min/Max labels
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatValue(min),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    _formatValue(max),
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
    );
  }

  String _formatValue(double value) {
    if (valueFormatter != null) {
      return valueFormatter!(value);
    }
    
    final formatted = value.toStringAsFixed(
      value == value.roundToDouble() ? 0 : 2,
    );
    return unit != null ? '$formatted$unit' : formatted;
  }
}

// Predefined voice parameter sliders for common use cases
class VoiceStabilitySlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoiceStabilitySlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VoiceParameterSlider(
      label: 'Độ ổn định (Stability)',
      description: 'Giá trị cao hơn làm giọng nói ổn định hơn nhưng có thể kém biểu cảm',
      value: value,
      min: 0.0,
      max: 1.0,
      divisions: 20,
      onChanged: onChanged,
      icon: Icons.balance,
      activeColor: Colors.blue,
      valueFormatter: (value) => '${(value * 100).round()}%',
    );
  }
}

class VoiceSimilarityBoostSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoiceSimilarityBoostSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VoiceParameterSlider(
      label: 'Tăng cường giống (Similarity Boost)',
      description: 'Tăng độ giống với giọng gốc, giá trị cao có thể gây tạp âm',
      value: value,
      min: 0.0,
      max: 1.0,
      divisions: 20,
      onChanged: onChanged,
      icon: Icons.tune,
      activeColor: Colors.green,
      valueFormatter: (value) => '${(value * 100).round()}%',
    );
  }
}

class VoiceStyleSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoiceStyleSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VoiceParameterSlider(
      label: 'Phong cách (Style)',
      description: 'Điều chỉnh phong cách và cảm xúc của giọng nói',
      value: value,
      min: 0.0,
      max: 1.0,
      divisions: 20,
      onChanged: onChanged,
      icon: Icons.style,
      activeColor: Colors.purple,
      valueFormatter: (value) => '${(value * 100).round()}%',
    );
  }
}

// Additional parameter sliders for extended voice control
class VoicePitchSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoicePitchSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VoiceParameterSlider(
      label: 'Cao độ (Pitch)',
      description: 'Điều chỉnh cao độ của giọng nói',
      value: value,
      min: 0.5,
      max: 2.0,
      divisions: 15,
      onChanged: onChanged,
      icon: Icons.graphic_eq,
      activeColor: Colors.orange,
      valueFormatter: (value) => '${value.toStringAsFixed(1)}x',
    );
  }
}

class VoiceSpeedSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoiceSpeedSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VoiceParameterSlider(
      label: 'Tốc độ (Speed)',
      description: 'Điều chỉnh tốc độ nói của giọng nói',
      value: value,
      min: 0.25,
      max: 4.0,
      divisions: 15,
      onChanged: onChanged,
      icon: Icons.speed,
      activeColor: Colors.red,
      valueFormatter: (value) => '${value.toStringAsFixed(2)}x',
    );
  }
}

class VoiceVolumeSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const VoiceVolumeSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return VoiceParameterSlider(
      label: 'Âm lượng (Volume)',
      description: 'Điều chỉnh âm lượng của giọng nói',
      value: value,
      min: 0.0,
      max: 1.0,
      divisions: 20,
      onChanged: onChanged,
      icon: Icons.volume_up,
      activeColor: Colors.teal,
      valueFormatter: (value) => '${(value * 100).round()}%',
    );
  }
}