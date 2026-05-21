class TableStatistic {
  final int table;
  final int totalAttempts;
  final int correctAnswers;

  TableStatistic({
    required this.table,
    required this.totalAttempts,
    required this.correctAnswers,
  });

  double get successRate => totalAttempts == 0 ? 0 : (correctAnswers / totalAttempts) * 100;
}

class DailyStatistic {
  final DateTime date;
  final int correctAnswers;

  DailyStatistic({
    required this.date,
    required this.correctAnswers,
  });
}

class ChildStatistics {
  final List<TableStatistic> tableStats;
  final List<DailyStatistic> dailyProgress;
  final DateTime? lastActiveAt;

  ChildStatistics({
    required this.tableStats,
    required this.dailyProgress,
    this.lastActiveAt,
  });
}

