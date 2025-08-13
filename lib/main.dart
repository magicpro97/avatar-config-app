// Main App Entry Point
import 'package:avatar_config_app/data/services/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/app_state_provider.dart';
import 'presentation/providers/avatar_provider.dart';
import 'presentation/providers/voice_provider.dart';
import 'presentation/theme/app_theme.dart' as theme;
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/configuration/configuration_management_screen.dart';
import 'presentation/screens/voice_selection_screen.dart';
import 'presentation/screens/settings/basic_settings_screen.dart';
import 'presentation/widgets/common/copyable_error_widget.dart';
import 'data/repositories/avatar_repository_impl.dart';
import 'data/repositories/voice_repository_impl.dart';
import 'data/services/elevenlabs_service.dart';
import 'core/storage/database_helper.dart';
import 'core/storage/secure_storage.dart';
import 'package:http/http.dart' as http;

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const AvatarConfigApp());
}

class AvatarConfigApp extends StatelessWidget {
  const AvatarConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ElevenLabsService elevenLabsService = ElevenLabsService(
      httpClient: http.Client(),
      secureStorage: SecureStorage(),
    );
    return MultiProvider(
      providers: [
        // App State Provider
        ChangeNotifierProvider<AppStateProvider>(
          create: (_) => AppStateProvider()..initialize(),
        ),
        
        // Avatar Provider with real SQLite repository
        ChangeNotifierProvider<AvatarProvider>(
          create: (_) => AvatarProvider(
            avatarRepository: AvatarRepositoryImpl(),
          ),
        ),
        
        // Voice Provider with real ElevenLabs repository
        ChangeNotifierProvider<VoiceProvider>(
          create: (_) => VoiceProvider(
            voiceRepository: VoiceRepositoryImpl(
              elevenLabsService: elevenLabsService,
              databaseHelper: DatabaseHelper(),
            ),
            audioService: AudioService(elevenLabsService: elevenLabsService),
          ),
        ),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp(
            title: 'Avatar Config App',
            debugShowCheckedModeBanner: false,
            
            // Theme Configuration
            theme: theme.AppTheme.lightTheme,
            darkTheme: theme.AppTheme.darkTheme,
            themeMode: appState.themeMode,
            
            // Home Screen
            home: appState.isInitializing 
                ? const SplashScreen() 
                : const AppNavigator(),
            
            // Error handling
            builder: (context, child) {
              return Scaffold(
                body: child,
                // Global error handling with copyable error widget
                bottomSheet: appState.hasError
                    ? SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CopyableErrorWidget.generalError(
                              errorMessage: appState.globalError!,
                              title: 'Lỗi ứng dụng',
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: appState.clearGlobalError,
                                    child: const Text('Đóng'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon/Logo placeholder
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            const SizedBox(height: 24),
            
            // App Title
            Text(
              'Avatar Config App',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Configure your personalized avatar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 48),
            
            // Loading indicator
            CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  int _currentIndex = 0;
  
  final List<Widget> _screens = [
    const HomeScreen(),
    const ConfigurationManagementScreen(),
    const VoiceSelectionScreen(),
    const BasicSettingsScreen(),
  ];
  
  final List<NavigationDestination> _destinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Trang chủ',
    ),
    const NavigationDestination(
      icon: Icon(Icons.apps_outlined),
      selectedIcon: Icon(Icons.apps),
      label: 'Quản lý',
    ),
    const NavigationDestination(
      icon: Icon(Icons.record_voice_over_outlined),
      selectedIcon: Icon(Icons.record_voice_over),
      label: 'Giọng nói',
    ),
    const NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: 'Cài đặt',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Update app state
          context.read<AppStateProvider>().setBottomNavIndex(index);
        },
        destinations: _destinations,
      ),
    );
  }
}

