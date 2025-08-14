# Voice Chat Functionality Guide

## Overview

The demo chat now supports two-way voice communication, allowing users to:
- **Speak** their messages using voice input
- **Hear** AI responses in natural voice
- **Switch** between text and voice input modes
- **Control** the conversation with intuitive UI

## Features Implemented

### 1. Voice Recording
- **Real-time voice recording** with visual feedback
- **Permission handling** for microphone access
- **Audio quality optimization** for clear speech capture
- **Recording duration tracking** with visual indicators

### 2. Speech-to-Text (STT)
- **Vietnamese language support** (primary)
- **Multiple language support** (English, Spanish, French, German, Japanese, Korean, Chinese)
- **Real-time speech recognition** with partial results
- **Automatic language detection** and switching

### 3. Text-to-Speech (TTS)
- **Integration with ElevenLabs API** for natural AI voices
- **Voice selection** from available voice configurations
- **Audio playback controls** with proper volume handling
- **Error handling** for TTS failures

### 4. User Interface
- **Toggle button** to switch between text and voice modes
- **Animated recording indicators** with pulse effects
- **Visual feedback** for recording and listening states
- **Error messages** with clear instructions
- **Responsive design** that adapts to different screen sizes

## How to Use Voice Chat

### Starting a Voice Conversation

1. **Open the Demo Chat** screen
2. **Enable Voice Mode** by tapping the microphone/chat toggle button
3. **Grant microphone permissions** when prompted (first time only)
4. **Start speaking** by tapping the red microphone button
5. **Stop recording** by tapping the stop button when finished
6. **Wait for AI response** - the avatar will respond with voice

### Voice Input Process

```
User taps microphone button → 
Starts recording → 
User speaks message → 
User stops recording → 
Converts speech to text → 
Sends text to AI → 
AI generates response → 
Converts response to speech → 
Plays audio response
```

### Text Input (Alternative)

1. **Disable Voice Mode** by tapping the toggle button
2. **Type your message** in the text field
3. **Tap send** or press Enter
4. **AI responds** with voice (if enabled)

## Technical Implementation

### Core Services

#### VoiceRecordingService
- Handles audio recording using the `record` package
- Manages recording states (idle, recording, paused, stopped)
- Provides recording duration and file path
- Handles microphone permissions

#### SpeechToTextService
- Uses `speech_to_text` package for voice recognition
- Supports multiple languages with locale switching
- Provides real-time recognition with partial results
- Manages recognition states and error handling

#### AudioService
- Integrates with `audioplayers` for audio playback
- Handles ElevenLabs TTS API calls
- Manages audio session and volume control
- Provides audio playback controls

### UI Components

#### VoiceChatWidget
- Combined voice recording and speech recognition interface
- Animated recording indicators with pulse effects
- Error handling with user-friendly messages
- Responsive design with proper theming

#### DemoChatScreen Integration
- Toggle button to switch between text and voice modes
- Seamless integration with existing chat functionality
- Proper state management for voice/text modes
- Consistent theming and user experience

### Error Handling

The implementation includes comprehensive error handling for:
- **Microphone permissions** - Clear prompts and fallbacks
- **Recording failures** - User-friendly error messages
- **Speech recognition errors** - Graceful degradation to text input
- **TTS failures** - Fallback to text responses
- **Network issues** - Offline capability with local responses

## Dependencies

Required packages (already included in pubspec.yaml):
```yaml
dependencies:
  record: ^5.0.4          # Voice recording
  speech_to_text: ^6.3.0  # Speech-to-text conversion
  audioplayers: ^5.2.1    # Audio playback
  just_audio: ^0.9.36     # Advanced audio handling
```

## Platform Support

### Android
- ✅ Full voice recording support
- ✅ Speech-to-text with system services
- ✅ Audio playback with proper permissions
- ✅ Background audio handling

### iOS
- ✅ Voice recording with AVAudioSession
- ✅ Speech-to-text with system services
- ✅ Audio playback with proper permissions
- ✅ Background audio handling

### Web
- ⚠️ Limited voice recording support
- ⚠️ Speech-to-text with browser APIs
- ✅ Audio playback
- ⚠️ Some features may require HTTPS

### Desktop (Windows/macOS/Linux)
- ⚠️ Limited support
- ⚠️ May require additional setup
- ⚠️ Some features may not be available

## Performance Considerations

### Battery Usage
- Voice recording and processing consume battery
- Optimized for minimal power consumption
- Proper cleanup of audio resources

### Memory Usage
- Audio files are properly cleaned up after use
- Recording sessions are properly disposed
- Memory-efficient audio processing

### Network Usage
- TTS requires internet connection for ElevenLabs API
- STT works offline with system services
- Graceful handling of network interruptions

## Troubleshooting

### Common Issues

**Microphone Permission Denied**
- Solution: Go to app settings and enable microphone access
- Restart the app after granting permissions

**Voice Recording Not Working**
- Check microphone permissions
- Ensure no other app is using the microphone
- Try restarting the app

**Speech Recognition Not Accurate**
- Speak clearly and at a normal pace
- Reduce background noise
- Try switching to a different language
- Check internet connection for some STT services

**No Audio Response**
- Verify ElevenLabs API key is configured
- Check internet connection
- Try selecting a different voice
- Check device volume and ringer settings

### Debug Information

The app provides detailed logging for:
- Recording session start/stop
- Speech recognition results
- TTS synthesis status
- Error conditions and exceptions

## Future Enhancements

### Planned Features
- **Voice command support** for hands-free operation
- **Voice customization** with pitch, speed, and emotion controls
- **Background voice processing** for smoother conversation flow
- **Multi-language conversation** support
- **Voice profile personalization**

### Technical Improvements
- **Offline speech recognition** for better privacy
- **Voice activity detection** for automatic recording control
- **Audio enhancement** for better voice quality
- **Real-time voice modulation** for avatar voice effects
- **Voice analytics** for conversation insights

## Conclusion

The voice chat functionality provides a natural and intuitive way for users to interact with AI avatars. By combining voice recording, speech recognition, and text-to-speech capabilities, users can have seamless voice conversations with their configured avatars.

The implementation is robust, user-friendly, and handles edge cases gracefully while providing a smooth and responsive user experience.