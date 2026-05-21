abstract class TranslationRepository {
  /// Synchronise toutes les traductions depuis Supabase vers la base locale
  Future<void> syncTranslations();

  /// Récupère la traduction d'une clé dans la langue donnée (depuis le local)
  Future<String> getTranslation(String key, String languageCode);

  /// Liste les codes de langues disponibles en local
  Future<List<String>> getAvailableLanguages();

  /// Récupère toutes les traductions locales pour un code de langue donné
  Future<Map<String, String>> getTranslationsMap(String languageCode);
}
