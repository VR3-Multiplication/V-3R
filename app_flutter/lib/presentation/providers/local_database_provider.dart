import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/app_database.dart';

final localDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // On s'assure de fermer la base quand le provider est détruit (rare pour la DB principale mais bonne pratique)
  ref.onDispose(() {
    db.close();
  });
  
  return db;
});
