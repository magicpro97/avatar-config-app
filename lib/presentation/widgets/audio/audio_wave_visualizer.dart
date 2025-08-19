// Audio Wave Visualization Widget for real-time audio waveform display
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/services/voice_recording_service.dart';
import '../../../data/services/speech_to_text_service.dart';

class AudioWaveVisualizer extends StatefulWidget {
  final VoiceRecordingService recordingService;
  final SpeechToTextService? speechService;
  final double? height;
  final Color? waveColor;
  final Color? activeWaveColor;
  final EdgeInsetsGeometry? margin;

  const AudioWaveVisualizer({
    super.key,
    required this.recordingService,
    this.speechService,
    this.height,
    this.waveColor,
    this.activeWaveColor,
    this.margin,
  });

  @override
  State<AudioWaveVisualizer> createState() => _AudioWaveVisualizerState();
}

class _AudioWaveVisualizerState extends State<AudioWaveVisualizer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _waveAnimation;
  bool _isInitialized = false;
  StreamSubscription<List<int>>? _audioStreamSubscription;
  
  // Wave data for visualization
  List<double> _waveData = List.filled(20, 0.0);
  final Random _random = Random();
  double _currentSoundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _setupAudioStreamListener();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _setupAudioStreamListener() {
    // Cancel previous subscription
    _audioStreamSubscription?.cancel();
    
    // Set up new subscription
    final audioStream = widget.recordingService.getAudioStream();
    if (audioStream != null) {
      _audioStreamSubscription = audioStream.listen(
        (data) {
          if (mounted) {
            setState(() {
              // Use real audio data for visualization
              _waveData = List.generate(20, (index) {
                final value = index < data.length
                    ? (data[index].toDouble() / 255.0).clamp(0.1, 0.9)
                    : 0.1;
                return value;
              });
            });
          }
        },
        onError: (error) {
          debugPrint('Audio stream error: $error');
          // Try to restart the stream listener on error
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) {
                _setupAudioStreamListener();
              }
            });
          }
        },
        onDone: () {
          debugPrint('Audio stream completed');
          // Restart the stream listener when it completes
          if (mounted) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                _setupAudioStreamListener();
              }
            });
          }
        },
      );
    } else {
      debugPrint('Audio stream is null - using simulated data');
      // Fallback to simulated data if stream is null
      _startSimulatedData();
    }
  }

  void _startSimulatedData() {
    if (!mounted) return;
    
    // Cancel any existing timer
    Timer? existingTimer;
    
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      existingTimer = timer;
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      // Continue if recording OR listening
      final currentRecordingState = widget.recordingService.state;
      final currentSpeechState = widget.speechService?.state;
      final isActive = currentRecordingState == RecordingState.recording ||
                      currentSpeechState == SpeechRecognitionState.listening;
      
      if (!isActive) {
        timer.cancel();
        return;
      }
      _updateWaveData();
    });
  }

  void _updateWaveData() {
    if (!mounted) return;
    
    setState(() {
      // Use real sound level if available, otherwise random data
      final baseLevel = _currentSoundLevel > 0 ? _currentSoundLevel : _random.nextDouble();
      
      // Generate wave data based on sound level
      _waveData = List.generate(20, (index) {
        final variation = (_random.nextDouble() - 0.5) * 0.3; // ±15% variation
        final level = (baseLevel + variation).clamp(0.1, 0.9);
        return level;
      });
    });
  }

  void _handleSpeechSoundLevel(double level) {
    _currentSoundLevel = level;
    // Update wave data immediately when sound level changes
    if (mounted && (widget.speechService?.isListening ?? false)) {
      _updateWaveData();
    }
  }

  @override
  void didUpdateWidget(AudioWaveVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recordingService != oldWidget.recordingService) {
      _setupAudioStreamListener();
    }
    // Handle height changes
    if (widget.height != oldWidget.height) {
      if (mounted) {
        setState(() {});
      }
    }
  }


  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _isInitialized = true;
      _handleRecordingStateChange(widget.recordingService.state);
      
      // Set up speech service listeners if available
      if (widget.speechService != null) {
        widget.speechService!.setStateListener(_handleSpeechStateChange);
        widget.speechService!.setSoundLevelListener(_handleSpeechSoundLevel);
        _handleSpeechStateChange(widget.speechService!.state);
      }
    }
  }

  void _handleRecordingStateChange(RecordingState state) {
    if (!_isInitialized) return;

    switch (state) {
      case RecordingState.recording:
        _animationController.repeat(reverse: true);
        // Ensure wave data is being updated
        _startSimulatedData();
        break;
      case RecordingState.paused:
      case RecordingState.idle:
      case RecordingState.processing:
      case RecordingState.completed:
      case RecordingState.error:
        // Only stop if speech service is also not listening
        final isSpeechListening = widget.speechService?.state == SpeechRecognitionState.listening;
        if (!isSpeechListening) {
          _animationController.stop();
          _animationController.reset();
        }
        break;
    }
  }

  void _handleSpeechStateChange(SpeechRecognitionState state) {
    if (!_isInitialized) return;

    switch (state) {
      case SpeechRecognitionState.listening:
        _animationController.repeat(reverse: true);
        // Ensure wave data is being updated
        _startSimulatedData();
        break;
      case SpeechRecognitionState.idle:
      case SpeechRecognitionState.processing:
      case SpeechRecognitionState.completed:
      case SpeechRecognitionState.error:
        // Only stop if recording service is also not recording
        final isRecording = widget.recordingService.state == RecordingState.recording;
        if (!isRecording) {
          _animationController.stop();
          _animationController.reset();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final waveColor = widget.waveColor ?? colorScheme.primary;
    final activeWaveColor = widget.activeWaveColor ?? colorScheme.secondary;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(vertical: 8),
      height: widget.height ?? 60,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  height: widget.height ?? 60,
                  width: constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0,
                  child: CustomPaint(
                    painter: _WavePainter(
                      waveData: _waveData,
                      animationValue: _waveAnimation.value,
                      waveColor: waveColor,
                      activeWaveColor: activeWaveColor,
                      isRecording: widget.recordingService.isRecording,
                      isListening: widget.speechService?.isListening ?? false,
                    ),
                    size: Size(constraints.maxWidth.isFinite ? constraints.maxWidth : 200.0, widget.height ?? 60),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioStreamSubscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }
}

// Custom painter for drawing the waveform
class _WavePainter extends CustomPainter {
  final List<double> waveData;
  final double animationValue;
  final Color waveColor;
  final Color activeWaveColor;
  final bool isRecording;
  final bool isListening;

  _WavePainter({
    required this.waveData,
    required this.animationValue,
    required this.waveColor,
    required this.activeWaveColor,
    required this.isRecording,
    required this.isListening,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveData.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final barWidth = size.width / waveData.length;
    final centerY = size.height / 2;
    // Limit bar height to prevent overflow
    final maxBarHeight = size.height * 0.7; // 70% of container height

    for (int i = 0; i < waveData.length; i++) {
      final barHeight = (waveData[i] * size.height * 0.8).clamp(0.0, maxBarHeight);
      final x = i * barWidth + barWidth * 0.1;
      final y = centerY - barHeight / 2;
      final width = barWidth * 0.8;
      final height = barHeight;

      // Create gradient effect
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          activeWaveColor.withValues(alpha: 0.8),
          waveColor.withValues(alpha: 0.6),
        ],
      );

      // Draw bar with rounded corners
      final rect = Rect.fromLTWH(x, y, width, height);
      final rrect = RRect.fromRectAndRadius(rect, Radius.circular(width * 0.3));
      
      paint.shader = gradient.createShader(rect);
      canvas.drawRRect(rrect, paint);
    }

    // Add glow effect when recording or listening
    if (isRecording || isListening) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = (isRecording ? activeWaveColor : waveColor).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
      final glowRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawRRect(
        RRect.fromRectAndRadius(glowRect, Radius.circular(size.height * 0.1)),
        glowPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) {
    return waveData != oldDelegate.waveData ||
           animationValue != oldDelegate.animationValue ||
           isRecording != oldDelegate.isRecording ||
           isListening != oldDelegate.isListening;
  }
}

// Simple random number generator
class Random {
  int _seed = DateTime.now().millisecond;
  
  double nextDouble() {
    _seed = (_seed * 9301 + 49297) % 233280;
    return _seed / 233280;
  }
}