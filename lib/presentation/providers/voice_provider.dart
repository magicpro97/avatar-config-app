// Voice Provider for State Management
import 'package:flutter/foundation.dart';
import '../../domain/entities/voice.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../data/services/audio_service.dart';
import '../../data/models/voice_model.dart' as voice_model;

enum VoiceLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class VoiceProvider extends ChangeNotifier {
  final VoiceRepository _voiceRepository;
  final AudioService _audioService;

  VoiceProvider({required VoiceRepository voiceRepository, required AudioService audioService})
      : _voiceRepository = voiceRepository,
        _audioService = audioService;

  // State
  VoiceLoadingState _loadingState = VoiceLoadingState.initial;
  List<ElevenLabsVoice> _availableVoices = [];
  List<ElevenLabsVoice> _filteredVoices = [];
  ElevenLabsVoice? _selectedVoice;
  VoiceSettings _currentSettings = VoiceSettings.defaultSettings;
  String? _errorMessage;
  bool _isSynthesizing = false;
  bool _isUpdatingSettings = false;
  String _searchQuery = '';
  
  // Audio playback state
  String? _currentAudioId;
  AudioState _audioState = AudioState.idle;
  String? _audioErrorMessage;
  Gender? _genderFilter;
  String? _languageFilter;
  String? _accentFilter;

  // Getters
  VoiceLoadingState get loadingState => _loadingState;
  List<ElevenLabsVoice> get availableVoices => List.unmodifiable(_availableVoices);
  List<ElevenLabsVoice> get filteredVoices => List.unmodifiable(_filteredVoices);
  ElevenLabsVoice? get selectedVoice => _selectedVoice;
  VoiceSettings get currentSettings => _currentSettings;
  String? get errorMessage => _errorMessage;
  bool get isSynthesizing => _isSynthesizing;
  bool get isUpdatingSettings => _isUpdatingSettings;
  
  // Audio playback getters
  String? get currentAudioId => _currentAudioId;
  AudioState get audioState => _audioState;
  String? get audioErrorMessage => _audioErrorMessage;
  bool get isAudioPlaying => _audioState == AudioState.playing;
  bool get isAudioPaused => _audioState == AudioState.paused;
  bool get isAudioLoading => _audioState == AudioState.loading;
  bool get hasAudioError => _audioState == AudioState.error;
  bool get hasVoices => _availableVoices.isNotEmpty;
  bool get hasSelectedVoice => _selectedVoice != null;
  bool get isLoading => _loadingState == VoiceLoadingState.loading;
  bool get hasError => _loadingState == VoiceLoadingState.error;
  String get searchQuery => _searchQuery;
  Gender? get genderFilter => _genderFilter;
  String? get languageFilter => _languageFilter;
  String? get accentFilter => _accentFilter;
  int get voiceCount => _availableVoices.length;
  int get filteredVoiceCount => _filteredVoices.length;

  // Load available voices
  Future<void> loadAvailableVoices({bool forceRefresh = false}) async {
    _setLoadingState(VoiceLoadingState.loading);
    _clearError();

    try {
      List<ElevenLabsVoice> voices;
      
      if (forceRefresh) {
        voices = await _voiceRepository.getAvailableVoices();
        await _voiceRepository.cacheVoices(voices);
      } else {
        // Try to load from cache first
        voices = await _voiceRepository.getCachedVoices();
        if (voices.isEmpty) {
          voices = await _voiceRepository.getAvailableVoices();
          await _voiceRepository.cacheVoices(voices);
        }
      }
      
      _availableVoices = voices;
      _applyFilters();
      _setLoadingState(VoiceLoadingState.loaded);
    } catch (e) {
      _setError('Failed to load voices: $e');
      _setLoadingState(VoiceLoadingState.error);
      
      // Try to load from cache as fallback
      try {
        _availableVoices = await _voiceRepository.getCachedVoices();
        _applyFilters();
        if (_availableVoices.isNotEmpty) {
          _setLoadingState(VoiceLoadingState.loaded);
          _setError('Using cached voices (offline mode)');
        }
      } catch (cacheError) {
        // Cache also failed, keep error state
      }
    }
  }

  // Select voice
  void selectVoice(ElevenLabsVoice? voice) {
    _selectedVoice = voice;
    if (voice?.settings != null) {
      _currentSettings = voice!.settings!;
    }
    notifyListeners();
  }

