import '../../domain/entities/school_class.dart';
import '../../domain/entities/user_profile.dart';

abstract class ClassRepository {
  Future<List<SchoolClass>> getClasses();
  Future<SchoolClass> createClass(String name);
  Future<void> deleteClass(String classId);
  Future<List<UserProfile>> getClassStudents(String classId);
  Future<void> addStudentToClass(String classId, String studentId);
  Future<void> removeStudentFromClass(String classId, String studentId);
  Future<void> updateClassStudentSortOrder({required String classId, required String studentId, required int sortOrder});
  Future<void> updateClassSortPreference({required String classId, required String preference});
}
