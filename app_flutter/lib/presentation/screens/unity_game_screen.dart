import 'package:flutter/material.dart';
import 'package:flutter_embed_unity/flutter_embed_unity.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mission.dart';
import '../providers/mission_providers.dart';
import '../providers/statistic_providers.dart';
import '../providers/auth_providers.dart';
import '../providers/shop_providers.dart';
import '../providers/session_tracker.dart';

class UnityGameScreen extends ConsumerStatefulWidget {
  final Mission? mission;

  const UnityGameScreen({super.key, this.mission});

  @override
  ConsumerState<UnityGameScreen> createState() => _UnityGameScreenState();
}

class _UnityGameScreenState extends ConsumerState<UnityGameScreen> {
  // État pour la sélection
  final Set<int> _selectedTables = {2, 5}; // Par défaut tables de 2 et 5
  String _selectedMode = 'Expert'; // Par défaut mode Expert
  bool _gameStarted = false; // Pour cacher l'interface après le lancement
  bool _isPaused = false; // Pour gérer l'état de pause
  bool _unityReady = false; // Pour savoir si Unity est prêt
  int _highScore = 0; // Pour stocker le meilleur score

  // Suivi des objectifs
  int _questionsAnswered = 0;
  int _errorCount = 0;
  final List<double> _responseTimes = [];
  DateTime? _lastQuestionStartTime;
  bool _missionFinished = false;
  bool _dialogShowing = false;

  int get _totalQuestionsOfMission {
    if (widget.mission == null) return 0;
    final tables = widget.mission!.tables;
    return (tables.length * 10).clamp(10, 20);
  }

