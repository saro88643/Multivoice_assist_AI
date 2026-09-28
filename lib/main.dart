import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'providers/speech_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/history_provider.dart';

import 'services/audio_tts_service.dart';

import 'screens/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Could not load .env file: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        // ========================================================
        // AUTH PROVIDER
        // ========================================================
        ChangeNotifierProvider(create: (_) => AuthProvider()),

        // ========================================================
        // CHAT PROVIDER
        // ========================================================
        ChangeNotifierProvider(create: (_) => ChatProvider()),

        // ========================================================
        // SPEECH PROVIDER
        // ========================================================
        ChangeNotifierProvider(create: (_) => SpeechProvider()),

        // ========================================================
        // PROFILE PROVIDER
        // ========================================================
        ChangeNotifierProvider(create: (_) => ProfileProvider()),

        // ========================================================
        // HISTORY PROVIDER
        // ========================================================
        ChangeNotifierProvider(create: (_) => HistoryProvider()),

        // ========================================================
        // AUDIO TTS SERVICE
        // ========================================================
        ChangeNotifierProvider(create: (_) => AudioTtsService()),
      ],

      child: const MultiVoiceAssistApp(),
    ),
  );
}

class MultiVoiceAssistApp extends StatelessWidget {
  const MultiVoiceAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'MultiVoice Assist',

      theme: ThemeData(brightness: Brightness.dark, useMaterial3: true),

      home: const SplashScreen(),
    );
  }
}
