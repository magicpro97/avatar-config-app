// Voice Repository Implementation
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/voice.dart' as domain_voice;
import '../../domain/repositories/voice_repository.dart';
import '../../core/errors/exceptions.dart';
import '../../core/storage/database_helper.dart';
import '../../core/utils/platform_utils.dart';
import '../services/elevenlabs_service.dart';
import '../models/voice_model.dart';
import '../models/elevenlabs_models.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  final ElevenLabsService _elevenLabsService;
  final DatabaseHelper _databaseHelper;
  
  // Cache configuration
  static const Duration _cacheExpiry = Duration(hours: 24);
  
  // Audio cache directory
  Directory? _audioCacheDir;

  VoiceRepositoryImpl({
    required ElevenLabsService elevenLabsService,
    required DatabaseHelper databaseHelper,
  })  : _elevenLabsService = elevenLabsService,
        _databaseHelper = databaseHelper {
    _initializeAudioCache();
  }

  Future<void> _initializeAudioCache() async {
    // Skip audio cache initialization on web platform
    if (PlatformUtils.isWeb) {
      _audioCacheDir = null;
      return;
    }
    
    try {
      final tempDir = await getTemporaryDirectory();
      _audioCacheDir = Directory('${tempDir.path}/audio_cache');
      if (!await _audioCacheDir!.exists()) {
        await _audioCacheDir!.create(recursive: true);
      }
    } catch (e) {
      // Don't throw on web or when path_provider is not available
      if (PlatformUtils.supportsPathProvider) {
        throw CacheException(message: 'Failed to initialize audio cache: $e');
      }
      _audioCacheDir = null;
    }
  }

  @override
  Future<List<domain_voice.ElevenLabsVoice>> getAvailableVoices() async {
    try {
      if (kDebugMode) {
        print('VoiceRepository: Getting available voices from API...');
      }
      
      final response = await _elevenLabsService.getVoices();
      
      if (kDebugMode) {
        print('VoiceRepository: Received ${response.length} voices from API');
      }
      
      final voices = response.map((voiceResponse) {
        try {
          final voice = _convertResponseToDomain(voiceResponse);
          if (kDebugMode) {
            print('VoiceRepository: Converted voice "${voice.name}" with labels: ${voice.labels}');
          }
          return voice;
        } catch (conversionError) {
          if (kDebugMode) {
            print('VoiceRepository: Error converting voice ${voiceResponse.voiceId}: $conversionError');
          }
          rethrow;
        }
      }).toList();
      
      if (kDebugMode) {
        print('VoiceRepository: Successfully converted ${voices.length} voices');
      }
      
      // Cache the voices for offline use
      await cacheVoices(voices);
      
      return voices;
    } catch (e) {
      if (kDebugMode) {
        print('VoiceRepository: Error fetching voices from API: $e');
      }
      
      // If API fails, try to return cached voices
      try {
        if (kDebugMode) {
          print('VoiceRepository: API failed, trying to get cached voices...');
        }
        final cachedVoices = await getCachedVoices();
        if (cachedVoices.isNotEmpty) {
          if (kDebugMode) {
            print('VoiceRepository: Found ${cachedVoices.length} cached voices');
          }
          return cachedVoices;
        } else {
          if (kDebugMode) {
            print('VoiceRepository: No cached voices found');
          }
        }
      } catch (cacheError) {
        if (kDebugMode) {
          print('VoiceRepository: Error getting cached voices: $cacheError');
        }
        // Ignore cache errors if API also failed
      }
      
      if (e is ApiKeyException || e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to fetch voices: $e');
    }
  }

  @override
  Future<domain_voice.ElevenLabsVoice?> getVoiceById(String voiceId) async {
    try {
      final response = await _elevenLabsService.getVoice(voiceId);
      return _convertResponseToDomain(response);
    } catch (e) {
      // Try to get from cache
      final cachedVoices = await getCachedVoices();
      try {
        return cachedVoices.firstWhere((voice) => voice.voiceId == voiceId);
      } catch (notFound) {
        return null;
      }
    }
  }

  @override
  Future<List<domain_voice.ElevenLabsVoice>> getCachedVoices() async {
    try {
      if (kDebugMode) {
        print('VoiceRepository: Getting cached voices...');
      }
      
      List<Map<String, dynamic>> maps;
      
      if (PlatformUtils.isWeb) {
        maps = await _databaseHelper.webStorage.queryCachedVoices(
          where: 'expires_at > ?',
          whereArgs: [DateTime.now().millisecondsSinceEpoch],
        );
      } else {
        final db = await _databaseHelper.database;
        maps = await db.query(
          'cached_voices',
          where: 'expires_at > ?',
          whereArgs: [DateTime.now().millisecondsSinceEpoch],
        );
      }

      if (kDebugMode) {
        print('VoiceRepository: Found ${maps.length} cached voice records');
      }

      final voices = maps.map((map) {
        try {
          if (kDebugMode) {
            print('VoiceRepository: Converting cached voice: ${map['name']}');
          }
          
          final labelsStr = map['labels'] as String?;
          final settingsStr = map['settings'] as String?;
          
          if (kDebugMode) {
            print('VoiceRepository: Cached labels string: "$labelsStr"');
          }
          
          final voiceModel = ElevenLabsVoiceModel.fromJson(Map<String, dynamic>.from({
            'voice_id': map['voice_id'] ?? '',
            'name': map['name'] ?? '',
            'preview_url': map['preview_url'],
            'labels': _parseLabels(labelsStr ?? ''),
            'settings': settingsStr != null
              ? VoiceSettingsModel.fromJson(Map<String, dynamic>.from(_parseSettings(settingsStr)))
              : null,
            'available': map['available'] == 1,
          }));
          
          final voice = _convertModelToDomain(voiceModel);
          
          if (kDebugMode) {
            print('VoiceRepository: Successfully converted cached voice "${voice.name}" with labels: ${voice.labels}');
          }
          
          return voice;
        } catch (e) {
          if (kDebugMode) {
            print('VoiceRepository: Error converting cached voice ${map['name']}: $e');
            print('VoiceRepository: Voice data: $map');
          }
          // Skip this voice and continue with others
          return null;
        }
      }).where((voice) => voice != null).cast<domain_voice.ElevenLabsVoice>().toList();
      
      if (kDebugMode) {
        print('VoiceRepository: Successfully converted ${voices.length} cached voices');
      }
      
      return voices;
    } catch (e) {
      if (kDebugMode) {
        print('VoiceRepository: Error getting cached voices: $e');
      }
      throw CacheException(message: 'Failed to get cached voices: $e');
    }
  }

  @override
  Future<void> cacheVoices(List<domain_voice.ElevenLabsVoice> voices) async {
    try {
      final expiresAt = DateTime.now().add(_cacheExpiry).millisecondsSinceEpoch;

      if (PlatformUtils.isWeb) {
        // Clear old cache
        await _databaseHelper.webStorage.clearCachedVoices();
        
        // Insert new voices
        for (final voice in voices) {
          await _databaseHelper.webStorage.insertCachedVoice({
            'voice_id': voice.voiceId,
            'name': voice.name,
            'preview_url': voice.previewUrl,
            'labels': _stringifyLabels(voice.labels),
            'settings': voice.settings != null ? _stringifySettings(voice.settings!) : null,
            'available': voice.available ? 1 : 0,
            'cached_at': DateTime.now().millisecondsSinceEpoch,
            'expires_at': expiresAt,
          });
        }
      } else {
        final db = await _databaseHelper.database;
        final batch = db.batch();

        // Clear old cache
        batch.delete('cached_voices');

        // Insert new voices
        for (final voice in voices) {
          batch.insert('cached_voices', {
            'voice_id': voice.voiceId,
            'name': voice.name,
            'preview_url': voice.previewUrl,
            'labels': _stringifyLabels(voice.labels),
            'settings': voice.settings != null ? _stringifySettings(voice.settings!) : null,
            'available': voice.available ? 1 : 0,
            'cached_at': DateTime.now().millisecondsSinceEpoch,
            'expires_at': expiresAt,
          });
        }

        await batch.commit();
      }
    } catch (e) {
      throw CacheException(message: 'Failed to cache voices: $e');
    }
  }

  @override
  Future<void> updateVoiceCache() async {
    try {
      await getAvailableVoices(); // This will automatically cache
    } catch (e) {
      throw CacheException(message: 'Failed to update voice cache: $e');
    }
  }

  @override
  Future<domain_voice.VoiceSettings> getVoiceSettings(String voiceId) async {
    try {
      final response = await _elevenLabsService.getVoiceSettings(voiceId);
      return domain_voice.VoiceSettings(
        stability: response.stability,
        similarityBoost: response.similarityBoost,
        style: response.style ?? 0.0,
        useSpeakerBoost: response.useSpeakerBoost ?? true,
      );
    } catch (e) {
      if (e is ApiKeyException || e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to get voice settings: $e');
    }
  }

  @override
  Future<void> updateVoiceSettings(String voiceId, domain_voice.VoiceSettings settings) async {
    try {
      final settingsModel = VoiceSettingsModel(
        stability: settings.stability,
        similarityBoost: settings.similarityBoost,
        style: settings.style,
        useSpeakerBoost: settings.useSpeakerBoost,
      );
      
      await _elevenLabsService.updateVoiceSettings(voiceId, settingsModel);
    } catch (e) {
      if (e is ApiKeyException || e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to update voice settings: $e');
    }
  }

  @override
  Future<List<int>> synthesizeText({
    required String text,
    required String voiceId,
    domain_voice.VoiceSettings? settings,
  }) async {
    try {
      final settingsModel = settings != null
          ? VoiceSettingsModel(
              stability: settings.stability,
              similarityBoost: settings.similarityBoost,
              style: settings.style,
              useSpeakerBoost: settings.useSpeakerBoost,
            )
          : null;

      final audioData = await _elevenLabsService.synthesizeText(
        text: text,
        voiceId: voiceId,
        settings: settingsModel,
      );

      return audioData.toList();
    } catch (e) {
      if (e is ApiKeyException || e is NetworkException || e is ServerException) {
        rethrow;
      }
      throw ServerException(message: 'Failed to synthesize text: $e');
    }
  }

  @override
  Future<String?> getVoicePreviewUrl(String voiceId) async {
    try {
      final voice = await getVoiceById(voiceId);
      return voice?.previewUrl;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<String?> downloadAudioSample(String url, String fileName) async {
    // Audio caching not supported on web
    if (PlatformUtils.isWeb) {
      return url; // Return the URL directly for web playback
    }
    
    try {
      await _initializeAudioCache();
      if (_audioCacheDir == null) {
        return url; // Fallback to URL if cache not available
      }
      
      final file = File('${_audioCacheDir!.path}/$fileName');
      
      // Check if file already exists and is not too old
      if (await file.exists()) {
        final fileStats = await file.stat();
        final fileAge = DateTime.now().difference(fileStats.modified);
        
        // If file is less than 1 hour old, return cached version
        if (fileAge.inHours < 1) {
          return file.path;
        }
      }

      // Implement HTTP download using http package
      try {
        final response = await http.get(Uri.parse(url));
        
        if (response.statusCode == 200) {
          // Write audio data to file
          await file.create(recursive: true);
          await file.writeAsBytes(response.bodyBytes);
          
          return file.path;
        } else {
          throw Exception('Failed to download audio: ${response.statusCode}');
        }
      } catch (downloadError) {
        // If download fails, try to use the ElevenLabsService to get audio data
        try {
          // Extract voice ID from URL if possible, or use a fallback approach
          final audioData = await _elevenLabsService.synthesizeText(
            text: 'Audio sample preview',
            voiceId: 'default', // This would ideally be extracted from URL
            settings: null,
          );
          
          // Write synthesized audio to file
          await file.create(recursive: true);
          await file.writeAsBytes(audioData);
          
          return file.path;
        } catch (synthError) {
          // If both methods fail, log the error and return URL for streaming
          if (kDebugMode) {
            print('Failed to download audio sample: $downloadError, $synthError');
          }
          return url;
        }
      }
    } catch (e) {
      // Don't throw error, just return URL for streaming
      if (kDebugMode) {
        print('Error in downloadAudioSample: $e');
      }
      return url;
    }
  }

  @override
  Future<List<domain_voice.ElevenLabsVoice>> filterVoices({
    domain_voice.Gender? gender,
    String? language,
    String? accent,
    String? ageGroup,
  }) async {
    final voices = await getAvailableVoices();
    return voices.where((voice) {
      bool matches = true;
      
      if (gender != null && voice.gender != gender) matches = false;
      if (language != null && voice.language != language) matches = false;
      if (accent != null && voice.accent != accent) matches = false;
      if (ageGroup != null && voice.ageGroup != ageGroup) matches = false;
      
      return matches;
    }).toList();
  }

  @override
  Future<List<domain_voice.ElevenLabsVoice>> searchVoices(String query) async {
    final voices = await getAvailableVoices();
    final lowerQuery = query.toLowerCase();
    
    return voices.where((voice) {
      return voice.name.toLowerCase().contains(lowerQuery) ||
             voice.description.toLowerCase().contains(lowerQuery) ||
             voice.language.toLowerCase().contains(lowerQuery) ||
             voice.accent.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<domain_voice.ElevenLabsVoice>> getVoicesByGender(domain_voice.Gender gender) async {
    return filterVoices(gender: gender);
  }

  @override
  Future<List<domain_voice.ElevenLabsVoice>> getVoicesByLanguage(String language) async {
    return filterVoices(language: language);
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    final voices = await getAvailableVoices();
    final languages = voices.map((voice) => voice.language).toSet().toList();
    languages.sort();
    return languages;
  }

  @override
  Future<List<String>> getAvailableAccents(String language) async {
    final voices = await filterVoices(language: language);
    final accents = voices.map((voice) => voice.accent).toSet().toList();
    accents.sort();
    return accents;
  }

  @override
  Future<List<String>> getAvailableAgeGroups() async {
    final voices = await getAvailableVoices();
    final ageGroups = voices.map((voice) => voice.ageGroup).toSet().toList();
    ageGroups.sort();
    return ageGroups;
  }

  @override
  Future<bool> isVoiceAvailable(String voiceId) async {
    try {
      final voice = await getVoiceById(voiceId);
      return voice?.available ?? false;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getVoiceUsageStats() async {
    try {
      final userInfo = await _elevenLabsService.getUserInfo();
      return {
        'character_count': userInfo.subscription.characterCount,
        'character_limit': userInfo.subscription.characterLimit,
        'remaining_characters': userInfo.subscription.characterLimit - userInfo.subscription.characterCount,
        'tier': userInfo.subscription.tier,
        'status': userInfo.subscription.status,
        'next_reset': DateTime.fromMillisecondsSinceEpoch(
          userInfo.subscription.nextCharacterCountResetUnix * 1000,
        ),
      };
    } catch (e) {
      throw ServerException(message: 'Failed to get voice usage stats: $e');
    }
  }

  @override
  Future<void> clearVoiceCache() async {
    try {
      if (PlatformUtils.isWeb) {
        await _databaseHelper.webStorage.clearCachedVoices();
      } else {
        final db = await _databaseHelper.database;
        await db.delete('cached_voices');
        
        // Clear audio cache (only on supported platforms)
        if (_audioCacheDir != null && await _audioCacheDir!.exists()) {
          await _audioCacheDir!.delete(recursive: true);
          await _audioCacheDir!.create();
        }
      }
    } catch (e) {
      throw CacheException(message: 'Failed to clear voice cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      int totalSize = 0;
      
      // Only check cache size on supported platforms
      if (!PlatformUtils.isWeb && _audioCacheDir != null && await _audioCacheDir!.exists()) {
        await for (final entity in _audioCacheDir!.list(recursive: true)) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<DateTime?> getLastCacheUpdateTime() async {
    try {
      List<Map<String, dynamic>> result;
      
      if (PlatformUtils.isWeb) {
        result = await _databaseHelper.webStorage.rawQuery(
          'SELECT MAX(cached_at) as last_update FROM cached_voices',
        );
      } else {
        final db = await _databaseHelper.database;
        result = await db.rawQuery(
          'SELECT MAX(cached_at) as last_update FROM cached_voices',
        );
      }
      
      final timestamp = result.isNotEmpty ? result.first['last_update'] as int? : null;
      return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> validateApiKey(String apiKey) async {
    try {
      // First set the API key in the service
      await _elevenLabsService.setApiKey(apiKey);
      // Then validate it
      return await _elevenLabsService.validateApiKey(apiKey);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Map<String, dynamic>> getApiUsage() async {
    return getVoiceUsageStats();
  }

  @override
  Future<bool> testVoiceSynthesis() async {
    try {
      // Get a test voice
      final voices = await getAvailableVoices();
      if (voices.isEmpty) return false;
      
      final testVoice = voices.first;
      
      // Try to synthesize a short test phrase
      await synthesizeText(
        text: "Hello, this is a test.",
        voiceId: testVoice.voiceId,
      );
      
      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  domain_voice.ElevenLabsVoice _convertModelToDomain(ElevenLabsVoiceModel model) {
    // Ensure all labels are strings
    final Map<String, String> safeLabels = {};
    try {
      model.labels.forEach((key, value) {
        safeLabels[key] = value.toString();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error converting model labels: $e');
      }
      // Fallback to empty labels
      safeLabels.addAll({
        'gender': 'unknown',
        'language': 'unknown',
        'accent': 'unknown',
        'age': 'unknown',
      });
    }

    return domain_voice.ElevenLabsVoice(
      voiceId: model.voiceId,
      name: model.name,
      previewUrl: model.previewUrl,
      labels: safeLabels,
      settings: model.settings != null
        ? domain_voice.VoiceSettings(
            stability: model.settings!.stability,
            similarityBoost: model.settings!.similarityBoost,
            style: model.settings!.style,
            useSpeakerBoost: model.settings!.useSpeakerBoost,
          )
        : null,
      available: model.available,
    );
  }

  domain_voice.ElevenLabsVoice _convertResponseToDomain(ElevenLabsVoiceResponse response) {
    // Process labels to ensure they are all strings
    final Map<String, String> processedLabels = {};
    try {
      response.labels.forEach((key, value) {
        String stringValue;
        if (value is String) {
          stringValue = value;
        } else if (value is num) {
          stringValue = value.toString();
        } else if (value is bool) {
          stringValue = value.toString();
        } else if (value is Map || value is List) {
          stringValue = json.encode(value);
        } else {
          stringValue = value?.toString() ?? '';
        }
        processedLabels[key] = stringValue;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error processing labels: $e');
      }
      // Fallback to empty labels if processing fails
      processedLabels.addAll({
        'gender': 'unknown',
        'language': 'unknown',
        'accent': 'unknown',
        'age': 'unknown',
      });
    }

    return domain_voice.ElevenLabsVoice(
      voiceId: response.voiceId,
      name: response.name,
      previewUrl: response.previewUrl,
      labels: processedLabels,
      settings: response.settings != null
        ? domain_voice.VoiceSettings(
            stability: response.settings!.stability,
            similarityBoost: response.settings!.similarityBoost,
            style: response.settings!.style ?? 0.0,
            useSpeakerBoost: response.settings!.useSpeakerBoost ?? true,
          )
        : null,
      available: response.availableForTiers?.contains('free') ?? true,
    );
  }

  String _stringifyLabels(Map<String, String> labels) {
    try {
      return labels.entries
          .where((e) => e.key.isNotEmpty && e.value.isNotEmpty)
          .map((e) => '${e.key}:${e.value}')
          .join(';');
    } catch (e) {
      if (kDebugMode) {
        print('Error stringifying labels: $e');
      }
      return '';
    }
  }

  Map<String, String> _parseLabels(String labelsStr) {
    final Map<String, String> labels = {};
    try {
      if (labelsStr.isEmpty) {
        return labels;
      }
      
      for (final pair in labelsStr.split(';')) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          final key = parts[0].trim();
          final value = parts[1].trim();
          if (key.isNotEmpty && value.isNotEmpty) {
            labels[key] = value;
          }
        }
      }
    } catch (e) {
      // If parsing fails, return empty map
      if (kDebugMode) {
        print('Error parsing labels: $e, input: "$labelsStr"');
      }
    }
    return labels;
  }

  String _stringifySettings(domain_voice.VoiceSettings settings) {
    return '${settings.stability},${settings.similarityBoost},${settings.style},${settings.useSpeakerBoost}';
  }

  Map<String, dynamic> _parseSettings(String settingsStr) {
    try {
      if (settingsStr.isEmpty) {
        return {
          'stability': 0.5,
          'similarity_boost': 0.5,
          'style': 0.0,
          'use_speaker_boost': true,
        };
      }
      
      final parts = settingsStr.split(',');
      if (parts.length == 4) {
        return {
          'stability': double.tryParse(parts[0].trim()) ?? 0.5,
          'similarity_boost': double.tryParse(parts[1].trim()) ?? 0.5,
          'style': double.tryParse(parts[2].trim()) ?? 0.0,
          'use_speaker_boost': parts[3].trim().toLowerCase() == 'true',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing settings: $e, input: "$settingsStr"');
      }
    }
    return {
      'stability': 0.5,
      'similarity_boost': 0.5,
      'style': 0.0,
      'use_speaker_boost': true,
    };
  }
}