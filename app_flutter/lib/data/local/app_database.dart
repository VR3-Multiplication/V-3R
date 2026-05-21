import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

// 1. Table des Missions (Miroir de Supabase)
class Missions extends Table {
  TextColumn get id => text()();
  TextColumn get adultId => text()();
  TextColumn get childId => text()();
  TextColumn get operationType => text()(); // ex: 'table_7'
  IntColumn get difficulty => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// 2. Table des Statements (Les logs de réponses à synchroniser)
class LocalStatements extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get childId => text()();
  IntColumn get operand1 => integer()();
  IntColumn get operand2 => integer()();
  BoolColumn get success => boolean()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Flag pour savoir si cette donnée a déjà été envoyée à Supabase
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
}

// 3. Table des Traductions (Pour l'Hyper-Multilingue)
class LocalTranslations extends Table {
  TextColumn get key => text()();
  TextColumn get languageCode => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key, languageCode};
}

// 4. Table des Objets de la Boutique
@DataClassName('ShopItemData')
class ShopItems extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get price => integer()();
  TextColumn get unityId => text()();
  TextColumn get category => text().withDefault(const Constant('car'))();

  @override
  Set<Column> get primaryKey => {id};
}

// 5. Table de l'Inventaire Local
@DataClassName('LocalInventoryData')
class LocalInventory extends Table {
  TextColumn get id => text()();
  TextColumn get childId => text()();
  TextColumn get itemId => text()();
  BoolColumn get isEquipped => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// 6. La Base de Données
@DriftDatabase(tables: [Missions, LocalStatements, LocalTranslations, ShopItems, LocalInventory])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // --- Requêtes pour les Missions ---
  Future<List<Mission>> getPendingMissions(String childId) => 
    (select(missions)..where((t) => t.childId.equals(childId) & t.isCompleted.equals(false))).get();

  Stream<List<Mission>> watchPendingMissions(String childId) => 
    (select(missions)..where((t) => t.childId.equals(childId) & t.isCompleted.equals(false))).watch();
    
  Future insertMissions(List<MissionsCompanion> entries) => 
    batch((batch) => batch.insertAllOnConflictUpdate(missions, entries));

  Future deleteOldPendingMissions(String childId, List<String> remoteIds) {
    if (remoteIds.isEmpty) {
      return (delete(missions)..where((t) => t.childId.equals(childId) & t.isCompleted.equals(false))).go();
    }
    return (delete(missions)..where((t) => t.childId.equals(childId) & t.isCompleted.equals(false) & t.id.isNotIn(remoteIds))).go();
  }

  // --- Requêtes pour les Statements (Logs) ---
  Future<int> addStatement(LocalStatementsCompanion entry) => into(localStatements).insert(entry);
  
  Future<List<LocalStatement>> getUnsyncedStatements() => 
    (select(localStatements)..where((t) => t.isSynced.equals(false))).get();
    
  Future markAsSynced(List<int> ids) => 
    (update(localStatements)..where((t) => t.id.isIn(ids))).write(const LocalStatementsCompanion(isSynced: Value(true)));

  // --- Requêtes pour les Traductions ---
  Future<String?> getTranslation(String key, String lang) async {
    final query = select(localTranslations)..where((t) => t.key.equals(key) & t.languageCode.equals(lang));
    final result = await query.getSingleOrNull();
    return result?.value;
  }

  Future upsertTranslations(List<LocalTranslationsCompanion> entries) => 
    batch((batch) => batch.insertAllOnConflictUpdate(localTranslations, entries));
    
  Future<List<String>> getAvailableLanguages() async {
    final query = selectOnly(localTranslations, distinct: true)..addColumns([localTranslations.languageCode]);
    final result = await query.get();
    return result.map((row) => row.read(localTranslations.languageCode)!).toList();
  }

  // --- Requêtes pour la Boutique ---
  Future<List<ShopItemData>> getAllShopItems() => select(shopItems).get();
  
  Future upsertShopItems(List<ShopItemsCompanion> entries) => 
    batch((batch) => batch.insertAllOnConflictUpdate(shopItems, entries));

  Future<List<LocalInventoryData>> getChildInventory(String childId) => 
    (select(localInventory)..where((t) => t.childId.equals(childId))).get();

  Future equipItem(String childId, String itemId) async {
    return transaction(() async {
      // 1. Déséquiper tout ce qui est dans la même catégorie (ex: toutes les voitures)
      await (update(localInventory)..where((t) => t.childId.equals(childId)))
        .write(const LocalInventoryCompanion(isEquipped: Value(false)));
      
      // 2. Équiper l'objet choisi
      await (update(localInventory)..where((t) => t.childId.equals(childId) & t.itemId.equals(itemId)))
        .write(const LocalInventoryCompanion(isEquipped: Value(true)));
    });
  }

  Future addInventoryItem(LocalInventoryCompanion entry) => 
    into(localInventory).insertOnConflictUpdate(entry);
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase(file);
  });
}
