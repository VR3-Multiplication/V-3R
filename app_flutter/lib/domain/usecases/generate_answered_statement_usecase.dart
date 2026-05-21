import '../entities/xapi_statement.dart';

class GenerateAnsweredStatementUseCase {
  XAPIStatement execute({
    required String actorId,
    required String question,
    required String expectedAnswer,
    required String userAnswer,
    required double durationSeconds,
  }) {
    return XAPIStatement(
      actor: XAPIActor(name: actorId),
      verb: XAPIVerb(id: "http://adlnet.gov/expapi/verbs/answered"),
      object: XAPIObject(id: "https://votre-app.com/activities/multiplication/$question"),
      result: XAPIResult(
        success: expectedAnswer == userAnswer,
        response: userAnswer,
        durationSeconds: durationSeconds,
      ),
    );
  }
}
