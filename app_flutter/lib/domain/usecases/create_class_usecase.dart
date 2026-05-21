import '../entities/school_class.dart';
import '../repositories/class_repository.dart';

class CreateClassUseCase {
  final ClassRepository repository;

  CreateClassUseCase(this.repository);

  Future<SchoolClass> execute(String name) {
    if (name.trim().isEmpty) {
      throw Exception('Le nom de la classe ne peut pas être vide.');
    }
    return repository.createClass(name);
  }
}
