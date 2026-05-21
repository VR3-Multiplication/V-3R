class XAPIStatement {
  final XAPIActor actor;
  final XAPIVerb verb;
  final XAPIObject object;
  final XAPIResult result;

  XAPIStatement({
    required this.actor,
    required this.verb,
    required this.object,
    required this.result,
  });
}

class XAPIActor {
  final String name;
  XAPIActor({required this.name});
}

class XAPIVerb {
  final String id;
  XAPIVerb({required this.id});
}

class XAPIObject {
  final String id;
  XAPIObject({required this.id});
}

class XAPIResult {
  final bool success;
  final String response;
  final double durationSeconds;

  XAPIResult({
    required this.success,
    required this.response,
    required this.durationSeconds,
  });
}
