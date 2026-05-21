import 'child_statistics.dart';
import 'user_profile.dart';

class ClassStudentStats {
  final UserProfile student;
  final ChildStatistics stats;

  ClassStudentStats({
    required this.student,
    required this.stats,
  });
}

class PedagogicalAlert {
  final UserProfile student;
  final String message;
  final AlertType type;
  final int? table;
  final double? value;

  PedagogicalAlert({
    required this.student,
    required this.message,
    required this.type,
    this.table,
    this.value,
  });
}

enum AlertType {
  lowPerformance,
  inactivity,
}

class ClassStatistics {
  final String classId;
  final List<ClassStudentStats> studentsStats;

  ClassStatistics({
    required this.classId,
    required this.studentsStats,
  });

  /// Calcule le taux de réussite global de la classe
  double get globalSuccessRate {
    int totalAttempts = 0;
    int correctAnswers = 0;
    for (var s in studentsStats) {
      for (var t in s.stats.tableStats) {
        totalAttempts += t.totalAttempts;
        correctAnswers += t.correctAnswers;
      }
    }
    return totalAttempts == 0 ? 0.0 : (correctAnswers / totalAttempts) * 100;
  }

  /// Retourne le nombre total de calculs répondus par la classe
  int get totalCalculations {
    int total = 0;
    for (var s in studentsStats) {
      for (var t in s.stats.tableStats) {
        total += t.totalAttempts;
      }
    }
    return total;
  }

  /// Retourne le nombre d'élèves actifs (qui ont fait au moins 1 tentative)
  int get activeStudentsCount {
    int count = 0;
    for (var s in studentsStats) {
      final total = s.stats.tableStats.fold<int>(0, (sum, t) => sum + t.totalAttempts);
      if (total > 0) {
        count++;
      }
    }
    return count;
  }

  /// Génère les alertes pédagogiques pour la classe
  List<PedagogicalAlert> get pedagogicalAlerts {
    final List<PedagogicalAlert> alerts = [];
    final now = DateTime.now();

    for (var s in studentsStats) {
      final studentName = s.student.fullName?.trim().isNotEmpty == true
          ? s.student.fullName!
          : s.student.pseudo;

      // 1. Alerte de réussite faible (< 50% sur une table avec au moins 4 tentatives)
      for (var t in s.stats.tableStats) {
        if (t.totalAttempts >= 4 && t.successRate < 50.0) {
          alerts.add(PedagogicalAlert(
            student: s.student,
            message: '$studentName a des difficultés sur la table de ${t.table} (${t.successRate.toStringAsFixed(0)}% de réussite sur ${t.totalAttempts} essais).',
            type: AlertType.lowPerformance,
            table: t.table,
            value: t.successRate,
          ));
        }
      }

      // 2. Alerte d'inactivité (inactif depuis plus de 7 jours, s'il a déjà fait au moins un calcul)
      // On vérifie s'il a déjà joué
      final hasPlayed = s.stats.tableStats.any((t) => t.totalAttempts > 0);
      if (hasPlayed && s.stats.lastActiveAt != null) {
        final daysInactive = now.difference(s.stats.lastActiveAt!).inDays;
        if (daysInactive >= 7) {
          alerts.add(PedagogicalAlert(
            student: s.student,
            message: '$studentName n\'a pas joué depuis $daysInactive jours.',
            type: AlertType.inactivity,
            value: daysInactive.toDouble(),
          ));
        }
      }
    }

    return alerts;
  }

  /// Calcule le taux de réussite par table de multiplication (de 2 à 10) à l'échelle de la classe
  /// Retourne une liste triée de la table la plus difficile à la plus facile
  List<MapEntry<int, double>> get tableDifficultyRanking {
    final Map<int, List<bool>> classTableAttempts = {};
    for (int i = 2; i <= 10; i++) {
      classTableAttempts[i] = [];
    }

    for (var s in studentsStats) {
      for (var t in s.stats.tableStats) {
        if (t.table >= 2 && t.table <= 10) {
          // On ajoute autant de réussites et d'échecs que ce que l'élève a produit
          final correct = t.correctAnswers;
          final total = t.totalAttempts;
          for (int j = 0; j < correct; j++) {
            classTableAttempts[t.table]!.add(true);
          }
          for (int j = 0; j < (total - correct); j++) {
            classTableAttempts[t.table]!.add(false);
          }
        }
      }
    }

    final List<MapEntry<int, double>> rankings = [];
    classTableAttempts.forEach((table, attempts) {
      if (attempts.isNotEmpty) {
        final correct = attempts.where((a) => a).length;
        final rate = (correct / attempts.length) * 100;
        rankings.add(MapEntry(table, rate));
      }
    });

    // Trier de la plus difficile (taux de réussite le plus bas) à la plus facile
    rankings.sort((a, b) => a.value.compareTo(b.value));
    return rankings;
  }
}
