import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_flutter/domain/repositories/translation_repository.dart';
import 'package:app_flutter/presentation/providers/translation_providers.dart';

class DummyTranslationRepository implements TranslationRepository {
  @override
  Future<void> syncTranslations() async {}

  @override
  Future<String> getTranslation(String key, String languageCode) async => key;

  @override
  Future<List<String>> getAvailableLanguages() async => ['fr'];

  @override
  Future<Map<String, String>> getTranslationsMap(String languageCode) async => {};
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('L\'écran de démarrage affiche les 2 rôles principaux', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          translationRepositoryProvider.overrideWithValue(DummyTranslationRepository()),
        ],
        child: const MathRunnerApp(),
      ),
    );
    
    // On attend un peu que les animations se lancent
    await tester.pump(const Duration(milliseconds: 500));

    // Vérifie que les 2 rôles sont présents sur l'écran.
    // Note : On cherche les textes qui sont dans nos valeurs par défaut de tr()
    expect(find.text('Je suis un Élève'), findsOneWidget);
    expect(find.text('Je suis un Parent'), findsOneWidget);
    expect(find.text('Je suis un Enseignant'), findsOneWidget);
    
    // On vérifie que le titre est présent
    expect(find.text('MATH RUNNER'), findsOneWidget);
  });
}
