// Voice Chat Widget for two-way voice communication
import 'package:flutter/material.dart';
import '../../../data/services/voice_recording_service.dart';
import '../../../data/services/speech_to_text_service.dart';


class VoiceChatWidget extends StatefulWidget {
  final Function(String)? onVoiceMessageSent;
  final Function(String)? onTextMessageSent;
  final String? initialText;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool showText;
  final TextStyle? textStyle;

  const VoiceChatWidget({
    super.key,
    this.onVoiceMessageSent,
    this.onTextMessageSent,
    this.initialText,
    this.height,
    this.padding,
    this.showText = true,
    this.textStyle,
  });

  @override
  State<VoiceChatWidget> createState() => _VoiceChatWidgetState();
}

class _VoiceChatWidgetState extends State<VoiceChatWidget> 
    with SingleTickerProviderStateMixin {
  late VoiceRecordingService _recordingService;
  late SpeechToTextService _speechService;
  
  final TextEditingController _textController = TextEditingController();
  
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isRecording = false;
  String? _errorMessage;
  AnimationController? _animationController;
  Animation<double>? _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText ?? '';
    _initializeAnimation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _initializeServices();
    }
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeServices() async {
    try {
      _recordingService = VoiceRecordingService();
      _speechService = SpeechToTextService();

      // Initialize speech recognition
      final speechInitialized = await _speechService.initialize();
      if (!speechInitialized) {
        _setError('Speech recognition initialization failed');
        return;
      }

      // Set up listeners
      _recordingService.setStateListener(_handleRecordingStateChange);
      _recordingService.setDurationListener(_handleRecordingDurationChange);
      _speechService.setStateListener(_handleSpeechStateChange);
      _speechService.setTextRecognizedListener(_handleTextRecognized);
      _speechService.setErrorListener(_handleSpeechError);

      _isInitialized = true;
      // Services initialized successfully
    } catch (e) {
      _setError('Failed to initialize services: $e');
    }
  }

  void _handleRecordingStateChange(RecordingState state) {
    setState(() {
      _isRecording = state == RecordingState.recording;
      _errorMessage = null;
    });

    if (state == RecordingState.recording) {
      _animationController?.repeat(reverse: true);
    } else {
      _animationController?.stop();
      _animationController?.reset();
    }
  }

  void _handleRecordingDurationChange(Duration duration) {
    // Update recording duration if needed
    // Could be used to display recording time in the future
  }

  void _handleSpeechStateChange(SpeechRecognitionState state) {
    setState(() {
      _isListening = state == SpeechRecognitionState.listening;
      _errorMessage = null;
    });

    if (state == SpeechRecognitionState.listening) {
      _animationController?.repeat(reverse: true);
    } else {
      _animationController?.stop();
      _animationController?.reset();
    }
  }

  void _handleTextRecognized(String text) {
    setState(() {
      _textController.text = text;
    });
  }

  void _handleSpeechError(String error) {
    setState(() {
      _errorMessage = error;
    });
  }


  void _setError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _handleStartRecording() async {
    try {
      _clearError();

      // Check recording permissions
      final hasPermission = await _recordingService.hasRecordingPermission();
      if (!hasPermission) {
        _setError('Microphone permission is required for voice recording');
        return;
      }

      // Start recording
      final success = await _recordingService.startRecording();
      if (!success) {
        _setError('Failed to start recording');
        return;
      }
    } catch (e) {
      _setError('Failed to start recording: $e');
    }
  }

  Future<void> _handleStopRecording() async {
    try {
      // Stop recording
      final recordingPath = await _recordingService.stopRecording();
      if (recordingPath == null) {
        _setError('Failed to save recording');
        return;
      }

      // Convert speech to text
      _handleStartListening();
    } catch (e) {
      _setError('Failed to stop recording: $e');
    }
  }

  Future<void> _handleStartListening() async {
    try {
      _clearError();

      // Start speech recognition
      final success = await _speechService.startListening();
      if (!success) {
        _setError('Failed to start speech recognition');
        return;
      }
    } catch (e) {
      _setError('Failed to start speech recognition: $e');
    }
  }




  Future<void> _handleSendTextMessage() async {
    try {
      final text = _textController.text.trim();
      if (text.isEmpty) return;

      widget.onTextMessageSent?.call(text);
      _textController.clear();
    } catch (e) {
      _setError('Failed to send text message: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: widget.height ?? 120,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text input field
          if (widget.showText)
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Nhập tin nhắn hoặc nhấn nút ghi âm...',
                  hintStyle: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Voice recording button
                      Container(
                        decoration: BoxDecoration(
                          color: _isRecording || _isListening
                              ? colorScheme.error
                              : colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isRecording || _isListening
                                ? Icons.stop
                                : Icons.mic,
                            size: 20,
                            color: _isRecording || _isListening
                                ? colorScheme.onError
                                : colorScheme.onPrimaryContainer,
                          ),
                          onPressed: _isRecording || _isListening
                              ? _handleStopRecording
                              : _handleStartRecording,
                          tooltip: _isRecording || _isListening
                              ? 'Dừng ghi âm'
                              : 'Bắt đầu ghi âm',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Send button
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send, size: 18),
                          onPressed: _handleSendTextMessage,
                          tooltip: 'Gửi',
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                maxLines: 3,
                minLines: 1,
                onChanged: (value) {
                  // Handle text changes
                },
              ),
            ),
          
          // Voice recording controls
          if (_isRecording || _isListening)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Recording indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated pulse indicator
                        if (_isRecording || _isListening)
                          AnimatedBuilder(
                            animation: _pulseAnimation!,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnimation!.value,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: colorScheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        const SizedBox(width: 8),
                        Text(
                          _isRecording ? 'Đang ghi âm...' : 'Đang nghe...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _animationController?.dispose();
    
    if (_isInitialized) {
      _recordingService.dispose();
      _speechService.dispose();
    }
    
    super.dispose();
  }
}