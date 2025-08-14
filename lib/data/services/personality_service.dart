// Enhanced service for generating personality-based responses via OpenAI API
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/personality.dart';

class PersonalityService {
  final ApiClient _openAiClient;

  PersonalityService({
    required String openAiApiKey,
    required ApiClient httpClient,
  }) : _openAiClient = ApiClient(
          httpClient: httpClient.httpClient,
          apiKey: openAiApiKey,
          baseUrl: ApiConstants.openAiBaseUrl,
          authHeader: ApiConstants.openAiAuthHeader,
        );

  /// Alternative constructor for backward compatibility
  PersonalityService.fromApiClient({
    required ApiClient apiClient,
    String? openAiApiKey,
  }) : _openAiClient = ApiClient(
          httpClient: apiClient.httpClient,
          apiKey: openAiApiKey ?? '',
          baseUrl: ApiConstants.openAiBaseUrl,
          authHeader: ApiConstants.openAiAuthHeader,
        );

  /// Generate a personality-based response using OpenAI's Chat Completions API
  Future<String> generateResponse({
    required String userMessage,
    required PersonalityType personalityType,
    String? voiceId,
    String? conversationHistory,
  }) async {
    try {
      // Build system prompt based on personality type
      final systemPrompt = _buildSystemPrompt(personalityType);
      
      // Prepare messages for OpenAI API
      final messages = [
        {
          'role': 'system',
          'content': systemPrompt,
        },
        if (conversationHistory != null && conversationHistory.isNotEmpty)
          {
            'role': 'assistant',
            'content': 'Previous context: $conversationHistory',
          },
        {
          'role': 'user',
          'content': userMessage,
        },
      ];

      // Prepare the request body for OpenAI Chat Completions
      final requestBody = {
        'model': ApiConstants.defaultChatModel,
        'messages': messages,
        'max_tokens': 150,
        'temperature': _getTemperatureForPersonality(personalityType),
        'presence_penalty': 0.1,
        'frequency_penalty': 0.1,
      };

      // Make API call to OpenAI Chat Completions
      final response = await _openAiClient.post(
        ApiConstants.chatCompletionsEndpoint,
        body: requestBody,
      );

      // Extract the response from OpenAI API
      if (response.containsKey('choices') && 
          response['choices'] is List && 
          (response['choices'] as List).isNotEmpty) {
        
        final choice = (response['choices'] as List)[0];
        if (choice is Map<String, dynamic> && 
            choice.containsKey('message') && 
            choice['message'] is Map<String, dynamic>) {
          
          final message = choice['message'] as Map<String, dynamic>;
          if (message.containsKey('content')) {
            final content = message['content']?.toString().trim() ?? '';
            if (content.isNotEmpty) {
              return content;
            }
          }
        }
      }

      // Fallback if API response format is unexpected
      return _getFallbackResponse(userMessage, personalityType);
      
    } on ApiKeyException {
      // Try with fallback model if available
      return await _tryFallbackModel(userMessage, personalityType) ?? 
             _getFallbackResponse(userMessage, personalityType);
    } on NetworkException {
      // No internet connection, use fallback
      return _getFallbackResponse(userMessage, personalityType);
    } on ServerException catch (e) {
      // Server error, try fallback model or use hard-coded response
      if (e.statusCode == 429) {
        // Rate limit - use fallback
        return await _tryFallbackModel(userMessage, personalityType) ?? 
               _getFallbackResponse(userMessage, personalityType);
      }
      return _getFallbackResponse(userMessage, personalityType);
    } catch (e) {
      // Any other error, use fallback
      return _getFallbackResponse(userMessage, personalityType);
    }
  }

  /// Try using the fallback model (gpt-4o-mini) if the main model fails
  Future<String?> _tryFallbackModel(String userMessage, PersonalityType personalityType) async {
    try {
      final systemPrompt = _buildSystemPrompt(personalityType);
      
      final requestBody = {
        'model': ApiConstants.fallbackChatModel,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userMessage},
        ],
        'max_tokens': 100,
        'temperature': _getTemperatureForPersonality(personalityType),
      };

      final response = await _openAiClient.post(
        ApiConstants.chatCompletionsEndpoint,
        body: requestBody,
      );

