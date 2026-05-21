import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../providers/affiliation_providers.dart';
import '../providers/class_providers.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/affiliated_child.dart';
import 'affiliation_screen.dart';
import 'assign_mission_screen.dart';
import 'child_statistics_screen.dart';
import 'manage_access_screen.dart';
import 'unity_game_screen.dart';
import '../providers/translation_providers.dart';
import 'adult_profile_setup_screen.dart';
import '../providers/session_tracker.dart';
import 'role_selection_screen.dart';
import 'class_statistics_screen.dart';
import 'class_students_management_screen.dart';

class AdultDashboardScreen extends ConsumerWidget {
  const AdultDashboardScreen({super.key});

  List<Widget> _buildAppBarActions(BuildContext context, WidgetRef ref) {
    return [
      IconButton(
        icon: const Icon(Icons.account_circle),
        tooltip: 'Mon Profil',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AdultProfileSetupScreen(isFirstSetup: false)),
          );
        },
      ),
      // Sélecteur de langue
      PopupMenuButton<String>(
        icon: const Icon(Icons.language),
        onSelected: (code) => ref.read(languageProvider.notifier).setLanguage(code),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'fr', child: Text('Français')),
          const PopupMenuItem(value: 'en', child: Text('English')),
          const PopupMenuItem(value: 'wolof', child: Text('Wolof')),
        ],
      ),
      IconButton(
        icon: const Icon(Icons.star, color: Colors.amber),
        tooltip: 'Devenir Premium (Test)',
        onPressed: () async {
          try {
            await ref.read(authRepositoryProvider).simulatePayment();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('🎉 Vous êtes Premium ! Relancez l\'app pour voir vos pouvoirs.')),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Erreur: $e')),
              );
            }
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.gamepad),
        tooltip: 'Lancer le jeu',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const UnityGameScreen()),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.logout_rounded),
        tooltip: 'Se déconnecter',
        onPressed: () async {
          final navigator = Navigator.of(context);
          
          // Naviguer immédiatement vers la page de sélection de rôles et nettoyer la pile d'écrans
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
            (route) => false,
          );

          // Déconnexion et invalidation en arrière-plan
          await ref.read(authRepositoryProvider).logout();
          ref.invalidate(currentUserProfileProvider);
        },
      ),
    ];
  }

  Widget _buildSortToolbar(
    BuildContext context,
    WidgetRef ref,
    String currentSortPref,
    int count,
    bool isTeacher,
    bool isSelectionMode,
  ) {
    String sortLabel = "Personnalisé";
    IconData sortIcon = Icons.sort_rounded;
    if (currentSortPref == 'alpha_asc') {
      sortLabel = "Nom (A-Z)";
      sortIcon = Icons.arrow_upward_rounded;
    } else if (currentSortPref == 'alpha_desc') {
      sortLabel = "Nom (Z-A)";
      sortIcon = Icons.arrow_downward_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isTeacher
                ? '$count élève${count > 1 ? 's' : ''}'
                : '$count enfant${count > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          if (!isSelectionMode && count > 0) ...[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () => ref.read(dashboardSelectionProvider.notifier).enterSelectionMode(),
                  icon: const Icon(Icons.person_remove_outlined, color: Colors.red, size: 16),
                  label: Text(
                    isTeacher ? 'Désaffilier' : 'Se désaffilier',
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: currentSortPref,
                  tooltip: 'Trier la liste',
                  onSelected: (String val) {
                    ref
                        .read(studentSortPreferenceProvider.notifier)
                        .updatePreference(val);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sortIcon, size: 16, color: Colors.teal.shade700),
                        const SizedBox(width: 6),
                        Text(
                          sortLabel,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down,
                            size: 16, color: Colors.teal.shade700),
                      ],
                    ),
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'custom',
                      child: Row(
                        children: [
                          Icon(Icons.sort_rounded, color: Colors.indigo),
                          SizedBox(width: 8),
                          Text('Ordre personnalisé'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'alpha_asc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('Nom (A-Z)'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'alpha_desc',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward_rounded, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('Nom (Z-A)'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ] else if (isSelectionMode && count > 0) ...[
            Text(
              'Mode sélection actif',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentsTab(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AffiliatedChild>> childrenAsyncValue,
    bool isTeacher,
  ) {
    final sortPrefAsync = ref.watch(studentSortPreferenceProvider);
    final selectionState = ref.watch(dashboardSelectionProvider);
    final isSelectionMode = selectionState.isSelectionMode;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: childrenAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erreur: $error', style: const TextStyle(color: Colors.red)),
        ),
        data: (children) {
          final sortPref = sortPrefAsync.value ?? 'custom';

          return Column(
            children: [
              _buildSortToolbar(context, ref, sortPref, children.length, isTeacher, isSelectionMode),
              Expanded(
                child: ReorderableAffiliatedChildrenList(
                  children: children,
                  isTeacher: isTeacher,
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: !isSelectionMode
          ? FloatingActionButton.extended(
              heroTag: 'affiliateFab',
              backgroundColor: Colors.orange.shade600,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: Text(isTeacher ? tr(ref, 'affiliate_student') : tr(ref, 'affiliate_child')),
              onPressed: () async {
                // Navigue vers l'écran d'affiliation et attend le retour
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AffiliationScreen()),
                );
                // Au retour, on force le rafraîchissement de la liste
                ref.invalidate(affiliatedChildrenProvider);
              },
            )
          : null,
    );
  }

  Widget _buildClassesTab(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherClassesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: classesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erreur: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (classes) {
          if (classes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.school_rounded, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucune classe créée pour le moment.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une classe'),
                    onPressed: () => _showCreateClassDialog(context, ref),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final schoolClass = classes[index];
              
              // On peut écouter le nombre d'élèves
              final studentsAsync = ref.watch(classStudentsProvider(schoolClass.id));
              final studentsCount = studentsAsync.maybeWhen(
                data: (list) => '${list.length} élève(s)',
                orElse: () => 'Chargement...',
              );

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple.shade100,
                    foregroundColor: Colors.deepPurple.shade800,
                    child: const Icon(Icons.school),
                  ),
                  title: Text(
                    schoolClass.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(studentsCount),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.group_add_rounded, color: Colors.teal),
                        tooltip: 'Gérer les élèves',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassStudentsManagementScreen(schoolClass: schoolClass),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.bar_chart_rounded, color: Colors.indigo),
                        tooltip: 'Statistiques de la classe',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClassStatisticsScreen(classId: schoolClass.id),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.orange),
                        tooltip: 'Donner une mission',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignMissionScreen(schoolClass: schoolClass),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                        tooltip: 'Supprimer la classe',
                        onPressed: () => _confirmDeleteClass(context, ref, schoolClass),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ClassStudentsManagementScreen(schoolClass: schoolClass),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'createClassFab',
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Créer une classe'),
        onPressed: () => _showCreateClassDialog(context, ref),
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer une nouvelle classe'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nom de la classe (ex: CE2-A, CM1)',
            hintText: 'Entrez un nom...',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              try {
                await ref.read(teacherClassesProvider.notifier).createClass(name);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Classe "$name" créée avec succès !')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClass(BuildContext context, WidgetRef ref, SchoolClass schoolClass) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la classe ?'),
        content: Text('Voulez-vous vraiment supprimer la classe "${schoolClass.name}" ? Cela ne supprimera pas vos élèves affiliés.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(teacherClassesProvider.notifier).deleteClass(schoolClass.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Classe "${schoolClass.name}" supprimée.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveSelectedChildren(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedChildIds,
    bool isTeacher,
  ) {
    final count = selectedChildIds.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTeacher ? 'Désaffilier les élèves ?' : 'Se désaffilier ?'),
        content: Text(
          isTeacher
              ? 'Voulez-vous vraiment désaffilier les $count élèves sélectionnés ? Ils n\'apparaîtront plus sur votre tableau de bord et seront retirés de toutes vos classes.'
              : 'Voulez-vous vraiment vous désaffilier des $count enfants sélectionnés ? Ils n\'apparaîtront plus sur votre tableau de bord.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              final idsToRemove = List<String>.from(selectedChildIds);
              
              // Sortir du mode sélection d'abord
              ref.read(dashboardSelectionProvider.notifier).exitSelectionMode();

              final currentUser = ref.read(supabaseClientProvider).auth.currentUser;
              final currentUserId = currentUser?.id;
              if (currentUserId == null) return;

              int successCount = 0;
              for (final childId in idsToRemove) {
                try {
                  await ref.read(revokeAffiliationUseCaseProvider).execute(
                    adultId: currentUserId,
                    childId: childId,
                  );
                  successCount++;
                } catch (e) {
                  // Ignorer l'erreur individuelle
                }
              }

              // Rafraîchir les données
              ref.invalidate(affiliatedChildrenProvider);
              if (isTeacher) {
                ref.invalidate(teacherClassesProvider);
                final classesVal = ref.read(teacherClassesProvider).value;
                if (classesVal != null) {
                  for (final schoolClass in classesVal) {
                    ref.invalidate(classStudentsProvider(schoolClass.id));
                  }
                }
              }

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isTeacher
                          ? '$successCount élève(s) désaffilié(s) avec succès.'
                          : 'Vous vous êtes désaffilié de $successCount enfant(s).',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Confirmer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mettre à jour l'activité
    SessionTracker.updateActivity();

    // Écoute le provider qui charge la liste des enfants
    final childrenAsyncValue = ref.watch(affiliatedChildrenProvider);
    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';

    final selectionState = ref.watch(dashboardSelectionProvider);
    final isSelectionMode = selectionState.isSelectionMode;
    final selectedCount = selectionState.selectedChildIds.length;

    if (isTeacher) {
      return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: isSelectionMode
              ? AppBar(
                  title: Text('$selectedCount sélectionné(s)'),
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                  leading: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => ref.read(dashboardSelectionProvider.notifier).exitSelectionMode(),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        selectionState.selectedChildIds.length == (childrenAsyncValue.value?.length ?? 0)
                            ? Icons.deselect
                            : Icons.select_all,
                      ),
                      tooltip: selectionState.selectedChildIds.length == (childrenAsyncValue.value?.length ?? 0)
                          ? 'Tout désélectionner'
                          : 'Tout sélectionner',
                      onPressed: () {
                        final children = childrenAsyncValue.value ?? [];
                        final ids = children.map((c) => c.profile.id).toList();
                        if (selectionState.selectedChildIds.length == children.length) {
                          ref.read(dashboardSelectionProvider.notifier).clearSelection();
                        } else {
                          ref.read(dashboardSelectionProvider.notifier).selectAll(ids);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Désaffilier les élèves sélectionnés',
                      onPressed: selectionState.selectedChildIds.isEmpty
                          ? null
                          : () => _confirmRemoveSelectedChildren(context, ref, selectionState.selectedChildIds, isTeacher),
                    ),
                  ],
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: IgnorePointer(
                      ignoring: true,
                      child: Opacity(
                        opacity: 0.5,
                        child: const TabBar(
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white70,
                          indicatorColor: Colors.amber,
                          tabs: [
                            Tab(icon: Icon(Icons.people), text: 'Mes élèves'),
                            Tab(icon: Icon(Icons.school), text: 'Mes classes'),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : AppBar(
                  title: Text(tr(ref, 'teacher_dashboard_title')),
                  backgroundColor: Colors.deepPurple.shade700,
                  foregroundColor: Colors.white,
                  bottom: const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.amber,
                    tabs: [
                      Tab(icon: Icon(Icons.people), text: 'Mes élèves'),
                      Tab(icon: Icon(Icons.school), text: 'Mes classes'),
                    ],
                  ),
                  actions: _buildAppBarActions(context, ref),
                ),
          body: TabBarView(
            children: [
              _buildStudentsTab(context, ref, childrenAsyncValue, isTeacher),
              _buildClassesTab(context, ref),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: isSelectionMode
          ? AppBar(
              title: Text('$selectedCount sélectionné(s)'),
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => ref.read(dashboardSelectionProvider.notifier).exitSelectionMode(),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    selectionState.selectedChildIds.length == (childrenAsyncValue.value?.length ?? 0)
                        ? Icons.deselect
                        : Icons.select_all,
                  ),
                  tooltip: selectionState.selectedChildIds.length == (childrenAsyncValue.value?.length ?? 0)
                      ? 'Tout désélectionner'
                      : 'Tout sélectionner',
                  onPressed: () {
                    final children = childrenAsyncValue.value ?? [];
                    final ids = children.map((c) => c.profile.id).toList();
                    if (selectionState.selectedChildIds.length == children.length) {
                      ref.read(dashboardSelectionProvider.notifier).clearSelection();
                    } else {
                      ref.read(dashboardSelectionProvider.notifier).selectAll(ids);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Se désaffilier des enfants sélectionnés',
                  onPressed: selectionState.selectedChildIds.isEmpty
                      ? null
                      : () => _confirmRemoveSelectedChildren(context, ref, selectionState.selectedChildIds, isTeacher),
                ),
              ],
            )
          : AppBar(
              title: Text(tr(ref, 'dashboard_title')),
              backgroundColor: Colors.teal.shade700,
              foregroundColor: Colors.white,
              actions: _buildAppBarActions(context, ref),
            ),
      body: _buildStudentsTab(context, ref, childrenAsyncValue, isTeacher),
    );
  }
}

class ReorderableAffiliatedChildrenList extends ConsumerStatefulWidget {
  final List<AffiliatedChild> children;
  final bool isTeacher;

  const ReorderableAffiliatedChildrenList({
    super.key,
    required this.children,
    required this.isTeacher,
  });

  @override
  ConsumerState<ReorderableAffiliatedChildrenList> createState() =>
      _ReorderableAffiliatedChildrenListState();
}

class _ReorderableAffiliatedChildrenListState
    extends ConsumerState<ReorderableAffiliatedChildrenList> {
  late List<AffiliatedChild> _localChildren;

  @override
  void initState() {
    super.initState();
    _localChildren = List<AffiliatedChild>.from(widget.children);
  }

  @override
  void didUpdateWidget(ReorderableAffiliatedChildrenList oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si la liste provenant du provider change (ex: ajout/retrait), on synchronise la liste locale
    if (widget.children != oldWidget.children) {
      _localChildren = List<AffiliatedChild>.from(widget.children);
    }
  }

  String _getChildDisplayName(AffiliatedChild child, bool isTeacher) {
    final profile = child.profile;
    if (profile.fullName != null && profile.fullName!.trim().isNotEmpty) {
      return isTeacher
          ? profile.fullName!
          : profile.fullName!.trim().split(' ').first;
    }
    return profile.pseudo;
  }

  Future<void> _showUnaffiliateDialog(
    BuildContext context,
    WidgetRef ref,
    AffiliatedChild child,
    bool isTeacher,
  ) async {
    final displayName = _getChildDisplayName(child, isTeacher);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTeacher ? 'Désaffilier l\'élève ?' : 'Se désaffilier de l\'enfant ?'),
        content: Text(
          isTeacher
              ? 'Voulez-vous vraiment désaffilier $displayName ? Il n\'apparaîtra plus sur votre tableau de bord.'
              : 'Voulez-vous vraiment vous désaffilier de $displayName ? Il n\'apparaîtra plus sur votre tableau de bord.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final currentUser = ref.read(supabaseClientProvider).auth.currentUser;
      final currentUserId = currentUser?.id;
      if (currentUserId == null) return;

      try {
        await ref.read(revokeAffiliationUseCaseProvider).execute(
          adultId: currentUserId,
          childId: child.profile.id,
        );
        ref.invalidate(affiliatedChildrenProvider);
        if (isTeacher) {
          ref.invalidate(teacherClassesProvider);
          final classesVal = ref.read(teacherClassesProvider).value;
          if (classesVal != null) {
            for (final schoolClass in classesVal) {
              ref.invalidate(classStudentsProvider(schoolClass.id));
            }
          }
        }
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isTeacher
                    ? '$displayName a été désaffilié avec succès.'
                    : 'Vous vous êtes désaffilié de $displayName.',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortPrefAsync = ref.watch(studentSortPreferenceProvider);
    final sortPref = sortPrefAsync.value ?? 'custom';

    final selectionState = ref.watch(dashboardSelectionProvider);
    final isSelectionMode = selectionState.isSelectionMode;
    final selectedChildIds = selectionState.selectedChildIds;

    if (_localChildren.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isTeacher
                  ? Icons.school_rounded
                  : Icons.family_restroom_rounded,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              widget.isTeacher ? tr(ref, 'no_student_yet') : tr(ref, 'no_child_yet'),
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    final isTeacher = widget.isTeacher;

    // Trier les enfants en fonction de la préférence de tri
    List<AffiliatedChild> displayList = List<AffiliatedChild>.from(_localChildren);
    if (sortPref == 'alpha_asc') {
      displayList.sort((a, b) {
        final nameA = _getChildDisplayName(a, isTeacher).toLowerCase();
        final nameB = _getChildDisplayName(b, isTeacher).toLowerCase();
        return nameA.compareTo(nameB);
      });
    } else if (sortPref == 'alpha_desc') {
      displayList.sort((a, b) {
        final nameA = _getChildDisplayName(a, isTeacher).toLowerCase();
        final nameB = _getChildDisplayName(b, isTeacher).toLowerCase();
        return nameB.compareTo(nameA);
      });
    } else {
      // custom: trié par sortOrder
      displayList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.all(16.0),
      itemCount: displayList.length,
      onReorder: isSelectionMode
          ? (_, __) {}
          : (oldIndex, newIndex) async {
              if (newIndex > oldIndex) newIndex--;

              final reordered = List<AffiliatedChild>.from(displayList);
              final movedChild = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, movedChild);

              final updatedReordered = reordered.asMap().entries.map((entry) {
                return entry.value.copyWith(sortOrder: entry.key);
              }).toList();

              setState(() {
                _localChildren = updatedReordered;
              });

              // Si l'utilisateur réorganise alors qu'il était en tri alphabétique,
              // on bascule automatiquement la préférence sur "custom"
              if (sortPref != 'custom') {
                ref
                    .read(studentSortPreferenceProvider.notifier)
                    .updatePreference('custom');
              }

              // Enregistrer le nouvel ordre en base de données en tâche de fond
              try {
                final repo = ref.read(affiliationRepositoryProvider);
                await Future.wait(
                  updatedReordered.asMap().entries.map((entry) {
                    return repo.updateSortOrder(
                      childId: entry.value.profile.id,
                      sortOrder: entry.key,
                    );
                  }),
                );
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur lors de la sauvegarde de l\'ordre : $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
      proxyDecorator: (child, index, animation) {
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            // Immediate lift and scale feedback on drag start
            final elevation = Tween<double>(begin: 6, end: 12).evaluate(animation);
            final scale = Tween<double>(begin: 1.02, end: 1.05).evaluate(animation);
            final outlineColor = widget.isTeacher ? Colors.deepPurple.shade400 : Colors.teal.shade400;
            final borderOpacity = Tween<double>(begin: 0.6, end: 1.0).evaluate(animation);
            final tintOpacity = Tween<double>(begin: 0.04, end: 0.08).evaluate(animation);

            return Transform.scale(
              scale: scale,
              child: Material(
                elevation: elevation,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(15),
                shadowColor: Colors.black45,
                child: Stack(
                  children: [
                    child ?? const SizedBox(),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            // Soft tint highlight during drag
                            color: outlineColor.withOpacity(tintOpacity),
                            border: Border.all(
                              color: outlineColor.withOpacity(borderOpacity),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          child: child,
        );
      },
      itemBuilder: (context, index) {
        final child = displayList[index];
        final isSelected = selectedChildIds.contains(child.profile.id);
        return Card(
          key: ValueKey(child.profile.id),
          elevation: 3,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isSelectionMode && isSelected
                ? BorderSide(color: Colors.red.shade400, width: 2)
                : BorderSide.none,
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            leading: isSelectionMode
                ? Checkbox(
                    value: isSelected,
                    activeColor: Colors.red,
                    onChanged: (val) {
                      ref
                          .read(dashboardSelectionProvider.notifier)
                          .toggleSelection(child.profile.id);
                    },
                  )
                : CircleAvatar(
                    backgroundColor: Colors.green.shade100,
                    foregroundColor: Colors.green.shade800,
                    child: const Icon(Icons.face),
                  ),
            title: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style:
                          const TextStyle(fontSize: 18, color: Colors.black87),
                      children: [
                        TextSpan(
                          text: (child.profile.fullName != null &&
                                  child.profile.fullName!.trim().isNotEmpty)
                              ? (isTeacher
                                  ? child.profile.fullName!
                                  : child.profile.fullName!
                                      .trim()
                                      .split(' ')
                                      .first)
                              : child.profile.pseudo,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (child.profile.fullName != null &&
                            child.profile.fullName!.trim().isNotEmpty) ...[
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: '(${child.profile.pseudo})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (child.isSuperAdmin)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('👑', style: TextStyle(fontSize: 18)),
                  ),
              ],
            ),
            subtitle: Text(child.isSuperAdmin
                ? (isTeacher
                    ? 'Enseignant Principal'
                    : 'Responsable (Super-Admin)')
                : (isTeacher
                    ? 'Co-Enseignant / Observateur'
                    : 'Consultant / Enseignant')),
            trailing: isSelectionMode
                ? null
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.bar_chart, color: Colors.indigo),
                        tooltip: 'Voir les progrès',
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ChildStatisticsScreen(child: child.profile),
                            ),
                          );
                        },
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.settings, color: Colors.teal),
                        tooltip: 'Options',
                        onSelected: (val) {
                          if (val == 'manage') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManageAccessScreen(
                                  child: child.profile,
                                  isUserSuperAdmin: child.isSuperAdmin,
                                ),
                              ),
                            );
                          } else if (val == 'unaffiliate') {
                            _showUnaffiliateDialog(context, ref, child, isTeacher);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'manage',
                            child: Row(
                              children: [
                                Icon(Icons.people_outline, color: Colors.teal.shade700),
                                const SizedBox(width: 8),
                                const Text('Gérer les accès'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'unaffiliate',
                            child: Row(
                              children: [
                                const Icon(Icons.person_remove, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  isTeacher ? 'Désaffilier l\'élève' : 'Se désaffilier',
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Listener(
                        onPointerDown: (_) {
                          HapticFeedback.lightImpact();
                        },
                        child: ReorderableDragStartListener(
                          index: index,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.drag_handle_rounded,
                              color: sortPref == 'custom' ? Colors.grey.shade500 : Colors.grey.shade300,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            onTap: isSelectionMode
                ? () {
                    ref
                        .read(dashboardSelectionProvider.notifier)
                        .toggleSelection(child.profile.id);
                  }
                : () {
                    // Naviguer vers l'écran de création de mission pour cet enfant
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignMissionScreen(child: child.profile),
                      ),
                    );
                  },
          ),
        );
      },
    );
  }
}

