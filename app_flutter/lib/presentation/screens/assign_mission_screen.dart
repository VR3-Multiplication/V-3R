import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/mission_providers.dart';
import '../providers/class_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/school_class.dart';

class AssignMissionScreen extends ConsumerStatefulWidget {
  final UserProfile? child;
  final SchoolClass? schoolClass;

  const AssignMissionScreen({
    super.key,
    this.child,
    this.schoolClass,
  }) : assert(child != null || schoolClass != null);

  @override
  ConsumerState<AssignMissionScreen> createState() => _AssignMissionScreenState();
}

class _AssignMissionScreenState extends ConsumerState<AssignMissionScreen> {
  bool _isAllTables = false;
  final Set<int> _selectedTables = {5}; // Par défaut : Table de 5
  int _selectedDifficulty = 1;
  bool _isLoading = false;

  // Objectifs personnalisés
  bool _useCustomGoals = false;
  int _maxErrors = 3;
  double _avgTime = 3.0;
  double _questionTime = 5.0;

  Future<void> _submitMission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final String operationType;
      if (_isAllTables) {
        operationType = _useCustomGoals
            ? 'all?max_errors=$_maxErrors&avg_time=${_avgTime.toStringAsFixed(1)}&question_time=${_questionTime.toStringAsFixed(1)}'
            : 'all';
      } else {
        if (_selectedTables.isEmpty) {
          throw Exception('Veuillez sélectionner au moins une table de multiplication.');
        }
        final sortedTables = _selectedTables.toList()..sort();
        final base = 'table_${sortedTables.join(',')}';
        operationType = _useCustomGoals
            ? '$base?max_errors=$_maxErrors&avg_time=${_avgTime.toStringAsFixed(1)}&question_time=${_questionTime.toStringAsFixed(1)}'
            : base;
      }

      final adultId = Supabase.instance.client.auth.currentUser!.id;
      final useCase = ref.read(assignMissionUseCaseProvider);
      
