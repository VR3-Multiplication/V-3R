import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/mission_providers.dart';
import '../providers/translation_providers.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/mission.dart';
import '../../domain/entities/user_profile.dart';
import 'unity_game_screen.dart';
import 'garage_screen.dart';
import 'role_selection_screen.dart';
import '../providers/affiliation_providers.dart';
import '../providers/session_tracker.dart';
import '../providers/statistic_providers.dart';
import 'child_profile_setup_screen.dart';

class ChildDashboardScreen extends ConsumerWidget {
  const ChildDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mettre à jour l'activité
    SessionTracker.updateActivity();

    // Lancer la synchronisation des calculs locaux en attente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(statementRepositoryProvider).syncPendingStatements().catchError((e) {
        debugPrint('FLUTTER_DEBUG: Erreur de synchro en arrière-plan depuis ChildDashboardScreen: $e');
      });
    });

    final childId = Supabase.instance.client.auth.currentUser?.id;

    if (childId == null) {
      return const Scaffold(body: Center(child: Text('Enfant non connecté')));
    }

    final missionsAsync = ref.watch(pendingMissionsStreamProvider(childId));
    final profileAsyncValue = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, ref, profileAsyncValue),
          SliverToBoxAdapter(
            child: _buildHeader(ref).animate().fadeIn().slideY(begin: -0.2),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: missionsAsync.when(
                loading: () => const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SizedBox(
                  height: 200,
                  child: Center(child: Text('Erreur: $error')),
                ),
                data: (missions) {
                  if (missions.isEmpty) {
                    return _buildFreePlayMode(context, ref).animate().fadeIn(delay: 300.ms);
                  }
                  return _buildDualMode(context, ref, missions.first);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, WidgetRef ref, AsyncValue<UserProfile?> profileAsync) {
    return SliverAppBar(
      floating: true,
      backgroundColor: const Color(0xFF1976D2),
      foregroundColor: Colors.white,
      title: Text(tr(ref, 'child_dashboard_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
      actions: [
        IconButton(
          icon: const Icon(Icons.directions_car_filled_rounded),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GarageScreen())),
        ).animate(onPlay: (c) => c.repeat(reverse: true)).shake(hz: 1, duration: 2.seconds),
        IconButton(
          icon: const Icon(Icons.account_circle_rounded),
          tooltip: 'Mon Profil',
          onPressed: () => _showProfileDialog(context, ref),
        ),
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Quitter l\'espace',
          onPressed: () => _showLogoutConfirmation(context, ref),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final greeting = profileAsync.when(
      loading: () => "Bonjour !",
      error: (err, stack) => "Bonjour !",
      data: (profile) {
        if (profile == null) return "Bonjour !";
        final name = (profile.fullName != null && profile.fullName!.trim().isNotEmpty)
            ? profile.fullName!.split(' ').first
            : profile.pseudo;
        return "Bonjour $name !";
      },
    );

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: const BoxDecoration(
        color: Color(0xFF1976D2),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch_rounded, size: 80, color: Colors.white)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -10, duration: 1500.ms),
          const SizedBox(height: 16),
          Text(
            greeting,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            tr(ref, 'ready_for_adventure'),
            style: TextStyle(fontSize: 18, color: Colors.white.withValues(alpha: 0.9)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showProfileDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        bool isRegenerating = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              backgroundColor: const Color(0xFF1976D2),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    final profileAsync = ref.watch(currentUserProfileProvider);
                    return profileAsync.when(
                      loading: () => const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator(color: Colors.white)),
                      ),
                      error: (err, stack) => const Text('Erreur lors du chargement du profil', style: TextStyle(color: Colors.white)),
                      data: (profile) {
                        final code = profile?.affiliationCode ?? '------';
                        final pseudo = profile?.pseudo ?? 'Joueur';
                        final profileId = profile?.id ?? '';
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.face_rounded, size: 70, color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                              pseudo,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Profil Élève / Enfant',
                              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
                            ),
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Ton code d\'affiliation unique :',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 48,
                                    child: isRegenerating
                                        ? const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                width: 24,
                                                height: 24,
                                                child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 3),
                                              ),
                                              SizedBox(width: 12),
                                              Text(
                                                'Génération...',
                                                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        : Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(width: 32), // pour équilibrer l'icône à droite
                                              SelectableText(
                                                code,
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.amber,
                                                  letterSpacing: 4,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.refresh_rounded, color: Colors.amber),
                                                tooltip: 'Régénérer le code',
                                                onPressed: () => _showRegenerateCodeConfirmation(
                                                  context,
                                                  ref,
                                                  setDialogState,
                                                  (generating) {
                                                    setDialogState(() {
                                                      isRegenerating = generating;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Donne ce code à ton parent ou ton enseignant pour qu\'ils puissent se connecter à ton espace !',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                            ),
                            if (profileId.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              const Divider(color: Colors.white30),
                              const SizedBox(height: 16),
                              Consumer(
                                builder: (context, ref, child) {
                                  final affiliatesAsync = ref.watch(childAffiliatesProvider(profileId));
                                  return affiliatesAsync.when(
                                    loading: () => const SizedBox(
                                      height: 40,
                                      child: Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                                    ),
                                    error: (err, stack) => const Text(
                                      'Impossible de charger les adultes connectés',
                                      style: TextStyle(color: Colors.white60, fontSize: 13),
                                    ),
                                    data: (affiliates) {
                                      if (affiliates.isEmpty) {
                                        return Text(
                                          'Aucun parent ou enseignant n\'est connecté à ton compte.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white70, fontSize: 13, fontStyle: FontStyle.italic),
                                        );
                                      }
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Adultes connectés à ton compte :',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 8),
                                          ...affiliates.map((adult) => Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.check_circle_rounded, size: 16, color: Colors.greenAccent),
                                                const SizedBox(width: 8),
                                                Text(
                                                  adult.pseudo,
                                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                                ),
                                                if (adult.isSuperAdmin)
                                                  Text(
                                                    ' (Admin)',
                                                    style: TextStyle(color: Colors.amber.shade300, fontSize: 12),
                                                  ),
                                              ],
                                            ),
                                          )),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                              icon: const Icon(Icons.edit_rounded, size: 18),
                              label: const Text('Modifier mon profil', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.pop(context); // fermer le dialog
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const ChildProfileSetupScreen()),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withValues(alpha: 0.2),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter ?'),
        content: const Text('Veux-tu vraiment quitter ton espace de jeu ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Non'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final navigator = Navigator.of(context);
              navigator.pop(); // fermer la boîte de dialogue
              
              // Naviguer immédiatement vers la page de sélection de rôles et nettoyer la pile d'écrans
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                (route) => false,
              );

              // Déconnexion et invalidation en arrière-plan
              await ref.read(authRepositoryProvider).logout();
              ref.invalidate(currentUserProfileProvider);
            },
            child: const Text('Oui, quitter', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showRegenerateCodeConfirmation(
    BuildContext context,
    WidgetRef ref,
    StateSetter setDialogState,
    void Function(bool) setGenerating,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Régénérer le code ?'),
        content: const Text(
          'L\'ancien code d\'affiliation sera désactivé. Les parents ou enseignants déjà connectés à ton compte le resteront.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context); // fermer la boîte de dialogue de confirmation
              
              // Déclencher l'animation de chargement
              setGenerating(true);

              // Faire semblant que le système travaille pendant 1.5 seconde
              await Future.delayed(const Duration(milliseconds: 1500));

              try {
                await ref.read(authRepositoryProvider).regenerateAffiliationCode();
                ref.invalidate(currentUserProfileProvider);
                // Attendre la résolution effective de la récupération du nouveau profil
                await ref.read(currentUserProfileProvider.future);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur : $e')),
                  );
                }
              } finally {
                // Arrêter l'animation seulement après avoir chargé le nouveau code
                setGenerating(false);
              }
            },
            child: const Text('Régénérer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildFreePlayMode(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 80, color: Colors.amber),
              const SizedBox(height: 20),
              Text(tr(ref, 'no_challenge'), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 12),
              Text(tr(ref, 'free_play_description'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 30),
              _buildBigButton(
                context,
                title: tr(ref, 'free_play_mode'),
                icon: Icons.play_circle_fill_rounded,
                color: Colors.green.shade600,
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UnityGameScreen())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionMode(BuildContext context, WidgetRef ref, Mission mission) {
    String operationText = mission.operationType;
    if (operationText.startsWith('table_')) {
      operationText = tr(ref, 'mission_table').replaceAll('{table}', operationText.split('_')[1]);
    } else if (operationText == 'all') {
      operationText = tr(ref, 'all_tables');
    }

    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Column(
              children: [
                const Icon(Icons.stars_rounded, size: 70, color: Colors.orange),
                const SizedBox(height: 16),
                Text(tr(ref, 'new_challenge'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.orange)),
                const SizedBox(height: 20),
                Text(operationText, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(tr(ref, 'difficulty').replaceAll('{diff}', mission.difficulty.toString()), style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(height: 40),
          _buildBigButton(
            context,
            title: tr(ref, 'accept_challenge'),
            icon: Icons.flash_on_rounded,
            color: Colors.orange.shade700,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => UnityGameScreen(mission: mission))),
          ),
        ],
      ),
    );
  }

  Widget _buildBigButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 32),
        label: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 8,
        ),
        onPressed: onPressed,
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.03, 1.03), duration: 1.seconds);
  }

  Widget _buildDualMode(BuildContext context, WidgetRef ref, Mission mission) {
    String operationText = mission.operationType;
    if (operationText.startsWith('table_')) {
      operationText = tr(ref, 'mission_table').replaceAll('{table}', operationText.split('_')[1]);
    } else if (operationText == 'all') {
      operationText = tr(ref, 'all_tables');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎯 ${tr(ref, 'assigned_work')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          const SizedBox(height: 12),
          Consumer(
            builder: (context, ref, child) {
              final senderProfileAsync = ref.watch(adultProfileProvider(mission.assignedBy));
              return senderProfileAsync.when(
                loading: () => Container(
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const CircularProgressIndicator(),
                ),
                error: (err, stack) => const SizedBox(),
                data: (sender) {
                  final isTeacher = sender?.role == UserRole.teacher;
                  final Color themeColor = isTeacher ? Colors.deepPurple : Colors.orange;
                  final Color buttonColor = isTeacher ? Colors.deepPurple.shade700 : Colors.orange.shade700;
                  final IconData missionIcon = isTeacher ? Icons.school_rounded : Icons.home_rounded;
                  final String badgeText = isTeacher ? 'ÉCOLE' : 'MAISON';
                  final String challengeTitle = isTeacher ? "Mission de l'école" : "Défi de la maison";

                  final String displayName;
                  if (sender != null) {
                    displayName = sender.pseudo.startsWith('User_')
                        ? (sender.fullName ?? 'Mon tuteur')
                        : sender.pseudo;
                  } else {
                    displayName = 'Adulte';
                  }

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                      border: Border.all(color: themeColor.withValues(alpha: 0.25), width: 2),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(missionIcon, size: 36, color: themeColor),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        challengeTitle,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          color: themeColor,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: themeColor,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          badgeText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    operationText,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    tr(ref, 'difficulty').replaceAll('{diff}', mission.difficulty.toString()),
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Icon(Icons.person_pin_rounded, size: 16, color: themeColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Envoyé par : $displayName',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: themeColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildCompactButton(
                          context,
                          title: tr(ref, 'accept_challenge'),
                          icon: Icons.flash_on_rounded,
                          color: buttonColor,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => UnityGameScreen(mission: mission)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ).animate().slideX(begin: -0.05, duration: 450.ms, curve: Curves.easeOutQuad),

          const SizedBox(height: 24),

          Text(
            '🏎️ ${tr(ref, 'free_play_title')}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
              border: Border.all(color: Colors.green.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome_rounded, size: 36, color: Colors.green),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tr(ref, 'free_play_mode'),
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.green.shade700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr(ref, 'free_play_description'),
                            style: const TextStyle(fontSize: 13, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildCompactButton(
                  context,
                  title: tr(ref, 'play_free'),
                  icon: Icons.play_circle_fill_rounded,
                  color: Colors.green.shade600,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const UnityGameScreen()),
                  ),
                ),
              ],
            ),
          ).animate().slideX(begin: 0.05, duration: 450.ms, curve: Curves.easeOutQuad),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompactButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onPressed}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 22),
        label: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
