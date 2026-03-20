// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfileTableTable extends ProfileTable
    with TableInfo<$ProfileTableTable, ProfileTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTableTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 50,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nickname,
    photoPath,
    birthDate,
    bio,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
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
  $ProfileTableTable createAlias(String alias) {
    return $ProfileTableTable(attachedDatabase, alias);
  }
}

class ProfileTableData extends DataClass
    implements Insertable<ProfileTableData> {
  final int id;
  final String name;
  final String? nickname;
  final String? photoPath;
  final DateTime? birthDate;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ProfileTableData({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,
    this.birthDate,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProfileTableCompanion toCompanion(bool nullToAbsent) {
    return ProfileTableCompanion(
      id: Value(id),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ProfileTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      bio: serializer.fromJson<String?>(json['bio']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'photoPath': serializer.toJson<String?>(photoPath),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'bio': serializer.toJson<String?>(bio),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ProfileTableData copyWith({
    int? id,
    String? name,
    Value<String?> nickname = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProfileTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    bio: bio.present ? bio.value : this.bio,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ProfileTableData copyWithCompanion(ProfileTableCompanion data) {
    return ProfileTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      bio: data.bio.present ? data.bio.value : this.bio,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('birthDate: $birthDate, ')
          ..write('bio: $bio, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nickname,
    photoPath,
    birthDate,
    bio,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.photoPath == this.photoPath &&
          other.birthDate == this.birthDate &&
          other.bio == this.bio &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProfileTableCompanion extends UpdateCompanion<ProfileTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String?> photoPath;
  final Value<DateTime?> birthDate;
  final Value<String?> bio;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProfileTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.bio = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProfileTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.bio = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ProfileTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? photoPath,
    Expression<DateTime>? birthDate,
    Expression<String>? bio,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (photoPath != null) 'photo_path': photoPath,
      if (birthDate != null) 'birth_date': birthDate,
      if (bio != null) 'bio': bio,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProfileTableCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String?>? photoPath,
    Value<DateTime?>? birthDate,
    Value<String?>? bio,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProfileTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      birthDate: birthDate ?? this.birthDate,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('birthDate: $birthDate, ')
          ..write('bio: $bio, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $NodesTableTable extends NodesTable
    with TableInfo<$NodesTableTable, NodesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodesTableTable(this.attachedDatabase, [this._alias]);
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
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
    'bio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deathDateMeta = const VerificationMeta(
    'deathDate',
  );
  @override
  late final GeneratedColumn<DateTime> deathDate = GeneratedColumn<DateTime>(
    'death_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isGhostMeta = const VerificationMeta(
    'isGhost',
  );
  @override
  late final GeneratedColumn<bool> isGhost = GeneratedColumn<bool>(
    'is_ghost',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ghost" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<int> temperature = GeneratedColumn<int>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _positionXMeta = const VerificationMeta(
    'positionX',
  );
  @override
  late final GeneratedColumn<double> positionX = GeneratedColumn<double>(
    'position_x',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _positionYMeta = const VerificationMeta(
    'positionY',
  );
  @override
  late final GeneratedColumn<double> positionY = GeneratedColumn<double>(
    'position_y',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nickname,
    photoPath,
    bio,
    birthDate,
    deathDate,
    isGhost,
    temperature,
    positionX,
    positionY,
    tagsJson,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<NodesTableData> instance, {
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
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('bio')) {
      context.handle(
        _bioMeta,
        bio.isAcceptableOrUnknown(data['bio']!, _bioMeta),
      );
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('death_date')) {
      context.handle(
        _deathDateMeta,
        deathDate.isAcceptableOrUnknown(data['death_date']!, _deathDateMeta),
      );
    }
    if (data.containsKey('is_ghost')) {
      context.handle(
        _isGhostMeta,
        isGhost.isAcceptableOrUnknown(data['is_ghost']!, _isGhostMeta),
      );
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    }
    if (data.containsKey('position_x')) {
      context.handle(
        _positionXMeta,
        positionX.isAcceptableOrUnknown(data['position_x']!, _positionXMeta),
      );
    }
    if (data.containsKey('position_y')) {
      context.handle(
        _positionYMeta,
        positionY.isAcceptableOrUnknown(data['position_y']!, _positionYMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NodesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NodesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      bio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bio'],
      ),
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      deathDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}death_date'],
      ),
      isGhost: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ghost'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature'],
      )!,
      positionX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_x'],
      )!,
      positionY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}position_y'],
      )!,
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
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
  $NodesTableTable createAlias(String alias) {
    return $NodesTableTable(attachedDatabase, alias);
  }
}

class NodesTableData extends DataClass implements Insertable<NodesTableData> {
  final String id;
  final String name;
  final String? nickname;
  final String? photoPath;
  final String? bio;
  final DateTime? birthDate;
  final DateTime? deathDate;

  /// Ghost Node: 실제 인물 미확인 조상
  final bool isGhost;

  /// 온도 레벨 0(icy) ~ 5(fire), 기본 2(neutral)
  final int temperature;

  /// 캔버스 좌표
  final double positionX;
  final double positionY;

  /// 태그 (JSON 배열 문자열)
  final String tagsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NodesTableData({
    required this.id,
    required this.name,
    this.nickname,
    this.photoPath,
    this.bio,
    this.birthDate,
    this.deathDate,
    required this.isGhost,
    required this.temperature,
    required this.positionX,
    required this.positionY,
    required this.tagsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || bio != null) {
      map['bio'] = Variable<String>(bio);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || deathDate != null) {
      map['death_date'] = Variable<DateTime>(deathDate);
    }
    map['is_ghost'] = Variable<bool>(isGhost);
    map['temperature'] = Variable<int>(temperature);
    map['position_x'] = Variable<double>(positionX);
    map['position_y'] = Variable<double>(positionY);
    map['tags_json'] = Variable<String>(tagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NodesTableCompanion toCompanion(bool nullToAbsent) {
    return NodesTableCompanion(
      id: Value(id),
      name: Value(name),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      bio: bio == null && nullToAbsent ? const Value.absent() : Value(bio),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      deathDate: deathDate == null && nullToAbsent
          ? const Value.absent()
          : Value(deathDate),
      isGhost: Value(isGhost),
      temperature: Value(temperature),
      positionX: Value(positionX),
      positionY: Value(positionY),
      tagsJson: Value(tagsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NodesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NodesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      bio: serializer.fromJson<String?>(json['bio']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      deathDate: serializer.fromJson<DateTime?>(json['deathDate']),
      isGhost: serializer.fromJson<bool>(json['isGhost']),
      temperature: serializer.fromJson<int>(json['temperature']),
      positionX: serializer.fromJson<double>(json['positionX']),
      positionY: serializer.fromJson<double>(json['positionY']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nickname': serializer.toJson<String?>(nickname),
      'photoPath': serializer.toJson<String?>(photoPath),
      'bio': serializer.toJson<String?>(bio),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'deathDate': serializer.toJson<DateTime?>(deathDate),
      'isGhost': serializer.toJson<bool>(isGhost),
      'temperature': serializer.toJson<int>(temperature),
      'positionX': serializer.toJson<double>(positionX),
      'positionY': serializer.toJson<double>(positionY),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NodesTableData copyWith({
    String? id,
    String? name,
    Value<String?> nickname = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> bio = const Value.absent(),
    Value<DateTime?> birthDate = const Value.absent(),
    Value<DateTime?> deathDate = const Value.absent(),
    bool? isGhost,
    int? temperature,
    double? positionX,
    double? positionY,
    String? tagsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NodesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    nickname: nickname.present ? nickname.value : this.nickname,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    bio: bio.present ? bio.value : this.bio,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    deathDate: deathDate.present ? deathDate.value : this.deathDate,
    isGhost: isGhost ?? this.isGhost,
    temperature: temperature ?? this.temperature,
    positionX: positionX ?? this.positionX,
    positionY: positionY ?? this.positionY,
    tagsJson: tagsJson ?? this.tagsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NodesTableData copyWithCompanion(NodesTableCompanion data) {
    return NodesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      bio: data.bio.present ? data.bio.value : this.bio,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      deathDate: data.deathDate.present ? data.deathDate.value : this.deathDate,
      isGhost: data.isGhost.present ? data.isGhost.value : this.isGhost,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      positionX: data.positionX.present ? data.positionX.value : this.positionX,
      positionY: data.positionY.present ? data.positionY.value : this.positionY,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NodesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('bio: $bio, ')
          ..write('birthDate: $birthDate, ')
          ..write('deathDate: $deathDate, ')
          ..write('isGhost: $isGhost, ')
          ..write('temperature: $temperature, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nickname,
    photoPath,
    bio,
    birthDate,
    deathDate,
    isGhost,
    temperature,
    positionX,
    positionY,
    tagsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NodesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.nickname == this.nickname &&
          other.photoPath == this.photoPath &&
          other.bio == this.bio &&
          other.birthDate == this.birthDate &&
          other.deathDate == this.deathDate &&
          other.isGhost == this.isGhost &&
          other.temperature == this.temperature &&
          other.positionX == this.positionX &&
          other.positionY == this.positionY &&
          other.tagsJson == this.tagsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NodesTableCompanion extends UpdateCompanion<NodesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> nickname;
  final Value<String?> photoPath;
  final Value<String?> bio;
  final Value<DateTime?> birthDate;
  final Value<DateTime?> deathDate;
  final Value<bool> isGhost;
  final Value<int> temperature;
  final Value<double> positionX;
  final Value<double> positionY;
  final Value<String> tagsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NodesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.bio = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.isGhost = const Value.absent(),
    this.temperature = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NodesTableCompanion.insert({
    required String id,
    required String name,
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.bio = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.deathDate = const Value.absent(),
    this.isGhost = const Value.absent(),
    this.temperature = const Value.absent(),
    this.positionX = const Value.absent(),
    this.positionY = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<NodesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nickname,
    Expression<String>? photoPath,
    Expression<String>? bio,
    Expression<DateTime>? birthDate,
    Expression<DateTime>? deathDate,
    Expression<bool>? isGhost,
    Expression<int>? temperature,
    Expression<double>? positionX,
    Expression<double>? positionY,
    Expression<String>? tagsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nickname != null) 'nickname': nickname,
      if (photoPath != null) 'photo_path': photoPath,
      if (bio != null) 'bio': bio,
      if (birthDate != null) 'birth_date': birthDate,
      if (deathDate != null) 'death_date': deathDate,
      if (isGhost != null) 'is_ghost': isGhost,
      if (temperature != null) 'temperature': temperature,
      if (positionX != null) 'position_x': positionX,
      if (positionY != null) 'position_y': positionY,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NodesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? nickname,
    Value<String?>? photoPath,
    Value<String?>? bio,
    Value<DateTime?>? birthDate,
    Value<DateTime?>? deathDate,
    Value<bool>? isGhost,
    Value<int>? temperature,
    Value<double>? positionX,
    Value<double>? positionY,
    Value<String>? tagsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NodesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      bio: bio ?? this.bio,
      birthDate: birthDate ?? this.birthDate,
      deathDate: deathDate ?? this.deathDate,
      isGhost: isGhost ?? this.isGhost,
      temperature: temperature ?? this.temperature,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      tagsJson: tagsJson ?? this.tagsJson,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (deathDate.present) {
      map['death_date'] = Variable<DateTime>(deathDate.value);
    }
    if (isGhost.present) {
      map['is_ghost'] = Variable<bool>(isGhost.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<int>(temperature.value);
    }
    if (positionX.present) {
      map['position_x'] = Variable<double>(positionX.value);
    }
    if (positionY.present) {
      map['position_y'] = Variable<double>(positionY.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
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
    return (StringBuffer('NodesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('bio: $bio, ')
          ..write('birthDate: $birthDate, ')
          ..write('deathDate: $deathDate, ')
          ..write('isGhost: $isGhost, ')
          ..write('temperature: $temperature, ')
          ..write('positionX: $positionX, ')
          ..write('positionY: $positionY, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NodeEdgesTableTable extends NodeEdgesTable
    with TableInfo<$NodeEdgesTableTable, NodeEdgesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodeEdgesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromNodeIdMeta = const VerificationMeta(
    'fromNodeId',
  );
  @override
  late final GeneratedColumn<String> fromNodeId = GeneratedColumn<String>(
    'from_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _toNodeIdMeta = const VerificationMeta(
    'toNodeId',
  );
  @override
  late final GeneratedColumn<String> toNodeId = GeneratedColumn<String>(
    'to_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nodes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromNodeId,
    toNodeId,
    relation,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'node_edges';
  @override
  VerificationContext validateIntegrity(
    Insertable<NodeEdgesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_node_id')) {
      context.handle(
        _fromNodeIdMeta,
        fromNodeId.isAcceptableOrUnknown(
          data['from_node_id']!,
          _fromNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromNodeIdMeta);
    }
    if (data.containsKey('to_node_id')) {
      context.handle(
        _toNodeIdMeta,
        toNodeId.isAcceptableOrUnknown(data['to_node_id']!, _toNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toNodeIdMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NodeEdgesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NodeEdgesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_node_id'],
      )!,
      toNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_node_id'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NodeEdgesTableTable createAlias(String alias) {
    return $NodeEdgesTableTable(attachedDatabase, alias);
  }
}

class NodeEdgesTableData extends DataClass
    implements Insertable<NodeEdgesTableData> {
  final String id;
  final String fromNodeId;
  final String toNodeId;

  /// 관계 타입: parent, child, spouse, sibling, other
  final String relation;
  final String? label;
  final DateTime createdAt;
  const NodeEdgesTableData({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.relation,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_node_id'] = Variable<String>(fromNodeId);
    map['to_node_id'] = Variable<String>(toNodeId);
    map['relation'] = Variable<String>(relation);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NodeEdgesTableCompanion toCompanion(bool nullToAbsent) {
    return NodeEdgesTableCompanion(
      id: Value(id),
      fromNodeId: Value(fromNodeId),
      toNodeId: Value(toNodeId),
      relation: Value(relation),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory NodeEdgesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NodeEdgesTableData(
      id: serializer.fromJson<String>(json['id']),
      fromNodeId: serializer.fromJson<String>(json['fromNodeId']),
      toNodeId: serializer.fromJson<String>(json['toNodeId']),
      relation: serializer.fromJson<String>(json['relation']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromNodeId': serializer.toJson<String>(fromNodeId),
      'toNodeId': serializer.toJson<String>(toNodeId),
      'relation': serializer.toJson<String>(relation),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NodeEdgesTableData copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    String? relation,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => NodeEdgesTableData(
    id: id ?? this.id,
    fromNodeId: fromNodeId ?? this.fromNodeId,
    toNodeId: toNodeId ?? this.toNodeId,
    relation: relation ?? this.relation,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  NodeEdgesTableData copyWithCompanion(NodeEdgesTableCompanion data) {
    return NodeEdgesTableData(
      id: data.id.present ? data.id.value : this.id,
      fromNodeId: data.fromNodeId.present
          ? data.fromNodeId.value
          : this.fromNodeId,
      toNodeId: data.toNodeId.present ? data.toNodeId.value : this.toNodeId,
      relation: data.relation.present ? data.relation.value : this.relation,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NodeEdgesTableData(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('relation: $relation, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromNodeId, toNodeId, relation, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NodeEdgesTableData &&
          other.id == this.id &&
          other.fromNodeId == this.fromNodeId &&
          other.toNodeId == this.toNodeId &&
          other.relation == this.relation &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class NodeEdgesTableCompanion extends UpdateCompanion<NodeEdgesTableData> {
  final Value<String> id;
  final Value<String> fromNodeId;
  final Value<String> toNodeId;
  final Value<String> relation;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NodeEdgesTableCompanion({
    this.id = const Value.absent(),
    this.fromNodeId = const Value.absent(),
    this.toNodeId = const Value.absent(),
    this.relation = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NodeEdgesTableCompanion.insert({
    required String id,
    required String fromNodeId,
    required String toNodeId,
    required String relation,
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromNodeId = Value(fromNodeId),
       toNodeId = Value(toNodeId),
       relation = Value(relation);
  static Insertable<NodeEdgesTableData> custom({
    Expression<String>? id,
    Expression<String>? fromNodeId,
    Expression<String>? toNodeId,
    Expression<String>? relation,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromNodeId != null) 'from_node_id': fromNodeId,
      if (toNodeId != null) 'to_node_id': toNodeId,
      if (relation != null) 'relation': relation,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NodeEdgesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? fromNodeId,
    Value<String>? toNodeId,
    Value<String>? relation,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NodeEdgesTableCompanion(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      relation: relation ?? this.relation,
      label: label ?? this.label,
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
    if (fromNodeId.present) {
      map['from_node_id'] = Variable<String>(fromNodeId.value);
    }
    if (toNodeId.present) {
      map['to_node_id'] = Variable<String>(toNodeId.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
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
    return (StringBuffer('NodeEdgesTableCompanion(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('relation: $relation, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoriesTableTable extends MemoriesTable
    with TableInfo<$MemoriesTableTable, MemoriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES nodes (id) ON DELETE CASCADE',
    ),
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
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thumbnailPathMeta = const VerificationMeta(
    'thumbnailPath',
  );
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
    'thumbnail_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateTakenMeta = const VerificationMeta(
    'dateTaken',
  );
  @override
  late final GeneratedColumn<DateTime> dateTaken = GeneratedColumn<DateTime>(
    'date_taken',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsJsonMeta = const VerificationMeta(
    'tagsJson',
  );
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
    'tags_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  static const VerificationMeta _isPrivateMeta = const VerificationMeta(
    'isPrivate',
  );
  @override
  late final GeneratedColumn<bool> isPrivate = GeneratedColumn<bool>(
    'is_private',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_private" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeId,
    type,
    title,
    description,
    filePath,
    thumbnailPath,
    durationSeconds,
    dateTaken,
    tagsJson,
    createdAt,
    isPrivate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemoriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
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
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
        _thumbnailPathMeta,
        thumbnailPath.isAcceptableOrUnknown(
          data['thumbnail_path']!,
          _thumbnailPathMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('date_taken')) {
      context.handle(
        _dateTakenMeta,
        dateTaken.isAcceptableOrUnknown(data['date_taken']!, _dateTakenMeta),
      );
    }
    if (data.containsKey('tags_json')) {
      context.handle(
        _tagsJsonMeta,
        tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('is_private')) {
      context.handle(
        _isPrivateMeta,
        isPrivate.isAcceptableOrUnknown(data['is_private']!, _isPrivateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      thumbnailPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnail_path'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      ),
      dateTaken: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_taken'],
      ),
      tagsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      isPrivate: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_private'],
      )!,
    );
  }

  @override
  $MemoriesTableTable createAlias(String alias) {
    return $MemoriesTableTable(attachedDatabase, alias);
  }
}

class MemoriesTableData extends DataClass
    implements Insertable<MemoriesTableData> {
  final String id;
  final String nodeId;

  /// 타입: photo, voice, note, ai
  final String type;
  final String? title;
  final String? description;

  /// 로컬 파일 경로 (사진/음성)
  final String? filePath;
  final String? thumbnailPath;

  /// 음성 길이 (초)
  final int? durationSeconds;
  final DateTime? dateTaken;
  final String tagsJson;
  final DateTime createdAt;

  /// Privacy Layer: 개인 메모 잠금 여부
  final bool isPrivate;
  const MemoriesTableData({
    required this.id,
    required this.nodeId,
    required this.type,
    this.title,
    this.description,
    this.filePath,
    this.thumbnailPath,
    this.durationSeconds,
    this.dateTaken,
    required this.tagsJson,
    required this.createdAt,
    required this.isPrivate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['node_id'] = Variable<String>(nodeId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || thumbnailPath != null) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath);
    }
    if (!nullToAbsent || durationSeconds != null) {
      map['duration_seconds'] = Variable<int>(durationSeconds);
    }
    if (!nullToAbsent || dateTaken != null) {
      map['date_taken'] = Variable<DateTime>(dateTaken);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_private'] = Variable<bool>(isPrivate);
    return map;
  }

  MemoriesTableCompanion toCompanion(bool nullToAbsent) {
    return MemoriesTableCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      type: Value(type),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      thumbnailPath: thumbnailPath == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnailPath),
      durationSeconds: durationSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(durationSeconds),
      dateTaken: dateTaken == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTaken),
      tagsJson: Value(tagsJson),
      createdAt: Value(createdAt),
      isPrivate: Value(isPrivate),
    );
  }

  factory MemoriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoriesTableData(
      id: serializer.fromJson<String>(json['id']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      thumbnailPath: serializer.fromJson<String?>(json['thumbnailPath']),
      durationSeconds: serializer.fromJson<int?>(json['durationSeconds']),
      dateTaken: serializer.fromJson<DateTime?>(json['dateTaken']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isPrivate: serializer.fromJson<bool>(json['isPrivate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nodeId': serializer.toJson<String>(nodeId),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'filePath': serializer.toJson<String?>(filePath),
      'thumbnailPath': serializer.toJson<String?>(thumbnailPath),
      'durationSeconds': serializer.toJson<int?>(durationSeconds),
      'dateTaken': serializer.toJson<DateTime?>(dateTaken),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isPrivate': serializer.toJson<bool>(isPrivate),
    };
  }

  MemoriesTableData copyWith({
    String? id,
    String? nodeId,
    String? type,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> filePath = const Value.absent(),
    Value<String?> thumbnailPath = const Value.absent(),
    Value<int?> durationSeconds = const Value.absent(),
    Value<DateTime?> dateTaken = const Value.absent(),
    String? tagsJson,
    DateTime? createdAt,
    bool? isPrivate,
  }) => MemoriesTableData(
    id: id ?? this.id,
    nodeId: nodeId ?? this.nodeId,
    type: type ?? this.type,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    filePath: filePath.present ? filePath.value : this.filePath,
    thumbnailPath: thumbnailPath.present
        ? thumbnailPath.value
        : this.thumbnailPath,
    durationSeconds: durationSeconds.present
        ? durationSeconds.value
        : this.durationSeconds,
    dateTaken: dateTaken.present ? dateTaken.value : this.dateTaken,
    tagsJson: tagsJson ?? this.tagsJson,
    createdAt: createdAt ?? this.createdAt,
    isPrivate: isPrivate ?? this.isPrivate,
  );
  MemoriesTableData copyWithCompanion(MemoriesTableCompanion data) {
    return MemoriesTableData(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      dateTaken: data.dateTaken.present ? data.dateTaken.value : this.dateTaken,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isPrivate: data.isPrivate.present ? data.isPrivate.value : this.isPrivate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesTableData(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('filePath: $filePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('dateTaken: $dateTaken, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isPrivate: $isPrivate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nodeId,
    type,
    title,
    description,
    filePath,
    thumbnailPath,
    durationSeconds,
    dateTaken,
    tagsJson,
    createdAt,
    isPrivate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoriesTableData &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.type == this.type &&
          other.title == this.title &&
          other.description == this.description &&
          other.filePath == this.filePath &&
          other.thumbnailPath == this.thumbnailPath &&
          other.durationSeconds == this.durationSeconds &&
          other.dateTaken == this.dateTaken &&
          other.tagsJson == this.tagsJson &&
          other.createdAt == this.createdAt &&
          other.isPrivate == this.isPrivate);
}

class MemoriesTableCompanion extends UpdateCompanion<MemoriesTableData> {
  final Value<String> id;
  final Value<String> nodeId;
  final Value<String> type;
  final Value<String?> title;
  final Value<String?> description;
  final Value<String?> filePath;
  final Value<String?> thumbnailPath;
  final Value<int?> durationSeconds;
  final Value<DateTime?> dateTaken;
  final Value<String> tagsJson;
  final Value<DateTime> createdAt;
  final Value<bool> isPrivate;
  final Value<int> rowid;
  const MemoriesTableCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.filePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.dateTaken = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesTableCompanion.insert({
    required String id,
    required String nodeId,
    required String type,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.filePath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.dateTaken = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isPrivate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nodeId = Value(nodeId),
       type = Value(type);
  static Insertable<MemoriesTableData> custom({
    Expression<String>? id,
    Expression<String>? nodeId,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? filePath,
    Expression<String>? thumbnailPath,
    Expression<int>? durationSeconds,
    Expression<DateTime>? dateTaken,
    Expression<String>? tagsJson,
    Expression<DateTime>? createdAt,
    Expression<bool>? isPrivate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (filePath != null) 'file_path': filePath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (dateTaken != null) 'date_taken': dateTaken,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (isPrivate != null) 'is_private': isPrivate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? nodeId,
    Value<String>? type,
    Value<String?>? title,
    Value<String?>? description,
    Value<String?>? filePath,
    Value<String?>? thumbnailPath,
    Value<int?>? durationSeconds,
    Value<DateTime?>? dateTaken,
    Value<String>? tagsJson,
    Value<DateTime>? createdAt,
    Value<bool>? isPrivate,
    Value<int>? rowid,
  }) {
    return MemoriesTableCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      dateTaken: dateTaken ?? this.dateTaken,
      tagsJson: tagsJson ?? this.tagsJson,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (dateTaken.present) {
      map['date_taken'] = Variable<DateTime>(dateTaken.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isPrivate.present) {
      map['is_private'] = Variable<bool>(isPrivate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesTableCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('filePath: $filePath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('dateTaken: $dateTaken, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('isPrivate: $isPrivate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
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
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const SettingsTableData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SettingsTableData copyWith({
    String? key,
    String? value,
    DateTime? updatedAt,
  }) => SettingsTableData(
    key: key ?? this.key,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
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
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemperatureLogsTableTable extends TemperatureLogsTable
    with TableInfo<$TemperatureLogsTableTable, TemperatureLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemperatureLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<int> temperature = GeneratedColumn<int>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emotionTagMeta = const VerificationMeta(
    'emotionTag',
  );
  @override
  late final GeneratedColumn<String> emotionTag = GeneratedColumn<String>(
    'emotion_tag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeId,
    temperature,
    emotionTag,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temperature_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemperatureLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('emotion_tag')) {
      context.handle(
        _emotionTagMeta,
        emotionTag.isAcceptableOrUnknown(data['emotion_tag']!, _emotionTagMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemperatureLogsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemperatureLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}temperature'],
      )!,
      emotionTag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion_tag'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TemperatureLogsTableTable createAlias(String alias) {
    return $TemperatureLogsTableTable(attachedDatabase, alias);
  }
}

class TemperatureLogsTableData extends DataClass
    implements Insertable<TemperatureLogsTableData> {
  final String id;
  final String nodeId;
  final int temperature;
  final String? emotionTag;
  final DateTime date;
  final DateTime createdAt;
  const TemperatureLogsTableData({
    required this.id,
    required this.nodeId,
    required this.temperature,
    this.emotionTag,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['node_id'] = Variable<String>(nodeId);
    map['temperature'] = Variable<int>(temperature);
    if (!nullToAbsent || emotionTag != null) {
      map['emotion_tag'] = Variable<String>(emotionTag);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TemperatureLogsTableCompanion toCompanion(bool nullToAbsent) {
    return TemperatureLogsTableCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      temperature: Value(temperature),
      emotionTag: emotionTag == null && nullToAbsent
          ? const Value.absent()
          : Value(emotionTag),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory TemperatureLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemperatureLogsTableData(
      id: serializer.fromJson<String>(json['id']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      temperature: serializer.fromJson<int>(json['temperature']),
      emotionTag: serializer.fromJson<String?>(json['emotionTag']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nodeId': serializer.toJson<String>(nodeId),
      'temperature': serializer.toJson<int>(temperature),
      'emotionTag': serializer.toJson<String?>(emotionTag),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TemperatureLogsTableData copyWith({
    String? id,
    String? nodeId,
    int? temperature,
    Value<String?> emotionTag = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
  }) => TemperatureLogsTableData(
    id: id ?? this.id,
    nodeId: nodeId ?? this.nodeId,
    temperature: temperature ?? this.temperature,
    emotionTag: emotionTag.present ? emotionTag.value : this.emotionTag,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  TemperatureLogsTableData copyWithCompanion(
    TemperatureLogsTableCompanion data,
  ) {
    return TemperatureLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      emotionTag: data.emotionTag.present
          ? data.emotionTag.value
          : this.emotionTag,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemperatureLogsTableData(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('temperature: $temperature, ')
          ..write('emotionTag: $emotionTag, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nodeId, temperature, emotionTag, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemperatureLogsTableData &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.temperature == this.temperature &&
          other.emotionTag == this.emotionTag &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class TemperatureLogsTableCompanion
    extends UpdateCompanion<TemperatureLogsTableData> {
  final Value<String> id;
  final Value<String> nodeId;
  final Value<int> temperature;
  final Value<String?> emotionTag;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TemperatureLogsTableCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.temperature = const Value.absent(),
    this.emotionTag = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemperatureLogsTableCompanion.insert({
    required String id,
    required String nodeId,
    required int temperature,
    this.emotionTag = const Value.absent(),
    required DateTime date,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nodeId = Value(nodeId),
       temperature = Value(temperature),
       date = Value(date);
  static Insertable<TemperatureLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? nodeId,
    Expression<int>? temperature,
    Expression<String>? emotionTag,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (temperature != null) 'temperature': temperature,
      if (emotionTag != null) 'emotion_tag': emotionTag,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemperatureLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? nodeId,
    Value<int>? temperature,
    Value<String?>? emotionTag,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TemperatureLogsTableCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      temperature: temperature ?? this.temperature,
      emotionTag: emotionTag ?? this.emotionTag,
      date: date ?? this.date,
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
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<int>(temperature.value);
    }
    if (emotionTag.present) {
      map['emotion_tag'] = Variable<String>(emotionTag.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
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
    return (StringBuffer('TemperatureLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('temperature: $temperature, ')
          ..write('emotionTag: $emotionTag, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BouquetsTableTable extends BouquetsTable
    with TableInfo<$BouquetsTableTable, BouquetsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BouquetsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromNodeIdMeta = const VerificationMeta(
    'fromNodeId',
  );
  @override
  late final GeneratedColumn<String> fromNodeId = GeneratedColumn<String>(
    'from_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toNodeIdMeta = const VerificationMeta(
    'toNodeId',
  );
  @override
  late final GeneratedColumn<String> toNodeId = GeneratedColumn<String>(
    'to_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flowerTypeMeta = const VerificationMeta(
    'flowerType',
  );
  @override
  late final GeneratedColumn<String> flowerType = GeneratedColumn<String>(
    'flower_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromNodeId,
    toNodeId,
    flowerType,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bouquets';
  @override
  VerificationContext validateIntegrity(
    Insertable<BouquetsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_node_id')) {
      context.handle(
        _fromNodeIdMeta,
        fromNodeId.isAcceptableOrUnknown(
          data['from_node_id']!,
          _fromNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromNodeIdMeta);
    }
    if (data.containsKey('to_node_id')) {
      context.handle(
        _toNodeIdMeta,
        toNodeId.isAcceptableOrUnknown(data['to_node_id']!, _toNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toNodeIdMeta);
    }
    if (data.containsKey('flower_type')) {
      context.handle(
        _flowerTypeMeta,
        flowerType.isAcceptableOrUnknown(data['flower_type']!, _flowerTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_flowerTypeMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BouquetsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BouquetsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_node_id'],
      )!,
      toNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_node_id'],
      )!,
      flowerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flower_type'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BouquetsTableTable createAlias(String alias) {
    return $BouquetsTableTable(attachedDatabase, alias);
  }
}

class BouquetsTableData extends DataClass
    implements Insertable<BouquetsTableData> {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String flowerType;
  final DateTime date;
  final DateTime createdAt;
  const BouquetsTableData({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.flowerType,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_node_id'] = Variable<String>(fromNodeId);
    map['to_node_id'] = Variable<String>(toNodeId);
    map['flower_type'] = Variable<String>(flowerType);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BouquetsTableCompanion toCompanion(bool nullToAbsent) {
    return BouquetsTableCompanion(
      id: Value(id),
      fromNodeId: Value(fromNodeId),
      toNodeId: Value(toNodeId),
      flowerType: Value(flowerType),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory BouquetsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BouquetsTableData(
      id: serializer.fromJson<String>(json['id']),
      fromNodeId: serializer.fromJson<String>(json['fromNodeId']),
      toNodeId: serializer.fromJson<String>(json['toNodeId']),
      flowerType: serializer.fromJson<String>(json['flowerType']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromNodeId': serializer.toJson<String>(fromNodeId),
      'toNodeId': serializer.toJson<String>(toNodeId),
      'flowerType': serializer.toJson<String>(flowerType),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BouquetsTableData copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    String? flowerType,
    DateTime? date,
    DateTime? createdAt,
  }) => BouquetsTableData(
    id: id ?? this.id,
    fromNodeId: fromNodeId ?? this.fromNodeId,
    toNodeId: toNodeId ?? this.toNodeId,
    flowerType: flowerType ?? this.flowerType,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  BouquetsTableData copyWithCompanion(BouquetsTableCompanion data) {
    return BouquetsTableData(
      id: data.id.present ? data.id.value : this.id,
      fromNodeId: data.fromNodeId.present
          ? data.fromNodeId.value
          : this.fromNodeId,
      toNodeId: data.toNodeId.present ? data.toNodeId.value : this.toNodeId,
      flowerType: data.flowerType.present
          ? data.flowerType.value
          : this.flowerType,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BouquetsTableData(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('flowerType: $flowerType, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, fromNodeId, toNodeId, flowerType, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BouquetsTableData &&
          other.id == this.id &&
          other.fromNodeId == this.fromNodeId &&
          other.toNodeId == this.toNodeId &&
          other.flowerType == this.flowerType &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class BouquetsTableCompanion extends UpdateCompanion<BouquetsTableData> {
  final Value<String> id;
  final Value<String> fromNodeId;
  final Value<String> toNodeId;
  final Value<String> flowerType;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BouquetsTableCompanion({
    this.id = const Value.absent(),
    this.fromNodeId = const Value.absent(),
    this.toNodeId = const Value.absent(),
    this.flowerType = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BouquetsTableCompanion.insert({
    required String id,
    required String fromNodeId,
    required String toNodeId,
    required String flowerType,
    required DateTime date,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromNodeId = Value(fromNodeId),
       toNodeId = Value(toNodeId),
       flowerType = Value(flowerType),
       date = Value(date);
  static Insertable<BouquetsTableData> custom({
    Expression<String>? id,
    Expression<String>? fromNodeId,
    Expression<String>? toNodeId,
    Expression<String>? flowerType,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromNodeId != null) 'from_node_id': fromNodeId,
      if (toNodeId != null) 'to_node_id': toNodeId,
      if (flowerType != null) 'flower_type': flowerType,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BouquetsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? fromNodeId,
    Value<String>? toNodeId,
    Value<String>? flowerType,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BouquetsTableCompanion(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      flowerType: flowerType ?? this.flowerType,
      date: date ?? this.date,
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
    if (fromNodeId.present) {
      map['from_node_id'] = Variable<String>(fromNodeId.value);
    }
    if (toNodeId.present) {
      map['to_node_id'] = Variable<String>(toNodeId.value);
    }
    if (flowerType.present) {
      map['flower_type'] = Variable<String>(flowerType.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
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
    return (StringBuffer('BouquetsTableCompanion(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('flowerType: $flowerType, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapsulesTableTable extends CapsulesTable
    with TableInfo<$CapsulesTableTable, CapsulesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapsulesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openDateMeta = const VerificationMeta(
    'openDate',
  );
  @override
  late final GeneratedColumn<DateTime> openDate = GeneratedColumn<DateTime>(
    'open_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOpenedMeta = const VerificationMeta(
    'isOpened',
  );
  @override
  late final GeneratedColumn<bool> isOpened = GeneratedColumn<bool>(
    'is_opened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_opened" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    message,
    openDate,
    isOpened,
    openedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capsules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapsulesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    }
    if (data.containsKey('open_date')) {
      context.handle(
        _openDateMeta,
        openDate.isAcceptableOrUnknown(data['open_date']!, _openDateMeta),
      );
    } else if (isInserting) {
      context.missing(_openDateMeta);
    }
    if (data.containsKey('is_opened')) {
      context.handle(
        _isOpenedMeta,
        isOpened.isAcceptableOrUnknown(data['is_opened']!, _isOpenedMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapsulesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapsulesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      ),
      openDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}open_date'],
      )!,
      isOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_opened'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CapsulesTableTable createAlias(String alias) {
    return $CapsulesTableTable(attachedDatabase, alias);
  }
}

class CapsulesTableData extends DataClass
    implements Insertable<CapsulesTableData> {
  final String id;
  final String title;
  final String? message;
  final DateTime openDate;
  final bool isOpened;
  final DateTime? openedAt;
  final DateTime createdAt;
  const CapsulesTableData({
    required this.id,
    required this.title,
    this.message,
    required this.openDate,
    required this.isOpened,
    this.openedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || message != null) {
      map['message'] = Variable<String>(message);
    }
    map['open_date'] = Variable<DateTime>(openDate);
    map['is_opened'] = Variable<bool>(isOpened);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CapsulesTableCompanion toCompanion(bool nullToAbsent) {
    return CapsulesTableCompanion(
      id: Value(id),
      title: Value(title),
      message: message == null && nullToAbsent
          ? const Value.absent()
          : Value(message),
      openDate: Value(openDate),
      isOpened: Value(isOpened),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      createdAt: Value(createdAt),
    );
  }

  factory CapsulesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapsulesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String?>(json['message']),
      openDate: serializer.fromJson<DateTime>(json['openDate']),
      isOpened: serializer.fromJson<bool>(json['isOpened']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String?>(message),
      'openDate': serializer.toJson<DateTime>(openDate),
      'isOpened': serializer.toJson<bool>(isOpened),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CapsulesTableData copyWith({
    String? id,
    String? title,
    Value<String?> message = const Value.absent(),
    DateTime? openDate,
    bool? isOpened,
    Value<DateTime?> openedAt = const Value.absent(),
    DateTime? createdAt,
  }) => CapsulesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    message: message.present ? message.value : this.message,
    openDate: openDate ?? this.openDate,
    isOpened: isOpened ?? this.isOpened,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  CapsulesTableData copyWithCompanion(CapsulesTableCompanion data) {
    return CapsulesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      openDate: data.openDate.present ? data.openDate.value : this.openDate,
      isOpened: data.isOpened.present ? data.isOpened.value : this.isOpened,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapsulesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('openDate: $openDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedAt: $openedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, message, openDate, isOpened, openedAt, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapsulesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.message == this.message &&
          other.openDate == this.openDate &&
          other.isOpened == this.isOpened &&
          other.openedAt == this.openedAt &&
          other.createdAt == this.createdAt);
}

class CapsulesTableCompanion extends UpdateCompanion<CapsulesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> message;
  final Value<DateTime> openDate;
  final Value<bool> isOpened;
  final Value<DateTime?> openedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CapsulesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.openDate = const Value.absent(),
    this.isOpened = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapsulesTableCompanion.insert({
    required String id,
    required String title,
    this.message = const Value.absent(),
    required DateTime openDate,
    this.isOpened = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       openDate = Value(openDate);
  static Insertable<CapsulesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? message,
    Expression<DateTime>? openDate,
    Expression<bool>? isOpened,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (openDate != null) 'open_date': openDate,
      if (isOpened != null) 'is_opened': isOpened,
      if (openedAt != null) 'opened_at': openedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapsulesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? message,
    Value<DateTime>? openDate,
    Value<bool>? isOpened,
    Value<DateTime?>? openedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CapsulesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      openDate: openDate ?? this.openDate,
      isOpened: isOpened ?? this.isOpened,
      openedAt: openedAt ?? this.openedAt,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (openDate.present) {
      map['open_date'] = Variable<DateTime>(openDate.value);
    }
    if (isOpened.present) {
      map['is_opened'] = Variable<bool>(isOpened.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
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
    return (StringBuffer('CapsulesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('openDate: $openDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedAt: $openedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CapsuleItemsTableTable extends CapsuleItemsTable
    with TableInfo<$CapsuleItemsTableTable, CapsuleItemsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CapsuleItemsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capsuleIdMeta = const VerificationMeta(
    'capsuleId',
  );
  @override
  late final GeneratedColumn<String> capsuleId = GeneratedColumn<String>(
    'capsule_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryIdMeta = const VerificationMeta(
    'memoryId',
  );
  @override
  late final GeneratedColumn<String> memoryId = GeneratedColumn<String>(
    'memory_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, capsuleId, memoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capsule_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CapsuleItemsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('capsule_id')) {
      context.handle(
        _capsuleIdMeta,
        capsuleId.isAcceptableOrUnknown(data['capsule_id']!, _capsuleIdMeta),
      );
    } else if (isInserting) {
      context.missing(_capsuleIdMeta);
    }
    if (data.containsKey('memory_id')) {
      context.handle(
        _memoryIdMeta,
        memoryId.isAcceptableOrUnknown(data['memory_id']!, _memoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_memoryIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CapsuleItemsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CapsuleItemsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      capsuleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capsule_id'],
      )!,
      memoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id'],
      )!,
    );
  }

  @override
  $CapsuleItemsTableTable createAlias(String alias) {
    return $CapsuleItemsTableTable(attachedDatabase, alias);
  }
}

class CapsuleItemsTableData extends DataClass
    implements Insertable<CapsuleItemsTableData> {
  final String id;
  final String capsuleId;
  final String memoryId;
  const CapsuleItemsTableData({
    required this.id,
    required this.capsuleId,
    required this.memoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['capsule_id'] = Variable<String>(capsuleId);
    map['memory_id'] = Variable<String>(memoryId);
    return map;
  }

  CapsuleItemsTableCompanion toCompanion(bool nullToAbsent) {
    return CapsuleItemsTableCompanion(
      id: Value(id),
      capsuleId: Value(capsuleId),
      memoryId: Value(memoryId),
    );
  }

  factory CapsuleItemsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CapsuleItemsTableData(
      id: serializer.fromJson<String>(json['id']),
      capsuleId: serializer.fromJson<String>(json['capsuleId']),
      memoryId: serializer.fromJson<String>(json['memoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'capsuleId': serializer.toJson<String>(capsuleId),
      'memoryId': serializer.toJson<String>(memoryId),
    };
  }

  CapsuleItemsTableData copyWith({
    String? id,
    String? capsuleId,
    String? memoryId,
  }) => CapsuleItemsTableData(
    id: id ?? this.id,
    capsuleId: capsuleId ?? this.capsuleId,
    memoryId: memoryId ?? this.memoryId,
  );
  CapsuleItemsTableData copyWithCompanion(CapsuleItemsTableCompanion data) {
    return CapsuleItemsTableData(
      id: data.id.present ? data.id.value : this.id,
      capsuleId: data.capsuleId.present ? data.capsuleId.value : this.capsuleId,
      memoryId: data.memoryId.present ? data.memoryId.value : this.memoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CapsuleItemsTableData(')
          ..write('id: $id, ')
          ..write('capsuleId: $capsuleId, ')
          ..write('memoryId: $memoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, capsuleId, memoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CapsuleItemsTableData &&
          other.id == this.id &&
          other.capsuleId == this.capsuleId &&
          other.memoryId == this.memoryId);
}

class CapsuleItemsTableCompanion
    extends UpdateCompanion<CapsuleItemsTableData> {
  final Value<String> id;
  final Value<String> capsuleId;
  final Value<String> memoryId;
  final Value<int> rowid;
  const CapsuleItemsTableCompanion({
    this.id = const Value.absent(),
    this.capsuleId = const Value.absent(),
    this.memoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CapsuleItemsTableCompanion.insert({
    required String id,
    required String capsuleId,
    required String memoryId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       capsuleId = Value(capsuleId),
       memoryId = Value(memoryId);
  static Insertable<CapsuleItemsTableData> custom({
    Expression<String>? id,
    Expression<String>? capsuleId,
    Expression<String>? memoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (capsuleId != null) 'capsule_id': capsuleId,
      if (memoryId != null) 'memory_id': memoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CapsuleItemsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? capsuleId,
    Value<String>? memoryId,
    Value<int>? rowid,
  }) {
    return CapsuleItemsTableCompanion(
      id: id ?? this.id,
      capsuleId: capsuleId ?? this.capsuleId,
      memoryId: memoryId ?? this.memoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (capsuleId.present) {
      map['capsule_id'] = Variable<String>(capsuleId.value);
    }
    if (memoryId.present) {
      map['memory_id'] = Variable<String>(memoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CapsuleItemsTableCompanion(')
          ..write('id: $id, ')
          ..write('capsuleId: $capsuleId, ')
          ..write('memoryId: $memoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemorialMessagesTableTable extends MemorialMessagesTable
    with TableInfo<$MemorialMessagesTableTable, MemorialMessagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemorialMessagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _messageMeta = const VerificationMeta(
    'message',
  );
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
    'message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _authorNameMeta = const VerificationMeta(
    'authorName',
  );
  @override
  late final GeneratedColumn<String> authorName = GeneratedColumn<String>(
    'author_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeId,
    message,
    authorName,
    date,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memorial_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MemorialMessagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('message')) {
      context.handle(
        _messageMeta,
        message.isAcceptableOrUnknown(data['message']!, _messageMeta),
      );
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('author_name')) {
      context.handle(
        _authorNameMeta,
        authorName.isAcceptableOrUnknown(data['author_name']!, _authorNameMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemorialMessagesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemorialMessagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      message: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message'],
      )!,
      authorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author_name'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $MemorialMessagesTableTable createAlias(String alias) {
    return $MemorialMessagesTableTable(attachedDatabase, alias);
  }
}

class MemorialMessagesTableData extends DataClass
    implements Insertable<MemorialMessagesTableData> {
  final String id;
  final String nodeId;
  final String message;
  final String? authorName;
  final DateTime date;
  final DateTime createdAt;
  const MemorialMessagesTableData({
    required this.id,
    required this.nodeId,
    required this.message,
    this.authorName,
    required this.date,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['node_id'] = Variable<String>(nodeId);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || authorName != null) {
      map['author_name'] = Variable<String>(authorName);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MemorialMessagesTableCompanion toCompanion(bool nullToAbsent) {
    return MemorialMessagesTableCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      message: Value(message),
      authorName: authorName == null && nullToAbsent
          ? const Value.absent()
          : Value(authorName),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory MemorialMessagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemorialMessagesTableData(
      id: serializer.fromJson<String>(json['id']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      message: serializer.fromJson<String>(json['message']),
      authorName: serializer.fromJson<String?>(json['authorName']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nodeId': serializer.toJson<String>(nodeId),
      'message': serializer.toJson<String>(message),
      'authorName': serializer.toJson<String?>(authorName),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MemorialMessagesTableData copyWith({
    String? id,
    String? nodeId,
    String? message,
    Value<String?> authorName = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
  }) => MemorialMessagesTableData(
    id: id ?? this.id,
    nodeId: nodeId ?? this.nodeId,
    message: message ?? this.message,
    authorName: authorName.present ? authorName.value : this.authorName,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
  );
  MemorialMessagesTableData copyWithCompanion(
    MemorialMessagesTableCompanion data,
  ) {
    return MemorialMessagesTableData(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      message: data.message.present ? data.message.value : this.message,
      authorName: data.authorName.present
          ? data.authorName.value
          : this.authorName,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemorialMessagesTableData(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('message: $message, ')
          ..write('authorName: $authorName, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nodeId, message, authorName, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemorialMessagesTableData &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.message == this.message &&
          other.authorName == this.authorName &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class MemorialMessagesTableCompanion
    extends UpdateCompanion<MemorialMessagesTableData> {
  final Value<String> id;
  final Value<String> nodeId;
  final Value<String> message;
  final Value<String?> authorName;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MemorialMessagesTableCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.message = const Value.absent(),
    this.authorName = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemorialMessagesTableCompanion.insert({
    required String id,
    required String nodeId,
    required String message,
    this.authorName = const Value.absent(),
    required DateTime date,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nodeId = Value(nodeId),
       message = Value(message),
       date = Value(date);
  static Insertable<MemorialMessagesTableData> custom({
    Expression<String>? id,
    Expression<String>? nodeId,
    Expression<String>? message,
    Expression<String>? authorName,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (message != null) 'message': message,
      if (authorName != null) 'author_name': authorName,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemorialMessagesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? nodeId,
    Value<String>? message,
    Value<String?>? authorName,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return MemorialMessagesTableCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      message: message ?? this.message,
      authorName: authorName ?? this.authorName,
      date: date ?? this.date,
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
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (authorName.present) {
      map['author_name'] = Variable<String>(authorName.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
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
    return (StringBuffer('MemorialMessagesTableCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('message: $message, ')
          ..write('authorName: $authorName, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GlossaryTableTable extends GlossaryTable
    with TableInfo<$GlossaryTableTable, GlossaryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlossaryTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  @override
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  @override
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voicePathMeta = const VerificationMeta(
    'voicePath',
  );
  @override
  late final GeneratedColumn<String> voicePath = GeneratedColumn<String>(
    'voice_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    meaning,
    example,
    voicePath,
    nodeId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'glossary';
  @override
  VerificationContext validateIntegrity(
    Insertable<GlossaryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('meaning')) {
      context.handle(
        _meaningMeta,
        meaning.isAcceptableOrUnknown(data['meaning']!, _meaningMeta),
      );
    } else if (isInserting) {
      context.missing(_meaningMeta);
    }
    if (data.containsKey('example')) {
      context.handle(
        _exampleMeta,
        example.isAcceptableOrUnknown(data['example']!, _exampleMeta),
      );
    }
    if (data.containsKey('voice_path')) {
      context.handle(
        _voicePathMeta,
        voicePath.isAcceptableOrUnknown(data['voice_path']!, _voicePathMeta),
      );
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GlossaryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlossaryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      voicePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_path'],
      ),
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $GlossaryTableTable createAlias(String alias) {
    return $GlossaryTableTable(attachedDatabase, alias);
  }
}

class GlossaryTableData extends DataClass
    implements Insertable<GlossaryTableData> {
  final String id;
  final String word;
  final String meaning;
  final String? example;
  final String? voicePath;
  final String? nodeId;
  final DateTime createdAt;
  const GlossaryTableData({
    required this.id,
    required this.word,
    required this.meaning,
    this.example,
    this.voicePath,
    this.nodeId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['word'] = Variable<String>(word);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    if (!nullToAbsent || voicePath != null) {
      map['voice_path'] = Variable<String>(voicePath);
    }
    if (!nullToAbsent || nodeId != null) {
      map['node_id'] = Variable<String>(nodeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  GlossaryTableCompanion toCompanion(bool nullToAbsent) {
    return GlossaryTableCompanion(
      id: Value(id),
      word: Value(word),
      meaning: Value(meaning),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      voicePath: voicePath == null && nullToAbsent
          ? const Value.absent()
          : Value(voicePath),
      nodeId: nodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(nodeId),
      createdAt: Value(createdAt),
    );
  }

  factory GlossaryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlossaryTableData(
      id: serializer.fromJson<String>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      meaning: serializer.fromJson<String>(json['meaning']),
      example: serializer.fromJson<String?>(json['example']),
      voicePath: serializer.fromJson<String?>(json['voicePath']),
      nodeId: serializer.fromJson<String?>(json['nodeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'word': serializer.toJson<String>(word),
      'meaning': serializer.toJson<String>(meaning),
      'example': serializer.toJson<String?>(example),
      'voicePath': serializer.toJson<String?>(voicePath),
      'nodeId': serializer.toJson<String?>(nodeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  GlossaryTableData copyWith({
    String? id,
    String? word,
    String? meaning,
    Value<String?> example = const Value.absent(),
    Value<String?> voicePath = const Value.absent(),
    Value<String?> nodeId = const Value.absent(),
    DateTime? createdAt,
  }) => GlossaryTableData(
    id: id ?? this.id,
    word: word ?? this.word,
    meaning: meaning ?? this.meaning,
    example: example.present ? example.value : this.example,
    voicePath: voicePath.present ? voicePath.value : this.voicePath,
    nodeId: nodeId.present ? nodeId.value : this.nodeId,
    createdAt: createdAt ?? this.createdAt,
  );
  GlossaryTableData copyWithCompanion(GlossaryTableCompanion data) {
    return GlossaryTableData(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      example: data.example.present ? data.example.value : this.example,
      voicePath: data.voicePath.present ? data.voicePath.value : this.voicePath,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlossaryTableData(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('voicePath: $voicePath, ')
          ..write('nodeId: $nodeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, word, meaning, example, voicePath, nodeId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GlossaryTableData &&
          other.id == this.id &&
          other.word == this.word &&
          other.meaning == this.meaning &&
          other.example == this.example &&
          other.voicePath == this.voicePath &&
          other.nodeId == this.nodeId &&
          other.createdAt == this.createdAt);
}

class GlossaryTableCompanion extends UpdateCompanion<GlossaryTableData> {
  final Value<String> id;
  final Value<String> word;
  final Value<String> meaning;
  final Value<String?> example;
  final Value<String?> voicePath;
  final Value<String?> nodeId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const GlossaryTableCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
    this.voicePath = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GlossaryTableCompanion.insert({
    required String id,
    required String word,
    required String meaning,
    this.example = const Value.absent(),
    this.voicePath = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       word = Value(word),
       meaning = Value(meaning);
  static Insertable<GlossaryTableData> custom({
    Expression<String>? id,
    Expression<String>? word,
    Expression<String>? meaning,
    Expression<String>? example,
    Expression<String>? voicePath,
    Expression<String>? nodeId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
      if (voicePath != null) 'voice_path': voicePath,
      if (nodeId != null) 'node_id': nodeId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GlossaryTableCompanion copyWith({
    Value<String>? id,
    Value<String>? word,
    Value<String>? meaning,
    Value<String?>? example,
    Value<String?>? voicePath,
    Value<String?>? nodeId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return GlossaryTableCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      voicePath: voicePath ?? this.voicePath,
      nodeId: nodeId ?? this.nodeId,
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
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (voicePath.present) {
      map['voice_path'] = Variable<String>(voicePath.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
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
    return (StringBuffer('GlossaryTableCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('voicePath: $voicePath, ')
          ..write('nodeId: $nodeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecipesTableTable extends RecipesTable
    with TableInfo<$RecipesTableTable, RecipesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecipesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingredientsMeta = const VerificationMeta(
    'ingredients',
  );
  @override
  late final GeneratedColumn<String> ingredients = GeneratedColumn<String>(
    'ingredients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _instructionsMeta = const VerificationMeta(
    'instructions',
  );
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
    'instructions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    ingredients,
    instructions,
    photoPath,
    nodeId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recipes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecipesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('ingredients')) {
      context.handle(
        _ingredientsMeta,
        ingredients.isAcceptableOrUnknown(
          data['ingredients']!,
          _ingredientsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ingredientsMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
        _instructionsMeta,
        instructions.isAcceptableOrUnknown(
          data['instructions']!,
          _instructionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecipesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecipesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      ingredients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingredients'],
      )!,
      instructions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}instructions'],
      )!,
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecipesTableTable createAlias(String alias) {
    return $RecipesTableTable(attachedDatabase, alias);
  }
}

class RecipesTableData extends DataClass
    implements Insertable<RecipesTableData> {
  final String id;
  final String title;
  final String ingredients;
  final String instructions;
  final String? photoPath;
  final String? nodeId;
  final DateTime createdAt;
  const RecipesTableData({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.photoPath,
    this.nodeId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['ingredients'] = Variable<String>(ingredients);
    map['instructions'] = Variable<String>(instructions);
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || nodeId != null) {
      map['node_id'] = Variable<String>(nodeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecipesTableCompanion toCompanion(bool nullToAbsent) {
    return RecipesTableCompanion(
      id: Value(id),
      title: Value(title),
      ingredients: Value(ingredients),
      instructions: Value(instructions),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      nodeId: nodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(nodeId),
      createdAt: Value(createdAt),
    );
  }

  factory RecipesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecipesTableData(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      ingredients: serializer.fromJson<String>(json['ingredients']),
      instructions: serializer.fromJson<String>(json['instructions']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      nodeId: serializer.fromJson<String?>(json['nodeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'ingredients': serializer.toJson<String>(ingredients),
      'instructions': serializer.toJson<String>(instructions),
      'photoPath': serializer.toJson<String?>(photoPath),
      'nodeId': serializer.toJson<String?>(nodeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecipesTableData copyWith({
    String? id,
    String? title,
    String? ingredients,
    String? instructions,
    Value<String?> photoPath = const Value.absent(),
    Value<String?> nodeId = const Value.absent(),
    DateTime? createdAt,
  }) => RecipesTableData(
    id: id ?? this.id,
    title: title ?? this.title,
    ingredients: ingredients ?? this.ingredients,
    instructions: instructions ?? this.instructions,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    nodeId: nodeId.present ? nodeId.value : this.nodeId,
    createdAt: createdAt ?? this.createdAt,
  );
  RecipesTableData copyWithCompanion(RecipesTableCompanion data) {
    return RecipesTableData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      ingredients: data.ingredients.present
          ? data.ingredients.value
          : this.ingredients,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecipesTableData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('ingredients: $ingredients, ')
          ..write('instructions: $instructions, ')
          ..write('photoPath: $photoPath, ')
          ..write('nodeId: $nodeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    ingredients,
    instructions,
    photoPath,
    nodeId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecipesTableData &&
          other.id == this.id &&
          other.title == this.title &&
          other.ingredients == this.ingredients &&
          other.instructions == this.instructions &&
          other.photoPath == this.photoPath &&
          other.nodeId == this.nodeId &&
          other.createdAt == this.createdAt);
}

class RecipesTableCompanion extends UpdateCompanion<RecipesTableData> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> ingredients;
  final Value<String> instructions;
  final Value<String?> photoPath;
  final Value<String?> nodeId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecipesTableCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.ingredients = const Value.absent(),
    this.instructions = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecipesTableCompanion.insert({
    required String id,
    required String title,
    required String ingredients,
    required String instructions,
    this.photoPath = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       ingredients = Value(ingredients),
       instructions = Value(instructions);
  static Insertable<RecipesTableData> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? ingredients,
    Expression<String>? instructions,
    Expression<String>? photoPath,
    Expression<String>? nodeId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (ingredients != null) 'ingredients': ingredients,
      if (instructions != null) 'instructions': instructions,
      if (photoPath != null) 'photo_path': photoPath,
      if (nodeId != null) 'node_id': nodeId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecipesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? ingredients,
    Value<String>? instructions,
    Value<String?>? photoPath,
    Value<String?>? nodeId,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return RecipesTableCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      photoPath: photoPath ?? this.photoPath,
      nodeId: nodeId ?? this.nodeId,
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
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (ingredients.present) {
      map['ingredients'] = Variable<String>(ingredients.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
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
    return (StringBuffer('RecipesTableCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('ingredients: $ingredients, ')
          ..write('instructions: $instructions, ')
          ..write('photoPath: $photoPath, ')
          ..write('nodeId: $nodeId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NodeLocationsTableTable extends NodeLocationsTable
    with TableInfo<$NodeLocationsTableTable, NodeLocationsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodeLocationsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nodeIdMeta = const VerificationMeta('nodeId');
  @override
  late final GeneratedColumn<String> nodeId = GeneratedColumn<String>(
    'node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startYearMeta = const VerificationMeta(
    'startYear',
  );
  @override
  late final GeneratedColumn<int> startYear = GeneratedColumn<int>(
    'start_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endYearMeta = const VerificationMeta(
    'endYear',
  );
  @override
  late final GeneratedColumn<int> endYear = GeneratedColumn<int>(
    'end_year',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeId,
    address,
    latitude,
    longitude,
    startYear,
    endYear,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'node_locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<NodeLocationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('node_id')) {
      context.handle(
        _nodeIdMeta,
        nodeId.isAcceptableOrUnknown(data['node_id']!, _nodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeIdMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('start_year')) {
      context.handle(
        _startYearMeta,
        startYear.isAcceptableOrUnknown(data['start_year']!, _startYearMeta),
      );
    }
    if (data.containsKey('end_year')) {
      context.handle(
        _endYearMeta,
        endYear.isAcceptableOrUnknown(data['end_year']!, _endYearMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NodeLocationsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NodeLocationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      nodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}node_id'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      startYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_year'],
      ),
      endYear: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_year'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NodeLocationsTableTable createAlias(String alias) {
    return $NodeLocationsTableTable(attachedDatabase, alias);
  }
}

class NodeLocationsTableData extends DataClass
    implements Insertable<NodeLocationsTableData> {
  final String id;
  final String nodeId;
  final String address;
  final double latitude;
  final double longitude;
  final int? startYear;
  final int? endYear;
  final DateTime createdAt;
  const NodeLocationsTableData({
    required this.id,
    required this.nodeId,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.startYear,
    this.endYear,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['node_id'] = Variable<String>(nodeId);
    map['address'] = Variable<String>(address);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || startYear != null) {
      map['start_year'] = Variable<int>(startYear);
    }
    if (!nullToAbsent || endYear != null) {
      map['end_year'] = Variable<int>(endYear);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NodeLocationsTableCompanion toCompanion(bool nullToAbsent) {
    return NodeLocationsTableCompanion(
      id: Value(id),
      nodeId: Value(nodeId),
      address: Value(address),
      latitude: Value(latitude),
      longitude: Value(longitude),
      startYear: startYear == null && nullToAbsent
          ? const Value.absent()
          : Value(startYear),
      endYear: endYear == null && nullToAbsent
          ? const Value.absent()
          : Value(endYear),
      createdAt: Value(createdAt),
    );
  }

  factory NodeLocationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NodeLocationsTableData(
      id: serializer.fromJson<String>(json['id']),
      nodeId: serializer.fromJson<String>(json['nodeId']),
      address: serializer.fromJson<String>(json['address']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      startYear: serializer.fromJson<int?>(json['startYear']),
      endYear: serializer.fromJson<int?>(json['endYear']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'nodeId': serializer.toJson<String>(nodeId),
      'address': serializer.toJson<String>(address),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'startYear': serializer.toJson<int?>(startYear),
      'endYear': serializer.toJson<int?>(endYear),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  NodeLocationsTableData copyWith({
    String? id,
    String? nodeId,
    String? address,
    double? latitude,
    double? longitude,
    Value<int?> startYear = const Value.absent(),
    Value<int?> endYear = const Value.absent(),
    DateTime? createdAt,
  }) => NodeLocationsTableData(
    id: id ?? this.id,
    nodeId: nodeId ?? this.nodeId,
    address: address ?? this.address,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    startYear: startYear.present ? startYear.value : this.startYear,
    endYear: endYear.present ? endYear.value : this.endYear,
    createdAt: createdAt ?? this.createdAt,
  );
  NodeLocationsTableData copyWithCompanion(NodeLocationsTableCompanion data) {
    return NodeLocationsTableData(
      id: data.id.present ? data.id.value : this.id,
      nodeId: data.nodeId.present ? data.nodeId.value : this.nodeId,
      address: data.address.present ? data.address.value : this.address,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      startYear: data.startYear.present ? data.startYear.value : this.startYear,
      endYear: data.endYear.present ? data.endYear.value : this.endYear,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NodeLocationsTableData(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('startYear: $startYear, ')
          ..write('endYear: $endYear, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    nodeId,
    address,
    latitude,
    longitude,
    startYear,
    endYear,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NodeLocationsTableData &&
          other.id == this.id &&
          other.nodeId == this.nodeId &&
          other.address == this.address &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.startYear == this.startYear &&
          other.endYear == this.endYear &&
          other.createdAt == this.createdAt);
}

class NodeLocationsTableCompanion
    extends UpdateCompanion<NodeLocationsTableData> {
  final Value<String> id;
  final Value<String> nodeId;
  final Value<String> address;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int?> startYear;
  final Value<int?> endYear;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NodeLocationsTableCompanion({
    this.id = const Value.absent(),
    this.nodeId = const Value.absent(),
    this.address = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.startYear = const Value.absent(),
    this.endYear = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NodeLocationsTableCompanion.insert({
    required String id,
    required String nodeId,
    required String address,
    required double latitude,
    required double longitude,
    this.startYear = const Value.absent(),
    this.endYear = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       nodeId = Value(nodeId),
       address = Value(address),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<NodeLocationsTableData> custom({
    Expression<String>? id,
    Expression<String>? nodeId,
    Expression<String>? address,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? startYear,
    Expression<int>? endYear,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeId != null) 'node_id': nodeId,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (startYear != null) 'start_year': startYear,
      if (endYear != null) 'end_year': endYear,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NodeLocationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? nodeId,
    Value<String>? address,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int?>? startYear,
    Value<int?>? endYear,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NodeLocationsTableCompanion(
      id: id ?? this.id,
      nodeId: nodeId ?? this.nodeId,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
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
    if (nodeId.present) {
      map['node_id'] = Variable<String>(nodeId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (startYear.present) {
      map['start_year'] = Variable<int>(startYear.value);
    }
    if (endYear.present) {
      map['end_year'] = Variable<int>(endYear.value);
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
    return (StringBuffer('NodeLocationsTableCompanion(')
          ..write('id: $id, ')
          ..write('nodeId: $nodeId, ')
          ..write('address: $address, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('startYear: $startYear, ')
          ..write('endYear: $endYear, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VoiceLegacyTableTable extends VoiceLegacyTable
    with TableInfo<$VoiceLegacyTableTable, VoiceLegacyTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VoiceLegacyTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromNodeIdMeta = const VerificationMeta(
    'fromNodeId',
  );
  @override
  late final GeneratedColumn<String> fromNodeId = GeneratedColumn<String>(
    'from_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toNodeIdMeta = const VerificationMeta(
    'toNodeId',
  );
  @override
  late final GeneratedColumn<String> toNodeId = GeneratedColumn<String>(
    'to_node_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _voicePathMeta = const VerificationMeta(
    'voicePath',
  );
  @override
  late final GeneratedColumn<String> voicePath = GeneratedColumn<String>(
    'voice_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _openConditionMeta = const VerificationMeta(
    'openCondition',
  );
  @override
  late final GeneratedColumn<String> openCondition = GeneratedColumn<String>(
    'open_condition',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('date'),
  );
  static const VerificationMeta _openDateMeta = const VerificationMeta(
    'openDate',
  );
  @override
  late final GeneratedColumn<DateTime> openDate = GeneratedColumn<DateTime>(
    'open_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isOpenedMeta = const VerificationMeta(
    'isOpened',
  );
  @override
  late final GeneratedColumn<bool> isOpened = GeneratedColumn<bool>(
    'is_opened',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_opened" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fromNodeId,
    toNodeId,
    title,
    voicePath,
    durationSeconds,
    openCondition,
    openDate,
    isOpened,
    openedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'voice_legacy';
  @override
  VerificationContext validateIntegrity(
    Insertable<VoiceLegacyTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('from_node_id')) {
      context.handle(
        _fromNodeIdMeta,
        fromNodeId.isAcceptableOrUnknown(
          data['from_node_id']!,
          _fromNodeIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fromNodeIdMeta);
    }
    if (data.containsKey('to_node_id')) {
      context.handle(
        _toNodeIdMeta,
        toNodeId.isAcceptableOrUnknown(data['to_node_id']!, _toNodeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_toNodeIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('voice_path')) {
      context.handle(
        _voicePathMeta,
        voicePath.isAcceptableOrUnknown(data['voice_path']!, _voicePathMeta),
      );
    } else if (isInserting) {
      context.missing(_voicePathMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('open_condition')) {
      context.handle(
        _openConditionMeta,
        openCondition.isAcceptableOrUnknown(
          data['open_condition']!,
          _openConditionMeta,
        ),
      );
    }
    if (data.containsKey('open_date')) {
      context.handle(
        _openDateMeta,
        openDate.isAcceptableOrUnknown(data['open_date']!, _openDateMeta),
      );
    }
    if (data.containsKey('is_opened')) {
      context.handle(
        _isOpenedMeta,
        isOpened.isAcceptableOrUnknown(data['is_opened']!, _isOpenedMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VoiceLegacyTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VoiceLegacyTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fromNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_node_id'],
      )!,
      toNodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_node_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      voicePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}voice_path'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      openCondition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}open_condition'],
      )!,
      openDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}open_date'],
      ),
      isOpened: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_opened'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VoiceLegacyTableTable createAlias(String alias) {
    return $VoiceLegacyTableTable(attachedDatabase, alias);
  }
}

class VoiceLegacyTableData extends DataClass
    implements Insertable<VoiceLegacyTableData> {
  final String id;
  final String fromNodeId;
  final String toNodeId;
  final String title;
  final String voicePath;
  final int durationSeconds;
  final String openCondition;
  final DateTime? openDate;
  final bool isOpened;
  final DateTime? openedAt;
  final DateTime createdAt;
  const VoiceLegacyTableData({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    required this.title,
    required this.voicePath,
    required this.durationSeconds,
    required this.openCondition,
    this.openDate,
    required this.isOpened,
    this.openedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['from_node_id'] = Variable<String>(fromNodeId);
    map['to_node_id'] = Variable<String>(toNodeId);
    map['title'] = Variable<String>(title);
    map['voice_path'] = Variable<String>(voicePath);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['open_condition'] = Variable<String>(openCondition);
    if (!nullToAbsent || openDate != null) {
      map['open_date'] = Variable<DateTime>(openDate);
    }
    map['is_opened'] = Variable<bool>(isOpened);
    if (!nullToAbsent || openedAt != null) {
      map['opened_at'] = Variable<DateTime>(openedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VoiceLegacyTableCompanion toCompanion(bool nullToAbsent) {
    return VoiceLegacyTableCompanion(
      id: Value(id),
      fromNodeId: Value(fromNodeId),
      toNodeId: Value(toNodeId),
      title: Value(title),
      voicePath: Value(voicePath),
      durationSeconds: Value(durationSeconds),
      openCondition: Value(openCondition),
      openDate: openDate == null && nullToAbsent
          ? const Value.absent()
          : Value(openDate),
      isOpened: Value(isOpened),
      openedAt: openedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(openedAt),
      createdAt: Value(createdAt),
    );
  }

  factory VoiceLegacyTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VoiceLegacyTableData(
      id: serializer.fromJson<String>(json['id']),
      fromNodeId: serializer.fromJson<String>(json['fromNodeId']),
      toNodeId: serializer.fromJson<String>(json['toNodeId']),
      title: serializer.fromJson<String>(json['title']),
      voicePath: serializer.fromJson<String>(json['voicePath']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      openCondition: serializer.fromJson<String>(json['openCondition']),
      openDate: serializer.fromJson<DateTime?>(json['openDate']),
      isOpened: serializer.fromJson<bool>(json['isOpened']),
      openedAt: serializer.fromJson<DateTime?>(json['openedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fromNodeId': serializer.toJson<String>(fromNodeId),
      'toNodeId': serializer.toJson<String>(toNodeId),
      'title': serializer.toJson<String>(title),
      'voicePath': serializer.toJson<String>(voicePath),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'openCondition': serializer.toJson<String>(openCondition),
      'openDate': serializer.toJson<DateTime?>(openDate),
      'isOpened': serializer.toJson<bool>(isOpened),
      'openedAt': serializer.toJson<DateTime?>(openedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  VoiceLegacyTableData copyWith({
    String? id,
    String? fromNodeId,
    String? toNodeId,
    String? title,
    String? voicePath,
    int? durationSeconds,
    String? openCondition,
    Value<DateTime?> openDate = const Value.absent(),
    bool? isOpened,
    Value<DateTime?> openedAt = const Value.absent(),
    DateTime? createdAt,
  }) => VoiceLegacyTableData(
    id: id ?? this.id,
    fromNodeId: fromNodeId ?? this.fromNodeId,
    toNodeId: toNodeId ?? this.toNodeId,
    title: title ?? this.title,
    voicePath: voicePath ?? this.voicePath,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    openCondition: openCondition ?? this.openCondition,
    openDate: openDate.present ? openDate.value : this.openDate,
    isOpened: isOpened ?? this.isOpened,
    openedAt: openedAt.present ? openedAt.value : this.openedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  VoiceLegacyTableData copyWithCompanion(VoiceLegacyTableCompanion data) {
    return VoiceLegacyTableData(
      id: data.id.present ? data.id.value : this.id,
      fromNodeId: data.fromNodeId.present
          ? data.fromNodeId.value
          : this.fromNodeId,
      toNodeId: data.toNodeId.present ? data.toNodeId.value : this.toNodeId,
      title: data.title.present ? data.title.value : this.title,
      voicePath: data.voicePath.present ? data.voicePath.value : this.voicePath,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      openCondition: data.openCondition.present
          ? data.openCondition.value
          : this.openCondition,
      openDate: data.openDate.present ? data.openDate.value : this.openDate,
      isOpened: data.isOpened.present ? data.isOpened.value : this.isOpened,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VoiceLegacyTableData(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('title: $title, ')
          ..write('voicePath: $voicePath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('openCondition: $openCondition, ')
          ..write('openDate: $openDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedAt: $openedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fromNodeId,
    toNodeId,
    title,
    voicePath,
    durationSeconds,
    openCondition,
    openDate,
    isOpened,
    openedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VoiceLegacyTableData &&
          other.id == this.id &&
          other.fromNodeId == this.fromNodeId &&
          other.toNodeId == this.toNodeId &&
          other.title == this.title &&
          other.voicePath == this.voicePath &&
          other.durationSeconds == this.durationSeconds &&
          other.openCondition == this.openCondition &&
          other.openDate == this.openDate &&
          other.isOpened == this.isOpened &&
          other.openedAt == this.openedAt &&
          other.createdAt == this.createdAt);
}

class VoiceLegacyTableCompanion extends UpdateCompanion<VoiceLegacyTableData> {
  final Value<String> id;
  final Value<String> fromNodeId;
  final Value<String> toNodeId;
  final Value<String> title;
  final Value<String> voicePath;
  final Value<int> durationSeconds;
  final Value<String> openCondition;
  final Value<DateTime?> openDate;
  final Value<bool> isOpened;
  final Value<DateTime?> openedAt;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const VoiceLegacyTableCompanion({
    this.id = const Value.absent(),
    this.fromNodeId = const Value.absent(),
    this.toNodeId = const Value.absent(),
    this.title = const Value.absent(),
    this.voicePath = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.openCondition = const Value.absent(),
    this.openDate = const Value.absent(),
    this.isOpened = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VoiceLegacyTableCompanion.insert({
    required String id,
    required String fromNodeId,
    required String toNodeId,
    required String title,
    required String voicePath,
    this.durationSeconds = const Value.absent(),
    this.openCondition = const Value.absent(),
    this.openDate = const Value.absent(),
    this.isOpened = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       fromNodeId = Value(fromNodeId),
       toNodeId = Value(toNodeId),
       title = Value(title),
       voicePath = Value(voicePath);
  static Insertable<VoiceLegacyTableData> custom({
    Expression<String>? id,
    Expression<String>? fromNodeId,
    Expression<String>? toNodeId,
    Expression<String>? title,
    Expression<String>? voicePath,
    Expression<int>? durationSeconds,
    Expression<String>? openCondition,
    Expression<DateTime>? openDate,
    Expression<bool>? isOpened,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fromNodeId != null) 'from_node_id': fromNodeId,
      if (toNodeId != null) 'to_node_id': toNodeId,
      if (title != null) 'title': title,
      if (voicePath != null) 'voice_path': voicePath,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (openCondition != null) 'open_condition': openCondition,
      if (openDate != null) 'open_date': openDate,
      if (isOpened != null) 'is_opened': isOpened,
      if (openedAt != null) 'opened_at': openedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VoiceLegacyTableCompanion copyWith({
    Value<String>? id,
    Value<String>? fromNodeId,
    Value<String>? toNodeId,
    Value<String>? title,
    Value<String>? voicePath,
    Value<int>? durationSeconds,
    Value<String>? openCondition,
    Value<DateTime?>? openDate,
    Value<bool>? isOpened,
    Value<DateTime?>? openedAt,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return VoiceLegacyTableCompanion(
      id: id ?? this.id,
      fromNodeId: fromNodeId ?? this.fromNodeId,
      toNodeId: toNodeId ?? this.toNodeId,
      title: title ?? this.title,
      voicePath: voicePath ?? this.voicePath,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      openCondition: openCondition ?? this.openCondition,
      openDate: openDate ?? this.openDate,
      isOpened: isOpened ?? this.isOpened,
      openedAt: openedAt ?? this.openedAt,
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
    if (fromNodeId.present) {
      map['from_node_id'] = Variable<String>(fromNodeId.value);
    }
    if (toNodeId.present) {
      map['to_node_id'] = Variable<String>(toNodeId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (voicePath.present) {
      map['voice_path'] = Variable<String>(voicePath.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (openCondition.present) {
      map['open_condition'] = Variable<String>(openCondition.value);
    }
    if (openDate.present) {
      map['open_date'] = Variable<DateTime>(openDate.value);
    }
    if (isOpened.present) {
      map['is_opened'] = Variable<bool>(isOpened.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
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
    return (StringBuffer('VoiceLegacyTableCompanion(')
          ..write('id: $id, ')
          ..write('fromNodeId: $fromNodeId, ')
          ..write('toNodeId: $toNodeId, ')
          ..write('title: $title, ')
          ..write('voicePath: $voicePath, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('openCondition: $openCondition, ')
          ..write('openDate: $openDate, ')
          ..write('isOpened: $isOpened, ')
          ..write('openedAt: $openedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ThenNowTableTable extends ThenNowTable
    with TableInfo<$ThenNowTableTable, ThenNowTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThenNowTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryId1Meta = const VerificationMeta(
    'memoryId1',
  );
  @override
  late final GeneratedColumn<String> memoryId1 = GeneratedColumn<String>(
    'memory_id1',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoryId2Meta = const VerificationMeta(
    'memoryId2',
  );
  @override
  late final GeneratedColumn<String> memoryId2 = GeneratedColumn<String>(
    'memory_id2',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    memoryId1,
    memoryId2,
    label,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'then_now';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThenNowTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_id1')) {
      context.handle(
        _memoryId1Meta,
        memoryId1.isAcceptableOrUnknown(data['memory_id1']!, _memoryId1Meta),
      );
    } else if (isInserting) {
      context.missing(_memoryId1Meta);
    }
    if (data.containsKey('memory_id2')) {
      context.handle(
        _memoryId2Meta,
        memoryId2.isAcceptableOrUnknown(data['memory_id2']!, _memoryId2Meta),
      );
    } else if (isInserting) {
      context.missing(_memoryId2Meta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ThenNowTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThenNowTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      memoryId1: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id1'],
      )!,
      memoryId2: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memory_id2'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ThenNowTableTable createAlias(String alias) {
    return $ThenNowTableTable(attachedDatabase, alias);
  }
}

class ThenNowTableData extends DataClass
    implements Insertable<ThenNowTableData> {
  final String id;
  final String memoryId1;
  final String memoryId2;
  final String? label;
  final DateTime createdAt;
  const ThenNowTableData({
    required this.id,
    required this.memoryId1,
    required this.memoryId2,
    this.label,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_id1'] = Variable<String>(memoryId1);
    map['memory_id2'] = Variable<String>(memoryId2);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ThenNowTableCompanion toCompanion(bool nullToAbsent) {
    return ThenNowTableCompanion(
      id: Value(id),
      memoryId1: Value(memoryId1),
      memoryId2: Value(memoryId2),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      createdAt: Value(createdAt),
    );
  }

  factory ThenNowTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThenNowTableData(
      id: serializer.fromJson<String>(json['id']),
      memoryId1: serializer.fromJson<String>(json['memoryId1']),
      memoryId2: serializer.fromJson<String>(json['memoryId2']),
      label: serializer.fromJson<String?>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryId1': serializer.toJson<String>(memoryId1),
      'memoryId2': serializer.toJson<String>(memoryId2),
      'label': serializer.toJson<String?>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ThenNowTableData copyWith({
    String? id,
    String? memoryId1,
    String? memoryId2,
    Value<String?> label = const Value.absent(),
    DateTime? createdAt,
  }) => ThenNowTableData(
    id: id ?? this.id,
    memoryId1: memoryId1 ?? this.memoryId1,
    memoryId2: memoryId2 ?? this.memoryId2,
    label: label.present ? label.value : this.label,
    createdAt: createdAt ?? this.createdAt,
  );
  ThenNowTableData copyWithCompanion(ThenNowTableCompanion data) {
    return ThenNowTableData(
      id: data.id.present ? data.id.value : this.id,
      memoryId1: data.memoryId1.present ? data.memoryId1.value : this.memoryId1,
      memoryId2: data.memoryId2.present ? data.memoryId2.value : this.memoryId2,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThenNowTableData(')
          ..write('id: $id, ')
          ..write('memoryId1: $memoryId1, ')
          ..write('memoryId2: $memoryId2, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryId1, memoryId2, label, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThenNowTableData &&
          other.id == this.id &&
          other.memoryId1 == this.memoryId1 &&
          other.memoryId2 == this.memoryId2 &&
          other.label == this.label &&
          other.createdAt == this.createdAt);
}

class ThenNowTableCompanion extends UpdateCompanion<ThenNowTableData> {
  final Value<String> id;
  final Value<String> memoryId1;
  final Value<String> memoryId2;
  final Value<String?> label;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ThenNowTableCompanion({
    this.id = const Value.absent(),
    this.memoryId1 = const Value.absent(),
    this.memoryId2 = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThenNowTableCompanion.insert({
    required String id,
    required String memoryId1,
    required String memoryId2,
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       memoryId1 = Value(memoryId1),
       memoryId2 = Value(memoryId2);
  static Insertable<ThenNowTableData> custom({
    Expression<String>? id,
    Expression<String>? memoryId1,
    Expression<String>? memoryId2,
    Expression<String>? label,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryId1 != null) 'memory_id1': memoryId1,
      if (memoryId2 != null) 'memory_id2': memoryId2,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThenNowTableCompanion copyWith({
    Value<String>? id,
    Value<String>? memoryId1,
    Value<String>? memoryId2,
    Value<String?>? label,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ThenNowTableCompanion(
      id: id ?? this.id,
      memoryId1: memoryId1 ?? this.memoryId1,
      memoryId2: memoryId2 ?? this.memoryId2,
      label: label ?? this.label,
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
    if (memoryId1.present) {
      map['memory_id1'] = Variable<String>(memoryId1.value);
    }
    if (memoryId2.present) {
      map['memory_id2'] = Variable<String>(memoryId2.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
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
    return (StringBuffer('ThenNowTableCompanion(')
          ..write('id: $id, ')
          ..write('memoryId1: $memoryId1, ')
          ..write('memoryId2: $memoryId2, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfileTableTable profileTable = $ProfileTableTable(this);
  late final $NodesTableTable nodesTable = $NodesTableTable(this);
  late final $NodeEdgesTableTable nodeEdgesTable = $NodeEdgesTableTable(this);
  late final $MemoriesTableTable memoriesTable = $MemoriesTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $TemperatureLogsTableTable temperatureLogsTable =
      $TemperatureLogsTableTable(this);
  late final $BouquetsTableTable bouquetsTable = $BouquetsTableTable(this);
  late final $CapsulesTableTable capsulesTable = $CapsulesTableTable(this);
  late final $CapsuleItemsTableTable capsuleItemsTable =
      $CapsuleItemsTableTable(this);
  late final $MemorialMessagesTableTable memorialMessagesTable =
      $MemorialMessagesTableTable(this);
  late final $GlossaryTableTable glossaryTable = $GlossaryTableTable(this);
  late final $RecipesTableTable recipesTable = $RecipesTableTable(this);
  late final $NodeLocationsTableTable nodeLocationsTable =
      $NodeLocationsTableTable(this);
  late final $VoiceLegacyTableTable voiceLegacyTable = $VoiceLegacyTableTable(
    this,
  );
  late final $ThenNowTableTable thenNowTable = $ThenNowTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profileTable,
    nodesTable,
    nodeEdgesTable,
    memoriesTable,
    settingsTable,
    temperatureLogsTable,
    bouquetsTable,
    capsulesTable,
    capsuleItemsTable,
    memorialMessagesTable,
    glossaryTable,
    recipesTable,
    nodeLocationsTable,
    voiceLegacyTable,
    thenNowTable,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'nodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('node_edges', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'nodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('node_edges', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'nodes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('memories', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ProfileTableTableCreateCompanionBuilder =
    ProfileTableCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> nickname,
      Value<String?> photoPath,
      Value<DateTime?> birthDate,
      Value<String?> bio,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ProfileTableTableUpdateCompanionBuilder =
    ProfileTableCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> nickname,
      Value<String?> photoPath,
      Value<DateTime?> birthDate,
      Value<String?> bio,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ProfileTableTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileTableTable> {
  $$ProfileTableTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
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

class $$ProfileTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileTableTable> {
  $$ProfileTableTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
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

class $$ProfileTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileTableTable> {
  $$ProfileTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProfileTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileTableTable,
          ProfileTableData,
          $$ProfileTableTableFilterComposer,
          $$ProfileTableTableOrderingComposer,
          $$ProfileTableTableAnnotationComposer,
          $$ProfileTableTableCreateCompanionBuilder,
          $$ProfileTableTableUpdateCompanionBuilder,
          (
            ProfileTableData,
            BaseReferences<_$AppDatabase, $ProfileTableTable, ProfileTableData>,
          ),
          ProfileTableData,
          PrefetchHooks Function()
        > {
  $$ProfileTableTableTableManager(_$AppDatabase db, $ProfileTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfileTableCompanion(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                birthDate: birthDate,
                bio: bio,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProfileTableCompanion.insert(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                birthDate: birthDate,
                bio: bio,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfileTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileTableTable,
      ProfileTableData,
      $$ProfileTableTableFilterComposer,
      $$ProfileTableTableOrderingComposer,
      $$ProfileTableTableAnnotationComposer,
      $$ProfileTableTableCreateCompanionBuilder,
      $$ProfileTableTableUpdateCompanionBuilder,
      (
        ProfileTableData,
        BaseReferences<_$AppDatabase, $ProfileTableTable, ProfileTableData>,
      ),
      ProfileTableData,
      PrefetchHooks Function()
    >;
typedef $$NodesTableTableCreateCompanionBuilder =
    NodesTableCompanion Function({
      required String id,
      required String name,
      Value<String?> nickname,
      Value<String?> photoPath,
      Value<String?> bio,
      Value<DateTime?> birthDate,
      Value<DateTime?> deathDate,
      Value<bool> isGhost,
      Value<int> temperature,
      Value<double> positionX,
      Value<double> positionY,
      Value<String> tagsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$NodesTableTableUpdateCompanionBuilder =
    NodesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> nickname,
      Value<String?> photoPath,
      Value<String?> bio,
      Value<DateTime?> birthDate,
      Value<DateTime?> deathDate,
      Value<bool> isGhost,
      Value<int> temperature,
      Value<double> positionX,
      Value<double> positionY,
      Value<String> tagsJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$NodesTableTableReferences
    extends BaseReferences<_$AppDatabase, $NodesTableTable, NodesTableData> {
  $$NodesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MemoriesTableTable, List<MemoriesTableData>>
  _memoriesTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.memoriesTable,
    aliasName: $_aliasNameGenerator(db.nodesTable.id, db.memoriesTable.nodeId),
  );

  $$MemoriesTableTableProcessedTableManager get memoriesTableRefs {
    final manager = $$MemoriesTableTableTableManager(
      $_db,
      $_db.memoriesTable,
    ).filter((f) => f.nodeId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_memoriesTableRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$NodesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NodesTableTable> {
  $$NodesTableTableFilterComposer({
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

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deathDate => $composableBuilder(
    column: $table.deathDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isGhost => $composableBuilder(
    column: $table.isGhost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
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

  Expression<bool> memoriesTableRefs(
    Expression<bool> Function($$MemoriesTableTableFilterComposer f) f,
  ) {
    final $$MemoriesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoriesTable,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableTableFilterComposer(
            $db: $db,
            $table: $db.memoriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NodesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NodesTableTable> {
  $$NodesTableTableOrderingComposer({
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

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bio => $composableBuilder(
    column: $table.bio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deathDate => $composableBuilder(
    column: $table.deathDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isGhost => $composableBuilder(
    column: $table.isGhost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionX => $composableBuilder(
    column: $table.positionX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get positionY => $composableBuilder(
    column: $table.positionY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
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

class $$NodesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodesTableTable> {
  $$NodesTableTableAnnotationComposer({
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

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get bio =>
      $composableBuilder(column: $table.bio, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<DateTime> get deathDate =>
      $composableBuilder(column: $table.deathDate, builder: (column) => column);

  GeneratedColumn<bool> get isGhost =>
      $composableBuilder(column: $table.isGhost, builder: (column) => column);

  GeneratedColumn<int> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<double> get positionX =>
      $composableBuilder(column: $table.positionX, builder: (column) => column);

  GeneratedColumn<double> get positionY =>
      $composableBuilder(column: $table.positionY, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> memoriesTableRefs<T extends Object>(
    Expression<T> Function($$MemoriesTableTableAnnotationComposer a) f,
  ) {
    final $$MemoriesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.memoriesTable,
      getReferencedColumn: (t) => t.nodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MemoriesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.memoriesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$NodesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodesTableTable,
          NodesTableData,
          $$NodesTableTableFilterComposer,
          $$NodesTableTableOrderingComposer,
          $$NodesTableTableAnnotationComposer,
          $$NodesTableTableCreateCompanionBuilder,
          $$NodesTableTableUpdateCompanionBuilder,
          (NodesTableData, $$NodesTableTableReferences),
          NodesTableData,
          PrefetchHooks Function({bool memoriesTableRefs})
        > {
  $$NodesTableTableTableManager(_$AppDatabase db, $NodesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<DateTime?> deathDate = const Value.absent(),
                Value<bool> isGhost = const Value.absent(),
                Value<int> temperature = const Value.absent(),
                Value<double> positionX = const Value.absent(),
                Value<double> positionY = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodesTableCompanion(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                bio: bio,
                birthDate: birthDate,
                deathDate: deathDate,
                isGhost: isGhost,
                temperature: temperature,
                positionX: positionX,
                positionY: positionY,
                tagsJson: tagsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> bio = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<DateTime?> deathDate = const Value.absent(),
                Value<bool> isGhost = const Value.absent(),
                Value<int> temperature = const Value.absent(),
                Value<double> positionX = const Value.absent(),
                Value<double> positionY = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodesTableCompanion.insert(
                id: id,
                name: name,
                nickname: nickname,
                photoPath: photoPath,
                bio: bio,
                birthDate: birthDate,
                deathDate: deathDate,
                isGhost: isGhost,
                temperature: temperature,
                positionX: positionX,
                positionY: positionY,
                tagsJson: tagsJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NodesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({memoriesTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (memoriesTableRefs) db.memoriesTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (memoriesTableRefs)
                    await $_getPrefetchedData<
                      NodesTableData,
                      $NodesTableTable,
                      MemoriesTableData
                    >(
                      currentTable: table,
                      referencedTable: $$NodesTableTableReferences
                          ._memoriesTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$NodesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).memoriesTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.nodeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$NodesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodesTableTable,
      NodesTableData,
      $$NodesTableTableFilterComposer,
      $$NodesTableTableOrderingComposer,
      $$NodesTableTableAnnotationComposer,
      $$NodesTableTableCreateCompanionBuilder,
      $$NodesTableTableUpdateCompanionBuilder,
      (NodesTableData, $$NodesTableTableReferences),
      NodesTableData,
      PrefetchHooks Function({bool memoriesTableRefs})
    >;
typedef $$NodeEdgesTableTableCreateCompanionBuilder =
    NodeEdgesTableCompanion Function({
      required String id,
      required String fromNodeId,
      required String toNodeId,
      required String relation,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$NodeEdgesTableTableUpdateCompanionBuilder =
    NodeEdgesTableCompanion Function({
      Value<String> id,
      Value<String> fromNodeId,
      Value<String> toNodeId,
      Value<String> relation,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$NodeEdgesTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $NodeEdgesTableTable,
          NodeEdgesTableData
        > {
  $$NodeEdgesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NodesTableTable _fromNodeIdTable(_$AppDatabase db) =>
      db.nodesTable.createAlias(
        $_aliasNameGenerator(db.nodeEdgesTable.fromNodeId, db.nodesTable.id),
      );

  $$NodesTableTableProcessedTableManager get fromNodeId {
    final $_column = $_itemColumn<String>('from_node_id')!;

    final manager = $$NodesTableTableTableManager(
      $_db,
      $_db.nodesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $NodesTableTable _toNodeIdTable(_$AppDatabase db) =>
      db.nodesTable.createAlias(
        $_aliasNameGenerator(db.nodeEdgesTable.toNodeId, db.nodesTable.id),
      );

  $$NodesTableTableProcessedTableManager get toNodeId {
    final $_column = $_itemColumn<String>('to_node_id')!;

    final manager = $$NodesTableTableTableManager(
      $_db,
      $_db.nodesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toNodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NodeEdgesTableTableFilterComposer
    extends Composer<_$AppDatabase, $NodeEdgesTableTable> {
  $$NodeEdgesTableTableFilterComposer({
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

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$NodesTableTableFilterComposer get fromNodeId {
    final $$NodesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableFilterComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NodesTableTableFilterComposer get toNodeId {
    final $$NodesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableFilterComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NodeEdgesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NodeEdgesTableTable> {
  $$NodeEdgesTableTableOrderingComposer({
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

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$NodesTableTableOrderingComposer get fromNodeId {
    final $$NodesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableOrderingComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NodesTableTableOrderingComposer get toNodeId {
    final $$NodesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableOrderingComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NodeEdgesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodeEdgesTableTable> {
  $$NodeEdgesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$NodesTableTableAnnotationComposer get fromNodeId {
    final $$NodesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromNodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$NodesTableTableAnnotationComposer get toNodeId {
    final $$NodesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toNodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NodeEdgesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodeEdgesTableTable,
          NodeEdgesTableData,
          $$NodeEdgesTableTableFilterComposer,
          $$NodeEdgesTableTableOrderingComposer,
          $$NodeEdgesTableTableAnnotationComposer,
          $$NodeEdgesTableTableCreateCompanionBuilder,
          $$NodeEdgesTableTableUpdateCompanionBuilder,
          (NodeEdgesTableData, $$NodeEdgesTableTableReferences),
          NodeEdgesTableData,
          PrefetchHooks Function({bool fromNodeId, bool toNodeId})
        > {
  $$NodeEdgesTableTableTableManager(
    _$AppDatabase db,
    $NodeEdgesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodeEdgesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodeEdgesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodeEdgesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromNodeId = const Value.absent(),
                Value<String> toNodeId = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodeEdgesTableCompanion(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                relation: relation,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromNodeId,
                required String toNodeId,
                required String relation,
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodeEdgesTableCompanion.insert(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                relation: relation,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$NodeEdgesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromNodeId = false, toNodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fromNodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.fromNodeId,
                                referencedTable: $$NodeEdgesTableTableReferences
                                    ._fromNodeIdTable(db),
                                referencedColumn:
                                    $$NodeEdgesTableTableReferences
                                        ._fromNodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (toNodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.toNodeId,
                                referencedTable: $$NodeEdgesTableTableReferences
                                    ._toNodeIdTable(db),
                                referencedColumn:
                                    $$NodeEdgesTableTableReferences
                                        ._toNodeIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NodeEdgesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodeEdgesTableTable,
      NodeEdgesTableData,
      $$NodeEdgesTableTableFilterComposer,
      $$NodeEdgesTableTableOrderingComposer,
      $$NodeEdgesTableTableAnnotationComposer,
      $$NodeEdgesTableTableCreateCompanionBuilder,
      $$NodeEdgesTableTableUpdateCompanionBuilder,
      (NodeEdgesTableData, $$NodeEdgesTableTableReferences),
      NodeEdgesTableData,
      PrefetchHooks Function({bool fromNodeId, bool toNodeId})
    >;
typedef $$MemoriesTableTableCreateCompanionBuilder =
    MemoriesTableCompanion Function({
      required String id,
      required String nodeId,
      required String type,
      Value<String?> title,
      Value<String?> description,
      Value<String?> filePath,
      Value<String?> thumbnailPath,
      Value<int?> durationSeconds,
      Value<DateTime?> dateTaken,
      Value<String> tagsJson,
      Value<DateTime> createdAt,
      Value<bool> isPrivate,
      Value<int> rowid,
    });
typedef $$MemoriesTableTableUpdateCompanionBuilder =
    MemoriesTableCompanion Function({
      Value<String> id,
      Value<String> nodeId,
      Value<String> type,
      Value<String?> title,
      Value<String?> description,
      Value<String?> filePath,
      Value<String?> thumbnailPath,
      Value<int?> durationSeconds,
      Value<DateTime?> dateTaken,
      Value<String> tagsJson,
      Value<DateTime> createdAt,
      Value<bool> isPrivate,
      Value<int> rowid,
    });

final class $$MemoriesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $MemoriesTableTable, MemoriesTableData> {
  $$MemoriesTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $NodesTableTable _nodeIdTable(_$AppDatabase db) =>
      db.nodesTable.createAlias(
        $_aliasNameGenerator(db.memoriesTable.nodeId, db.nodesTable.id),
      );

  $$NodesTableTableProcessedTableManager get nodeId {
    final $_column = $_itemColumn<String>('node_id')!;

    final manager = $$NodesTableTableTableManager(
      $_db,
      $_db.nodesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_nodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MemoriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MemoriesTableTable> {
  $$MemoriesTableTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTaken => $composableBuilder(
    column: $table.dateTaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnFilters(column),
  );

  $$NodesTableTableFilterComposer get nodeId {
    final $$NodesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableFilterComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoriesTableTable> {
  $$MemoriesTableTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTaken => $composableBuilder(
    column: $table.dateTaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPrivate => $composableBuilder(
    column: $table.isPrivate,
    builder: (column) => ColumnOrderings(column),
  );

  $$NodesTableTableOrderingComposer get nodeId {
    final $$NodesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableOrderingComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoriesTableTable> {
  $$MemoriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
    column: $table.thumbnailPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTaken =>
      $composableBuilder(column: $table.dateTaken, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isPrivate =>
      $composableBuilder(column: $table.isPrivate, builder: (column) => column);

  $$NodesTableTableAnnotationComposer get nodeId {
    final $$NodesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.nodeId,
      referencedTable: $db.nodesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NodesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.nodesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MemoriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoriesTableTable,
          MemoriesTableData,
          $$MemoriesTableTableFilterComposer,
          $$MemoriesTableTableOrderingComposer,
          $$MemoriesTableTableAnnotationComposer,
          $$MemoriesTableTableCreateCompanionBuilder,
          $$MemoriesTableTableUpdateCompanionBuilder,
          (MemoriesTableData, $$MemoriesTableTableReferences),
          MemoriesTableData,
          PrefetchHooks Function({bool nodeId})
        > {
  $$MemoriesTableTableTableManager(_$AppDatabase db, $MemoriesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> dateTaken = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesTableCompanion(
                id: id,
                nodeId: nodeId,
                type: type,
                title: title,
                description: description,
                filePath: filePath,
                thumbnailPath: thumbnailPath,
                durationSeconds: durationSeconds,
                dateTaken: dateTaken,
                tagsJson: tagsJson,
                createdAt: createdAt,
                isPrivate: isPrivate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nodeId,
                required String type,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<String?> thumbnailPath = const Value.absent(),
                Value<int?> durationSeconds = const Value.absent(),
                Value<DateTime?> dateTaken = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<bool> isPrivate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesTableCompanion.insert(
                id: id,
                nodeId: nodeId,
                type: type,
                title: title,
                description: description,
                filePath: filePath,
                thumbnailPath: thumbnailPath,
                durationSeconds: durationSeconds,
                dateTaken: dateTaken,
                tagsJson: tagsJson,
                createdAt: createdAt,
                isPrivate: isPrivate,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MemoriesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({nodeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (nodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.nodeId,
                                referencedTable: $$MemoriesTableTableReferences
                                    ._nodeIdTable(db),
                                referencedColumn: $$MemoriesTableTableReferences
                                    ._nodeIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MemoriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoriesTableTable,
      MemoriesTableData,
      $$MemoriesTableTableFilterComposer,
      $$MemoriesTableTableOrderingComposer,
      $$MemoriesTableTableAnnotationComposer,
      $$MemoriesTableTableCreateCompanionBuilder,
      $$MemoriesTableTableUpdateCompanionBuilder,
      (MemoriesTableData, $$MemoriesTableTableReferences),
      MemoriesTableData,
      PrefetchHooks Function({bool nodeId})
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      required String value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
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

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
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

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
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

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$TemperatureLogsTableTableCreateCompanionBuilder =
    TemperatureLogsTableCompanion Function({
      required String id,
      required String nodeId,
      required int temperature,
      Value<String?> emotionTag,
      required DateTime date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$TemperatureLogsTableTableUpdateCompanionBuilder =
    TemperatureLogsTableCompanion Function({
      Value<String> id,
      Value<String> nodeId,
      Value<int> temperature,
      Value<String?> emotionTag,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TemperatureLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $TemperatureLogsTableTable> {
  $$TemperatureLogsTableTableFilterComposer({
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

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotionTag => $composableBuilder(
    column: $table.emotionTag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TemperatureLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $TemperatureLogsTableTable> {
  $$TemperatureLogsTableTableOrderingComposer({
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

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotionTag => $composableBuilder(
    column: $table.emotionTag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemperatureLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemperatureLogsTableTable> {
  $$TemperatureLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<int> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<String> get emotionTag => $composableBuilder(
    column: $table.emotionTag,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TemperatureLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemperatureLogsTableTable,
          TemperatureLogsTableData,
          $$TemperatureLogsTableTableFilterComposer,
          $$TemperatureLogsTableTableOrderingComposer,
          $$TemperatureLogsTableTableAnnotationComposer,
          $$TemperatureLogsTableTableCreateCompanionBuilder,
          $$TemperatureLogsTableTableUpdateCompanionBuilder,
          (
            TemperatureLogsTableData,
            BaseReferences<
              _$AppDatabase,
              $TemperatureLogsTableTable,
              TemperatureLogsTableData
            >,
          ),
          TemperatureLogsTableData,
          PrefetchHooks Function()
        > {
  $$TemperatureLogsTableTableTableManager(
    _$AppDatabase db,
    $TemperatureLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemperatureLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemperatureLogsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TemperatureLogsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<int> temperature = const Value.absent(),
                Value<String?> emotionTag = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemperatureLogsTableCompanion(
                id: id,
                nodeId: nodeId,
                temperature: temperature,
                emotionTag: emotionTag,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nodeId,
                required int temperature,
                Value<String?> emotionTag = const Value.absent(),
                required DateTime date,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemperatureLogsTableCompanion.insert(
                id: id,
                nodeId: nodeId,
                temperature: temperature,
                emotionTag: emotionTag,
                date: date,
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

typedef $$TemperatureLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemperatureLogsTableTable,
      TemperatureLogsTableData,
      $$TemperatureLogsTableTableFilterComposer,
      $$TemperatureLogsTableTableOrderingComposer,
      $$TemperatureLogsTableTableAnnotationComposer,
      $$TemperatureLogsTableTableCreateCompanionBuilder,
      $$TemperatureLogsTableTableUpdateCompanionBuilder,
      (
        TemperatureLogsTableData,
        BaseReferences<
          _$AppDatabase,
          $TemperatureLogsTableTable,
          TemperatureLogsTableData
        >,
      ),
      TemperatureLogsTableData,
      PrefetchHooks Function()
    >;
typedef $$BouquetsTableTableCreateCompanionBuilder =
    BouquetsTableCompanion Function({
      required String id,
      required String fromNodeId,
      required String toNodeId,
      required String flowerType,
      required DateTime date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$BouquetsTableTableUpdateCompanionBuilder =
    BouquetsTableCompanion Function({
      Value<String> id,
      Value<String> fromNodeId,
      Value<String> toNodeId,
      Value<String> flowerType,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BouquetsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BouquetsTableTable> {
  $$BouquetsTableTableFilterComposer({
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

  ColumnFilters<String> get fromNodeId => $composableBuilder(
    column: $table.fromNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toNodeId => $composableBuilder(
    column: $table.toNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flowerType => $composableBuilder(
    column: $table.flowerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BouquetsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BouquetsTableTable> {
  $$BouquetsTableTableOrderingComposer({
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

  ColumnOrderings<String> get fromNodeId => $composableBuilder(
    column: $table.fromNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toNodeId => $composableBuilder(
    column: $table.toNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flowerType => $composableBuilder(
    column: $table.flowerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BouquetsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BouquetsTableTable> {
  $$BouquetsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromNodeId => $composableBuilder(
    column: $table.fromNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toNodeId =>
      $composableBuilder(column: $table.toNodeId, builder: (column) => column);

  GeneratedColumn<String> get flowerType => $composableBuilder(
    column: $table.flowerType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BouquetsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BouquetsTableTable,
          BouquetsTableData,
          $$BouquetsTableTableFilterComposer,
          $$BouquetsTableTableOrderingComposer,
          $$BouquetsTableTableAnnotationComposer,
          $$BouquetsTableTableCreateCompanionBuilder,
          $$BouquetsTableTableUpdateCompanionBuilder,
          (
            BouquetsTableData,
            BaseReferences<
              _$AppDatabase,
              $BouquetsTableTable,
              BouquetsTableData
            >,
          ),
          BouquetsTableData,
          PrefetchHooks Function()
        > {
  $$BouquetsTableTableTableManager(_$AppDatabase db, $BouquetsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BouquetsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BouquetsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BouquetsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromNodeId = const Value.absent(),
                Value<String> toNodeId = const Value.absent(),
                Value<String> flowerType = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BouquetsTableCompanion(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                flowerType: flowerType,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromNodeId,
                required String toNodeId,
                required String flowerType,
                required DateTime date,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BouquetsTableCompanion.insert(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                flowerType: flowerType,
                date: date,
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

typedef $$BouquetsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BouquetsTableTable,
      BouquetsTableData,
      $$BouquetsTableTableFilterComposer,
      $$BouquetsTableTableOrderingComposer,
      $$BouquetsTableTableAnnotationComposer,
      $$BouquetsTableTableCreateCompanionBuilder,
      $$BouquetsTableTableUpdateCompanionBuilder,
      (
        BouquetsTableData,
        BaseReferences<_$AppDatabase, $BouquetsTableTable, BouquetsTableData>,
      ),
      BouquetsTableData,
      PrefetchHooks Function()
    >;
typedef $$CapsulesTableTableCreateCompanionBuilder =
    CapsulesTableCompanion Function({
      required String id,
      required String title,
      Value<String?> message,
      required DateTime openDate,
      Value<bool> isOpened,
      Value<DateTime?> openedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CapsulesTableTableUpdateCompanionBuilder =
    CapsulesTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> message,
      Value<DateTime> openDate,
      Value<bool> isOpened,
      Value<DateTime?> openedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CapsulesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CapsulesTableTable> {
  $$CapsulesTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpened => $composableBuilder(
    column: $table.isOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapsulesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CapsulesTableTable> {
  $$CapsulesTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpened => $composableBuilder(
    column: $table.isOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapsulesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapsulesTableTable> {
  $$CapsulesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<DateTime> get openDate =>
      $composableBuilder(column: $table.openDate, builder: (column) => column);

  GeneratedColumn<bool> get isOpened =>
      $composableBuilder(column: $table.isOpened, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CapsulesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapsulesTableTable,
          CapsulesTableData,
          $$CapsulesTableTableFilterComposer,
          $$CapsulesTableTableOrderingComposer,
          $$CapsulesTableTableAnnotationComposer,
          $$CapsulesTableTableCreateCompanionBuilder,
          $$CapsulesTableTableUpdateCompanionBuilder,
          (
            CapsulesTableData,
            BaseReferences<
              _$AppDatabase,
              $CapsulesTableTable,
              CapsulesTableData
            >,
          ),
          CapsulesTableData,
          PrefetchHooks Function()
        > {
  $$CapsulesTableTableTableManager(_$AppDatabase db, $CapsulesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapsulesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapsulesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapsulesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> message = const Value.absent(),
                Value<DateTime> openDate = const Value.absent(),
                Value<bool> isOpened = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapsulesTableCompanion(
                id: id,
                title: title,
                message: message,
                openDate: openDate,
                isOpened: isOpened,
                openedAt: openedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> message = const Value.absent(),
                required DateTime openDate,
                Value<bool> isOpened = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapsulesTableCompanion.insert(
                id: id,
                title: title,
                message: message,
                openDate: openDate,
                isOpened: isOpened,
                openedAt: openedAt,
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

typedef $$CapsulesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapsulesTableTable,
      CapsulesTableData,
      $$CapsulesTableTableFilterComposer,
      $$CapsulesTableTableOrderingComposer,
      $$CapsulesTableTableAnnotationComposer,
      $$CapsulesTableTableCreateCompanionBuilder,
      $$CapsulesTableTableUpdateCompanionBuilder,
      (
        CapsulesTableData,
        BaseReferences<_$AppDatabase, $CapsulesTableTable, CapsulesTableData>,
      ),
      CapsulesTableData,
      PrefetchHooks Function()
    >;
typedef $$CapsuleItemsTableTableCreateCompanionBuilder =
    CapsuleItemsTableCompanion Function({
      required String id,
      required String capsuleId,
      required String memoryId,
      Value<int> rowid,
    });
typedef $$CapsuleItemsTableTableUpdateCompanionBuilder =
    CapsuleItemsTableCompanion Function({
      Value<String> id,
      Value<String> capsuleId,
      Value<String> memoryId,
      Value<int> rowid,
    });

class $$CapsuleItemsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CapsuleItemsTableTable> {
  $$CapsuleItemsTableTableFilterComposer({
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

  ColumnFilters<String> get capsuleId => $composableBuilder(
    column: $table.capsuleId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CapsuleItemsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CapsuleItemsTableTable> {
  $$CapsuleItemsTableTableOrderingComposer({
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

  ColumnOrderings<String> get capsuleId => $composableBuilder(
    column: $table.capsuleId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId => $composableBuilder(
    column: $table.memoryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CapsuleItemsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CapsuleItemsTableTable> {
  $$CapsuleItemsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get capsuleId =>
      $composableBuilder(column: $table.capsuleId, builder: (column) => column);

  GeneratedColumn<String> get memoryId =>
      $composableBuilder(column: $table.memoryId, builder: (column) => column);
}

class $$CapsuleItemsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CapsuleItemsTableTable,
          CapsuleItemsTableData,
          $$CapsuleItemsTableTableFilterComposer,
          $$CapsuleItemsTableTableOrderingComposer,
          $$CapsuleItemsTableTableAnnotationComposer,
          $$CapsuleItemsTableTableCreateCompanionBuilder,
          $$CapsuleItemsTableTableUpdateCompanionBuilder,
          (
            CapsuleItemsTableData,
            BaseReferences<
              _$AppDatabase,
              $CapsuleItemsTableTable,
              CapsuleItemsTableData
            >,
          ),
          CapsuleItemsTableData,
          PrefetchHooks Function()
        > {
  $$CapsuleItemsTableTableTableManager(
    _$AppDatabase db,
    $CapsuleItemsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CapsuleItemsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CapsuleItemsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CapsuleItemsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> capsuleId = const Value.absent(),
                Value<String> memoryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CapsuleItemsTableCompanion(
                id: id,
                capsuleId: capsuleId,
                memoryId: memoryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String capsuleId,
                required String memoryId,
                Value<int> rowid = const Value.absent(),
              }) => CapsuleItemsTableCompanion.insert(
                id: id,
                capsuleId: capsuleId,
                memoryId: memoryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CapsuleItemsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CapsuleItemsTableTable,
      CapsuleItemsTableData,
      $$CapsuleItemsTableTableFilterComposer,
      $$CapsuleItemsTableTableOrderingComposer,
      $$CapsuleItemsTableTableAnnotationComposer,
      $$CapsuleItemsTableTableCreateCompanionBuilder,
      $$CapsuleItemsTableTableUpdateCompanionBuilder,
      (
        CapsuleItemsTableData,
        BaseReferences<
          _$AppDatabase,
          $CapsuleItemsTableTable,
          CapsuleItemsTableData
        >,
      ),
      CapsuleItemsTableData,
      PrefetchHooks Function()
    >;
typedef $$MemorialMessagesTableTableCreateCompanionBuilder =
    MemorialMessagesTableCompanion Function({
      required String id,
      required String nodeId,
      required String message,
      Value<String?> authorName,
      required DateTime date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$MemorialMessagesTableTableUpdateCompanionBuilder =
    MemorialMessagesTableCompanion Function({
      Value<String> id,
      Value<String> nodeId,
      Value<String> message,
      Value<String?> authorName,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$MemorialMessagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $MemorialMessagesTableTable> {
  $$MemorialMessagesTableTableFilterComposer({
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

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemorialMessagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MemorialMessagesTableTable> {
  $$MemorialMessagesTableTableOrderingComposer({
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

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get message => $composableBuilder(
    column: $table.message,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemorialMessagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemorialMessagesTableTable> {
  $$MemorialMessagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get authorName => $composableBuilder(
    column: $table.authorName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MemorialMessagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemorialMessagesTableTable,
          MemorialMessagesTableData,
          $$MemorialMessagesTableTableFilterComposer,
          $$MemorialMessagesTableTableOrderingComposer,
          $$MemorialMessagesTableTableAnnotationComposer,
          $$MemorialMessagesTableTableCreateCompanionBuilder,
          $$MemorialMessagesTableTableUpdateCompanionBuilder,
          (
            MemorialMessagesTableData,
            BaseReferences<
              _$AppDatabase,
              $MemorialMessagesTableTable,
              MemorialMessagesTableData
            >,
          ),
          MemorialMessagesTableData,
          PrefetchHooks Function()
        > {
  $$MemorialMessagesTableTableTableManager(
    _$AppDatabase db,
    $MemorialMessagesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemorialMessagesTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MemorialMessagesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MemorialMessagesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<String> message = const Value.absent(),
                Value<String?> authorName = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemorialMessagesTableCompanion(
                id: id,
                nodeId: nodeId,
                message: message,
                authorName: authorName,
                date: date,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nodeId,
                required String message,
                Value<String?> authorName = const Value.absent(),
                required DateTime date,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemorialMessagesTableCompanion.insert(
                id: id,
                nodeId: nodeId,
                message: message,
                authorName: authorName,
                date: date,
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

typedef $$MemorialMessagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemorialMessagesTableTable,
      MemorialMessagesTableData,
      $$MemorialMessagesTableTableFilterComposer,
      $$MemorialMessagesTableTableOrderingComposer,
      $$MemorialMessagesTableTableAnnotationComposer,
      $$MemorialMessagesTableTableCreateCompanionBuilder,
      $$MemorialMessagesTableTableUpdateCompanionBuilder,
      (
        MemorialMessagesTableData,
        BaseReferences<
          _$AppDatabase,
          $MemorialMessagesTableTable,
          MemorialMessagesTableData
        >,
      ),
      MemorialMessagesTableData,
      PrefetchHooks Function()
    >;
typedef $$GlossaryTableTableCreateCompanionBuilder =
    GlossaryTableCompanion Function({
      required String id,
      required String word,
      required String meaning,
      Value<String?> example,
      Value<String?> voicePath,
      Value<String?> nodeId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$GlossaryTableTableUpdateCompanionBuilder =
    GlossaryTableCompanion Function({
      Value<String> id,
      Value<String> word,
      Value<String> meaning,
      Value<String?> example,
      Value<String?> voicePath,
      Value<String?> nodeId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$GlossaryTableTableFilterComposer
    extends Composer<_$AppDatabase, $GlossaryTableTable> {
  $$GlossaryTableTableFilterComposer({
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

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voicePath => $composableBuilder(
    column: $table.voicePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GlossaryTableTableOrderingComposer
    extends Composer<_$AppDatabase, $GlossaryTableTable> {
  $$GlossaryTableTableOrderingComposer({
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

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get meaning => $composableBuilder(
    column: $table.meaning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get example => $composableBuilder(
    column: $table.example,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voicePath => $composableBuilder(
    column: $table.voicePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GlossaryTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $GlossaryTableTable> {
  $$GlossaryTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get voicePath =>
      $composableBuilder(column: $table.voicePath, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$GlossaryTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GlossaryTableTable,
          GlossaryTableData,
          $$GlossaryTableTableFilterComposer,
          $$GlossaryTableTableOrderingComposer,
          $$GlossaryTableTableAnnotationComposer,
          $$GlossaryTableTableCreateCompanionBuilder,
          $$GlossaryTableTableUpdateCompanionBuilder,
          (
            GlossaryTableData,
            BaseReferences<
              _$AppDatabase,
              $GlossaryTableTable,
              GlossaryTableData
            >,
          ),
          GlossaryTableData,
          PrefetchHooks Function()
        > {
  $$GlossaryTableTableTableManager(_$AppDatabase db, $GlossaryTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GlossaryTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GlossaryTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GlossaryTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> voicePath = const Value.absent(),
                Value<String?> nodeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlossaryTableCompanion(
                id: id,
                word: word,
                meaning: meaning,
                example: example,
                voicePath: voicePath,
                nodeId: nodeId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String word,
                required String meaning,
                Value<String?> example = const Value.absent(),
                Value<String?> voicePath = const Value.absent(),
                Value<String?> nodeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlossaryTableCompanion.insert(
                id: id,
                word: word,
                meaning: meaning,
                example: example,
                voicePath: voicePath,
                nodeId: nodeId,
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

typedef $$GlossaryTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GlossaryTableTable,
      GlossaryTableData,
      $$GlossaryTableTableFilterComposer,
      $$GlossaryTableTableOrderingComposer,
      $$GlossaryTableTableAnnotationComposer,
      $$GlossaryTableTableCreateCompanionBuilder,
      $$GlossaryTableTableUpdateCompanionBuilder,
      (
        GlossaryTableData,
        BaseReferences<_$AppDatabase, $GlossaryTableTable, GlossaryTableData>,
      ),
      GlossaryTableData,
      PrefetchHooks Function()
    >;
typedef $$RecipesTableTableCreateCompanionBuilder =
    RecipesTableCompanion Function({
      required String id,
      required String title,
      required String ingredients,
      required String instructions,
      Value<String?> photoPath,
      Value<String?> nodeId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$RecipesTableTableUpdateCompanionBuilder =
    RecipesTableCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> ingredients,
      Value<String> instructions,
      Value<String?> photoPath,
      Value<String?> nodeId,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$RecipesTableTableFilterComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecipesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecipesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecipesTableTable> {
  $$RecipesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get ingredients => $composableBuilder(
    column: $table.ingredients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get instructions => $composableBuilder(
    column: $table.instructions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$RecipesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecipesTableTable,
          RecipesTableData,
          $$RecipesTableTableFilterComposer,
          $$RecipesTableTableOrderingComposer,
          $$RecipesTableTableAnnotationComposer,
          $$RecipesTableTableCreateCompanionBuilder,
          $$RecipesTableTableUpdateCompanionBuilder,
          (
            RecipesTableData,
            BaseReferences<_$AppDatabase, $RecipesTableTable, RecipesTableData>,
          ),
          RecipesTableData,
          PrefetchHooks Function()
        > {
  $$RecipesTableTableTableManager(_$AppDatabase db, $RecipesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecipesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecipesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecipesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> ingredients = const Value.absent(),
                Value<String> instructions = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> nodeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesTableCompanion(
                id: id,
                title: title,
                ingredients: ingredients,
                instructions: instructions,
                photoPath: photoPath,
                nodeId: nodeId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String ingredients,
                required String instructions,
                Value<String?> photoPath = const Value.absent(),
                Value<String?> nodeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecipesTableCompanion.insert(
                id: id,
                title: title,
                ingredients: ingredients,
                instructions: instructions,
                photoPath: photoPath,
                nodeId: nodeId,
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

typedef $$RecipesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecipesTableTable,
      RecipesTableData,
      $$RecipesTableTableFilterComposer,
      $$RecipesTableTableOrderingComposer,
      $$RecipesTableTableAnnotationComposer,
      $$RecipesTableTableCreateCompanionBuilder,
      $$RecipesTableTableUpdateCompanionBuilder,
      (
        RecipesTableData,
        BaseReferences<_$AppDatabase, $RecipesTableTable, RecipesTableData>,
      ),
      RecipesTableData,
      PrefetchHooks Function()
    >;
typedef $$NodeLocationsTableTableCreateCompanionBuilder =
    NodeLocationsTableCompanion Function({
      required String id,
      required String nodeId,
      required String address,
      required double latitude,
      required double longitude,
      Value<int?> startYear,
      Value<int?> endYear,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$NodeLocationsTableTableUpdateCompanionBuilder =
    NodeLocationsTableCompanion Function({
      Value<String> id,
      Value<String> nodeId,
      Value<String> address,
      Value<double> latitude,
      Value<double> longitude,
      Value<int?> startYear,
      Value<int?> endYear,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$NodeLocationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $NodeLocationsTableTable> {
  $$NodeLocationsTableTableFilterComposer({
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

  ColumnFilters<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endYear => $composableBuilder(
    column: $table.endYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NodeLocationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $NodeLocationsTableTable> {
  $$NodeLocationsTableTableOrderingComposer({
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

  ColumnOrderings<String> get nodeId => $composableBuilder(
    column: $table.nodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startYear => $composableBuilder(
    column: $table.startYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endYear => $composableBuilder(
    column: $table.endYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NodeLocationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodeLocationsTableTable> {
  $$NodeLocationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nodeId =>
      $composableBuilder(column: $table.nodeId, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get startYear =>
      $composableBuilder(column: $table.startYear, builder: (column) => column);

  GeneratedColumn<int> get endYear =>
      $composableBuilder(column: $table.endYear, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$NodeLocationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodeLocationsTableTable,
          NodeLocationsTableData,
          $$NodeLocationsTableTableFilterComposer,
          $$NodeLocationsTableTableOrderingComposer,
          $$NodeLocationsTableTableAnnotationComposer,
          $$NodeLocationsTableTableCreateCompanionBuilder,
          $$NodeLocationsTableTableUpdateCompanionBuilder,
          (
            NodeLocationsTableData,
            BaseReferences<
              _$AppDatabase,
              $NodeLocationsTableTable,
              NodeLocationsTableData
            >,
          ),
          NodeLocationsTableData,
          PrefetchHooks Function()
        > {
  $$NodeLocationsTableTableTableManager(
    _$AppDatabase db,
    $NodeLocationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodeLocationsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodeLocationsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodeLocationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> nodeId = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int?> startYear = const Value.absent(),
                Value<int?> endYear = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodeLocationsTableCompanion(
                id: id,
                nodeId: nodeId,
                address: address,
                latitude: latitude,
                longitude: longitude,
                startYear: startYear,
                endYear: endYear,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String nodeId,
                required String address,
                required double latitude,
                required double longitude,
                Value<int?> startYear = const Value.absent(),
                Value<int?> endYear = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NodeLocationsTableCompanion.insert(
                id: id,
                nodeId: nodeId,
                address: address,
                latitude: latitude,
                longitude: longitude,
                startYear: startYear,
                endYear: endYear,
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

typedef $$NodeLocationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodeLocationsTableTable,
      NodeLocationsTableData,
      $$NodeLocationsTableTableFilterComposer,
      $$NodeLocationsTableTableOrderingComposer,
      $$NodeLocationsTableTableAnnotationComposer,
      $$NodeLocationsTableTableCreateCompanionBuilder,
      $$NodeLocationsTableTableUpdateCompanionBuilder,
      (
        NodeLocationsTableData,
        BaseReferences<
          _$AppDatabase,
          $NodeLocationsTableTable,
          NodeLocationsTableData
        >,
      ),
      NodeLocationsTableData,
      PrefetchHooks Function()
    >;
typedef $$VoiceLegacyTableTableCreateCompanionBuilder =
    VoiceLegacyTableCompanion Function({
      required String id,
      required String fromNodeId,
      required String toNodeId,
      required String title,
      required String voicePath,
      Value<int> durationSeconds,
      Value<String> openCondition,
      Value<DateTime?> openDate,
      Value<bool> isOpened,
      Value<DateTime?> openedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$VoiceLegacyTableTableUpdateCompanionBuilder =
    VoiceLegacyTableCompanion Function({
      Value<String> id,
      Value<String> fromNodeId,
      Value<String> toNodeId,
      Value<String> title,
      Value<String> voicePath,
      Value<int> durationSeconds,
      Value<String> openCondition,
      Value<DateTime?> openDate,
      Value<bool> isOpened,
      Value<DateTime?> openedAt,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$VoiceLegacyTableTableFilterComposer
    extends Composer<_$AppDatabase, $VoiceLegacyTableTable> {
  $$VoiceLegacyTableTableFilterComposer({
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

  ColumnFilters<String> get fromNodeId => $composableBuilder(
    column: $table.fromNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toNodeId => $composableBuilder(
    column: $table.toNodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get voicePath => $composableBuilder(
    column: $table.voicePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openCondition => $composableBuilder(
    column: $table.openCondition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOpened => $composableBuilder(
    column: $table.isOpened,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VoiceLegacyTableTableOrderingComposer
    extends Composer<_$AppDatabase, $VoiceLegacyTableTable> {
  $$VoiceLegacyTableTableOrderingComposer({
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

  ColumnOrderings<String> get fromNodeId => $composableBuilder(
    column: $table.fromNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toNodeId => $composableBuilder(
    column: $table.toNodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get voicePath => $composableBuilder(
    column: $table.voicePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openCondition => $composableBuilder(
    column: $table.openCondition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openDate => $composableBuilder(
    column: $table.openDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOpened => $composableBuilder(
    column: $table.isOpened,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VoiceLegacyTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $VoiceLegacyTableTable> {
  $$VoiceLegacyTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fromNodeId => $composableBuilder(
    column: $table.fromNodeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toNodeId =>
      $composableBuilder(column: $table.toNodeId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get voicePath =>
      $composableBuilder(column: $table.voicePath, builder: (column) => column);

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openCondition => $composableBuilder(
    column: $table.openCondition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openDate =>
      $composableBuilder(column: $table.openDate, builder: (column) => column);

  GeneratedColumn<bool> get isOpened =>
      $composableBuilder(column: $table.isOpened, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$VoiceLegacyTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VoiceLegacyTableTable,
          VoiceLegacyTableData,
          $$VoiceLegacyTableTableFilterComposer,
          $$VoiceLegacyTableTableOrderingComposer,
          $$VoiceLegacyTableTableAnnotationComposer,
          $$VoiceLegacyTableTableCreateCompanionBuilder,
          $$VoiceLegacyTableTableUpdateCompanionBuilder,
          (
            VoiceLegacyTableData,
            BaseReferences<
              _$AppDatabase,
              $VoiceLegacyTableTable,
              VoiceLegacyTableData
            >,
          ),
          VoiceLegacyTableData,
          PrefetchHooks Function()
        > {
  $$VoiceLegacyTableTableTableManager(
    _$AppDatabase db,
    $VoiceLegacyTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VoiceLegacyTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VoiceLegacyTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VoiceLegacyTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> fromNodeId = const Value.absent(),
                Value<String> toNodeId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> voicePath = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<String> openCondition = const Value.absent(),
                Value<DateTime?> openDate = const Value.absent(),
                Value<bool> isOpened = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoiceLegacyTableCompanion(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                title: title,
                voicePath: voicePath,
                durationSeconds: durationSeconds,
                openCondition: openCondition,
                openDate: openDate,
                isOpened: isOpened,
                openedAt: openedAt,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String fromNodeId,
                required String toNodeId,
                required String title,
                required String voicePath,
                Value<int> durationSeconds = const Value.absent(),
                Value<String> openCondition = const Value.absent(),
                Value<DateTime?> openDate = const Value.absent(),
                Value<bool> isOpened = const Value.absent(),
                Value<DateTime?> openedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VoiceLegacyTableCompanion.insert(
                id: id,
                fromNodeId: fromNodeId,
                toNodeId: toNodeId,
                title: title,
                voicePath: voicePath,
                durationSeconds: durationSeconds,
                openCondition: openCondition,
                openDate: openDate,
                isOpened: isOpened,
                openedAt: openedAt,
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

typedef $$VoiceLegacyTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VoiceLegacyTableTable,
      VoiceLegacyTableData,
      $$VoiceLegacyTableTableFilterComposer,
      $$VoiceLegacyTableTableOrderingComposer,
      $$VoiceLegacyTableTableAnnotationComposer,
      $$VoiceLegacyTableTableCreateCompanionBuilder,
      $$VoiceLegacyTableTableUpdateCompanionBuilder,
      (
        VoiceLegacyTableData,
        BaseReferences<
          _$AppDatabase,
          $VoiceLegacyTableTable,
          VoiceLegacyTableData
        >,
      ),
      VoiceLegacyTableData,
      PrefetchHooks Function()
    >;
typedef $$ThenNowTableTableCreateCompanionBuilder =
    ThenNowTableCompanion Function({
      required String id,
      required String memoryId1,
      required String memoryId2,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$ThenNowTableTableUpdateCompanionBuilder =
    ThenNowTableCompanion Function({
      Value<String> id,
      Value<String> memoryId1,
      Value<String> memoryId2,
      Value<String?> label,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ThenNowTableTableFilterComposer
    extends Composer<_$AppDatabase, $ThenNowTableTable> {
  $$ThenNowTableTableFilterComposer({
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

  ColumnFilters<String> get memoryId1 => $composableBuilder(
    column: $table.memoryId1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memoryId2 => $composableBuilder(
    column: $table.memoryId2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThenNowTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ThenNowTableTable> {
  $$ThenNowTableTableOrderingComposer({
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

  ColumnOrderings<String> get memoryId1 => $composableBuilder(
    column: $table.memoryId1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memoryId2 => $composableBuilder(
    column: $table.memoryId2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThenNowTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ThenNowTableTable> {
  $$ThenNowTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoryId1 =>
      $composableBuilder(column: $table.memoryId1, builder: (column) => column);

  GeneratedColumn<String> get memoryId2 =>
      $composableBuilder(column: $table.memoryId2, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ThenNowTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ThenNowTableTable,
          ThenNowTableData,
          $$ThenNowTableTableFilterComposer,
          $$ThenNowTableTableOrderingComposer,
          $$ThenNowTableTableAnnotationComposer,
          $$ThenNowTableTableCreateCompanionBuilder,
          $$ThenNowTableTableUpdateCompanionBuilder,
          (
            ThenNowTableData,
            BaseReferences<_$AppDatabase, $ThenNowTableTable, ThenNowTableData>,
          ),
          ThenNowTableData,
          PrefetchHooks Function()
        > {
  $$ThenNowTableTableTableManager(_$AppDatabase db, $ThenNowTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThenNowTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThenNowTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThenNowTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> memoryId1 = const Value.absent(),
                Value<String> memoryId2 = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThenNowTableCompanion(
                id: id,
                memoryId1: memoryId1,
                memoryId2: memoryId2,
                label: label,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String memoryId1,
                required String memoryId2,
                Value<String?> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ThenNowTableCompanion.insert(
                id: id,
                memoryId1: memoryId1,
                memoryId2: memoryId2,
                label: label,
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

typedef $$ThenNowTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ThenNowTableTable,
      ThenNowTableData,
      $$ThenNowTableTableFilterComposer,
      $$ThenNowTableTableOrderingComposer,
      $$ThenNowTableTableAnnotationComposer,
      $$ThenNowTableTableCreateCompanionBuilder,
      $$ThenNowTableTableUpdateCompanionBuilder,
      (
        ThenNowTableData,
        BaseReferences<_$AppDatabase, $ThenNowTableTable, ThenNowTableData>,
      ),
      ThenNowTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfileTableTableTableManager get profileTable =>
      $$ProfileTableTableTableManager(_db, _db.profileTable);
  $$NodesTableTableTableManager get nodesTable =>
      $$NodesTableTableTableManager(_db, _db.nodesTable);
  $$NodeEdgesTableTableTableManager get nodeEdgesTable =>
      $$NodeEdgesTableTableTableManager(_db, _db.nodeEdgesTable);
  $$MemoriesTableTableTableManager get memoriesTable =>
      $$MemoriesTableTableTableManager(_db, _db.memoriesTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$TemperatureLogsTableTableTableManager get temperatureLogsTable =>
      $$TemperatureLogsTableTableTableManager(_db, _db.temperatureLogsTable);
  $$BouquetsTableTableTableManager get bouquetsTable =>
      $$BouquetsTableTableTableManager(_db, _db.bouquetsTable);
  $$CapsulesTableTableTableManager get capsulesTable =>
      $$CapsulesTableTableTableManager(_db, _db.capsulesTable);
  $$CapsuleItemsTableTableTableManager get capsuleItemsTable =>
      $$CapsuleItemsTableTableTableManager(_db, _db.capsuleItemsTable);
  $$MemorialMessagesTableTableTableManager get memorialMessagesTable =>
      $$MemorialMessagesTableTableTableManager(_db, _db.memorialMessagesTable);
  $$GlossaryTableTableTableManager get glossaryTable =>
      $$GlossaryTableTableTableManager(_db, _db.glossaryTable);
  $$RecipesTableTableTableManager get recipesTable =>
      $$RecipesTableTableTableManager(_db, _db.recipesTable);
  $$NodeLocationsTableTableTableManager get nodeLocationsTable =>
      $$NodeLocationsTableTableTableManager(_db, _db.nodeLocationsTable);
  $$VoiceLegacyTableTableTableManager get voiceLegacyTable =>
      $$VoiceLegacyTableTableTableManager(_db, _db.voiceLegacyTable);
  $$ThenNowTableTableTableManager get thenNowTable =>
      $$ThenNowTableTableTableManager(_db, _db.thenNowTable);
}
