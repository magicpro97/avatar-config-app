// Domain Entity for Personality
import 'package:equatable/equatable.dart';

enum PersonalityType {
  happy,
  romantic,
  funny,
  professional,
  casual,
  energetic,
  calm,
  mysterious,
}

class Personality extends Equatable {
  final PersonalityType type;
  final String displayName;
  final String description;
  final Map<String, dynamic> parameters;

  const Personality({
    required this.type,
    required this.displayName,
    required this.description,
    required this.parameters,
  });

  @override
  List<Object> get props => [type, displayName, description, parameters];

  @override
  String toString() {
    return 'Personality(type: $type, displayName: $displayName, description: $description)';
  }

  Personality copyWith({
    PersonalityType? type,
    String? displayName,
    String? description,
    Map<String, dynamic>? parameters,
  }) {
    return Personality(
      type: type ?? this.type,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      parameters: parameters ?? this.parameters,
    );
  }

  // Factory methods for predefined personalities
  static const Personality happy = Personality(
    type: PersonalityType.happy,
    displayName: 'Happy',
    description: 'Cheerful and upbeat personality with an optimistic tone',
    parameters: {'energy': 0.8, 'positivity': 0.9},
  );

  static const Personality romantic = Personality(
    type: PersonalityType.romantic,
    displayName: 'Romantic',
    description: 'Warm and affectionate with a gentle, loving tone',
    parameters: {'warmth': 0.9, 'gentleness': 0.8},
  );

  static const Personality funny = Personality(
    type: PersonalityType.funny,
    displayName: 'Funny',
    description: 'Playful and humorous with a light-hearted approach',
    parameters: {'playfulness': 0.9, 'humor': 0.8},
  );

  static const Personality professional = Personality(
    type: PersonalityType.professional,
    displayName: 'Professional',
    description: 'Formal and business-like with clear, articulate speech',
    parameters: {'formality': 0.9, 'clarity': 0.8},
  );

  static const Personality casual = Personality(
    type: PersonalityType.casual,
    displayName: 'Casual',
    description: 'Relaxed and informal with a friendly conversational tone',
    parameters: {'relaxation': 0.8, 'friendliness': 0.7},
  );

  static const Personality energetic = Personality(
    type: PersonalityType.energetic,
    displayName: 'Energetic',
    description: 'High-energy and enthusiastic with dynamic delivery',
    parameters: {'energy': 0.9, 'enthusiasm': 0.8},
  );

  static const Personality calm = Personality(
    type: PersonalityType.calm,
    displayName: 'Calm',
    description: 'Peaceful and soothing with a steady, tranquil tone',
    parameters: {'tranquility': 0.9, 'stability': 0.8},
  );

  static const Personality mysterious = Personality(
    type: PersonalityType.mysterious,
    displayName: 'Mysterious',
    description: 'Intriguing and enigmatic with a subtle, alluring tone',
    parameters: {'mystery': 0.8, 'allure': 0.7},
  );

  static List<Personality> get allPersonalities => [
        happy,
        romantic,
        funny,
        professional,
        casual,
        energetic,
        calm,
        mysterious,
      ];

  static Personality? getByType(PersonalityType type) {
    return allPersonalities.firstWhere(
      (personality) => personality.type == type,
    );
  }
}