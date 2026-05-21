import '../repositories/class_repository.dart';

class UpdateClassStudentSortOrderUseCase {
  final ClassRepository repository;

  UpdateClassStudentSortOrderUseCase(this.repository);

  Future<void> execute({
    required String classId,
    required String studentId,
    required int sortOrder,
  }) async {
    await repository.updateClassStudentSortOrder(
      classId: classId,
      studentId: studentId,
      sortOrder: sortOrder,
    );
  }
}