  // Update voice settings
  Future<bool> updateVoiceSettings(VoiceSettings settings) async {
    if (_selectedVoice == null) return false;

    _isUpdatingSettings = true;
    _clearError();
    notifyListeners();

    try {
      await _voiceRepository.updateVoiceSettings(_selectedVoice!.voiceId, settings);
      _currentSettings = settings;
      
      // Update the selected voice with new settings
      _selectedVoice = _selectedVoice!.copyWith(settings: settings);
      
      // Update in the main list
      final index = _availableVoices.indexWhere((v) => v.voiceId == _selectedVoice!.voiceId);
      if (index != -1) {
        _availableVoices[index] = _selectedVoice!;
        _applyFilters();
      }
      
      _isUpdatingSettings = false;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to update voice settings: $e');
      _isUpdatingSettings = false;
      notifyListeners();
      return false;
    }
  }

  // Synthesize text to speech
  Future<List<int>?> synthesizeText(String text) async {
    if (_selectedVoice == null || text.isEmpty) return null;

    _isSynthesizing = true;
    _clearError();
    notifyListeners();

    try {
      final audioData = await _voiceRepository.synthesizeText(
        text: text,
        voiceId: _selectedVoice!.voiceId,
        settings: _currentSettings,
      );
      
      _isSynthesizing = false;
      notifyListeners();
      return audioData;
    } catch (e) {
      _setError('Failed to synthesize speech: $e');
      _isSynthesizing = false;
      notifyListeners();
      return null;
    }
  }

  // Audio playback methods
  Future<String?> synthesizeAndPlayAudio(String text) async {
    if (_selectedVoice == null || text.isEmpty) return null;

    _isSynthesizing = true;
    _setAudioState(AudioState.loading);
    _clearAudioError();
    notifyListeners();

    try {
      // Use the injected audio service instance
      // Convert settings to model type
      final settingsModel = voice_model.VoiceSettingsModel(
        stability: _currentSettings.stability,
        similarityBoost: _currentSettings.similarityBoost,
        style: _currentSettings.style,
        useSpeakerBoost: _currentSettings.useSpeakerBoost,
      );
      
      // Synthesize and play audio
      final audioId = await _audioService.synthesizeAndPlay(
        text: text,
        voiceId: _selectedVoice!.voiceId,
        settings: settingsModel,
      );
      
      _currentAudioId = audioId;
      _isSynthesizing = false;
      _setAudioState(AudioState.playing);
      notifyListeners();
      
      return audioId;
    } catch (e) {
      _setError('Failed to synthesize and play audio: $e');
      _setAudioError('Failed to synthesize and play audio: $e');
      _isSynthesizing = false;
      notifyListeners();
      return null;
    }
  }

  Future<String?> playCachedAudio(String audioId) async {
    if (audioId.isEmpty) return null;

    try {
      // Play cached audio
      final newAudioId = await _audioService.playAudio(audioId);
      _currentAudioId = newAudioId;
      _setAudioState(AudioState.playing);
      notifyListeners();
      
      return newAudioId;
    } catch (e) {
      _setAudioError('Failed to play cached audio: $e');
      notifyListeners();
      return null;
    }
  }

  Future<void> pauseAudio() async {
    if (_currentAudioId == null) return;

    try {
      await _audioService.pauseAudio(_currentAudioId!);
      _setAudioState(AudioState.paused);
      notifyListeners();
    } catch (e) {
      _setAudioError('Failed to pause audio: $e');
      notifyListeners();
    }
  }

  Future<void> resumeAudio() async {
    if (_currentAudioId == null) return;

    try {
      await _audioService.resumeAudio(_currentAudioId!);
      _setAudioState(AudioState.playing);
      notifyListeners();
    } catch (e) {
      _setAudioError('Failed to resume audio: $e');
      notifyListeners();
    }
  }

  Future<void> stopAudio() async {
    if (_currentAudioId == null) return;

    try {
      await _audioService.stopAudio(_currentAudioId!);
      _currentAudioId = null;
      _setAudioState(AudioState.idle);
      notifyListeners();
    } catch (e) {
      _setAudioError('Failed to stop audio: $e');
      notifyListeners();
    }
  }

  Future<void> seekAudio(Duration position) async {
    if (_currentAudioId == null) return;

    try {
      await _audioService.seekAudio(_currentAudioId!, position);
      notifyListeners();
    } catch (e) {
      _setAudioError('Failed to seek audio: $e');
      notifyListeners();
    }
  }

  void clearAudioState() {
    _currentAudioId = null;
    _setAudioState(AudioState.idle);
    _clearAudioError();
    notifyListeners();
  }

