import 'package:shared_preferences/shared_preferences.dart';

class SessionTracker {
  static const String _keyLastActivity = 'last_activity_time';

  /// Met à jour l'horodatage de la dernière activité
  static Future<void> updateActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActivity, DateTime.now().millisecondsSinceEpoch);
  }

  /// Efface l'horodatage de la dernière activité
  static Future<void> clearActivity() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastActivity);
  }

  /// Vérifie si la session est encore valide (moins de 12 heures depuis la dernière activité)
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActivity = prefs.getInt(_keyLastActivity);
    if (lastActivity == null) {
      return true; // Session considérée valide s'il n'y a pas encore d'horodatage
    }

    final diff = DateTime.now().millisecondsSinceEpoch - lastActivity;
    final twelveHoursMs = 12 * 60 * 60 * 1000;
    return diff < twelveHoursMs;
  }
}
