import 'package:supabase_flutter/supabase_flutter.dart';

abstract class ClassRemoteDataSource {
  Future<List<Map<String, dynamic>>> getClasses();
  Future<Map<String, dynamic>> createClass(String name);
  Future<void> deleteClass(String classId);
  Future<List<Map<String, dynamic>>> getClassStudents(String classId);
  Future<void> addStudentToClass(String classId, String studentId);
  Future<void> removeStudentFromClass(String classId, String studentId);
  Future<void> updateClassStudentSortOrder({required String classId, required String studentId, required int sortOrder});
  Future<void> updateClassSortPreference({required String classId, required String preference});
}

class ClassRemoteDataSourceImpl implements ClassRemoteDataSource {
  final SupabaseClient supabaseClient;

  ClassRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getClasses() async {
    final response = await supabaseClient
        .from('classes')
        .select('*')
        .eq('teacher_id', supabaseClient.auth.currentUser!.id)
        .order('name');
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<Map<String, dynamic>> createClass(String name) async {
    final response = await supabaseClient
        .from('classes')
        .insert({
          'teacher_id': supabaseClient.auth.currentUser!.id,
          'name': name,
        })
        .select()
        .single();
    return response;
  }

  @override
  Future<void> deleteClass(String classId) async {
    await supabaseClient.from('classes').delete().eq('id', classId);
  }

  @override
  Future<List<Map<String, dynamic>>> getClassStudents(String classId) async {
    final response = await supabaseClient
        .from('class_students')
        .select('sort_order, profiles:student_id(id, role, pseudo, full_name, affiliation_code)')
        .eq('class_id', classId)
        .order('sort_order', ascending: true);
    
    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Future<void> addStudentToClass(String classId, String studentId) async {
    // Calculer le sort_order max
    final existing = await getClassStudents(classId);
    final nextOrder = existing.length;

    await supabaseClient.from('class_students').insert({
      'class_id': classId,
      'student_id': studentId,
      'sort_order': nextOrder,
    });
  }

  @override
  Future<void> removeStudentFromClass(String classId, String studentId) async {
    await supabaseClient
        .from('class_students')
        .delete()
        .eq('class_id', classId)
        .eq('student_id', studentId);
  }

  @override
  Future<void> updateClassStudentSortOrder({
    required String classId,
    required String studentId,
    required int sortOrder,
  }) async {
    await supabaseClient
        .from('class_students')
        .update({'sort_order': sortOrder})
        .eq('class_id', classId)
        .eq('student_id', studentId);
  }

  @override
  Future<void> updateClassSortPreference({
    required String classId,
    required String preference,
  }) async {
    await supabaseClient
        .from('classes')
        .update({'student_sort_preference': preference})
        .eq('id', classId);
  }
}
