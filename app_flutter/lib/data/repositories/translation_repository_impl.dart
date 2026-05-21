import '../../domain/repositories/translation_repository.dart';
import '../datasources/translation_remote_data_source.dart';
import '../local/app_database.dart';

class TranslationRepositoryImpl implements TranslationRepository {
  final TranslationRemoteDataSource remoteDataSource;
  final AppDatabase localDb;

  TranslationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDb,
  });

  @override
  Future<void> syncTranslations() async {
    try {
      final remoteData = await remoteDataSource.getAllTranslations();
      
      final companions = remoteData.map((json) => LocalTranslationsCompanion.insert(
        key: json['key'],
        languageCode: json['language_code'],
        value: json['value'],
      )).toList();
      
      await localDb.upsertTranslations(companions);
    } catch (e) {
      // Si pas d'internet, on ne fait rien, on garde ce qu'on a en local
    }
  }

  @override
  Future<String> getTranslation(String key, String languageCode) async {
    final localValue = await localDb.getTranslation(key, languageCode);
    
    // Si pas trouvé dans la langue demandée, on tente en français (fallback)
    if (localValue == null && languageCode != 'fr') {
      return await getTranslation(key, 'fr');
    }
    
    return localValue ?? key; // Si vraiment rien, on affiche la clé
  }

  @override
  Future<List<String>> getAvailableLanguages() async {
    return await localDb.getAvailableLanguages();
  }

  @override
  Future<Map<String, String>> getTranslationsMap(String languageCode) async {
    final entries = await (localDb.select(localDb.localTranslations)
          ..where((t) => t.languageCode.equals(languageCode)))
        .get();

    final map = {for (var e in entries) e.key: e.value};

    if (languageCode != 'fr') {
      final frEntries = await (localDb.select(localDb.localTranslations)
            ..where((t) => t.languageCode.equals('fr')))
          .get();
      for (var e in frEntries) {
        map.putIfAbsent(e.key, () => e.value);
      }
    }

    return map;
  }
}
