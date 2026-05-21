import '../repositories/class_repository.dart';

class UpdateClassSortPreferenceUseCase {
  final ClassRepository repository;

  UpdateClassSortPreferenceUseCase(this.repository);

  Future<void> execute({
    required String classId,
    required String preference,
  }) async {
    await repository.updateClassSortPreference(
      classId: classId,
      preference: preference,
    );
  }
}
