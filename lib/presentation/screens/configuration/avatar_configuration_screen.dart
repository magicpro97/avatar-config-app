// Avatar Configuration Screen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../domain/entities/avatar_configuration.dart';
import '../../../domain/entities/personality.dart';
import '../../../domain/entities/voice.dart';
import '../../providers/avatar_provider.dart';
import '../personality_selection_screen.dart';
import '../voice_selection_screen.dart';
import '../../widgets/personality_card.dart';
import '../../theme/colors.dart';
import '../../widgets/common/copyable_error_widget.dart';

class AvatarConfigurationScreen extends StatefulWidget {
  final AvatarConfiguration? existingConfiguration;
  final bool isEditing;

  const AvatarConfigurationScreen({
    super.key,
    this.existingConfiguration,
    this.isEditing = false,
  });

  @override
  State<AvatarConfigurationScreen> createState() =>
      _AvatarConfigurationScreenState();
}

class _AvatarConfigurationScreenState extends State<AvatarConfigurationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // DEBUG: AvatarConfigurationScreen initState
    // DEBUG: widget.isEditing: ${widget.isEditing}
    // DEBUG: widget.existingConfiguration: ${widget.existingConfiguration?.toString() ?? 'null'}
    // DEBUG: widget.existingConfiguration?.id: ${widget.existingConfiguration?.id ?? 'null'}

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.existingConfiguration != null) {
      _loadExistingConfiguration();
    }

    // Thêm listener để cập nhật trạng thái nút "Tiếp tục" khi nhập liệu
    _nameController.addListener(() {
      if (mounted) {
        setState(() {
          // Trigger rebuild để cập nhật trạng thái nút
        });
      }
    });

    // Thêm listener cho description controller (tùy chọn)
    _descriptionController.addListener(() {
      if (mounted) {
        setState(() {
          // Trigger rebuild để cập nhật UI
        });
      }
    });

    _animationController.forward();
  }

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Personality? _selectedPersonality;
  VoiceConfiguration? _selectedVoice;
  bool _isActive = false;
  int _currentStep = 0;
  bool _isLoading = false;

  final List<String> _stepTitles = [
    'Thông tin cơ bản',
    'Chọn tính cách',
    'Cài đặt giọng nói',
    'Xem trước & Lưu',
  ];

  void _loadExistingConfiguration() {
    final config = widget.existingConfiguration!;
    print('DEBUG: _loadExistingConfiguration called');
    print('DEBUG: Config name: ${config.name}');
    print('DEBUG: Config personalityType: ${config.personalityType}');
    print(
      'DEBUG: Config personalityType.runtimeType: ${config.personalityType.runtimeType}',
    );

    _nameController.text = config.name;
    _isActive = config.isActive;

    // Find the personality by type
    _selectedPersonality = Personality.getByType(config.personalityType);
    print(
      'DEBUG: After Personality.getByType - _selectedPersonality: ${_selectedPersonality?.type.name ?? 'null'}',
    );
    print(
      'DEBUG: _selectedPersonality type: ${_selectedPersonality?.type.runtimeType}',
    );
    _selectedVoice = config.voiceConfiguration;

    print('DEBUG: _loadExistingConfiguration completed');
    print(
      'DEBUG: Final _selectedPersonality: ${_selectedPersonality?.type.name ?? 'null'}',
    );
    print('DEBUG: Final _selectedVoice: ${_selectedVoice?.name ?? 'null'}');
    print('DEBUG: Final _isActive: $_isActive');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _stepTitles.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _openPersonalitySelection() async {
    print('DEBUG: _openPersonalitySelection called');
    print(
      'DEBUG: Current _selectedPersonality: ${_selectedPersonality?.type.name ?? 'null'}',
    );

    final result = await Navigator.of(context).push<Personality>(
      MaterialPageRoute(
        builder: (context) => PersonalitySelectionScreen(
          initialPersonality: _selectedPersonality,
        ),
      ),
    );

    print(
      'DEBUG: Returned from PersonalitySelectionScreen: ${result?.type.name ?? 'null'}',
    );

    if (result != null) {
      print('DEBUG: Setting new personality: ${result.type.name}');
      setState(() {
        _selectedPersonality = result;
      });
      print(
        'DEBUG: After setState - _selectedPersonality: ${_selectedPersonality?.type.name ?? 'null'}',
      );
      HapticFeedback.lightImpact();

      // Show feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn tính cách: ${result.displayName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      print('DEBUG: No personality selected, result is null');
    }
  }

  void _openVoiceSelection() async {
    print('DEBUG: _openVoiceSelection called');
    print('DEBUG: Current _selectedVoice: ${_selectedVoice?.name ?? 'null'}');

    try {
      // Use MaterialPageRoute for proper navigation
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VoiceSelectionScreen(
            initialVoice: _selectedVoice,
            onVoiceSelected: (voice) {
              print('DEBUG: Voice selected callback: ${voice?.name ?? 'null'}');
              // Update the state when voice is selected
              if (mounted && voice != null) {
                setState(() {
                  _selectedVoice = voice;
                });
                print(
                  'DEBUG: After setState - _selectedVoice: ${_selectedVoice?.name ?? 'null'}',
                );
                HapticFeedback.lightImpact();
              }
            },
          ),
        ),
      );

      // Show feedback after returning from VoiceSelectionScreen
      if (_selectedVoice != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn giọng nói: ${_selectedVoice!.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lỗi chọn giọng nói: Nhấn "Chi tiết" để xem và sao chép',
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    CopyableErrorDialog.show(
                      context,
                      errorMessage: e.toString(),
                      title: 'Lỗi chọn giọng nói',
                      icon: Icons.mic_off,
                    );
                  },
                  child: const Text(
                    'Chi tiết',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveConfiguration() async {
    // DEBUG: _saveConfiguration called
    // DEBUG: Form key: $_formKey
    // DEBUG: Form current state: ${_formKey.currentState}

    try {
      // Bypass form validation and do direct field validation
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Lỗi xác thực'),
              ],
            ),
            content: CopyableErrorWidget.validationError(
              errorMessage: 'Vui lòng nhập tên cấu hình',
              title: 'Lỗi xác thực',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        return;
      }
      if (name.length < 2) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Lỗi xác thực'),
              ],
            ),
            content: CopyableErrorWidget.validationError(
              errorMessage: 'Tên cấu hình phải có ít nhất 2 ký tự',
              title: 'Lỗi xác thực',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        return;
      }

      if (_selectedPersonality == null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                SizedBox(width: 8),
                Text('Lỗi xác thực'),
              ],
            ),
            content: CopyableErrorWidget.validationError(
              errorMessage: 'Vui lòng chọn tính cách',
              title: 'Lỗi xác thực',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _isLoading = true;
      });
    } catch (e) {
      // DEBUG: Error in save configuration: $e
      _showSnackBar('Lỗi: Nhấn "Chi tiết" để xem và sao chép', isError: true);
      // Show detailed error dialog
      if (mounted) {
        CopyableErrorDialog.show(
          context,
          errorMessage: e.toString(),
          title: 'Lỗi lưu cấu hình',
          icon: Icons.error,
        );
      }
      return;
    }

    try {
      final avatarProvider = context.read<AvatarProvider>();

      // Validate name field
      final name = _nameController.text.trim();
      if (name.isEmpty) {
        _showSnackBar('Vui lòng nhập tên cấu hình', isError: true);
        return;
      }

      // Use selected voice or create a default one
      final voiceConfiguration =
          _selectedVoice ??
          const VoiceConfiguration(
            voiceId: 'default_voice',
            name: 'Default Voice',
            gender: Gender.neutral,
            language: 'Vietnamese',
            accent: 'Northern',
            settings: VoiceSettings.defaultSettings,
          );

      // Validate editing scenario
      if (widget.isEditing && widget.existingConfiguration == null) {
        throw Exception(
          'Cannot edit configuration: existingConfiguration is null',
        );
      }

      // Generate ID based on editing state
      final String configurationId;
      if (widget.isEditing) {
        // When editing, use the existing configuration ID directly
        configurationId = widget.existingConfiguration!.id;
      } else {
        // When creating new, generate timestamp-based ID
        configurationId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      // DEBUG: Log the selected personality and voice before saving
      print('DEBUG: Selected personality: ${_selectedPersonality?.type}');
      print(
        'DEBUG: Selected personality type: ${_selectedPersonality?.type.runtimeType}',
      );
      print(
        'DEBUG: Selected personality name: ${_selectedPersonality?.type.name}',
      );
      print(
        'DEBUG: Selected voice: ${voiceConfiguration.voiceId} - ${voiceConfiguration.name}',
      );
      print('DEBUG: Voice language: ${voiceConfiguration.language}');
      print('DEBUG: Voice accent: ${voiceConfiguration.accent}');

      final configuration = AvatarConfiguration(
        id: configurationId,
        name: name,
        personalityType: _selectedPersonality!.type,
        voiceConfiguration: voiceConfiguration,
        isActive: _isActive,
        createdAt: widget.isEditing && widget.existingConfiguration != null
            ? widget.existingConfiguration!.createdAt
            : DateTime.now(),
        lastModified: DateTime.now(),
      );

      // DEBUG: Log the final configuration
      print(
        'DEBUG: Final configuration - Personality: ${configuration.personalityType}',
      );
      print(
        'DEBUG: Final configuration - Personality type: ${configuration.personalityType.runtimeType}',
      );
      print(
        'DEBUG: Final configuration - Personality name: ${configuration.personalityType.name}',
      );
      print(
        'DEBUG: Final configuration - Voice: ${configuration.voiceConfiguration.name}',
      );

      bool success;
      try {
        print('DEBUG: About to save configuration to AvatarProvider');
        print(
          'DEBUG: Configuration to save - isActive: ${configuration.isActive}',
        );
        print(
          'DEBUG: Configuration to save - personalityType: ${configuration.personalityType}',
        );
        print(
          'DEBUG: Configuration to save - voice: ${configuration.voiceConfiguration.name}',
        );

        if (widget.isEditing) {
          print('DEBUG: Updating existing configuration');
          success = await avatarProvider.updateConfiguration(configuration);
        } else {
          print('DEBUG: Creating new configuration');
          success = await avatarProvider.createConfiguration(configuration);
        }

        print('DEBUG: Save operation result: $success');
      } catch (e) {
        print('ERROR: Exception during save operation: $e');
        _showSnackBar(
          'Lỗi khi lưu cấu hình: Nhấn "Chi tiết" để xem và sao chép',
          isError: true,
        );
        // Show detailed error dialog
        if (mounted) {
          CopyableErrorDialog.show(
            context,
            errorMessage: e.toString(),
            title: 'Lỗi lưu cấu hình',
            icon: Icons.error,
          );
        }
        return;
      }

      if (success) {
        _showSnackBar(
          widget.isEditing ? 'Đã cập nhật cấu hình' : 'Đã tạo cấu hình mới',
          isError: false,
        );

        // Wait a bit for the snackbar to show, then navigate back
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.of(context).pop(configuration);
        }
      } else {
        _showSnackBar(
          'Không thể lưu cấu hình. Vui lòng thử lại.',
          isError: true,
        );
      }
    } catch (e) {
      _showSnackBar(
        'Đã xảy ra lỗi: Nhấn "Chi tiết" để xem và sao chép',
        isError: true,
      );
      // Show detailed error dialog
      if (mounted) {
        CopyableErrorDialog.show(
          context,
          errorMessage: e.toString(),
          title: 'Lỗi hệ thống',
          icon: Icons.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(
    String message, {
    required bool isError,
    String? errorTitle,
    IconData? errorIcon,
  }) {
    if (isError && message.contains('Nhấn "Chi tiết"')) {
      // Already has copy functionality
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Theme.of(context).colorScheme.error
              : Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (isError) {
      // Add copy functionality to regular errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('$message: Nhấn "Chi tiết" để xem và sao chép'),
              ),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  CopyableErrorDialog.show(
                    context,
                    errorMessage: message,
                    title: errorTitle ?? 'Lỗi hệ thống',
                    icon: errorIcon ?? Icons.error,
                  );
                },
                child: const Text(
                  'Chi tiết',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      // Regular success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Chỉnh sửa cấu hình' : 'Tạo cấu hình mới',
        ),
        elevation: 0,
        actions: [
          if (_currentStep == _stepTitles.length - 1)
            TextButton(
              onPressed: _isLoading ? null : _saveConfiguration,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('LỰU'),
            ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Step indicator
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: List.generate(
                  _stepTitles.length,
                  (index) => Expanded(
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= _currentStep
                                ? colorScheme.primary
                                : colorScheme.outline,
                          ),
                          child: Center(
                            child: index < _currentStep
                                ? Icon(
                                    Icons.check,
                                    size: 18,
                                    color: colorScheme.onPrimary,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: index <= _currentStep
                                          ? colorScheme.onPrimary
                                          : colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stepTitles[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: index <= _currentStep
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: index == _currentStep
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const Divider(),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildBasicInfoStep(),
                  _buildPersonalityStep(),
                  _buildVoiceStep(),
                  _buildPreviewStep(),
                ],
              ),
            ),

            // Navigation buttons
            // Nút "Tiếp tục" được enable/disable dựa trên _canProceedToNextStep()
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    offset: const Offset(0, -2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        child: const Text('Quay lại'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep == _stepTitles.length - 1
                          ? (_isLoading ? null : _saveConfiguration)
                          : _canProceedToNextStep()
                          ? _nextStep
                          : null,
                      child: _currentStep == _stepTitles.length - 1
                          ? (_isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Lưu cấu hình'))
                          : const Text('Tiếp tục'),
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

  /// Kiểm tra xem có thể chuyển sang bước tiếp theo hay không
  /// Bước 0: Chỉ cần tên cấu hình (>= 2 ký tự)
  /// Bước 1: Cần chọn tính cách
  /// Bước 2: Luôn có thể tiếp tục (giọng nói là tùy chọn)
  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        // Chỉ cần tên cấu hình để tiếp tục, mô tả và trạng thái active là tùy chọn
        final canProceed =
            _nameController.text.trim().isNotEmpty &&
            _nameController.text.trim().length >= 2;
        // Debug: Log validation state
        print(
          'DEBUG: Step 0 validation - Name: "${_nameController.text.trim()}", Length: ${_nameController.text.trim().length}, Can proceed: $canProceed',
        );
        return canProceed;
      case 1:
        final canProceed = _selectedPersonality != null;
        print(
          'DEBUG: Step 0 validation - Personality selected: ${_selectedPersonality != null}, Can proceed: $canProceed',
        );
        return canProceed;
      case 2:
        print(
          'DEBUG: Step 2 validation - Voice step is optional, Can proceed: true',
        );
        return true; // Voice step is optional
      default:
        return true;
    }
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin cơ bản',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Đặt tên và mô tả cho cấu hình avatar của bạn',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Tên cấu hình *',
                hintText: 'VD: Avatar Chính, Bot Hỗ Trợ...',
                prefixIcon: const Icon(Icons.person),
                suffixIcon:
                    _nameController.text.trim().isNotEmpty &&
                        _nameController.text.trim().length >= 2
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Vui lòng nhập tên cấu hình';
                }
                if (value.trim().length < 2) {
                  return 'Tên cấu hình phải có ít nhất 2 ký tự';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 24),

            // Thông báo về điều kiện để tiếp tục
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _canProceedToNextStep()
                    ? Theme.of(
                        context,
                      ).colorScheme.primaryContainer.withValues(alpha: 0.2)
                    : Theme.of(context).colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _canProceedToNextStep()
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.5)
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _canProceedToNextStep()
                        ? Icons.check_circle
                        : Icons.info_outline,
                    size: 16,
                    color: _canProceedToNextStep()
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _canProceedToNextStep()
                          ? '✓ Sẵn sàng tiếp tục!'
                          : 'Nút "Tiếp tục" sẽ được kích hoạt khi bạn nhập tên cấu hình (ít nhất 2 ký tự)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _canProceedToNextStep()
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: _canProceedToNextStep()
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description field (tùy chọn - không ảnh hưởng đến việc enable nút "Tiếp tục")
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Mô tả (tùy chọn)',
                hintText: 'Mô tả ngắn gọn về cấu hình này...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),

            const SizedBox(height: 24),

            // Active toggle (không ảnh hưởng đến việc enable nút "Tiếp tục")
            SwitchListTile(
              title: const Text('Đặt làm cấu hình hoạt động'),
              subtitle: const Text('Cấu hình này sẽ được sử dụng mặc định'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              secondary: const Icon(Icons.star),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chọn tính cách',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn tính cách phù hợp cho avatar của bạn',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Debug info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Debug Info',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Selected Personality: ${_selectedPersonality?.type.name ?? 'null'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Personality Type: ${_selectedPersonality?.type.runtimeType}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selected personality preview
          if (_selectedPersonality != null) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: PersonalityCard(
                personality: _selectedPersonality!,
                isSelected: true,
                showDescription: true,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Browse button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openPersonalitySelection,
              icon: Icon(
                _selectedPersonality == null ? Icons.add : Icons.edit,
                color: _selectedPersonality == null
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
              label: Text(
                _selectedPersonality == null
                    ? 'Chọn tính cách'
                    : 'Thay đổi tính cách',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _selectedPersonality == null
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedPersonality == null
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          if (_selectedPersonality == null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.errorContainer,
                    Theme.of(
                      context,
                    ).colorScheme.errorContainer.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chưa chọn tính cách',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onErrorContainer,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Vui lòng chọn một tính cách để tiếp tục',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer
                                        .withOpacity(0.8),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openPersonalitySelection,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Chọn tính cách ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceStep() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cài đặt giọng nói',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chọn giọng nói phù hợp cho avatar của bạn',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Debug info for voice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bug_report,
                      size: 16,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Debug Info - Voice',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Selected Voice: ${_selectedVoice?.name ?? 'null'}',
                  style: theme.textTheme.bodySmall,
                ),
                Text(
                  'Voice ID: ${_selectedVoice?.voiceId ?? 'null'}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Selected voice preview
          if (_selectedVoice != null) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.secondary.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Card(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              _selectedVoice!.gender == Gender.male
                                  ? Icons.male
                                  : _selectedVoice!.gender == Gender.female
                                  ? Icons.female
                                  : Icons.person,
                              color: colorScheme.onSecondary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedVoice!.name,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_selectedVoice!.language} - ${_selectedVoice!.accent}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.secondary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.check_circle,
                              color: colorScheme.onSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Voice parameters preview
                      Row(
                        children: [
                          Expanded(
                            child: _buildParameterChip(
                              'Ổn định',
                              '${(_selectedVoice!.settings.stability * 100).round()}%',
                              Icons.balance,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildParameterChip(
                              'Giống',
                              '${(_selectedVoice!.settings.similarityBoost * 100).round()}%',
                              Icons.tune,
                              theme,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildParameterChip(
                              'Phong cách',
                              '${(_selectedVoice!.settings.style * 100).round()}%',
                              Icons.style,
                              theme,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Voice selection button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openVoiceSelection,
              icon: Icon(
                _selectedVoice == null ? Icons.mic : Icons.edit,
                color: _selectedVoice == null
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondary,
              ),
              label: Text(
                _selectedVoice == null
                    ? 'Chọn giọng nói'
                    : 'Thay đổi giọng nói',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _selectedVoice == null
                      ? colorScheme.onPrimary
                      : colorScheme.onSecondary,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedVoice == null
                    ? colorScheme.primary
                    : colorScheme.secondary,
                foregroundColor: _selectedVoice == null
                    ? colorScheme.onPrimary
                    : colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Use default voice option
          if (_selectedVoice == null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainerHighest.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.mic,
                      size: 32,
                      color: colorScheme.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sử dụng giọng mặc định',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn có thể tiếp tục mà không chọn giọng nói. Hệ thống sẽ sử dụng giọng mặc định.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openVoiceSelection,
                      icon: const Icon(Icons.mic_external_on),
                      label: const Text('Chọn giọng nói ngay'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Info card about voice selection
          Card(
            color: colorScheme.primaryContainer.withValues(alpha: 0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lưu ý về giọng nói',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Giọng nói có thể được tùy chỉnh sau khi tạo cấu hình. Bạn có thể thử nghiệm và điều chỉnh các thông số để tìm ra giọng phù hợp nhất.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterChip(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xem trước & Lưu',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Kiểm tra lại thông tin cấu hình trước khi lưu',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // Configuration preview card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _nameController.text.trim(),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (_isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Hoạt động',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Personality
                  if (_selectedPersonality != null) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          size: 20,
                          color: AppColors.getPersonalityColor(
                            _selectedPersonality!.type.name,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tính cách: ${_selectedPersonality!.displayName}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedPersonality!.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Voice info
                  Row(
                    children: [
                      Icon(
                        Icons.mic,
                        size: 20,
                        color: _selectedVoice != null
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Giọng nói: ${_selectedVoice?.name ?? "Mặc định"}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  if (_selectedVoice != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${_selectedVoice!.language} - ${_selectedVoice!.accent}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Validation warnings
          if (_selectedPersonality == null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chưa chọn tính cách. Quay lại bước 2 để chọn tính cách.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
