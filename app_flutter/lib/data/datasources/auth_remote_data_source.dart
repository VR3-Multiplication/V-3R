import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> loginAdult({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpAdult({
    required String email,
    required String password,
    required String role,
    String? pseudo,
  });

  Future<void> logout();
  Future<void> simulatePayment();
  Future<void> createUserProfile({
    required String id,
    required String role,
    required String pseudo,
    String? affiliationCode,
  });
  Future<void> updateProfileAffiliationCode({
    required String userId,
    required String code,
  });
  String? get currentUserId;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient supabaseClient;

  AuthRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AuthResponse> loginAdult({
    required String email,
    required String password,
  }) async {
    return await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpAdult({
    required String email,
    required String password,
    required String role,
    String? pseudo,
  }) async {
    return await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'role': role,
        'pseudo': pseudo,
      },
    );
  }

  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }

  @override
  Future<void> simulatePayment() async {
    await supabaseClient.rpc('simulate_payment');
  }

  @override
  Future<void> createUserProfile({
    required String id,
    required String role,
    required String pseudo,
    String? affiliationCode,
  }) async {
    await supabaseClient.from('profiles').insert({
      'id': id,
      'role': role,
      'pseudo': pseudo,
      if (affiliationCode != null) 'affiliation_code': affiliationCode,
      'stars': 0,
    });
  }

  @override
  Future<void> updateProfileAffiliationCode({
    required String userId,
    required String code,
  }) async {
    await supabaseClient
        .from('profiles')
        .update({'affiliation_code': code})
        .eq('id', userId);
  }

  @override
  String? get currentUserId => supabaseClient.auth.currentUser?.id;
}
