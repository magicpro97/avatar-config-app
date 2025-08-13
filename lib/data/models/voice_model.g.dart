// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VoiceSettingsModel _$VoiceSettingsModelFromJson(Map<String, dynamic> json) =>
    VoiceSettingsModel(
      stability: (json['stability'] as num).toDouble(),
      similarityBoost: (json['similarity_boost'] as num).toDouble(),
      style: (json['style'] as num).toDouble(),
      useSpeakerBoost: json['use_speaker_boost'] as bool,
    );

Map<String, dynamic> _$VoiceSettingsModelToJson(VoiceSettingsModel instance) =>
    <String, dynamic>{
      'stability': instance.stability,
      'similarity_boost': instance.similarityBoost,
      'style': instance.style,
      'use_speaker_boost': instance.useSpeakerBoost,
    };

VoiceConfigurationModel _$VoiceConfigurationModelFromJson(
  Map<String, dynamic> json,
) => VoiceConfigurationModel(
  voiceId: json['voice_id'] as String,
  name: json['name'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  language: json['language'] as String,
  accent: json['accent'] as String,
  settings: VoiceSettingsModel.fromJson(
    json['settings'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$VoiceConfigurationModelToJson(
  VoiceConfigurationModel instance,
) => <String, dynamic>{
  'voice_id': instance.voiceId,
  'name': instance.name,
  'gender': _$GenderEnumMap[instance.gender]!,
  'language': instance.language,
  'accent': instance.accent,
  'settings': instance.settings,
};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.neutral: 'neutral',
};

ElevenLabsVoiceModel _$ElevenLabsVoiceModelFromJson(
  Map<String, dynamic> json,
) => ElevenLabsVoiceModel(
  voiceId: json['voice_id'] as String,
  name: json['name'] as String,
  previewUrl: json['preview_url'] as String?,
  labels: Map<String, String>.from(json['labels'] as Map),
  settings: json['settings'] == null
      ? null
      : VoiceSettingsModel.fromJson(json['settings'] as Map<String, dynamic>),
  available: json['available'] as bool,
);

Map<String, dynamic> _$ElevenLabsVoiceModelToJson(
  ElevenLabsVoiceModel instance,
) => <String, dynamic>{
  'voice_id': instance.voiceId,
  'name': instance.name,
  'preview_url': instance.previewUrl,
  'labels': instance.labels,
  'settings': instance.settings,
  'available': instance.available,
};
