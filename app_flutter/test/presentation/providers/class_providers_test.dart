import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_flutter/domain/entities/school_class.dart';
import 'package:app_flutter/domain/entities/user_profile.dart';
import 'package:app_flutter/domain/repositories/class_repository.dart';
import 'package:app_flutter/domain/usecases/get_classes_usecase.dart';
import 'package:app_flutter/domain/usecases/create_class_usecase.dart';
import 'package:app_flutter/domain/usecases/delete_class_usecase.dart';
import 'package:app_flutter/domain/usecases/get_class_students_usecase.dart';
import 'package:app_flutter/domain/usecases/add_student_to_class_usecase.dart';
import 'package:app_flutter/domain/usecases/remove_student_from_class_usecase.dart';
import 'package:app_flutter/presentation/providers/class_providers.dart';

import 'package:app_flutter/domain/usecases/update_class_sort_preference_usecase.dart';
import 'package:app_flutter/domain/usecases/update_class_student_sort_order_usecase.dart';

class MockClassRepository implements ClassRepository {
  final List<SchoolClass> classes = [
    SchoolClass(id: 'c1', teacherId: 't1', name: 'CM1', createdAt: DateTime(2026, 5, 20)),
  ];
  final Map<String, List<UserProfile>> students = {
    'c1': [
      UserProfile(id: 's1', role: UserRole.child, pseudo: 'Alice'),
    ]
  };

  @override
  Future<List<SchoolClass>> getClasses() async => List.of(classes);

  @override
  Future<SchoolClass> createClass(String name) async {
    final c = SchoolClass(id: 'c2', teacherId: 't1', name: name, createdAt: DateTime(2026, 5, 20));
    classes.add(c);
    return c;
  }

  @override
  Future<void> deleteClass(String classId) async {
    classes.removeWhere((c) => c.id == classId);
  }

  @override
  Future<List<UserProfile>> getClassStudents(String classId) async {
    return List.of(students[classId] ?? []);
  }

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {
    final s = UserProfile(id: studentId, role: UserRole.child, pseudo: 'NewStudent');
    students.putIfAbsent(classId, () => []).add(s);
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    students[classId]?.removeWhere((s) => s.id == studentId);
  }

  @override
  Future<void> updateClassStudentSortOrder({
    required String classId,
    required String studentId,
    required int sortOrder,
  }) async {
    final list = students[classId];
    if (list != null) {
      final index = list.indexWhere((s) => s.id == studentId);
      if (index != -1) {
        list[index] = list[index].copyWith(sortOrder: sortOrder);
      }
    }
  }

  @override
  Future<void> updateClassSortPreference({
    required String classId,
    required String preference,
  }) async {
    final index = classes.indexWhere((c) => c.id == classId);
    if (index != -1) {
      final c = classes[index];
      classes[index] = SchoolClass(
        id: c.id,
        teacherId: c.teacherId,
        name: c.name,
        createdAt: c.createdAt,
        studentSortPreference: preference,
      );
    }
  }
}

