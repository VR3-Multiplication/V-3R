import '../repositories/class_repository.dart';

class RemoveStudentFromClassUseCase {
  final ClassRepository repository;

  RemoveStudentFromClassUseCase(this.repository);

  Future<void> execute(String classId, String studentId) {
    return repository.removeStudentFromClass(classId, studentId);
  }
}
