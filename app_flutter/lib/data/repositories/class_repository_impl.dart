import '../../domain/entities/school_class.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/class_repository.dart';
import '../datasources/class_remote_data_source.dart';

class ClassRepositoryImpl implements ClassRepository {
  final ClassRemoteDataSource remoteDataSource;

  ClassRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SchoolClass>> getClasses() async {
    final list = await remoteDataSource.getClasses();
    return list.map((json) => SchoolClass.fromJson(json)).toList();
  }

  @override
  Future<SchoolClass> createClass(String name) async {
    final json = await remoteDataSource.createClass(name);
    return SchoolClass.fromJson(json);
  }

  @override
  Future<void> deleteClass(String classId) async {
    await remoteDataSource.deleteClass(classId);
  }

  @override
  Future<List<UserProfile>> getClassStudents(String classId) async {
    final list = await remoteDataSource.getClassStudents(classId);
    return list.map((json) {
      final profileJson = json['profiles'] as Map<String, dynamic>;
      final roleStr = profileJson['role'] as String;
      final role = UserRole.values.firstWhere((e) => e.name == roleStr, orElse: () => UserRole.child);
      return UserProfile(
        id: profileJson['id'] as String,
        role: role,
        email: null,
        pseudo: profileJson['pseudo'] as String,
        fullName: profileJson['full_name'] as String?,
        affiliationCode: profileJson['affiliation_code'] as String?,
        sortOrder: json['sort_order'] as int? ?? 0,
      );
    }).toList();
  }

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {
    await remoteDataSource.addStudentToClass(classId, studentId);
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    await remoteDataSource.removeStudentFromClass(classId, studentId);
  }

  @override
  Future<void> updateClassStudentSortOrder({
    required String classId,
    required String studentId,
    required int sortOrder,
  }) async {
    await remoteDataSource.updateClassStudentSortOrder(
      classId: classId,
      studentId: studentId,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<void> updateClassSortPreference({
    required String classId,
    required String preference,
  }) async {
    await remoteDataSource.updateClassSortPreference(
      classId: classId,
      preference: preference,
    );
  }
}
