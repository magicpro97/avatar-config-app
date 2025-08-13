import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/voice_provider.dart';
import '../../../domain/entities/avatar_configuration.dart';
import '../../../domain/entities/voice.dart';
import '../../../domain/entities/personality.dart';
import '../../../presentation/widgets/avatar/avatar_display_widget.dart';
import 'widgets/chat_message_widget.dart';

/// Demo chat screen that showcases avatar and voice configuration functionality
class DemoChatScreen extends StatefulWidget {
  const DemoChatScreen({super.key});

  @override
  State<DemoChatScreen> createState() => _DemoChatScreenState();
}

class _DemoChatScreenState extends State<DemoChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _conversationHistory = [];
  bool _isGeneratingVoice = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Load avatar configurations
    await context.read<AvatarProvider>().loadConfigurations();
    
    // Load voice configurations
    await context.read<VoiceProvider>().loadAvailableVoices();
    
    // Add welcome message
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    final avatarProvider = context.read<AvatarProvider>();
    final activeConfig = avatarProvider.activeConfiguration;
    
    if (activeConfig != null) {
      _addToConversation(
        message: 'Xin chào! Tôi là ${activeConfig.name}. Tôi rất vui được trò chuyện với bạn hôm nay. Tôi có tính cách ${activeConfig.personalityDisplayName} và sẽ sử dụng giọng nói ${activeConfig.voiceName} để trò chuyện cùng bạn.',
        isUserMessage: false,
        avatarConfig: activeConfig,
        voiceConfig: activeConfig.voiceConfiguration,
      );
    } else {
      _addToConversation(
        message: 'Xin chào! Chào mừng bạn đến với màn hình demo chat. Vui lòng chọn một cấu hình avatar để bắt đầu trò chuyện.',
        isUserMessage: false,
      );
    }
  }

  void _addToConversation({
    required String message,
    required bool isUserMessage,
    AvatarConfiguration? avatarConfig,
    VoiceConfiguration? voiceConfig,
    String? audioId,
  }) {
    setState(() {
      _conversationHistory.add({
        'id': const Uuid().v4(),
        'message': message,
        'timestamp': DateTime.now(),
        'isUserMessage': isUserMessage,
        'avatarConfig': avatarConfig,
        'voiceConfig': voiceConfig,
        'audioId': audioId,
      });
    });
    
    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _handleSendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Add user message
    _addToConversation(
      message: message,
      isUserMessage: true,
    );

    // Clear input
    _messageController.clear();

    // Simulate avatar response after a delay
    _simulateAvatarResponse(message);
  }

  Future<void> _simulateAvatarResponse(String userMessage) async {
    final avatarProvider = context.read<AvatarProvider>();
    final activeConfig = avatarProvider.activeConfiguration;
    
    if (activeConfig == null) {
      // No active configuration
      _addToConversation(
        message: 'Xin lỗi, hiện tại không có cấu hình avatar hoạt động. Vui lòng quay lại màn hình chính để chọn một cấu hình.',
        isUserMessage: false,
      );
      return;
    }

    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 1000));

    // Generate response based on personality type
    final response = _generatePersonalityResponse(userMessage, activeConfig.personalityType);
    
    _addToConversation(
      message: response,
      isUserMessage: false,
      avatarConfig: activeConfig,
      voiceConfig: activeConfig.voiceConfiguration,
    );
  }

  String _generatePersonalityResponse(String userMessage, PersonalityType personalityType) {
    final lowerMessage = userMessage.toLowerCase();
    
    switch (personalityType) {
      case PersonalityType.happy:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Chào bạn! Rất vui được gặp bạn! Hôm nay của bạn thế nào? 😊';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Không có gì cả! Tôi luôn sẵn lòng giúp đỡ bạn! Bạn có điều gì khác muốn trò chuyện không? 😄';
        } else {
          return 'Tuyệt vời! Tôi rất thích trò chuyện với bạn! Bạn có muốn chia sẻ thêm điều gì không? 🌟';
        }
        
      case PersonalityType.romantic:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Chào em... Tôi rất vui khi được trò chuyện cùng em. Em có vẻ đẹp rạng rỡ hôm nay. 💕';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Dạ, em không cần cảm ơn ạ. Làm điều tốt cho em khiến tôi hạnh phận. 💖';
        } else {
          return 'Em có biết... đôi khi chỉ cần nhìn em cười đã đủ làm tôi hạnh phục rồi. ✨';
        }
        
      case PersonalityType.funny:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Ê, chào bạn! Tôi là avatar hài hước nhất vũ trụ! Bạn có tin không? 😜';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Cảm ơn cái gì? Tôi là siêu anh hùng, việc giúp đỡ người khác là... à không, tôi chỉ là avatar thôi! 😂';
        } else {
          return 'Biết không? Tôi vừa nghĩ ra một câu đùa... nhưng tôi quên mất! Giống như trí nhớ của tôi vậy đó! 🤪';
        }
        
      case PersonalityType.professional:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Xin chào. Tôi là trợ lý ảo chuyên nghiệp. Tôi có thể hỗ trợ bạn hôm nay như thế nào?';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Đây là trách nhiệm của tôi. Cảm ơn bạn đã sử dụng dịch vụ.';
        } else {
          return 'Dựa trên phân tích của tôi, tôi có thể đề xuất một số giải pháp cho vấn đề của bạn.';
        }
        
      case PersonalityType.casual:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Hey! Chào bạn! Tụi mình trò chuyện nhé? 😊';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Có gì đâu! Tụi mình là bạn mà! Cứ việc nhé! 👍';
        } else {
          return 'Ừm... thì là... bạn đang nghĩ gì vậy? Chia sẻ với tui đi! 😄';
        }
        
      case PersonalityType.energetic:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'WOW! CHÀO BẠN! HÔM NAY CỰC KỲ TUYỆT VỜI PHẢI KHÔNG? 🎉🎊';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'CẢM ƠN BẠN! BẠN LÀ TỐT NHẤT! 💪🔥';
        } else {
          return 'BẠN CÓ BIẾT KHÔNG? MỌI NGÀY ĐỀU LÀ MỘT CƠ HỘI TUYỆT VỜI ĐỂ VUI VẺ! 🚀✨';
        }
        
      case PersonalityType.calm:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Xin chào. Hãy tìm một nơi yên tĩnh và thư giãn. Chúng ta có thể trò chuyện một cách bình yên.';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Đó là điều bình thường. Hãy giữ cho tâm trí bạn thanh thản.';
        } else {
          return 'Hít thở sâu... và cảm nhận sự bình yên trong khoảnh khắc này.';
        }
        
      case PersonalityType.mysterious:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Chào bạn... Tôi biết điều bạn đang tìm kiếm... nhưng bạn có sẵn sàng nghe sự thật không? 🔮';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Cảm ơn... là một từ ngữ đơn giản cho những điều phức tạp... bạn có hiểu không? 🌙';
        } else {
          return 'Mọi thứ đều có ý nghĩa... nếu bạn biết cách nhìn... bí mật nằm trong tầm tay bạn... ✨';
        }
        
      default:
        return 'Xin chào! Tôi là avatar của bạn. Chúng ta có thể trò chuyện về bất cứ điều gì bạn muốn.';
    }
  }

  Future<void> _handleSynthesizeSpeech() async {
    final avatarProvider = context.read<AvatarProvider>();
    final voiceProvider = context.read<VoiceProvider>();
    final activeConfig = avatarProvider.activeConfiguration;
    
    if (activeConfig == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một cấu hình avatar trước')),
      );
      return;
    }

    if (_conversationHistory.isEmpty || _conversationHistory.last['isUserMessage'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng gửi một tin nhắn trước khi tổng hợp giọng nói')),
      );
      return;
    }

    setState(() {
      _isGeneratingVoice = true;
    });

    try {
      // Get the last avatar message
      final lastAvatarMessage = _conversationHistory.lastWhere(
        (msg) => msg['isUserMessage'] == false,
        orElse: () => <String, dynamic>{},
      );

      if (lastAvatarMessage.isNotEmpty) {
        final message = lastAvatarMessage['message'] as String;
        final messageId = lastAvatarMessage['id'] as String;
        
        // Use the voice provider to synthesize and play audio
        final audioId = await voiceProvider.synthesizeAndPlayAudio(message);
        
        if (audioId != null) {
          // Update the conversation history with the audio ID
          setState(() {
            final index = _conversationHistory.indexWhere((msg) => msg['id'] == messageId);
            if (index != -1) {
              _conversationHistory[index]['audioId'] = audioId;
            }
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã tổng hợp và phát giọng nói thành công!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không thể phát giọng nói. Vui lòng kiểm tra cài đặt.')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi tổng hợp giọng nói: $e')),
      );
    } finally {
      setState(() {
        _isGeneratingVoice = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatarProvider = context.watch<AvatarProvider>();
    final voiceProvider = context.watch<VoiceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Chat với Avatar'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInitialData,
            tooltip: 'Tải lại',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Thông tin',
          ),
        ],
      ),
      body: Column(
        children: [
          // Active configuration banner
          if (avatarProvider.hasActiveConfiguration)
            _buildActiveConfigBanner(avatarProvider.activeConfiguration!),
          
          // Conversation area
          Expanded(
            child: _buildConversationArea(),
          ),
          
          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildActiveConfigBanner(AvatarConfiguration config) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          AvatarDisplayWidget(
            avatarConfig: config,
            size: 40,
            showAnimation: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Avatar đang hoạt động: ${config.name}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Tính cách: ${config.personalityDisplayName} • Giọng: ${config.voiceName}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationArea() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      itemCount: _conversationHistory.length,
      itemBuilder: (context, index) {
        final message = _conversationHistory[index];
        return ChatMessageWidget(
          message: message['message'] as String,
          isUserMessage: message['isUserMessage'] as bool,
          timestamp: message['timestamp'] as DateTime,
          avatarConfig: message['avatarConfig'] as AvatarConfiguration?,
          voiceConfig: message['voiceConfig'] as VoiceConfiguration?,
          audioId: message['audioId'] as String?,
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Voice synthesis button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn của bạn...',
                    hintStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                      ),
                    ),
                    enabled: !_isGeneratingVoice,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _handleSendMessage(),
                  textInputAction: TextInputAction.send,
                ),
              ),
              const SizedBox(width: 12),
              
              // Voice synthesis button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: _isGeneratingVoice
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.record_voice_over),
                  onPressed: _isGeneratingVoice ? null : _handleSynthesizeSpeech,
                  tooltip: 'Tổng hợp giọng nói',
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Send button
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSendMessage,
                  tooltip: 'Gửi tin nhắn',
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Instructions
          Text(
            'Nhập tin nhắn và gửi để xem avatar phản hồi. Sử dụng nút tổng hợp giọng nói để phát âm thanh.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin Demo Chat'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• Demo này cho thấy cách avatar có tính cách khác nhau phản hồi tin nhắn.'),
            Text('• Mỗi tính cách có cách trả lời và giọng nói khác nhau.'),
            Text('• Nút tổng hợp giọng nói sẽ phát âm thanh từ tin nhắn cuối cùng của avatar.'),
            Text('• Bạn cần chọn một cấu hình avatar hoạt động để sử dụng tính năng này.'),
            Text('• Đây là phiên bản demo, trong ứng dụng thực tế sẽ kết nối với ElevenLabs API.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}