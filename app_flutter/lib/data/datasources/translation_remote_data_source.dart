import 'package:supabase_flutter/supabase_flutter.dart';

abstract class TranslationRemoteDataSource {
  Future<List<Map<String, dynamic>>> getAllTranslations();
}

class TranslationRemoteDataSourceImpl implements TranslationRemoteDataSource {
  final SupabaseClient supabaseClient;

  TranslationRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<Map<String, dynamic>>> getAllTranslations() async {
    final response = await supabaseClient
        .from('translations')
        .select('key, language_code, value');
    
    return (response as List<dynamic>).map((e) => e as Map<String, dynamic>).toList();
  }
}
