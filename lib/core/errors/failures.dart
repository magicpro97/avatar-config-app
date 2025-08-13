// Failures for Clean Architecture error handling

abstract class Failure {
  final String message;
  
  const Failure({required this.message});
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}

class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure({
    required super.message,
    this.statusCode,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ServerFailure &&
          statusCode == other.statusCode;

  @override
  int get hashCode => super.hashCode ^ statusCode.hashCode;
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class DatabaseFailure extends Failure {
  const DatabaseFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  final String? field;
  
  const ValidationFailure({
    required super.message,
    this.field,
  });
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is ValidationFailure &&
          field == other.field;

  @override
  int get hashCode => super.hashCode ^ field.hashCode;
}

class ApiKeyFailure extends Failure {
  const ApiKeyFailure({required super.message});
}

class AudioFailure extends Failure {
  const AudioFailure({required super.message});
}

class UnknownFailure extends Failure {
  const UnknownFailure({required super.message});
}