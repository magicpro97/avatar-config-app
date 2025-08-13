// ElevenLabs API Models and DTOs
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'voice_model.dart';

part 'elevenlabs_models.g.dart';

// API Response Models
@JsonSerializable()
class ElevenLabsVoicesResponse {
  final List<ElevenLabsVoiceResponse> voices;

  const ElevenLabsVoicesResponse({
    required this.voices,
  });

  factory ElevenLabsVoicesResponse.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsVoicesResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsVoicesResponseToJson(this);
}

@JsonSerializable()
class ElevenLabsVoiceResponse {
  @JsonKey(name: 'voice_id')
  final String voiceId;
  final String name;
  @JsonKey(name: 'preview_url')
  final String? previewUrl;
  final Map<String, dynamic> labels;
  final ElevenLabsVoiceSettingsResponse? settings;
  @JsonKey(name: 'available_for_tiers')
  final List<String>? availableForTiers;
  final String category;
  @JsonKey(name: 'fine_tuning')
  final FineTuningResponse? fineTuning;
  final String? description;
  final dynamic samples;
  final dynamic sharing;
  @JsonKey(name: 'high_quality_base_model_ids')
  final List<String>? highQualityBaseModelIds;
  @JsonKey(name: 'safety_control')
  final dynamic safetyControl;
  @JsonKey(name: 'voice_verification')
  final dynamic voiceVerification;
  @JsonKey(name: 'permission_on_resource')
  final dynamic permissionOnResource;
  @JsonKey(name: 'is_owner')
  final bool? isOwner;
  @JsonKey(name: 'is_legacy')
  final bool? isLegacy;
  @JsonKey(name: 'is_mixed')
  final bool? isMixed;
  @JsonKey(name: 'created_at_unix')
  final int? createdAtUnix;
  @JsonKey(name: 'verified_languages')
  final List<dynamic>? verifiedLanguages;

  const ElevenLabsVoiceResponse({
    required this.voiceId,
    required this.name,
    this.previewUrl,
    required this.labels,
    this.settings,
    this.availableForTiers,
    required this.category,
    this.fineTuning,
    this.description,
    this.samples,
    this.sharing,
    this.highQualityBaseModelIds,
    this.safetyControl,
    this.voiceVerification,
    this.permissionOnResource,
    this.isOwner,
    this.isLegacy,
    this.isMixed,
    this.createdAtUnix,
    this.verifiedLanguages,
  });

  factory ElevenLabsVoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsVoiceResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsVoiceResponseToJson(this);

  // Convert to domain model
  ElevenLabsVoiceModel toDomain() {
    // Process labels to extract proper metadata
    final processedLabels = <String, String>{};
    
    // Handle different label formats from ElevenLabs API
    if (labels['gender'] != null) {
      processedLabels['gender'] = labels['gender'].toString();
    }
    if (labels['accent'] != null) {
      processedLabels['accent'] = labels['accent'].toString();
    }
    if (labels['language'] != null) {
      processedLabels['language'] = labels['language'].toString();
    }
    if (labels['age'] != null) {
      processedLabels['age'] = labels['age'].toString();
    }
    if (labels['description'] != null) {
      processedLabels['description'] = labels['description'].toString();
    }
    if (labels['descriptive'] != null) {
      processedLabels['description'] = labels['descriptive'].toString();
    }

    return ElevenLabsVoiceModel(
      voiceId: voiceId,
      name: name,
      previewUrl: previewUrl,
      labels: processedLabels,
      settings: settings?.toDomain(),
      available: availableForTiers?.contains('free') ?? true,
    );
  }
}

@JsonSerializable()
class ElevenLabsVoiceSettingsResponse {
  final double stability;
  @JsonKey(name: 'similarity_boost')
  final double similarityBoost;
  final double? style;
  @JsonKey(name: 'use_speaker_boost')
  final bool? useSpeakerBoost;

  const ElevenLabsVoiceSettingsResponse({
    required this.stability,
    required this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
  });

  factory ElevenLabsVoiceSettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsVoiceSettingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsVoiceSettingsResponseToJson(this);

  // Convert to domain model
  VoiceSettingsModel toDomain() {
    return VoiceSettingsModel(
      stability: stability,
      similarityBoost: similarityBoost,
      style: style ?? 0.0,
      useSpeakerBoost: useSpeakerBoost ?? true,
    );
  }
}

