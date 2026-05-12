// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'autolife_database.dart';

// ignore_for_file: type=lint
class $SystemEventCacheTable extends SystemEventCache
    with TableInfo<$SystemEventCacheTable, SystemEventCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SystemEventCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _moduleMeta = const VerificationMeta('module');
  @override
  late final GeneratedColumn<String> module = GeneratedColumn<String>(
    'module',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderingTagMeta = const VerificationMeta(
    'orderingTag',
  );
  @override
  late final GeneratedColumn<String> orderingTag = GeneratedColumn<String>(
    'ordering_tag',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _schemaVersionMeta = const VerificationMeta(
    'schemaVersion',
  );
  @override
  late final GeneratedColumn<int> schemaVersion = GeneratedColumn<int>(
    'schema_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    actorId,
    module,
    type,
    payloadJson,
    idempotencyKey,
    occurredAt,
    orderingTag,
    schemaVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'system_event_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<SystemEventCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('module')) {
      context.handle(
        _moduleMeta,
        module.isAcceptableOrUnknown(data['module']!, _moduleMeta),
      );
    } else if (isInserting) {
      context.missing(_moduleMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('ordering_tag')) {
      context.handle(
        _orderingTagMeta,
        orderingTag.isAcceptableOrUnknown(
          data['ordering_tag']!,
          _orderingTagMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_orderingTagMeta);
    }
    if (data.containsKey('schema_version')) {
      context.handle(
        _schemaVersionMeta,
        schemaVersion.isAcceptableOrUnknown(
          data['schema_version']!,
          _schemaVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_schemaVersionMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SystemEventCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SystemEventCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      module: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}module'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      orderingTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ordering_tag'],
      )!,
      schemaVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}schema_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SystemEventCacheTable createAlias(String alias) {
    return $SystemEventCacheTable(attachedDatabase, alias);
  }
}

class SystemEventCacheData extends DataClass
    implements Insertable<SystemEventCacheData> {
  final String id;
  final String tenantId;
  final String actorId;
  final String module;
  final String type;
  final String payloadJson;
  final String idempotencyKey;
  final DateTime occurredAt;
  final String orderingTag;
  final int schemaVersion;
  final DateTime updatedAt;
  const SystemEventCacheData({
    required this.id,
    required this.tenantId,
    required this.actorId,
    required this.module,
    required this.type,
    required this.payloadJson,
    required this.idempotencyKey,
    required this.occurredAt,
    required this.orderingTag,
    required this.schemaVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['actor_id'] = Variable<String>(actorId);
    map['module'] = Variable<String>(module);
    map['type'] = Variable<String>(type);
    map['payload_json'] = Variable<String>(payloadJson);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['ordering_tag'] = Variable<String>(orderingTag);
    map['schema_version'] = Variable<int>(schemaVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SystemEventCacheCompanion toCompanion(bool nullToAbsent) {
    return SystemEventCacheCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      actorId: Value(actorId),
      module: Value(module),
      type: Value(type),
      payloadJson: Value(payloadJson),
      idempotencyKey: Value(idempotencyKey),
      occurredAt: Value(occurredAt),
      orderingTag: Value(orderingTag),
      schemaVersion: Value(schemaVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory SystemEventCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SystemEventCacheData(
      id: serializer.fromJson<String>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      actorId: serializer.fromJson<String>(json['actorId']),
      module: serializer.fromJson<String>(json['module']),
      type: serializer.fromJson<String>(json['type']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      orderingTag: serializer.fromJson<String>(json['orderingTag']),
      schemaVersion: serializer.fromJson<int>(json['schemaVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'actorId': serializer.toJson<String>(actorId),
      'module': serializer.toJson<String>(module),
      'type': serializer.toJson<String>(type),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'orderingTag': serializer.toJson<String>(orderingTag),
      'schemaVersion': serializer.toJson<int>(schemaVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SystemEventCacheData copyWith({
    String? id,
    String? tenantId,
    String? actorId,
    String? module,
    String? type,
    String? payloadJson,
    String? idempotencyKey,
    DateTime? occurredAt,
    String? orderingTag,
    int? schemaVersion,
    DateTime? updatedAt,
  }) => SystemEventCacheData(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    actorId: actorId ?? this.actorId,
    module: module ?? this.module,
    type: type ?? this.type,
    payloadJson: payloadJson ?? this.payloadJson,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    occurredAt: occurredAt ?? this.occurredAt,
    orderingTag: orderingTag ?? this.orderingTag,
    schemaVersion: schemaVersion ?? this.schemaVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SystemEventCacheData copyWithCompanion(SystemEventCacheCompanion data) {
    return SystemEventCacheData(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      module: data.module.present ? data.module.value : this.module,
      type: data.type.present ? data.type.value : this.type,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      orderingTag: data.orderingTag.present
          ? data.orderingTag.value
          : this.orderingTag,
      schemaVersion: data.schemaVersion.present
          ? data.schemaVersion.value
          : this.schemaVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SystemEventCacheData(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('actorId: $actorId, ')
          ..write('module: $module, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('orderingTag: $orderingTag, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    actorId,
    module,
    type,
    payloadJson,
    idempotencyKey,
    occurredAt,
    orderingTag,
    schemaVersion,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SystemEventCacheData &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.actorId == this.actorId &&
          other.module == this.module &&
          other.type == this.type &&
          other.payloadJson == this.payloadJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.occurredAt == this.occurredAt &&
          other.orderingTag == this.orderingTag &&
          other.schemaVersion == this.schemaVersion &&
          other.updatedAt == this.updatedAt);
}

class SystemEventCacheCompanion extends UpdateCompanion<SystemEventCacheData> {
  final Value<String> id;
  final Value<String> tenantId;
  final Value<String> actorId;
  final Value<String> module;
  final Value<String> type;
  final Value<String> payloadJson;
  final Value<String> idempotencyKey;
  final Value<DateTime> occurredAt;
  final Value<String> orderingTag;
  final Value<int> schemaVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SystemEventCacheCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.module = const Value.absent(),
    this.type = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.orderingTag = const Value.absent(),
    this.schemaVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SystemEventCacheCompanion.insert({
    required String id,
    required String tenantId,
    required String actorId,
    required String module,
    required String type,
    required String payloadJson,
    required String idempotencyKey,
    required DateTime occurredAt,
    required String orderingTag,
    required int schemaVersion,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tenantId = Value(tenantId),
       actorId = Value(actorId),
       module = Value(module),
       type = Value(type),
       payloadJson = Value(payloadJson),
       idempotencyKey = Value(idempotencyKey),
       occurredAt = Value(occurredAt),
       orderingTag = Value(orderingTag),
       schemaVersion = Value(schemaVersion),
       updatedAt = Value(updatedAt);
  static Insertable<SystemEventCacheData> custom({
    Expression<String>? id,
    Expression<String>? tenantId,
    Expression<String>? actorId,
    Expression<String>? module,
    Expression<String>? type,
    Expression<String>? payloadJson,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? occurredAt,
    Expression<String>? orderingTag,
    Expression<int>? schemaVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (actorId != null) 'actor_id': actorId,
      if (module != null) 'module': module,
      if (type != null) 'type': type,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (orderingTag != null) 'ordering_tag': orderingTag,
      if (schemaVersion != null) 'schema_version': schemaVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SystemEventCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? tenantId,
    Value<String>? actorId,
    Value<String>? module,
    Value<String>? type,
    Value<String>? payloadJson,
    Value<String>? idempotencyKey,
    Value<DateTime>? occurredAt,
    Value<String>? orderingTag,
    Value<int>? schemaVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SystemEventCacheCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      actorId: actorId ?? this.actorId,
      module: module ?? this.module,
      type: type ?? this.type,
      payloadJson: payloadJson ?? this.payloadJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      occurredAt: occurredAt ?? this.occurredAt,
      orderingTag: orderingTag ?? this.orderingTag,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (module.present) {
      map['module'] = Variable<String>(module.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (orderingTag.present) {
      map['ordering_tag'] = Variable<String>(orderingTag.value);
    }
    if (schemaVersion.present) {
      map['schema_version'] = Variable<int>(schemaVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SystemEventCacheCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('actorId: $actorId, ')
          ..write('module: $module, ')
          ..write('type: $type, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('orderingTag: $orderingTag, ')
          ..write('schemaVersion: $schemaVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EventDeliveryCacheTable extends EventDeliveryCache
    with TableInfo<$EventDeliveryCacheTable, EventDeliveryCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EventDeliveryCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _consumerMeta = const VerificationMeta(
    'consumer',
  );
  @override
  late final GeneratedColumn<String> consumer = GeneratedColumn<String>(
    'consumer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EventDeliveryStatus, String>
  status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EventDeliveryStatus>(
        $EventDeliveryCacheTable.$converterstatus,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventId,
    consumer,
    attempt,
    status,
    lastError,
    nextAttemptAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'event_delivery_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<EventDeliveryCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('consumer')) {
      context.handle(
        _consumerMeta,
        consumer.isAcceptableOrUnknown(data['consumer']!, _consumerMeta),
      );
    } else if (isInserting) {
      context.missing(_consumerMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EventDeliveryCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EventDeliveryCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      consumer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}consumer'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      status: $EventDeliveryCacheTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EventDeliveryCacheTable createAlias(String alias) {
    return $EventDeliveryCacheTable(attachedDatabase, alias);
  }

  static TypeConverter<EventDeliveryStatus, String> $converterstatus =
      const EventDeliveryStatusConverter();
}

class EventDeliveryCacheData extends DataClass
    implements Insertable<EventDeliveryCacheData> {
  final String id;
  final String eventId;
  final String consumer;
  final int attempt;
  final EventDeliveryStatus status;
  final String? lastError;
  final DateTime? nextAttemptAt;
  final DateTime updatedAt;
  const EventDeliveryCacheData({
    required this.id,
    required this.eventId,
    required this.consumer,
    required this.attempt,
    required this.status,
    this.lastError,
    this.nextAttemptAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_id'] = Variable<String>(eventId);
    map['consumer'] = Variable<String>(consumer);
    map['attempt'] = Variable<int>(attempt);
    {
      map['status'] = Variable<String>(
        $EventDeliveryCacheTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EventDeliveryCacheCompanion toCompanion(bool nullToAbsent) {
    return EventDeliveryCacheCompanion(
      id: Value(id),
      eventId: Value(eventId),
      consumer: Value(consumer),
      attempt: Value(attempt),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EventDeliveryCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EventDeliveryCacheData(
      id: serializer.fromJson<String>(json['id']),
      eventId: serializer.fromJson<String>(json['eventId']),
      consumer: serializer.fromJson<String>(json['consumer']),
      attempt: serializer.fromJson<int>(json['attempt']),
      status: serializer.fromJson<EventDeliveryStatus>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventId': serializer.toJson<String>(eventId),
      'consumer': serializer.toJson<String>(consumer),
      'attempt': serializer.toJson<int>(attempt),
      'status': serializer.toJson<EventDeliveryStatus>(status),
      'lastError': serializer.toJson<String?>(lastError),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EventDeliveryCacheData copyWith({
    String? id,
    String? eventId,
    String? consumer,
    int? attempt,
    EventDeliveryStatus? status,
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    DateTime? updatedAt,
  }) => EventDeliveryCacheData(
    id: id ?? this.id,
    eventId: eventId ?? this.eventId,
    consumer: consumer ?? this.consumer,
    attempt: attempt ?? this.attempt,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EventDeliveryCacheData copyWithCompanion(EventDeliveryCacheCompanion data) {
    return EventDeliveryCacheData(
      id: data.id.present ? data.id.value : this.id,
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      consumer: data.consumer.present ? data.consumer.value : this.consumer,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EventDeliveryCacheData(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('consumer: $consumer, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    eventId,
    consumer,
    attempt,
    status,
    lastError,
    nextAttemptAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EventDeliveryCacheData &&
          other.id == this.id &&
          other.eventId == this.eventId &&
          other.consumer == this.consumer &&
          other.attempt == this.attempt &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.updatedAt == this.updatedAt);
}

class EventDeliveryCacheCompanion
    extends UpdateCompanion<EventDeliveryCacheData> {
  final Value<String> id;
  final Value<String> eventId;
  final Value<String> consumer;
  final Value<int> attempt;
  final Value<EventDeliveryStatus> status;
  final Value<String?> lastError;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EventDeliveryCacheCompanion({
    this.id = const Value.absent(),
    this.eventId = const Value.absent(),
    this.consumer = const Value.absent(),
    this.attempt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EventDeliveryCacheCompanion.insert({
    required String id,
    required String eventId,
    required String consumer,
    required int attempt,
    required EventDeliveryStatus status,
    this.lastError = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventId = Value(eventId),
       consumer = Value(consumer),
       attempt = Value(attempt),
       status = Value(status),
       updatedAt = Value(updatedAt);
  static Insertable<EventDeliveryCacheData> custom({
    Expression<String>? id,
    Expression<String>? eventId,
    Expression<String>? consumer,
    Expression<int>? attempt,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventId != null) 'event_id': eventId,
      if (consumer != null) 'consumer': consumer,
      if (attempt != null) 'attempt': attempt,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EventDeliveryCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? eventId,
    Value<String>? consumer,
    Value<int>? attempt,
    Value<EventDeliveryStatus>? status,
    Value<String?>? lastError,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EventDeliveryCacheCompanion(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      consumer: consumer ?? this.consumer,
      attempt: attempt ?? this.attempt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (consumer.present) {
      map['consumer'] = Variable<String>(consumer.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $EventDeliveryCacheTable.$converterstatus.toSql(status.value),
      );
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EventDeliveryCacheCompanion(')
          ..write('id: $id, ')
          ..write('eventId: $eventId, ')
          ..write('consumer: $consumer, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfileCacheTable extends ProfileCache
    with TableInfo<$ProfileCacheTable, ProfileCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeFamilyIdMeta = const VerificationMeta(
    'activeFamilyId',
  );
  @override
  late final GeneratedColumn<String> activeFamilyId = GeneratedColumn<String>(
    'active_family_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    activeFamilyId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('active_family_id')) {
      context.handle(
        _activeFamilyIdMeta,
        activeFamilyId.isAcceptableOrUnknown(
          data['active_family_id']!,
          _activeFamilyIdMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      activeFamilyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}active_family_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProfileCacheTable createAlias(String alias) {
    return $ProfileCacheTable(attachedDatabase, alias);
  }
}

class ProfileCacheData extends DataClass
    implements Insertable<ProfileCacheData> {
  final String id;
  final String displayName;
  final String? activeFamilyId;
  final DateTime updatedAt;
  const ProfileCacheData({
    required this.id,
    required this.displayName,
    this.activeFamilyId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || activeFamilyId != null) {
      map['active_family_id'] = Variable<String>(activeFamilyId);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfileCacheCompanion toCompanion(bool nullToAbsent) {
    return ProfileCacheCompanion(
      id: Value(id),
      displayName: Value(displayName),
      activeFamilyId: activeFamilyId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeFamilyId),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileCacheData(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      activeFamilyId: serializer.fromJson<String?>(json['activeFamilyId']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'displayName': serializer.toJson<String>(displayName),
      'activeFamilyId': serializer.toJson<String?>(activeFamilyId),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileCacheData copyWith({
    String? id,
    String? displayName,
    Value<String?> activeFamilyId = const Value.absent(),
    DateTime? updatedAt,
  }) => ProfileCacheData(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    activeFamilyId: activeFamilyId.present
        ? activeFamilyId.value
        : this.activeFamilyId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileCacheData copyWithCompanion(ProfileCacheCompanion data) {
    return ProfileCacheData(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      activeFamilyId: data.activeFamilyId.present
          ? data.activeFamilyId.value
          : this.activeFamilyId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCacheData(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('activeFamilyId: $activeFamilyId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, activeFamilyId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileCacheData &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.activeFamilyId == this.activeFamilyId &&
          other.updatedAt == this.updatedAt);
}

class ProfileCacheCompanion extends UpdateCompanion<ProfileCacheData> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> activeFamilyId;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ProfileCacheCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.activeFamilyId = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileCacheCompanion.insert({
    required String id,
    required String displayName,
    this.activeFamilyId = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       updatedAt = Value(updatedAt);
  static Insertable<ProfileCacheData> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? activeFamilyId,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (activeFamilyId != null) 'active_family_id': activeFamilyId,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? activeFamilyId,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProfileCacheCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      activeFamilyId: activeFamilyId ?? this.activeFamilyId,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (activeFamilyId.present) {
      map['active_family_id'] = Variable<String>(activeFamilyId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCacheCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('activeFamilyId: $activeFamilyId, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FamilyCacheTable extends FamilyCache
    with TableInfo<$FamilyCacheTable, FamilyCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FamilyCacheTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'family_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<FamilyCacheData> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FamilyCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FamilyCacheData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FamilyCacheTable createAlias(String alias) {
    return $FamilyCacheTable(attachedDatabase, alias);
  }
}

class FamilyCacheData extends DataClass implements Insertable<FamilyCacheData> {
  final String id;
  final String name;
  final DateTime updatedAt;
  const FamilyCacheData({
    required this.id,
    required this.name,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FamilyCacheCompanion toCompanion(bool nullToAbsent) {
    return FamilyCacheCompanion(
      id: Value(id),
      name: Value(name),
      updatedAt: Value(updatedAt),
    );
  }

  factory FamilyCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FamilyCacheData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FamilyCacheData copyWith({String? id, String? name, DateTime? updatedAt}) =>
      FamilyCacheData(
        id: id ?? this.id,
        name: name ?? this.name,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FamilyCacheData copyWithCompanion(FamilyCacheCompanion data) {
    return FamilyCacheData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FamilyCacheData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FamilyCacheData &&
          other.id == this.id &&
          other.name == this.name &&
          other.updatedAt == this.updatedAt);
}

class FamilyCacheCompanion extends UpdateCompanion<FamilyCacheData> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FamilyCacheCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FamilyCacheCompanion.insert({
    required String id,
    required String name,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       updatedAt = Value(updatedAt);
  static Insertable<FamilyCacheData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FamilyCacheCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FamilyCacheCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FamilyCacheCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MembershipCacheTable extends MembershipCache
    with TableInfo<$MembershipCacheTable, MembershipCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MembershipCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _joinedAtMeta = const VerificationMeta(
    'joinedAt',
  );
  @override
  late final GeneratedColumn<DateTime> joinedAt = GeneratedColumn<DateTime>(
    'joined_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    familyId,
    userId,
    role,
    joinedAt,
    removedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'membership_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<MembershipCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('joined_at')) {
      context.handle(
        _joinedAtMeta,
        joinedAt.isAcceptableOrUnknown(data['joined_at']!, _joinedAtMeta),
      );
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {familyId, userId};
  @override
  MembershipCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MembershipCacheData(
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      joinedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}joined_at'],
      ),
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MembershipCacheTable createAlias(String alias) {
    return $MembershipCacheTable(attachedDatabase, alias);
  }
}

class MembershipCacheData extends DataClass
    implements Insertable<MembershipCacheData> {
  final String familyId;
  final String userId;
  final String role;
  final DateTime? joinedAt;
  final DateTime? removedAt;
  final DateTime updatedAt;
  const MembershipCacheData({
    required this.familyId,
    required this.userId,
    required this.role,
    this.joinedAt,
    this.removedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['family_id'] = Variable<String>(familyId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || joinedAt != null) {
      map['joined_at'] = Variable<DateTime>(joinedAt);
    }
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MembershipCacheCompanion toCompanion(bool nullToAbsent) {
    return MembershipCacheCompanion(
      familyId: Value(familyId),
      userId: Value(userId),
      role: Value(role),
      joinedAt: joinedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(joinedAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MembershipCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MembershipCacheData(
      familyId: serializer.fromJson<String>(json['familyId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
      joinedAt: serializer.fromJson<DateTime?>(json['joinedAt']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'familyId': serializer.toJson<String>(familyId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
      'joinedAt': serializer.toJson<DateTime?>(joinedAt),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MembershipCacheData copyWith({
    String? familyId,
    String? userId,
    String? role,
    Value<DateTime?> joinedAt = const Value.absent(),
    Value<DateTime?> removedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => MembershipCacheData(
    familyId: familyId ?? this.familyId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
    joinedAt: joinedAt.present ? joinedAt.value : this.joinedAt,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MembershipCacheData copyWithCompanion(MembershipCacheCompanion data) {
    return MembershipCacheData(
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
      joinedAt: data.joinedAt.present ? data.joinedAt.value : this.joinedAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MembershipCacheData(')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(familyId, userId, role, joinedAt, removedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MembershipCacheData &&
          other.familyId == this.familyId &&
          other.userId == this.userId &&
          other.role == this.role &&
          other.joinedAt == this.joinedAt &&
          other.removedAt == this.removedAt &&
          other.updatedAt == this.updatedAt);
}

class MembershipCacheCompanion extends UpdateCompanion<MembershipCacheData> {
  final Value<String> familyId;
  final Value<String> userId;
  final Value<String> role;
  final Value<DateTime?> joinedAt;
  final Value<DateTime?> removedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MembershipCacheCompanion({
    this.familyId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.joinedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MembershipCacheCompanion.insert({
    required String familyId,
    required String userId,
    required String role,
    this.joinedAt = const Value.absent(),
    this.removedAt = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : familyId = Value(familyId),
       userId = Value(userId),
       role = Value(role),
       updatedAt = Value(updatedAt);
  static Insertable<MembershipCacheData> custom({
    Expression<String>? familyId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<DateTime>? joinedAt,
    Expression<DateTime>? removedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (familyId != null) 'family_id': familyId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (joinedAt != null) 'joined_at': joinedAt,
      if (removedAt != null) 'removed_at': removedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MembershipCacheCompanion copyWith({
    Value<String>? familyId,
    Value<String>? userId,
    Value<String>? role,
    Value<DateTime?>? joinedAt,
    Value<DateTime?>? removedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MembershipCacheCompanion(
      familyId: familyId ?? this.familyId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      removedAt: removedAt ?? this.removedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (joinedAt.present) {
      map['joined_at'] = Variable<DateTime>(joinedAt.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MembershipCacheCompanion(')
          ..write('familyId: $familyId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('joinedAt: $joinedAt, ')
          ..write('removedAt: $removedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingWritesTable extends PendingWrites
    with TableInfo<$PendingWritesTable, PendingWrite> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingWritesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _tenantIdMeta = const VerificationMeta(
    'tenantId',
  );
  @override
  late final GeneratedColumn<String> tenantId = GeneratedColumn<String>(
    'tenant_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actorIdMeta = const VerificationMeta(
    'actorId',
  );
  @override
  late final GeneratedColumn<String> actorId = GeneratedColumn<String>(
    'actor_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTableMeta = const VerificationMeta(
    'targetTable',
  );
  @override
  late final GeneratedColumn<String> targetTable = GeneratedColumn<String>(
    'target_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<Uint8List> payload = GeneratedColumn<Uint8List>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptMeta = const VerificationMeta(
    'attempt',
  );
  @override
  late final GeneratedColumn<int> attempt = GeneratedColumn<int>(
    'attempt',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tenantId,
    actorId,
    targetTable,
    operation,
    payload,
    idempotencyKey,
    attempt,
    status,
    lastError,
    createdAt,
    nextAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_writes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingWrite> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tenant_id')) {
      context.handle(
        _tenantIdMeta,
        tenantId.isAcceptableOrUnknown(data['tenant_id']!, _tenantIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tenantIdMeta);
    }
    if (data.containsKey('actor_id')) {
      context.handle(
        _actorIdMeta,
        actorId.isAcceptableOrUnknown(data['actor_id']!, _actorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_actorIdMeta);
    }
    if (data.containsKey('target_table')) {
      context.handle(
        _targetTableMeta,
        targetTable.isAcceptableOrUnknown(
          data['target_table']!,
          _targetTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetTableMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idempotencyKeyMeta);
    }
    if (data.containsKey('attempt')) {
      context.handle(
        _attemptMeta,
        attempt.isAcceptableOrUnknown(data['attempt']!, _attemptMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
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
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingWrite map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingWrite(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tenantId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tenant_id'],
      )!,
      actorId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actor_id'],
      )!,
      targetTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_table'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}payload'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      )!,
      attempt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
    );
  }

  @override
  $PendingWritesTable createAlias(String alias) {
    return $PendingWritesTable(attachedDatabase, alias);
  }
}

class PendingWrite extends DataClass implements Insertable<PendingWrite> {
  final int id;
  final String tenantId;
  final String actorId;
  final String targetTable;
  final String operation;
  final Uint8List payload;
  final String idempotencyKey;
  final int attempt;
  final String status;
  final String? lastError;
  final DateTime createdAt;
  final DateTime? nextAttemptAt;
  const PendingWrite({
    required this.id,
    required this.tenantId,
    required this.actorId,
    required this.targetTable,
    required this.operation,
    required this.payload,
    required this.idempotencyKey,
    required this.attempt,
    required this.status,
    this.lastError,
    required this.createdAt,
    this.nextAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tenant_id'] = Variable<String>(tenantId);
    map['actor_id'] = Variable<String>(actorId);
    map['target_table'] = Variable<String>(targetTable);
    map['operation'] = Variable<String>(operation);
    map['payload'] = Variable<Uint8List>(payload);
    map['idempotency_key'] = Variable<String>(idempotencyKey);
    map['attempt'] = Variable<int>(attempt);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    return map;
  }

  PendingWritesCompanion toCompanion(bool nullToAbsent) {
    return PendingWritesCompanion(
      id: Value(id),
      tenantId: Value(tenantId),
      actorId: Value(actorId),
      targetTable: Value(targetTable),
      operation: Value(operation),
      payload: Value(payload),
      idempotencyKey: Value(idempotencyKey),
      attempt: Value(attempt),
      status: Value(status),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
    );
  }

  factory PendingWrite.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingWrite(
      id: serializer.fromJson<int>(json['id']),
      tenantId: serializer.fromJson<String>(json['tenantId']),
      actorId: serializer.fromJson<String>(json['actorId']),
      targetTable: serializer.fromJson<String>(json['targetTable']),
      operation: serializer.fromJson<String>(json['operation']),
      payload: serializer.fromJson<Uint8List>(json['payload']),
      idempotencyKey: serializer.fromJson<String>(json['idempotencyKey']),
      attempt: serializer.fromJson<int>(json['attempt']),
      status: serializer.fromJson<String>(json['status']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tenantId': serializer.toJson<String>(tenantId),
      'actorId': serializer.toJson<String>(actorId),
      'targetTable': serializer.toJson<String>(targetTable),
      'operation': serializer.toJson<String>(operation),
      'payload': serializer.toJson<Uint8List>(payload),
      'idempotencyKey': serializer.toJson<String>(idempotencyKey),
      'attempt': serializer.toJson<int>(attempt),
      'status': serializer.toJson<String>(status),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
    };
  }

  PendingWrite copyWith({
    int? id,
    String? tenantId,
    String? actorId,
    String? targetTable,
    String? operation,
    Uint8List? payload,
    String? idempotencyKey,
    int? attempt,
    String? status,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
  }) => PendingWrite(
    id: id ?? this.id,
    tenantId: tenantId ?? this.tenantId,
    actorId: actorId ?? this.actorId,
    targetTable: targetTable ?? this.targetTable,
    operation: operation ?? this.operation,
    payload: payload ?? this.payload,
    idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    attempt: attempt ?? this.attempt,
    status: status ?? this.status,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
  );
  PendingWrite copyWithCompanion(PendingWritesCompanion data) {
    return PendingWrite(
      id: data.id.present ? data.id.value : this.id,
      tenantId: data.tenantId.present ? data.tenantId.value : this.tenantId,
      actorId: data.actorId.present ? data.actorId.value : this.actorId,
      targetTable: data.targetTable.present
          ? data.targetTable.value
          : this.targetTable,
      operation: data.operation.present ? data.operation.value : this.operation,
      payload: data.payload.present ? data.payload.value : this.payload,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      attempt: data.attempt.present ? data.attempt.value : this.attempt,
      status: data.status.present ? data.status.value : this.status,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingWrite(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('actorId: $actorId, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tenantId,
    actorId,
    targetTable,
    operation,
    $driftBlobEquality.hash(payload),
    idempotencyKey,
    attempt,
    status,
    lastError,
    createdAt,
    nextAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingWrite &&
          other.id == this.id &&
          other.tenantId == this.tenantId &&
          other.actorId == this.actorId &&
          other.targetTable == this.targetTable &&
          other.operation == this.operation &&
          $driftBlobEquality.equals(other.payload, this.payload) &&
          other.idempotencyKey == this.idempotencyKey &&
          other.attempt == this.attempt &&
          other.status == this.status &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.nextAttemptAt == this.nextAttemptAt);
}

class PendingWritesCompanion extends UpdateCompanion<PendingWrite> {
  final Value<int> id;
  final Value<String> tenantId;
  final Value<String> actorId;
  final Value<String> targetTable;
  final Value<String> operation;
  final Value<Uint8List> payload;
  final Value<String> idempotencyKey;
  final Value<int> attempt;
  final Value<String> status;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime?> nextAttemptAt;
  const PendingWritesCompanion({
    this.id = const Value.absent(),
    this.tenantId = const Value.absent(),
    this.actorId = const Value.absent(),
    this.targetTable = const Value.absent(),
    this.operation = const Value.absent(),
    this.payload = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.attempt = const Value.absent(),
    this.status = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
  });
  PendingWritesCompanion.insert({
    this.id = const Value.absent(),
    required String tenantId,
    required String actorId,
    required String targetTable,
    required String operation,
    required Uint8List payload,
    required String idempotencyKey,
    this.attempt = const Value.absent(),
    required String status,
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    this.nextAttemptAt = const Value.absent(),
  }) : tenantId = Value(tenantId),
       actorId = Value(actorId),
       targetTable = Value(targetTable),
       operation = Value(operation),
       payload = Value(payload),
       idempotencyKey = Value(idempotencyKey),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<PendingWrite> custom({
    Expression<int>? id,
    Expression<String>? tenantId,
    Expression<String>? actorId,
    Expression<String>? targetTable,
    Expression<String>? operation,
    Expression<Uint8List>? payload,
    Expression<String>? idempotencyKey,
    Expression<int>? attempt,
    Expression<String>? status,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? nextAttemptAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tenantId != null) 'tenant_id': tenantId,
      if (actorId != null) 'actor_id': actorId,
      if (targetTable != null) 'target_table': targetTable,
      if (operation != null) 'operation': operation,
      if (payload != null) 'payload': payload,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (attempt != null) 'attempt': attempt,
      if (status != null) 'status': status,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
    });
  }

  PendingWritesCompanion copyWith({
    Value<int>? id,
    Value<String>? tenantId,
    Value<String>? actorId,
    Value<String>? targetTable,
    Value<String>? operation,
    Value<Uint8List>? payload,
    Value<String>? idempotencyKey,
    Value<int>? attempt,
    Value<String>? status,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime?>? nextAttemptAt,
  }) {
    return PendingWritesCompanion(
      id: id ?? this.id,
      tenantId: tenantId ?? this.tenantId,
      actorId: actorId ?? this.actorId,
      targetTable: targetTable ?? this.targetTable,
      operation: operation ?? this.operation,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      attempt: attempt ?? this.attempt,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tenantId.present) {
      map['tenant_id'] = Variable<String>(tenantId.value);
    }
    if (actorId.present) {
      map['actor_id'] = Variable<String>(actorId.value);
    }
    if (targetTable.present) {
      map['target_table'] = Variable<String>(targetTable.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (payload.present) {
      map['payload'] = Variable<Uint8List>(payload.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (attempt.present) {
      map['attempt'] = Variable<int>(attempt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingWritesCompanion(')
          ..write('id: $id, ')
          ..write('tenantId: $tenantId, ')
          ..write('actorId: $actorId, ')
          ..write('targetTable: $targetTable, ')
          ..write('operation: $operation, ')
          ..write('payload: $payload, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('attempt: $attempt, ')
          ..write('status: $status, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('nextAttemptAt: $nextAttemptAt')
          ..write(')'))
        .toString();
  }
}

class $DashboardLayoutCacheTable extends DashboardLayoutCache
    with TableInfo<$DashboardLayoutCacheTable, DashboardLayoutCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DashboardLayoutCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _familyIdMeta = const VerificationMeta(
    'familyId',
  );
  @override
  late final GeneratedColumn<String> familyId = GeneratedColumn<String>(
    'family_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memberScopeMeta = const VerificationMeta(
    'memberScope',
  );
  @override
  late final GeneratedColumn<String> memberScope = GeneratedColumn<String>(
    'member_scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _layoutVersionMeta = const VerificationMeta(
    'layoutVersion',
  );
  @override
  late final GeneratedColumn<int> layoutVersion = GeneratedColumn<int>(
    'layout_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    familyId,
    memberScope,
    payloadJson,
    layoutVersion,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dashboard_layout_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<DashboardLayoutCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('family_id')) {
      context.handle(
        _familyIdMeta,
        familyId.isAcceptableOrUnknown(data['family_id']!, _familyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_familyIdMeta);
    }
    if (data.containsKey('member_scope')) {
      context.handle(
        _memberScopeMeta,
        memberScope.isAcceptableOrUnknown(
          data['member_scope']!,
          _memberScopeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_memberScopeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('layout_version')) {
      context.handle(
        _layoutVersionMeta,
        layoutVersion.isAcceptableOrUnknown(
          data['layout_version']!,
          _layoutVersionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {familyId, memberScope};
  @override
  DashboardLayoutCacheData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DashboardLayoutCacheData(
      familyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family_id'],
      )!,
      memberScope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}member_scope'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      layoutVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}layout_version'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DashboardLayoutCacheTable createAlias(String alias) {
    return $DashboardLayoutCacheTable(attachedDatabase, alias);
  }
}

class DashboardLayoutCacheData extends DataClass
    implements Insertable<DashboardLayoutCacheData> {
  final String familyId;
  final String memberScope;
  final String payloadJson;
  final int layoutVersion;
  final DateTime updatedAt;
  const DashboardLayoutCacheData({
    required this.familyId,
    required this.memberScope,
    required this.payloadJson,
    required this.layoutVersion,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['family_id'] = Variable<String>(familyId);
    map['member_scope'] = Variable<String>(memberScope);
    map['payload_json'] = Variable<String>(payloadJson);
    map['layout_version'] = Variable<int>(layoutVersion);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DashboardLayoutCacheCompanion toCompanion(bool nullToAbsent) {
    return DashboardLayoutCacheCompanion(
      familyId: Value(familyId),
      memberScope: Value(memberScope),
      payloadJson: Value(payloadJson),
      layoutVersion: Value(layoutVersion),
      updatedAt: Value(updatedAt),
    );
  }

  factory DashboardLayoutCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DashboardLayoutCacheData(
      familyId: serializer.fromJson<String>(json['familyId']),
      memberScope: serializer.fromJson<String>(json['memberScope']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      layoutVersion: serializer.fromJson<int>(json['layoutVersion']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'familyId': serializer.toJson<String>(familyId),
      'memberScope': serializer.toJson<String>(memberScope),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'layoutVersion': serializer.toJson<int>(layoutVersion),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DashboardLayoutCacheData copyWith({
    String? familyId,
    String? memberScope,
    String? payloadJson,
    int? layoutVersion,
    DateTime? updatedAt,
  }) => DashboardLayoutCacheData(
    familyId: familyId ?? this.familyId,
    memberScope: memberScope ?? this.memberScope,
    payloadJson: payloadJson ?? this.payloadJson,
    layoutVersion: layoutVersion ?? this.layoutVersion,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DashboardLayoutCacheData copyWithCompanion(
    DashboardLayoutCacheCompanion data,
  ) {
    return DashboardLayoutCacheData(
      familyId: data.familyId.present ? data.familyId.value : this.familyId,
      memberScope: data.memberScope.present
          ? data.memberScope.value
          : this.memberScope,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      layoutVersion: data.layoutVersion.present
          ? data.layoutVersion.value
          : this.layoutVersion,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DashboardLayoutCacheData(')
          ..write('familyId: $familyId, ')
          ..write('memberScope: $memberScope, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('layoutVersion: $layoutVersion, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(familyId, memberScope, payloadJson, layoutVersion, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DashboardLayoutCacheData &&
          other.familyId == this.familyId &&
          other.memberScope == this.memberScope &&
          other.payloadJson == this.payloadJson &&
          other.layoutVersion == this.layoutVersion &&
          other.updatedAt == this.updatedAt);
}

class DashboardLayoutCacheCompanion
    extends UpdateCompanion<DashboardLayoutCacheData> {
  final Value<String> familyId;
  final Value<String> memberScope;
  final Value<String> payloadJson;
  final Value<int> layoutVersion;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DashboardLayoutCacheCompanion({
    this.familyId = const Value.absent(),
    this.memberScope = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.layoutVersion = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DashboardLayoutCacheCompanion.insert({
    required String familyId,
    required String memberScope,
    required String payloadJson,
    this.layoutVersion = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : familyId = Value(familyId),
       memberScope = Value(memberScope),
       payloadJson = Value(payloadJson),
       updatedAt = Value(updatedAt);
  static Insertable<DashboardLayoutCacheData> custom({
    Expression<String>? familyId,
    Expression<String>? memberScope,
    Expression<String>? payloadJson,
    Expression<int>? layoutVersion,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (familyId != null) 'family_id': familyId,
      if (memberScope != null) 'member_scope': memberScope,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (layoutVersion != null) 'layout_version': layoutVersion,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DashboardLayoutCacheCompanion copyWith({
    Value<String>? familyId,
    Value<String>? memberScope,
    Value<String>? payloadJson,
    Value<int>? layoutVersion,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DashboardLayoutCacheCompanion(
      familyId: familyId ?? this.familyId,
      memberScope: memberScope ?? this.memberScope,
      payloadJson: payloadJson ?? this.payloadJson,
      layoutVersion: layoutVersion ?? this.layoutVersion,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (familyId.present) {
      map['family_id'] = Variable<String>(familyId.value);
    }
    if (memberScope.present) {
      map['member_scope'] = Variable<String>(memberScope.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (layoutVersion.present) {
      map['layout_version'] = Variable<int>(layoutVersion.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DashboardLayoutCacheCompanion(')
          ..write('familyId: $familyId, ')
          ..write('memberScope: $memberScope, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('layoutVersion: $layoutVersion, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AutolifeDatabase extends GeneratedDatabase {
  _$AutolifeDatabase(QueryExecutor e) : super(e);
  $AutolifeDatabaseManager get managers => $AutolifeDatabaseManager(this);
  late final $SystemEventCacheTable systemEventCache = $SystemEventCacheTable(
    this,
  );
  late final $EventDeliveryCacheTable eventDeliveryCache =
      $EventDeliveryCacheTable(this);
  late final $ProfileCacheTable profileCache = $ProfileCacheTable(this);
  late final $FamilyCacheTable familyCache = $FamilyCacheTable(this);
  late final $MembershipCacheTable membershipCache = $MembershipCacheTable(
    this,
  );
  late final $PendingWritesTable pendingWrites = $PendingWritesTable(this);
  late final $DashboardLayoutCacheTable dashboardLayoutCache =
      $DashboardLayoutCacheTable(this);
  late final Index pendingWriteTenantIdempotency = Index(
    'pending_write_tenant_idempotency',
    'CREATE UNIQUE INDEX pending_write_tenant_idempotency ON pending_writes (tenant_id, idempotency_key)',
  );
  late final Index dashboardLayoutFamilyMember = Index(
    'dashboard_layout_family_member',
    'CREATE UNIQUE INDEX dashboard_layout_family_member ON dashboard_layout_cache (family_id, member_scope)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    systemEventCache,
    eventDeliveryCache,
    profileCache,
    familyCache,
    membershipCache,
    pendingWrites,
    dashboardLayoutCache,
    pendingWriteTenantIdempotency,
    dashboardLayoutFamilyMember,
  ];
}

typedef $$SystemEventCacheTableCreateCompanionBuilder =
    SystemEventCacheCompanion Function({
      required String id,
      required String tenantId,
      required String actorId,
      required String module,
      required String type,
      required String payloadJson,
      required String idempotencyKey,
      required DateTime occurredAt,
      required String orderingTag,
      required int schemaVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SystemEventCacheTableUpdateCompanionBuilder =
    SystemEventCacheCompanion Function({
      Value<String> id,
      Value<String> tenantId,
      Value<String> actorId,
      Value<String> module,
      Value<String> type,
      Value<String> payloadJson,
      Value<String> idempotencyKey,
      Value<DateTime> occurredAt,
      Value<String> orderingTag,
      Value<int> schemaVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SystemEventCacheTableFilterComposer
    extends Composer<_$AutolifeDatabase, $SystemEventCacheTable> {
  $$SystemEventCacheTableFilterComposer({
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

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderingTag => $composableBuilder(
    column: $table.orderingTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SystemEventCacheTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $SystemEventCacheTable> {
  $$SystemEventCacheTableOrderingComposer({
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

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get module => $composableBuilder(
    column: $table.module,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderingTag => $composableBuilder(
    column: $table.orderingTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SystemEventCacheTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $SystemEventCacheTable> {
  $$SystemEventCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get module =>
      $composableBuilder(column: $table.module, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderingTag => $composableBuilder(
    column: $table.orderingTag,
    builder: (column) => column,
  );

  GeneratedColumn<int> get schemaVersion => $composableBuilder(
    column: $table.schemaVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SystemEventCacheTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $SystemEventCacheTable,
          SystemEventCacheData,
          $$SystemEventCacheTableFilterComposer,
          $$SystemEventCacheTableOrderingComposer,
          $$SystemEventCacheTableAnnotationComposer,
          $$SystemEventCacheTableCreateCompanionBuilder,
          $$SystemEventCacheTableUpdateCompanionBuilder,
          (
            SystemEventCacheData,
            BaseReferences<
              _$AutolifeDatabase,
              $SystemEventCacheTable,
              SystemEventCacheData
            >,
          ),
          SystemEventCacheData,
          PrefetchHooks Function()
        > {
  $$SystemEventCacheTableTableManager(
    _$AutolifeDatabase db,
    $SystemEventCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SystemEventCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SystemEventCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SystemEventCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> module = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> orderingTag = const Value.absent(),
                Value<int> schemaVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SystemEventCacheCompanion(
                id: id,
                tenantId: tenantId,
                actorId: actorId,
                module: module,
                type: type,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                occurredAt: occurredAt,
                orderingTag: orderingTag,
                schemaVersion: schemaVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tenantId,
                required String actorId,
                required String module,
                required String type,
                required String payloadJson,
                required String idempotencyKey,
                required DateTime occurredAt,
                required String orderingTag,
                required int schemaVersion,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SystemEventCacheCompanion.insert(
                id: id,
                tenantId: tenantId,
                actorId: actorId,
                module: module,
                type: type,
                payloadJson: payloadJson,
                idempotencyKey: idempotencyKey,
                occurredAt: occurredAt,
                orderingTag: orderingTag,
                schemaVersion: schemaVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SystemEventCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $SystemEventCacheTable,
      SystemEventCacheData,
      $$SystemEventCacheTableFilterComposer,
      $$SystemEventCacheTableOrderingComposer,
      $$SystemEventCacheTableAnnotationComposer,
      $$SystemEventCacheTableCreateCompanionBuilder,
      $$SystemEventCacheTableUpdateCompanionBuilder,
      (
        SystemEventCacheData,
        BaseReferences<
          _$AutolifeDatabase,
          $SystemEventCacheTable,
          SystemEventCacheData
        >,
      ),
      SystemEventCacheData,
      PrefetchHooks Function()
    >;
typedef $$EventDeliveryCacheTableCreateCompanionBuilder =
    EventDeliveryCacheCompanion Function({
      required String id,
      required String eventId,
      required String consumer,
      required int attempt,
      required EventDeliveryStatus status,
      Value<String?> lastError,
      Value<DateTime?> nextAttemptAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EventDeliveryCacheTableUpdateCompanionBuilder =
    EventDeliveryCacheCompanion Function({
      Value<String> id,
      Value<String> eventId,
      Value<String> consumer,
      Value<int> attempt,
      Value<EventDeliveryStatus> status,
      Value<String?> lastError,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EventDeliveryCacheTableFilterComposer
    extends Composer<_$AutolifeDatabase, $EventDeliveryCacheTable> {
  $$EventDeliveryCacheTableFilterComposer({
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

  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get consumer => $composableBuilder(
    column: $table.consumer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<
    EventDeliveryStatus,
    EventDeliveryStatus,
    String
  >
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EventDeliveryCacheTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $EventDeliveryCacheTable> {
  $$EventDeliveryCacheTableOrderingComposer({
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

  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get consumer => $composableBuilder(
    column: $table.consumer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EventDeliveryCacheTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $EventDeliveryCacheTable> {
  $$EventDeliveryCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get consumer =>
      $composableBuilder(column: $table.consumer, builder: (column) => column);

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EventDeliveryStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EventDeliveryCacheTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $EventDeliveryCacheTable,
          EventDeliveryCacheData,
          $$EventDeliveryCacheTableFilterComposer,
          $$EventDeliveryCacheTableOrderingComposer,
          $$EventDeliveryCacheTableAnnotationComposer,
          $$EventDeliveryCacheTableCreateCompanionBuilder,
          $$EventDeliveryCacheTableUpdateCompanionBuilder,
          (
            EventDeliveryCacheData,
            BaseReferences<
              _$AutolifeDatabase,
              $EventDeliveryCacheTable,
              EventDeliveryCacheData
            >,
          ),
          EventDeliveryCacheData,
          PrefetchHooks Function()
        > {
  $$EventDeliveryCacheTableTableManager(
    _$AutolifeDatabase db,
    $EventDeliveryCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EventDeliveryCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EventDeliveryCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EventDeliveryCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventId = const Value.absent(),
                Value<String> consumer = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<EventDeliveryStatus> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EventDeliveryCacheCompanion(
                id: id,
                eventId: eventId,
                consumer: consumer,
                attempt: attempt,
                status: status,
                lastError: lastError,
                nextAttemptAt: nextAttemptAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventId,
                required String consumer,
                required int attempt,
                required EventDeliveryStatus status,
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EventDeliveryCacheCompanion.insert(
                id: id,
                eventId: eventId,
                consumer: consumer,
                attempt: attempt,
                status: status,
                lastError: lastError,
                nextAttemptAt: nextAttemptAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EventDeliveryCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $EventDeliveryCacheTable,
      EventDeliveryCacheData,
      $$EventDeliveryCacheTableFilterComposer,
      $$EventDeliveryCacheTableOrderingComposer,
      $$EventDeliveryCacheTableAnnotationComposer,
      $$EventDeliveryCacheTableCreateCompanionBuilder,
      $$EventDeliveryCacheTableUpdateCompanionBuilder,
      (
        EventDeliveryCacheData,
        BaseReferences<
          _$AutolifeDatabase,
          $EventDeliveryCacheTable,
          EventDeliveryCacheData
        >,
      ),
      EventDeliveryCacheData,
      PrefetchHooks Function()
    >;
typedef $$ProfileCacheTableCreateCompanionBuilder =
    ProfileCacheCompanion Function({
      required String id,
      required String displayName,
      Value<String?> activeFamilyId,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ProfileCacheTableUpdateCompanionBuilder =
    ProfileCacheCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String?> activeFamilyId,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ProfileCacheTableFilterComposer
    extends Composer<_$AutolifeDatabase, $ProfileCacheTable> {
  $$ProfileCacheTableFilterComposer({
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

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activeFamilyId => $composableBuilder(
    column: $table.activeFamilyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileCacheTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $ProfileCacheTable> {
  $$ProfileCacheTableOrderingComposer({
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

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeFamilyId => $composableBuilder(
    column: $table.activeFamilyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileCacheTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $ProfileCacheTable> {
  $$ProfileCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activeFamilyId => $composableBuilder(
    column: $table.activeFamilyId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfileCacheTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $ProfileCacheTable,
          ProfileCacheData,
          $$ProfileCacheTableFilterComposer,
          $$ProfileCacheTableOrderingComposer,
          $$ProfileCacheTableAnnotationComposer,
          $$ProfileCacheTableCreateCompanionBuilder,
          $$ProfileCacheTableUpdateCompanionBuilder,
          (
            ProfileCacheData,
            BaseReferences<
              _$AutolifeDatabase,
              $ProfileCacheTable,
              ProfileCacheData
            >,
          ),
          ProfileCacheData,
          PrefetchHooks Function()
        > {
  $$ProfileCacheTableTableManager(
    _$AutolifeDatabase db,
    $ProfileCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> activeFamilyId = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileCacheCompanion(
                id: id,
                displayName: displayName,
                activeFamilyId: activeFamilyId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String?> activeFamilyId = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfileCacheCompanion.insert(
                id: id,
                displayName: displayName,
                activeFamilyId: activeFamilyId,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $ProfileCacheTable,
      ProfileCacheData,
      $$ProfileCacheTableFilterComposer,
      $$ProfileCacheTableOrderingComposer,
      $$ProfileCacheTableAnnotationComposer,
      $$ProfileCacheTableCreateCompanionBuilder,
      $$ProfileCacheTableUpdateCompanionBuilder,
      (
        ProfileCacheData,
        BaseReferences<
          _$AutolifeDatabase,
          $ProfileCacheTable,
          ProfileCacheData
        >,
      ),
      ProfileCacheData,
      PrefetchHooks Function()
    >;
typedef $$FamilyCacheTableCreateCompanionBuilder =
    FamilyCacheCompanion Function({
      required String id,
      required String name,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FamilyCacheTableUpdateCompanionBuilder =
    FamilyCacheCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FamilyCacheTableFilterComposer
    extends Composer<_$AutolifeDatabase, $FamilyCacheTable> {
  $$FamilyCacheTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FamilyCacheTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $FamilyCacheTable> {
  $$FamilyCacheTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FamilyCacheTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $FamilyCacheTable> {
  $$FamilyCacheTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FamilyCacheTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $FamilyCacheTable,
          FamilyCacheData,
          $$FamilyCacheTableFilterComposer,
          $$FamilyCacheTableOrderingComposer,
          $$FamilyCacheTableAnnotationComposer,
          $$FamilyCacheTableCreateCompanionBuilder,
          $$FamilyCacheTableUpdateCompanionBuilder,
          (
            FamilyCacheData,
            BaseReferences<
              _$AutolifeDatabase,
              $FamilyCacheTable,
              FamilyCacheData
            >,
          ),
          FamilyCacheData,
          PrefetchHooks Function()
        > {
  $$FamilyCacheTableTableManager(_$AutolifeDatabase db, $FamilyCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FamilyCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FamilyCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FamilyCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FamilyCacheCompanion(
                id: id,
                name: name,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FamilyCacheCompanion.insert(
                id: id,
                name: name,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FamilyCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $FamilyCacheTable,
      FamilyCacheData,
      $$FamilyCacheTableFilterComposer,
      $$FamilyCacheTableOrderingComposer,
      $$FamilyCacheTableAnnotationComposer,
      $$FamilyCacheTableCreateCompanionBuilder,
      $$FamilyCacheTableUpdateCompanionBuilder,
      (
        FamilyCacheData,
        BaseReferences<_$AutolifeDatabase, $FamilyCacheTable, FamilyCacheData>,
      ),
      FamilyCacheData,
      PrefetchHooks Function()
    >;
typedef $$MembershipCacheTableCreateCompanionBuilder =
    MembershipCacheCompanion Function({
      required String familyId,
      required String userId,
      required String role,
      Value<DateTime?> joinedAt,
      Value<DateTime?> removedAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MembershipCacheTableUpdateCompanionBuilder =
    MembershipCacheCompanion Function({
      Value<String> familyId,
      Value<String> userId,
      Value<String> role,
      Value<DateTime?> joinedAt,
      Value<DateTime?> removedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MembershipCacheTableFilterComposer
    extends Composer<_$AutolifeDatabase, $MembershipCacheTable> {
  $$MembershipCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MembershipCacheTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $MembershipCacheTable> {
  $$MembershipCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get joinedAt => $composableBuilder(
    column: $table.joinedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MembershipCacheTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $MembershipCacheTable> {
  $$MembershipCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get joinedAt =>
      $composableBuilder(column: $table.joinedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MembershipCacheTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $MembershipCacheTable,
          MembershipCacheData,
          $$MembershipCacheTableFilterComposer,
          $$MembershipCacheTableOrderingComposer,
          $$MembershipCacheTableAnnotationComposer,
          $$MembershipCacheTableCreateCompanionBuilder,
          $$MembershipCacheTableUpdateCompanionBuilder,
          (
            MembershipCacheData,
            BaseReferences<
              _$AutolifeDatabase,
              $MembershipCacheTable,
              MembershipCacheData
            >,
          ),
          MembershipCacheData,
          PrefetchHooks Function()
        > {
  $$MembershipCacheTableTableManager(
    _$AutolifeDatabase db,
    $MembershipCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MembershipCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MembershipCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MembershipCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> familyId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MembershipCacheCompanion(
                familyId: familyId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                removedAt: removedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String familyId,
                required String userId,
                required String role,
                Value<DateTime?> joinedAt = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MembershipCacheCompanion.insert(
                familyId: familyId,
                userId: userId,
                role: role,
                joinedAt: joinedAt,
                removedAt: removedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MembershipCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $MembershipCacheTable,
      MembershipCacheData,
      $$MembershipCacheTableFilterComposer,
      $$MembershipCacheTableOrderingComposer,
      $$MembershipCacheTableAnnotationComposer,
      $$MembershipCacheTableCreateCompanionBuilder,
      $$MembershipCacheTableUpdateCompanionBuilder,
      (
        MembershipCacheData,
        BaseReferences<
          _$AutolifeDatabase,
          $MembershipCacheTable,
          MembershipCacheData
        >,
      ),
      MembershipCacheData,
      PrefetchHooks Function()
    >;
typedef $$PendingWritesTableCreateCompanionBuilder =
    PendingWritesCompanion Function({
      Value<int> id,
      required String tenantId,
      required String actorId,
      required String targetTable,
      required String operation,
      required Uint8List payload,
      required String idempotencyKey,
      Value<int> attempt,
      required String status,
      Value<String?> lastError,
      required DateTime createdAt,
      Value<DateTime?> nextAttemptAt,
    });
typedef $$PendingWritesTableUpdateCompanionBuilder =
    PendingWritesCompanion Function({
      Value<int> id,
      Value<String> tenantId,
      Value<String> actorId,
      Value<String> targetTable,
      Value<String> operation,
      Value<Uint8List> payload,
      Value<String> idempotencyKey,
      Value<int> attempt,
      Value<String> status,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime?> nextAttemptAt,
    });

class $$PendingWritesTableFilterComposer
    extends Composer<_$AutolifeDatabase, $PendingWritesTable> {
  $$PendingWritesTableFilterComposer({
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

  ColumnFilters<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingWritesTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $PendingWritesTable> {
  $$PendingWritesTableOrderingComposer({
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

  ColumnOrderings<String> get tenantId => $composableBuilder(
    column: $table.tenantId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actorId => $composableBuilder(
    column: $table.actorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempt => $composableBuilder(
    column: $table.attempt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingWritesTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $PendingWritesTable> {
  $$PendingWritesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tenantId =>
      $composableBuilder(column: $table.tenantId, builder: (column) => column);

  GeneratedColumn<String> get actorId =>
      $composableBuilder(column: $table.actorId, builder: (column) => column);

  GeneratedColumn<String> get targetTable => $composableBuilder(
    column: $table.targetTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<Uint8List> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get attempt =>
      $composableBuilder(column: $table.attempt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );
}

class $$PendingWritesTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $PendingWritesTable,
          PendingWrite,
          $$PendingWritesTableFilterComposer,
          $$PendingWritesTableOrderingComposer,
          $$PendingWritesTableAnnotationComposer,
          $$PendingWritesTableCreateCompanionBuilder,
          $$PendingWritesTableUpdateCompanionBuilder,
          (
            PendingWrite,
            BaseReferences<
              _$AutolifeDatabase,
              $PendingWritesTable,
              PendingWrite
            >,
          ),
          PendingWrite,
          PrefetchHooks Function()
        > {
  $$PendingWritesTableTableManager(
    _$AutolifeDatabase db,
    $PendingWritesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingWritesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingWritesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingWritesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tenantId = const Value.absent(),
                Value<String> actorId = const Value.absent(),
                Value<String> targetTable = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<Uint8List> payload = const Value.absent(),
                Value<String> idempotencyKey = const Value.absent(),
                Value<int> attempt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
              }) => PendingWritesCompanion(
                id: id,
                tenantId: tenantId,
                actorId: actorId,
                targetTable: targetTable,
                operation: operation,
                payload: payload,
                idempotencyKey: idempotencyKey,
                attempt: attempt,
                status: status,
                lastError: lastError,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tenantId,
                required String actorId,
                required String targetTable,
                required String operation,
                required Uint8List payload,
                required String idempotencyKey,
                Value<int> attempt = const Value.absent(),
                required String status,
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> nextAttemptAt = const Value.absent(),
              }) => PendingWritesCompanion.insert(
                id: id,
                tenantId: tenantId,
                actorId: actorId,
                targetTable: targetTable,
                operation: operation,
                payload: payload,
                idempotencyKey: idempotencyKey,
                attempt: attempt,
                status: status,
                lastError: lastError,
                createdAt: createdAt,
                nextAttemptAt: nextAttemptAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingWritesTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $PendingWritesTable,
      PendingWrite,
      $$PendingWritesTableFilterComposer,
      $$PendingWritesTableOrderingComposer,
      $$PendingWritesTableAnnotationComposer,
      $$PendingWritesTableCreateCompanionBuilder,
      $$PendingWritesTableUpdateCompanionBuilder,
      (
        PendingWrite,
        BaseReferences<_$AutolifeDatabase, $PendingWritesTable, PendingWrite>,
      ),
      PendingWrite,
      PrefetchHooks Function()
    >;
typedef $$DashboardLayoutCacheTableCreateCompanionBuilder =
    DashboardLayoutCacheCompanion Function({
      required String familyId,
      required String memberScope,
      required String payloadJson,
      Value<int> layoutVersion,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DashboardLayoutCacheTableUpdateCompanionBuilder =
    DashboardLayoutCacheCompanion Function({
      Value<String> familyId,
      Value<String> memberScope,
      Value<String> payloadJson,
      Value<int> layoutVersion,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$DashboardLayoutCacheTableFilterComposer
    extends Composer<_$AutolifeDatabase, $DashboardLayoutCacheTable> {
  $$DashboardLayoutCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memberScope => $composableBuilder(
    column: $table.memberScope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get layoutVersion => $composableBuilder(
    column: $table.layoutVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DashboardLayoutCacheTableOrderingComposer
    extends Composer<_$AutolifeDatabase, $DashboardLayoutCacheTable> {
  $$DashboardLayoutCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get familyId => $composableBuilder(
    column: $table.familyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memberScope => $composableBuilder(
    column: $table.memberScope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get layoutVersion => $composableBuilder(
    column: $table.layoutVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DashboardLayoutCacheTableAnnotationComposer
    extends Composer<_$AutolifeDatabase, $DashboardLayoutCacheTable> {
  $$DashboardLayoutCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get familyId =>
      $composableBuilder(column: $table.familyId, builder: (column) => column);

  GeneratedColumn<String> get memberScope => $composableBuilder(
    column: $table.memberScope,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get layoutVersion => $composableBuilder(
    column: $table.layoutVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DashboardLayoutCacheTableTableManager
    extends
        RootTableManager<
          _$AutolifeDatabase,
          $DashboardLayoutCacheTable,
          DashboardLayoutCacheData,
          $$DashboardLayoutCacheTableFilterComposer,
          $$DashboardLayoutCacheTableOrderingComposer,
          $$DashboardLayoutCacheTableAnnotationComposer,
          $$DashboardLayoutCacheTableCreateCompanionBuilder,
          $$DashboardLayoutCacheTableUpdateCompanionBuilder,
          (
            DashboardLayoutCacheData,
            BaseReferences<
              _$AutolifeDatabase,
              $DashboardLayoutCacheTable,
              DashboardLayoutCacheData
            >,
          ),
          DashboardLayoutCacheData,
          PrefetchHooks Function()
        > {
  $$DashboardLayoutCacheTableTableManager(
    _$AutolifeDatabase db,
    $DashboardLayoutCacheTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DashboardLayoutCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DashboardLayoutCacheTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DashboardLayoutCacheTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> familyId = const Value.absent(),
                Value<String> memberScope = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<int> layoutVersion = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DashboardLayoutCacheCompanion(
                familyId: familyId,
                memberScope: memberScope,
                payloadJson: payloadJson,
                layoutVersion: layoutVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String familyId,
                required String memberScope,
                required String payloadJson,
                Value<int> layoutVersion = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DashboardLayoutCacheCompanion.insert(
                familyId: familyId,
                memberScope: memberScope,
                payloadJson: payloadJson,
                layoutVersion: layoutVersion,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DashboardLayoutCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AutolifeDatabase,
      $DashboardLayoutCacheTable,
      DashboardLayoutCacheData,
      $$DashboardLayoutCacheTableFilterComposer,
      $$DashboardLayoutCacheTableOrderingComposer,
      $$DashboardLayoutCacheTableAnnotationComposer,
      $$DashboardLayoutCacheTableCreateCompanionBuilder,
      $$DashboardLayoutCacheTableUpdateCompanionBuilder,
      (
        DashboardLayoutCacheData,
        BaseReferences<
          _$AutolifeDatabase,
          $DashboardLayoutCacheTable,
          DashboardLayoutCacheData
        >,
      ),
      DashboardLayoutCacheData,
      PrefetchHooks Function()
    >;

class $AutolifeDatabaseManager {
  final _$AutolifeDatabase _db;
  $AutolifeDatabaseManager(this._db);
  $$SystemEventCacheTableTableManager get systemEventCache =>
      $$SystemEventCacheTableTableManager(_db, _db.systemEventCache);
  $$EventDeliveryCacheTableTableManager get eventDeliveryCache =>
      $$EventDeliveryCacheTableTableManager(_db, _db.eventDeliveryCache);
  $$ProfileCacheTableTableManager get profileCache =>
      $$ProfileCacheTableTableManager(_db, _db.profileCache);
  $$FamilyCacheTableTableManager get familyCache =>
      $$FamilyCacheTableTableManager(_db, _db.familyCache);
  $$MembershipCacheTableTableManager get membershipCache =>
      $$MembershipCacheTableTableManager(_db, _db.membershipCache);
  $$PendingWritesTableTableManager get pendingWrites =>
      $$PendingWritesTableTableManager(_db, _db.pendingWrites);
  $$DashboardLayoutCacheTableTableManager get dashboardLayoutCache =>
      $$DashboardLayoutCacheTableTableManager(_db, _db.dashboardLayoutCache);
}
