// Audio utilities for the application
// import 'package:path_provider/path_provider.dart';
import '../constants/app_constants.dart';

class AudioUtils {
  // static Future<String> get _audioDirectory async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final audioDir = Directory('${directory.path}/audio_cache');
  //   if (!await audioDir.exists()) {
  //     await audioDir.create(recursive: true);
  //   }
  //   return audioDir.path;
  // }

  static String generateFileName(String text, String voiceId) {
    final textHash = text.hashCode.toString();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${voiceId}_${textHash}_$timestamp.${AppConstants.audioFormat}';
  }

  // static Future<String> saveAudioFile(Uint8List audioData, String fileName) async {
  //   try {
  //     final directory = await _audioDirectory;
  //     final filePath = '$directory/$fileName';
  //     final file = File(filePath);
  //     await file.writeAsBytes(audioData);
  //     return filePath;
  //   } catch (e) {
  //     throw AudioException(message: 'Failed to save audio file: $e');
  //   }
  // }

  // static Future<bool> audioFileExists(String fileName) async {
  //   try {
  //     final directory = await _audioDirectory;
  //     final filePath = '$directory/$fileName';
  //     return await File(filePath).exists();
  //   } catch (e) {
  //     return false;
  //   }
  // }

  // static Future<void> deleteAudioFile(String fileName) async {
  //   try {
  //     final directory = await _audioDirectory;
  //     final filePath = '$directory/$fileName';
  //     final file = File(filePath);
  //     if (await file.exists()) {
  //       await file.delete();
  //     }
  //   } catch (e) {
  //     throw AudioException(message: 'Failed to delete audio file: $e');
  //   }
  // }

  // static Future<int> getCacheSize() async {
  //   try {
  //     final directory = await _audioDirectory;
  //     final dir = Directory(directory);
  //     if (!await dir.exists()) return 0;
      
  //     int totalSize = 0;
  //     await for (final entity in dir.list()) {
  //       if (entity is File) {
  //         final stat = await entity.stat();
  //         totalSize += stat.size;
  //       }
  //     }
  //     return totalSize;
  //   } catch (e) {
  //     return 0;
  //   }
  // }

  // static Future<void> clearCache() async {
  //   try {
  //     final directory = await _audioDirectory;
  //     final dir = Directory(directory);
  //     if (await dir.exists()) {
  //       await for (final entity in dir.list()) {
  //         await entity.delete();
  //       }
  //     }
  //   } catch (e) {
  //     throw AudioException(message: 'Failed to clear audio cache: $e');
  //   }
  // }

  static bool isValidAudioFormat(String fileName) {
    final supportedFormats = ['mp3', 'wav', 'aac', 'm4a'];
    final extension = fileName.split('.').last.toLowerCase();
    return supportedFormats.contains(extension);
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}