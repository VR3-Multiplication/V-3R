import 'package:supabase_flutter/supabase_flutter.dart';

abstract class StatementRemoteDataSource {
  Future<List<Map<String, dynamic>>> getStatementsForChild(String childId);
  Future<void> saveStatement({
    required String childId,
    required int operand1,
    required int operand2,
    required bool success,
  });
}

class StatementRemoteDataSourceImpl implements StatementRemoteDataSource {
  final SupabaseClient supabaseClient;

  StatementRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getStatementsForChild(String childId) async {
    final response = await supabaseClient
        .from('statements')
        .select()
        .eq('child_id', childId)
        .order('created_at', ascending: true);
    return response;
  }

  @override
  Future<void> saveStatement({
    required String childId,
    required int operand1,
    required int operand2,
    required bool success,
  }) async {
    await supabaseClient.from('statements').insert({
      'child_id': childId,
      'operand1': operand1,
      'operand2': operand2,
      'success': success,
    });
  }
}
