// Personality Data Model
import 'package:json_annotation/json_annotation.dart';

part 'personality_model.g.dart';

enum PersonalityType {
  @JsonValue('happy')
  happy,
  @JsonValue('romantic')
  romantic,
  @JsonValue('funny')
  funny,
  @JsonValue('professional')
  professional,
  @JsonValue('casual')
  casual,
  @JsonValue('energetic')
  energetic,
  @JsonValue('calm')
  calm,
  @JsonValue('mysterious')
  mysterious,
}

@JsonSerializable()
class PersonalityModel {
  final PersonalityType type;
  @JsonKey(name: 'display_name')
  final String displayName;
  final String description;
  final Map<String, dynamic> parameters;

  const PersonalityModel({
    required this.type,
    required this.displayName,
    required this.description,
    required this.parameters,
  });

  factory PersonalityModel.fromJson(Map<String, dynamic> json) =>
      _$PersonalityModelFromJson(json);

  Map<String, dynamic> toJson() => _$PersonalityModelToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PersonalityModel &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          displayName == other.displayName &&
          description == other.description;

  @override
  int get hashCode =>
      type.hashCode ^ displayName.hashCode ^ description.hashCode;

  @override
  String toString() {
    return 'PersonalityModel(type: $type, displayName: $displayName, description: $description)';
  }

  PersonalityModel copyWith({
    PersonalityType? type,
    String? displayName,
    String? description,
    Map<String, dynamic>? parameters,
  }) {
    return PersonalityModel(
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
    );
  }

  // Factory methods for predefined personalities
  static PersonalityModel get happy => const PersonalityModel(
        type: PersonalityType.happy,
        displayName: 'Happy',
        description: 'Cheerful and upbeat personality with an optimistic tone',
        parameters: {'energy': 0.8, 'positivity': 0.9},
      );

  static PersonalityModel get romantic => const PersonalityModel(
        type: PersonalityType.romantic,
        displayName: 'Romantic',
        description: 'Warm and affectionate with a gentle, loving tone',
        parameters: {'warmth': 0.9, 'gentleness': 0.8},
      );

  static PersonalityModel get funny => const PersonalityModel(
        type: PersonalityType.funny,
        displayName: 'Funny',
        description: 'Playful and humorous with a light-hearted approach',
        parameters: {'playfulness': 0.9, 'humor': 0.8},
      );

  static PersonalityModel get professional => const PersonalityModel(
        type: PersonalityType.professional,
        displayName: 'Professional',
        description: 'Formal and business-like with clear, articulate speech',
        parameters: {'formality': 0.9, 'clarity': 0.8},
      );

  static PersonalityModel get casual => const PersonalityModel(
        type: PersonalityType.casual,
        displayName: 'Casual',
        description: 'Relaxed and informal with a friendly conversational tone',
        parameters: {'relaxation': 0.8, 'friendliness': 0.7},
      );

  static PersonalityModel get energetic => const PersonalityModel(
        type: PersonalityType.energetic,
        displayName: 'Energetic',
        description: 'High-energy and enthusiastic with dynamic delivery',
        parameters: {'energy': 0.9, 'enthusiasm': 0.8},
      );

  static PersonalityModel get calm => const PersonalityModel(
        type: PersonalityType.calm,
        displayName: 'Calm',
        description: 'Peaceful and soothing with a steady, tranquil tone',
        parameters: {'tranquility': 0.9, 'stability': 0.8},
      );

  static PersonalityModel get mysterious => const PersonalityModel(
        type: PersonalityType.mysterious,
        displayName: 'Mysterious',
        description: 'Intriguing and enigmatic with a subtle, alluring tone',
        parameters: {'mystery': 0.8, 'allure': 0.7},
      );

  static List<PersonalityModel> get allPersonalities => [
        happy,
        romantic,
        funny,
        professional,
        casual,
        energetic,
        calm,
        mysterious,
      ];
}