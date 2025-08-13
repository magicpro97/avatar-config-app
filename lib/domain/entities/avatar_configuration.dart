// Domain Entity for Avatar Configuration
import 'package:equatable/equatable.dart';
import 'personality.dart';
import 'voice.dart';

class AvatarConfiguration extends Equatable {
  final String id;
  final String name;
  final PersonalityType personalityType;
  final VoiceConfiguration voiceConfiguration;
  final DateTime createdAt;
  final DateTime lastModified;
  final bool isActive;

  const AvatarConfiguration({
    required this.id,
    required this.name,
    required this.personalityType,
    required this.voiceConfiguration,
    required this.createdAt,
    required this.lastModified,
    required this.isActive,
  });

  @override
  List<Object> get props => [
        id,
        name,
        personalityType,
        voiceConfiguration,
        createdAt,
        lastModified,
        isActive,
      ];

  @override
  String toString() {
    return 'AvatarConfiguration(id: $id, name: $name, personality: $personalityType, isActive: $isActive)';
  }

  AvatarConfiguration copyWith({
    String? id,
    String? name,
    PersonalityType? personalityType,
    VoiceConfiguration? voiceConfiguration,
    DateTime? createdAt,
    DateTime? lastModified,
    bool? isActive,
  }) {
    return AvatarConfiguration(
      id: id ?? this.id,
      name: name ?? this.name,
      personalityType: personalityType ?? this.personalityType,
      voiceConfiguration: voiceConfiguration ?? this.voiceConfiguration,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
      isActive: isActive ?? this.isActive,
    );
  }

  // Factory method to create a new configuration
  factory AvatarConfiguration.create({
    required String id,
    required String name,
    required PersonalityType personalityType,
    required VoiceConfiguration voiceConfiguration,
    bool isActive = false,
  }) {
    final now = DateTime.now();
    return AvatarConfiguration(
      id: id,
      name: name,
      personalityType: personalityType,
      voiceConfiguration: voiceConfiguration,
      createdAt: now,
      lastModified: now,
      isActive: isActive,
    );
  }

  // Factory method to create from string personality type (for database conversion)
  factory AvatarConfiguration.createFromString({
    required String id,
    required String name,
    required String personalityTypeStr,
    required VoiceConfiguration voiceConfiguration,
    bool isActive = false,
  }) {
    print('DEBUG: AvatarConfiguration.createWithString called with personalityTypeStr: $personalityTypeStr');
    
    try {
      // Convert string to PersonalityType enum
      final personalityType = PersonalityType.values.firstWhere(
        (e) => e.name == personalityTypeStr,
        orElse: () {
          print('DEBUG: PersonalityType $personalityTypeStr not found, using casual');
          return PersonalityType.casual;
        },
      );
      
      print('DEBUG: Successfully converted $personalityTypeStr to $personalityType');
      
      return AvatarConfiguration.create(
        id: id,
        name: name,
        personalityType: personalityType,
        voiceConfiguration: voiceConfiguration,
        isActive: isActive,
      );
    } catch (e, stackTrace) {
      print('ERROR: Failed to convert personality type string: $e');
      print('ERROR: Stack trace: $stackTrace');
      // Fallback to casual
      return AvatarConfiguration.create(
        id: id,
        name: name,
        personalityType: PersonalityType.casual,
        voiceConfiguration: voiceConfiguration,
        isActive: isActive,
      );
    }
  }

  // Helper method to update configuration
  AvatarConfiguration updateConfiguration({
    String? name,
    PersonalityType? personalityType,
    VoiceConfiguration? voiceConfiguration,
    bool? isActive,
  }) {
    return copyWith(
      name: name,
      personalityType: personalityType,
      voiceConfiguration: voiceConfiguration,
      isActive: isActive,
      lastModified: DateTime.now(),
    );
  }

  // Helper method to activate configuration
  AvatarConfiguration activate() {
    return copyWith(
      isActive: true,
      lastModified: DateTime.now(),
    );
  }

  // Helper method to deactivate configuration
  AvatarConfiguration deactivate() {
    return copyWith(
      isActive: false,
      lastModified: DateTime.now(),
    );
  }

  // Helper getters
  Personality? get personality => Personality.getByType(personalityType);
  String get personalityDisplayName => personality?.displayName ?? personalityType.name;
  String get voiceName => voiceConfiguration.name;
  String get voiceGender => voiceConfiguration.gender.name;
  String get formattedCreatedDate => '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  String get formattedModifiedDate => '${lastModified.day}/${lastModified.month}/${lastModified.year}';

  // Validation
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        voiceConfiguration.voiceId.isNotEmpty;
  }

  // Time-based helpers
  Duration get age => DateTime.now().difference(createdAt);
  Duration get timeSinceLastModified => DateTime.now().difference(lastModified);
  bool get isRecentlyModified => timeSinceLastModified.inHours < 24;
  bool get isOld => age.inDays > 30;

  // Status helpers
  String get statusText => isActive ? 'Active' : 'Inactive';
  bool get canBeActivated => isValid && !isActive;
  bool get canBeDeactivated => isActive;
}