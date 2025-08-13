// Custom Exceptions for the Avatar Configuration App

class ServerException implements Exception {
  final String message;
  final int? statusCode;
  
  const ServerException({
    required this.message,
    this.statusCode,
  });
  
  @override
  String toString() => 'ServerException: $message (Status: $statusCode)';
}

class CacheException implements Exception {
  final String message;
  
  const CacheException({required this.message});
  
  @override
  String toString() => 'CacheException: $message';
}

class DatabaseException implements Exception {
  final String message;
  
  const DatabaseException({required this.message});
  
  @override
  String toString() => 'DatabaseException: $message';
}

class NetworkException implements Exception {
  final String message;
  
  const NetworkException({required this.message});
  
  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  final String message;
  final String? field;
  
  const ValidationException({
    required this.message,
    this.field,
  });
  
  @override
  String toString() => 'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

class ApiKeyException implements Exception {
  final String message;
  
  const ApiKeyException({required this.message});
  
  @override
  String toString() => 'ApiKeyException: $message';
}

class AudioException implements Exception {
  final String message;
  
  const AudioException({required this.message});
  
  @override
  String toString() => 'AudioException: $message';
}

class StorageException implements Exception {
  final String message;
  
  const StorageException({required this.message});
  
  @override
  String toString() => 'StorageException: $message';
}