// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'elevenlabs_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ElevenLabsVoicesResponse _$ElevenLabsVoicesResponseFromJson(
  Map<String, dynamic> json,
) => ElevenLabsVoicesResponse(
  voices: (json['voices'] as List<dynamic>)
      .map((e) => ElevenLabsVoiceResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ElevenLabsVoicesResponseToJson(
  ElevenLabsVoicesResponse instance,
) => <String, dynamic>{'voices': instance.voices};

ElevenLabsVoiceResponse _$ElevenLabsVoiceResponseFromJson(
  Map<String, dynamic> json,
) => ElevenLabsVoiceResponse(
  voiceId: json['voice_id'] as String,
  name: json['name'] as String,
  previewUrl: json['preview_url'] as String?,
  labels: json['labels'] as Map<String, dynamic>,
  settings: json['settings'] == null
      ? null
      : ElevenLabsVoiceSettingsResponse.fromJson(
          json['settings'] as Map<String, dynamic>,
        ),
  availableForTiers: (json['available_for_tiers'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  category: json['category'] as String,
  fineTuning: json['fine_tuning'] == null
      ? null
      : FineTuningResponse.fromJson(
          json['fine_tuning'] as Map<String, dynamic>,
        ),
  description: json['description'] as String?,
  samples: json['samples'],
  sharing: json['sharing'],
  highQualityBaseModelIds:
      (json['high_quality_base_model_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
  safetyControl: json['safety_control'],
  voiceVerification: json['voice_verification'],
  permissionOnResource: json['permission_on_resource'],
  isOwner: json['is_owner'] as bool?,
  isLegacy: json['is_legacy'] as bool?,
  isMixed: json['is_mixed'] as bool?,
  createdAtUnix: (json['created_at_unix'] as num?)?.toInt(),
  verifiedLanguages: json['verified_languages'] as List<dynamic>?,
);

Map<String, dynamic> _$ElevenLabsVoiceResponseToJson(
  ElevenLabsVoiceResponse instance,
) => <String, dynamic>{
  'voice_id': instance.voiceId,
  'name': instance.name,
  'preview_url': instance.previewUrl,
  'labels': instance.labels,
  'settings': instance.settings,
  'available_for_tiers': instance.availableForTiers,
  'category': instance.category,
  'fine_tuning': instance.fineTuning,
  'description': instance.description,
  'samples': instance.samples,
  'sharing': instance.sharing,
  'high_quality_base_model_ids': instance.highQualityBaseModelIds,
  'safety_control': instance.safetyControl,
  'voice_verification': instance.voiceVerification,
  'permission_on_resource': instance.permissionOnResource,
  'is_owner': instance.isOwner,
  'is_legacy': instance.isLegacy,
  'is_mixed': instance.isMixed,
  'created_at_unix': instance.createdAtUnix,
  'verified_languages': instance.verifiedLanguages,
};

ElevenLabsVoiceSettingsResponse _$ElevenLabsVoiceSettingsResponseFromJson(
  Map<String, dynamic> json,
) => ElevenLabsVoiceSettingsResponse(
  stability: (json['stability'] as num).toDouble(),
  similarityBoost: (json['similarity_boost'] as num).toDouble(),
  style: (json['style'] as num?)?.toDouble(),
  useSpeakerBoost: json['use_speaker_boost'] as bool?,
);

Map<String, dynamic> _$ElevenLabsVoiceSettingsResponseToJson(
  ElevenLabsVoiceSettingsResponse instance,
) => <String, dynamic>{
  'stability': instance.stability,
  'similarity_boost': instance.similarityBoost,
  'style': instance.style,
  'use_speaker_boost': instance.useSpeakerBoost,
};

FineTuningResponse _$FineTuningResponseFromJson(
  Map<String, dynamic> json,
) => FineTuningResponse(
  isAllowedToFineTune: json['is_allowed_to_fine_tune'] as bool,
  state: FineTuningResponse._stateFromJson(json['state']),
  verificationAttempts: json['verification_attempts'],
  verificationFailures: json['verification_failures'] as List<dynamic>?,
  verificationAttemptsCount: (json['verification_attempts_count'] as num?)
      ?.toInt(),
  manualVerificationRequested: json['manual_verification_requested'] as bool?,
  language: json['language'] as String?,
  progress: json['progress'],
  message: json['message'],
  datasetDurationSeconds: json['dataset_duration_seconds'],
  sliceIds: json['slice_ids'],
  manualVerification: json['manual_verification'],
  maxVerificationAttempts: (json['max_verification_attempts'] as num?)?.toInt(),
  nextMaxVerificationAttemptsResetUnixMs:
      (json['next_max_verification_attempts_reset_unix_ms'] as num?)?.toInt(),
);

Map<String, dynamic> _$FineTuningResponseToJson(FineTuningResponse instance) =>
    <String, dynamic>{
      'is_allowed_to_fine_tune': instance.isAllowedToFineTune,
      'state': FineTuningResponse._stateToJson(instance.state),
      'verification_attempts': instance.verificationAttempts,
      'verification_failures': instance.verificationFailures,
      'verification_attempts_count': instance.verificationAttemptsCount,
      'manual_verification_requested': instance.manualVerificationRequested,
      'language': instance.language,
      'progress': instance.progress,
      'message': instance.message,
      'dataset_duration_seconds': instance.datasetDurationSeconds,
      'slice_ids': instance.sliceIds,
      'manual_verification': instance.manualVerification,
      'max_verification_attempts': instance.maxVerificationAttempts,
      'next_max_verification_attempts_reset_unix_ms':
          instance.nextMaxVerificationAttemptsResetUnixMs,
    };

VoiceSynthesisRequest _$VoiceSynthesisRequestFromJson(
  Map<String, dynamic> json,
) => VoiceSynthesisRequest(
  text: json['text'] as String,
  voiceSettings: VoiceSettingsRequest.fromJson(
    json['voice_settings'] as Map<String, dynamic>,
  ),
  modelId: json['model_id'] as String,
  languageCode: json['language_code'] as String,
  pronunciationDictionaryLocators:
      (json['pronunciation_dictionary_locators'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
  seed: (json['seed'] as num).toInt(),
  previousText: json['previousText'] as String,
  nextText: json['nextText'] as String,
  previousRequestIds: (json['previous_request_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  nextRequestIds: (json['next_request_ids'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  usePvcAsIvc: json['use_pvc_as_ivc'] as bool,
  applyTextNormalization: json['apply_text_normalization'] as String,
  applyLanguageTextNormalization:
      json['apply_language_text_normalization'] as bool,
  customJson: json['customJson'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$VoiceSynthesisRequestToJson(
  VoiceSynthesisRequest instance,
) => <String, dynamic>{
  'text': instance.text,
  'voice_settings': instance.voiceSettings,
  'model_id': instance.modelId,
  'language_code': instance.languageCode,
  'pronunciation_dictionary_locators': instance.pronunciationDictionaryLocators,
  'seed': instance.seed,
  'previousText': instance.previousText,
  'nextText': instance.nextText,
  'previous_request_ids': instance.previousRequestIds,
  'next_request_ids': instance.nextRequestIds,
  'use_pvc_as_ivc': instance.usePvcAsIvc,
  'apply_text_normalization': instance.applyTextNormalization,
  'apply_language_text_normalization': instance.applyLanguageTextNormalization,
  'customJson': ?instance.customJson,
};

VoiceSettingsRequest _$VoiceSettingsRequestFromJson(
  Map<String, dynamic> json,
) => VoiceSettingsRequest(
  stability: (json['stability'] as num).toDouble(),
  similarityBoost: (json['similarity_boost'] as num).toDouble(),
  style: (json['style'] as num?)?.toDouble(),
  useSpeakerBoost: json['use_speaker_boost'] as bool?,
);

Map<String, dynamic> _$VoiceSettingsRequestToJson(
  VoiceSettingsRequest instance,
) => <String, dynamic>{
  'stability': instance.stability,
  'similarity_boost': instance.similarityBoost,
  'style': instance.style,
  'use_speaker_boost': instance.useSpeakerBoost,
};

ElevenLabsErrorResponse _$ElevenLabsErrorResponseFromJson(
  Map<String, dynamic> json,
) => ElevenLabsErrorResponse(
  detail: ElevenLabsErrorDetail.fromJson(
    json['detail'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ElevenLabsErrorResponseToJson(
  ElevenLabsErrorResponse instance,
) => <String, dynamic>{'detail': instance.detail};

ElevenLabsErrorDetail _$ElevenLabsErrorDetailFromJson(
  Map<String, dynamic> json,
) => ElevenLabsErrorDetail(
  status: json['status'] as String,
  message: json['message'] as String,
);

Map<String, dynamic> _$ElevenLabsErrorDetailToJson(
  ElevenLabsErrorDetail instance,
) => <String, dynamic>{'status': instance.status, 'message': instance.message};

ElevenLabsUserResponse _$ElevenLabsUserResponseFromJson(
  Map<String, dynamic> json,
) => ElevenLabsUserResponse(
  subscription: SubscriptionInfo.fromJson(
    json['subscription'] as Map<String, dynamic>,
  ),
  isNewUser: json['is_new_user'] as bool,
  xiApiKey: json['xi_api_key'] as String?,
);

Map<String, dynamic> _$ElevenLabsUserResponseToJson(
  ElevenLabsUserResponse instance,
) => <String, dynamic>{
  'subscription': instance.subscription,
  'is_new_user': instance.isNewUser,
  'xi_api_key': instance.xiApiKey,
};

SubscriptionInfo _$SubscriptionInfoFromJson(Map<String, dynamic> json) =>
    SubscriptionInfo(
      tier: json['tier'] as String,
      characterCount: (json['character_count'] as num).toInt(),
      characterLimit: (json['character_limit'] as num).toInt(),
      canExtendCharacterLimit: json['can_extend_character_limit'] as bool,
      allowedToExtendCharacterLimit:
          json['allowed_to_extend_character_limit'] as bool,
      nextCharacterCountResetUnix:
          (json['next_character_count_reset_unix'] as num).toInt(),
      voiceLimit: (json['voice_limit'] as num).toInt(),
      maxVoiceAddEdits: (json['max_voice_add_edits'] as num).toInt(),
      voiceAddEditCounter: (json['voice_add_edit_counter'] as num).toInt(),
      professionalVoiceLimit: (json['professional_voice_limit'] as num).toInt(),
      canExtendVoiceLimit: json['can_extend_voice_limit'] as bool,
      canUseInstantVoiceCloning: json['can_use_instant_voice_cloning'] as bool,
      canUseProfessionalVoiceCloning:
          json['can_use_professional_voice_cloning'] as bool,
      currency: json['currency'] as String,
      status: json['status'] as String,
    );

Map<String, dynamic> _$SubscriptionInfoToJson(
  SubscriptionInfo instance,
) => <String, dynamic>{
  'tier': instance.tier,
  'character_count': instance.characterCount,
  'character_limit': instance.characterLimit,
  'can_extend_character_limit': instance.canExtendCharacterLimit,
  'allowed_to_extend_character_limit': instance.allowedToExtendCharacterLimit,
  'next_character_count_reset_unix': instance.nextCharacterCountResetUnix,
  'voice_limit': instance.voiceLimit,
  'max_voice_add_edits': instance.maxVoiceAddEdits,
  'voice_add_edit_counter': instance.voiceAddEditCounter,
  'professional_voice_limit': instance.professionalVoiceLimit,
  'can_extend_voice_limit': instance.canExtendVoiceLimit,
  'can_use_instant_voice_cloning': instance.canUseInstantVoiceCloning,
  'can_use_professional_voice_cloning': instance.canUseProfessionalVoiceCloning,
  'currency': instance.currency,
  'status': instance.status,
};

ElevenLabsModelsResponse _$ElevenLabsModelsResponseFromJson(
  Map<String, dynamic> json,
) => ElevenLabsModelsResponse(
  models: (json['models'] as List<dynamic>)
      .map((e) => ElevenLabsModelInfo.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$ElevenLabsModelsResponseToJson(
  ElevenLabsModelsResponse instance,
) => <String, dynamic>{'models': instance.models};

ElevenLabsModelInfo _$ElevenLabsModelInfoFromJson(Map<String, dynamic> json) =>
    ElevenLabsModelInfo(
      modelId: json['model_id'] as String,
      name: json['name'] as String,
      canBeFinetuned: json['can_be_finetuned'] as bool,
      canDoTextToSpeech: json['can_do_text_to_speech'] as bool,
      canDoVoiceConversion: json['can_do_voice_conversion'] as bool,
      canUseStyle: json['can_use_style'] as bool,
      canUseSpeakerBoost: json['can_use_speaker_boost'] as bool,
      servesProVoices: json['serves_pro_voices'] as bool,
      tokenCostFactor: (json['token_cost_factor'] as num).toDouble(),
      description: json['description'] as String,
      language: json['language'] as String,
      maxCharactersRequestFreeUser:
          (json['max_characters_request_free_user'] as num).toInt(),
      maxCharactersRequestSubscribedUser:
          (json['max_characters_request_subscribed_user'] as num).toInt(),
    );

Map<String, dynamic> _$ElevenLabsModelInfoToJson(
  ElevenLabsModelInfo instance,
) => <String, dynamic>{
  'model_id': instance.modelId,
  'name': instance.name,
  'can_be_finetuned': instance.canBeFinetuned,
  'can_do_text_to_speech': instance.canDoTextToSpeech,
  'can_do_voice_conversion': instance.canDoVoiceConversion,
  'can_use_style': instance.canUseStyle,
  'can_use_speaker_boost': instance.canUseSpeakerBoost,
  'serves_pro_voices': instance.servesProVoices,
  'token_cost_factor': instance.tokenCostFactor,
  'description': instance.description,
  'language': instance.language,
  'max_characters_request_free_user': instance.maxCharactersRequestFreeUser,
  'max_characters_request_subscribed_user':
      instance.maxCharactersRequestSubscribedUser,
};
