// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $QueueItemsTable extends QueueItems
    with TableInfo<$QueueItemsTable, QueueItemEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commandJsonMeta = const VerificationMeta(
    'commandJson',
  );
  @override
  late final GeneratedColumn<String> commandJson = GeneratedColumn<String>(
    'command_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _commandTypeMeta = const VerificationMeta(
    'commandType',
  );
  @override
  late final GeneratedColumn<String> commandType = GeneratedColumn<String>(
    'command_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(QueuePriority.medium),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(QueueStatus.pending),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxRetriesMeta = const VerificationMeta(
    'maxRetries',
  );
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
    'max_retries',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
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
    commandJson,
    commandType,
    priority,
    status,
    retryCount,
    maxRetries,
    lastError,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueItemEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('command_json')) {
      context.handle(
        _commandJsonMeta,
        commandJson.isAcceptableOrUnknown(
          data['command_json']!,
          _commandJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commandJsonMeta);
    }
    if (data.containsKey('command_type')) {
      context.handle(
        _commandTypeMeta,
        commandType.isAcceptableOrUnknown(
          data['command_type']!,
          _commandTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_commandTypeMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('max_retries')) {
      context.handle(
        _maxRetriesMeta,
        maxRetries.isAcceptableOrUnknown(data['max_retries']!, _maxRetriesMeta),
      );
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
  QueueItemEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueItemEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      commandJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_json'],
      )!,
      commandType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}command_type'],
      )!,
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      maxRetries: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_retries'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QueueItemsTable createAlias(String alias) {
    return $QueueItemsTable(attachedDatabase, alias);
  }
}

class QueueItemEntry extends DataClass implements Insertable<QueueItemEntry> {
  /// UUID v4 — matches the commandId.
  final String id;

  /// Serialized JSON of the Command object.
  final String commandJson;

  /// Command type (scan, add_product, etc.) for filtering.
  final String commandType;

  /// Priority: 0=High, 1=Medium, 2=Low.
  final int priority;

  /// Status: 0=pending, 1=sending, 2=completed, 3=failed.
  final int status;

  /// Number of send attempts.
  final int retryCount;

  /// Maximum retries before marking as failed.
  final int maxRetries;

  /// Last error message (if any).
  final String? lastError;

  /// When this item was created.
  final DateTime createdAt;

