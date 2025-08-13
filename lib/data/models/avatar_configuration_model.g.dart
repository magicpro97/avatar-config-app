// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_configuration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AvatarConfigurationModel _$AvatarConfigurationModelFromJson(
  Map<String, dynamic> json,
) => AvatarConfigurationModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  personalityType: $enumDecode(
    _$PersonalityTypeEnumMap,
    json['personality_type'],
  ),
  voiceConfiguration: voice_model.VoiceConfigurationModel.fromJson(
    json['voice_configuration'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['created_at'] as String),
  lastModified: DateTime.parse(json['last_modified'] as String),
  lastUsedDate: json['last_used_date'] == null
      ? null
      : DateTime.parse(json['last_used_date'] as String),
  usageCount: (json['usage_count'] as num?)?.toInt() ?? 0,
  isFavorite: json['is_favorite'] as bool? ?? false,
  isActive: json['is_active'] as bool,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$AvatarConfigurationModelToJson(
  AvatarConfigurationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'personality_type': _$PersonalityTypeEnumMap[instance.personalityType]!,
  'voice_configuration': instance.voiceConfiguration,
  'created_at': instance.createdAt.toIso8601String(),
  'last_modified': instance.lastModified.toIso8601String(),
  'last_used_date': instance.lastUsedDate?.toIso8601String(),
  'usage_count': instance.usageCount,
  'is_favorite': instance.isFavorite,
  'is_active': instance.isActive,
  'tags': instance.tags,
};

const _$PersonalityTypeEnumMap = {
  PersonalityType.happy: 'happy',
  PersonalityType.romantic: 'romantic',
  PersonalityType.funny: 'funny',
  PersonalityType.professional: 'professional',
  PersonalityType.casual: 'casual',
  PersonalityType.energetic: 'energetic',
  PersonalityType.calm: 'calm',
  PersonalityType.mysterious: 'mysterious',
};
