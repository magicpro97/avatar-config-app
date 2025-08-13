// Voice Data Models
import 'package:json_annotation/json_annotation.dart';

part 'voice_model.g.dart';

enum Gender {
  @JsonValue('male')
  male,
  @JsonValue('female')
  female,
  @JsonValue('neutral')
  neutral,
}

@JsonSerializable()
class VoiceSettingsModel {
  final double stability;
  @JsonKey(name: 'similarity_boost')
  final double similarityBoost;
  final double style;
  @JsonKey(name: 'use_speaker_boost')
  final bool useSpeakerBoost;

  const VoiceSettingsModel({
    required this.stability,
    required this.similarityBoost,
    required this.style,
    required this.useSpeakerBoost,
  });

  factory VoiceSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$VoiceSettingsModelFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceSettingsModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceSettingsModel &&
          runtimeType == other.runtimeType &&
          stability == other.stability &&
          similarityBoost == other.similarityBoost &&
          style == other.style &&
          useSpeakerBoost == other.useSpeakerBoost;

  @override
  int get hashCode =>
      stability.hashCode ^
      similarityBoost.hashCode ^
      style.hashCode ^
      useSpeakerBoost.hashCode;

  VoiceSettingsModel copyWith({
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
  }) {
    return VoiceSettingsModel(
      stability: stability ?? this.stability,
      similarityBoost: similarityBoost ?? this.similarityBoost,
      style: style ?? this.style,
      useSpeakerBoost: useSpeakerBoost ?? this.useSpeakerBoost,
    );
  }

  // Default settings
  static const VoiceSettingsModel defaultSettings = VoiceSettingsModel(
    stability: 0.5,
    similarityBoost: 0.5,
    style: 0.0,
    useSpeakerBoost: true,
  );
}

@JsonSerializable()
class VoiceConfigurationModel {
  @JsonKey(name: 'voice_id')
  final String voiceId;
  final String name;
  final Gender gender;
  final String language;
  final String accent;
  final VoiceSettingsModel settings;

  const VoiceConfigurationModel({
    required this.voiceId,
    required this.name,
    required this.gender,
    required this.language,
    required this.accent,
    required this.settings,
  });

  factory VoiceConfigurationModel.fromJson(Map<String, dynamic> json) =>
      _$VoiceConfigurationModelFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceConfigurationModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceConfigurationModel &&
          runtimeType == other.runtimeType &&
          voiceId == other.voiceId &&
          name == other.name &&
          gender == other.gender &&
          language == other.language &&
          accent == other.accent &&
          settings == other.settings;

  @override
  int get hashCode =>
      voiceId.hashCode ^
      name.hashCode ^
      gender.hashCode ^
      language.hashCode ^
      accent.hashCode ^
      settings.hashCode;

  VoiceConfigurationModel copyWith({
    String? voiceId,
    String? name,
    Gender? gender,
    String? language,
    String? accent,
    VoiceSettingsModel? settings,
  }) {
    return VoiceConfigurationModel(
      voiceId: voiceId ?? this.voiceId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      accent: accent ?? this.accent,
      settings: settings ?? this.settings,
    );
  }
}

@JsonSerializable()
class ElevenLabsVoiceModel {
  @JsonKey(name: 'voice_id')
  final String voiceId;
  final String name;
  @JsonKey(name: 'preview_url')
  final String? previewUrl;
  final Map<String, String> labels;
  final VoiceSettingsModel? settings;
  final bool available;

  const ElevenLabsVoiceModel({
    required this.voiceId,
    required this.name,
    this.previewUrl,
    required this.labels,
    this.settings,
    required this.available,
  });

  factory ElevenLabsVoiceModel.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsVoiceModelFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsVoiceModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ElevenLabsVoiceModel &&
          runtimeType == other.runtimeType &&
          voiceId == other.voiceId &&
          name == other.name &&
          previewUrl == other.previewUrl &&
          available == other.available;

  @override
  int get hashCode =>
      voiceId.hashCode ^ name.hashCode ^ previewUrl.hashCode ^ available.hashCode;

  ElevenLabsVoiceModel copyWith({
    String? voiceId,
    String? name,
    String? previewUrl,
    Map<String, String>? labels,
    VoiceSettingsModel? settings,
    bool? available,
  }) {
    return ElevenLabsVoiceModel(
      voiceId: voiceId ?? this.voiceId,
      name: name ?? this.name,
      previewUrl: previewUrl ?? this.previewUrl,
      labels: labels ?? this.labels,
      settings: settings ?? this.settings,
      available: available ?? this.available,
    );
  }

  // Helper getters
  Gender get gender {
    final genderLabel = labels['gender']?.toLowerCase();
    switch (genderLabel) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.neutral;
    }
  }

  String get language => labels['language'] ?? 'English';
  String get accent => labels['accent'] ?? 'American';
  String get ageGroup => labels['age'] ?? 'Adult';
  String get description => labels['description'] ?? '';
}