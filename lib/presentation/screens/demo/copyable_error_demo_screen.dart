import 'package:flutter/material.dart';
import '../../widgets/common/copyable_error_widget.dart';

/// Demo screen to showcase the copyable error widget functionality
class CopyableErrorDemoScreen extends StatelessWidget {
  const CopyableErrorDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Lỗi Có Thể Sao Chép'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Các loại lỗi có thể sao chép',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // API Error Example
            CopyableErrorWidget.apiError(
              errorMessage: 'Failed to connect to ElevenLabs API. Status code: 401. Please check your API key and ensure it has the necessary permissions.',
              title: 'Lỗi API ElevenLabs',
            ),
            
            const SizedBox(height: 16),
            
            // Network Error Example
            CopyableErrorWidget.networkError(
              errorMessage: 'Network timeout occurred while fetching voice data. Please check your internet connection and try again.',
              title: 'Lỗi kết nối mạng',
            ),
            
            const SizedBox(height: 16),
            
            // Validation Error Example
            CopyableErrorWidget.validationError(
              errorMessage: 'API Key format is invalid. Expected format: sk-xxxxxxxxxx. Please ensure you copied the complete key from ElevenLabs dashboard.',
            ),
            
            const SizedBox(height: 16),
            
            // General Error Example
            CopyableErrorWidget.generalError(
              errorMessage: 'An unexpected error occurred while processing your request. Error details: SQLite database is locked. Please restart the application.',
            ),
            
            const SizedBox(height: 24),
            
            // Custom Error Example
            CopyableErrorWidget(
              errorMessage: 'Voice synthesis failed due to insufficient credits. Current balance: 0 characters remaining. Please upgrade your ElevenLabs subscription or purchase additional credits.',
              title: 'Lỗi tài nguyên',
              icon: Icons.account_balance_wallet,
              copySuccessMessage: 'Đã sao chép thông tin lỗi tài nguyên',
            ),
            
            const SizedBox(height: 24),
            
            // Demonstration buttons
            Text(
              'Thử nghiệm các tính năng',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test error dialog button
            ElevatedButton.icon(
              onPressed: () => _showErrorDialog(context),
              icon: const Icon(Icons.error_outline),
              label: const Text('Hiện dialog lỗi'),
            ),
            const SizedBox(height: 8),
            
            // Test error with extension method
            ElevatedButton.icon(
              onPressed: () => _showErrorWithExtension(context),
              icon: const Icon(Icons.extension),
              label: const Text('Lỗi với extension method'),
            ),
            const SizedBox(height: 8),
            
            // Test complex error
            ElevatedButton.icon(
              onPressed: () => _showComplexError(context),
              icon: const Icon(Icons.bug_report),
              label: const Text('Lỗi phức tạp'),
            ),
            
            const SizedBox(height: 24),
            
            // Information card
            Card(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Hướng dẫn sử dụng',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('• Nhấn vào biểu tượng copy để sao chép thông tin lỗi'),
                    const SizedBox(height: 4),
                    const Text('• Text lỗi có thể được chọn và sao chép trực tiếp'),
                    const SizedBox(height: 4),
                    const Text('• Thông tin copy bao gồm timestamp và chi tiết ứng dụng'),
                    const SizedBox(height: 4),
                    const Text('• Widget hỗ trợ nhiều loại lỗi khác nhau với màu sắc phù hợp'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context) {
    CopyableErrorDialog.show(
      context,
      errorMessage: 'This is a sample error dialog that demonstrates the copyable error functionality. The error contains detailed information that can be easily copied and shared with support.',
      title: 'Demo Error Dialog',
      icon: Icons.warning,
    );
  }

  void _showErrorWithExtension(BuildContext context) {
    const errorMessage = 'Voice synthesis failed with timeout error. Connection to server was lost during processing.';
    errorMessage.showAsErrorDialog(
      context,
      title: 'Extension Method Error',
      icon: Icons.record_voice_over,
    );
  }

  void _showComplexError(BuildContext context) {
    final complexError = '''
Stack Trace:
  at VoiceSynthesisService.synthesize(line 127)
  at VoiceProvider.generateVoice(line 85)
  at _VoiceSelectionScreenState._generateVoice(line 1010)

Request Details:
- Voice ID: 21m00Tcm4TlvDq8ikWAM
- Text Length: 156 characters
- API Endpoint: https://api.elevenlabs.io/v1/text-to-speech
- Timestamp: ${DateTime.now().toIso8601String()}

System Information:
- Platform: Flutter Web
- User Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
- Memory Usage: 45.2 MB
    ''';

    CopyableErrorDialog.show(
      context,
      errorMessage: complexError,
      title: 'Complex Error with Stack Trace',
      icon: Icons.code,
    );
  }
}