  /// When this item was last updated.
  final DateTime updatedAt;
  const QueueItemEntry({
    required this.id,
    required this.commandJson,
    required this.commandType,
    required this.priority,
    required this.status,
    required this.retryCount,
    required this.maxRetries,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['command_json'] = Variable<String>(commandJson);
    map['command_type'] = Variable<String>(commandType);
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<int>(status);
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QueueItemsCompanion toCompanion(bool nullToAbsent) {
    return QueueItemsCompanion(
      id: Value(id),
      commandJson: Value(commandJson),
      commandType: Value(commandType),
      priority: Value(priority),
      status: Value(status),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QueueItemEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueItemEntry(
      id: serializer.fromJson<String>(json['id']),
      commandJson: serializer.fromJson<String>(json['commandJson']),
      commandType: serializer.fromJson<String>(json['commandType']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<int>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'commandJson': serializer.toJson<String>(commandJson),
      'commandType': serializer.toJson<String>(commandType),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<int>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QueueItemEntry copyWith({
    String? id,
    String? commandJson,
    String? commandType,
    int? priority,
    int? status,
    int? retryCount,
    int? maxRetries,
    Value<String?> lastError = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => QueueItemEntry(
    id: id ?? this.id,
    commandJson: commandJson ?? this.commandJson,
    commandType: commandType ?? this.commandType,
    priority: priority ?? this.priority,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    maxRetries: maxRetries ?? this.maxRetries,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QueueItemEntry copyWithCompanion(QueueItemsCompanion data) {
    return QueueItemEntry(
      id: data.id.present ? data.id.value : this.id,
      commandJson: data.commandJson.present
          ? data.commandJson.value
          : this.commandJson,
      commandType: data.commandType.present
          ? data.commandType.value
          : this.commandType,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      maxRetries: data.maxRetries.present
          ? data.maxRetries.value
          : this.maxRetries,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueItemEntry(')
          ..write('id: $id, ')
          ..write('commandJson: $commandJson, ')
          ..write('commandType: $commandType, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    commandJson,
    commandType,
    priority,
    status,
    retryCount,
    maxRetries,
    lastError,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueItemEntry &&
          other.id == this.id &&
          other.commandJson == this.commandJson &&
          other.commandType == this.commandType &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QueueItemsCompanion extends UpdateCompanion<QueueItemEntry> {
  final Value<String> id;
  final Value<String> commandJson;
  final Value<String> commandType;
  final Value<int> priority;
  final Value<int> status;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<String?> lastError;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const QueueItemsCompanion({
    this.id = const Value.absent(),
    this.commandJson = const Value.absent(),
    this.commandType = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QueueItemsCompanion.insert({
    required String id,
    required String commandJson,
    required String commandType,
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.lastError = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       commandJson = Value(commandJson),
       commandType = Value(commandType),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<QueueItemEntry> custom({
    Expression<String>? id,
    Expression<String>? commandJson,
    Expression<String>? commandType,
    Expression<int>? priority,
    Expression<int>? status,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<String>? lastError,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (commandJson != null) 'command_json': commandJson,
      if (commandType != null) 'command_type': commandType,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QueueItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? commandJson,
    Value<String>? commandType,
    Value<int>? priority,
    Value<int>? status,
    Value<int>? retryCount,
    Value<int>? maxRetries,
    Value<String?>? lastError,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return QueueItemsCompanion(
      id: id ?? this.id,
      commandJson: commandJson ?? this.commandJson,
      commandType: commandType ?? this.commandType,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
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
    if (commandJson.present) {
      map['command_json'] = Variable<String>(commandJson.value);
    }
    if (commandType.present) {
      map['command_type'] = Variable<String>(commandType.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
    return (StringBuffer('QueueItemsCompanion(')
          ..write('id: $id, ')
          ..write('commandJson: $commandJson, ')
          ..write('commandType: $commandType, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _serverUrlMeta = const VerificationMeta(
    'serverUrl',
  );
  @override
  late final GeneratedColumn<String> serverUrl = GeneratedColumn<String>(
    'server_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionTokenMeta = const VerificationMeta(
    'sessionToken',
  );
  @override
  late final GeneratedColumn<String> sessionToken = GeneratedColumn<String>(
    'session_token',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionsMeta = const VerificationMeta(
    'permissions',
  );
  @override
  late final GeneratedColumn<String> permissions = GeneratedColumn<String>(
    'permissions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    serverUrl,
    sessionToken,
    deviceId,
    deviceName,
    expiresAt,
    permissions,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('server_url')) {
      context.handle(
        _serverUrlMeta,
        serverUrl.isAcceptableOrUnknown(data['server_url']!, _serverUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_serverUrlMeta);
    }
    if (data.containsKey('session_token')) {
      context.handle(
        _sessionTokenMeta,
        sessionToken.isAcceptableOrUnknown(
          data['session_token']!,
          _sessionTokenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sessionTokenMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('permissions')) {
      context.handle(
        _permissionsMeta,
        permissions.isAcceptableOrUnknown(
          data['permissions']!,
          _permissionsMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
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
  SessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      serverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_url'],
      )!,
      sessionToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_token'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      permissions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionEntry extends DataClass implements Insertable<SessionEntry> {
  /// Auto-incremented ID.
  final int id;

  /// The Balora Desktop server URL.
  final String serverUrl;

  /// Session authentication token.
  final String sessionToken;

  /// Unique device ID assigned by the server.
  final String deviceId;

  /// Human-readable desktop name.
  final String deviceName;

  /// When this session expires.
  final DateTime expiresAt;

  /// Comma-separated list of permissions.
  final String permissions;

  /// Whether this is the currently active session.
  final bool isActive;

  /// When this session was created.
  final DateTime createdAt;
  const SessionEntry({
    required this.id,
    required this.serverUrl,
    required this.sessionToken,
    required this.deviceId,
    required this.deviceName,
    required this.expiresAt,
    required this.permissions,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['server_url'] = Variable<String>(serverUrl);
    map['session_token'] = Variable<String>(sessionToken);
    map['device_id'] = Variable<String>(deviceId);
    map['device_name'] = Variable<String>(deviceName);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['permissions'] = Variable<String>(permissions);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      id: Value(id),
      serverUrl: Value(serverUrl),
      sessionToken: Value(sessionToken),
      deviceId: Value(deviceId),
      deviceName: Value(deviceName),
      expiresAt: Value(expiresAt),
      permissions: Value(permissions),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory SessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEntry(
      id: serializer.fromJson<int>(json['id']),
      serverUrl: serializer.fromJson<String>(json['serverUrl']),
      sessionToken: serializer.fromJson<String>(json['sessionToken']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      permissions: serializer.fromJson<String>(json['permissions']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'serverUrl': serializer.toJson<String>(serverUrl),
      'sessionToken': serializer.toJson<String>(sessionToken),
      'deviceId': serializer.toJson<String>(deviceId),
      'deviceName': serializer.toJson<String>(deviceName),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'permissions': serializer.toJson<String>(permissions),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SessionEntry copyWith({
    int? id,
    String? serverUrl,
    String? sessionToken,
    String? deviceId,
    String? deviceName,
    DateTime? expiresAt,
    String? permissions,
    bool? isActive,
    DateTime? createdAt,
  }) => SessionEntry(
    id: id ?? this.id,
    serverUrl: serverUrl ?? this.serverUrl,
    sessionToken: sessionToken ?? this.sessionToken,
    deviceId: deviceId ?? this.deviceId,
    deviceName: deviceName ?? this.deviceName,
    expiresAt: expiresAt ?? this.expiresAt,
    permissions: permissions ?? this.permissions,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  SessionEntry copyWithCompanion(SessionsCompanion data) {
    return SessionEntry(
      id: data.id.present ? data.id.value : this.id,
      serverUrl: data.serverUrl.present ? data.serverUrl.value : this.serverUrl,
      sessionToken: data.sessionToken.present
          ? data.sessionToken.value
          : this.sessionToken,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      permissions: data.permissions.present
          ? data.permissions.value
          : this.permissions,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntry(')
          ..write('id: $id, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('sessionToken: $sessionToken, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('permissions: $permissions, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    serverUrl,
    sessionToken,
    deviceId,
    deviceName,
    expiresAt,
    permissions,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEntry &&
          other.id == this.id &&
          other.serverUrl == this.serverUrl &&
          other.sessionToken == this.sessionToken &&
          other.deviceId == this.deviceId &&
          other.deviceName == this.deviceName &&
          other.expiresAt == this.expiresAt &&
          other.permissions == this.permissions &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SessionsCompanion extends UpdateCompanion<SessionEntry> {
  final Value<int> id;
  final Value<String> serverUrl;
  final Value<String> sessionToken;
  final Value<String> deviceId;
  final Value<String> deviceName;
  final Value<DateTime> expiresAt;
  final Value<String> permissions;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const SessionsCompanion({
    this.id = const Value.absent(),
    this.serverUrl = const Value.absent(),
    this.sessionToken = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.permissions = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.id = const Value.absent(),
    required String serverUrl,
    required String sessionToken,
    required String deviceId,
    required String deviceName,
    required DateTime expiresAt,
    this.permissions = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : serverUrl = Value(serverUrl),
       sessionToken = Value(sessionToken),
       deviceId = Value(deviceId),
       deviceName = Value(deviceName),
       expiresAt = Value(expiresAt),
       createdAt = Value(createdAt);
  static Insertable<SessionEntry> custom({
    Expression<int>? id,
    Expression<String>? serverUrl,
    Expression<String>? sessionToken,
    Expression<String>? deviceId,
    Expression<String>? deviceName,
    Expression<DateTime>? expiresAt,
    Expression<String>? permissions,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (serverUrl != null) 'server_url': serverUrl,
      if (sessionToken != null) 'session_token': sessionToken,
      if (deviceId != null) 'device_id': deviceId,
      if (deviceName != null) 'device_name': deviceName,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (permissions != null) 'permissions': permissions,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? serverUrl,
    Value<String>? sessionToken,
    Value<String>? deviceId,
    Value<String>? deviceName,
    Value<DateTime>? expiresAt,
    Value<String>? permissions,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return SessionsCompanion(
      id: id ?? this.id,
      serverUrl: serverUrl ?? this.serverUrl,
      sessionToken: sessionToken ?? this.sessionToken,
      deviceId: deviceId ?? this.deviceId,
      deviceName: deviceName ?? this.deviceName,
      expiresAt: expiresAt ?? this.expiresAt,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (serverUrl.present) {
      map['server_url'] = Variable<String>(serverUrl.value);
    }
    if (sessionToken.present) {
      map['session_token'] = Variable<String>(sessionToken.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (permissions.present) {
      map['permissions'] = Variable<String>(permissions.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('id: $id, ')
          ..write('serverUrl: $serverUrl, ')
          ..write('sessionToken: $sessionToken, ')
          ..write('deviceId: $deviceId, ')
          ..write('deviceName: $deviceName, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('permissions: $permissions, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ScanHistoryTable extends ScanHistory
    with TableInfo<$ScanHistoryTable, ScanHistoryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScanHistoryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productNameMeta = const VerificationMeta(
    'productName',
  );
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
    'product_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scannedAtMeta = const VerificationMeta(
    'scannedAt',
  );
  @override
  late final GeneratedColumn<DateTime> scannedAt = GeneratedColumn<DateTime>(
    'scanned_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    barcode,
    format,
    productName,
    synced,
    scannedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scan_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScanHistoryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
        _productNameMeta,
        productName.isAcceptableOrUnknown(
          data['product_name']!,
          _productNameMeta,
        ),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('scanned_at')) {
      context.handle(
        _scannedAtMeta,
        scannedAt.isAcceptableOrUnknown(data['scanned_at']!, _scannedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_scannedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScanHistoryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScanHistoryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      productName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}product_name'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      scannedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scanned_at'],
      )!,
    );
  }

  @override
  $ScanHistoryTable createAlias(String alias) {
    return $ScanHistoryTable(attachedDatabase, alias);
  }
}

class ScanHistoryEntry extends DataClass
    implements Insertable<ScanHistoryEntry> {
  /// Auto-incremented ID.
  final int id;

  /// The scanned barcode value.
  final String barcode;

  /// Barcode format (ean13, qr, code128, etc.).
  final String format;

  /// Product name (if resolved from server).
  final String? productName;

  /// Whether the scan was successfully synced.
  final bool synced;

  /// Timestamp of the scan.
  final DateTime scannedAt;
  const ScanHistoryEntry({
    required this.id,
    required this.barcode,
    required this.format,
    this.productName,
    required this.synced,
    required this.scannedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['barcode'] = Variable<String>(barcode);
    map['format'] = Variable<String>(format);
    if (!nullToAbsent || productName != null) {
      map['product_name'] = Variable<String>(productName);
    }
    map['synced'] = Variable<bool>(synced);
    map['scanned_at'] = Variable<DateTime>(scannedAt);
    return map;
  }

  ScanHistoryCompanion toCompanion(bool nullToAbsent) {
    return ScanHistoryCompanion(
      id: Value(id),
      barcode: Value(barcode),
      format: Value(format),
      productName: productName == null && nullToAbsent
          ? const Value.absent()
          : Value(productName),
      synced: Value(synced),
      scannedAt: Value(scannedAt),
    );
  }

  factory ScanHistoryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScanHistoryEntry(
      id: serializer.fromJson<int>(json['id']),
      barcode: serializer.fromJson<String>(json['barcode']),
      format: serializer.fromJson<String>(json['format']),
      productName: serializer.fromJson<String?>(json['productName']),
      synced: serializer.fromJson<bool>(json['synced']),
      scannedAt: serializer.fromJson<DateTime>(json['scannedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'barcode': serializer.toJson<String>(barcode),
      'format': serializer.toJson<String>(format),
      'productName': serializer.toJson<String?>(productName),
      'synced': serializer.toJson<bool>(synced),
      'scannedAt': serializer.toJson<DateTime>(scannedAt),
    };
  }

  ScanHistoryEntry copyWith({
    int? id,
    String? barcode,
    String? format,
    Value<String?> productName = const Value.absent(),
    bool? synced,
    DateTime? scannedAt,
  }) => ScanHistoryEntry(
    id: id ?? this.id,
    barcode: barcode ?? this.barcode,
    format: format ?? this.format,
    productName: productName.present ? productName.value : this.productName,
    synced: synced ?? this.synced,
    scannedAt: scannedAt ?? this.scannedAt,
  );
  ScanHistoryEntry copyWithCompanion(ScanHistoryCompanion data) {
    return ScanHistoryEntry(
      id: data.id.present ? data.id.value : this.id,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      format: data.format.present ? data.format.value : this.format,
      productName: data.productName.present
          ? data.productName.value
          : this.productName,
      synced: data.synced.present ? data.synced.value : this.synced,
      scannedAt: data.scannedAt.present ? data.scannedAt.value : this.scannedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryEntry(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('format: $format, ')
          ..write('productName: $productName, ')
          ..write('synced: $synced, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, barcode, format, productName, synced, scannedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScanHistoryEntry &&
          other.id == this.id &&
          other.barcode == this.barcode &&
          other.format == this.format &&
          other.productName == this.productName &&
          other.synced == this.synced &&
          other.scannedAt == this.scannedAt);
}

class ScanHistoryCompanion extends UpdateCompanion<ScanHistoryEntry> {
  final Value<int> id;
  final Value<String> barcode;
  final Value<String> format;
  final Value<String?> productName;
  final Value<bool> synced;
  final Value<DateTime> scannedAt;
  const ScanHistoryCompanion({
    this.id = const Value.absent(),
    this.barcode = const Value.absent(),
    this.format = const Value.absent(),
    this.productName = const Value.absent(),
    this.synced = const Value.absent(),
    this.scannedAt = const Value.absent(),
  });
  ScanHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String barcode,
    required String format,
    this.productName = const Value.absent(),
    this.synced = const Value.absent(),
    required DateTime scannedAt,
  }) : barcode = Value(barcode),
       format = Value(format),
       scannedAt = Value(scannedAt);
  static Insertable<ScanHistoryEntry> custom({
    Expression<int>? id,
    Expression<String>? barcode,
    Expression<String>? format,
    Expression<String>? productName,
    Expression<bool>? synced,
    Expression<DateTime>? scannedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (barcode != null) 'barcode': barcode,
      if (format != null) 'format': format,
      if (productName != null) 'product_name': productName,
      if (synced != null) 'synced': synced,
      if (scannedAt != null) 'scanned_at': scannedAt,
    });
  }

  ScanHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? barcode,
    Value<String>? format,
    Value<String?>? productName,
    Value<bool>? synced,
    Value<DateTime>? scannedAt,
  }) {
    return ScanHistoryCompanion(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      format: format ?? this.format,
      productName: productName ?? this.productName,
      synced: synced ?? this.synced,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (scannedAt.present) {
      map['scanned_at'] = Variable<DateTime>(scannedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScanHistoryCompanion(')
          ..write('id: $id, ')
          ..write('barcode: $barcode, ')
          ..write('format: $format, ')
          ..write('productName: $productName, ')
          ..write('synced: $synced, ')
          ..write('scannedAt: $scannedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $QueueItemsTable queueItems = $QueueItemsTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $ScanHistoryTable scanHistory = $ScanHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    queueItems,
    sessions,
    scanHistory,
  ];
}

typedef $$QueueItemsTableCreateCompanionBuilder =
    QueueItemsCompanion Function({
      required String id,
      required String commandJson,
      required String commandType,
      Value<int> priority,
      Value<int> status,
      Value<int> retryCount,
      Value<int> maxRetries,
      Value<String?> lastError,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$QueueItemsTableUpdateCompanionBuilder =
    QueueItemsCompanion Function({
      Value<String> id,
      Value<String> commandJson,
      Value<String> commandType,
      Value<int> priority,
      Value<int> status,
      Value<int> retryCount,
      Value<int> maxRetries,
      Value<String?> lastError,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$QueueItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableFilterComposer({
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

  ColumnFilters<String> get commandJson => $composableBuilder(
    column: $table.commandJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get commandType => $composableBuilder(
    column: $table.commandType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxRetries => $composableBuilder(
    column: $table.maxRetries,
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableOrderingComposer({
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

  ColumnOrderings<String> get commandJson => $composableBuilder(
    column: $table.commandJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get commandType => $composableBuilder(
    column: $table.commandType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxRetries => $composableBuilder(
    column: $table.maxRetries,
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueItemsTable> {
  $$QueueItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get commandJson => $composableBuilder(
    column: $table.commandJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get commandType => $composableBuilder(
    column: $table.commandType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxRetries => $composableBuilder(
    column: $table.maxRetries,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QueueItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueItemsTable,
          QueueItemEntry,
          $$QueueItemsTableFilterComposer,
          $$QueueItemsTableOrderingComposer,
          $$QueueItemsTableAnnotationComposer,
          $$QueueItemsTableCreateCompanionBuilder,
          $$QueueItemsTableUpdateCompanionBuilder,
          (
            QueueItemEntry,
            BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItemEntry>,
          ),
          QueueItemEntry,
          PrefetchHooks Function()
        > {
  $$QueueItemsTableTableManager(_$AppDatabase db, $QueueItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> commandJson = const Value.absent(),
                Value<String> commandType = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> maxRetries = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QueueItemsCompanion(
                id: id,
                commandJson: commandJson,
                commandType: commandType,
                priority: priority,
                status: status,
                retryCount: retryCount,
                maxRetries: maxRetries,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String commandJson,
                required String commandType,
                Value<int> priority = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<int> maxRetries = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QueueItemsCompanion.insert(
                id: id,
                commandJson: commandJson,
                commandType: commandType,
                priority: priority,
                status: status,
                retryCount: retryCount,
                maxRetries: maxRetries,
                lastError: lastError,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QueueItemsTable, QueueItemEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $QueueItemsTable,
                    QueueItemEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueItemsTable,
      QueueItemEntry,
      $$QueueItemsTableFilterComposer,
      $$QueueItemsTableOrderingComposer,
      $$QueueItemsTableAnnotationComposer,
      $$QueueItemsTableCreateCompanionBuilder,
      $$QueueItemsTableUpdateCompanionBuilder,
      (
        QueueItemEntry,
        BaseReferences<_$AppDatabase, $QueueItemsTable, QueueItemEntry>,
      ),
      QueueItemEntry,
      PrefetchHooks Function()
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      required String serverUrl,
      required String sessionToken,
      required String deviceId,
      required String deviceName,
      required DateTime expiresAt,
      Value<String> permissions,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<int> id,
      Value<String> serverUrl,
      Value<String> sessionToken,
      Value<String> deviceId,
      Value<String> deviceName,
      Value<DateTime> expiresAt,
      Value<String> permissions,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
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

  ColumnFilters<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionToken => $composableBuilder(
    column: $table.sessionToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
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

  ColumnOrderings<String> get serverUrl => $composableBuilder(
    column: $table.serverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionToken => $composableBuilder(
    column: $table.sessionToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serverUrl =>
      $composableBuilder(column: $table.serverUrl, builder: (column) => column);

  GeneratedColumn<String> get sessionToken => $composableBuilder(
    column: $table.sessionToken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get permissions => $composableBuilder(
    column: $table.permissions,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionEntry,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (
            SessionEntry,
            BaseReferences<_$AppDatabase, $SessionsTable, SessionEntry>,
          ),
          SessionEntry,
          PrefetchHooks Function()
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> serverUrl = const Value.absent(),
                Value<String> sessionToken = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<String> permissions = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SessionsCompanion(
                id: id,
                serverUrl: serverUrl,
                sessionToken: sessionToken,
                deviceId: deviceId,
                deviceName: deviceName,
                expiresAt: expiresAt,
                permissions: permissions,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String serverUrl,
                required String sessionToken,
                required String deviceId,
                required String deviceName,
                required DateTime expiresAt,
                Value<String> permissions = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => SessionsCompanion.insert(
                id: id,
                serverUrl: serverUrl,
                sessionToken: sessionToken,
                deviceId: deviceId,
                deviceName: deviceName,
                expiresAt: expiresAt,
                permissions: permissions,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionsTable, SessionEntry>(table),
                  BaseReferences<_$AppDatabase, $SessionsTable, SessionEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionEntry,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (
        SessionEntry,
        BaseReferences<_$AppDatabase, $SessionsTable, SessionEntry>,
      ),
      SessionEntry,
      PrefetchHooks Function()
    >;
typedef $$ScanHistoryTableCreateCompanionBuilder =
    ScanHistoryCompanion Function({
      Value<int> id,
      required String barcode,
      required String format,
      Value<String?> productName,
      Value<bool> synced,
      required DateTime scannedAt,
    });
typedef $$ScanHistoryTableUpdateCompanionBuilder =
    ScanHistoryCompanion Function({
      Value<int> id,
      Value<String> barcode,
      Value<String> format,
      Value<String?> productName,
      Value<bool> synced,
      Value<DateTime> scannedAt,
    });

class $$ScanHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $ScanHistoryTable> {
  $$ScanHistoryTableFilterComposer({
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

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ScanHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $ScanHistoryTable> {
  $$ScanHistoryTableOrderingComposer({
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

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scannedAt => $composableBuilder(
    column: $table.scannedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScanHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScanHistoryTable> {
  $$ScanHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
    column: $table.productName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<DateTime> get scannedAt =>
      $composableBuilder(column: $table.scannedAt, builder: (column) => column);
}

class $$ScanHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScanHistoryTable,
          ScanHistoryEntry,
          $$ScanHistoryTableFilterComposer,
          $$ScanHistoryTableOrderingComposer,
          $$ScanHistoryTableAnnotationComposer,
          $$ScanHistoryTableCreateCompanionBuilder,
          $$ScanHistoryTableUpdateCompanionBuilder,
          (
            ScanHistoryEntry,
            BaseReferences<_$AppDatabase, $ScanHistoryTable, ScanHistoryEntry>,
          ),
          ScanHistoryEntry,
          PrefetchHooks Function()
        > {
  $$ScanHistoryTableTableManager(_$AppDatabase db, $ScanHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScanHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScanHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScanHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> barcode = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<String?> productName = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<DateTime> scannedAt = const Value.absent(),
              }) => ScanHistoryCompanion(
                id: id,
                barcode: barcode,
                format: format,
                productName: productName,
                synced: synced,
                scannedAt: scannedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String barcode,
                required String format,
                Value<String?> productName = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                required DateTime scannedAt,
              }) => ScanHistoryCompanion.insert(
                id: id,
                barcode: barcode,
                format: format,
                productName: productName,
                synced: synced,
                scannedAt: scannedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScanHistoryTable, ScanHistoryEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ScanHistoryTable,
                    ScanHistoryEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ScanHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScanHistoryTable,
      ScanHistoryEntry,
      $$ScanHistoryTableFilterComposer,
      $$ScanHistoryTableOrderingComposer,
      $$ScanHistoryTableAnnotationComposer,
      $$ScanHistoryTableCreateCompanionBuilder,
      $$ScanHistoryTableUpdateCompanionBuilder,
      (
        ScanHistoryEntry,
        BaseReferences<_$AppDatabase, $ScanHistoryTable, ScanHistoryEntry>,
      ),
      ScanHistoryEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$QueueItemsTableTableManager get queueItems =>
      $$QueueItemsTableTableManager(_db, _db.queueItems);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$ScanHistoryTableTableManager get scanHistory =>
      $$ScanHistoryTableTableManager(_db, _db.scanHistory);
}