  // Search voices
  void searchVoices(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  // Filter by gender
  void filterByGender(Gender? gender) {
    _genderFilter = gender;
    _applyFilters();
  }

  // Filter by language
  void filterByLanguage(String? language) {
    _languageFilter = language;
    _applyFilters();
  }

  // Filter by accent
  void filterByAccent(String? accent) {
    _accentFilter = accent;
    _applyFilters();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _genderFilter = null;
    _languageFilter = null;
    _accentFilter = null;
    _applyFilters();
  }

  // Get available languages
  List<String> getAvailableLanguages() {
    final languages = <String>{};
    for (final voice in _availableVoices) {
      languages.add(voice.language);
    }
    return languages.toList()..sort();
  }

  // Get available accents for a language
  List<String> getAvailableAccents(String language) {
    final accents = <String>{};
    for (final voice in _availableVoices) {
      if (voice.language == language) {
        accents.add(voice.accent);
      }
    }
    return accents.toList()..sort();
  }

  // Get voices by gender
  List<ElevenLabsVoice> getVoicesByGender(Gender gender) {
    return _availableVoices.where((voice) => voice.gender == gender).toList();
  }

  // Validate API key
  Future<bool> validateApiKey(String apiKey) async {
    try {
      return await _voiceRepository.validateApiKey(apiKey);
    } catch (e) {
      _setError('Failed to validate API key: $e');
      return false;
    }
  }

  // Get voice by ID
  ElevenLabsVoice? getVoiceById(String voiceId) {
    try {
      return _availableVoices.firstWhere((voice) => voice.voiceId == voiceId);
    } catch (e) {
      return null;
    }
  }

  // Refresh voices
  Future<void> refresh() async {
    await loadAvailableVoices(forceRefresh: true);
  }

  // Clear cache
  Future<void> clearCache() async {
    try {
      await _voiceRepository.clearVoiceCache();
      _availableVoices.clear();
      _filteredVoices.clear();
      _selectedVoice = null;
      _setLoadingState(VoiceLoadingState.initial);
    } catch (e) {
      _setError('Failed to clear cache: $e');
    }
  }

  // Get API usage information
  Future<Map<String, dynamic>> getApiUsage() async {
    try {
      return await _voiceRepository.getApiUsage();
    } catch (e) {
      _setError('Failed to get API usage: $e');
      rethrow;
    }
  }

  // Test voice synthesis
  Future<bool> testVoiceSynthesis() async {
    try {
      return await _voiceRepository.testVoiceSynthesis();
    } catch (e) {
      _setError('Voice synthesis test failed: $e');
      return false;
    }
  }

  // Get cache information
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      final cacheSize = await _voiceRepository.getCacheSize();
      final lastUpdate = await _voiceRepository.getLastCacheUpdateTime();
      
      return {
        'size': cacheSize,
        'lastUpdate': lastUpdate,
        'voiceCount': _availableVoices.length,
      };
    } catch (e) {
      return {
        'size': 0,
        'lastUpdate': null,
        'voiceCount': 0,
      };
    }
  }

  // Check if API key is configured
  Future<bool> hasApiKey() async {
    try {
      final apiKey = await _voiceRepository.validateApiKey('');
      return apiKey;
    } catch (e) {
      return false;
    }
  }

  // Private methods
  void _applyFilters() {
    List<ElevenLabsVoice> filtered = List.from(_availableVoices);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((voice) {
        return voice.name.toLowerCase().contains(query) ||
               voice.description.toLowerCase().contains(query) ||
               voice.language.toLowerCase().contains(query) ||
               voice.accent.toLowerCase().contains(query);
      }).toList();
    }

    // Apply gender filter
    if (_genderFilter != null) {
      filtered = filtered.where((voice) => voice.gender == _genderFilter).toList();
    }

    // Apply language filter
    if (_languageFilter != null) {
      filtered = filtered.where((voice) => voice.language == _languageFilter).toList();
    }

    // Apply accent filter
    if (_accentFilter != null) {
      filtered = filtered.where((voice) => voice.accent == _accentFilter).toList();
    }

    _filteredVoices = filtered;
    notifyListeners();
  }

  void _setLoadingState(VoiceLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Audio playback private methods
  void _setAudioState(AudioState state) {
    _audioState = state;
  }

  void _setAudioError(String message) {
    _audioErrorMessage = message;
    _audioState = AudioState.error;
  }

  void _clearAudioError() {
    _audioErrorMessage = null;
  }

}