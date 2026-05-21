import '../repositories/class_repository.dart';

class AddStudentToClassUseCase {
  final ClassRepository repository;

  AddStudentToClassUseCase(this.repository);

  Future<void> execute(String classId, String studentId) {
    return repository.addStudentToClass(classId, studentId);
  }
}