@JsonSerializable()
class FineTuningResponse {
  @JsonKey(name: 'is_allowed_to_fine_tune')
  final bool isAllowedToFineTune;
  @JsonKey(fromJson: _stateFromJson, toJson: _stateToJson)
  final Map<String, dynamic>? state;
  @JsonKey(name: 'verification_attempts')
  final dynamic verificationAttempts;
  @JsonKey(name: 'verification_failures')
  final List<dynamic>? verificationFailures;
  @JsonKey(name: 'verification_attempts_count')
  final int? verificationAttemptsCount;
  @JsonKey(name: 'manual_verification_requested')
  final bool? manualVerificationRequested;
  final String? language;
  final dynamic progress;
  final dynamic message;
  @JsonKey(name: 'dataset_duration_seconds')
  final dynamic datasetDurationSeconds;
  @JsonKey(name: 'slice_ids')
  final dynamic sliceIds;
  @JsonKey(name: 'manual_verification')
  final dynamic manualVerification;
  @JsonKey(name: 'max_verification_attempts')
  final int? maxVerificationAttempts;
  @JsonKey(name: 'next_max_verification_attempts_reset_unix_ms')
  final int? nextMaxVerificationAttemptsResetUnixMs;

  const FineTuningResponse({
    required this.isAllowedToFineTune,
    this.state,
    this.verificationAttempts,
    this.verificationFailures,
    this.verificationAttemptsCount,
    this.manualVerificationRequested,
    this.language,
    this.progress,
    this.message,
    this.datasetDurationSeconds,
    this.sliceIds,
    this.manualVerification,
    this.maxVerificationAttempts,
    this.nextMaxVerificationAttemptsResetUnixMs,
  });

  factory FineTuningResponse.fromJson(Map<String, dynamic> json) =>
      _$FineTuningResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FineTuningResponseToJson(this);

  // Helper methods for state field conversion
  static Map<String, dynamic>? _stateFromJson(dynamic json) {
    if (json == null) return null;
    if (json is Map<String, dynamic>) {
      return json;
    }
    // If it's a string, try to parse it as JSON
    if (json is String) {
      try {
        return Map<String, dynamic>.from(jsonDecode(json));
      } catch (e) {
        // If parsing fails, return null or handle appropriately
        return null;
      }
    }
    return null;
  }

  static dynamic _stateToJson(Map<String, dynamic>? state) {
    return state;
  }
}

// Request Models
@JsonSerializable()
class VoiceSynthesisRequest {
  final String text;
  @JsonKey(name: 'voice_settings')
  final VoiceSettingsRequest voiceSettings;
  @JsonKey(name: 'model_id')
  final String modelId;
  @JsonKey(name: 'language_code', includeIfNull: false)
  final String? languageCode;
  @JsonKey(name: 'pronunciation_dictionary_locators')
  final List<String> pronunciationDictionaryLocators;
  final int seed;
  final String previousText;
  final String nextText;
  @JsonKey(name: 'previous_request_ids')
  final List<String> previousRequestIds;
  @JsonKey(name: 'next_request_ids')
  final List<String> nextRequestIds;
  @JsonKey(name: 'use_pvc_as_ivc')
  final bool usePvcAsIvc;
  @JsonKey(name: 'apply_text_normalization')
  final String applyTextNormalization;
  @JsonKey(name: 'apply_language_text_normalization')
  final bool applyLanguageTextNormalization;
  @JsonKey(includeIfNull: false)
  final Map<String, dynamic>? customJson;

  const VoiceSynthesisRequest({
    required this.text,
    required this.voiceSettings,
    required this.modelId,
    this.languageCode,
    required this.pronunciationDictionaryLocators,
    required this.seed,
    required this.previousText,
    required this.nextText,
    required this.previousRequestIds,
    required this.nextRequestIds,
    required this.usePvcAsIvc,
    required this.applyTextNormalization,
    required this.applyLanguageTextNormalization,
    this.customJson,
  });

  factory VoiceSynthesisRequest.fromJson(Map<String, dynamic> json) =>
      _$VoiceSynthesisRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceSynthesisRequestToJson(this);
}

@JsonSerializable()
class VoiceSettingsRequest {
  final double stability;
  @JsonKey(name: 'similarity_boost')
  final double similarityBoost;
  final double? style;
  @JsonKey(name: 'use_speaker_boost')
  final bool? useSpeakerBoost;

  const VoiceSettingsRequest({
    required this.stability,
    required this.similarityBoost,
    this.style,
    this.useSpeakerBoost,
  });

  factory VoiceSettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$VoiceSettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VoiceSettingsRequestToJson(this);

  // Create from domain model
  factory VoiceSettingsRequest.fromDomain(VoiceSettingsModel settings) {
    return VoiceSettingsRequest(
      stability: settings.stability,
      similarityBoost: settings.similarityBoost,
      style: settings.style,
      useSpeakerBoost: settings.useSpeakerBoost,
    );
  }
}

// Error Response Models
@JsonSerializable()
class ElevenLabsErrorResponse {
  final ElevenLabsErrorDetail detail;

  const ElevenLabsErrorResponse({
    required this.detail,
  });

  factory ElevenLabsErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsErrorResponseToJson(this);
}

