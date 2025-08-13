import 'package:flutter/material.dart';

/// Reusable confirmation dialog for destructive actions
class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;
  final Widget? icon;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Xác nhận',
    this.cancelText = 'Hủy',
    this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      icon: icon ?? (isDestructive 
        ? Icon(Icons.warning_rounded, color: theme.colorScheme.error) 
        : null),
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel ?? () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        FilledButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          style: isDestructive 
            ? FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              )
            : null,
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Show delete confirmation dialog
  static Future<bool> showDeleteDialog(
    BuildContext context, {
    required String itemName,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa cấu hình',
        content: customMessage ?? 'Bạn có chắc chắn muốn xóa cấu hình "$itemName"? '
            'Hành động này không thể hoàn tác.',
        confirmText: 'Xóa',
        isDestructive: true,
      ),
    ).then((value) => value ?? false);
  }

  /// Show batch delete confirmation dialog
  static Future<bool> showBatchDeleteDialog(
    BuildContext context, {
    required int count,
    String? customMessage,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa nhiều cấu hình',
        content: customMessage ?? 'Bạn có chắc chắn muốn xóa $count cấu hình đã chọn? '
            'Hành động này không thể hoàn tác.',
        confirmText: 'Xóa tất cả',
        isDestructive: true,
      ),
    ).then((value) => value ?? false);
  }

  /// Show export confirmation dialog
  static Future<bool> showExportDialog(
    BuildContext context, {
    required String destinationPath,
    int? count,
  }) {
    final message = count != null 
      ? 'Xuất $count cấu hình đến:\n$destinationPath'
      : 'Xuất cấu hình đến:\n$destinationPath';
    
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xuất cấu hình',
        content: message,
        confirmText: 'Xuất',
        icon: const Icon(Icons.file_download_outlined),
      ),
    ).then((value) => value ?? false);
  }

  /// Show import confirmation dialog
  static Future<bool> showImportDialog(
    BuildContext context, {
    required int count,
    String? sourcePath,
  }) {
    final message = sourcePath != null 
      ? 'Nhập $count cấu hình từ:\n$sourcePath\n\nCác cấu hình trùng tên sẽ được ghi đè.'
      : 'Nhập $count cấu hình.\n\nCác cấu hình trùng tên sẽ được ghi đè.';
    
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Nhập cấu hình',
        content: message,
        confirmText: 'Nhập',
        icon: const Icon(Icons.file_upload_outlined),
      ),
    ).then((value) => value ?? false);
  }

  /// Show clear all confirmation dialog
  static Future<bool> showClearAllDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Xóa tất cả cấu hình',
        content: 'Bạn có chắc chắn muốn xóa TẤT CẢ cấu hình? '
            'Hành động này sẽ xóa toàn bộ dữ liệu và không thể hoàn tác.',
        confirmText: 'Xóa tất cả',
        isDestructive: true,
      ),
    ).then((value) => value ?? false);
  }

  /// Show duplicate confirmation dialog
  static Future<bool> showDuplicateDialog(
    BuildContext context, {
    required String originalName,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Sao chép cấu hình',
        content: 'Tạo bản sao của cấu hình "$originalName"?',
        confirmText: 'Sao chép',
        icon: const Icon(Icons.content_copy_outlined),
      ),
    ).then((value) => value ?? false);
  }
}

/// Loading dialog for long-running operations
class LoadingDialog extends StatelessWidget {
  final String title;
  final String? message;
  final bool cancellable;
  final VoidCallback? onCancel;

  const LoadingDialog({
    super.key,
    required this.title,
    this.message,
    this.cancellable = false,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (message != null) ...[
            const SizedBox(height: 8),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: cancellable
        ? [
            TextButton(
              onPressed: onCancel ?? () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
          ]
        : null,
    );
  }

  /// Show loading dialog
  static void show(
    BuildContext context, {
    required String title,
    String? message,
    bool cancellable = false,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LoadingDialog(
        title: title,
        message: message,
        cancellable: cancellable,
        onCancel: onCancel,
      ),
    );
  }

  /// Hide loading dialog
  static void hide(BuildContext context) {
    Navigator.of(context).pop();
  }
}

/// Success dialog with auto-dismiss
class SuccessDialog extends StatefulWidget {
  final String title;
  final String message;
  final Duration duration;
  final Widget? icon;

  const SuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.duration = const Duration(seconds: 2),
    this.icon,
  });

  @override
  State<SuccessDialog> createState() => _SuccessDialogState();

  /// Show success dialog with auto-dismiss
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 2),
    Widget? icon,
  }) {
    showDialog(
      context: context,
      builder: (context) => SuccessDialog(
        title: title,
        message: message,
        duration: duration,
        icon: icon,
      ),
    );
  }
}

class _SuccessDialogState extends State<SuccessDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    
    _controller.forward();
    
    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: AlertDialog(
        icon: widget.icon ?? Icon(
          Icons.check_circle_outline,
          color: theme.colorScheme.primary,
          size: 48,
        ),
        title: Text(widget.title),
        content: Text(widget.message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}