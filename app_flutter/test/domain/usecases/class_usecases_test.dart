import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/entities/school_class.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/repositories/class_repository.dart';
import 'package:app_flutter/domain/usecases/get_classes_usecase.dart';
import 'package:app_flutter/domain/usecases/create_class_usecase.dart';
import 'package:app_flutter/domain/usecases/delete_class_usecase.dart';
import 'package:app_flutter/domain/usecases/get_class_students_usecase.dart';
import 'package:app_flutter/domain/usecases/add_student_to_class_usecase.dart';
import 'package:app_flutter/domain/usecases/remove_student_from_class_usecase.dart';

class MockClassRepository implements ClassRepository {
  final List<SchoolClass> classes = [];
  final Map<String, List<String>> classStudents = {};

  @override
  Future<List<SchoolClass>> getClasses() async {
    return List.of(classes);
  }

  @override
  Future<SchoolClass> createClass(String name) async {
    final newClass = SchoolClass(
      id: 'class-${classes.length + 1}',
      teacherId: 'teacher-1',
      name: name,
      createdAt: DateTime(2026, 5, 20),
    );
    classes.add(newClass);
    return newClass;
  }

  @override
  Future<void> deleteClass(String classId) async {
    classes.removeWhere((c) => c.id == classId);
  }

  @override
  Future<List<UserProfile>> getClassStudents(String classId) async {
    final studentIds = classStudents[classId] ?? [];
    return studentIds.map((id) => UserProfile(id: id, role: UserRole.child, pseudo: 'Student-$id')).toList();
  }

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {
    classStudents.putIfAbsent(classId, () => []).add(studentId);
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    classStudents[classId]?.remove(studentId);
  }

  @override
  Future<void> updateClassStudentSortOrder({
    required String classId,
    required String studentId,
    required int sortOrder,
  }) async {
    // Mock basique pour les tests
  }

  @override
  Future<void> updateClassSortPreference({
    required String classId,
    required String preference,
  }) async {
    // Mock basique pour les tests
  }
}

void main() {
  late MockClassRepository mockRepository;

  setUp(() {
    mockRepository = MockClassRepository();
  });

  group('Class Use Cases', () {
    test('GetClassesUseCase doit retourner les classes', () async {
      mockRepository.classes.add(SchoolClass(id: 'c1', teacherId: 'teacher-1', name: 'CM1', createdAt: DateTime(2026, 5, 20)));
      final useCase = GetClassesUseCase(mockRepository);
      final result = await useCase.execute();
      expect(result.length, 1);
      expect(result.first.name, 'CM1');
    });

    test('CreateClassUseCase doit ajouter une classe si le nom est valide', () async {
      final useCase = CreateClassUseCase(mockRepository);
      final newClass = await useCase.execute('CM2');
      expect(newClass.name, 'CM2');
      expect(mockRepository.classes.length, 1);
    });

    test('CreateClassUseCase doit lever une exception si le nom est vide', () async {
      final useCase = CreateClassUseCase(mockRepository);
      expect(() => useCase.execute('  '), throwsA(isA<Exception>()));
    });

    test('DeleteClassUseCase doit supprimer la classe', () async {
      mockRepository.classes.add(SchoolClass(id: 'c1', teacherId: 'teacher-1', name: 'CM1', createdAt: DateTime(2026, 5, 20)));
      final useCase = DeleteClassUseCase(mockRepository);
      await useCase.execute('c1');
      expect(mockRepository.classes.isEmpty, true);
    });

    test('GetClassStudentsUseCase doit retourner les eleves de la classe', () async {
      mockRepository.classStudents['c1'] = ['student-1', 'student-2'];
      final useCase = GetClassStudentsUseCase(mockRepository);
      final students = await useCase.execute('c1');
      expect(students.length, 2);
      expect(students.first.id, 'student-1');
    });

    test('AddStudentToClassUseCase doit ajouter un eleve', () async {
      final useCase = AddStudentToClassUseCase(mockRepository);
      await useCase.execute('c1', 'student-9');
      expect(mockRepository.classStudents['c1']?.contains('student-9'), true);
    });

    test('RemoveStudentFromClassUseCase doit enlever un eleve', () async {
      mockRepository.classStudents['c1'] = ['student-9'];
      final useCase = RemoveStudentFromClassUseCase(mockRepository);
      await useCase.execute('c1', 'student-9');
      expect(mockRepository.classStudents['c1']?.contains('student-9'), false);
    });
  });
}