@JsonSerializable()
class ElevenLabsErrorDetail {
  final String status;
  final String message;

  const ElevenLabsErrorDetail({
    required this.status,
    required this.message,
  });

  factory ElevenLabsErrorDetail.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsErrorDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsErrorDetailToJson(this);
}

// User Info Response (for API validation)
@JsonSerializable()
class ElevenLabsUserResponse {
  @JsonKey(name: 'subscription')
  final SubscriptionInfo subscription;
  @JsonKey(name: 'is_new_user')
  final bool isNewUser;
  @JsonKey(name: 'xi_api_key')
  final String? xiApiKey;

  const ElevenLabsUserResponse({
    required this.subscription,
    required this.isNewUser,
    this.xiApiKey,
  });

  factory ElevenLabsUserResponse.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsUserResponseToJson(this);
}

@JsonSerializable()
class SubscriptionInfo {
  final String tier;
  @JsonKey(name: 'character_count')
  final int characterCount;
  @JsonKey(name: 'character_limit')
  final int characterLimit;
  @JsonKey(name: 'can_extend_character_limit')
  final bool canExtendCharacterLimit;
  @JsonKey(name: 'allowed_to_extend_character_limit')
  final bool allowedToExtendCharacterLimit;
  @JsonKey(name: 'next_character_count_reset_unix')
  final int nextCharacterCountResetUnix;
  @JsonKey(name: 'voice_limit')
  final int voiceLimit;
  @JsonKey(name: 'max_voice_add_edits')
  final int maxVoiceAddEdits;
  @JsonKey(name: 'voice_add_edit_counter')
  final int voiceAddEditCounter;
  @JsonKey(name: 'professional_voice_limit')
  final int professionalVoiceLimit;
  @JsonKey(name: 'can_extend_voice_limit')
  final bool canExtendVoiceLimit;
  @JsonKey(name: 'can_use_instant_voice_cloning')
  final bool canUseInstantVoiceCloning;
  @JsonKey(name: 'can_use_professional_voice_cloning')
  final bool canUseProfessionalVoiceCloning;
  final String currency;
  final String status;

  const SubscriptionInfo({
    required this.tier,
    required this.characterCount,
    required this.characterLimit,
    required this.canExtendCharacterLimit,
    required this.allowedToExtendCharacterLimit,
    required this.nextCharacterCountResetUnix,
    required this.voiceLimit,
    required this.maxVoiceAddEdits,
    required this.voiceAddEditCounter,
    required this.professionalVoiceLimit,
    required this.canExtendVoiceLimit,
    required this.canUseInstantVoiceCloning,
    required this.canUseProfessionalVoiceCloning,
    required this.currency,
    required this.status,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionInfoFromJson(json);

  Map<String, dynamic> toJson() => _$SubscriptionInfoToJson(this);
}

// Voice Models Response (for text-to-speech endpoint)
@JsonSerializable()
class ElevenLabsModelsResponse {
  final List<ElevenLabsModelInfo> models;

  const ElevenLabsModelsResponse({
    required this.models,
  });

  factory ElevenLabsModelsResponse.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsModelsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsModelsResponseToJson(this);
}

@JsonSerializable()
class ElevenLabsModelInfo {
  @JsonKey(name: 'model_id')
  final String modelId;
  final String name;
  @JsonKey(name: 'can_be_finetuned')
  final bool canBeFinetuned;
  @JsonKey(name: 'can_do_text_to_speech')
  final bool canDoTextToSpeech;
  @JsonKey(name: 'can_do_voice_conversion')
  final bool canDoVoiceConversion;
  @JsonKey(name: 'can_use_style')
  final bool canUseStyle;
  @JsonKey(name: 'can_use_speaker_boost')
  final bool canUseSpeakerBoost;
  @JsonKey(name: 'serves_pro_voices')
  final bool servesProVoices;
  @JsonKey(name: 'token_cost_factor')
  final double tokenCostFactor;
  final String description;
  final String language;
  @JsonKey(name: 'max_characters_request_free_user')
  final int maxCharactersRequestFreeUser;
  @JsonKey(name: 'max_characters_request_subscribed_user')
  final int maxCharactersRequestSubscribedUser;

  const ElevenLabsModelInfo({
    required this.modelId,
    required this.name,
    required this.canBeFinetuned,
    required this.canDoTextToSpeech,
    required this.canDoVoiceConversion,
    required this.canUseStyle,
    required this.canUseSpeakerBoost,
    required this.servesProVoices,
    required this.tokenCostFactor,
    required this.description,
    required this.language,
    required this.maxCharactersRequestFreeUser,
    required this.maxCharactersRequestSubscribedUser,
  });

  factory ElevenLabsModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ElevenLabsModelInfoFromJson(json);

  Map<String, dynamic> toJson() => _$ElevenLabsModelInfoToJson(this);
}