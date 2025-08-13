// API Client for HTTP requests
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client httpClient;
  final String? apiKey;

  ApiClient({
    required this.httpClient,
    this.apiKey,
  });

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await httpClient.get(
        uri,
        headers: _buildHeaders(headers),
      ).timeout(
        const Duration(milliseconds: ApiConstants.connectionTimeout),
      );

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on HttpException {
      throw const NetworkException(message: 'HTTP error occurred');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final response = await httpClient.post(
        uri,
        headers: _buildHeaders(headers),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(
        const Duration(milliseconds: ApiConstants.receiveTimeout),
      );

      return _handleResponse(response);
    } on SocketException {
      throw const NetworkException(message: 'No internet connection');
    } on HttpException {
      throw const NetworkException(message: 'HTTP error occurred');
    } catch (e) {
      throw ServerException(message: 'Unexpected error: $e');
    }
  }

  Map<String, String> _buildHeaders(Map<String, String>? additionalHeaders) {
    final headers = <String, String>{
      'Content-Type': ApiConstants.contentType,
      'User-Agent': 'Avatar-Config-App/1.0.0',
    };

    if (apiKey != null) {
      headers[ApiConstants.authorizationHeader] = apiKey!;
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          // Handle non-JSON responses (like binary data)
          return {'data': response.body, 'statusCode': response.statusCode};
        }
      case 400:
        throw ServerException(
          message: _extractErrorMessage(response),
          statusCode: response.statusCode,
        );
      case 401:
        throw const ApiKeyException(message: 'Invalid or missing API key');
      case 403:
        throw const ServerException(message: 'Forbidden - insufficient permissions');
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
          message: 'Unexpected error occurred',
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
}