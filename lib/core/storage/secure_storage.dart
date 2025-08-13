// Secure Storage for sensitive data
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';
import '../errors/exceptions.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Generic methods
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw CacheException(message: 'Failed to store value: $e');
    }
  }

  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve value: $e');
    }
  }

  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw CacheException(message: 'Failed to delete value: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw CacheException(message: 'Failed to clear secure storage: $e');
    }
  }

  // Specific methods for common use cases
  Future<void> storeApiKey(String apiKey) async {
    try {
      await _storage.write(
        key: StorageKeys.elevenlabsApiKey,
        value: apiKey,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to store API key: $e');
    }
  }

  Future<String?> getApiKey() async {
    try {
      return await _storage.read(key: StorageKeys.elevenlabsApiKey);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve API key: $e');
    }
  }

  Future<void> storeUserToken(String token) async {
    try {
      await _storage.write(
        key: StorageKeys.userToken,
        value: token,
      );
    } catch (e) {
      throw CacheException(message: 'Failed to store user token: $e');
    }
  }

  Future<String?> getUserToken() async {
    try {
      return await _storage.read(key: StorageKeys.userToken);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve user token: $e');
    }
  }

  Future<bool> hasApiKey() async {
    try {
      final apiKey = await getApiKey();
      return apiKey != null && apiKey.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}