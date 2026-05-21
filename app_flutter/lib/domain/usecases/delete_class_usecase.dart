import '../repositories/class_repository.dart';

class DeleteClassUseCase {
  final ClassRepository repository;

  DeleteClassUseCase(this.repository);

  Future<void> execute(String classId) {
    return repository.deleteClass(classId);
  }
}
