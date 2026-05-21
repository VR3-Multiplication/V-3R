import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/statistic_providers.dart';
import '../providers/class_providers.dart';
import '../../domain/entities/class_statistics.dart';
import '../../domain/entities/child_statistics.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/school_class.dart';
import 'child_statistics_screen.dart';

class ClassStatisticsScreen extends ConsumerWidget {
  final String classId;

  const ClassStatisticsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classesAsync = ref.watch(teacherClassesProvider);
    final statsAsync = ref.watch(classStatisticsProvider(classId));

    // Trouver le nom de la classe
    final String className = classesAsync.maybeWhen(
      data: (list) {
        final c = list.firstWhere(
          (element) => element.id == classId,
          orElse: () => SchoolClass(
            id: classId,
            teacherId: '',
            name: 'Classe',
            createdAt: DateTime.now(),
          ),
        );
        return c.name;
      },
      orElse: () => 'Classe',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Slate 50 background for clean aesthetic
      appBar: AppBar(
        title: Text(
          'Statistiques : $className',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Rafraîchir',
            onPressed: () {
              ref.invalidate(classStatisticsProvider(classId));
            },
          ),
        ],
      ),
      body: statsAsync.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.indigo),
              SizedBox(height: 16),
              Text(
                'Calcul des statistiques en cours...',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.red, size: 60),
                const SizedBox(height: 16),
                Text(
                  'Une erreur est survenue lors du chargement des statistiques.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade800, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(classStatisticsProvider(classId)),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (classStats) {
          if (classStats.studentsStats.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 80, color: Colors.indigo.shade200),
                    const SizedBox(height: 16),
                    const Text(
                      'Aucun élève dans cette classe',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ajoutez des élèves à cette classe depuis la gestion des élèves pour commencer à collecter des statistiques.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Résumé global (KPIs)
                _buildKPIs(context, classStats),
                const SizedBox(height: 24),

                // 2. Heatmap de Maîtrise des Tables
                _buildHeatmapCard(context, classStats),
                const SizedBox(height: 24),

                // 3. Alertes Pédagogiques & Classement des Tables (côte à côte si large, sinon vertical)
                LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth > 800) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: _buildAlertsCard(context, classStats),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2,
                            child: _buildTableDifficultyCard(context, classStats),
                          ),
                        ],
                      );
                    } else {
                      return Column(
                        children: [
                          _buildAlertsCard(context, classStats),
                          const SizedBox(height: 24),
                          _buildTableDifficultyCard(context, classStats),
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widgets Composants ---

  Widget _buildKPIs(BuildContext context, ClassStatistics stats) {
    final totalStudents = stats.studentsStats.length;
    final activeStudents = stats.activeStudentsCount;

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 1;
        final double childAspectRatio = constraints.maxWidth > 600 ? 1.5 : 3.0;

        return GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          children: [
            _buildKPICard(
              title: 'Taux de Réussite Moyen',
              value: '${stats.globalSuccessRate.toStringAsFixed(1)}%',
              icon: Icons.auto_awesome_rounded,
              color: Colors.green,
              gradientColors: [Colors.green.shade600, Colors.teal.shade500],
            ),
            _buildKPICard(
              title: 'Élèves Actifs',
              value: '$activeStudents / $totalStudents',
              icon: Icons.people_rounded,
              color: Colors.indigo,
              gradientColors: [Colors.indigo.shade600, Colors.blue.shade500],
            ),
            _buildKPICard(
              title: 'Calculs Répondus',
              value: stats.totalCalculations.toString(),
              icon: Icons.calculate_rounded,
              color: Colors.purple,
              gradientColors: [Colors.purple.shade600, Colors.pink.shade500],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required List<Color> gradientColors,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 100,
              color: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapCard(BuildContext context, ClassStatistics stats) {
    // Les colonnes correspondent aux tables de 2 à 10
    final tables = List.generate(9, (index) => index + 2); // 2 à 10

    return Card(
      elevation: 2,
      shadowColor: const Color(0x1F000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grille de Maîtrise (Heatmap)',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cliquez sur une cellule pour voir les détails de l\'élève.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                // Légende
                Wrap(
                  spacing: 8,
                  children: [
                    _buildLegendItem('≥90%', const Color(0xFF15803D)),
                    _buildLegendItem('80-89%', const Color(0xFF22C55E)),
                    _buildLegendItem('50-79%', const Color(0xFFEAB308)),
                    _buildLegendItem('<50%', const Color(0xFFEF4444)),
                    _buildLegendItem('Nouveau', const Color(0xFFCBD5E1)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Table de heatmap scrollable horizontalement pour s'adapter à toutes les résolutions
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 14,
                horizontalMargin: 8,
                headingRowColor: WidgetStateProperty.all(Colors.indigo.shade50),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                columns: [
                  const DataColumn(
                    label: Text(
                      'Élève',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                    ),
                  ),
                  ...tables.map(
                    (t) => DataColumn(
                      numeric: true,
                      label: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Text(
                          '×$t',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                      ),
                    ),
                  ),
                ],
                rows: stats.studentsStats.map((sStats) {
                  final studentName = sStats.student.fullName?.trim().isNotEmpty == true
                      ? sStats.student.fullName!
                      : sStats.student.pseudo;

                  return DataRow(
                    cells: [
                      // Colonne Nom
                      DataCell(
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChildStatisticsScreen(child: sStats.student),
                              ),
                            );
                          },
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: Colors.indigo.shade100,
                                foregroundColor: Colors.indigo.shade800,
                                child: Text(
                                  studentName[0].toUpperCase(),
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                studentName,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Colonnes des tables 2 à 10
                      ...tables.map((t) {
                        // Trouver la statistique pour cette table
                        final stat = sStats.stats.tableStats.firstWhere(
                          (element) => element.table == t,
                          orElse: () => TableStatistic(table: t, totalAttempts: 0, correctAnswers: 0),
                        );

                        Color cellColor;
                        Color textColor = Colors.white;
                        String label = '-';

                        if (stat.totalAttempts == 0) {
                          cellColor = const Color(0xFFE2E8F0); // Slate 200
                          textColor = Colors.grey.shade700;
                        } else {
                          final rate = stat.successRate;
                          label = '${rate.toStringAsFixed(0)}%';
                          if (rate >= 90.0) {
                            cellColor = const Color(0xFF15803D); // Emerald 700
                          } else if (rate >= 80.0) {
                            cellColor = const Color(0xFF22C55E); // Emerald 500
                          } else if (rate >= 50.0) {
                            cellColor = const Color(0xFFEAB308); // Yellow 500
                            textColor = Colors.black87;
                          } else {
                            cellColor = const Color(0xFFEF4444); // Red 500
                          }
                        }

                        return DataCell(
                          GestureDetector(
                            onTap: () => _showCellDetails(context, sStats.student, stat),
                            child: Container(
                              alignment: Alignment.center,
                              width: 44,
                              height: 36,
                              decoration: BoxDecoration(
                                color: cellColor,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600)),
      ],
    );
  }

  void _showCellDetails(BuildContext context, UserProfile student, TableStatistic stat) {
    final studentName = student.fullName?.trim().isNotEmpty == true ? student.fullName! : student.pseudo;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade100,
                    foregroundColor: Colors.indigo.shade800,
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Pseudo : ${student.pseudo}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              Text(
                'Détail : Table de ${stat.table}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailMetric('Réussites', '${stat.correctAnswers} / ${stat.totalAttempts}'),
                  _buildDetailMetric('Taux de succès', stat.totalAttempts > 0 ? '${stat.successRate.toStringAsFixed(1)}%' : 'N/A'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.bar_chart_rounded),
                  label: const Text('Voir toutes ses statistiques'),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChildStatisticsScreen(child: student),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildAlertsCard(BuildContext context, ClassStatistics stats) {
    final alerts = stats.pedagogicalAlerts;

    return Card(
      elevation: 2,
      shadowColor: const Color(0x1F000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notification_important_rounded, color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text(
                  'Alertes Pédagogiques',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (alerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: Colors.green.shade700, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Aucune alerte pour le moment. Félicitations à toute la classe !',
                        style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: alerts.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final alert = alerts[index];
                  final isLowPerf = alert.type == AlertType.lowPerformance;
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isLowPerf ? Colors.red.shade50 : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isLowPerf ? Colors.red.shade100 : Colors.amber.shade200,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          isLowPerf ? Icons.warning_amber_rounded : Icons.timer_off_outlined,
                          color: isLowPerf ? Colors.red.shade700 : Colors.amber.shade800,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert.message,
                                style: TextStyle(
                                  color: isLowPerf ? Colors.red.shade900 : Colors.amber.shade900,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChildStatisticsScreen(child: alert.student),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Voir le profil →',
                                  style: TextStyle(
                                    color: isLowPerf ? Colors.red.shade800 : Colors.amber.shade900,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableDifficultyCard(BuildContext context, ClassStatistics stats) {
    final ranking = stats.tableDifficultyRanking;

    return Card(
      elevation: 2,
      shadowColor: const Color(0x1F000000),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.align_horizontal_left_rounded, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Tables les plus Difficiles',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Triées du plus bas taux de réussite au plus élevé.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (ranking.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text(
                    'Aucune donnée de calcul disponible.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: ranking.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final entry = ranking[index];
                  final tableNum = entry.key;
                  final successRate = entry.value;

                  Color progressColor;
                  if (successRate >= 90.0) {
                    progressColor = const Color(0xFF15803D);
                  } else if (successRate >= 80.0) {
                    progressColor = const Color(0xFF22C55E);
                  } else if (successRate >= 50.0) {
                    progressColor = const Color(0xFFEAB308);
                  } else {
                    progressColor = const Color(0xFFEF4444);
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Table de $tableNum',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            '${successRate.toStringAsFixed(1)}% réussite',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: progressColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: successRate / 100,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
