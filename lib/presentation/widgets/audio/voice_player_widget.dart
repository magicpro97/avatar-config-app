// Voice Player Widget for audio playback controls
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/audio_service.dart';
import '../../providers/voice_provider.dart';

class VoicePlayerWidget extends StatefulWidget {
  final String audioId;
  final String? audioText;
  final Function(AudioState)? onStateChanged;
  final Function(Duration)? onPositionChanged;
  final Function(Duration)? onDurationChanged;
  final Function(String)? onError;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool showText;
  final TextStyle? textStyle;

  const VoicePlayerWidget({
    super.key,
    required this.audioId,
    this.audioText,
    this.onStateChanged,
    this.onPositionChanged,
    this.onDurationChanged,
    this.onError,
    this.height,
    this.padding,
    this.showText = true,
    this.textStyle,
  });

  @override
  State<VoicePlayerWidget> createState() => _VoicePlayerWidgetState();
}

class _VoicePlayerWidgetState extends State<VoicePlayerWidget> 
    with SingleTickerProviderStateMixin {
  late AudioService _audioService;
  late String _audioId;
  AudioState _audioState = AudioState.idle;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;
  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _audioId = widget.audioId;
    _initializeAudioService();
  }

  @override
  void didUpdateWidget(VoicePlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audioId != widget.audioId) {
      _audioId = widget.audioId;
      _reinitializeListeners();
    }
  }

  Future<void> _initializeAudioService() async {
    try {
      // Get the voice provider which contains the audio service
      final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
      
      // Access the audio service through the voice provider
      // We need to add a getter for the audio service in VoiceProvider
      _audioService = voiceProvider.audioService;
      
      // Set up listeners
      _audioService.addStateListener(_audioId, _handleStateChange);
      _audioService.addPositionListener(_audioId, _handlePositionChange);
      _audioService.addDurationListener(_audioId, _handleDurationChange);
      _audioService.addErrorListener(_audioId, _handleError);
      
      _isInitialized = true;
      _updateState();
    } catch (e) {
      _handleError('Failed to initialize audio service: $e');
    }
  }

  void _reinitializeListeners() {
    if (_isInitialized) {
      _audioService.removeStateListener(_audioId);
      _audioService.removePositionListener(_audioId);
      _audioService.removeDurationListener(_audioId);
      _audioService.removeErrorListener(_audioId);
      
      _audioService.addStateListener(_audioId, _handleStateChange);
      _audioService.addPositionListener(_audioId, _handlePositionChange);
      _audioService.addDurationListener(_audioId, _handleDurationChange);
      _audioService.addErrorListener(_audioId, _handleError);
      
      _updateState();
    }
  }

  void _handleStateChange(AudioState state) {
    setState(() {
      _audioState = state;
      _errorMessage = null;
    });
    widget.onStateChanged?.call(state);
  }

  void _handlePositionChange(Duration position) {
    setState(() {
      _audioPosition = position;
    });
    widget.onPositionChanged?.call(position);
  }

  void _handleDurationChange(Duration duration) {
    setState(() {
      _audioDuration = duration;
    });
    widget.onDurationChanged?.call(duration);
  }

  void _handleError(String error) {
    setState(() {
      _errorMessage = error;
      _audioState = AudioState.error;
    });
    widget.onError?.call(error);
  }

  void _updateState() {
    if (_isInitialized) {
      _handleStateChange(_audioService.getAudioState(_audioId));
      _handlePositionChange(_audioService.getAudioPosition(_audioId));
      _handleDurationChange(_audioService.getAudioDuration(_audioId));
    }
  }

  Future<void> _handlePlayPause() async {
    try {
      switch (_audioState) {
        case AudioState.playing:
          await _audioService.pauseAudio(_audioId);
          break;
        case AudioState.paused:
        case AudioState.idle:
        case AudioState.completed:
          await _audioService.resumeAudio(_audioId);
          break;
        case AudioState.loading:
        case AudioState.error:
          // Don't allow play/pause during loading or error states
          break;
      }
    } catch (e) {
      _handleError('Failed to toggle playback: $e');
    }
  }

  Future<void> _handleStop() async {
    try {
      await _audioService.stopAudio(_audioId);
    } catch (e) {
      _handleError('Failed to stop audio: $e');
    }
  }

  Future<void> _handleSeek(double progress) async {
    try {
      final duration = _audioDuration;
      if (duration.inMilliseconds > 0) {
        final position = Duration(
          milliseconds: (duration.inMilliseconds * progress).round(),
        );
        await _audioService.seekAudio(_audioId, position);
      }
    } catch (e) {
      _handleError('Failed to seek audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getPlayPauseIcon() {
    switch (_audioState) {
      case AudioState.playing:
        return Icons.pause;
      case AudioState.paused:
      case AudioState.idle:
      case AudioState.completed:
        return Icons.play_arrow;
      case AudioState.loading:
      case AudioState.error:
        return Icons.play_arrow;
    }
  }

  Color _getPlayPauseColor() {
    switch (_audioState) {
      case AudioState.playing:
        return Colors.white;
      case AudioState.paused:
      case AudioState.idle:
      case AudioState.completed:
        return Theme.of(context).colorScheme.onPrimary;
      case AudioState.loading:
      case AudioState.error:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      constraints: BoxConstraints(
        minHeight: widget.height ?? 80,
        maxHeight: widget.height != null ? widget.height! + 40 : 120, // Allow some flexibility
      ),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Audio text (if provided)
            if (widget.showText && widget.audioText != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.audioText!,
                  style: widget.textStyle ?? theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            
            // Progress bar
            if (_audioState != AudioState.idle && _audioState != AudioState.loading)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress track
                    GestureDetector(
                      onTap: () {
                        final box = context.findRenderObject() as RenderBox?;
                        final offset = box?.globalToLocal(Offset.zero);
                        if (offset != null) {
                          final position = box?.localToGlobal(Offset.zero);
                          if (position != null) {
                            final tapPosition = box?.globalToLocal(position);
                            if (tapPosition != null) {
                              final progress = tapPosition.dx / box!.size.width;
                              _handleSeek(progress.clamp(0.0, 1.0));
                            }
                          }
                        }
                      },
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: colorScheme.outline.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: _audioDuration.inMilliseconds > 0 
                              ? _audioPosition.inMilliseconds / _audioDuration.inMilliseconds
                              : 0.0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    // Time indicators
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_audioPosition),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                          Text(
                            _formatDuration(_audioDuration),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Control buttons
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop button
                  if (_audioState == AudioState.playing || _audioState == AudioState.paused)
                    IconButton(
                      icon: const Icon(Icons.stop, size: 18),
                      onPressed: _handleStop,
                      tooltip: 'Dừng',
                      color: colorScheme.onSurfaceVariant,
                      style: IconButton.styleFrom(
                        minimumSize: const Size(28, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  
                  const SizedBox(width: 8),
                  
                  // Play/Pause button
                  IconButton(
                    icon: Icon(_getPlayPauseIcon(), size: 24),
                    onPressed: _audioState == AudioState.loading ? null : _handlePlayPause,
                    tooltip: _audioState == AudioState.playing ? 'Tạm dừng' : 'Phát',
                    color: _getPlayPauseColor(),
                    style: IconButton.styleFrom(
                      backgroundColor: _audioState == AudioState.playing 
                          ? colorScheme.primary 
                          : colorScheme.primaryContainer,
                      minimumSize: const Size(36, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Loading indicator
                  if (_audioState == AudioState.loading)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                  
                  // Error indicator
                  if (_audioState == AudioState.error)
                    Icon(
                      Icons.error_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                ],
              ),
            ),
            
            // Error message
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isInitialized) {
      _audioService.removeStateListener(_audioId);
      _audioService.removePositionListener(_audioId);
      _audioService.removeDurationListener(_audioId);
      _audioService.removeErrorListener(_audioId);
    }
    super.dispose();
  }
}