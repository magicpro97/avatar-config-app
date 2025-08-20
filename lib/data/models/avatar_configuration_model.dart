// Avatar Configuration Data Model with Database Support
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import '../../domain/entities/avatar_configuration.dart';
import '../../domain/entities/voice.dart';
import 'personality_model.dart' as personality_model;
import '../../domain/entities/personality.dart' as domain_personality;
import 'voice_model.dart' as voice_model;

part 'avatar_configuration_model.g.dart';

typedef PersonalityType = personality_model.PersonalityType; // alias for generated code compatibility
typedef PersonalityModel = personality_model.PersonalityModel;

@JsonSerializable()
class AvatarConfigurationModel {
  final String id;
  final String name;
  final String? description;
  @JsonKey(name: 'personality_type')
  final personality_model.PersonalityType personalityType;
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
    personality_model.PersonalityType? personalityType,
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
  personality_model.PersonalityModel get personality {
    switch (personalityType) {
      case personality_model.PersonalityType.happy:
        return personality_model.PersonalityModel.happy;
      case personality_model.PersonalityType.romantic:
        return personality_model.PersonalityModel.romantic;
      case personality_model.PersonalityType.funny:
        return personality_model.PersonalityModel.funny;
      case personality_model.PersonalityType.professional:
        return personality_model.PersonalityModel.professional;
      case personality_model.PersonalityType.casual:
        return personality_model.PersonalityModel.casual;
      case personality_model.PersonalityType.energetic:
        return personality_model.PersonalityModel.energetic;
      case personality_model.PersonalityType.calm:
        return personality_model.PersonalityModel.calm;
      case personality_model.PersonalityType.mysterious:
        return personality_model.PersonalityModel.mysterious;
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
      print('DEBUG: AvatarConfigurationModel.fromMap called with map: $map');

      // Parse personality data with enhanced error handling
      final personalityData =
          jsonDecode(map['personality_data'] as String) as Map<String, dynamic>;
      print('DEBUG: Parsed personalityData: $personalityData');

      final personalityTypeStr = personalityData['type'] as String;
      print('DEBUG: personalityTypeStr: $personalityTypeStr');

      // Enhanced personality type validation and conversion
      personality_model.PersonalityType personalityType;
      try {
        personalityType = personality_model.PersonalityType.values.firstWhere(
          (e) => e.name == personalityTypeStr,
          orElse: () {
            print(
              'WARNING: PersonalityType $personalityTypeStr not found, using casual',
            );
            return personality_model.PersonalityType.casual;
          },
        );
      } catch (e) {
        print('ERROR: Failed to resolve personality type: $e');
        personalityType = personality_model.PersonalityType.casual;
      }
      print('DEBUG: Resolved personalityType: $personalityType');

      // Parse voice data
      final voiceData =
          jsonDecode(map['voice_data'] as String) as Map<String, dynamic>;
      print('DEBUG: Parsed voiceData: $voiceData');
      final voiceConfiguration = voice_model.VoiceConfigurationModel.fromJson(
        voiceData,
      );

      // Parse tags
      final tagsString = map['tags'] as String?;
      final tags = tagsString?.isNotEmpty == true
          ? tagsString!.split(',').where((tag) => tag.isNotEmpty).toList()
          : <String>[];
      print('DEBUG: Parsed tags: $tags');

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

      print('DEBUG: Successfully created AvatarConfigurationModel: $model');
      return model;
    } catch (e, stackTrace) {
      print('ERROR: Failed to create AvatarConfigurationModel from map: $e');
      print('ERROR: Stack trace: $stackTrace');
      print('ERROR: Map data: $map');
      rethrow;
    }
  }

