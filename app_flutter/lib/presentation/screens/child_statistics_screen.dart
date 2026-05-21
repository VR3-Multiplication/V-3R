import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/statistic_providers.dart';
import '../providers/mission_providers.dart';
import '../providers/auth_providers.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/child_statistics.dart';
import '../../domain/entities/mission.dart';

class ChildStatisticsScreen extends ConsumerWidget {
  final UserProfile child;

  const ChildStatisticsScreen({super.key, required this.child});

  String _getOperationLabel(String opType) {
    if (opType == 'addition') return 'Additions';
    if (opType == 'subtraction') return 'Soustractions';
    if (opType == 'multiplication') return 'Multiplications';
    if (opType == 'division') return 'Divisions';
    if (opType.startsWith('table_')) {
      return 'Table de ${opType.split('_')[1]}';
    }
    return opType;
  }

  String _getDifficultyLabel(int diff) {
    if (diff == 1) return 'Découverte (Facile)';
    if (diff == 2) return 'Intermédiaire (Moyen)';
    return 'Expert (Difficile)';
  }

  void _confirmAbandon(BuildContext context, WidgetRef ref, Mission mission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abandonner la mission ?'),
        content: const Text('L\'enfant ne verra plus cette mission sur son tableau de bord.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ref.read(missionRepositoryProvider).abandonMission(mission.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Mission abandonnée avec succès.')),
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Abandonner'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(childStatisticsProvider(child.id));
    final adultId = ref.watch(currentUserProfileProvider).value?.id;
    final missionsAsync = adultId != null
        ? ref.watch(missionsAssignedByAdultProvider(adultId))
        : const AsyncValue<List<Mission>>.loading();

    final currentUser = ref.watch(supabaseClientProvider).auth.currentUser;
    final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';
    final childName = (child.fullName != null && child.fullName!.trim().isNotEmpty)
        ? (isTeacher ? child.fullName! : child.fullName!.trim().split(' ').first)
        : child.pseudo;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text((child.fullName != null && child.fullName!.trim().isNotEmpty) ? 'Suivi de $childName (${child.pseudo})' : 'Suivi de $childName'),
          backgroundColor: Colors.indigo.shade700,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.bar_chart), text: 'Statistiques'),
              Tab(icon: Icon(Icons.assignment), text: 'Missions données'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Statistiques
            statsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur: $err')),
              data: (stats) => SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryHeader(stats),
                    const SizedBox(height: 30),
                    const Text(
                      'Maîtrise des Tables',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildSuccessRateChart(stats.tableStats),
                    const SizedBox(height: 40),
                    const Text(
                      'Progression (Réponses correctes)',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildDailyProgressChart(stats.dailyProgress),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            // Tab 2: Missions
            missionsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Erreur lors du chargement des missions : $err')),
              data: (missions) {
                final childMissions = missions.where((m) => m.assignedTo == child.id).toList();
                return _buildMissionsTab(context, ref, childMissions);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionsTab(BuildContext context, WidgetRef ref, List<Mission> missions) {
    final currentUser = ref.read(supabaseClientProvider).auth.currentUser;
    final isTeacher = currentUser?.userMetadata?['role'] == 'teacher';
    final childName = (child.fullName != null && child.fullName!.trim().isNotEmpty)
        ? (isTeacher ? child.fullName! : child.fullName!.trim().split(' ').first)
        : child.pseudo;

    if (missions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_turned_in_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucune mission donnée à $childName pour le moment.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final total = missions.length;
    final completed = missions.where((m) => m.status == 'completed').length;
    final pending = missions.where((m) => m.status == 'pending').length;
    final abandoned = missions.where((m) => m.status == 'abandoned').length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Résumé des missions
          Row(
            children: [
              _buildMiniSummaryCard('Total', total.toString(), Colors.blue),
              const SizedBox(width: 8),
              _buildMiniSummaryCard('Faites', completed.toString(), Colors.green),
              const SizedBox(width: 8),
              _buildMiniSummaryCard('En cours', pending.toString(), Colors.orange),
              const SizedBox(width: 8),
              _buildMiniSummaryCard('Abandonnées', abandoned.toString(), Colors.grey),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Historique des missions',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: missions.length,
            itemBuilder: (context, index) {
              final mission = missions[index];
              return _buildMissionCard(context, ref, mission);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMiniSummaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionCard(BuildContext context, WidgetRef ref, Mission mission) {
    final dateStr = '${mission.createdAt.day.toString().padLeft(2, '0')}/${mission.createdAt.month.toString().padLeft(2, '0')}/${mission.createdAt.year}';
    
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (mission.status == 'completed') {
      statusColor = Colors.green;
      statusText = mission.score != null ? 'Fait (Score: ${mission.score} 🏆)' : 'Fait';
      statusIcon = Icons.check_circle_rounded;
    } else if (mission.status == 'abandoned') {
      statusColor = Colors.grey;
      statusText = 'Abandonné';
      statusIcon = Icons.cancel_rounded;
    } else {
      statusColor = Colors.blue;
      statusText = 'En cours';
      statusIcon = Icons.hourglass_empty_rounded;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getOperationLabel(mission.operationType),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Difficulté : ${_getDifficultyLabel(mission.difficulty)}',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                Text(
                  'Donnée le $dateStr',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                ),
              ],
            ),
            if (mission.status == 'pending') ...[
              const SizedBox(height: 12),
              const Divider(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _confirmAbandon(context, ref, mission),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Abandonner', style: TextStyle(fontSize: 13)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader(ChildStatistics stats) {
    final totalAttempts = stats.tableStats.fold<int>(0, (sum, item) => sum + item.totalAttempts);
    final totalCorrect = stats.tableStats.fold<int>(0, (sum, item) => sum + item.correctAnswers);
    final avgRate = totalAttempts == 0 ? 0 : (totalCorrect / totalAttempts) * 100;

    return Row(
      children: [
        _buildStatCard('Calculs faits', totalAttempts.toString(), Colors.blue),
        const SizedBox(width: 10),
        _buildStatCard('Réussite', '${avgRate.toStringAsFixed(1)}%', Colors.green),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessRateChart(List<TableStatistic> tableStats) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 100,
          barTouchData: BarTouchData(enabled: true),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('T${value.toInt()}'),
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text('${value.toInt()}%'),
                reservedSize: 40,
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: tableStats.map((s) {
            return BarChartGroupData(
              x: s.table,
              barRods: [
                BarChartRodData(
                  toY: s.successRate,
                  color: s.successRate > 80 ? Colors.green : s.successRate > 50 ? Colors.orange : Colors.red,
                  width: 15,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDailyProgressChart(List<DailyStatistic> dailyProgress) {
    if (dailyProgress.isEmpty) {
      return const Center(child: Text('Pas encore assez de données.'));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: true),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: dailyProgress.asMap().entries.map((e) {
                return FlSpot(e.key.toDouble(), e.value.correctAnswers.toDouble());
              }).toList(),
              isCurved: true,
              color: Colors.indigo,
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.indigo.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
