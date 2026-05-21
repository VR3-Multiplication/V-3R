import '../entities/user_profile.dart';
import '../repositories/class_repository.dart';

class GetClassStudentsUseCase {
  final ClassRepository repository;

  GetClassStudentsUseCase(this.repository);

  Future<List<UserProfile>> execute(String classId) {
    return repository.getClassStudents(classId);
  }
}
