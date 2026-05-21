class Mission {
  final String id;
  final String assignedBy; // ID de l'adulte (Parent/Prof)
  final String assignedTo; // ID de l'enfant
  final String operationType; // ex: 'addition', 'multiplication'
  final int difficulty; // ex: 1 (Facile), 2 (Moyen), 3 (Difficile)
  final bool isCompleted;
  final DateTime createdAt;
  final int? score;
  final String status; // 'pending', 'completed', 'abandoned'

  Mission({
    required this.id,
    required this.assignedBy,
    required this.assignedTo,
    required this.operationType,
    required this.difficulty,
    this.isCompleted = false,
    required this.createdAt,
    this.score,
    this.status = 'pending',
  });

  Mission copyWith({
    String? id,
    String? assignedBy,
    String? assignedTo,
    String? operationType,
    int? difficulty,
    bool? isCompleted,
    DateTime? createdAt,
    int? score,
    String? status,
  }) {
    return Mission(
      id: id ?? this.id,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedTo: assignedTo ?? this.assignedTo,
      operationType: operationType ?? this.operationType,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      score: score ?? this.score,
      status: status ?? this.status,
    );
  }
}

extension MissionParser on Mission {
  List<int> get tables {
    final baseType = operationType.split('?')[0];
    if (!baseType.startsWith('table_')) {
      return [2, 3, 4, 5, 6, 7, 8, 9];
    }
    final tablesPart = baseType.split('_')[1];
    if (tablesPart == 'all') {
      return [2, 3, 4, 5, 6, 7, 8, 9];
    }
    return tablesPart
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .where((e) => e != null)
        .cast<int>()
        .toList();
  }

  int? get maxErrors {
    if (!operationType.contains('?')) return null;
    final queryString = operationType.split('?')[1];
    final params = Uri.splitQueryString(queryString);
    final val = params['max_errors'];
    return val != null ? int.tryParse(val) : null;
  }

  double? get avgTimeLimit {
    if (!operationType.contains('?')) return null;
    final queryString = operationType.split('?')[1];
    final params = Uri.splitQueryString(queryString);
    final val = params['avg_time'];
    return val != null ? double.tryParse(val) : null;
  }

  double? get questionTimeLimit {
    if (!operationType.contains('?')) return null;
    final queryString = operationType.split('?')[1];
    final params = Uri.splitQueryString(queryString);
    final val = params['question_time'];
    return val != null ? double.tryParse(val) : null;
  }

  bool get hasCustomGoals => maxErrors != null || avgTimeLimit != null || questionTimeLimit != null;
}
