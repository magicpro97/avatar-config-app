// ElevenLabs API Service
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // For kIsWeb
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/storage/secure_storage.dart';
import '../models/elevenlabs_models.dart';
import '../models/voice_model.dart';
import 'web_cors_handler.dart';
import 'api_config_service.dart';

class ElevenLabsService {
  final http.Client _httpClient;
  final SecureStorage _secureStorage;

  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 100);

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _baseRetryDelay = Duration(seconds: 1);

  ElevenLabsService({
    required http.Client httpClient,
    required SecureStorage secureStorage,
  }) : _httpClient = httpClient,
       _secureStorage = secureStorage;

  // API Key Management
  Future<String?> getApiKey() async {
    try {
      return await ApiConfigService.getElevenLabsApiKey();
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve API key: $e');
    }
  }

  Future<void> setApiKey(String apiKey) async {
    try {
      await ApiConfigService.setElevenLabsApiKey(apiKey);
    } catch (e) {
      throw CacheException(message: 'Failed to store API key: $e');
    }
  }

  Future<void> clearApiKey() async {
    try {
      await ApiConfigService.removeElevenLabsApiKey();
    } catch (e) {
      throw CacheException(message: 'Failed to clear API key: $e');
    }
  }

  // API Validation
  Future<bool> validateApiKey([String? apiKey]) async {
    final keyToValidate = apiKey ?? await getApiKey();
    if (keyToValidate == null) return false;

    try {
      final response = await _makeRequest(
        'GET',
        '/v1/user',
        headers: {'xi-api-key': keyToValidate},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Debug method to check API key status
  Future<Map<String, dynamic>> debugApiKey() async {
    try {
      final apiKey = await getApiKey();
      final hasKey = apiKey != null && apiKey.isNotEmpty;
      final keyLength = apiKey?.length ?? 0;
      final keyPreview = apiKey != null ? '${apiKey.substring(0, 7)}...' : null;
      
      return {
        'has_key': hasKey,
        'key_length': keyLength,
        'key_preview': keyPreview,
        'source': 'ApiConfigService',
      };
    } catch (e) {
      return {
        'has_key': false,
        'error': e.toString(),
        'source': 'ApiConfigService',
      };
    }
  }

  // Get User Information (for API validation and usage tracking)
  Future<ElevenLabsUserResponse> getUserInfo() async {
    final response = await _makeAuthenticatedRequest('GET', '/v1/user');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ElevenLabsUserResponse.fromJson(data);
  }

  // Voice Management
  Future<List<ElevenLabsVoiceResponse>> getVoices() async {
    final response = await _makeAuthenticatedRequest('GET', '/v1/voices');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final voicesResponse = ElevenLabsVoicesResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
    return voicesResponse.voices;
  }

  Future<ElevenLabsVoiceResponse> getVoice(String voiceId) async {
    final response = await _makeAuthenticatedRequest(
      'GET',
      '/v1/voices/$voiceId',
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ElevenLabsVoiceResponse.fromJson(Map<String, dynamic>.from(data));
  }

  Future<ElevenLabsVoiceSettingsResponse> getVoiceSettings(
    String voiceId,
  ) async {
    final response = await _makeAuthenticatedRequest(
      'GET',
      '/v1/voices/$voiceId/settings',
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return ElevenLabsVoiceSettingsResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  Future<void> updateVoiceSettings(
    String voiceId,
    VoiceSettingsModel settings,
  ) async {
    final requestBody = VoiceSettingsRequest.fromDomain(settings);
    await _makeAuthenticatedRequest(
      'POST',
      '/v1/voices/$voiceId/settings/edit',
      body: requestBody.toJson(),
    );
  }

  // Text-to-Speech
  Future<Uint8List> synthesizeText({
    required String text,
    required String voiceId,
    VoiceSettingsModel? settings,
    String? modelId,
    String? languageCode,
    List<String>? pronunciationDictionaryLocators,
    String? seed,
    String? previousText,
    String? nextText,
    List<String>? previousRequestIds,
    List<String>? nextRequestIds,
    bool? usePvcAsIvc,
    String? applyTextNormalization,
    bool? applyLanguageTextNormalization,
  }) async {
    final request = VoiceSynthesisRequest(
      text: text,
      voiceSettings: settings != null
          ? VoiceSettingsRequest.fromDomain(settings)
          : const VoiceSettingsRequest(
              stability: 0.5,
              similarityBoost: 0.5,
              style: 0,
              useSpeakerBoost: true,
            ),
      modelId: modelId ?? 'eleven_monolingual_v1',
      languageCode: null, // Không gửi language_code vì API không hỗ trợ
      pronunciationDictionaryLocators: pronunciationDictionaryLocators ?? [],
      seed: seed != null ? int.tryParse(seed) ?? 0 : 0,
      previousText: previousText ?? '',
      nextText: nextText ?? '',
      previousRequestIds: previousRequestIds ?? [],
      nextRequestIds: nextRequestIds ?? [],
      usePvcAsIvc: usePvcAsIvc ?? false,
      applyTextNormalization: applyTextNormalization ?? 'on',
      applyLanguageTextNormalization: applyLanguageTextNormalization ?? false,
    );

    // Debug: Log the request body for web debugging
    // DEBUG: ElevenLabs request body: ${request.toJson()}

    try {
      // For web, we need a special approach due to CORS issues
      if (kIsWeb) {
        // DEBUG: Web platform detected, using special CORS handling...

        // Use a simplified approach for web - try with minimal headers
        final originalUrl =
            '${ApiConstants.elevenLabsBaseUrl}/v1/text-to-speech/$voiceId';
        final apiKey = await getApiKey();
        if (apiKey == null) {
          throw const ApiKeyException(message: 'API key not found');
        }

        final headers = {
          'xi-api-key': apiKey,
          'Content-Type': 'application/json',
          'User-Agent': 'Avatar-Config-App/1.0.0',
        };

        final requestBody = jsonEncode(request.toJson());

        try {
          // Try with CORS handler with multiple fallback strategies for web
          final bodyBytes = utf8.encode(requestBody);
          return await WebCorsHandler.handleCorsRequestWithFallback(
            originalUrl,
            headers,
            bodyBytes,
          );
        } catch (corsError) {
          // DEBUG: CORS handler failed: $corsError
          rethrow;
        }
      }

      // For non-web platforms, use the normal approach
      final response = await _makeAuthenticatedRequest(
        'POST',
        '/v1/text-to-speech/$voiceId',
        body: request.toJson(),
        expectBinaryResponse: true,
      );

      // Debug: Log the response for web debugging
      // DEBUG: ElevenLabs response status: ${response.statusCode}
      // DEBUG: ElevenLabs response headers: ${response.headers}
      if (response.statusCode != 200) {
        // DEBUG: ElevenLabs error body: ${response.body}
      }

      return response.bodyBytes;
    } catch (e) {
      // DEBUG: Request failed: $e
      rethrow;
    }
  }

  // Get Available Models
  Future<List<ElevenLabsModelInfo>> getModels() async {
    final response = await _makeAuthenticatedRequest('GET', '/v1/models');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final modelsResponse = ElevenLabsModelsResponse.fromJson(
      Map<String, dynamic>.from(data),
    );
    return modelsResponse.models;
  }

  // Voice History (optional - for usage tracking)
  Future<Map<String, dynamic>> getHistory() async {
    final response = await _makeAuthenticatedRequest('GET', '/v1/history');
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Private helper methods
  Future<http.Response> _makeAuthenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    bool expectBinaryResponse = false,
  }) async {
    final apiKey = await getApiKey();
    if (apiKey == null) {
      throw const ApiKeyException(message: 'API key not found');
    }

    final headers = {
      'xi-api-key': apiKey,
      if (!expectBinaryResponse) 'Content-Type': 'application/json',
      ...?additionalHeaders,
    };

    return _makeRequest(method, endpoint, headers: headers, body: body);
  }

  Future<http.Response> _makeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    // Rate limiting
    await _enforceRateLimit();

    final uri = Uri.parse('${ApiConstants.elevenLabsBaseUrl}$endpoint');

    // For web, we need to handle CORS differently
    if (kIsWeb) {
      // DEBUG: Web request to $uri with method $method
      // DEBUG: Request body: $body

      // Use a simple approach for web - try with minimal headers
      // final webHeaders = {
      //   'Content-Type': 'application/json',
      //   'User-Agent': 'Avatar-Config-App/1.0.0',
      //   if (headers != null) ...headers,
      // };

      // DEBUG: Web request headers: $webHeaders
    }

    final requestHeaders = {
      'User-Agent': 'Avatar-Config-App/1.0.0',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        http.Response response;

        switch (method.toUpperCase()) {
          case 'GET':
            response = await _httpClient
                .get(uri, headers: requestHeaders)
                .timeout(
                  const Duration(milliseconds: ApiConstants.connectionTimeout),
                );
            break;
          case 'POST':
            response = await _httpClient
                .post(
                  uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(
                  const Duration(milliseconds: ApiConstants.receiveTimeout),
                );
            break;
          case 'PUT':
            response = await _httpClient
                .put(
                  uri,
                  headers: requestHeaders,
                  body: body != null ? jsonEncode(body) : null,
                )
                .timeout(
                  const Duration(milliseconds: ApiConstants.receiveTimeout),
                );
            break;
          case 'DELETE':
            response = await _httpClient
                .delete(uri, headers: requestHeaders)
                .timeout(
                  const Duration(milliseconds: ApiConstants.connectionTimeout),
                );
            break;
          default:
            throw ArgumentError('Unsupported HTTP method: $method');
        }

        _lastRequestTime = DateTime.now();

        if (response.statusCode == 429 && attempt < _maxRetries) {
          // Rate limited, wait and retry
          final retryDelay = _calculateRetryDelay(attempt);
          await Future.delayed(retryDelay);
          continue;
        }

        _handleResponseErrors(response);
        return response;
      } on SocketException {
        if (attempt == _maxRetries) {
          throw const NetworkException(message: 'No internet connection');
        }
        await Future.delayed(_calculateRetryDelay(attempt));
      } on HttpException {
        if (attempt == _maxRetries) {
          throw const NetworkException(message: 'HTTP error occurred');
        }
        await Future.delayed(_calculateRetryDelay(attempt));
      } catch (e) {
        if (attempt == _maxRetries) {
          throw ServerException(message: 'Request failed: $e');
        }
        await Future.delayed(_calculateRetryDelay(attempt));
      }
    }

    throw const ServerException(message: 'Max retries exceeded');
  }

  void _handleResponseErrors(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return; // Success
      case 400:
        throw ServerException(
          message: 'Bad request: ${_extractErrorMessage(response)}',
          statusCode: response.statusCode,
        );
      case 401:
        throw const ApiKeyException(message: 'Invalid or missing API key');
      case 403:
        throw const ServerException(
          message: 'Forbidden - insufficient permissions',
        );
      case 404:
        throw const ServerException(message: 'Resource not found');
      case 422:
        throw ServerException(
          message: 'Validation error: ${_extractErrorMessage(response)}',
          statusCode: response.statusCode,
        );
      case 429:
        throw const ServerException(message: 'Rate limit exceeded');
      case 500:
        throw const ServerException(message: 'Internal server error');
      case 502:
        throw const ServerException(message: 'Bad gateway');
      case 503:
        throw const ServerException(message: 'Service unavailable');
      case 504:
        throw const ServerException(message: 'Gateway timeout');
      default:
        throw ServerException(
          message: 'Unexpected error occurred (${response.statusCode})',
          statusCode: response.statusCode,
        );
    }
  }

  String _extractErrorMessage(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Try different error message formats
      if (data['detail'] != null) {
        if (data['detail'] is Map) {
          final detail = data['detail'] as Map<String, dynamic>;
          return detail['message']?.toString() ?? 'Unknown error';
        }
        return data['detail'].toString();
      }

      if (data['message'] != null) {
        return data['message'].toString();
      }

      if (data['error'] != null) {
        return data['error'].toString();
      }

      return 'Unknown error';
    } catch (e) {
      return 'Failed to parse error response';
    }
  }

  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final elapsed = DateTime.now().difference(_lastRequestTime!);
      if (elapsed < _minRequestInterval) {
        await Future.delayed(_minRequestInterval - elapsed);
      }
    }
  }

  Duration _calculateRetryDelay(int attempt) {
    // Exponential backoff with jitter
    final baseDelay = _baseRetryDelay.inMilliseconds * (1 << attempt);
    final jitter = (baseDelay * 0.1).round();
    final delay = baseDelay + (jitter * (0.5 - (attempt % 2)));

    return Duration(milliseconds: delay.clamp(1000, 30000).toInt());
  }

  // Dispose method
  void dispose() {
    _httpClient.close();
  }
}
