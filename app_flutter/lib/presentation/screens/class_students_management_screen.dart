import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/class_providers.dart';
import '../providers/affiliation_providers.dart';
import 'class_statistics_screen.dart';
import 'child_statistics_screen.dart';

class ClassStudentsManagementScreen extends ConsumerStatefulWidget {
  final SchoolClass schoolClass;

  const ClassStudentsManagementScreen({super.key, required this.schoolClass});

  @override
  ConsumerState<ClassStudentsManagementScreen> createState() => _ClassStudentsManagementScreenState();
}

class _ClassStudentsManagementScreenState extends ConsumerState<ClassStudentsManagementScreen> {
  bool _isSelectionMode = false;
  final Set<String> _selectedStudentIds = {};
  List<UserProfile>? _localStudents;

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedStudentIds.clear();
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  bool _areListsEqual(List<UserProfile> a, List<UserProfile> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].sortOrder != b[i].sortOrder || a[i].pseudo != b[i].pseudo || a[i].fullName != b[i].fullName) {
        return false;
      }
    }
    return true;
  }

  String _getStudentDisplayName(UserProfile student) {
    if (student.fullName != null && student.fullName!.trim().isNotEmpty) {
      return student.fullName!;
    }
    return student.pseudo;
  }

  Widget _buildSortToolbar(
    BuildContext context,
    String currentSortPref,
    int count,
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
            '$count élève${count > 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          PopupMenuButton<String>(
            initialValue: currentSortPref,
            tooltip: 'Trier la liste',
            onSelected: (String val) {
              ref
                  .read(teacherClassesProvider.notifier)
                  .updateClassSortPreference(widget.schoolClass.id, val);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(sortIcon, size: 16, color: Colors.deepPurple.shade700),
                  const SizedBox(width: 6),
                  Text(
                    sortLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple.shade800,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down,
                      size: 16, color: Colors.deepPurple.shade700),
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
                    Icon(Icons.arrow_upward_rounded, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Nom (A-Z)'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'alpha_desc',
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward_rounded, color: Colors.deepPurple),
                    SizedBox(width: 8),
                    Text('Nom (Z-A)'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmRemoveSingleStudent(BuildContext context, UserProfile student) {
    final displayName = _getStudentDisplayName(student);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retirer de la classe ?'),
        content: Text('Voulez-vous vraiment retirer $displayName de la classe ${widget.schoolClass.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(classStudentsProvider(widget.schoolClass.id).notifier).removeStudent(student.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$displayName a été retiré de la classe.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Retirer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(classStudentsProvider(widget.schoolClass.id));
    final sortPref = ref.watch(classSortPreferenceProvider(widget.schoolClass.id));

    return Scaffold(
      appBar: AppBar(
        title: _isSelectionMode
            ? Text('${_selectedStudentIds.length} sélectionné(s)')
            : Text('Élèves de ${widget.schoolClass.name}'),
        backgroundColor: _isSelectionMode ? Colors.red.shade800 : Colors.deepPurple.shade700,
        foregroundColor: Colors.white,
        leading: _isSelectionMode
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: _exitSelectionMode,
              )
            : null,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: Icon(
                _selectedStudentIds.length == (studentsAsync.value?.length ?? 0)
                    ? Icons.deselect
                    : Icons.select_all,
              ),
              tooltip: _selectedStudentIds.length == (studentsAsync.value?.length ?? 0)
                  ? 'Tout désélectionner'
                  : 'Tout sélectionner',
              onPressed: () {
                final students = studentsAsync.value ?? [];
                setState(() {
                  if (_selectedStudentIds.length == students.length) {
                    _selectedStudentIds.clear();
                  } else {
                    _selectedStudentIds.clear();
                    _selectedStudentIds.addAll(students.map((s) => s.id));
                  }
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Retirer de la classe',
              onPressed: _selectedStudentIds.isEmpty
                  ? null
                  : () => _confirmRemoveSelectedStudents(context),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Statistiques de la classe',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClassStatisticsScreen(classId: widget.schoolClass.id),
                  ),
                );
              },
            ),
            studentsAsync.maybeWhen(
              data: (students) => students.isNotEmpty
                  ? TextButton.icon(
                      icon: const Icon(Icons.person_remove_outlined, color: Colors.white),
                      label: const Text(
                        'Retirer',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _enterSelectionMode,
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ]
        ],
      ),
      body: studentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err', style: const TextStyle(color: Colors.red))),
        data: (students) {
          if (students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline_rounded, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun élève dans cette classe.',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter des élèves'),
                    onPressed: () => _showAddStudentsDialog(context, students),
                  ),
                ],
              ),
            );
          }

          if (_localStudents == null || !_areListsEqual(_localStudents!, students)) {
            _localStudents = List<UserProfile>.from(students);
          }

          // Trier les élèves en fonction de la préférence de tri
          List<UserProfile> displayList = List<UserProfile>.from(_localStudents!);
          if (sortPref == 'alpha_asc') {
            displayList.sort((a, b) {
              final nameA = _getStudentDisplayName(a).toLowerCase();
              final nameB = _getStudentDisplayName(b).toLowerCase();
              return nameA.compareTo(nameB);
            });
          } else if (sortPref == 'alpha_desc') {
            displayList.sort((a, b) {
              final nameA = _getStudentDisplayName(a).toLowerCase();
              final nameB = _getStudentDisplayName(b).toLowerCase();
              return nameB.compareTo(nameA);
            });
          } else {
            // custom: trié par sortOrder
            displayList.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
          }

          return Column(
            children: [
              _buildSortToolbar(context, sortPref, displayList.length),
              Expanded(
                child: ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  padding: const EdgeInsets.all(16),
                  itemCount: displayList.length,
                  onReorder: _isSelectionMode
                      ? (_, __) {}
                      : (oldIndex, newIndex) async {
                          if (newIndex > oldIndex) newIndex--;

                          final reordered = List<UserProfile>.from(displayList);
                          final movedStudent = reordered.removeAt(oldIndex);
                          reordered.insert(newIndex, movedStudent);

                          final updatedReordered = reordered.asMap().entries.map((entry) {
                            return entry.value.copyWith(sortOrder: entry.key);
                          }).toList();

                          setState(() {
                            _localStudents = updatedReordered;
                          });

                          // Basculer en mode personnalisé si trié différemment
                          if (sortPref != 'custom') {
                            await ref.read(teacherClassesProvider.notifier).updateClassSortPreference(widget.schoolClass.id, 'custom');
                          }

                          try {
                            await ref.read(classStudentsProvider(widget.schoolClass.id).notifier).updateStudentsOrder(
                                  updatedReordered,
                                  ref.read(updateClassStudentSortOrderUseCaseProvider),
                                );
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur lors du déplacement : $e'),
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
                        final outlineColor = Colors.deepPurple.shade400;
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
                    final student = displayList[index];
                    final isSelected = _selectedStudentIds.contains(student.id);
                    final name = _getStudentDisplayName(student);

                    return Card(
                      key: ValueKey(student.id),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: _isSelectionMode && isSelected
                            ? BorderSide(color: Colors.red.shade400, width: 2)
                            : BorderSide.none,
                      ),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: _isSelectionMode
                            ? Checkbox(
                                value: isSelected,
                                activeColor: Colors.red,
                                onChanged: (val) {
                                  setState(() {
                                    if (val == true) {
                                      _selectedStudentIds.add(student.id);
                                    } else {
                                      _selectedStudentIds.remove(student.id);
                                    }
                                  });
                                },
                              )
                            : const CircleAvatar(
                                backgroundColor: Colors.deepPurpleAccent,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                        title: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: student.fullName != null && student.fullName!.trim().isNotEmpty
                            ? Text('Pseudo: ${student.pseudo}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13))
                            : null,
                        trailing: _isSelectionMode
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
                                              ChildStatisticsScreen(child: student),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                                    tooltip: 'Retirer de la classe',
                                    onPressed: () => _confirmRemoveSingleStudent(context, student),
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
                        onTap: _isSelectionMode
                            ? () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedStudentIds.remove(student.id);
                                  } else {
                                    _selectedStudentIds.add(student.id);
                                  }
                                });
                              }
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: !_isSelectionMode && studentsAsync.value != null && studentsAsync.value!.isNotEmpty
          ? FloatingActionButton.extended(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter des élèves'),
              onPressed: () => _showAddStudentsDialog(context, studentsAsync.value!),
            )
          : null,
    );
  }

  void _showAddStudentsDialog(BuildContext context, List<UserProfile> currentStudents) {
    // Le Set DOIT être déclaré ICI, en dehors du builder,
    // pour persister entre les rebuilds du StatefulBuilder.
    final Set<String> selectedToAdd = {};

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {

            return AlertDialog(
              title: const Text('Ajouter des élèves'),
              content: Consumer(
                builder: (context, ref, child) {
                  final affiliatesAsync = ref.watch(affiliatedChildrenProvider);
                  return affiliatesAsync.when(
                    loading: () => const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => Text('Erreur: $err'),
                    data: (affiliates) {
                      // Filtrer les affiliés qui ne sont pas déjà dans la classe
                      final availableStudents = affiliates
                          .where((aff) => !currentStudents.any((s) => s.id == aff.profile.id))
                          .toList();

                      if (availableStudents.isEmpty) {
                        return const Text(
                          'Tous vos élèves affiliés sont déjà dans cette classe ou vous n\'avez aucun élève affilié.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        );
                      }

                      return SizedBox(
                        width: double.maxFinite,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Sélectionnez les élèves à ajouter à la classe :',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: availableStudents.length,
                                itemBuilder: (context, index) {
                                  final childAff = availableStudents[index];
                                  final student = childAff.profile;
                                  final isChecked = selectedToAdd.contains(student.id);
                                  // Prénom + initiale du nom pour les enseignants
                                  final displayName = (student.fullName != null && student.fullName!.trim().isNotEmpty)
                                      ? (() {
                                          final parts = student.fullName!.trim().split(' ');
                                          if (parts.length > 1) {
                                            return '${parts.first} ${parts.last[0]}.';
                                          }
                                          return parts.first;
                                        })()
                                      : student.pseudo;

                                  return CheckboxListTile(
                                    title: Text(displayName),
                                    subtitle: student.fullName != null && student.fullName!.trim().isNotEmpty
                                        ? Text('Pseudo: ${student.pseudo}')
                                        : null,
                                    value: isChecked,
                                    activeColor: Colors.deepPurple,
                                    onChanged: (val) {
                                      setDialogState(() {
                                        if (val == true) {
                                          selectedToAdd.add(student.id);
                                        } else {
                                          selectedToAdd.remove(student.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (selectedToAdd.isEmpty) {
                      Navigator.pop(context);
                      return;
                    }

                    // Récupérer la liste complète des profils à ajouter
                    final affiliates = ref.read(affiliatedChildrenProvider).value ?? [];
                    final studentsToAdd = affiliates
                        .map((aff) => aff.profile)
                        .where((p) => selectedToAdd.contains(p.id))
                        .toList();

                    Navigator.pop(context);

                    // Afficher un indicateur de chargement global si nécessaire, ou exécuter en boucle
                    int successCount = 0;
                    for (final student in studentsToAdd) {
                      try {
                        await ref.read(classStudentsProvider(widget.schoolClass.id).notifier).addStudent(student);
                        successCount++;
                      } catch (e) {
                        // Ignorer ou log l'erreur individuelle
                      }
                    }

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$successCount élève(s) ajouté(s) avec succès !'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: const Text('Ajouter'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmRemoveSelectedStudents(BuildContext context) {
    final count = _selectedStudentIds.length;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Retirer de la classe ?'),
        content: Text('Voulez-vous vraiment retirer les $count élèves sélectionnés de la classe ${widget.schoolClass.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final idsToRemove = List<String>.from(_selectedStudentIds);
              _exitSelectionMode();

              int successCount = 0;
              for (final id in idsToRemove) {
                try {
                  await ref.read(classStudentsProvider(widget.schoolClass.id).notifier).removeStudent(id);
                  successCount++;
                } catch (e) {
                  // Erreur individuelle
                }
              }

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$successCount élève(s) retiré(s) de la classe.'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Retirer', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
