import 'package:flutter_test/flutter_test.dart';
import 'package:app_flutter/domain/usecases/generate_answered_statement_usecase.dart';

void main() {
  late GenerateAnsweredStatementUseCase useCase;

  setUp(() {
    useCase = GenerateAnsweredStatementUseCase();
  });

  test('Doit générer un xAPI Statement valide pour une bonne réponse à un calcul', () {
    // Arrange (Préparation des données reçues de Unity)
    const actorId = "user-123";
    const question = "7x8";
    const expectedAnswer = "56";
    const userAnswer = "56";
    const durationSeconds = 1.2;

    // Act (Exécution du Use Case)
    final result = useCase.execute(
      actorId: actorId,
      question: question,
      expectedAnswer: expectedAnswer,
      userAnswer: userAnswer,
      durationSeconds: durationSeconds,
    );

    // Assert (Vérification)
    expect(result.actor.name, "user-123");
    expect(result.verb.id, "http://adlnet.gov/expapi/verbs/answered");
    expect(result.object.id, "https://votre-app.com/activities/multiplication/7x8");
    expect(result.result.success, true);
    expect(result.result.response, "56");
    expect(result.result.durationSeconds, 1.2);
  });

  test('Doit générer un xAPI Statement valide pour une MAUVAISE réponse', () {
    final result = useCase.execute(
      actorId: "user-123",
      question: "7x8",
      expectedAnswer: "56",
      userAnswer: "48", // Mauvaise réponse
      durationSeconds: 2.5,
    );

    expect(result.result.success, false);
    expect(result.result.response, "48");
  });
}
