// Voice Repository Interface (Domain Layer)
import '../entities/voice.dart';

abstract class VoiceRepository {
  /// Get all available voices from ElevenLabs API
  Future<List<ElevenLabsVoice>> getAvailableVoices();

  /// Get a specific voice by ID
  Future<ElevenLabsVoice?> getVoiceById(String voiceId);

  /// Get cached voices (for offline use)
  Future<List<ElevenLabsVoice>> getCachedVoices();

  /// Cache voices for offline use
  Future<void> cacheVoices(List<ElevenLabsVoice> voices);

  /// Update voice cache
  Future<void> updateVoiceCache();

  /// Get voice settings for a specific voice
  Future<VoiceSettings> getVoiceSettings(String voiceId);

  /// Update voice settings
  Future<void> updateVoiceSettings(String voiceId, VoiceSettings settings);

  /// Synthesize text to speech
  Future<List<int>> synthesizeText({
    required String text,
    required String voiceId,
    VoiceSettings? settings,
  });

  /// Get voice preview URL
  Future<String?> getVoicePreviewUrl(String voiceId);

  /// Download and cache audio sample
  Future<String?> downloadAudioSample(String url, String fileName);

  /// Filter voices by criteria
  Future<List<ElevenLabsVoice>> filterVoices({
    Gender? gender,
    String? language,
    String? accent,
    String? ageGroup,
  });

  /// Search voices by name or description
  Future<List<ElevenLabsVoice>> searchVoices(String query);

  /// Get voices by gender
  Future<List<ElevenLabsVoice>> getVoicesByGender(Gender gender);

  /// Get voices by language
  Future<List<ElevenLabsVoice>> getVoicesByLanguage(String language);

  /// Get available languages
  Future<List<String>> getAvailableLanguages();

  /// Get available accents for a language
  Future<List<String>> getAvailableAccents(String language);

  /// Get available age groups
  Future<List<String>> getAvailableAgeGroups();

  /// Check if voice is available
  Future<bool> isVoiceAvailable(String voiceId);

  /// Get voice usage statistics
  Future<Map<String, dynamic>> getVoiceUsageStats();

  /// Clear voice cache
  Future<void> clearVoiceCache();

  /// Get cache size
  Future<int> getCacheSize();

  /// Get last cache update time
  Future<DateTime?> getLastCacheUpdateTime();

  /// Validate API key
  Future<bool> validateApiKey(String apiKey);

  /// Get API usage information
  Future<Map<String, dynamic>> getApiUsage();

  /// Test voice synthesis (for API key validation)
  Future<bool> testVoiceSynthesis();
}