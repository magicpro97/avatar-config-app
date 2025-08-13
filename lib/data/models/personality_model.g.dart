// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personality_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PersonalityModel _$PersonalityModelFromJson(Map<String, dynamic> json) =>
    PersonalityModel(
      type: $enumDecode(_$PersonalityTypeEnumMap, json['type']),
      displayName: json['display_name'] as String,
      description: json['description'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$PersonalityModelToJson(PersonalityModel instance) =>
    <String, dynamic>{
      'type': _$PersonalityTypeEnumMap[instance.type]!,
      'display_name': instance.displayName,
      'description': instance.description,
      'parameters': instance.parameters,
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
