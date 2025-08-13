// Web CORS Handler for ElevenLabs API
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class WebCorsHandler {
  // For web, we'll use a simple approach - let the browser handle CORS
  // and provide fallback error messages for users
  
  static Future<Uint8List> handleCorsRequest(
    String originalUrl,
    Map<String, String> headers,
    Uint8List body,
  ) async {
    if (!kIsWeb) {
      // For non-web platforms, return the original request
      throw UnsupportedError('This handler is only for web platform');
    }
    
    try {
      // For web, try the direct request first
      // Browser will handle CORS automatically
      final response = await http.post(
        Uri.parse(originalUrl),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Request failed with status: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      throw Exception('Network error: ${e.message}. This might be a CORS issue.');
    } on HttpException catch (e) {
      throw Exception('HTTP error: ${e.message}. This might be a CORS issue.');
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }
  
  static Future<http.Response> handleCorsResponse(
    Future<http.Response> originalRequest,
  ) async {
    if (!kIsWeb) {
      return await originalRequest;
    }
    
    try {
      return await originalRequest;
    } on SocketException catch (e) {
      // This is likely a CORS issue
      throw Exception('CORS error: ${e.message}');
    } on HttpException catch (e) {
      // This is likely a CORS issue
      throw Exception('HTTP error (likely CORS): ${e.message}');
    }
  }
}