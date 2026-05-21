import '../entities/school_class.dart';
import '../repositories/class_repository.dart';

class GetClassesUseCase {
  final ClassRepository repository;

  GetClassesUseCase(this.repository);

  Future<List<SchoolClass>> execute() {
    return repository.getClasses();
  }
}