  /// Convert to domain entity using string-based conversion approach
  AvatarConfiguration toDomain() {
    try {
      print('DEBUG: AvatarConfigurationModel.toDomain() called');
      print('DEBUG: Model personalityType: $personalityType');
      print('DEBUG: Model personalityType.name: ${personalityType.name}');

      // Use the new string-based conversion method
      final domainVoiceConfig = _convertToEntityVoiceConfiguration(
        voiceConfiguration,
      );
      print('DEBUG: Converted domain voiceConfiguration: $domainVoiceConfig');

      // Use the string-based conversion to avoid enum type conflicts
      final personalityTypeStr = _convertToEntityPersonalityType(
        personalityType,
      );
      print('DEBUG: Converted personalityTypeStr: $personalityTypeStr');

      final result = AvatarConfiguration.createFromString(
        id: id,
        name: name,
        personalityTypeStr: personalityTypeStr,
        voiceConfiguration: domainVoiceConfig,
        isActive: isActive,
      ).copyWith(createdAt: createdAt, lastModified: lastModified);

      print('DEBUG: Successfully created domain entity: $result');
      return result;
    } catch (e, stackTrace) {
      print('ERROR: Failed to convert model to domain: $e');
      print('ERROR: Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Helper to convert model PersonalityType to entity PersonalityType
  String _convertToEntityPersonalityType(personality_model.PersonalityType modelType) {
    try {
      print('DEBUG: _convertToEntityPersonalityType called with: $modelType');

      // Map model PersonalityType to domain PersonalityType using string comparison
      // Since we can't import domain entities directly, we'll return the enum name
      // and let the domain layer handle the actual enum creation
      print('DEBUG: Mapping ${modelType.name} to domain');

      // Return the enum name as a string for the domain layer to handle
      return modelType.name;
    } catch (e, stackTrace) {
      print('ERROR: Failed to convert personality type: $e');
      print('ERROR: Stack trace: $stackTrace');
      return 'casual'; // Fallback as string
    }
  }

  /// Helper to convert model VoiceConfiguration to entity VoiceConfiguration
  VoiceConfiguration _convertToEntityVoiceConfiguration(
    voice_model.VoiceConfigurationModel modelVoice,
  ) {
    try {
      print('DEBUG: Converting VoiceConfigurationModel to VoiceConfiguration');
      print(
        'DEBUG: Model voice: ${modelVoice.voiceId}, ${modelVoice.name}, ${modelVoice.gender}',
      );

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

      print('DEBUG: Successfully converted to domain: $result');
      return result;
    } catch (e, stackTrace) {
      print(
        'ERROR: Failed to convert VoiceConfigurationModel to VoiceConfiguration: $e',
      );
      print('ERROR: Stack trace: $stackTrace');
      print('ERROR: Model voice data: $modelVoice');
      rethrow;
    }
  }

  /// Convert model Gender to domain Gender
  Gender _convertGenderToDomain(dynamic modelGender) {
    print('DEBUG: Converting gender from model to domain: $modelGender');
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
  static personality_model.PersonalityType _convertFromEntityPersonalityType(
    dynamic entityType,
  ) {
    // Convert from domain PersonalityType to model PersonalityType
    if (entityType is domain_personality.PersonalityType) {
      switch (entityType) {
        case domain_personality.PersonalityType.happy:
          return personality_model.PersonalityType.happy;
        case domain_personality.PersonalityType.romantic:
          return personality_model.PersonalityType.romantic;
        case domain_personality.PersonalityType.funny:
          return personality_model.PersonalityType.funny;
        case domain_personality.PersonalityType.professional:
          return personality_model.PersonalityType.professional;
        case domain_personality.PersonalityType.casual:
          return personality_model.PersonalityType.casual;
        case domain_personality.PersonalityType.energetic:
          return personality_model.PersonalityType.energetic;
        case domain_personality.PersonalityType.calm:
          return personality_model.PersonalityType.calm;
        case domain_personality.PersonalityType.mysterious:
          return personality_model.PersonalityType.mysterious;
      }
    }

    // If it's a string, parse it
    if (entityType is String) {
      switch (entityType.toLowerCase()) {
        case 'happy':
          return personality_model.PersonalityType.happy;
        case 'romantic':
          return personality_model.PersonalityType.romantic;
        case 'funny':
          return personality_model.PersonalityType.funny;
        case 'professional':
          return personality_model.PersonalityType.professional;
        case 'casual':
          return personality_model.PersonalityType.casual;
        case 'energetic':
          return personality_model.PersonalityType.energetic;
        case 'calm':
          return personality_model.PersonalityType.calm;
        case 'mysterious':
          return personality_model.PersonalityType.mysterious;
        default:
          return personality_model.PersonalityType.casual;
      }
    }

    // Default fallback
    return personality_model.PersonalityType.casual;
  }

  /// Helper to convert entity VoiceConfiguration to model VoiceConfiguration
  static voice_model.VoiceConfigurationModel
  _convertFromEntityVoiceConfiguration(dynamic entityVoice) {
    // Convert from domain VoiceConfiguration to model VoiceConfiguration
    if (entityVoice is VoiceConfiguration) {
      // Convert domain entity to model
      return voice_model.VoiceConfigurationModel(
        voiceId: entityVoice.voiceId,
        name: entityVoice.name,
        gender: _convertGender(entityVoice.gender),
        language: entityVoice.language,
        accent: entityVoice.accent,
        settings: _convertVoiceSettings(entityVoice.settings),
      );
    }
    
    // If it's already a model, return as is
    if (entityVoice is voice_model.VoiceConfigurationModel) {
      return entityVoice;
    }
    
    // Default fallback voice configuration
    return voice_model.VoiceConfigurationModel(
      voiceId: 'default_voice',
      name: 'Default Voice',
      gender: voice_model.Gender.neutral,
      language: 'Vietnamese',
      accent: 'Northern',
      settings: voice_model.VoiceSettingsModel.defaultSettings,
    );
  }

  /// Helper to convert Gender enum
  static voice_model.Gender _convertGender(Gender domainGender) {
    switch (domainGender) {
      case Gender.male:
        return voice_model.Gender.male;
      case Gender.female:
        return voice_model.Gender.female;
      case Gender.neutral:
        return voice_model.Gender.neutral;
    }
  }

  /// Helper to convert VoiceSettings
  static voice_model.VoiceSettingsModel _convertVoiceSettings(VoiceSettings domainSettings) {
    return voice_model.VoiceSettingsModel(
      stability: domainSettings.stability,
      similarityBoost: domainSettings.similarityBoost,
      style: domainSettings.style,
      useSpeakerBoost: domainSettings.useSpeakerBoost,
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
