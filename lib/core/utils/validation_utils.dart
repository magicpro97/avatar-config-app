// Validation utilities
class ValidationUtils {
  static bool isValidApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) return false;
    // ElevenLabs API keys typically start with specific patterns
    return apiKey.length > 10 && apiKey.isNotEmpty;
  }

  static bool isValidConfigurationName(String? name) {
    if (name == null || name.isEmpty) return false;
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  static bool isValidVoiceId(String? voiceId) {
    if (voiceId == null || voiceId.isEmpty) return false;
    // Voice IDs are typically UUIDs or similar format
    return voiceId.length >= 10;
  }

  static bool isValidPersonalityType(String? personalityType) {
    if (personalityType == null || personalityType.isEmpty) return false;
    const validTypes = [
      'happy',
      'romantic',
      'funny',
      'professional',
      'casual',
      'energetic',
      'calm',
      'mysterious',
    ];
    return validTypes.contains(personalityType.toLowerCase());
  }

  static bool isValidVoiceSettings(double? stability, double? similarityBoost, double? style) {
    if (stability != null && (stability < 0.0 || stability > 1.0)) return false;
    if (similarityBoost != null && (similarityBoost < 0.0 || similarityBoost > 1.0)) return false;
    if (style != null && (style < 0.0 || style > 1.0)) return false;
    return true;
  }

  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  static String? validateConfigurationName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Configuration name is required';
    }
    if (name.trim().length < 2) {
      return 'Configuration name must be at least 2 characters';
    }
    if (name.trim().length > 50) {
      return 'Configuration name must be less than 50 characters';
    }
    return null;
  }

  static String? validateApiKey(String? apiKey) {
    if (apiKey == null || apiKey.isEmpty) {
      return 'API key is required';
    }
    if (apiKey.length < 10) {
      return 'API key appears to be invalid';
    }
    return null;
  }

  static String? validateVoiceSettings(double? value, String fieldName) {
    if (value == null) return null;
    if (value < 0.0 || value > 1.0) {
      return '$fieldName must be between 0.0 and 1.0';
    }
    return null;
  }
}