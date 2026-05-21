import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AffiliationRemoteDataSource {
  Future<void> affiliateChild({required String code});
  Future<bool> checkAffiliationCodeExists(String code);
  Future<List<Map<String, dynamic>>> getAffiliatedChildren();
  Future<void> revokeAffiliation({required String adultId, required String childId});
  Future<List<Map<String, dynamic>>> getChildAffiliates(String childId);
  Future<void> updateSortOrder({required String childId, required int sortOrder});
  Future<String> getStudentSortPreference();
  Future<void> updateStudentSortPreference(String preference);
}

class AffiliationRemoteDataSourceImpl implements AffiliationRemoteDataSource {
  final SupabaseClient supabaseClient;

  AffiliationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<void> affiliateChild({required String code}) async {
    // Appel de la fonction RPC (Remote Procedure Call) créée dans Supabase
    await supabaseClient.rpc(
      'link_child',
      params: {'affiliation_code': code},
    );
  }

  @override
  Future<bool> checkAffiliationCodeExists(String code) async {
    final response = await supabaseClient
        .from('profiles')
        .select('id')
        .eq('affiliation_code', code)
        .maybeSingle();
    return response != null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAffiliatedChildren() async {
    final response = await supabaseClient
        .from('affiliations')
        .select('is_super_admin, sort_order, profiles:child_id(id, pseudo, role, full_name)')
        .eq('adult_id', supabaseClient.auth.currentUser!.id)
        .order('sort_order', ascending: true);

    // On retourne à la fois le profil de l'enfant, le statut super_admin et l'ordre
    return (response as List<dynamic>).map((row) {
      final profile = row['profiles'] as Map<String, dynamic>;
      return {
        'profile': profile,
        'is_super_admin': row['is_super_admin'] ?? false,
        'sort_order': row['sort_order'] ?? 0,
      };
    }).toList();
  }

  @override
  Future<void> revokeAffiliation({required String adultId, required String childId}) async {
    await supabaseClient.rpc(
      'revoke_affiliation',
      params: {
        'p_adult_id': adultId,
        'p_child_id': childId,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getChildAffiliates(String childId) async {
    final response = await supabaseClient.rpc(
      'get_child_affiliates',
      params: {'p_child_id': childId},
    );
    return (response as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
  }

  @override
  Future<void> updateSortOrder({required String childId, required int sortOrder}) async {
    await supabaseClient
        .from('affiliations')
        .update({'sort_order': sortOrder})
        .eq('adult_id', supabaseClient.auth.currentUser!.id)
        .eq('child_id', childId);
  }

  @override
  Future<String> getStudentSortPreference() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return 'custom';
    final response = await supabaseClient
        .from('profiles')
        .select('student_sort_preference')
        .eq('id', user.id)
        .maybeSingle();
    return response?['student_sort_preference'] as String? ?? 'custom';
  }

  @override
  Future<void> updateStudentSortPreference(String preference) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;
    await supabaseClient
        .from('profiles')
        .update({'student_sort_preference': preference})
        .eq('id', user.id);
  }
}
