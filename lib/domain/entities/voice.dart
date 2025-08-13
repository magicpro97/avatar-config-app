// Domain Entity for Voice
import 'package:equatable/equatable.dart';

enum Gender {
  male,
  female,
  neutral,
}

class VoiceSettings extends Equatable {
  final double stability;
  final double similarityBoost;
  final double style;
  final bool useSpeakerBoost;

  const VoiceSettings({
    required this.stability,
    required this.similarityBoost,
    required this.style,
    required this.useSpeakerBoost,
  });

  @override
  List<Object> get props => [stability, similarityBoost, style, useSpeakerBoost];

  VoiceSettings copyWith({
    double? stability,
    double? similarityBoost,
    double? style,
    bool? useSpeakerBoost,
  }) {
    return VoiceSettings(
      stability: stability ?? this.stability,
      similarityBoost: similarityBoost ?? this.similarityBoost,
      style: style ?? this.style,
      useSpeakerBoost: useSpeakerBoost ?? this.useSpeakerBoost,
    );
  }

  // Default settings
  static const VoiceSettings defaultSettings = VoiceSettings(
    stability: 0.5,
    similarityBoost: 0.5,
    style: 0.0,
    useSpeakerBoost: true,
  );
}

class VoiceConfiguration extends Equatable {
  final String voiceId;
  final String name;
  final Gender gender;
  final String language;
  final String accent;
  final VoiceSettings settings;

  const VoiceConfiguration({
    required this.voiceId,
    required this.name,
    required this.gender,
    required this.language,
    required this.accent,
    required this.settings,
  });

  @override
  List<Object> get props => [voiceId, name, gender, language, accent, settings];

  VoiceConfiguration copyWith({
    String? voiceId,
    String? name,
    Gender? gender,
    String? language,
    String? accent,
    VoiceSettings? settings,
  }) {
    return VoiceConfiguration(
      voiceId: voiceId ?? this.voiceId,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      accent: accent ?? this.accent,
      settings: settings ?? this.settings,
    );
  }

  @override
  String toString() {
    return 'VoiceConfiguration(voiceId: $voiceId, name: $name, gender: $gender, language: $language)';
  }
}

class ElevenLabsVoice extends Equatable {
  final String voiceId;
  final String name;
  final String? previewUrl;
  final Map<String, String> labels;
  final VoiceSettings? settings;
  final bool available;

  const ElevenLabsVoice({
    required this.voiceId,
    required this.name,
    this.previewUrl,
    required this.labels,
    this.settings,
    required this.available,
  });

  @override
  List<Object?> get props => [voiceId, name, previewUrl, labels, settings, available];

  ElevenLabsVoice copyWith({
    String? voiceId,
    String? name,
    String? previewUrl,
    Map<String, String>? labels,
    VoiceSettings? settings,
    bool? available,
  }) {
    return ElevenLabsVoice(
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

  // Convert to VoiceConfiguration
  VoiceConfiguration toVoiceConfiguration() {
    return VoiceConfiguration(
      voiceId: voiceId,
      name: name,
      gender: gender,
      language: language,
      accent: accent,
      settings: settings ?? VoiceSettings.defaultSettings,
    );
  }

  @override
  String toString() {
    return 'ElevenLabsVoice(voiceId: $voiceId, name: $name, gender: $gender, available: $available)';
  }
}