      if (widget.schoolClass != null) {
        final studentsAsync = ref.read(classStudentsProvider(widget.schoolClass!.id));
        final students = studentsAsync.value ?? [];
        if (students.isEmpty) {
          throw Exception('La classe ne contient aucun élève.');
        }
        for (final student in students) {
          await useCase.execute(
            assignedBy: adultId,
            assignedTo: student.id,
            operationType: operationType,
            difficulty: _selectedDifficulty,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mission envoyée à la classe ${widget.schoolClass!.name} !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        await useCase.execute(
          assignedBy: adultId,
          assignedTo: widget.child!.id,
          operationType: operationType,
          difficulty: _selectedDifficulty,
        );

        if (mounted) {
          final currentUser = Supabase.instance.client.auth.currentUser;
          final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';
          final childName = (widget.child!.fullName != null && widget.child!.fullName!.trim().isNotEmpty)
              ? (isTeacher ? widget.child!.fullName! : widget.child!.fullName!.trim().split(' ').first)
              : widget.child!.pseudo;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mission envoyée à $childName !'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;
    final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';
    
    final String displayName;
    if (widget.schoolClass != null) {
      displayName = 'la classe ${widget.schoolClass!.name}';
    } else {
      final child = widget.child!;
      displayName = (child.fullName != null && child.fullName!.trim().isNotEmpty)
          ? (isTeacher ? child.fullName! : child.fullName!.trim().split(' ').first)
          : child.pseudo;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mission pour $displayName'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section 1: Tables Selection
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.grid_on, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Tables de multiplication',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Toutes les tables')),
                            selected: _isAllTables,
                            selectedColor: Colors.orange.shade200,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _isAllTables = true;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('Sélection personnalisée')),
                            selected: !_isAllTables,
                            selectedColor: Colors.orange.shade200,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _isAllTables = false;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: !_isAllTables
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Tables sélectionnées : ${_selectedTables.length}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        TextButton.icon(
                                          icon: const Icon(Icons.select_all, size: 18),
                                          label: const Text('Toutes'),
                                          onPressed: () {
                                            setState(() {
                                              _selectedTables.addAll(List.generate(9, (index) => index + 2));
                                            });
                                          },
                                        ),
                                        TextButton.icon(
                                          icon: const Icon(Icons.clear, size: 18),
                                          label: const Text('Aucune'),
                                          onPressed: () {
                                            setState(() {
                                              _selectedTables.clear();
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(9, (index) => index + 2).map((tableNumber) {
                                    final isSelected = _selectedTables.contains(tableNumber);
                                    return FilterChip(
                                      label: Text('Table de $tableNumber'),
                                      selected: isSelected,
                                      selectedColor: Colors.orange.shade200,
                                      checkmarkColor: Colors.orange.shade800,
                                      onSelected: (selected) {
                                        setState(() {
                                          if (selected) {
                                            _selectedTables.add(tableNumber);
                                          } else {
                                            _selectedTables.remove(tableNumber);
                                          }
                                        });
                                      },
                                    );
                                  }).toList(),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 2: Difficulty Selection
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.speed, color: Colors.orange.shade700),
                        const SizedBox(width: 8),
                        const Text(
                          'Difficulté de la course',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Slider(
                      value: _selectedDifficulty.toDouble(),
                      min: 1,
                      max: 3,
                      divisions: 2,
                      label: _selectedDifficulty == 1 
                          ? 'Facile (Découverte)' 
                          : _selectedDifficulty == 2 
                              ? 'Moyen (Intermédiaire)' 
                              : 'Difficile (Expert)',
                      activeColor: Colors.orange.shade700,
                      inactiveColor: Colors.orange.shade100,
                      onChanged: (double value) {
                        setState(() {
                          _selectedDifficulty = value.toInt();
                        });
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Facile',
                            style: TextStyle(
                              fontWeight: _selectedDifficulty == 1 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedDifficulty == 1 ? Colors.orange.shade800 : Colors.grey,
                            ),
                          ),
                          Text(
                            'Moyen',
                            style: TextStyle(
                              fontWeight: _selectedDifficulty == 2 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedDifficulty == 2 ? Colors.orange.shade800 : Colors.grey,
                            ),
                          ),
                          Text(
                            'Difficile',
                            style: TextStyle(
                              fontWeight: _selectedDifficulty == 3 ? FontWeight.bold : FontWeight.normal,
                              color: _selectedDifficulty == 3 ? Colors.orange.shade800 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Section 3: Custom Success Goals
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          Icon(Icons.stars, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Objectifs de réussite',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      subtitle: const Text('Définir des critères de validation personnalisés'),
                      value: _useCustomGoals,
                      activeColor: Colors.orange.shade700,
                      onChanged: (bool value) {
                        setState(() {
                          _useCustomGoals = value;
                        });
                      },
                    ),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: _useCustomGoals
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Divider(height: 24),
                                
                                // Max Errors Goal
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Erreurs maximales autorisées',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '$_maxErrors ${_maxErrors <= 1 ? "erreur" : "erreurs"}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _maxErrors.toDouble(),
                                  min: 0,
                                  max: 10,
                                  divisions: 10,
                                  activeColor: Colors.orange.shade600,
                                  inactiveColor: Colors.orange.shade100,
                                  onChanged: (double value) {
                                    setState(() {
                                      _maxErrors = value.toInt();
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Avg response time
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Temps de réponse moyen max.',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${_avgTime.toStringAsFixed(1)} s',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _avgTime,
                                  min: 1.0,
                                  max: 10.0,
                                  divisions: 18, // Steps of 0.5s: 1.0, 1.5, 2.0... 10.0 (18 divisions)
                                  activeColor: Colors.orange.shade600,
                                  inactiveColor: Colors.orange.shade100,
                                  onChanged: (double value) {
                                    setState(() {
                                      _avgTime = value;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Question response time
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Temps limite par question',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${_questionTime.toStringAsFixed(1)} s',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                                Slider(
                                  value: _questionTime,
                                  min: 1.0,
                                  max: 10.0,
                                  divisions: 18, // Steps of 0.5s: 1.0, 1.5, 2.0... 10.0
                                  activeColor: Colors.orange.shade600,
                                  inactiveColor: Colors.orange.shade100,
                                  onChanged: (double value) {
                                    setState(() {
                                      _questionTime = value;
                                    });
                                  },
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Envoyer la mission',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : _submitMission,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
