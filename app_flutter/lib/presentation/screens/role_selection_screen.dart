import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'login_screen.dart';
import 'child_login_screen.dart';
import '../providers/translation_providers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'unity_game_screen.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (code) => ref.read(languageProvider.notifier).setLanguage(code),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'fr', child: Text('Français')),
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'wolof', child: Text('Wolof')),
            ],
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0D47A1),
              const Color(0xFF4A148C),
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              const Icon(
                Icons.rocket_launch_rounded,
                size: 100,
                color: Colors.white,
              ).animate(onPlay: (controller) => controller.repeat())
                .shimmer(duration: 2000.ms, color: Colors.blue.shade200)
                .shake(hz: 2, curve: Curves.easeInOut),
              
              const SizedBox(height: 24),
              
              Text(
                tr(ref, 'math_runner'),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 8),
              
              Text(
                tr(ref, 'who_is_playing'),
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 60),

              // Bouton Élève
              _buildRoleButton(
                context,
                title: tr(ref, 'i_am_student'),
                icon: Icons.face_retouching_natural,
                color: const Color(0xFF00E676),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChildLoginScreen()),
                  );
                },
              ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2),
              
              const SizedBox(height: 20),

              // Bouton Parent
              _buildRoleButton(
                context,
                title: tr(ref, 'i_am_parent'),
                icon: Icons.family_restroom_rounded,
                color: const Color(0xFF00B0FF),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen(role: UserRole.parent)),
                  );
                },
              ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2),
              
              const SizedBox(height: 20),

              // Bouton Enseignant
              _buildRoleButton(
                context,
                title: tr(ref, 'i_am_teacher'),
                icon: Icons.school_rounded,
                color: const Color(0xFFAB47BC),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen(role: UserRole.teacher)),
                  );
                },
              ).animate().fadeIn(delay: 1000.ms).slideX(begin: -0.2),
              
              const SizedBox(height: 30),

              // Bouton Invité (Look discret mais moderne)
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white60,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const UnityGameScreen()),
                  );
                },
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text(
                  'Jouer en Invité',
                  style: TextStyle(fontSize: 16, decoration: TextDecoration.underline),
                ),
              ).animate().fadeIn(delay: 1300.ms),
            ],
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildRoleButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 0, // Géré par le Container
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
