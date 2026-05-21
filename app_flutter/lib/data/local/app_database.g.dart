// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MissionsTable extends Missions with TableInfo<$MissionsTable, Mission> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MissionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adultIdMeta = const VerificationMeta(
    'adultId',
  );
  @override
  late final GeneratedColumn<String> adultId = GeneratedColumn<String>(
    'adult_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    adultId,
    childId,
    operationType,
    difficulty,
    isCompleted,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'missions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mission> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('adult_id')) {
      context.handle(
        _adultIdMeta,
        adultId.isAcceptableOrUnknown(data['adult_id']!, _adultIdMeta),
      );
    } else if (isInserting) {
      context.missing(_adultIdMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Mission map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mission(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      adultId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adult_id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MissionsTable createAlias(String alias) {
    return $MissionsTable(attachedDatabase, alias);
  }
}

class Mission extends DataClass implements Insertable<Mission> {
  final String id;
  final String adultId;
  final String childId;
  final String operationType;
  final int difficulty;
  final bool isCompleted;
  final DateTime createdAt;
  const Mission({
    required this.id,
    required this.adultId,
    required this.childId,
    required this.operationType,
    required this.difficulty,
    required this.isCompleted,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['adult_id'] = Variable<String>(adultId);
    map['child_id'] = Variable<String>(childId);
    map['operation_type'] = Variable<String>(operationType);
    map['difficulty'] = Variable<int>(difficulty);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MissionsCompanion toCompanion(bool nullToAbsent) {
    return MissionsCompanion(
      id: Value(id),
      adultId: Value(adultId),
      childId: Value(childId),
      operationType: Value(operationType),
      difficulty: Value(difficulty),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
    );
  }

  factory Mission.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mission(
      id: serializer.fromJson<String>(json['id']),
      adultId: serializer.fromJson<String>(json['adultId']),
      childId: serializer.fromJson<String>(json['childId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'adultId': serializer.toJson<String>(adultId),
      'childId': serializer.toJson<String>(childId),
      'operationType': serializer.toJson<String>(operationType),
      'difficulty': serializer.toJson<int>(difficulty),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Mission copyWith({
    String? id,
    String? adultId,
    String? childId,
    String? operationType,
    int? difficulty,
    bool? isCompleted,
    DateTime? createdAt,
  }) => Mission(
    id: id ?? this.id,
    adultId: adultId ?? this.adultId,
    childId: childId ?? this.childId,
    operationType: operationType ?? this.operationType,
    difficulty: difficulty ?? this.difficulty,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
  );
  Mission copyWithCompanion(MissionsCompanion data) {
    return Mission(
      id: data.id.present ? data.id.value : this.id,
      adultId: data.adultId.present ? data.adultId.value : this.adultId,
      childId: data.childId.present ? data.childId.value : this.childId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mission(')
          ..write('id: $id, ')
          ..write('adultId: $adultId, ')
          ..write('childId: $childId, ')
          ..write('operationType: $operationType, ')
          ..write('difficulty: $difficulty, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    adultId,
    childId,
    operationType,
    difficulty,
    isCompleted,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mission &&
          other.id == this.id &&
          other.adultId == this.adultId &&
          other.childId == this.childId &&
          other.operationType == this.operationType &&
          other.difficulty == this.difficulty &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt);
}

class MissionsCompanion extends UpdateCompanion<Mission> {
  final Value<String> id;
  final Value<String> adultId;
  final Value<String> childId;
  final Value<String> operationType;
  final Value<int> difficulty;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MissionsCompanion({
    this.id = const Value.absent(),
    this.adultId = const Value.absent(),
    this.childId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MissionsCompanion.insert({
    required String id,
    required String adultId,
    required String childId,
    required String operationType,
    required int difficulty,
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       adultId = Value(adultId),
       childId = Value(childId),
       operationType = Value(operationType),
       difficulty = Value(difficulty),
       createdAt = Value(createdAt);
  static Insertable<Mission> custom({
    Expression<String>? id,
    Expression<String>? adultId,
    Expression<String>? childId,
    Expression<String>? operationType,
    Expression<int>? difficulty,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adultId != null) 'adult_id': adultId,
      if (childId != null) 'child_id': childId,
      if (operationType != null) 'operation_type': operationType,
      if (difficulty != null) 'difficulty': difficulty,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MissionsCompanion copyWith({
    Value<String>? id,
    Value<String>? adultId,
    Value<String>? childId,
    Value<String>? operationType,
    Value<int>? difficulty,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MissionsCompanion(
      id: id ?? this.id,
      adultId: adultId ?? this.adultId,
      childId: childId ?? this.childId,
      operationType: operationType ?? this.operationType,
      difficulty: difficulty ?? this.difficulty,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (adultId.present) {
      map['adult_id'] = Variable<String>(adultId.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MissionsCompanion(')
          ..write('id: $id, ')
          ..write('adultId: $adultId, ')
          ..write('childId: $childId, ')
          ..write('operationType: $operationType, ')
          ..write('difficulty: $difficulty, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalStatementsTable extends LocalStatements
    with TableInfo<$LocalStatementsTable, LocalStatement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalStatementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operand1Meta = const VerificationMeta(
    'operand1',
  );
  @override
  late final GeneratedColumn<int> operand1 = GeneratedColumn<int>(
    'operand1',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operand2Meta = const VerificationMeta(
    'operand2',
  );
  @override
  late final GeneratedColumn<int> operand2 = GeneratedColumn<int>(
    'operand2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _successMeta = const VerificationMeta(
    'success',
  );
  @override
  late final GeneratedColumn<bool> success = GeneratedColumn<bool>(
    'success',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("success" IN (0, 1))',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    childId,
    operand1,
    operand2,
    success,
    createdAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_statements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalStatement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('operand1')) {
      context.handle(
        _operand1Meta,
        operand1.isAcceptableOrUnknown(data['operand1']!, _operand1Meta),
      );
    } else if (isInserting) {
      context.missing(_operand1Meta);
    }
    if (data.containsKey('operand2')) {
      context.handle(
        _operand2Meta,
        operand2.isAcceptableOrUnknown(data['operand2']!, _operand2Meta),
      );
    } else if (isInserting) {
      context.missing(_operand2Meta);
    }
    if (data.containsKey('success')) {
      context.handle(
        _successMeta,
        success.isAcceptableOrUnknown(data['success']!, _successMeta),
      );
    } else if (isInserting) {
      context.missing(_successMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalStatement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalStatement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      operand1: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operand1'],
      )!,
      operand2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}operand2'],
      )!,
      success: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}success'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalStatementsTable createAlias(String alias) {
    return $LocalStatementsTable(attachedDatabase, alias);
  }
}

class LocalStatement extends DataClass implements Insertable<LocalStatement> {
  final int id;
  final String childId;
  final int operand1;
  final int operand2;
  final bool success;
  final DateTime createdAt;
  final bool isSynced;
  const LocalStatement({
    required this.id,
    required this.childId,
    required this.operand1,
    required this.operand2,
    required this.success,
    required this.createdAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['child_id'] = Variable<String>(childId);
    map['operand1'] = Variable<int>(operand1);
    map['operand2'] = Variable<int>(operand2);
    map['success'] = Variable<bool>(success);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalStatementsCompanion toCompanion(bool nullToAbsent) {
    return LocalStatementsCompanion(
      id: Value(id),
      childId: Value(childId),
      operand1: Value(operand1),
      operand2: Value(operand2),
      success: Value(success),
      createdAt: Value(createdAt),
      isSynced: Value(isSynced),
    );
  }

  factory LocalStatement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalStatement(
      id: serializer.fromJson<int>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      operand1: serializer.fromJson<int>(json['operand1']),
      operand2: serializer.fromJson<int>(json['operand2']),
      success: serializer.fromJson<bool>(json['success']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'childId': serializer.toJson<String>(childId),
      'operand1': serializer.toJson<int>(operand1),
      'operand2': serializer.toJson<int>(operand2),
      'success': serializer.toJson<bool>(success),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalStatement copyWith({
    int? id,
    String? childId,
    int? operand1,
    int? operand2,
    bool? success,
    DateTime? createdAt,
    bool? isSynced,
  }) => LocalStatement(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    operand1: operand1 ?? this.operand1,
    operand2: operand2 ?? this.operand2,
    success: success ?? this.success,
    createdAt: createdAt ?? this.createdAt,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalStatement copyWithCompanion(LocalStatementsCompanion data) {
    return LocalStatement(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      operand1: data.operand1.present ? data.operand1.value : this.operand1,
      operand2: data.operand2.present ? data.operand2.value : this.operand2,
      success: data.success.present ? data.success.value : this.success,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalStatement(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('operand1: $operand1, ')
          ..write('operand2: $operand2, ')
          ..write('success: $success, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    childId,
    operand1,
    operand2,
    success,
    createdAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalStatement &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.operand1 == this.operand1 &&
          other.operand2 == this.operand2 &&
          other.success == this.success &&
          other.createdAt == this.createdAt &&
          other.isSynced == this.isSynced);
}

class LocalStatementsCompanion extends UpdateCompanion<LocalStatement> {
  final Value<int> id;
  final Value<String> childId;
  final Value<int> operand1;
  final Value<int> operand2;
  final Value<bool> success;
  final Value<DateTime> createdAt;
  final Value<bool> isSynced;
  const LocalStatementsCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.operand1 = const Value.absent(),
    this.operand2 = const Value.absent(),
    this.success = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  });
  LocalStatementsCompanion.insert({
    this.id = const Value.absent(),
    required String childId,
    required int operand1,
    required int operand2,
    required bool success,
    this.createdAt = const Value.absent(),
    this.isSynced = const Value.absent(),
  }) : childId = Value(childId),
       operand1 = Value(operand1),
       operand2 = Value(operand2),
       success = Value(success);
  static Insertable<LocalStatement> custom({
    Expression<int>? id,
    Expression<String>? childId,
    Expression<int>? operand1,
    Expression<int>? operand2,
    Expression<bool>? success,
    Expression<DateTime>? createdAt,
    Expression<bool>? isSynced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (operand1 != null) 'operand1': operand1,
      if (operand2 != null) 'operand2': operand2,
      if (success != null) 'success': success,
      if (createdAt != null) 'created_at': createdAt,
      if (isSynced != null) 'is_synced': isSynced,
    });
  }

  LocalStatementsCompanion copyWith({
    Value<int>? id,
    Value<String>? childId,
    Value<int>? operand1,
    Value<int>? operand2,
    Value<bool>? success,
    Value<DateTime>? createdAt,
    Value<bool>? isSynced,
  }) {
    return LocalStatementsCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      operand1: operand1 ?? this.operand1,
      operand2: operand2 ?? this.operand2,
      success: success ?? this.success,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (operand1.present) {
      map['operand1'] = Variable<int>(operand1.value);
    }
    if (operand2.present) {
      map['operand2'] = Variable<int>(operand2.value);
    }
    if (success.present) {
      map['success'] = Variable<bool>(success.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalStatementsCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('operand1: $operand1, ')
          ..write('operand2: $operand2, ')
          ..write('success: $success, ')
          ..write('createdAt: $createdAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }
}

class $LocalTranslationsTable extends LocalTranslations
    with TableInfo<$LocalTranslationsTable, LocalTranslation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTranslationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _languageCodeMeta = const VerificationMeta(
    'languageCode',
  );
  @override
  late final GeneratedColumn<String> languageCode = GeneratedColumn<String>(
    'language_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, languageCode, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_translations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTranslation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('language_code')) {
      context.handle(
        _languageCodeMeta,
        languageCode.isAcceptableOrUnknown(
          data['language_code']!,
          _languageCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_languageCodeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key, languageCode};
  @override
  LocalTranslation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTranslation(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      languageCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language_code'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $LocalTranslationsTable createAlias(String alias) {
    return $LocalTranslationsTable(attachedDatabase, alias);
  }
}

class LocalTranslation extends DataClass
    implements Insertable<LocalTranslation> {
  final String key;
  final String languageCode;
  final String value;
  const LocalTranslation({
    required this.key,
    required this.languageCode,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['language_code'] = Variable<String>(languageCode);
    map['value'] = Variable<String>(value);
    return map;
  }

  LocalTranslationsCompanion toCompanion(bool nullToAbsent) {
    return LocalTranslationsCompanion(
      key: Value(key),
      languageCode: Value(languageCode),
      value: Value(value),
    );
  }

  factory LocalTranslation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTranslation(
      key: serializer.fromJson<String>(json['key']),
      languageCode: serializer.fromJson<String>(json['languageCode']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'languageCode': serializer.toJson<String>(languageCode),
      'value': serializer.toJson<String>(value),
    };
  }

  LocalTranslation copyWith({
    String? key,
    String? languageCode,
    String? value,
  }) => LocalTranslation(
    key: key ?? this.key,
    languageCode: languageCode ?? this.languageCode,
    value: value ?? this.value,
  );
  LocalTranslation copyWithCompanion(LocalTranslationsCompanion data) {
    return LocalTranslation(
      key: data.key.present ? data.key.value : this.key,
      languageCode: data.languageCode.present
          ? data.languageCode.value
          : this.languageCode,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTranslation(')
          ..write('key: $key, ')
          ..write('languageCode: $languageCode, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, languageCode, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTranslation &&
          other.key == this.key &&
          other.languageCode == this.languageCode &&
          other.value == this.value);
}

class LocalTranslationsCompanion extends UpdateCompanion<LocalTranslation> {
  final Value<String> key;
  final Value<String> languageCode;
  final Value<String> value;
  final Value<int> rowid;
  const LocalTranslationsCompanion({
    this.key = const Value.absent(),
    this.languageCode = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTranslationsCompanion.insert({
    required String key,
    required String languageCode,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       languageCode = Value(languageCode),
       value = Value(value);
  static Insertable<LocalTranslation> custom({
    Expression<String>? key,
    Expression<String>? languageCode,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (languageCode != null) 'language_code': languageCode,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTranslationsCompanion copyWith({
    Value<String>? key,
    Value<String>? languageCode,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return LocalTranslationsCompanion(
      key: key ?? this.key,
      languageCode: languageCode ?? this.languageCode,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (languageCode.present) {
      map['language_code'] = Variable<String>(languageCode.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTranslationsCompanion(')
          ..write('key: $key, ')
          ..write('languageCode: $languageCode, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopItemsTable extends ShopItems
    with TableInfo<$ShopItemsTable, ShopItemData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unityIdMeta = const VerificationMeta(
    'unityId',
  );
  @override
  late final GeneratedColumn<String> unityId = GeneratedColumn<String>(
    'unity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('car'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    price,
    unityId,
    category,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShopItemData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('unity_id')) {
      context.handle(
        _unityIdMeta,
        unityId.isAcceptableOrUnknown(data['unity_id']!, _unityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_unityIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopItemData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopItemData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      unityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unity_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
    );
  }

  @override
  $ShopItemsTable createAlias(String alias) {
    return $ShopItemsTable(attachedDatabase, alias);
  }
}

class ShopItemData extends DataClass implements Insertable<ShopItemData> {
  final String id;
  final String name;
  final String? description;
  final int price;
  final String unityId;
  final String category;
  const ShopItemData({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.unityId,
    required this.category,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['price'] = Variable<int>(price);
    map['unity_id'] = Variable<String>(unityId);
    map['category'] = Variable<String>(category);
    return map;
  }

  ShopItemsCompanion toCompanion(bool nullToAbsent) {
    return ShopItemsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      price: Value(price),
      unityId: Value(unityId),
      category: Value(category),
    );
  }

  factory ShopItemData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopItemData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      price: serializer.fromJson<int>(json['price']),
      unityId: serializer.fromJson<String>(json['unityId']),
      category: serializer.fromJson<String>(json['category']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'price': serializer.toJson<int>(price),
      'unityId': serializer.toJson<String>(unityId),
      'category': serializer.toJson<String>(category),
    };
  }

  ShopItemData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    int? price,
    String? unityId,
    String? category,
  }) => ShopItemData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    price: price ?? this.price,
    unityId: unityId ?? this.unityId,
    category: category ?? this.category,
  );
  ShopItemData copyWithCompanion(ShopItemsCompanion data) {
    return ShopItemData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      price: data.price.present ? data.price.value : this.price,
      unityId: data.unityId.present ? data.unityId.value : this.unityId,
      category: data.category.present ? data.category.value : this.category,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopItemData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('unityId: $unityId, ')
          ..write('category: $category')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, price, unityId, category);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopItemData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.price == this.price &&
          other.unityId == this.unityId &&
          other.category == this.category);
}

class ShopItemsCompanion extends UpdateCompanion<ShopItemData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<int> price;
  final Value<String> unityId;
  final Value<String> category;
  final Value<int> rowid;
  const ShopItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.price = const Value.absent(),
    this.unityId = const Value.absent(),
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopItemsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required int price,
    required String unityId,
    this.category = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       price = Value(price),
       unityId = Value(unityId);
  static Insertable<ShopItemData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? price,
    Expression<String>? unityId,
    Expression<String>? category,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (price != null) 'price': price,
      if (unityId != null) 'unity_id': unityId,
      if (category != null) 'category': category,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<int>? price,
    Value<String>? unityId,
    Value<String>? category,
    Value<int>? rowid,
  }) {
    return ShopItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unityId: unityId ?? this.unityId,
      category: category ?? this.category,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (unityId.present) {
      map['unity_id'] = Variable<String>(unityId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('price: $price, ')
          ..write('unityId: $unityId, ')
          ..write('category: $category, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalInventoryTable extends LocalInventory
    with TableInfo<$LocalInventoryTable, LocalInventoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalInventoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _childIdMeta = const VerificationMeta(
    'childId',
  );
  @override
  late final GeneratedColumn<String> childId = GeneratedColumn<String>(
    'child_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEquippedMeta = const VerificationMeta(
    'isEquipped',
  );
  @override
  late final GeneratedColumn<bool> isEquipped = GeneratedColumn<bool>(
    'is_equipped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_equipped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, childId, itemId, isEquipped];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_inventory';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalInventoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('child_id')) {
      context.handle(
        _childIdMeta,
        childId.isAcceptableOrUnknown(data['child_id']!, _childIdMeta),
      );
    } else if (isInserting) {
      context.missing(_childIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('is_equipped')) {
      context.handle(
        _isEquippedMeta,
        isEquipped.isAcceptableOrUnknown(data['is_equipped']!, _isEquippedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalInventoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalInventoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      childId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}child_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      isEquipped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_equipped'],
      )!,
    );
  }

  @override
  $LocalInventoryTable createAlias(String alias) {
    return $LocalInventoryTable(attachedDatabase, alias);
  }
}

class LocalInventoryData extends DataClass
    implements Insertable<LocalInventoryData> {
  final String id;
  final String childId;
  final String itemId;
  final bool isEquipped;
  const LocalInventoryData({
    required this.id,
    required this.childId,
    required this.itemId,
    required this.isEquipped,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['child_id'] = Variable<String>(childId);
    map['item_id'] = Variable<String>(itemId);
    map['is_equipped'] = Variable<bool>(isEquipped);
    return map;
  }

  LocalInventoryCompanion toCompanion(bool nullToAbsent) {
    return LocalInventoryCompanion(
      id: Value(id),
      childId: Value(childId),
      itemId: Value(itemId),
      isEquipped: Value(isEquipped),
    );
  }

  factory LocalInventoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalInventoryData(
      id: serializer.fromJson<String>(json['id']),
      childId: serializer.fromJson<String>(json['childId']),
      itemId: serializer.fromJson<String>(json['itemId']),
      isEquipped: serializer.fromJson<bool>(json['isEquipped']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'childId': serializer.toJson<String>(childId),
      'itemId': serializer.toJson<String>(itemId),
      'isEquipped': serializer.toJson<bool>(isEquipped),
    };
  }

  LocalInventoryData copyWith({
    String? id,
    String? childId,
    String? itemId,
    bool? isEquipped,
  }) => LocalInventoryData(
    id: id ?? this.id,
    childId: childId ?? this.childId,
    itemId: itemId ?? this.itemId,
    isEquipped: isEquipped ?? this.isEquipped,
  );
  LocalInventoryData copyWithCompanion(LocalInventoryCompanion data) {
    return LocalInventoryData(
      id: data.id.present ? data.id.value : this.id,
      childId: data.childId.present ? data.childId.value : this.childId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      isEquipped: data.isEquipped.present
          ? data.isEquipped.value
          : this.isEquipped,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryData(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('itemId: $itemId, ')
          ..write('isEquipped: $isEquipped')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, childId, itemId, isEquipped);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalInventoryData &&
          other.id == this.id &&
          other.childId == this.childId &&
          other.itemId == this.itemId &&
          other.isEquipped == this.isEquipped);
}

class LocalInventoryCompanion extends UpdateCompanion<LocalInventoryData> {
  final Value<String> id;
  final Value<String> childId;
  final Value<String> itemId;
  final Value<bool> isEquipped;
  final Value<int> rowid;
  const LocalInventoryCompanion({
    this.id = const Value.absent(),
    this.childId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.isEquipped = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalInventoryCompanion.insert({
    required String id,
    required String childId,
    required String itemId,
    this.isEquipped = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       childId = Value(childId),
       itemId = Value(itemId);
  static Insertable<LocalInventoryData> custom({
    Expression<String>? id,
    Expression<String>? childId,
    Expression<String>? itemId,
    Expression<bool>? isEquipped,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (childId != null) 'child_id': childId,
      if (itemId != null) 'item_id': itemId,
      if (isEquipped != null) 'is_equipped': isEquipped,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalInventoryCompanion copyWith({
    Value<String>? id,
    Value<String>? childId,
    Value<String>? itemId,
    Value<bool>? isEquipped,
    Value<int>? rowid,
  }) {
    return LocalInventoryCompanion(
      id: id ?? this.id,
      childId: childId ?? this.childId,
      itemId: itemId ?? this.itemId,
      isEquipped: isEquipped ?? this.isEquipped,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (childId.present) {
      map['child_id'] = Variable<String>(childId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (isEquipped.present) {
      map['is_equipped'] = Variable<bool>(isEquipped.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalInventoryCompanion(')
          ..write('id: $id, ')
          ..write('childId: $childId, ')
          ..write('itemId: $itemId, ')
          ..write('isEquipped: $isEquipped, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MissionsTable missions = $MissionsTable(this);
  late final $LocalStatementsTable localStatements = $LocalStatementsTable(
    this,
  );
  late final $LocalTranslationsTable localTranslations =
      $LocalTranslationsTable(this);
  late final $ShopItemsTable shopItems = $ShopItemsTable(this);
  late final $LocalInventoryTable localInventory = $LocalInventoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    missions,
    localStatements,
    localTranslations,
    shopItems,
    localInventory,
  ];
}

typedef $$MissionsTableCreateCompanionBuilder =
    MissionsCompanion Function({
      required String id,
      required String adultId,
      required String childId,
      required String operationType,
      required int difficulty,
      Value<bool> isCompleted,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$MissionsTableUpdateCompanionBuilder =
    MissionsCompanion Function({
      Value<String> id,
      Value<String> adultId,
      Value<String> childId,
      Value<String> operationType,
      Value<int> difficulty,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MissionsTableFilterComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adultId => $composableBuilder(
    column: $table.adultId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MissionsTableOrderingComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adultId => $composableBuilder(
    column: $table.adultId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MissionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MissionsTable> {
  $$MissionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get adultId =>
      $composableBuilder(column: $table.adultId, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MissionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MissionsTable,
          Mission,
          $$MissionsTableFilterComposer,
          $$MissionsTableOrderingComposer,
          $$MissionsTableAnnotationComposer,
          $$MissionsTableCreateCompanionBuilder,
          $$MissionsTableUpdateCompanionBuilder,
          (Mission, BaseReferences<_$AppDatabase, $MissionsTable, Mission>),
          Mission,
          PrefetchHooks Function()
        > {
  $$MissionsTableTableManager(_$AppDatabase db, $MissionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MissionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MissionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MissionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> adultId = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion(
                id: id,
                adultId: adultId,
                childId: childId,
                operationType: operationType,
                difficulty: difficulty,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String adultId,
                required String childId,
                required String operationType,
                required int difficulty,
                Value<bool> isCompleted = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => MissionsCompanion.insert(
                id: id,
                adultId: adultId,
                childId: childId,
                operationType: operationType,
                difficulty: difficulty,
                isCompleted: isCompleted,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MissionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MissionsTable,
      Mission,
      $$MissionsTableFilterComposer,
      $$MissionsTableOrderingComposer,
      $$MissionsTableAnnotationComposer,
      $$MissionsTableCreateCompanionBuilder,
      $$MissionsTableUpdateCompanionBuilder,
      (Mission, BaseReferences<_$AppDatabase, $MissionsTable, Mission>),
      Mission,
      PrefetchHooks Function()
    >;
typedef $$LocalStatementsTableCreateCompanionBuilder =
    LocalStatementsCompanion Function({
      Value<int> id,
      required String childId,
      required int operand1,
      required int operand2,
      required bool success,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });
typedef $$LocalStatementsTableUpdateCompanionBuilder =
    LocalStatementsCompanion Function({
      Value<int> id,
      Value<String> childId,
      Value<int> operand1,
      Value<int> operand2,
      Value<bool> success,
      Value<DateTime> createdAt,
      Value<bool> isSynced,
    });

class $$LocalStatementsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalStatementsTable> {
  $$LocalStatementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operand1 => $composableBuilder(
    column: $table.operand1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get operand2 => $composableBuilder(
    column: $table.operand2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalStatementsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalStatementsTable> {
  $$LocalStatementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operand1 => $composableBuilder(
    column: $table.operand1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get operand2 => $composableBuilder(
    column: $table.operand2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get success => $composableBuilder(
    column: $table.success,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalStatementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalStatementsTable> {
  $$LocalStatementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<int> get operand1 =>
      $composableBuilder(column: $table.operand1, builder: (column) => column);

  GeneratedColumn<int> get operand2 =>
      $composableBuilder(column: $table.operand2, builder: (column) => column);

  GeneratedColumn<bool> get success =>
      $composableBuilder(column: $table.success, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$LocalStatementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalStatementsTable,
          LocalStatement,
          $$LocalStatementsTableFilterComposer,
          $$LocalStatementsTableOrderingComposer,
          $$LocalStatementsTableAnnotationComposer,
          $$LocalStatementsTableCreateCompanionBuilder,
          $$LocalStatementsTableUpdateCompanionBuilder,
          (
            LocalStatement,
            BaseReferences<
              _$AppDatabase,
              $LocalStatementsTable,
              LocalStatement
            >,
          ),
          LocalStatement,
          PrefetchHooks Function()
        > {
  $$LocalStatementsTableTableManager(
    _$AppDatabase db,
    $LocalStatementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalStatementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalStatementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalStatementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<int> operand1 = const Value.absent(),
                Value<int> operand2 = const Value.absent(),
                Value<bool> success = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => LocalStatementsCompanion(
                id: id,
                childId: childId,
                operand1: operand1,
                operand2: operand2,
                success: success,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String childId,
                required int operand1,
                required int operand2,
                required bool success,
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
              }) => LocalStatementsCompanion.insert(
                id: id,
                childId: childId,
                operand1: operand1,
                operand2: operand2,
                success: success,
                createdAt: createdAt,
                isSynced: isSynced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalStatementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalStatementsTable,
      LocalStatement,
      $$LocalStatementsTableFilterComposer,
      $$LocalStatementsTableOrderingComposer,
      $$LocalStatementsTableAnnotationComposer,
      $$LocalStatementsTableCreateCompanionBuilder,
      $$LocalStatementsTableUpdateCompanionBuilder,
      (
        LocalStatement,
        BaseReferences<_$AppDatabase, $LocalStatementsTable, LocalStatement>,
      ),
      LocalStatement,
      PrefetchHooks Function()
    >;
typedef $$LocalTranslationsTableCreateCompanionBuilder =
    LocalTranslationsCompanion Function({
      required String key,
      required String languageCode,
      required String value,
      Value<int> rowid,
    });
typedef $$LocalTranslationsTableUpdateCompanionBuilder =
    LocalTranslationsCompanion Function({
      Value<String> key,
      Value<String> languageCode,
      Value<String> value,
      Value<int> rowid,
    });

class $$LocalTranslationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTranslationsTable> {
  $$LocalTranslationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTranslationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTranslationsTable> {
  $$LocalTranslationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTranslationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTranslationsTable> {
  $$LocalTranslationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get languageCode => $composableBuilder(
    column: $table.languageCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$LocalTranslationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTranslationsTable,
          LocalTranslation,
          $$LocalTranslationsTableFilterComposer,
          $$LocalTranslationsTableOrderingComposer,
          $$LocalTranslationsTableAnnotationComposer,
          $$LocalTranslationsTableCreateCompanionBuilder,
          $$LocalTranslationsTableUpdateCompanionBuilder,
          (
            LocalTranslation,
            BaseReferences<
              _$AppDatabase,
              $LocalTranslationsTable,
              LocalTranslation
            >,
          ),
          LocalTranslation,
          PrefetchHooks Function()
        > {
  $$LocalTranslationsTableTableManager(
    _$AppDatabase db,
    $LocalTranslationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTranslationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTranslationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTranslationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> languageCode = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTranslationsCompanion(
                key: key,
                languageCode: languageCode,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String languageCode,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => LocalTranslationsCompanion.insert(
                key: key,
                languageCode: languageCode,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTranslationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTranslationsTable,
      LocalTranslation,
      $$LocalTranslationsTableFilterComposer,
      $$LocalTranslationsTableOrderingComposer,
      $$LocalTranslationsTableAnnotationComposer,
      $$LocalTranslationsTableCreateCompanionBuilder,
      $$LocalTranslationsTableUpdateCompanionBuilder,
      (
        LocalTranslation,
        BaseReferences<
          _$AppDatabase,
          $LocalTranslationsTable,
          LocalTranslation
        >,
      ),
      LocalTranslation,
      PrefetchHooks Function()
    >;
typedef $$ShopItemsTableCreateCompanionBuilder =
    ShopItemsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required int price,
      required String unityId,
      Value<String> category,
      Value<int> rowid,
    });
typedef $$ShopItemsTableUpdateCompanionBuilder =
    ShopItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<int> price,
      Value<String> unityId,
      Value<String> category,
      Value<int> rowid,
    });

class $$ShopItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopItemsTable> {
  $$ShopItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unityId => $composableBuilder(
    column: $table.unityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShopItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopItemsTable> {
  $$ShopItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unityId => $composableBuilder(
    column: $table.unityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopItemsTable> {
  $$ShopItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get unityId =>
      $composableBuilder(column: $table.unityId, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);
}

class $$ShopItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopItemsTable,
          ShopItemData,
          $$ShopItemsTableFilterComposer,
          $$ShopItemsTableOrderingComposer,
          $$ShopItemsTableAnnotationComposer,
          $$ShopItemsTableCreateCompanionBuilder,
          $$ShopItemsTableUpdateCompanionBuilder,
          (
            ShopItemData,
            BaseReferences<_$AppDatabase, $ShopItemsTable, ShopItemData>,
          ),
          ShopItemData,
          PrefetchHooks Function()
        > {
  $$ShopItemsTableTableManager(_$AppDatabase db, $ShopItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<String> unityId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopItemsCompanion(
                id: id,
                name: name,
                description: description,
                price: price,
                unityId: unityId,
                category: category,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required int price,
                required String unityId,
                Value<String> category = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ShopItemsCompanion.insert(
                id: id,
                name: name,
                description: description,
                price: price,
                unityId: unityId,
                category: category,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShopItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopItemsTable,
      ShopItemData,
      $$ShopItemsTableFilterComposer,
      $$ShopItemsTableOrderingComposer,
      $$ShopItemsTableAnnotationComposer,
      $$ShopItemsTableCreateCompanionBuilder,
      $$ShopItemsTableUpdateCompanionBuilder,
      (
        ShopItemData,
        BaseReferences<_$AppDatabase, $ShopItemsTable, ShopItemData>,
      ),
      ShopItemData,
      PrefetchHooks Function()
    >;
typedef $$LocalInventoryTableCreateCompanionBuilder =
    LocalInventoryCompanion Function({
      required String id,
      required String childId,
      required String itemId,
      Value<bool> isEquipped,
      Value<int> rowid,
    });
typedef $$LocalInventoryTableUpdateCompanionBuilder =
    LocalInventoryCompanion Function({
      Value<String> id,
      Value<String> childId,
      Value<String> itemId,
      Value<bool> isEquipped,
      Value<int> rowid,
    });

class $$LocalInventoryTableFilterComposer
    extends Composer<_$AppDatabase, $LocalInventoryTable> {
  $$LocalInventoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEquipped => $composableBuilder(
    column: $table.isEquipped,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalInventoryTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalInventoryTable> {
  $$LocalInventoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get childId => $composableBuilder(
    column: $table.childId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEquipped => $composableBuilder(
    column: $table.isEquipped,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalInventoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalInventoryTable> {
  $$LocalInventoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get childId =>
      $composableBuilder(column: $table.childId, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<bool> get isEquipped => $composableBuilder(
    column: $table.isEquipped,
    builder: (column) => column,
  );
}

class $$LocalInventoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalInventoryTable,
          LocalInventoryData,
          $$LocalInventoryTableFilterComposer,
          $$LocalInventoryTableOrderingComposer,
          $$LocalInventoryTableAnnotationComposer,
          $$LocalInventoryTableCreateCompanionBuilder,
          $$LocalInventoryTableUpdateCompanionBuilder,
          (
            LocalInventoryData,
            BaseReferences<
              _$AppDatabase,
              $LocalInventoryTable,
              LocalInventoryData
            >,
          ),
          LocalInventoryData,
          PrefetchHooks Function()
        > {
  $$LocalInventoryTableTableManager(
    _$AppDatabase db,
    $LocalInventoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalInventoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalInventoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalInventoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> childId = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<bool> isEquipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryCompanion(
                id: id,
                childId: childId,
                itemId: itemId,
                isEquipped: isEquipped,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String childId,
                required String itemId,
                Value<bool> isEquipped = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalInventoryCompanion.insert(
                id: id,
                childId: childId,
                itemId: itemId,
                isEquipped: isEquipped,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalInventoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalInventoryTable,
      LocalInventoryData,
      $$LocalInventoryTableFilterComposer,
      $$LocalInventoryTableOrderingComposer,
      $$LocalInventoryTableAnnotationComposer,
      $$LocalInventoryTableCreateCompanionBuilder,
      $$LocalInventoryTableUpdateCompanionBuilder,
      (
        LocalInventoryData,
        BaseReferences<_$AppDatabase, $LocalInventoryTable, LocalInventoryData>,
      ),
      LocalInventoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MissionsTableTableManager get missions =>
      $$MissionsTableTableManager(_db, _db.missions);
  $$LocalStatementsTableTableManager get localStatements =>
      $$LocalStatementsTableTableManager(_db, _db.localStatements);
  $$LocalTranslationsTableTableManager get localTranslations =>
      $$LocalTranslationsTableTableManager(_db, _db.localTranslations);
  $$ShopItemsTableTableManager get shopItems =>
      $$ShopItemsTableTableManager(_db, _db.shopItems);
  $$LocalInventoryTableTableManager get localInventory =>
      $$LocalInventoryTableTableManager(_db, _db.localInventory);
}