  @override
  void initState() {
    super.initState();
    SessionTracker.updateActivity();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('high_score') ?? 0;
    });
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('high_score', score);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Le jeu Unity en fond
            EmbedUnity(
              onMessageFromUnity: _onUnityMessage,
            ),
            
            // HUD en temps réel (uniquement en mission et si le jeu est lancé et non en pause)
            if (_gameStarted && widget.mission != null && !_isPaused)
              Positioned(
                top: 40,
                left: 20,
                child: _buildHUD(),
              ),

            // 1. Bouton Pause (visible seulement si le jeu est lancé et non en pause)
            if (_gameStarted && !_isPaused)
              Positioned(
                top: 40, // Descendu un peu plus pour éviter les encoches
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      debugPrint('FLUTTER_DEBUG: Clic sur Pause');
                      // On envoie l'ordre de pause à Unity
                      sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Pause');
                      setState(() {
                        _isPaused = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.pause, color: Colors.white, size: 30),
                    ),
                  ),
                ),
              ),
            
            // 2. Menu de Pause (visible seulement si on est en pause)
            if (_isPaused)
              Container(
                color: Colors.black.withValues(alpha: 0.7), // Fond sombre
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Jeu en Pause',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          
                          // Bouton Reprendre
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              minimumSize: const Size(200, 50),
                            ),
                            onPressed: () {
                              // On envoie l'ordre de reprise à Unity
                              sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Resume');
                              setState(() {
                                _isPaused = false;
                              });
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Reprendre', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(height: 15),
                          
                          // Bouton Changer les tables (Retour menu) ou Abandonner la mission
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              minimumSize: const Size(200, 50),
                            ),
                            onPressed: () {
                              if (widget.mission != null) {
                                // Abandonner la mission : on remet le temps normal et on quitte
                                sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Resume');
                                Navigator.of(context).pop();
                              } else {
                                setState(() {
                                  _gameStarted = false;
                                  _isPaused = false;
                                });
                              }
                            },
                            icon: Icon(widget.mission != null ? Icons.assignment_return : Icons.settings),
                            label: Text(
                              widget.mission != null ? 'Abandonner la mission' : 'Changer les tables',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          // Bouton Quitter le jeu
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              minimumSize: const Size(200, 50),
                            ),
                            onPressed: () {
                              // On assure la reprise du temps à 1 si l'utilisateur quitte
                              sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Resume');
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.exit_to_app),
                            label: const Text('Quitter le jeu', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            
            // 3. Interface de sélection (affichée seulement si le jeu n'est pas lancé, et qu'il n'y a pas de mission forcée)
            if (!_gameStarted && widget.mission == null)
              Container(
                color: Colors.black.withValues(alpha: 0.7), // Fond sombre
                child: Center(
                  child: Card(
                    margin: const EdgeInsets.all(20),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Configuration de la partie',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Meilleur score : $_highScore ⭐',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange),
                          ),
                          const SizedBox(height: 20),
                          
                          // Choix du mode
                          const Text('Choisissez le mode :'),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: ['Discovery', 'Intermediate', 'Expert'].map((mode) {
                              return ChoiceChip(
                                label: Text(mode == 'Discovery' ? 'Découverte' : mode == 'Intermediate' ? 'Intermédiaire' : 'Expert'),
                                selected: _selectedMode == mode,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedMode = mode;
                                    });
                                  }
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),
                          
                          // Choix des tables
                          const Text('Choisissez les tables à travailler :'),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: List.generate(10, (index) {
                              final table = index + 1;
                              final isSelected = _selectedTables.contains(table);
                              return FilterChip(
                                label: Text('x$table'),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedTables.add(table);
                                    } else {
                                      // On garde au moins une table sélectionnée
                                      if (_selectedTables.length > 1) {
                                        _selectedTables.remove(table);
                                      }
                                    }
                                  });
                                },
                              );
                            }),
                          ),
                          const SizedBox(height: 30),
                          
                          // Bouton de lancement
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _unityReady ? Colors.green : Colors.grey,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            ),
                            onPressed: _unityReady ? () {
                              // On prépare le message (ex: "Expert|2,5")
                              final tablesStr = _selectedTables.toList().join(',');
                              final message = '$_selectedMode|$tablesStr';
                              
                              debugPrint('FLUTTER_DEBUG: Envoi à Unity: $message');
                              
                              // On envoie à Unity (et on remet le temps à 1 au cas où)
                              sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Resume');
                              sendToUnity('FlutterManager', 'OnMessageFromFlutter', message);
                              
                              // On cache l'interface
                              setState(() {
                                _questionsAnswered = 0;
                                _errorCount = 0;
                                _responseTimes.clear();
                                _lastQuestionStartTime = DateTime.now();
                                _missionFinished = false;
                                _dialogShowing = false;
                                _gameStarted = true;
                              });
                            } : null, // Désactivé si Unity n'est pas prêt
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!_unityReady)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                if (!_unityReady) const SizedBox(width: 10),
                                Text(
                                  _unityReady ? 'Lancer la course !' : 'Chargement de Unity...',
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            // Briefing de mission (affiché si le jeu n'est pas lancé et qu'il y a une mission forcée)
            if (!_gameStarted && widget.mission != null)
              _buildMissionBriefing(),
          ],
        ),
      ),
    );
  }

  // Callback appelé quand Unity envoie un message à Flutter
  void _onUnityMessage(String message) {
    debugPrint('UNITY_DEBUG: Message de Unity: $message');
    if (message == 'Ready') {
      setState(() {
        _unityReady = true;
      });
    } else if (message.startsWith('AnsweredStatement')) {
      _handleAnsweredStatement(message);
    } else if (message.startsWith('GameOver')) {
      ref.read(statementRepositoryProvider).syncPendingStatements().catchError((e) {
        debugPrint('FLUTTER_DEBUG: Erreur de synchro en arrière-plan après GameOver: $e');
      });
      final parts = message.split('|');
      final score = parts.length > 1 ? parts[1] : '0';
      _showGameOverDialog(score);
    }
  }

  void _handleAnsweredStatement(String message) {
    final parts = message.split('|');
    if (parts.length < 4) return;

    final op1 = int.tryParse(parts[1]) ?? 0;
    final op2 = int.tryParse(parts[2]) ?? 0;
    final success = parts[3].toLowerCase() == 'true';

    double duration = 0.0;
    if (parts.length >= 5) {
      duration = double.tryParse(parts[4]) ?? 0.0;
    } else {
      if (_lastQuestionStartTime != null) {
        duration = DateTime.now().difference(_lastQuestionStartTime!).inMilliseconds / 1000.0;
      }
    }

    // Suivi des performances pour les objectifs
    setState(() {
      _questionsAnswered++;
      if (!success) {
        _errorCount++;
      }
      _responseTimes.add(duration);
      _lastQuestionStartTime = DateTime.now();
    });

    // Check early failure / success if we are in mission
    if (widget.mission != null) {
      final maxErrors = widget.mission!.maxErrors ?? 3;
      if (_errorCount > maxErrors) {
        _finishMission(success: false);
      } else if (_questionsAnswered >= _totalQuestionsOfMission) {
        _finishMission(success: true);
      }
    }

    // On récupère l'ID de l'enfant (soit via l'auth, soit via les paramètres si c'est un test)
    final childId = ref.read(supabaseClientProvider).auth.currentUser?.id;

    if (childId != null) {
      ref.read(statementRepositoryProvider).saveStatement(
        childId: childId,
        operand1: op1,
        operand2: op2,
        success: success,
      );
      debugPrint('FLUTTER_DEBUG: Calcul enregistré localement: $op1 x $op2 = ${op1 * op2} ($success) en ${duration.toStringAsFixed(2)}s');
    }
  }

  void _startMission() {
    // Réinitialisation des statistiques de la session
    setState(() {
      _questionsAnswered = 0;
      _errorCount = 0;
      _responseTimes.clear();
      _lastQuestionStartTime = DateTime.now();
      _missionFinished = false;
      _dialogShowing = false;
      _gameStarted = true;
    });

    // 1. Récupérer la voiture équipée
    ref.read(childInventoryProvider).whenData((inventory) {
      final equipped = inventory.firstWhere((item) => item.isEquipped, orElse: () => inventory.first);
      // On cherche l'item complet pour avoir l'unity_id
      ref.read(shopItemsProvider).whenData((items) {
        final shopItem = items.firstWhere((i) => i.id == equipped.itemId);
        sendToUnity('FlutterManager', 'ChangeCar', shopItem.unityId);
      });
    });

    String modeStr = 'Expert';
    if (widget.mission!.difficulty == 1) {
      modeStr = 'Discovery';
    } else if (widget.mission!.difficulty == 2) {
      modeStr = 'Intermediate';
    }

    String tablesStr = '2,3,4,5,6,7,8,9';
    if (widget.mission!.operationType.startsWith('table_')) {
      tablesStr = widget.mission!.tables.join(',');
    }
    
    final message = '$modeStr|$tablesStr';
    debugPrint('FLUTTER_DEBUG: Lancement mission: $message');
    
    sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Resume');
    sendToUnity('FlutterManager', 'OnMessageFromFlutter', message);
  }

  void _finishMission({required bool success}) {
    if (_missionFinished) return;
    setState(() {
      _missionFinished = true;
    });

    // Send Stop to Unity
    sendToUnity('FlutterManager', 'OnMessageFromFlutter', 'Stop');

    // Force sync
    ref.read(statementRepositoryProvider).syncPendingStatements().catchError((e) {
      debugPrint('FLUTTER_DEBUG: Erreur de synchro en arrière-plan post-mission: $e');
    });

    final correctAnswers = _questionsAnswered - _errorCount;
    final score = (correctAnswers * 10).clamp(0, 999999);

    _showGameOverDialog(score.toString());
  }

  // Fonction pour afficher la pop-up de Game Over avec le score
  void _showGameOverDialog(String scoreStr) {
    if (_dialogShowing) return;
    setState(() {
      _dialogShowing = true;
      _missionFinished = true;
    });

    final score = int.tryParse(scoreStr) ?? 0;
    bool isNewRecord = false;
    
    if (score > _highScore) {
      _highScore = score;
      _saveHighScore(score);
      isNewRecord = true;
    }

    bool missionSucceeded = true;
    final List<String> failedCriteria = [];

    if (widget.mission != null) {
      final mission = widget.mission!;
      final maxErrors = mission.maxErrors;
      final avgTimeLimit = mission.avgTimeLimit;
      final questionTimeLimit = mission.questionTimeLimit;

      if (_questionsAnswered < _totalQuestionsOfMission) {
        missionSucceeded = false;
        failedCriteria.add("Calculs résolus : $_questionsAnswered / $_totalQuestionsOfMission");
      }

      if (maxErrors != null && _errorCount > maxErrors) {
        missionSucceeded = false;
        failedCriteria.add("Erreurs : $_errorCount / $maxErrors max");
      }

      final avgTime = _responseTimes.isEmpty
          ? 0.0
          : _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
      if (avgTimeLimit != null && avgTime > avgTimeLimit) {
        missionSucceeded = false;
        failedCriteria.add("Temps moyen : ${avgTime.toStringAsFixed(1)}s / ${avgTimeLimit.toStringAsFixed(1)}s max");
      }

      if (questionTimeLimit != null) {
        final hasExceededLimit = _responseTimes.any((t) => t > questionTimeLimit);
        if (hasExceededLimit) {
          missionSucceeded = false;
          final maxSingleTime = _responseTimes.isEmpty ? 0.0 : _responseTimes.reduce((a, b) => a > b ? a : b);
          failedCriteria.add("Temps max question : ${maxSingleTime.toStringAsFixed(1)}s / ${questionTimeLimit.toStringAsFixed(1)}s max");
        }
      }

      if (missionSucceeded) {
        ref.read(markMissionAsCompletedUseCaseProvider).execute(missionId: widget.mission!.id, score: score).then((_) {
          debugPrint('FLUTTER_DEBUG: Mission ${widget.mission!.id} marquée comme terminée avec score : $score.');
        }).catchError((e) {
          debugPrint('FLUTTER_DEBUG: Erreur lors de la validation de la mission: $e');
        });
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false, // L'utilisateur doit cliquer sur un bouton
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isNewRecord 
                ? '🎉 Record Battu ! 🎉' 
                : (widget.mission != null && !missionSucceeded ? '⚠️ Mission non validée ⚠️' : 'Game Over !'), 
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: isNewRecord 
                  ? Colors.green 
                  : (widget.mission != null && !missionSucceeded ? Colors.orange : Colors.red)
            )
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isNewRecord
                  ? 'Félicitations !\n\nVotre nouveau score record est de : $score 🏆'
                  : 'Dommage, la course est terminée !\n\nVotre score final est de : $score 🏆\nMeilleur score : $_highScore ⭐'
              ),
              if (widget.mission != null) ...[
                const SizedBox(height: 15),
                if (missionSucceeded)
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 10),
                      Text('Mission validée !', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                  )
                else ...[
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cancel, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Objectifs non atteints :', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...failedCriteria.map((c) => Text(c, style: const TextStyle(fontWeight: FontWeight.w500))),
                  const SizedBox(height: 10),
                  const Text('Tu peux réessayer quand tu veux !', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Retour au menu', style: TextStyle(fontSize: 16)),
              onPressed: () {
                setState(() {
                  _dialogShowing = false;
                });
                Navigator.of(context).pop(); // Ferme le dialogue
                
                // Si on était en mission, on quitte l'écran de jeu pour revenir au dashboard
                if (widget.mission != null) {
                  Navigator.of(context).pop(); 
                } else {
                  setState(() {
                    _gameStarted = false; // Revient au menu de configuration libre
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissionBriefing() {
    final mission = widget.mission!;
    final tables = mission.tables;
    final maxErrors = mission.maxErrors;
    final avgTimeLimit = mission.avgTimeLimit;
    
    String difficultyLabel = "Découverte";
    Color difficultyColor = Colors.green;
    if (mission.difficulty == 2) {
      difficultyLabel = "Intermédiaire";
      difficultyColor = Colors.orange;
    } else if (mission.difficulty == 3) {
      difficultyLabel = "Expert";
      difficultyColor = Colors.red;
    }

    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: difficultyColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.directions_car_filled_rounded,
                    color: difficultyColor,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Briefing de Mission 🚀',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: difficultyColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    difficultyLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                const Text(
                  'Tables visées :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: tables.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1.5),
                    ),
                    child: Text(
                      'Table de $t',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 24),
                
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Objectifs à atteindre :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildObjectiveItem(
                  icon: Icons.track_changes_rounded,
                  color: Colors.blue,
                  title: 'Résoudre correctement :',
                  value: '$_totalQuestionsOfMission calculs',
                ),
                if (maxErrors != null)
                  _buildObjectiveItem(
                    icon: Icons.error_outline_rounded,
                    color: Colors.red,
                    title: 'Erreurs autorisées :',
                    value: 'maximum $maxErrors',
                  ),
                if (avgTimeLimit != null)
                  _buildObjectiveItem(
                    icon: Icons.timer_outlined,
                    color: Colors.orange,
                    title: 'Temps moyen max :',
                    value: '${avgTimeLimit.toStringAsFixed(1)}s par calcul',
                  ),
                
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Retour',
                          style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _unityReady ? Colors.green : Colors.grey.shade400,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _unityReady ? _startMission : null,
                        child: _unityReady
                            ? const Text(
                                'Lancer la mission ! 🚀',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Chargement...',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildObjectiveItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    final mission = widget.mission!;
    final maxErrors = mission.maxErrors;
    final avgTimeLimit = mission.avgTimeLimit;
    
    final avgTime = _responseTimes.isEmpty
        ? 0.0
        : _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
        
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHUDLine(
            icon: Icons.track_changes_rounded,
            color: Colors.blue.shade300,
            text: 'Calculs : $_questionsAnswered / $_totalQuestionsOfMission',
            isSuccess: _questionsAnswered >= _totalQuestionsOfMission,
          ),
          const SizedBox(height: 8),
          
          _buildHUDLine(
            icon: Icons.error_outline_rounded,
            color: _errorCount > (maxErrors ?? 3) ? Colors.red.shade300 : Colors.orange.shade300,
            text: 'Erreurs : $_errorCount / ${maxErrors ?? 3}',
            isFailure: maxErrors != null && _errorCount > maxErrors,
          ),
          
          if (avgTimeLimit != null) ...[
            const SizedBox(height: 8),
            _buildHUDLine(
              icon: Icons.timer_outlined,
              color: avgTime > avgTimeLimit ? Colors.red.shade300 : Colors.green.shade300,
              text: 'Temps moyen : ${avgTime.toStringAsFixed(1)}s / ${avgTimeLimit.toStringAsFixed(1)}s',
              isFailure: avgTime > avgTimeLimit,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHUDLine({
    required IconData icon,
    required Color color,
    required String text,
    bool isSuccess = false,
    bool isFailure = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        if (isSuccess) ...[
          const SizedBox(width: 6),
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16),
        ],
        if (isFailure) ...[
          const SizedBox(width: 6),
          const Icon(Icons.cancel_rounded, color: Colors.red, size: 16),
        ],
      ],
    );
  }
}