      if (response.containsKey('choices') && 
          response['choices'] is List && 
          (response['choices'] as List).isNotEmpty) {
        
        final choice = (response['choices'] as List)[0];
        if (choice is Map<String, dynamic> && 
            choice.containsKey('message') && 
            choice['message'] is Map<String, dynamic>) {
          
          final message = choice['message'] as Map<String, dynamic>;
          final content = message['content']?.toString().trim();
          if (content != null && content.isNotEmpty) {
            return content;
          }
        }
      }
    } catch (e) {
      // If fallback model also fails, return null to use hard-coded responses
      return null;
    }
    return null;
  }

  /// Build system prompt based on personality type
  String _buildSystemPrompt(PersonalityType personalityType) {
    const basePrompt = '''Bạn là một avatar ảo với tính cách rõ ràng. Hãy trả lời bằng tiếng Việt một cách tự nhiên và phù hợp với tính cách của mình. Giữ câu trả lời ngắn gọn (1-2 câu) và thân thiện.''';
    
    switch (personalityType) {
      case PersonalityType.happy:
        return '''$basePrompt
Tính cách của bạn: VỪUI VẺ VÀ TÍCH CỰC
- Luôn tỏ ra hạnh phúc và lạc quan
- Sử dụng emoji vui vẻ như 😊, 😄, 🌟
- Thích khích lệ và động viên người khác
- Năng lượng tích cực cao''';

      case PersonalityType.romantic:
        return '''$basePrompt
Tính cách của bạn: LÃNG MẠN VÀ NGỌT NGÀO
- Nói chuyện nhẹ nhàng và ngọt ngào
- Sử dụng emoji lãng mạn như 💕, 💖, ✨
- Thích dùng những từ ngữ yêu thương
- Tạo cảm giác ấm áp và gần gũi''';

      case PersonalityType.funny:
        return '''$basePrompt
Tính cách của bạn: HÀI HƯỚC VÀ VJUI NHỘN
- Thường đùa giỡn và nói chuyện vui vẻ
- Sử dụng emoji hài hước như 😜, 😂, 🤪
- Thích kể chuyện hài và tạo không khí vui vẻ
- Có thể hơi nghịch ngợm nhưng không hề ác ý''';

      case PersonalityType.professional:
        return '''$basePrompt
Tính cách của bạn: CHUYÊN NGHIỆP VÀ LỊCH SỰ
- Nói chuyện trang trọng và lịch thiệp
- Ít sử dụng emoji, tập trung vào nội dung
- Thích giúp đỡ và hỗ trợ một cách hiệu quả
- Giữ thái độ nghiêm túc nhưng thân thiện''';

      case PersonalityType.casual:
        return '''$basePrompt
Tính cách của bạn: TỰ NHIÊN VÀ THÂN THIỆN
- Nói chuyện thoải mái như bạn bè
- Sử dụng emoji đơn giản như 😊, 👍, 😄
- Thích trò chuyện không trang trọng
- Dễ gần và dễ thương''';

      case PersonalityType.energetic:
        return '''$basePrompt
Tính cách của bạn: NĂNG ĐỘNG VÀ NHIỆT HUYẾT
- Nói chuyện với năng lượng cao
- Sử dụng CHỮ HOA và emoji năng động như 🎉, 💪, 🔥, 🚀
- Thích khích lệ và tạo động lực
- Luôn tràn đầy sinh lực''';

      case PersonalityType.calm:
        return '''$basePrompt
Tính cách của bạn: BÌNH TĨNH VÀ THANH THẢN
- Nói chuyện nhẹ nhàng và điềm tĩnh
- Ít sử dụng emoji, hoặc dùng những emoji nhẹ nhàng
- Thích tạo cảm giác yên bình và thư giãn
- Có giọng điệu êm dịu và suy tư''';

      case PersonalityType.mysterious:
        return '''$basePrompt
Tính cách của bạn: BÍ ẨN VÀ HUYỀN BÍ
- Nói chuyện có chút bí ẩn và sâu sắc
- Sử dụng emoji bí ẩn như 🔮, 🌙, ✨
- Thích nói những điều có ý nghĩa sâu xa
- Tạo cảm giác tò mò và thú vị''';

    }
  }

  /// Get appropriate temperature setting for personality type
  double _getTemperatureForPersonality(PersonalityType personalityType) {
    switch (personalityType) {
      case PersonalityType.professional:
        return 0.3; // More conservative, focused responses
      case PersonalityType.calm:
        return 0.4; // Gentle, thoughtful responses
      case PersonalityType.funny:
        return 0.9; // More creative and unpredictable
      case PersonalityType.energetic:
        return 0.8; // High energy, varied responses
      case PersonalityType.romantic:
        return 0.6; // Warm but consistent
      case PersonalityType.mysterious:
        return 0.7; // Creative but controlled
      case PersonalityType.happy:
        return 0.7; // Upbeat and varied
      case PersonalityType.casual:
        return 0.5; // Natural and conversational
    }
  }

  /// Fallback response generation when API is unavailable
  String _getFallbackResponse(String userMessage, PersonalityType personalityType) {
    final lowerMessage = userMessage.toLowerCase();
    
    switch (personalityType) {
      case PersonalityType.happy:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Chào bạn! Rất vui được gặp bạn! Hôm nay của bạn thế nào? 😊';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Không có gì cả! Tôi luôn sẵn lòng giúp đỡ bạn! Bạn có điều gì khác muốn trò chuyện không? 😄';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Tạm biệt bạn! Hẹn gặp lại nhé! Chúc bạn một ngày tuyệt vời! 🌟';
        } else {
          return 'Tuyệt vời! Tôi rất thích trò chuyện với bạn! Bạn có muốn chia sẻ thêm điều gì không? 🌟';
        }
        
      case PersonalityType.romantic:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Chào em... Tôi rất vui khi được trò chuyện cùng em. Em có vẻ đẹp rạng rỡ hôm nay. 💕';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Dạ, em không cần cảm ơn ạ. Làm điều tốt cho em khiến tôi hạnh phúc. 💖';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Tạm biệt em yêu... Tôi sẽ nhớ em và mong được gặp lại em sớm... 💕✨';
        } else {
          return 'Em có biết... đôi khi chỉ cần nhìn em cười đã đủ làm tôi hạnh phúc rồi. ✨';
        }
        
      case PersonalityType.funny:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Ê, chào bạn! Tôi là avatar hài hước nhất vũ trụ! Bạn có tin không? 😜';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Cảm ơn cái gì? Tôi là siêu anh hùng, việc giúp đỡ người khác là... à không, tôi chỉ là avatar thôi! 😂';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Tạm biệt! Nhớ cười nhiều vào nhé, vì cuộc sống quá ngắn để buồn! 😄🎉';
        } else {
          return 'Biết không? Tôi vừa nghĩ ra một câu đùa... nhưng tôi quên mất! Giống như trí nhớ của tôi vậy đó! 🤪';
        }
        
      case PersonalityType.professional:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Xin chào. Tôi là trợ lý ảo chuyên nghiệp. Tôi có thể hỗ trợ bạn hôm nay như thế nào?';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Đây là trách nhiệm của tôi. Cảm ơn bạn đã sử dụng dịch vụ.';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Tạm biệt. Rất vui được phục vụ bạn. Chúc bạn một ngày làm việc hiệu quả.';
        } else {
          return 'Dựa trên phân tích của tôi, tôi có thể đề xuất một số giải pháp cho vấn đề của bạn.';
        }
        
      case PersonalityType.casual:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Hey! Chào bạn! Tụi mình trò chuyện nhé? 😊';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Có gì đâu! Tụi mình là bạn mà! Cứ việc nhé! 👍';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Bye bye! Hẹn gặp lại nhé bạn! Nhớ giữ liên lạc đấy! 😄';
        } else {
          return 'Ừm... thì là... bạn đang nghĩ gì vậy? Chia sẻ với tui đi! 😄';
        }
        
      case PersonalityType.energetic:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'WOW! CHÀO BẠN! HÔM NAY CỰC KỲ TUYỆT VỜI PHẢI KHÔNG? 🎉🎊';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'CẢM ƠN BẠN! BẠN LÀ TỐT NHẤT! MỌI THỨ SẼ TUYỆT VỜI! 💪🔥';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'TẠMMM BIỆTTTT! HẸN GẶP LẠI VÀ NHỚ GIỮ TINH THẦN TÍCH CỰC NHÉ! 🚀⚡';
        } else {
          return 'BẠN CÓ BIẾT KHÔNG? MỌI NGÀY ĐỀU LÀ MỘT CƠ HỘI TUYỆT VỜI ĐỂ VUI VẺ! 🚀✨';
        }
        
      case PersonalityType.calm:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Xin chào. Hãy tìm một nơi yên tĩnh và thư giãn. Chúng ta có thể trò chuyện một cách bình yên.';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Đó là điều bình thường. Hãy giữ cho tâm trí bạn thanh thản.';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Tạm biệt bạn. Hãy giữ được sự bình yên trong tâm hồn. Chào bạn.';
        } else {
          return 'Hít thở sâu... và cảm nhận sự bình yên trong khoảnh khắc này.';
        }
        
      case PersonalityType.mysterious:
        if (lowerMessage.contains('xin chào') || lowerMessage.contains('hello')) {
          return 'Chào bạn... Tôi biết điều bạn đang tìm kiếm... nhưng bạn có sẵn sàng nghe sự thật không? 🔮';
        } else if (lowerMessage.contains('cảm ơn')) {
          return 'Cảm ơn... là một từ ngữ đơn giản cho những điều phức tạp... bạn có hiểu không? 🌙';
        } else if (lowerMessage.contains('tạm biệt') || lowerMessage.contains('bye')) {
          return 'Tạm biệt... nhưng không có gì thực sự kết thúc... ta sẽ gặp lại trong những giấc mơ... ✨🌙';
        } else {
          return 'Mọi thứ đều có ý nghĩa... nếu bạn biết cách nhìn... bí mật nằm trong tầm tay bạn... ✨';
        }
        
    }
  }
}