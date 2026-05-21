import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_providers.dart';
import 'local_database_provider.dart';
import '../../data/datasources/translation_remote_data_source.dart';
import '../../data/repositories/translation_repository_impl.dart';
import '../../domain/repositories/translation_repository.dart';

// 1. Data Source
final translationRemoteDataSourceProvider = Provider<TranslationRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return TranslationRemoteDataSourceImpl(supabaseClient: client);
});

// 2. Repository
final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  final remote = ref.watch(translationRemoteDataSourceProvider);
  final local = ref.watch(localDatabaseProvider);
  return TranslationRepositoryImpl(remoteDataSource: remote, localDb: local);
});

// 3. État de la langue actuelle (sauvegardé en local)
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('fr') {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('selected_language');
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setLanguage(String code) async {
    state = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', code);
  }
}

// 4. Provider qui charge toutes les traductions de la langue sélectionnée
final translationsMapProvider = FutureProvider<Map<String, String>>((ref) async {
  final lang = ref.watch(languageProvider);
  final repository = ref.watch(translationRepositoryProvider);
  return await repository.getTranslationsMap(lang);
});

// 5. Helper pour l'UI : tr(ref, 'ma_cle')
String tr(WidgetRef ref, String key) {
  final translations = ref.watch(translationsMapProvider).value ?? {};
  
  // Valeurs par défaut en dur pour éviter l'affichage des clés si la synchro est lente ou échoue
  final defaults = {
    'mon_pseudo': 'Mon Pseudo',
    'mon_code_secret': 'Mon Code Secret',
    'bon_retour': 'Bon retour !',
    'creer_profil': 'Créer mon profil',
    'pin_helper': '6 chiffres minimum',
    'jouer': 'Jouer !',
    'c_est_parti': 'C\'est parti !',
    'i_am_student': 'Je suis un Élève',
    'i_am_adult': 'Je suis un Adulte',
    'i_am_parent': 'Je suis un Parent',
    'i_am_teacher': 'Je suis un Enseignant',
    'math_runner': 'MATH RUNNER',
    'who_is_playing': 'Qui joue aujourd\'hui ?',
    'teacher_dashboard_title': 'Espace Enseignants',
    'no_student_yet': 'Aucun élève affilié pour le moment.',
    'affiliate_student': 'Affilier un élève',
    'no_child_yet': 'Aucun enfant affilié pour le moment.',
    'affiliate_child': 'Affilier un enfant',
    'ask_child_code': 'Demandez à l\'enfant de vous fournir le code à 6 caractères généré sur son application.',
    'ask_student_code': 'Demandez à l\'élève de vous fournir le code à 6 caractères généré sur son application.',
    'assigned_work': 'Mission Recommandée',
    'free_play_title': 'Entraînement Libre',
    'play_free': 'Jouer en Mode Libre',
  };

  return translations[key] ?? defaults[key] ?? key;
}
