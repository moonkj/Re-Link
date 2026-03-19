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
          ..write('createdAt: $createdAt')
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
          other.createdAt == this.createdAt);
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfileTableTable profileTable = $ProfileTableTable(this);
  late final $NodesTableTable nodesTable = $NodesTableTable(this);
  late final $NodeEdgesTableTable nodeEdgesTable = $NodeEdgesTableTable(this);
  late final $MemoriesTableTable memoriesTable = $MemoriesTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
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
}
