import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/class_repository.dart';
import '../../data/repositories/class_repository_impl.dart';
import '../../data/datasources/class_remote_data_source.dart';
import '../../domain/usecases/get_classes_usecase.dart';
import '../../domain/usecases/create_class_usecase.dart';
import '../../domain/usecases/delete_class_usecase.dart';
import '../../domain/usecases/get_class_students_usecase.dart';
import '../../domain/usecases/add_student_to_class_usecase.dart';
import '../../domain/usecases/remove_student_from_class_usecase.dart';
import '../../domain/usecases/update_class_student_sort_order_usecase.dart';
import '../../domain/usecases/update_class_sort_preference_usecase.dart';
import 'auth_providers.dart';

final classRemoteDataSourceProvider = Provider<ClassRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ClassRemoteDataSourceImpl(supabaseClient: client);
});

final classRepositoryProvider = Provider<ClassRepository>((ref) {
  final dataSource = ref.watch(classRemoteDataSourceProvider);
  return ClassRepositoryImpl(remoteDataSource: dataSource);
});

// Use Case Providers
final getClassesUseCaseProvider = Provider<GetClassesUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return GetClassesUseCase(repo);
});

final createClassUseCaseProvider = Provider<CreateClassUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return CreateClassUseCase(repo);
});

final deleteClassUseCaseProvider = Provider<DeleteClassUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return DeleteClassUseCase(repo);
});

final getClassStudentsUseCaseProvider = Provider<GetClassStudentsUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return GetClassStudentsUseCase(repo);
});

final addStudentToClassUseCaseProvider = Provider<AddStudentToClassUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return AddStudentToClassUseCase(repo);
});

final removeStudentFromClassUseCaseProvider = Provider<RemoveStudentFromClassUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return RemoveStudentFromClassUseCase(repo);
});

final updateClassStudentSortOrderUseCaseProvider = Provider<UpdateClassStudentSortOrderUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return UpdateClassStudentSortOrderUseCase(repo);
});

final updateClassSortPreferenceUseCaseProvider = Provider<UpdateClassSortPreferenceUseCase>((ref) {
  final repo = ref.watch(classRepositoryProvider);
  return UpdateClassSortPreferenceUseCase(repo);
});

class TeacherClassesNotifier extends StateNotifier<AsyncValue<List<SchoolClass>>> {
  final GetClassesUseCase _getClassesUseCase;
  final CreateClassUseCase _createClassUseCase;
  final DeleteClassUseCase _deleteClassUseCase;
  final UpdateClassSortPreferenceUseCase _updateClassSortPreferenceUseCase;

  TeacherClassesNotifier({
    required GetClassesUseCase getClassesUseCase,
    required CreateClassUseCase createClassUseCase,
    required DeleteClassUseCase deleteClassUseCase,
    required UpdateClassSortPreferenceUseCase updateClassSortPreferenceUseCase,
  })  : _getClassesUseCase = getClassesUseCase,
        _createClassUseCase = createClassUseCase,
        _deleteClassUseCase = deleteClassUseCase,
        _updateClassSortPreferenceUseCase = updateClassSortPreferenceUseCase,
        super(const AsyncValue.loading()) {
    loadClasses();
  }

  Future<void> loadClasses() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getClassesUseCase.execute();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createClass(String name) async {
    try {
      final newClass = await _createClassUseCase.execute(name);
      state.whenData((list) {
        state = AsyncValue.data([...list, newClass]);
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await _deleteClassUseCase.execute(id);
      state.whenData((list) {
        state = AsyncValue.data(list.where((c) => c.id != id).toList());
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateClassSortPreference(String classId, String preference) async {
    try {
      await _updateClassSortPreferenceUseCase.execute(classId: classId, preference: preference);
      state.whenData((list) {
        state = AsyncValue.data(
          list.map((c) {
            if (c.id == classId) {
              return SchoolClass(
                id: c.id,
                teacherId: c.teacherId,
                name: c.name,
                createdAt: c.createdAt,
                studentSortPreference: preference,
              );
            }
            return c;
          }).toList(),
        );
      });
    } catch (e) {
      rethrow;
    }
  }
}

final teacherClassesProvider = StateNotifierProvider.autoDispose<TeacherClassesNotifier, AsyncValue<List<SchoolClass>>>((ref) {
  return TeacherClassesNotifier(
    getClassesUseCase: ref.watch(getClassesUseCaseProvider),
    createClassUseCase: ref.watch(createClassUseCaseProvider),
    deleteClassUseCase: ref.watch(deleteClassUseCaseProvider),
    updateClassSortPreferenceUseCase: ref.watch(updateClassSortPreferenceUseCaseProvider),
  );
});

final classSortPreferenceProvider = Provider.family.autoDispose<String, String>((ref, classId) {
  final classesAsync = ref.watch(teacherClassesProvider);
  return classesAsync.maybeWhen(
    data: (list) {
      final c = list.firstWhere(
        (element) => element.id == classId,
        orElse: () => SchoolClass(
          id: classId,
          teacherId: '',
          name: '',
          createdAt: DateTime.now(),
        ),
      );
      return c.studentSortPreference;
    },
    orElse: () => 'custom',
  );
});

class ClassStudentsNotifier extends StateNotifier<AsyncValue<List<UserProfile>>> {
  final GetClassStudentsUseCase _getClassStudentsUseCase;
  final AddStudentToClassUseCase _addStudentToClassUseCase;
  final RemoveStudentFromClassUseCase _removeStudentFromClassUseCase;
  final String _classId;

  ClassStudentsNotifier({
    required GetClassStudentsUseCase getClassStudentsUseCase,
    required AddStudentToClassUseCase addStudentToClassUseCase,
    required RemoveStudentFromClassUseCase removeStudentFromClassUseCase,
    required String classId,
  })  : _getClassStudentsUseCase = getClassStudentsUseCase,
        _addStudentToClassUseCase = addStudentToClassUseCase,
        _removeStudentFromClassUseCase = removeStudentFromClassUseCase,
        _classId = classId,
        super(const AsyncValue.loading()) {
    loadStudents();
  }

  Future<void> loadStudents() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getClassStudentsUseCase.execute(_classId);
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addStudent(UserProfile student) async {
    try {
      await _addStudentToClassUseCase.execute(_classId, student.id);
      state.whenData((list) {
        if (!list.any((s) => s.id == student.id)) {
          state = AsyncValue.data([...list, student]);
        }
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeStudent(String studentId) async {
    try {
      await _removeStudentFromClassUseCase.execute(_classId, studentId);
      state.whenData((list) {
        state = AsyncValue.data(list.where((s) => s.id != studentId).toList());
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateStudentsOrder(List<UserProfile> reorderedList, UpdateClassStudentSortOrderUseCase useCase) async {
    state = AsyncValue.data(reorderedList);
    try {
      await Future.wait(
        reorderedList.asMap().entries.map((entry) {
          return useCase.execute(
            classId: _classId,
            studentId: entry.value.id,
            sortOrder: entry.key,
          );
        }),
      );
    } catch (e) {
      loadStudents();
      rethrow;
    }
  }
}

final classStudentsProvider = StateNotifierProvider.family.autoDispose<ClassStudentsNotifier, AsyncValue<List<UserProfile>>, String>((ref, classId) {
  return ClassStudentsNotifier(
    getClassStudentsUseCase: ref.watch(getClassStudentsUseCaseProvider),
    addStudentToClassUseCase: ref.watch(addStudentToClassUseCaseProvider),
    removeStudentFromClassUseCase: ref.watch(removeStudentFromClassUseCaseProvider),
    classId: classId,
  );
});
