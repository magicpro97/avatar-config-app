// App Color Scheme
import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color primaryBlueLight = Color(0xFF64B5F6);
  
  static const Color secondaryPurple = Color(0xFF9C27B0);
  static const Color secondaryPurpleDark = Color(0xFF7B1FA2);
  static const Color secondaryPurpleLight = Color(0xFFBA68C8);
  
  // Accent Colors
  static const Color accentGreen = Color(0xFF4CAF50);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentRed = Color(0xFFF44336);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);
  
  // Light Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryBlue,
    onPrimary: white,
    primaryContainer: primaryBlueLight,
    onPrimaryContainer: grey900,
    secondary: secondaryPurple,
    onSecondary: white,
    secondaryContainer: secondaryPurpleLight,
    onSecondaryContainer: grey900,
    tertiary: accentGreen,
    onTertiary: white,
    tertiaryContainer: Color(0xFFC8E6C9),
    onTertiaryContainer: grey900,
    error: accentRed,
    onError: white,
    errorContainer: Color(0xFFFFCDD2),
    onErrorContainer: grey900,
    surface: white,
    onSurface: grey900,
    surfaceContainerHighest: grey100,
    onSurfaceVariant: grey700,
    outline: grey400,
    outlineVariant: grey300,
    shadow: black,
    scrim: black,
    inverseSurface: grey800,
    onInverseSurface: grey100,
    inversePrimary: primaryBlueLight,
    surfaceTint: primaryBlue,
  );
  
  // Dark Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryBlueLight,
    onPrimary: grey900,
    primaryContainer: primaryBlueDark,
    onPrimaryContainer: grey100,
    secondary: secondaryPurpleLight,
    onSecondary: grey900,
    secondaryContainer: secondaryPurpleDark,
    onSecondaryContainer: grey100,
    tertiary: Color(0xFF81C784),
    onTertiary: grey900,
    tertiaryContainer: Color(0xFF2E7D32),
    onTertiaryContainer: grey100,
    error: Color(0xFFEF5350),
    onError: grey900,
    errorContainer: Color(0xFFD32F2F),
    onErrorContainer: grey100,
    surface: grey800,
    onSurface: grey100,
    surfaceContainerHighest: grey700,
    onSurfaceVariant: grey300,
    outline: grey500,
    outlineVariant: grey600,
    shadow: black,
    scrim: black,
    inverseSurface: grey100,
    onInverseSurface: grey800,
    inversePrimary: primaryBlueDark,
    surfaceTint: primaryBlueLight,
  );
  
  // Personality Colors
  static const Color happyColor = Color(0xFFFFEB3B);
  static const Color romanticColor = Color(0xFFE91E63);
  static const Color funnyColor = Color(0xFFFF9800);
  static const Color professionalColor = Color(0xFF3F51B5);
  static const Color casualColor = Color(0xFF4CAF50);
  static const Color energeticColor = Color(0xFFFF5722);
  static const Color calmColor = Color(0xFF00BCD4);
  static const Color mysteriousColor = Color(0xFF9C27B0);
  
  // Voice Gender Colors
  static const Color maleVoiceColor = Color(0xFF2196F3);
  static const Color femaleVoiceColor = Color(0xFFE91E63);
  static const Color neutralVoiceColor = Color(0xFF9E9E9E);
  
  // Status Colors
  static const Color successColor = accentGreen;
  static const Color warningColor = accentOrange;
  static const Color errorColor = accentRed;
  static const Color infoColor = primaryBlue;
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryBlue, primaryBlueDark],
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryPurple, secondaryPurpleDark],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentGreen, Color(0xFF388E3C)],
  );
  
  // Helper methods
  static Color getPersonalityColor(String personalityType) {
    switch (personalityType.toLowerCase()) {
      case 'happy':
        return happyColor;
      case 'romantic':
        return romanticColor;
      case 'funny':
        return funnyColor;
      case 'professional':
        return professionalColor;
      case 'casual':
        return casualColor;
      case 'energetic':
        return energeticColor;
      case 'calm':
        return calmColor;
      case 'mysterious':
        return mysteriousColor;
      default:
        return primaryBlue;
    }
  }
  
  static Color getVoiceGenderColor(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return maleVoiceColor;
      case 'female':
        return femaleVoiceColor;
      case 'neutral':
      default:
        return neutralVoiceColor;
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'active':
        return successColor;
      case 'warning':
      case 'pending':
        return warningColor;
      case 'error':
      case 'failed':
        return errorColor;
      case 'info':
      case 'inactive':
      default:
        return infoColor;
    }
  }
}