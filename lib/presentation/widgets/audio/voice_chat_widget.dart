// Voice Chat Widget for two-way voice communication
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/services/voice_recording_service.dart';
import '../../../data/services/speech_to_text_service.dart';
import 'audio_wave_visualizer.dart';
import '../../../data/repositories/settings_repository_impl.dart';


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
  bool _isStopping = false; // For loading state when stopping
  String? _errorMessage;
  String? _partialText; // For real-time partial results
  AnimationController? _animationController;
  Animation<double>? _pulseAnimation;
  
  // Button state management
  bool _isButtonDisabled = false;
  DateTime? _lastButtonPressTime;
  static const Duration _buttonDebounceDuration = Duration(milliseconds: 200); // Reduced debounce time
  
  // Unified state management
  static const Duration _stateTransitionDelay = Duration(milliseconds: 300);

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

      // Apply runtime settings for web speech fallback
      try {
        final settingsRepo = SettingsRepositoryImpl();
        final useFallback = await settingsRepo.getSetting<bool>('useWebSpeechFallback') ?? true;
        _speechService.setUseWebFallback(useFallback);
      } catch (_) {}

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
      _speechService.setPartialTextRecognizedListener(_handlePartialTextRecognized);
      _speechService.setErrorListener(_handleSpeechError);
      _speechService.setRealTimeResultsEnabled(true); // Enable real-time results

      _isInitialized = true;
      // Services initialized successfully
    } catch (e) {
      _setError('Failed to initialize services: $e');
    }
  }

  void _handleRecordingStateChange(RecordingState state) {
    if (mounted) {
      setState(() {
        _isRecording = state == RecordingState.recording;
        _errorMessage = null;
        _updateButtonState();
      });

      if (state == RecordingState.recording) {
        _animationController?.repeat(reverse: true);
      } else {
        _animationController?.stop();
        _animationController?.reset();
      }
      
      // Ensure state consistency after change
      _ensureStateConsistency();
    }
  }

  void _handleRecordingDurationChange(Duration duration) {
    // Update recording duration if needed
    // Could be used to display recording time in the future
  }

  void _handleSpeechStateChange(SpeechRecognitionState state) {
    if (mounted) {
      setState(() {
        _isListening = state == SpeechRecognitionState.listening;
        _errorMessage = null;
        _updateButtonState();
      });

      if (state == SpeechRecognitionState.listening) {
        _animationController?.repeat(reverse: true);
      } else {
        _animationController?.stop();
        _animationController?.reset();
      }
      
      // Ensure state consistency after change
      _ensureStateConsistency();
    }
  }

  void _handleTextRecognized(String text) {
    if (mounted) {
      setState(() {
        _textController.text = text;
        _partialText = null; // Clear partial text when final result is received
      });
    }
  }

  void _handlePartialTextRecognized(String text) {
    if (mounted) {
      setState(() {
        _partialText = text;
        // Update the main text controller with partial results for real-time display
        _textController.text = text;
      });
    }
  }

  void _handleSpeechError(String error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
      });
    }
  }


  void _setError(String message) {
    if (mounted) {
      setState(() {
        _errorMessage = message;
      });
    }
  }

  void _clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  // Friendly error helpers
  String _friendlyErrorText(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('permission') || lower.contains('denied')) {
      return 'Ứng dụng chưa có quyền micro. Hãy cấp quyền rồi thử lại.';
    }
    if (lower.contains('busy') || lower.contains('in use')) {
      return 'Micro đang bận bởi ứng dụng khác. Đóng tab/ứng dụng đang dùng micro và thử lại.';
    }
    if (lower.contains('not supported')) {
      return 'Trình duyệt của bạn không hỗ trợ tính năng nhận dạng giọng nói.';
    }
    if (lower.contains('network') || lower.contains('connection')) {
      return 'Lỗi kết nối mạng. Kiểm tra mạng rồi thử lại.';
    }
    return raw;
  }

  Future<void> _handleCheckMicPermission() async {
    try {
      final hasPerm = await _speechService.isMicrophoneAvailable();
      if (!hasPerm) {
        final granted = await _speechService.requestPermission();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(granted ? 'Đã cấp quyền micro' : 'Không thể cấp quyền micro')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quyền micro đã được cấp')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kiểm tra quyền micro: $e')),
      );
    }
  }

  // Button state management helpers
  void _updateButtonState() {
    if (mounted) {
      setState(() {
        // Only disable voice button, not send button
        _isButtonDisabled = _isRecording || _isListening; // keep responsive when stopping
      });
    }
  }

  bool _isButtonPressedRecently() {
    if (_lastButtonPressTime == null) return false;
    final now = DateTime.now();
    return now.difference(_lastButtonPressTime!) < _buttonDebounceDuration;
  }

  void _recordButtonPress() {
    _lastButtonPressTime = DateTime.now();
  }

  Future<void> _debouncedButtonPress(Future<void> Function() action) async {
    if (_isButtonPressedRecently() || _isButtonDisabled) {
      return;
    }

    _recordButtonPress();
    _updateButtonState();

    try {
      await action();
    } finally {
      // Reset button state after a shorter delay for better responsiveness
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {
          _isButtonDisabled = false;
        });
      }
    }
  }

  // Unified state coordination methods
  Future<void> _waitForStateTransition() async {
    await Future.delayed(_stateTransitionDelay);
  }

  void _ensureStateConsistency() {
    // Ensure UI always reflects actual state
    if (mounted) {
      setState(() {
        final actualRecordingState = _recordingService.state == RecordingState.recording;
        final actualListeningState = _speechService.state == SpeechRecognitionState.listening;
        
        // If there's a mismatch, update to reflect actual state
        if (_isRecording != actualRecordingState) {
          _isRecording = actualRecordingState;
        }
        if (_isListening != actualListeningState) {
          _isListening = actualListeningState;
        }
        
        _updateButtonState();
      });
    }
  }

  // Regular state transition with delays for start actions
  Future<void> _safeStateTransition(Future<void> Function() action) async {
    try {
      // Ensure current state is stable
      await _waitForStateTransition();
      
      // Execute the action
      await action();
      
      // Wait for state to settle
      await _waitForStateTransition();
      
      // Ensure UI consistency
      _ensureStateConsistency();
    } catch (e) {
      _setError('State transition error: $e');
      _ensureStateConsistency();
    }
  }

  // Ensure microphone resource is properly released before starting speech recognition
  Future<void> _ensureMicrophoneReleased() async {
    try {
      // Reset recording service to ensure microphone is released
      await _recordingService.reset();
      
      // Reset speech service to ensure clean state (it handles its own cleanup now)
      await _speechService.reset();
      
      // Wait for resources to be fully released
      await Future.delayed(const Duration(milliseconds: 200));
    } catch (e) {
      // Log error but continue - this is a cleanup operation
      debugPrint('Error ensuring microphone released: $e');
    }
  }

  Future<void> _handleStopRecording() async {
    await _debouncedButtonPress(() async {
      await _safeStateTransition(() async {
        try {
          _clearError();
          
          // Ensure we're actually recording before trying to stop
          if (!_isRecording) {
            _setError('Not currently recording');
            return;
          }

          // Stop recording with retry logic
          String? recordingPath;
          int maxRetries = 3;
          int retryCount = 0;
          
          while (retryCount < maxRetries) {
            try {
              recordingPath = await _recordingService.stopRecording();
              if (recordingPath != null) {
                break; // Success, exit retry loop
              }
            } catch (e) {
              retryCount++;
              if (retryCount >= maxRetries) {
                _setError('Failed to stop recording after $maxRetries attempts: $e');
                return;
              }
              // Wait before retrying
              await Future.delayed(const Duration(milliseconds: 100));
            }
          }

          if (recordingPath == null) {
            _setError('Failed to save recording');
            return;
          }

          // Ensure microphone is properly released before starting speech recognition
          await _ensureMicrophoneReleased();

          // Convert speech to text
          await _handleStartListening();
        } catch (e) {
          _setError('Failed to stop recording: $e');
        }
      });
    });
  }

  Future<void> _handleStartListening() async {
    await _debouncedButtonPress(() async {
      await _safeStateTransition(() async {
        try {
          _clearError();

          // Ensure previous session is fully cleaned up to avoid busy mic states
          await _speechService.reset();
          await Future.delayed(const Duration(milliseconds: 80));

          // Check if speech recognition is available
          final isAvailable = await _speechService.isAvailable();
          if (!isAvailable) {
            _setError('Speech recognition is not available on this device');
            return;
          }

          // Check if microphone is available and has permission
          final hasMicPermission = await _speechService.isMicrophoneAvailable();
          if (!hasMicPermission) {
            _setError('Microphone permission is required for speech recognition');
            return;
          }

          // Start speech recognition (the service now handles cleanup automatically)
          final success = await _speechService.startListening();
          if (!success) {
            _setError('Failed to start speech recognition - ${_speechService.errorMessage ?? "microphone may be in use"}');
            return;
          }
        } catch (e) {
          _setError('Failed to start speech recognition: $e');
        }
      });
    });
  }
  Future<void> _handleStopListening() async {
    // Immediate UI feedback - no debouncing for stop actions

    // Immediately unfocus text field and update UI
    FocusScope.of(context).unfocus();
    
    if (mounted) {
      setState(() {
        _isListening = false; // Immediate UI update
        _isStopping = true; // show spinner briefly
      });
    }

    // Prefer fast cancel over full stop to avoid platform hangs
    _speechService.cancelListening().then((ok) async {
      if (mounted) {
        if (ok) {
          _clearError();
        } else {
          _setError('Failed to cancel speech recognition');
        }
      }
      // Force reset to guarantee microphone is released
      try {
        await _speechService.reset();
      } catch (_) {}
      // Keep spinner for a short duration for smoother UX
      await Future.delayed(const Duration(milliseconds: 220));
      if (mounted) {
        setState(() {
          _isStopping = false;
        });
      }
    }).catchError((e) {
      if (mounted) {
        _setError('Failed to cancel speech recognition: $e');
        _isStopping = false;
      }
    });
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
    
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.keyM): const _StartVoiceIntent(),
        LogicalKeySet(LogicalKeyboardKey.escape): const _StopVoiceIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _StartVoiceIntent: CallbackAction<_StartVoiceIntent>(
            onInvoke: (intent) {
              if (!_isRecording && !_isListening && !_isButtonDisabled) {
                _handleStartListening();
              }
              return null;
            },
          ),
          _StopVoiceIntent: CallbackAction<_StopVoiceIntent>(
            onInvoke: (intent) {
              if (_isRecording) {
                _handleStopRecording();
              } else if (_isListening) {
                _handleStopListening();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: false,
          canRequestFocus: true,
          child: Container(
      height: widget.height ?? 130,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
          // Text input field with real-time indicator
          if (widget.showText)
            Container(
              constraints: const BoxConstraints(minHeight: 40),
              child: TextField(
                controller: _textController,
                // Keep enabled so suffix actions remain tappable; just make read-only
                readOnly: _isListening || _isRecording,
                decoration: InputDecoration(
                  hintText: _isListening ? 'Đang nghe...' : 'Nhập tin nhắn hoặc nhấn nút ghi âm...',
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: colorScheme.outline.withValues(alpha: 0.1),
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Real-time indicator when listening
                      if (_isListening && _partialText != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Live',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(width: 8),
                      // Voice recording/listening button with larger touch target
                      Container(
                        width: 48, // Explicit size for better touch target
                        height: 48,
                        decoration: BoxDecoration(
                          color: _isRecording || _isListening
                              ? colorScheme.error
                              : colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: (_isRecording || _isListening)
                                ? (_isRecording
                                    ? _handleStopRecording
                                    : _handleStopListening)
                                : (_isButtonDisabled ? null : _handleStartListening),
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              child: (_isRecording || _isListening)
                                  ? (_isStopping
                                      ? Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                colorScheme.onError,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Icon(
                                          Icons.stop,
                                          size: 24,
                                          color: colorScheme.onError,
                                        ))
                                  : Icon(
                                      Icons.mic,
                                      size: 24,
                                      color: colorScheme.onPrimaryContainer,
                                    ),
                            ),
                          ),
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
                          onPressed: _handleSendTextMessage, // Always enabled
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
          
          // Voice recording controls with enhanced real-time feedback
          if (_isRecording || _isListening)
            Column(
              children: [
                // Audio wave visualizer
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 30,
                    maxHeight: 60,
                  ),
                  child: AudioWaveVisualizer(
                    recordingService: _recordingService,
                    speechService: _speechService,
                    height: 30,
                    margin: const EdgeInsets.only(top: 4, bottom: 2),
                  ),
                ),
                // Enhanced recording indicator with real-time status
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? colorScheme.errorContainer
                              : colorScheme.primaryContainer,
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
                                        color: _isRecording
                                            ? colorScheme.error
                                            : colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            const SizedBox(width: 8),
                            Text(
                              _isRecording
                                  ? 'Đang ghi âm...'
                                  : (_partialText != null
                                      ? 'Đang nghe... $_partialText'
                                      : 'Đang nghe...'),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _isRecording
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          
          // Error message with CTAs
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                children: [
                  Text(
                    _friendlyErrorText(_errorMessage!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _handleStartListening,
                        child: const Text('Thử lại'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: _handleCheckMicPermission,
                        child: const Text('Kiểm tra quyền mic'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
      ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    try {
      _textController.dispose();
      _animationController?.dispose();
      
      if (_isInitialized) {
        // Ensure proper cleanup of both services
        _recordingService.dispose();
        _speechService.dispose();
      }
    } catch (e) {
      debugPrint('Error during voice chat widget disposal: $e');
    }
    
    super.dispose();
  }
}

class _StartVoiceIntent extends Intent {
  const _StartVoiceIntent();
}

class _StopVoiceIntent extends Intent {
  const _StopVoiceIntent();
}