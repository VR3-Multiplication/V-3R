import '../entities/class_statistics.dart';
import '../repositories/class_repository.dart';
import '../repositories/statement_repository.dart';

class GetClassStatisticsUseCase {
  final ClassRepository classRepository;
  final StatementRepository statementRepository;

  GetClassStatisticsUseCase({
    required this.classRepository,
    required this.statementRepository,
  });

  Future<ClassStatistics> execute(String classId) async {
    // 1. Récupérer les élèves de la classe
    final students = await classRepository.getClassStudents(classId);

    // 2. Récupérer en parallèle les statistiques de chaque élève
    final List<ClassStudentStats> studentsStats = await Future.wait(
      students.map((student) async {
        final stats = await statementRepository.getStatisticsForChild(student.id);
        return ClassStudentStats(
          student: student,
          stats: stats,
        );
      }),
    );

    return ClassStatistics(
      classId: classId,
      studentsStats: studentsStats,
    );
  }
}
