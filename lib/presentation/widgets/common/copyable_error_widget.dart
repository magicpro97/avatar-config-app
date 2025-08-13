import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that displays error messages with copy-to-clipboard functionality
class CopyableErrorWidget extends StatelessWidget {
  final String errorMessage;
  final String? title;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final bool showCopyButton;
  final String? copySuccessMessage;

  const CopyableErrorWidget({
    super.key,
    required this.errorMessage,
    this.title,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.margin,
    this.borderRadius,
    this.showCopyButton = true,
    this.copySuccessMessage,
  });

  /// Factory constructor for API errors
  factory CopyableErrorWidget.apiError({
    required String errorMessage,
    String? title,
  }) {
    return CopyableErrorWidget(
      errorMessage: errorMessage,
      title: title ?? 'Lỗi API',
      icon: Icons.cloud_off,
      copySuccessMessage: 'Đã sao chép thông tin lỗi',
    );
  }

  /// Factory constructor for validation errors
  factory CopyableErrorWidget.validationError({
    required String errorMessage,
    String? title,
  }) {
    return CopyableErrorWidget(
      errorMessage: errorMessage,
      title: title ?? 'Lỗi xác thực',
      icon: Icons.warning,
      copySuccessMessage: 'Đã sao chép thông tin lỗi',
    );
  }

  /// Factory constructor for network errors
  factory CopyableErrorWidget.networkError({
    required String errorMessage,
    String? title,
  }) {
    return CopyableErrorWidget(
      errorMessage: errorMessage,
      title: title ?? 'Lỗi mạng',
      icon: Icons.wifi_off,
      copySuccessMessage: 'Đã sao chép thông tin lỗi',
    );
  }

  /// Factory constructor for general errors
  factory CopyableErrorWidget.generalError({
    required String errorMessage,
    String? title,
  }) {
    return CopyableErrorWidget(
      errorMessage: errorMessage,
      title: title ?? 'Lỗi hệ thống',
      icon: Icons.error,
      copySuccessMessage: 'Đã sao chép thông tin lỗi',
    );
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    try {
      // Create a detailed error message for copying
      final copyText = _buildCopyText();
      
      await Clipboard.setData(ClipboardData(text: copyText));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              copySuccessMessage ?? 'Đã sao chép vào clipboard',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể sao chép: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _buildCopyText() {
    final buffer = StringBuffer();
    
    if (title != null) {
      buffer.writeln('=== $title ===');
    }
    
    buffer.writeln('Thời gian: ${DateTime.now().toIso8601String()}');
    buffer.writeln('Ứng dụng: Avatar Config App');
    buffer.writeln();
    buffer.writeln('Chi tiết lỗi:');
    buffer.writeln(errorMessage);
    
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.all(16),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.errorContainer,
        borderRadius: borderRadius ?? BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with icon and title
          if (title != null || icon != null)
            Row(
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: textColor ?? colorScheme.onErrorContainer,
                    size: 24,
                  ),
                if (icon != null && title != null) const SizedBox(width: 8),
                if (title != null)
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: textColor ?? colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (showCopyButton)
                  IconButton(
                    onPressed: () => _copyToClipboard(context),
                    icon: Icon(
                      Icons.copy,
                      color: textColor ?? colorScheme.onErrorContainer,
                    ),
                    tooltip: 'Sao chép thông tin lỗi',
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          
          // Spacing between header and content
          if ((title != null || icon != null) && errorMessage.isNotEmpty)
            const SizedBox(height: 12),
          
          // Error message content
          if (errorMessage.isNotEmpty)
            SelectableText(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor ?? colorScheme.onErrorContainer,
              ),
            ),
          
          // Copy button at bottom if no header
          if (showCopyButton && title == null && icon == null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _copyToClipboard(context),
                  icon: const Icon(Icons.copy),
                  label: const Text('Sao chép'),
                  style: TextButton.styleFrom(
                    foregroundColor: textColor ?? colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A dialog that displays a copyable error message
class CopyableErrorDialog extends StatelessWidget {
  final String errorMessage;
  final String title;
  final IconData? icon;

  const CopyableErrorDialog({
    super.key,
    required this.errorMessage,
    required this.title,
    this.icon,
  });

  static Future<void> show(
    BuildContext context, {
    required String errorMessage,
    required String title,
    IconData? icon,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CopyableErrorDialog(
        errorMessage: errorMessage,
        title: title,
        icon: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon),
            const SizedBox(width: 8),
          ],
          Expanded(child: Text(title)),
        ],
      ),
      content: SingleChildScrollView(
        child: CopyableErrorWidget(
          errorMessage: errorMessage,
          showCopyButton: true,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }
}

/// Extension methods for easy error display
extension ErrorDisplayExtensions on String {
  /// Show this error message in a copyable widget
  Widget toCopyableError({
    String? title,
    IconData? icon,
    Color? backgroundColor,
  }) {
    return CopyableErrorWidget(
      errorMessage: this,
      title: title,
      icon: icon,
      backgroundColor: backgroundColor,
    );
  }

  /// Show this error message in a dialog
  Future<void> showAsErrorDialog(
    BuildContext context, {
    String title = 'Lỗi',
    IconData? icon,
  }) {
    return CopyableErrorDialog.show(
      context,
      errorMessage: this,
      title: title,
      icon: icon,
    );
  }
}