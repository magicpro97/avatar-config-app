import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../domain/entities/voice.dart';
import '../../core/utils/platform_utils.dart';
import '../providers/voice_provider.dart';
import '../widgets/voice_parameter_slider.dart';
import '../widgets/voice_gender_selector.dart';
import '../widgets/voice_accent_selector.dart';
import '../widgets/voice_language_selector.dart';
import '../widgets/common/copyable_error_widget.dart';

class VoiceSelectionScreen extends StatefulWidget {
  final VoiceConfiguration? initialVoice;
  final Function(VoiceConfiguration?)? onVoiceSelected;

  const VoiceSelectionScreen({
    super.key,
    this.initialVoice,
    this.onVoiceSelected,
  });

  @override
  State<VoiceSelectionScreen> createState() => _VoiceSelectionScreenState();
}

class _VoiceSelectionScreenState extends State<VoiceSelectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AudioPlayer _audioPlayer;
  
  // Voice preview state
  String _previewText = 'Xin chào, tôi là avatar của bạn. Tôi có thể nói tiếng Việt và tiếng Anh rất tự nhiên.';
  bool _isPlaying = false;
  bool _isPaused = false;
  double _playbackSpeed = 1.0;
  double _volume = 1.0;
  
  // Extended voice parameters for more control
  double _pitch = 1.0;
  double _speed = 1.0;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _audioPlayer = AudioPlayer();
    
    // Initialize voice provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final voiceProvider = Provider.of<VoiceProvider>(context, listen: false);
      if (voiceProvider.loadingState == VoiceLoadingState.initial) {
        voiceProvider.loadAvailableVoices();
      }
      
      // Set initial voice if provided
      if (widget.initialVoice != null) {
        final voice = voiceProvider.getVoiceById(widget.initialVoice!.voiceId);
        if (voice != null) {
          voiceProvider.selectVoice(voice);
        }
      }
    });
    
    // Listen to audio player events
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isPaused = state == PlayerState.paused;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn giọng nói'),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        actions: [
          // Refresh voices
          Consumer<VoiceProvider>(
            builder: (context, voiceProvider, child) {
              return IconButton(
                onPressed: voiceProvider.isLoading 
                    ? null 
                    : () => voiceProvider.refresh(),
                icon: voiceProvider.isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onSurface,
                        ),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Cập nhật danh sách giọng',
              );
            },
          ),
          
          // Help/Info
          IconButton(
            onPressed: _showHelpDialog,
            icon: const Icon(Icons.help_outline),
            tooltip: 'Hướng dẫn',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.record_voice_over),
              text: 'Chọn giọng',
            ),
            Tab(
              icon: Icon(Icons.tune),
              text: 'Điều chỉnh',
            ),
            Tab(
              icon: Icon(Icons.play_arrow),
              text: 'Thử nghiệm',
            ),
          ],
        ),
      ),
      
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Voice Selection
          _buildVoiceSelectionTab(),
          
          // Tab 2: Voice Parameters
          _buildVoiceParametersTab(),
          
          // Tab 3: Voice Preview
          _buildVoicePreviewTab(),
        ],
      ),
      
      // Bottom action bar
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildVoiceSelectionTab() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        if (voiceProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        if (voiceProvider.hasError) {
          return _buildErrorState(voiceProvider.errorMessage!);
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar
              _buildSearchBar(voiceProvider),
              
              const SizedBox(height: 16),
              
              // Filters
              _buildFiltersSection(voiceProvider),
              
              const SizedBox(height: 16),
              
              // Voice statistics
              if (voiceProvider.hasVoices)
                _buildVoiceStats(voiceProvider),
              
              const SizedBox(height: 16),
              
              // Voice list
              _buildVoiceList(voiceProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(
              Icons.search,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm giọng nói...',
                  border: InputBorder.none,
                ),
                onChanged: voiceProvider.searchVoices,
              ),
            ),
            if (voiceProvider.searchQuery.isNotEmpty)
              IconButton(
                onPressed: () => voiceProvider.searchVoices(''),
                icon: const Icon(Icons.clear),
                tooltip: 'Xóa tìm kiếm',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersSection(VoiceProvider voiceProvider) {
    return Column(
      children: [
        // Gender selector
        CompactVoiceGenderSelector(
          selectedGender: voiceProvider.genderFilter,
          onGenderChanged: voiceProvider.filterByGender,
        ),
        
        const SizedBox(height: 12),
        
        // Language and accent selectors
        Row(
          children: [
            Expanded(
              child: CompactVoiceLanguageSelector(
                availableLanguages: voiceProvider.getAvailableLanguages(),
                selectedLanguage: voiceProvider.languageFilter,
                onLanguageChanged: voiceProvider.filterByLanguage,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CompactVoiceAccentSelector(
                availableAccents: voiceProvider.languageFilter != null
                    ? voiceProvider.getAvailableAccents(voiceProvider.languageFilter!)
                    : [],
                selectedAccent: voiceProvider.accentFilter,
                onAccentChanged: voiceProvider.filterByAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceStats(VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.analytics,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thống kê giọng nói',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${voiceProvider.filteredVoiceCount} giọng được tìm thấy / ${voiceProvider.voiceCount} tổng cộng',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (voiceProvider.searchQuery.isNotEmpty || 
                voiceProvider.genderFilter != null ||
                voiceProvider.languageFilter != null ||
                voiceProvider.accentFilter != null)
              TextButton.icon(
                onPressed: voiceProvider.clearFilters,
                icon: const Icon(Icons.clear_all),
                label: const Text('Xóa bộ lọc'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceList(VoiceProvider voiceProvider) {
    if (voiceProvider.filteredVoices.isEmpty) {
      return _buildEmptyState();
    }
    
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: voiceProvider.filteredVoices.length,
      itemBuilder: (context, index) {
        final voice = voiceProvider.filteredVoices[index];
        final isSelected = voiceProvider.selectedVoice?.voiceId == voice.voiceId;
        
        return _buildVoiceCard(voice, isSelected, voiceProvider);
      },
    );
  }

  Widget _buildVoiceCard(ElevenLabsVoice voice, bool isSelected, VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected 
          ? colorScheme.primaryContainer.withValues(alpha: 0.3) 
          : null,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: isSelected 
              ? colorScheme.primary 
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            voice.gender == Gender.male 
                ? Icons.male 
                : voice.gender == Gender.female 
                    ? Icons.female 
                    : Icons.person,
            color: isSelected 
                ? colorScheme.onPrimary 
                : colorScheme.onSurfaceVariant,
          ),
        ),
        
        title: Text(
          voice.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.language,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text('${voice.language} - ${voice.accent}'),
              ],
            ),
            if (voice.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                voice.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Preview button
            if (voice.previewUrl != null)
              IconButton(
                onPressed: () => _playVoicePreview(voice.previewUrl!),
                icon: const Icon(Icons.play_circle_outline),
                tooltip: 'Nghe thử',
              ),
            
            // Selection indicator
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
              ),
          ],
        ),
        
        onTap: () => voiceProvider.selectVoice(voice),
      ),
    );
  }

  Widget _buildVoiceParametersTab() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        if (voiceProvider.selectedVoice == null) {
          return _buildNoVoiceSelectedState();
        }
        
        final settings = voiceProvider.currentSettings;
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected voice info
              _buildSelectedVoiceInfo(voiceProvider.selectedVoice!),
              
              const SizedBox(height: 24),
              
              // ElevenLabs parameters
              VoiceStabilitySlider(
                value: settings.stability,
                onChanged: (value) => _updateVoiceSettings(
                  settings.copyWith(stability: value),
                  voiceProvider,
                ),
              ),
              
              const SizedBox(height: 16),
              
              VoiceSimilarityBoostSlider(
                value: settings.similarityBoost,
                onChanged: (value) => _updateVoiceSettings(
                  settings.copyWith(similarityBoost: value),
                  voiceProvider,
                ),
              ),
              
              const SizedBox(height: 16),
              
              VoiceStyleSlider(
                value: settings.style,
                onChanged: (value) => _updateVoiceSettings(
                  settings.copyWith(style: value),
                  voiceProvider,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Additional parameters
              VoicePitchSlider(
                value: _pitch,
                onChanged: (value) => setState(() => _pitch = value),
              ),
              
              const SizedBox(height: 16),
              
              VoiceSpeedSlider(
                value: _speed,
                onChanged: (value) => setState(() => _speed = value),
              ),
              
              const SizedBox(height: 16),
              
              VoiceVolumeSlider(
                value: _volume,
                onChanged: (value) => setState(() => _volume = value),
              ),
              
              const SizedBox(height: 24),
              
              // Speaker boost toggle
              _buildSpeakerBoostToggle(settings, voiceProvider),
              
              const SizedBox(height: 16),
              
              // Reset to defaults button
              _buildResetButton(voiceProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectedVoiceInfo(ElevenLabsVoice voice) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary,
              child: Icon(
                voice.gender == Gender.male 
                    ? Icons.male 
                    : voice.gender == Gender.female 
                        ? Icons.female 
                        : Icons.person,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voice.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${voice.language} - ${voice.accent}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakerBoostToggle(VoiceSettings settings, VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: SwitchListTile(
        title: const Text('Tăng cường chất lượng giọng (Speaker Boost)'),
        subtitle: const Text('Cải thiện chất lượng âm thanh nhưng có thể tăng độ trễ'),
        value: settings.useSpeakerBoost,
        onChanged: (value) => _updateVoiceSettings(
          settings.copyWith(useSpeakerBoost: value),
          voiceProvider,
        ),
        activeColor: colorScheme.primary,
      ),
    );
  }

  Widget _buildResetButton(VoiceProvider voiceProvider) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _resetToDefaults(voiceProvider),
        icon: const Icon(Icons.restore),
        label: const Text('Khôi phục cài đặt mặc định'),
      ),
    );
  }

  Widget _buildVoicePreviewTab() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        if (voiceProvider.selectedVoice == null) {
          return _buildNoVoiceSelectedState();
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selected voice info
              _buildSelectedVoiceInfo(voiceProvider.selectedVoice!),
              
              const SizedBox(height: 24),
              
              // Preview text input
              _buildPreviewTextInput(),
              
              const SizedBox(height: 24),
              
              // Audio controls
              _buildAudioControls(voiceProvider),
              
              const SizedBox(height: 24),
              
              // Quick test phrases
              _buildQuickTestPhrases(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviewTextInput() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Văn bản thử nghiệm',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Nhập văn bản để thử nghiệm giọng nói...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
              onChanged: (value) => setState(() => _previewText = value),
              controller: TextEditingController(text: _previewText),
            ),
            const SizedBox(height: 8),
            Text(
              'Độ dài: ${_previewText.length} ký tự',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls(VoiceProvider voiceProvider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Play/Pause button
                ElevatedButton.icon(
                  onPressed: _previewText.trim().isEmpty 
                      ? null 
                      : () => _playVoiceSynthesis(voiceProvider),
                  icon: Icon(_isPlaying 
                      ? Icons.pause 
                      : _isPaused 
                          ? Icons.play_arrow 
                          : Icons.play_arrow),
                  label: Text(_isPlaying 
                      ? 'Tạm dừng' 
                      : _isPaused 
                          ? 'Tiếp tục' 
                          : 'Phát'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                ),
                
                // Stop button
                ElevatedButton.icon(
                  onPressed: _isPlaying || _isPaused 
                      ? _stopAudio 
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Dừng'),
                ),
                
                // Generate button
                ElevatedButton.icon(
                  onPressed: voiceProvider.isSynthesizing || _previewText.trim().isEmpty
                      ? null
                      : () => _generateVoice(voiceProvider),
                  icon: voiceProvider.isSynthesizing 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(Icons.record_voice_over),
                  label: const Text('Tạo giọng'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Playback controls
            Row(
              children: [
                Icon(
                  Icons.speed,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _playbackSpeed,
                    min: 0.5,
                    max: 2.0,
                    divisions: 6,
                    label: '${_playbackSpeed.toStringAsFixed(1)}x',
                    onChanged: (value) => setState(() => _playbackSpeed = value),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.volume_up,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Slider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).round()}%',
                    onChanged: (value) => setState(() => _volume = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickTestPhrases() {
    final quickPhrases = [
      'Xin chào, tôi là trợ lý ảo của bạn.',
      'Hôm nay thời tiết thế nào?',
      'Bạn cần tôi giúp gì không?',
      'Hello, I am your virtual assistant.',
      'How can I help you today?',
      'Thank you for using our service.',
    ];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Câu thử nghiệm nhanh',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickPhrases.map((phrase) {
                return ActionChip(
                  label: Text(phrase),
                  onPressed: () => setState(() => _previewText = phrase),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Consumer<VoiceProvider>(
      builder: (context, voiceProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Voice info
              if (voiceProvider.hasSelectedVoice) ...[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đã chọn: ${voiceProvider.selectedVoice!.name}',
                        style: Theme.of(context).textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${voiceProvider.selectedVoice!.language} - ${voiceProvider.selectedVoice!.accent}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
              
              // Action buttons
              if (voiceProvider.hasSelectedVoice)
                ElevatedButton(
                  onPressed: () => _confirmSelection(voiceProvider),
                  child: const Text('Xác nhận'),
                )
              else
                ElevatedButton(
                  onPressed: null,
                  child: const Text('Chọn giọng nói'),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display copyable error widget
            CopyableErrorWidget.apiError(
              errorMessage: error,
              title: 'Lỗi tải danh sách giọng nói',
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Provider.of<VoiceProvider>(context, listen: false).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _showErrorDetailDialog(error),
                  icon: const Icon(Icons.info_outline),
                  label: const Text('Chi tiết'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.voice_over_off,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy giọng nói',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Thử điều chỉnh bộ lọc hoặc tìm kiếm với từ khóa khác',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoVoiceSelectedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.record_voice_over,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa chọn giọng nói',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng chọn một giọng nói từ tab "Chọn giọng"',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(0),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Chọn giọng nói'),
            ),
          ],
        ),
      ),
    );
  }

  // Audio and voice functions
  Future<void> _playVoicePreview(String previewUrl) async {
    try {
      await _audioPlayer.play(UrlSource(previewUrl));
    } catch (e) {
      if (mounted) {
        _showAudioPlaybackError(e.toString());
      }
    }
  }

  Future<void> _playVoiceSynthesis(VoiceProvider voiceProvider) async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else if (_isPaused) {
      await _audioPlayer.resume();
    } else {
      await _generateVoice(voiceProvider);
    }
  }

  Future<void> _generateVoice(VoiceProvider voiceProvider) async {
    if (_previewText.trim().isEmpty) return;
    
    try {
      final audioData = await voiceProvider.synthesizeText(_previewText);
      if (audioData != null && mounted) {
        if (PlatformUtils.isWeb) {
          // On web, create a data URL for audio playback
          final audioBlob = Uri.dataFromBytes(audioData, mimeType: 'audio/mp3');
          await _audioPlayer.play(
            UrlSource(audioBlob.toString()),
            volume: _volume,
          );
          await _audioPlayer.setPlaybackRate(_playbackSpeed);
        } else {
          // On mobile/desktop, save to temporary file and play
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/voice_preview.mp3');
          await tempFile.writeAsBytes(audioData);
          
          await _audioPlayer.play(
            DeviceFileSource(tempFile.path),
            volume: _volume,
          );
          await _audioPlayer.setPlaybackRate(_playbackSpeed);
        }
      }
    } catch (e) {
      if (mounted) {
        // Show detailed error with copy functionality
        _showVoiceSynthesisError(e.toString());
      }
    }
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
  }

  void _updateVoiceSettings(VoiceSettings settings, VoiceProvider voiceProvider) {
    voiceProvider.updateVoiceSettings(settings);
  }

  void _resetToDefaults(VoiceProvider voiceProvider) {
    _updateVoiceSettings(VoiceSettings.defaultSettings, voiceProvider);
    setState(() {
      _pitch = 1.0;
      _speed = 1.0;
      _volume = 1.0;
      _playbackSpeed = 1.0;
    });
  }

  void _confirmSelection(VoiceProvider voiceProvider) {
    try {
      if (!mounted) return;
      
      if (!voiceProvider.hasSelectedVoice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng chọn một giọng nói'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final selectedVoice = voiceProvider.selectedVoice!;
      
      // Validate voice data
      if (selectedVoice.voiceId.isEmpty || selectedVoice.name.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thông tin giọng nói không hợp lệ'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Use the built-in conversion method for safety
      VoiceConfiguration voiceConfiguration;
      try {
        voiceConfiguration = selectedVoice.toVoiceConfiguration();
        
        // Override settings with current user settings
        voiceConfiguration = voiceConfiguration.copyWith(
          settings: voiceProvider.currentSettings,
        );
      } catch (conversionError) {
        // Fallback to manual creation if conversion fails
        voiceConfiguration = VoiceConfiguration(
          voiceId: selectedVoice.voiceId.isNotEmpty ? selectedVoice.voiceId : 'default_voice',
          name: selectedVoice.name.isNotEmpty ? selectedVoice.name : 'Unknown Voice',
          gender: selectedVoice.gender,
          language: selectedVoice.language.isNotEmpty ? selectedVoice.language : 'Vietnamese',
          accent: selectedVoice.accent.isNotEmpty ? selectedVoice.accent : 'Northern',
          settings: voiceProvider.currentSettings,
        );
      }
      
      // Call callback if provided - this is the key to updating the parent screen
      widget.onVoiceSelected?.call(voiceConfiguration);
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn giọng nói: ${voiceConfiguration.name}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Log the error for debugging
        debugPrint('Voice selection confirmation error: $e');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi khi xác nhận giọng nói: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hướng dẫn chọn giọng nói'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('• Tab "Chọn giọng": Chọn giọng nói từ danh sách có sẵn'),
              SizedBox(height: 8),
              Text('• Tab "Điều chỉnh": Tùy chỉnh các thông số giọng nói'),
              SizedBox(height: 8),
              Text('• Tab "Thử nghiệm": Nghe thử giọng nói với văn bản tùy chỉnh'),
              SizedBox(height: 8),
              Text('• Sử dụng bộ lọc để tìm giọng phù hợp'),
              SizedBox(height: 8),
              Text('• Điều chỉnh độ ổn định để cân bằng giữa chất lượng và biểu cảm'),
            ],
          ),
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

  // Error dialog methods
  void _showErrorDetailDialog(String error) {
    CopyableErrorDialog.show(
      context,
      errorMessage: error,
      title: 'Chi tiết lỗi giọng nói',
      icon: Icons.cloud_off,
    );
  }

  void _showAudioPlaybackError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Lỗi phát âm thanh: Nhấn "Chi tiết" để xem và sao chép')),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                CopyableErrorDialog.show(
                  context,
                  errorMessage: error,
                  title: 'Lỗi phát âm thanh',
                  icon: Icons.volume_off,
                );
              },
              child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }

  void _showVoiceSynthesisError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Lỗi tạo giọng nói: Nhấn "Chi tiết" để xem và sao chép')),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                CopyableErrorDialog.show(
                  context,
                  errorMessage: error,
                  title: 'Lỗi tạo giọng nói',
                  icon: Icons.record_voice_over,
                );
              },
              child: const Text('Chi tiết', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Đóng',
          textColor: Colors.white,
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );
  }
}