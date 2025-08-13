// App Text Styles
import 'package:flutter/material.dart';
import 'colors.dart';

class AppTextStyles {
  // Font Family
  static const String primaryFontFamily = 'Roboto';
  static const String secondaryFontFamily = 'Roboto';
  
  // Base Text Styles
  static const TextStyle headline1 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 96,
    fontWeight: FontWeight.w300,
    letterSpacing: -1.5,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 60,
    fontWeight: FontWeight.w300,
    letterSpacing: -0.5,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 34,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const TextStyle headline5 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  
  static const TextStyle headline6 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitle1 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
  );
  
  static const TextStyle subtitle2 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const TextStyle button = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
  
  static const TextStyle caption = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  static const TextStyle overline = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w400,
    letterSpacing: 1.5,
  );
  
  // Custom Text Styles for Avatar App
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static const TextStyle cardTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static const TextStyle cardSubtitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const TextStyle listItemTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
  );
  
  static const TextStyle listItemSubtitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const TextStyle chipLabel = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.4,
  );
  
  static const TextStyle tabLabel = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.25,
  );
  
  static const TextStyle dialogTitle = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );
  
  static const TextStyle dialogContent = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static const TextStyle snackBarContent = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );
  
  static const TextStyle inputLabel = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  static const TextStyle inputText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );
  
  static const TextStyle errorText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.errorColor,
  );
  
  static const TextStyle helperText = TextStyle(
    fontFamily: primaryFontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
  
  // Theme-specific Text Themes
  static final TextTheme lightTextTheme = TextTheme(
    displayLarge: headline1.copyWith(color: AppColors.lightColorScheme.onSurface),
    displayMedium: headline2.copyWith(color: AppColors.lightColorScheme.onSurface),
    displaySmall: headline3.copyWith(color: AppColors.lightColorScheme.onSurface),
    headlineMedium: headline4.copyWith(color: AppColors.lightColorScheme.onSurface),
    headlineSmall: headline5.copyWith(color: AppColors.lightColorScheme.onSurface),
    titleLarge: headline6.copyWith(color: AppColors.lightColorScheme.onSurface),
    titleMedium: subtitle1.copyWith(color: AppColors.lightColorScheme.onSurface),
    titleSmall: subtitle2.copyWith(color: AppColors.lightColorScheme.onSurface),
    bodyLarge: bodyText1.copyWith(color: AppColors.lightColorScheme.onSurface),
    bodyMedium: bodyText2.copyWith(color: AppColors.lightColorScheme.onSurface),
    labelLarge: button.copyWith(color: AppColors.lightColorScheme.onPrimary),
    bodySmall: caption.copyWith(color: AppColors.lightColorScheme.onSurfaceVariant),
    labelSmall: overline.copyWith(color: AppColors.lightColorScheme.onSurfaceVariant),
  );
  
  static final TextTheme darkTextTheme = TextTheme(
    displayLarge: headline1.copyWith(color: AppColors.darkColorScheme.onSurface),
    displayMedium: headline2.copyWith(color: AppColors.darkColorScheme.onSurface),
    displaySmall: headline3.copyWith(color: AppColors.darkColorScheme.onSurface),
    headlineMedium: headline4.copyWith(color: AppColors.darkColorScheme.onSurface),
    headlineSmall: headline5.copyWith(color: AppColors.darkColorScheme.onSurface),
    titleLarge: headline6.copyWith(color: AppColors.darkColorScheme.onSurface),
    titleMedium: subtitle1.copyWith(color: AppColors.darkColorScheme.onSurface),
    titleSmall: subtitle2.copyWith(color: AppColors.darkColorScheme.onSurface),
    bodyLarge: bodyText1.copyWith(color: AppColors.darkColorScheme.onSurface),
    bodyMedium: bodyText2.copyWith(color: AppColors.darkColorScheme.onSurface),
    labelLarge: button.copyWith(color: AppColors.darkColorScheme.onPrimary),
    bodySmall: caption.copyWith(color: AppColors.darkColorScheme.onSurfaceVariant),
    labelSmall: overline.copyWith(color: AppColors.darkColorScheme.onSurfaceVariant),
  );
  
  // Utility methods
  static TextStyle getPersonalityTextStyle(String personalityType) {
    return cardTitle.copyWith(
      color: AppColors.getPersonalityColor(personalityType),
      fontWeight: FontWeight.w600,
    );
  }
  
  static TextStyle getStatusTextStyle(String status, {bool isLight = true}) {
    final baseStyle = caption.copyWith(
      color: AppColors.getStatusColor(status),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.8,
    );
    
    return baseStyle;
  }
  
  static TextStyle getVoiceGenderTextStyle(String gender) {
    return chipLabel.copyWith(
      color: AppColors.getVoiceGenderColor(gender),
      fontWeight: FontWeight.w600,
    );
  }
}