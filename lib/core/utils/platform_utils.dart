import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformUtils {
  /// Check if running on web platform
  static bool get isWeb => kIsWeb;
  
  /// Check if running on mobile platform
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  /// Check if running on desktop platform
  static bool get isDesktop => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);
  
  /// Check if the platform supports file system operations
  static bool get supportsFileSystem => !kIsWeb;
  
  /// Check if the platform supports audio file caching
  static bool get supportsAudioCaching => !kIsWeb;
  
  /// Check if the platform supports path_provider
  static bool get supportsPathProvider => !kIsWeb;
}