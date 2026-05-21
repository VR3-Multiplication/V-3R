import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/role_selection_screen.dart';
import 'presentation/screens/unity_game_screen.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/providers/session_tracker.dart';
import 'presentation/providers/auth_providers.dart';

import 'presentation/providers/statistic_providers.dart';

bool get _isRunningInTest {
  try {
    return !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
  } catch (_) {
    return false;
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MathRunnerApp(),
    ),
  );
}

class MathRunnerApp extends ConsumerStatefulWidget {
  const MathRunnerApp({super.key});

  @override
  ConsumerState<MathRunnerApp> createState() => _MathRunnerAppState();
}

class _MathRunnerAppState extends ConsumerState<MathRunnerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (!_isRunningInTest) {
      _updateActivityIfLoggedIn();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_isRunningInTest) {
      _checkSessionValidity();
      ref.read(statementRepositoryProvider).syncPendingStatements().catchError((e) {
        print('FLUTTER_DEBUG: Erreur de synchro en tâche de fond depuis main: $e');
      });
    }
  }

  Future<void> _updateActivityIfLoggedIn() async {
    final client = Supabase.instance.client;
    if (client.auth.currentSession != null) {
      await SessionTracker.updateActivity();
    }
  }

  Future<void> _checkSessionValidity() async {
    final client = Supabase.instance.client;
    if (client.auth.currentSession != null) {
      final isValid = await SessionTracker.isSessionValid();
      if (isValid) {
        await SessionTracker.updateActivity();
      } else {
        // Déconnexion automatique après 12 heures d'inactivité
        await client.auth.signOut();
        await SessionTracker.clearActivity();
        ref.invalidate(currentUserProfileProvider);
        
        // Rediriger vers l'écran de sélection de rôle
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Math Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006064), // Teal profond
          brightness: Brightness.light,
          primary: const Color(0xFF006064),
          secondary: const Color(0xFFFFAB00), // Amber vibrant
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
          titleLarge: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 4,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006064),
          brightness: Brightness.dark,
          primary: const Color(0xFF4DD0E1),
          secondary: const Color(0xFFFFD740),
          surface: const Color(0xFF121212),
        ),
      ),
      home: _isRunningInTest ? const RoleSelectionScreen() : const SplashScreen(),
    );
  }
}

// Un écran temporaire qui sera plus tard déplacé dans lib/presentation/
class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hangar Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenue dans Math Runner !',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const UnityGameScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Lancer une Mission'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
