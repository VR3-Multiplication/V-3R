import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/translation_providers.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/session_tracker.dart';
import 'adult_dashboard_screen.dart';
import 'child_dashboard_screen.dart';
import 'role_selection_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String _status = "Démarrage...";
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _initialize();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    final startTime = DateTime.now();
    try {
      setState(() {
        _status = "Démarrage...";
        _progress = 0.3;
      });
      await dotenv.load(fileName: ".env");

      setState(() {
        _status = "Initialisation...";
        _progress = 0.7;
      });
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );

      // Lancer la synchronisation en arrière-plan sans bloquer
      ref.read(translationRepositoryProvider).syncTranslations();

      setState(() {
        _status = "C'est parti !";
        _progress = 1.0;
      });

      // Assurer un temps d'affichage minimal de 2,2 secondes de l'animation pour le confort visuel
      final elapsedTime = DateTime.now().difference(startTime);
      final remainingTime = const Duration(milliseconds: 2200) - elapsedTime;
      if (remainingTime > Duration.zero) {
        await Future.delayed(remainingTime);
      }

      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user != null) {
        final isValid = await SessionTracker.isSessionValid();
        if (isValid) {
          await SessionTracker.updateActivity();
          final response = await client
              .from('profiles')
              .select('role')
              .eq('id', user.id)
              .maybeSingle();

          if (response != null && mounted) {
            final roleStr = response['role'];
            if (roleStr == 'child') {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const ChildDashboardScreen()),
              );
              return;
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const AdultDashboardScreen()),
              );
              return;
            }
          }
        } else {
          // Expiré après 12h d'inactvité
          await client.auth.signOut();
          await SessionTracker.clearActivity();
        }
      }

      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const RoleSelectionScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = "Erreur de chargement. Lancement...";
      });
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.cyan.shade500.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.shade400.withValues(alpha: 0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  size: 100,
                  color: Colors.cyanAccent,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'MATH RUNNER',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 6,
                shadows: [
                  Shadow(
                    color: Colors.cyanAccent,
                    blurRadius: 15,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prêt pour la course ?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.cyan.shade200,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48.0),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 6,
                      child: LinearProgressIndicator(
                        value: _progress,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _status,
                      key: ValueKey<String>(_status),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