void main() {
  late MockClassRepository mockRepository;
  late GetClassesUseCase getClassesUseCase;
  late CreateClassUseCase createClassUseCase;
  late DeleteClassUseCase deleteClassUseCase;
  late UpdateClassSortPreferenceUseCase updateClassSortPreferenceUseCase;
  late GetClassStudentsUseCase getClassStudentsUseCase;
  late AddStudentToClassUseCase addStudentToClassUseCase;
  late RemoveStudentFromClassUseCase removeStudentFromClassUseCase;

  setUp(() {
    mockRepository = MockClassRepository();
    getClassesUseCase = GetClassesUseCase(mockRepository);
    createClassUseCase = CreateClassUseCase(mockRepository);
    deleteClassUseCase = DeleteClassUseCase(mockRepository);
    updateClassSortPreferenceUseCase = UpdateClassSortPreferenceUseCase(mockRepository);
    getClassStudentsUseCase = GetClassStudentsUseCase(mockRepository);
    addStudentToClassUseCase = AddStudentToClassUseCase(mockRepository);
    removeStudentFromClassUseCase = RemoveStudentFromClassUseCase(mockRepository);
  });

  group('TeacherClassesNotifier', () {
    test('doit charger les classes au demarrage', () async {
      final notifier = TeacherClassesNotifier(
        getClassesUseCase: getClassesUseCase,
        createClassUseCase: createClassUseCase,
        deleteClassUseCase: deleteClassUseCase,
        updateClassSortPreferenceUseCase: updateClassSortPreferenceUseCase,
      );

      await Future.delayed(Duration.zero);
      expect(notifier.state.value?.length, 1);
      expect(notifier.state.value?.first.name, 'CM1');
    });

    test('doit creer une classe', () async {
      final notifier = TeacherClassesNotifier(
        getClassesUseCase: getClassesUseCase,
        createClassUseCase: createClassUseCase,
        deleteClassUseCase: deleteClassUseCase,
        updateClassSortPreferenceUseCase: updateClassSortPreferenceUseCase,
      );

      await Future.delayed(Duration.zero);
      await notifier.createClass('CM2');
      expect(notifier.state.value?.length, 2);
      expect(notifier.state.value?.last.name, 'CM2');
    });

    test('doit supprimer une classe', () async {
      final notifier = TeacherClassesNotifier(
        getClassesUseCase: getClassesUseCase,
        createClassUseCase: createClassUseCase,
        deleteClassUseCase: deleteClassUseCase,
        updateClassSortPreferenceUseCase: updateClassSortPreferenceUseCase,
      );

      await Future.delayed(Duration.zero);
      await notifier.deleteClass('c1');
      expect(notifier.state.value?.isEmpty, true);
    });

    test('doit mettre a jour la preference de tri', () async {
      final notifier = TeacherClassesNotifier(
        getClassesUseCase: getClassesUseCase,
        createClassUseCase: createClassUseCase,
        deleteClassUseCase: deleteClassUseCase,
        updateClassSortPreferenceUseCase: updateClassSortPreferenceUseCase,
      );

      await Future.delayed(Duration.zero);
      await notifier.updateClassSortPreference('c1', 'alpha_asc');
      expect(notifier.state.value?.firstWhere((c) => c.id == 'c1').studentSortPreference, 'alpha_asc');
    });
  });

  group('ClassStudentsNotifier', () {
    test('doit charger les eleves au demarrage', () async {
      final notifier = ClassStudentsNotifier(
        getClassStudentsUseCase: getClassStudentsUseCase,
        addStudentToClassUseCase: addStudentToClassUseCase,
        removeStudentFromClassUseCase: removeStudentFromClassUseCase,
        classId: 'c1',
      );

      await Future.delayed(Duration.zero);
      expect(notifier.state.value?.length, 1);
      expect(notifier.state.value?.first.pseudo, 'Alice');
    });

    test('doit ajouter un eleve', () async {
      final notifier = ClassStudentsNotifier(
        getClassStudentsUseCase: getClassStudentsUseCase,
        addStudentToClassUseCase: addStudentToClassUseCase,
        removeStudentFromClassUseCase: removeStudentFromClassUseCase,
        classId: 'c1',
      );

      await Future.delayed(Duration.zero);
      final student = UserProfile(id: 's2', role: UserRole.child, pseudo: 'Bob');
      await notifier.addStudent(student);
      expect(notifier.state.value?.length, 2);
      expect(notifier.state.value?.any((s) => s.id == 's2'), true);
    });

    test('doit supprimer un eleve', () async {
      final notifier = ClassStudentsNotifier(
        getClassStudentsUseCase: getClassStudentsUseCase,
        addStudentToClassUseCase: addStudentToClassUseCase,
        removeStudentFromClassUseCase: removeStudentFromClassUseCase,
        classId: 'c1',
      );

      await Future.delayed(Duration.zero);
      await notifier.removeStudent('s1');
      expect(notifier.state.value?.isEmpty, true);
    });

    test('doit mettre a jour l\'ordre des eleves', () async {
      final notifier = ClassStudentsNotifier(
        getClassStudentsUseCase: getClassStudentsUseCase,
        addStudentToClassUseCase: addStudentToClassUseCase,
        removeStudentFromClassUseCase: removeStudentFromClassUseCase,
        classId: 'c1',
      );

      await Future.delayed(Duration.zero);
      final student = UserProfile(id: 's1', role: UserRole.child, pseudo: 'Alice', sortOrder: 5);
      final updateUseCase = UpdateClassStudentSortOrderUseCase(mockRepository);
      await notifier.updateStudentsOrder([student], updateUseCase);
      expect(notifier.state.value?.first.sortOrder, 5);
    });
  });
}
