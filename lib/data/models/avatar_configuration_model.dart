// Avatar Configuration Data Model with Database Support
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import '../../domain/entities/avatar_configuration.dart';
import '../../domain/entities/voice.dart';
import 'personality_model.dart';
import 'voice_model.dart' as voice_model;
import 'package:flutter/foundation.dart';

part 'avatar_configuration_model.g.dart';

@JsonSerializable()
class AvatarConfigurationModel {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'personality_type')
  final PersonalityType personalityType;
  @JsonKey(name: 'voice_configuration')
  final voice_model.VoiceConfigurationModel voiceConfiguration;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'last_modified')
  final DateTime lastModified;
  @JsonKey(name: 'last_used_date')
  final DateTime? lastUsedDate;
  @JsonKey(name: 'usage_count')
  final int usageCount;
  @JsonKey(name: 'is_favorite')
  final bool isFavorite;
  @JsonKey(name: 'is_active')
  final bool isActive;
  final List<String> tags;

  const AvatarConfigurationModel({
    required this.id,
    required this.name,
    this.description,
    required this.personalityType,
    required this.voiceConfiguration,
    required this.createdAt,
    required this.lastModified,
    this.lastUsedDate,
    this.usageCount = 0,
    this.isFavorite = false,
    required this.isActive,
    this.tags = const [],
  });

  factory AvatarConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$AvatarConfigurationModelFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarConfigurationModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AvatarConfigurationModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          personalityType == other.personalityType &&
          voiceConfiguration == other.voiceConfiguration &&
          createdAt == other.createdAt &&
          lastModified == other.lastModified &&
          lastUsedDate == other.lastUsedDate &&
          usageCount == other.usageCount &&
          isFavorite == other.isFavorite &&
          isActive == other.isActive &&
          tags == other.tags;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      description.hashCode ^
      personalityType.hashCode ^
      voiceConfiguration.hashCode ^
      createdAt.hashCode ^
      lastModified.hashCode ^
      lastUsedDate.hashCode ^
      usageCount.hashCode ^
      isFavorite.hashCode ^
      isActive.hashCode ^
      tags.hashCode;

  @override
  String toString() {
    return 'AvatarConfigurationModel(id: $id, name: $name, personality: $personalityType, isActive: $isActive)';
  }

  AvatarConfigurationModel copyWith({
    String? id,
    String? name,
    String? description,
    PersonalityType? personalityType,
    voice_model.VoiceConfigurationModel? voiceConfiguration,
    DateTime? createdAt,
    DateTime? lastModified,
    DateTime? lastUsedDate,
    int? usageCount,
    bool? isFavorite,
    bool? isActive,
    List<String>? tags,
  }) {
    return AvatarConfigurationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      personalityType: personalityType ?? this.personalityType,
      voiceConfiguration: voiceConfiguration ?? this.voiceConfiguration,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      lastUsedDate: lastUsedDate ?? this.lastUsedDate,
      usageCount: usageCount ?? this.usageCount,
      isFavorite: isFavorite ?? this.isFavorite,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
    );
  }

  // Helper method to create a new configuration
  factory AvatarConfigurationModel.create({
    required String id,
    required String name,
    String? description,
    required PersonalityType personalityType,
    required voice_model.VoiceConfigurationModel voiceConfiguration,
    bool isActive = false,
    bool isFavorite = false,
    List<String>? tags,
  }) {
    final now = DateTime.now();
    return AvatarConfigurationModel(
      id: id,
      name: name,
      description: description,
      personalityType: personalityType,
      voiceConfiguration: voiceConfiguration,
      createdAt: now,
      lastModified: now,
      usageCount: 0,
      isFavorite: isFavorite,
      isActive: isActive,
      tags: tags ?? [],
    );
  }

  // Helper method to update configuration
  AvatarConfigurationModel updateConfiguration({
    String? name,
    String? description,
    PersonalityType? personalityType,
    voice_model.VoiceConfigurationModel? voiceConfiguration,
    bool? isActive,
    bool? isFavorite,
    List<String>? tags,
  }) {
    return copyWith(
      name: name,
      description: description,
      personalityType: personalityType,
      voiceConfiguration: voiceConfiguration,
      isActive: isActive,
      isFavorite: isFavorite,
      tags: tags,
      lastModified: DateTime.now(),
    );
  }

  // Helper method to activate configuration
  AvatarConfigurationModel activate() {
    return copyWith(isActive: true, lastModified: DateTime.now());
  }

  // Helper method to deactivate configuration
  AvatarConfigurationModel deactivate() {
    return copyWith(isActive: false, lastModified: DateTime.now());
  }

  // Helper getters
  PersonalityModel get personality {
    switch (personalityType) {
      case PersonalityType.happy:
        return PersonalityModel.happy;
      case PersonalityType.romantic:
        return PersonalityModel.romantic;
      case PersonalityType.funny:
        return PersonalityModel.funny;
      case PersonalityType.professional:
        return PersonalityModel.professional;
      case PersonalityType.casual:
        return PersonalityModel.casual;
      case PersonalityType.energetic:
        return PersonalityModel.energetic;
      case PersonalityType.calm:
        return PersonalityModel.calm;
      case PersonalityType.mysterious:
        return PersonalityModel.mysterious;
    }
  }

  String get personalityDisplayName => personality.displayName;
  String get voiceName => voiceConfiguration.name;
  String get voiceGender => voiceConfiguration.gender.name;
  String get formattedCreatedDate =>
      '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedModifiedDate =>
      '${lastModified.day}/${lastModified.month}/${lastModified.year}';

  // Validation
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        voiceConfiguration.voiceId.isNotEmpty;
  }

  // Time-based helpers
  Duration get age => DateTime.now().difference(createdAt);
  Duration get timeSinceLastModified => DateTime.now().difference(lastModified);
  Duration? get timeSinceLastUsed =>
      lastUsedDate != null ? DateTime.now().difference(lastUsedDate!) : null;

  bool get isRecentlyModified => timeSinceLastModified.inHours < 24;
  bool get isRecentlyUsed => (timeSinceLastUsed?.inDays ?? 999) < 7;
  bool get isOld => age.inDays > 30;

  // Status helpers
  String get statusText => isActive ? 'Active' : 'Inactive';
  bool get canBeActivated => isValid && !isActive;
  bool get canBeDeactivated => isActive;
  String get tagsString => tags.join(', ');

  // === DATABASE MAPPING METHODS ===

  /// Convert model to database map for SQLite storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'personality_data': jsonEncode({
        'type': personalityType.name,
        'parameters': personality.parameters,
      }),
      'voice_data': jsonEncode(voiceConfiguration.toJson()),
      'created_date': createdAt.millisecondsSinceEpoch,
      'updated_date': lastModified.millisecondsSinceEpoch,
      'last_used_date': lastUsedDate?.millisecondsSinceEpoch,
      'usage_count': usageCount,
      'is_favorite': isFavorite ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'tags': tags.join(','),
      'export_data': jsonEncode(toJson()),
    };
  }

  /// Create model from database map
  factory AvatarConfigurationModel.fromMap(Map<String, dynamic> map) {
    try {
      debugPrint('AvatarConfigurationModel.fromMap called with map: $map');

      // Parse personality data with enhanced error handling
      final personalityData =
          jsonDecode(map['personality_data'] as String) as Map<String, dynamic>;
      debugPrint('Parsed personalityData: $personalityData');

      final personalityTypeStr = personalityData['type'] as String;
      debugPrint('personalityTypeStr: $personalityTypeStr');

      // Enhanced personality type validation and conversion
      PersonalityType personalityType;
      try {
        personalityType = PersonalityType.values.firstWhere(
          (e) => e.name == personalityTypeStr,
          orElse: () {
            debugPrint('WARNING: PersonalityType $personalityTypeStr not found, using casual');
            return PersonalityType.casual;
          },
        );
      } catch (e) {
        debugPrint('ERROR: Failed to resolve personality type: $e');
        personalityType = PersonalityType.casual;
      }
      debugPrint('Resolved personalityType: $personalityType');

      // Parse voice data
      final voiceData =
          jsonDecode(map['voice_data'] as String) as Map<String, dynamic>;
      debugPrint('Parsed voiceData: $voiceData');
      final voiceConfiguration = voice_model.VoiceConfigurationModel.fromJson(
        voiceData,
      );

      // Parse tags
      final tagsString = map['tags'] as String?;
      final tags = tagsString?.isNotEmpty == true
          ? tagsString!.split(',').where((tag) => tag.isNotEmpty).toList()
          : <String>[];
      debugPrint('Parsed tags: $tags');

      final model = AvatarConfigurationModel(
        id: map['id'] as String,
        name: map['name'] as String,
        description: map['description'] as String?,
        personalityType: personalityType,
        voiceConfiguration: voiceConfiguration,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_date'] as int,
        ),
        lastModified: DateTime.fromMillisecondsSinceEpoch(
          map['updated_date'] as int,
        ),
        lastUsedDate: map['last_used_date'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['last_used_date'] as int)
            : null,
        usageCount: map['usage_count'] as int? ?? 0,
        isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
        isActive: (map['is_active'] as int? ?? 0) == 1,
        tags: tags,
      );

      debugPrint('Successfully created AvatarConfigurationModel: $model');
      return model;
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed to create AvatarConfigurationModel from map: $e');
      debugPrint('ERROR: Stack trace: $stackTrace');
      debugPrint('ERROR: Map data: $map');
      rethrow;
    }
  }

  /// Convert to domain entity using string-based conversion approach
  AvatarConfiguration toDomain() {
    try {
      debugPrint('AvatarConfigurationModel.toDomain() called');
      debugPrint('Model personalityType: $personalityType');
      debugPrint('Model personalityType.name: ${personalityType.name}');

      // Use the new string-based conversion method
      final domainVoiceConfig = _convertToEntityVoiceConfiguration(
        voiceConfiguration,
      );
      debugPrint('Converted domain voiceConfiguration: $domainVoiceConfig');

      // Use the string-based conversion to avoid enum type conflicts
      final personalityTypeStr = _convertToEntityPersonalityType(
        personalityType,
      );
      debugPrint('Converted personalityTypeStr: $personalityTypeStr');

      final result = AvatarConfiguration.createFromString(
        id: id,
        name: name,
        personalityTypeStr: personalityTypeStr,
        voiceConfiguration: domainVoiceConfig,
        isActive: isActive,
      ).copyWith(createdAt: createdAt, lastModified: lastModified);

      debugPrint('Successfully created domain entity: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed to convert model to domain: $e');
      debugPrint('ERROR: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Helper to convert model PersonalityType to entity PersonalityType
  String _convertToEntityPersonalityType(PersonalityType modelType) {
    try {
      debugPrint('_convertToEntityPersonalityType called with: $modelType');

      // Map model PersonalityType to domain PersonalityType using string comparison
      // Since we can't import domain entities directly, we'll return the enum name
      // and let the domain layer handle the actual enum creation
      debugPrint('Mapping ${modelType.name} to domain');

      // Return the enum name as a string for the domain layer to handle
      return modelType.name;
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed to convert personality type: $e');
      debugPrint('ERROR: Stack trace: $stackTrace');
      return 'casual'; // Fallback as string
    }
  }

  /// Helper to convert model VoiceConfiguration to entity VoiceConfiguration
  VoiceConfiguration _convertToEntityVoiceConfiguration(
    voice_model.VoiceConfigurationModel modelVoice,
  ) {
    try {
      debugPrint('Converting VoiceConfigurationModel to VoiceConfiguration');
      debugPrint('Model voice: ${modelVoice.voiceId}, ${modelVoice.name}, ${modelVoice.gender}');

      // Convert Gender enum from model to domain
      final domainGender = _convertGenderToDomain(modelVoice.gender as dynamic);

      // Convert VoiceSettingsModel to VoiceSettings
      final domainSettings = VoiceSettings(
        stability: modelVoice.settings.stability,
        similarityBoost: modelVoice.settings.similarityBoost,
        style: modelVoice.settings.style,
        useSpeakerBoost: modelVoice.settings.useSpeakerBoost,
      );

      final result = VoiceConfiguration(
        voiceId: modelVoice.voiceId,
        name: modelVoice.name,
        gender: domainGender,
        language: modelVoice.language,
        accent: modelVoice.accent,
        settings: domainSettings,
      );

      debugPrint('Successfully converted to domain: $result');
      return result;
    } catch (e, stackTrace) {
      debugPrint('ERROR: Failed to convert VoiceConfigurationModel to VoiceConfiguration: $e');
      debugPrint('ERROR: Stack trace: $stackTrace');
      debugPrint('ERROR: Model voice data: $modelVoice');
      rethrow;
    }
  }

  /// Convert model Gender to domain Gender
  Gender _convertGenderToDomain(dynamic modelGender) {
    debugPrint('Converting gender from model to domain: $modelGender');
    // Handle both enum and string values
    if (modelGender is String) {
      switch (modelGender.toLowerCase()) {
        case 'male':
          return Gender.male;
        case 'female':
          return Gender.female;
        default:
          return Gender.neutral;
      }
    } else if (modelGender is voice_model.Gender) {
      switch (modelGender) {
        case voice_model.Gender.male:
          return Gender.male;
        case voice_model.Gender.female:
          return Gender.female;
        case voice_model.Gender.neutral:
          return Gender.neutral;
      }
    }
    // Fallback to neutral if conversion fails
    return Gender.neutral;
  }

  /// Create from domain entity (simplified)
  factory AvatarConfigurationModel.fromDomain(AvatarConfiguration domain) {
    return AvatarConfigurationModel(
      id: domain.id,
      name: domain.name,
      personalityType: _convertFromEntityPersonalityType(
        domain.personalityType,
      ),
      voiceConfiguration: _convertFromEntityVoiceConfiguration(
        domain.voiceConfiguration,
      ),
      createdAt: domain.createdAt,
      lastModified: domain.lastModified,
      isActive: domain.isActive,
    );
  }

  /// Helper to convert entity PersonalityType to model PersonalityType
  static PersonalityType _convertFromEntityPersonalityType(dynamic entityType) {
    // Simplified conversion - assuming same enum structure
    return PersonalityType.casual; // Default for now
  }

  /// Helper to convert entity VoiceConfiguration to model VoiceConfiguration
  static voice_model.VoiceConfigurationModel
  _convertFromEntityVoiceConfiguration(dynamic entityVoice) {
    // Simplified conversion - you'd want proper mapping here
    // Return a default voice configuration
    return voice_model.VoiceConfigurationModel(
      voiceId: 'default',
      name: 'Default Voice',
      gender: voice_model.Gender.neutral,
      language: 'English',
      accent: 'American',
      settings: voice_model.VoiceSettingsModel.defaultSettings,
    );
  }

  /// Export configuration for backup
  Map<String, dynamic> toExportData() {
    return {
      'version': '2.0',
      'exported_at': DateTime.now().toIso8601String(),
      'configuration': toJson(),
      'metadata': {
        'usage_count': usageCount,
        'is_favorite': isFavorite,
        'tags': tags,
        'created_date': createdAt.toIso8601String(),
        'last_modified': lastModified.toIso8601String(),
        'last_used_date': lastUsedDate?.toIso8601String(),
      },
    };
  }

  /// Import configuration from backup
  factory AvatarConfigurationModel.fromExportData(
    Map<String, dynamic> exportData,
  ) {
    final configData = exportData['configuration'] as Map<String, dynamic>;
    final metadata = exportData['metadata'] as Map<String, dynamic>?;

    var model = AvatarConfigurationModel.fromJson(configData);

    // Apply metadata if available
    if (metadata != null) {
      model = model.copyWith(
        usageCount: metadata['usage_count'] as int?,
        isFavorite: metadata['is_favorite'] as bool?,
        tags: (metadata['tags'] as List<dynamic>?)?.cast<String>(),
        lastUsedDate: metadata['last_used_date'] != null
            ? DateTime.parse(metadata['last_used_date'] as String)
            : null,
      );
    }

    return model;
  }

  /// Create a duplicate with a new ID
  AvatarConfigurationModel duplicate(String newId) {
    final now = DateTime.now();
    return copyWith(
      id: newId,
      name: '$name (Copy)',
      createdAt: now,
      lastModified: now,
      lastUsedDate: null,
      usageCount: 0,
      isActive: false,
    );
  }

  /// Search match helper
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return name.toLowerCase().contains(lowerQuery) ||
        (description?.toLowerCase().contains(lowerQuery) ?? false) ||
        personalityDisplayName.toLowerCase().contains(lowerQuery) ||
        voiceName.toLowerCase().contains(lowerQuery) ||
        tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
  }
}
