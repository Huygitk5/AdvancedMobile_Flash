// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class Topics extends Table with TableInfo<Topics, Topic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Topics(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'A1\'',
    defaultValue: const CustomExpression('\'A1\''),
  );
  static const VerificationMeta _coverColorMeta = const VerificationMeta(
    'coverColor',
  );
  late final GeneratedColumn<int> coverColor = GeneratedColumn<int>(
    'cover_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 10',
    defaultValue: const CustomExpression('10'),
  );
  static const VerificationMeta _totalWordsMeta = const VerificationMeta(
    'totalWords',
  );
  late final GeneratedColumn<int> totalWords = GeneratedColumn<int>(
    'total_words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    iconPath,
    level,
    coverColor,
    estimatedMinutes,
    totalWords,
    sortOrder,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<Topic> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    } else if (isInserting) {
      context.missing(_iconPathMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('cover_color')) {
      context.handle(
        _coverColorMeta,
        coverColor.isAcceptableOrUnknown(data['cover_color']!, _coverColorMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('total_words')) {
      context.handle(
        _totalWordsMeta,
        totalWords.isAcceptableOrUnknown(data['total_words']!, _totalWordsMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Topic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Topic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      coverColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_color'],
      ),
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      totalWords: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_words'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      )!,
    );
  }

  @override
  Topics createAlias(String alias) {
    return Topics(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Topic extends DataClass implements Insertable<Topic> {
  final String id;
  final String title;
  final String? description;
  final String iconPath;
  final String level;
  final int? coverColor;
  final int estimatedMinutes;
  final int totalWords;
  final int sortOrder;
  final int serverUpdatedAt;
  const Topic({
    required this.id,
    required this.title,
    this.description,
    required this.iconPath,
    required this.level,
    this.coverColor,
    required this.estimatedMinutes,
    required this.totalWords,
    required this.sortOrder,
    required this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['icon_path'] = Variable<String>(iconPath);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || coverColor != null) {
      map['cover_color'] = Variable<int>(coverColor);
    }
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['total_words'] = Variable<int>(totalWords);
    map['sort_order'] = Variable<int>(sortOrder);
    map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    return map;
  }

  TopicsCompanion toCompanion(bool nullToAbsent) {
    return TopicsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      iconPath: Value(iconPath),
      level: Value(level),
      coverColor: coverColor == null && nullToAbsent
          ? const Value.absent()
          : Value(coverColor),
      estimatedMinutes: Value(estimatedMinutes),
      totalWords: Value(totalWords),
      sortOrder: Value(sortOrder),
      serverUpdatedAt: Value(serverUpdatedAt),
    );
  }

  factory Topic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Topic(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      iconPath: serializer.fromJson<String>(json['icon_path']),
      level: serializer.fromJson<String>(json['level']),
      coverColor: serializer.fromJson<int?>(json['cover_color']),
      estimatedMinutes: serializer.fromJson<int>(json['estimated_minutes']),
      totalWords: serializer.fromJson<int>(json['total_words']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      serverUpdatedAt: serializer.fromJson<int>(json['server_updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'icon_path': serializer.toJson<String>(iconPath),
      'level': serializer.toJson<String>(level),
      'cover_color': serializer.toJson<int?>(coverColor),
      'estimated_minutes': serializer.toJson<int>(estimatedMinutes),
      'total_words': serializer.toJson<int>(totalWords),
      'sort_order': serializer.toJson<int>(sortOrder),
      'server_updated_at': serializer.toJson<int>(serverUpdatedAt),
    };
  }

  Topic copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? iconPath,
    String? level,
    Value<int?> coverColor = const Value.absent(),
    int? estimatedMinutes,
    int? totalWords,
    int? sortOrder,
    int? serverUpdatedAt,
  }) => Topic(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    iconPath: iconPath ?? this.iconPath,
    level: level ?? this.level,
    coverColor: coverColor.present ? coverColor.value : this.coverColor,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    totalWords: totalWords ?? this.totalWords,
    sortOrder: sortOrder ?? this.sortOrder,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
  );
  Topic copyWithCompanion(TopicsCompanion data) {
    return Topic(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      level: data.level.present ? data.level.value : this.level,
      coverColor: data.coverColor.present
          ? data.coverColor.value
          : this.coverColor,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      totalWords: data.totalWords.present
          ? data.totalWords.value
          : this.totalWords,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Topic(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconPath: $iconPath, ')
          ..write('level: $level, ')
          ..write('coverColor: $coverColor, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('totalWords: $totalWords, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    iconPath,
    level,
    coverColor,
    estimatedMinutes,
    totalWords,
    sortOrder,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Topic &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.iconPath == this.iconPath &&
          other.level == this.level &&
          other.coverColor == this.coverColor &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.totalWords == this.totalWords &&
          other.sortOrder == this.sortOrder &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class TopicsCompanion extends UpdateCompanion<Topic> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> iconPath;
  final Value<String> level;
  final Value<int?> coverColor;
  final Value<int> estimatedMinutes;
  final Value<int> totalWords;
  final Value<int> sortOrder;
  final Value<int> serverUpdatedAt;
  final Value<int> rowid;
  const TopicsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.level = const Value.absent(),
    this.coverColor = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.totalWords = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TopicsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String iconPath,
    this.level = const Value.absent(),
    this.coverColor = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.totalWords = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int serverUpdatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       iconPath = Value(iconPath),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<Topic> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? iconPath,
    Expression<String>? level,
    Expression<int>? coverColor,
    Expression<int>? estimatedMinutes,
    Expression<int>? totalWords,
    Expression<int>? sortOrder,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (iconPath != null) 'icon_path': iconPath,
      if (level != null) 'level': level,
      if (coverColor != null) 'cover_color': coverColor,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (totalWords != null) 'total_words': totalWords,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TopicsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? iconPath,
    Value<String>? level,
    Value<int?>? coverColor,
    Value<int>? estimatedMinutes,
    Value<int>? totalWords,
    Value<int>? sortOrder,
    Value<int>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return TopicsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      level: level ?? this.level,
      coverColor: coverColor ?? this.coverColor,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      totalWords: totalWords ?? this.totalWords,
      sortOrder: sortOrder ?? this.sortOrder,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (coverColor.present) {
      map['cover_color'] = Variable<int>(coverColor.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (totalWords.present) {
      map['total_words'] = Variable<int>(totalWords.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('iconPath: $iconPath, ')
          ..write('level: $level, ')
          ..write('coverColor: $coverColor, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('totalWords: $totalWords, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Flashcards extends Table with TableInfo<Flashcards, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Flashcards(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES topics(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _partOfSpeechMeta = const VerificationMeta(
    'partOfSpeech',
  );
  late final GeneratedColumn<String> partOfSpeech = GeneratedColumn<String>(
    'part_of_speech',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _pronunciationMeta = const VerificationMeta(
    'pronunciation',
  );
  late final GeneratedColumn<String> pronunciation = GeneratedColumn<String>(
    'pronunciation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _meaningMeta = const VerificationMeta(
    'meaning',
  );
  late final GeneratedColumn<String> meaning = GeneratedColumn<String>(
    'meaning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _exampleMeta = const VerificationMeta(
    'example',
  );
  late final GeneratedColumn<String> example = GeneratedColumn<String>(
    'example',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _exampleTranslationMeta =
      const VerificationMeta('exampleTranslation');
  late final GeneratedColumn<String> exampleTranslation =
      GeneratedColumn<String>(
        'example_translation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    topicId,
    word,
    partOfSpeech,
    pronunciation,
    meaning,
    example,
    exampleTranslation,
    audioUrl,
    imageUrl,
    sortOrder,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(
    Insertable<Flashcard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('part_of_speech')) {
      context.handle(
        _partOfSpeechMeta,
        partOfSpeech.isAcceptableOrUnknown(
          data['part_of_speech']!,
          _partOfSpeechMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partOfSpeechMeta);
    }
    if (data.containsKey('pronunciation')) {
      context.handle(
        _pronunciationMeta,
        pronunciation.isAcceptableOrUnknown(
          data['pronunciation']!,
          _pronunciationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pronunciationMeta);
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
    if (data.containsKey('example_translation')) {
      context.handle(
        _exampleTranslationMeta,
        exampleTranslation.isAcceptableOrUnknown(
          data['example_translation']!,
          _exampleTranslationMeta,
        ),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      partOfSpeech: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_of_speech'],
      )!,
      pronunciation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pronunciation'],
      )!,
      meaning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meaning'],
      )!,
      example: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example'],
      ),
      exampleTranslation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}example_translation'],
      ),
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      )!,
    );
  }

  @override
  Flashcards createAlias(String alias) {
    return Flashcards(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final String id;
  final String topicId;
  final String word;
  final String partOfSpeech;
  final String pronunciation;
  final String meaning;
  final String? example;
  final String? exampleTranslation;
  final String? audioUrl;
  final String? imageUrl;
  final int sortOrder;
  final int serverUpdatedAt;
  const Flashcard({
    required this.id,
    required this.topicId,
    required this.word,
    required this.partOfSpeech,
    required this.pronunciation,
    required this.meaning,
    this.example,
    this.exampleTranslation,
    this.audioUrl,
    this.imageUrl,
    required this.sortOrder,
    required this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['word'] = Variable<String>(word);
    map['part_of_speech'] = Variable<String>(partOfSpeech);
    map['pronunciation'] = Variable<String>(pronunciation);
    map['meaning'] = Variable<String>(meaning);
    if (!nullToAbsent || example != null) {
      map['example'] = Variable<String>(example);
    }
    if (!nullToAbsent || exampleTranslation != null) {
      map['example_translation'] = Variable<String>(exampleTranslation);
    }
    if (!nullToAbsent || audioUrl != null) {
      map['audio_url'] = Variable<String>(audioUrl);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      topicId: Value(topicId),
      word: Value(word),
      partOfSpeech: Value(partOfSpeech),
      pronunciation: Value(pronunciation),
      meaning: Value(meaning),
      example: example == null && nullToAbsent
          ? const Value.absent()
          : Value(example),
      exampleTranslation: exampleTranslation == null && nullToAbsent
          ? const Value.absent()
          : Value(exampleTranslation),
      audioUrl: audioUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(audioUrl),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      sortOrder: Value(sortOrder),
      serverUpdatedAt: Value(serverUpdatedAt),
    );
  }

  factory Flashcard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topic_id']),
      word: serializer.fromJson<String>(json['word']),
      partOfSpeech: serializer.fromJson<String>(json['part_of_speech']),
      pronunciation: serializer.fromJson<String>(json['pronunciation']),
      meaning: serializer.fromJson<String>(json['meaning']),
      example: serializer.fromJson<String?>(json['example']),
      exampleTranslation: serializer.fromJson<String?>(
        json['example_translation'],
      ),
      audioUrl: serializer.fromJson<String?>(json['audio_url']),
      imageUrl: serializer.fromJson<String?>(json['image_url']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      serverUpdatedAt: serializer.fromJson<int>(json['server_updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topic_id': serializer.toJson<String>(topicId),
      'word': serializer.toJson<String>(word),
      'part_of_speech': serializer.toJson<String>(partOfSpeech),
      'pronunciation': serializer.toJson<String>(pronunciation),
      'meaning': serializer.toJson<String>(meaning),
      'example': serializer.toJson<String?>(example),
      'example_translation': serializer.toJson<String?>(exampleTranslation),
      'audio_url': serializer.toJson<String?>(audioUrl),
      'image_url': serializer.toJson<String?>(imageUrl),
      'sort_order': serializer.toJson<int>(sortOrder),
      'server_updated_at': serializer.toJson<int>(serverUpdatedAt),
    };
  }

  Flashcard copyWith({
    String? id,
    String? topicId,
    String? word,
    String? partOfSpeech,
    String? pronunciation,
    String? meaning,
    Value<String?> example = const Value.absent(),
    Value<String?> exampleTranslation = const Value.absent(),
    Value<String?> audioUrl = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    int? sortOrder,
    int? serverUpdatedAt,
  }) => Flashcard(
    id: id ?? this.id,
    topicId: topicId ?? this.topicId,
    word: word ?? this.word,
    partOfSpeech: partOfSpeech ?? this.partOfSpeech,
    pronunciation: pronunciation ?? this.pronunciation,
    meaning: meaning ?? this.meaning,
    example: example.present ? example.value : this.example,
    exampleTranslation: exampleTranslation.present
        ? exampleTranslation.value
        : this.exampleTranslation,
    audioUrl: audioUrl.present ? audioUrl.value : this.audioUrl,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    sortOrder: sortOrder ?? this.sortOrder,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
  );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      word: data.word.present ? data.word.value : this.word,
      partOfSpeech: data.partOfSpeech.present
          ? data.partOfSpeech.value
          : this.partOfSpeech,
      pronunciation: data.pronunciation.present
          ? data.pronunciation.value
          : this.pronunciation,
      meaning: data.meaning.present ? data.meaning.value : this.meaning,
      example: data.example.present ? data.example.value : this.example,
      exampleTranslation: data.exampleTranslation.present
          ? data.exampleTranslation.value
          : this.exampleTranslation,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    topicId,
    word,
    partOfSpeech,
    pronunciation,
    meaning,
    example,
    exampleTranslation,
    audioUrl,
    imageUrl,
    sortOrder,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.word == this.word &&
          other.partOfSpeech == this.partOfSpeech &&
          other.pronunciation == this.pronunciation &&
          other.meaning == this.meaning &&
          other.example == this.example &&
          other.exampleTranslation == this.exampleTranslation &&
          other.audioUrl == this.audioUrl &&
          other.imageUrl == this.imageUrl &&
          other.sortOrder == this.sortOrder &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> word;
  final Value<String> partOfSpeech;
  final Value<String> pronunciation;
  final Value<String> meaning;
  final Value<String?> example;
  final Value<String?> exampleTranslation;
  final Value<String?> audioUrl;
  final Value<String?> imageUrl;
  final Value<int> sortOrder;
  final Value<int> serverUpdatedAt;
  final Value<int> rowid;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.word = const Value.absent(),
    this.partOfSpeech = const Value.absent(),
    this.pronunciation = const Value.absent(),
    this.meaning = const Value.absent(),
    this.example = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    required String id,
    required String topicId,
    required String word,
    required String partOfSpeech,
    required String pronunciation,
    required String meaning,
    this.example = const Value.absent(),
    this.exampleTranslation = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int serverUpdatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       topicId = Value(topicId),
       word = Value(word),
       partOfSpeech = Value(partOfSpeech),
       pronunciation = Value(pronunciation),
       meaning = Value(meaning),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<Flashcard> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? word,
    Expression<String>? partOfSpeech,
    Expression<String>? pronunciation,
    Expression<String>? meaning,
    Expression<String>? example,
    Expression<String>? exampleTranslation,
    Expression<String>? audioUrl,
    Expression<String>? imageUrl,
    Expression<int>? sortOrder,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (word != null) 'word': word,
      if (partOfSpeech != null) 'part_of_speech': partOfSpeech,
      if (pronunciation != null) 'pronunciation': pronunciation,
      if (meaning != null) 'meaning': meaning,
      if (example != null) 'example': example,
      if (exampleTranslation != null) 'example_translation': exampleTranslation,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (imageUrl != null) 'image_url': imageUrl,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardsCompanion copyWith({
    Value<String>? id,
    Value<String>? topicId,
    Value<String>? word,
    Value<String>? partOfSpeech,
    Value<String>? pronunciation,
    Value<String>? meaning,
    Value<String?>? example,
    Value<String?>? exampleTranslation,
    Value<String?>? audioUrl,
    Value<String?>? imageUrl,
    Value<int>? sortOrder,
    Value<int>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      pronunciation: pronunciation ?? this.pronunciation,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      exampleTranslation: exampleTranslation ?? this.exampleTranslation,
      audioUrl: audioUrl ?? this.audioUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (partOfSpeech.present) {
      map['part_of_speech'] = Variable<String>(partOfSpeech.value);
    }
    if (pronunciation.present) {
      map['pronunciation'] = Variable<String>(pronunciation.value);
    }
    if (meaning.present) {
      map['meaning'] = Variable<String>(meaning.value);
    }
    if (example.present) {
      map['example'] = Variable<String>(example.value);
    }
    if (exampleTranslation.present) {
      map['example_translation'] = Variable<String>(exampleTranslation.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('word: $word, ')
          ..write('partOfSpeech: $partOfSpeech, ')
          ..write('pronunciation: $pronunciation, ')
          ..write('meaning: $meaning, ')
          ..write('example: $example, ')
          ..write('exampleTranslation: $exampleTranslation, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class GrammarLessons extends Table
    with TableInfo<GrammarLessons, GrammarLesson> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GrammarLessons(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _structureMeta = const VerificationMeta(
    'structure',
  );
  late final GeneratedColumn<String> structure = GeneratedColumn<String>(
    'structure',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _usageNotesMeta = const VerificationMeta(
    'usageNotes',
  );
  late final GeneratedColumn<String> usageNotes = GeneratedColumn<String>(
    'usage_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'A1\'',
    defaultValue: const CustomExpression('\'A1\''),
  );
  static const VerificationMeta _coverColorMeta = const VerificationMeta(
    'coverColor',
  );
  late final GeneratedColumn<int> coverColor = GeneratedColumn<int>(
    'cover_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 10',
    defaultValue: const CustomExpression('10'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    structure,
    content,
    usageNotes,
    iconName,
    level,
    coverColor,
    estimatedMinutes,
    sortOrder,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_lessons';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarLesson> instance, {
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
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('structure')) {
      context.handle(
        _structureMeta,
        structure.isAcceptableOrUnknown(data['structure']!, _structureMeta),
      );
    } else if (isInserting) {
      context.missing(_structureMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('usage_notes')) {
      context.handle(
        _usageNotesMeta,
        usageNotes.isAcceptableOrUnknown(data['usage_notes']!, _usageNotesMeta),
      );
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('cover_color')) {
      context.handle(
        _coverColorMeta,
        coverColor.isAcceptableOrUnknown(data['cover_color']!, _coverColorMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarLesson map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarLesson(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      structure: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}structure'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      usageNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_notes'],
      ),
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      coverColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cover_color'],
      ),
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      )!,
    );
  }

  @override
  GrammarLessons createAlias(String alias) {
    return GrammarLessons(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class GrammarLesson extends DataClass implements Insertable<GrammarLesson> {
  final String id;
  final String title;
  final String? description;
  final String structure;
  final String? content;
  final String? usageNotes;
  final String iconName;
  final String level;
  final int? coverColor;
  final int estimatedMinutes;
  final int sortOrder;
  final int serverUpdatedAt;
  const GrammarLesson({
    required this.id,
    required this.title,
    this.description,
    required this.structure,
    this.content,
    this.usageNotes,
    required this.iconName,
    required this.level,
    this.coverColor,
    required this.estimatedMinutes,
    required this.sortOrder,
    required this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['structure'] = Variable<String>(structure);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || usageNotes != null) {
      map['usage_notes'] = Variable<String>(usageNotes);
    }
    map['icon_name'] = Variable<String>(iconName);
    map['level'] = Variable<String>(level);
    if (!nullToAbsent || coverColor != null) {
      map['cover_color'] = Variable<int>(coverColor);
    }
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['sort_order'] = Variable<int>(sortOrder);
    map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    return map;
  }

  GrammarLessonsCompanion toCompanion(bool nullToAbsent) {
    return GrammarLessonsCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      structure: Value(structure),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      usageNotes: usageNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(usageNotes),
      iconName: Value(iconName),
      level: Value(level),
      coverColor: coverColor == null && nullToAbsent
          ? const Value.absent()
          : Value(coverColor),
      estimatedMinutes: Value(estimatedMinutes),
      sortOrder: Value(sortOrder),
      serverUpdatedAt: Value(serverUpdatedAt),
    );
  }

  factory GrammarLesson.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarLesson(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      structure: serializer.fromJson<String>(json['structure']),
      content: serializer.fromJson<String?>(json['content']),
      usageNotes: serializer.fromJson<String?>(json['usage_notes']),
      iconName: serializer.fromJson<String>(json['icon_name']),
      level: serializer.fromJson<String>(json['level']),
      coverColor: serializer.fromJson<int?>(json['cover_color']),
      estimatedMinutes: serializer.fromJson<int>(json['estimated_minutes']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      serverUpdatedAt: serializer.fromJson<int>(json['server_updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'structure': serializer.toJson<String>(structure),
      'content': serializer.toJson<String?>(content),
      'usage_notes': serializer.toJson<String?>(usageNotes),
      'icon_name': serializer.toJson<String>(iconName),
      'level': serializer.toJson<String>(level),
      'cover_color': serializer.toJson<int?>(coverColor),
      'estimated_minutes': serializer.toJson<int>(estimatedMinutes),
      'sort_order': serializer.toJson<int>(sortOrder),
      'server_updated_at': serializer.toJson<int>(serverUpdatedAt),
    };
  }

  GrammarLesson copyWith({
    String? id,
    String? title,
    Value<String?> description = const Value.absent(),
    String? structure,
    Value<String?> content = const Value.absent(),
    Value<String?> usageNotes = const Value.absent(),
    String? iconName,
    String? level,
    Value<int?> coverColor = const Value.absent(),
    int? estimatedMinutes,
    int? sortOrder,
    int? serverUpdatedAt,
  }) => GrammarLesson(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    structure: structure ?? this.structure,
    content: content.present ? content.value : this.content,
    usageNotes: usageNotes.present ? usageNotes.value : this.usageNotes,
    iconName: iconName ?? this.iconName,
    level: level ?? this.level,
    coverColor: coverColor.present ? coverColor.value : this.coverColor,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    sortOrder: sortOrder ?? this.sortOrder,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
  );
  GrammarLesson copyWithCompanion(GrammarLessonsCompanion data) {
    return GrammarLesson(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      structure: data.structure.present ? data.structure.value : this.structure,
      content: data.content.present ? data.content.value : this.content,
      usageNotes: data.usageNotes.present
          ? data.usageNotes.value
          : this.usageNotes,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      level: data.level.present ? data.level.value : this.level,
      coverColor: data.coverColor.present
          ? data.coverColor.value
          : this.coverColor,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarLesson(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('structure: $structure, ')
          ..write('content: $content, ')
          ..write('usageNotes: $usageNotes, ')
          ..write('iconName: $iconName, ')
          ..write('level: $level, ')
          ..write('coverColor: $coverColor, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    structure,
    content,
    usageNotes,
    iconName,
    level,
    coverColor,
    estimatedMinutes,
    sortOrder,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarLesson &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.structure == this.structure &&
          other.content == this.content &&
          other.usageNotes == this.usageNotes &&
          other.iconName == this.iconName &&
          other.level == this.level &&
          other.coverColor == this.coverColor &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.sortOrder == this.sortOrder &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class GrammarLessonsCompanion extends UpdateCompanion<GrammarLesson> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<String> structure;
  final Value<String?> content;
  final Value<String?> usageNotes;
  final Value<String> iconName;
  final Value<String> level;
  final Value<int?> coverColor;
  final Value<int> estimatedMinutes;
  final Value<int> sortOrder;
  final Value<int> serverUpdatedAt;
  final Value<int> rowid;
  const GrammarLessonsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.structure = const Value.absent(),
    this.content = const Value.absent(),
    this.usageNotes = const Value.absent(),
    this.iconName = const Value.absent(),
    this.level = const Value.absent(),
    this.coverColor = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrammarLessonsCompanion.insert({
    required String id,
    required String title,
    this.description = const Value.absent(),
    required String structure,
    this.content = const Value.absent(),
    this.usageNotes = const Value.absent(),
    required String iconName,
    this.level = const Value.absent(),
    this.coverColor = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int serverUpdatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       structure = Value(structure),
       iconName = Value(iconName),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<GrammarLesson> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? structure,
    Expression<String>? content,
    Expression<String>? usageNotes,
    Expression<String>? iconName,
    Expression<String>? level,
    Expression<int>? coverColor,
    Expression<int>? estimatedMinutes,
    Expression<int>? sortOrder,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (structure != null) 'structure': structure,
      if (content != null) 'content': content,
      if (usageNotes != null) 'usage_notes': usageNotes,
      if (iconName != null) 'icon_name': iconName,
      if (level != null) 'level': level,
      if (coverColor != null) 'cover_color': coverColor,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrammarLessonsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String?>? description,
    Value<String>? structure,
    Value<String?>? content,
    Value<String?>? usageNotes,
    Value<String>? iconName,
    Value<String>? level,
    Value<int?>? coverColor,
    Value<int>? estimatedMinutes,
    Value<int>? sortOrder,
    Value<int>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return GrammarLessonsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      structure: structure ?? this.structure,
      content: content ?? this.content,
      usageNotes: usageNotes ?? this.usageNotes,
      iconName: iconName ?? this.iconName,
      level: level ?? this.level,
      coverColor: coverColor ?? this.coverColor,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      sortOrder: sortOrder ?? this.sortOrder,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (structure.present) {
      map['structure'] = Variable<String>(structure.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (usageNotes.present) {
      map['usage_notes'] = Variable<String>(usageNotes.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (coverColor.present) {
      map['cover_color'] = Variable<int>(coverColor.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarLessonsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('structure: $structure, ')
          ..write('content: $content, ')
          ..write('usageNotes: $usageNotes, ')
          ..write('iconName: $iconName, ')
          ..write('level: $level, ')
          ..write('coverColor: $coverColor, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class GrammarExamples extends Table
    with TableInfo<GrammarExamples, GrammarExample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  GrammarExamples(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _grammarLessonIdMeta = const VerificationMeta(
    'grammarLessonId',
  );
  late final GeneratedColumn<String> grammarLessonId = GeneratedColumn<String>(
    'grammar_lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES grammar_lessons(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _sentenceMeta = const VerificationMeta(
    'sentence',
  );
  late final GeneratedColumn<String> sentence = GeneratedColumn<String>(
    'sentence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _translationMeta = const VerificationMeta(
    'translation',
  );
  late final GeneratedColumn<String> translation = GeneratedColumn<String>(
    'translation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _highlightMeta = const VerificationMeta(
    'highlight',
  );
  late final GeneratedColumn<String> highlight = GeneratedColumn<String>(
    'highlight',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    grammarLessonId,
    sentence,
    translation,
    highlight,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grammar_examples';
  @override
  VerificationContext validateIntegrity(
    Insertable<GrammarExample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('grammar_lesson_id')) {
      context.handle(
        _grammarLessonIdMeta,
        grammarLessonId.isAcceptableOrUnknown(
          data['grammar_lesson_id']!,
          _grammarLessonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grammarLessonIdMeta);
    }
    if (data.containsKey('sentence')) {
      context.handle(
        _sentenceMeta,
        sentence.isAcceptableOrUnknown(data['sentence']!, _sentenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sentenceMeta);
    }
    if (data.containsKey('translation')) {
      context.handle(
        _translationMeta,
        translation.isAcceptableOrUnknown(
          data['translation']!,
          _translationMeta,
        ),
      );
    }
    if (data.containsKey('highlight')) {
      context.handle(
        _highlightMeta,
        highlight.isAcceptableOrUnknown(data['highlight']!, _highlightMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GrammarExample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GrammarExample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      grammarLessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_lesson_id'],
      )!,
      sentence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sentence'],
      )!,
      translation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}translation'],
      ),
      highlight: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}highlight'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  GrammarExamples createAlias(String alias) {
    return GrammarExamples(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class GrammarExample extends DataClass implements Insertable<GrammarExample> {
  final String id;
  final String grammarLessonId;
  final String sentence;
  final String? translation;
  final String? highlight;
  final int sortOrder;
  const GrammarExample({
    required this.id,
    required this.grammarLessonId,
    required this.sentence,
    this.translation,
    this.highlight,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['grammar_lesson_id'] = Variable<String>(grammarLessonId);
    map['sentence'] = Variable<String>(sentence);
    if (!nullToAbsent || translation != null) {
      map['translation'] = Variable<String>(translation);
    }
    if (!nullToAbsent || highlight != null) {
      map['highlight'] = Variable<String>(highlight);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GrammarExamplesCompanion toCompanion(bool nullToAbsent) {
    return GrammarExamplesCompanion(
      id: Value(id),
      grammarLessonId: Value(grammarLessonId),
      sentence: Value(sentence),
      translation: translation == null && nullToAbsent
          ? const Value.absent()
          : Value(translation),
      highlight: highlight == null && nullToAbsent
          ? const Value.absent()
          : Value(highlight),
      sortOrder: Value(sortOrder),
    );
  }

  factory GrammarExample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GrammarExample(
      id: serializer.fromJson<String>(json['id']),
      grammarLessonId: serializer.fromJson<String>(json['grammar_lesson_id']),
      sentence: serializer.fromJson<String>(json['sentence']),
      translation: serializer.fromJson<String?>(json['translation']),
      highlight: serializer.fromJson<String?>(json['highlight']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'grammar_lesson_id': serializer.toJson<String>(grammarLessonId),
      'sentence': serializer.toJson<String>(sentence),
      'translation': serializer.toJson<String?>(translation),
      'highlight': serializer.toJson<String?>(highlight),
      'sort_order': serializer.toJson<int>(sortOrder),
    };
  }

  GrammarExample copyWith({
    String? id,
    String? grammarLessonId,
    String? sentence,
    Value<String?> translation = const Value.absent(),
    Value<String?> highlight = const Value.absent(),
    int? sortOrder,
  }) => GrammarExample(
    id: id ?? this.id,
    grammarLessonId: grammarLessonId ?? this.grammarLessonId,
    sentence: sentence ?? this.sentence,
    translation: translation.present ? translation.value : this.translation,
    highlight: highlight.present ? highlight.value : this.highlight,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  GrammarExample copyWithCompanion(GrammarExamplesCompanion data) {
    return GrammarExample(
      id: data.id.present ? data.id.value : this.id,
      grammarLessonId: data.grammarLessonId.present
          ? data.grammarLessonId.value
          : this.grammarLessonId,
      sentence: data.sentence.present ? data.sentence.value : this.sentence,
      translation: data.translation.present
          ? data.translation.value
          : this.translation,
      highlight: data.highlight.present ? data.highlight.value : this.highlight,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GrammarExample(')
          ..write('id: $id, ')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('sentence: $sentence, ')
          ..write('translation: $translation, ')
          ..write('highlight: $highlight, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    grammarLessonId,
    sentence,
    translation,
    highlight,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GrammarExample &&
          other.id == this.id &&
          other.grammarLessonId == this.grammarLessonId &&
          other.sentence == this.sentence &&
          other.translation == this.translation &&
          other.highlight == this.highlight &&
          other.sortOrder == this.sortOrder);
}

class GrammarExamplesCompanion extends UpdateCompanion<GrammarExample> {
  final Value<String> id;
  final Value<String> grammarLessonId;
  final Value<String> sentence;
  final Value<String?> translation;
  final Value<String?> highlight;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const GrammarExamplesCompanion({
    this.id = const Value.absent(),
    this.grammarLessonId = const Value.absent(),
    this.sentence = const Value.absent(),
    this.translation = const Value.absent(),
    this.highlight = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GrammarExamplesCompanion.insert({
    required String id,
    required String grammarLessonId,
    required String sentence,
    this.translation = const Value.absent(),
    this.highlight = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       grammarLessonId = Value(grammarLessonId),
       sentence = Value(sentence);
  static Insertable<GrammarExample> custom({
    Expression<String>? id,
    Expression<String>? grammarLessonId,
    Expression<String>? sentence,
    Expression<String>? translation,
    Expression<String>? highlight,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (grammarLessonId != null) 'grammar_lesson_id': grammarLessonId,
      if (sentence != null) 'sentence': sentence,
      if (translation != null) 'translation': translation,
      if (highlight != null) 'highlight': highlight,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GrammarExamplesCompanion copyWith({
    Value<String>? id,
    Value<String>? grammarLessonId,
    Value<String>? sentence,
    Value<String?>? translation,
    Value<String?>? highlight,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return GrammarExamplesCompanion(
      id: id ?? this.id,
      grammarLessonId: grammarLessonId ?? this.grammarLessonId,
      sentence: sentence ?? this.sentence,
      translation: translation ?? this.translation,
      highlight: highlight ?? this.highlight,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (grammarLessonId.present) {
      map['grammar_lesson_id'] = Variable<String>(grammarLessonId.value);
    }
    if (sentence.present) {
      map['sentence'] = Variable<String>(sentence.value);
    }
    if (translation.present) {
      map['translation'] = Variable<String>(translation.value);
    }
    if (highlight.present) {
      map['highlight'] = Variable<String>(highlight.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GrammarExamplesCompanion(')
          ..write('id: $id, ')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('sentence: $sentence, ')
          ..write('translation: $translation, ')
          ..write('highlight: $highlight, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Quizzes extends Table with TableInfo<Quizzes, Quizze> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Quizzes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _quizTypeMeta = const VerificationMeta(
    'quizType',
  );
  late final GeneratedColumn<String> quizType = GeneratedColumn<String>(
    'quiz_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (quiz_type IN (\'TOPIC\', \'GRAMMAR\'))',
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES topics(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _grammarLessonIdMeta = const VerificationMeta(
    'grammarLessonId',
  );
  late final GeneratedColumn<String> grammarLessonId = GeneratedColumn<String>(
    'grammar_lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES grammar_lessons(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _timeLimitSecondsMeta = const VerificationMeta(
    'timeLimitSeconds',
  );
  late final GeneratedColumn<int> timeLimitSeconds = GeneratedColumn<int>(
    'time_limit_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _passScorePercentMeta = const VerificationMeta(
    'passScorePercent',
  );
  late final GeneratedColumn<int> passScorePercent = GeneratedColumn<int>(
    'pass_score_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 70',
    defaultValue: const CustomExpression('70'),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    quizType,
    topicId,
    grammarLessonId,
    timeLimitSeconds,
    passScorePercent,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quizzes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Quizze> instance, {
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
    if (data.containsKey('quiz_type')) {
      context.handle(
        _quizTypeMeta,
        quizType.isAcceptableOrUnknown(data['quiz_type']!, _quizTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_quizTypeMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    }
    if (data.containsKey('grammar_lesson_id')) {
      context.handle(
        _grammarLessonIdMeta,
        grammarLessonId.isAcceptableOrUnknown(
          data['grammar_lesson_id']!,
          _grammarLessonIdMeta,
        ),
      );
    }
    if (data.containsKey('time_limit_seconds')) {
      context.handle(
        _timeLimitSecondsMeta,
        timeLimitSeconds.isAcceptableOrUnknown(
          data['time_limit_seconds']!,
          _timeLimitSecondsMeta,
        ),
      );
    }
    if (data.containsKey('pass_score_percent')) {
      context.handle(
        _passScorePercentMeta,
        passScorePercent.isAcceptableOrUnknown(
          data['pass_score_percent']!,
          _passScorePercentMeta,
        ),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Quizze map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quizze(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      quizType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiz_type'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      ),
      grammarLessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_lesson_id'],
      ),
      timeLimitSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_limit_seconds'],
      ),
      passScorePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_score_percent'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      )!,
    );
  }

  @override
  Quizzes createAlias(String alias) {
    return Quizzes(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((topic_id IS NULL)<>(grammar_lesson_id IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class Quizze extends DataClass implements Insertable<Quizze> {
  final String id;
  final String title;
  final String quizType;
  final String? topicId;
  final String? grammarLessonId;
  final int? timeLimitSeconds;
  final int passScorePercent;
  final int serverUpdatedAt;
  const Quizze({
    required this.id,
    required this.title,
    required this.quizType,
    this.topicId,
    this.grammarLessonId,
    this.timeLimitSeconds,
    required this.passScorePercent,
    required this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['quiz_type'] = Variable<String>(quizType);
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    if (!nullToAbsent || grammarLessonId != null) {
      map['grammar_lesson_id'] = Variable<String>(grammarLessonId);
    }
    if (!nullToAbsent || timeLimitSeconds != null) {
      map['time_limit_seconds'] = Variable<int>(timeLimitSeconds);
    }
    map['pass_score_percent'] = Variable<int>(passScorePercent);
    map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    return map;
  }

  QuizzesCompanion toCompanion(bool nullToAbsent) {
    return QuizzesCompanion(
      id: Value(id),
      title: Value(title),
      quizType: Value(quizType),
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
      grammarLessonId: grammarLessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarLessonId),
      timeLimitSeconds: timeLimitSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(timeLimitSeconds),
      passScorePercent: Value(passScorePercent),
      serverUpdatedAt: Value(serverUpdatedAt),
    );
  }

  factory Quizze.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quizze(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      quizType: serializer.fromJson<String>(json['quiz_type']),
      topicId: serializer.fromJson<String?>(json['topic_id']),
      grammarLessonId: serializer.fromJson<String?>(json['grammar_lesson_id']),
      timeLimitSeconds: serializer.fromJson<int?>(json['time_limit_seconds']),
      passScorePercent: serializer.fromJson<int>(json['pass_score_percent']),
      serverUpdatedAt: serializer.fromJson<int>(json['server_updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'quiz_type': serializer.toJson<String>(quizType),
      'topic_id': serializer.toJson<String?>(topicId),
      'grammar_lesson_id': serializer.toJson<String?>(grammarLessonId),
      'time_limit_seconds': serializer.toJson<int?>(timeLimitSeconds),
      'pass_score_percent': serializer.toJson<int>(passScorePercent),
      'server_updated_at': serializer.toJson<int>(serverUpdatedAt),
    };
  }

  Quizze copyWith({
    String? id,
    String? title,
    String? quizType,
    Value<String?> topicId = const Value.absent(),
    Value<String?> grammarLessonId = const Value.absent(),
    Value<int?> timeLimitSeconds = const Value.absent(),
    int? passScorePercent,
    int? serverUpdatedAt,
  }) => Quizze(
    id: id ?? this.id,
    title: title ?? this.title,
    quizType: quizType ?? this.quizType,
    topicId: topicId.present ? topicId.value : this.topicId,
    grammarLessonId: grammarLessonId.present
        ? grammarLessonId.value
        : this.grammarLessonId,
    timeLimitSeconds: timeLimitSeconds.present
        ? timeLimitSeconds.value
        : this.timeLimitSeconds,
    passScorePercent: passScorePercent ?? this.passScorePercent,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
  );
  Quizze copyWithCompanion(QuizzesCompanion data) {
    return Quizze(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      quizType: data.quizType.present ? data.quizType.value : this.quizType,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      grammarLessonId: data.grammarLessonId.present
          ? data.grammarLessonId.value
          : this.grammarLessonId,
      timeLimitSeconds: data.timeLimitSeconds.present
          ? data.timeLimitSeconds.value
          : this.timeLimitSeconds,
      passScorePercent: data.passScorePercent.present
          ? data.passScorePercent.value
          : this.passScorePercent,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quizze(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('quizType: $quizType, ')
          ..write('topicId: $topicId, ')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('timeLimitSeconds: $timeLimitSeconds, ')
          ..write('passScorePercent: $passScorePercent, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    quizType,
    topicId,
    grammarLessonId,
    timeLimitSeconds,
    passScorePercent,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quizze &&
          other.id == this.id &&
          other.title == this.title &&
          other.quizType == this.quizType &&
          other.topicId == this.topicId &&
          other.grammarLessonId == this.grammarLessonId &&
          other.timeLimitSeconds == this.timeLimitSeconds &&
          other.passScorePercent == this.passScorePercent &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class QuizzesCompanion extends UpdateCompanion<Quizze> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> quizType;
  final Value<String?> topicId;
  final Value<String?> grammarLessonId;
  final Value<int?> timeLimitSeconds;
  final Value<int> passScorePercent;
  final Value<int> serverUpdatedAt;
  final Value<int> rowid;
  const QuizzesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.quizType = const Value.absent(),
    this.topicId = const Value.absent(),
    this.grammarLessonId = const Value.absent(),
    this.timeLimitSeconds = const Value.absent(),
    this.passScorePercent = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizzesCompanion.insert({
    required String id,
    required String title,
    required String quizType,
    this.topicId = const Value.absent(),
    this.grammarLessonId = const Value.absent(),
    this.timeLimitSeconds = const Value.absent(),
    this.passScorePercent = const Value.absent(),
    required int serverUpdatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       quizType = Value(quizType),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<Quizze> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? quizType,
    Expression<String>? topicId,
    Expression<String>? grammarLessonId,
    Expression<int>? timeLimitSeconds,
    Expression<int>? passScorePercent,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (quizType != null) 'quiz_type': quizType,
      if (topicId != null) 'topic_id': topicId,
      if (grammarLessonId != null) 'grammar_lesson_id': grammarLessonId,
      if (timeLimitSeconds != null) 'time_limit_seconds': timeLimitSeconds,
      if (passScorePercent != null) 'pass_score_percent': passScorePercent,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizzesCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? quizType,
    Value<String?>? topicId,
    Value<String?>? grammarLessonId,
    Value<int?>? timeLimitSeconds,
    Value<int>? passScorePercent,
    Value<int>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return QuizzesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      quizType: quizType ?? this.quizType,
      topicId: topicId ?? this.topicId,
      grammarLessonId: grammarLessonId ?? this.grammarLessonId,
      timeLimitSeconds: timeLimitSeconds ?? this.timeLimitSeconds,
      passScorePercent: passScorePercent ?? this.passScorePercent,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
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
    if (quizType.present) {
      map['quiz_type'] = Variable<String>(quizType.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (grammarLessonId.present) {
      map['grammar_lesson_id'] = Variable<String>(grammarLessonId.value);
    }
    if (timeLimitSeconds.present) {
      map['time_limit_seconds'] = Variable<int>(timeLimitSeconds.value);
    }
    if (passScorePercent.present) {
      map['pass_score_percent'] = Variable<int>(passScorePercent.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizzesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('quizType: $quizType, ')
          ..write('topicId: $topicId, ')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('timeLimitSeconds: $timeLimitSeconds, ')
          ..write('passScorePercent: $passScorePercent, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class QuizQuestions extends Table with TableInfo<QuizQuestions, QuizQuestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuizQuestions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
    'quiz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES quizzes(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _correctOptionIndexMeta =
      const VerificationMeta('correctOptionIndex');
  late final GeneratedColumn<int> correctOptionIndex = GeneratedColumn<int>(
    'correct_option_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (correct_option_index BETWEEN 0 AND 3)',
  );
  static const VerificationMeta _explanationMeta = const VerificationMeta(
    'explanation',
  );
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
    'explanation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quizId,
    flashcardId,
    questionText,
    correctOptionIndex,
    explanation,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizQuestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(
        _quizIdMeta,
        quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('correct_option_index')) {
      context.handle(
        _correctOptionIndexMeta,
        correctOptionIndex.isAcceptableOrUnknown(
          data['correct_option_index']!,
          _correctOptionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctOptionIndexMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
        _explanationMeta,
        explanation.isAcceptableOrUnknown(
          data['explanation']!,
          _explanationMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizQuestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizQuestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quizId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiz_id'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      ),
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      correctOptionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_option_index'],
      )!,
      explanation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explanation'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  QuizQuestions createAlias(String alias) {
    return QuizQuestions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class QuizQuestion extends DataClass implements Insertable<QuizQuestion> {
  final String id;
  final String quizId;
  final String? flashcardId;
  final String questionText;
  final int correctOptionIndex;
  final String? explanation;
  final int sortOrder;
  const QuizQuestion({
    required this.id,
    required this.quizId,
    this.flashcardId,
    required this.questionText,
    required this.correctOptionIndex,
    this.explanation,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    if (!nullToAbsent || flashcardId != null) {
      map['flashcard_id'] = Variable<String>(flashcardId);
    }
    map['question_text'] = Variable<String>(questionText);
    map['correct_option_index'] = Variable<int>(correctOptionIndex);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuizQuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuizQuestionsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      flashcardId: flashcardId == null && nullToAbsent
          ? const Value.absent()
          : Value(flashcardId),
      questionText: Value(questionText),
      correctOptionIndex: Value(correctOptionIndex),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuizQuestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizQuestion(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quiz_id']),
      flashcardId: serializer.fromJson<String?>(json['flashcard_id']),
      questionText: serializer.fromJson<String>(json['question_text']),
      correctOptionIndex: serializer.fromJson<int>(
        json['correct_option_index'],
      ),
      explanation: serializer.fromJson<String?>(json['explanation']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quiz_id': serializer.toJson<String>(quizId),
      'flashcard_id': serializer.toJson<String?>(flashcardId),
      'question_text': serializer.toJson<String>(questionText),
      'correct_option_index': serializer.toJson<int>(correctOptionIndex),
      'explanation': serializer.toJson<String?>(explanation),
      'sort_order': serializer.toJson<int>(sortOrder),
    };
  }

  QuizQuestion copyWith({
    String? id,
    String? quizId,
    Value<String?> flashcardId = const Value.absent(),
    String? questionText,
    int? correctOptionIndex,
    Value<String?> explanation = const Value.absent(),
    int? sortOrder,
  }) => QuizQuestion(
    id: id ?? this.id,
    quizId: quizId ?? this.quizId,
    flashcardId: flashcardId.present ? flashcardId.value : this.flashcardId,
    questionText: questionText ?? this.questionText,
    correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
    explanation: explanation.present ? explanation.value : this.explanation,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QuizQuestion copyWithCompanion(QuizQuestionsCompanion data) {
    return QuizQuestion(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      correctOptionIndex: data.correctOptionIndex.present
          ? data.correctOptionIndex.value
          : this.correctOptionIndex,
      explanation: data.explanation.present
          ? data.explanation.value
          : this.explanation,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('questionText: $questionText, ')
          ..write('correctOptionIndex: $correctOptionIndex, ')
          ..write('explanation: $explanation, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quizId,
    flashcardId,
    questionText,
    correctOptionIndex,
    explanation,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizQuestion &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.flashcardId == this.flashcardId &&
          other.questionText == this.questionText &&
          other.correctOptionIndex == this.correctOptionIndex &&
          other.explanation == this.explanation &&
          other.sortOrder == this.sortOrder);
}

class QuizQuestionsCompanion extends UpdateCompanion<QuizQuestion> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<String?> flashcardId;
  final Value<String> questionText;
  final Value<int> correctOptionIndex;
  final Value<String?> explanation;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const QuizQuestionsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.questionText = const Value.absent(),
    this.correctOptionIndex = const Value.absent(),
    this.explanation = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizQuestionsCompanion.insert({
    required String id,
    required String quizId,
    this.flashcardId = const Value.absent(),
    required String questionText,
    required int correctOptionIndex,
    this.explanation = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quizId = Value(quizId),
       questionText = Value(questionText),
       correctOptionIndex = Value(correctOptionIndex);
  static Insertable<QuizQuestion> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<String>? flashcardId,
    Expression<String>? questionText,
    Expression<int>? correctOptionIndex,
    Expression<String>? explanation,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (questionText != null) 'question_text': questionText,
      if (correctOptionIndex != null)
        'correct_option_index': correctOptionIndex,
      if (explanation != null) 'explanation': explanation,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizQuestionsCompanion copyWith({
    Value<String>? id,
    Value<String>? quizId,
    Value<String?>? flashcardId,
    Value<String>? questionText,
    Value<int>? correctOptionIndex,
    Value<String?>? explanation,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return QuizQuestionsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      flashcardId: flashcardId ?? this.flashcardId,
      questionText: questionText ?? this.questionText,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (correctOptionIndex.present) {
      map['correct_option_index'] = Variable<int>(correctOptionIndex.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('questionText: $questionText, ')
          ..write('correctOptionIndex: $correctOptionIndex, ')
          ..write('explanation: $explanation, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class QuizQuestionOptions extends Table
    with TableInfo<QuizQuestionOptions, QuizQuestionOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuizQuestionOptions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES quiz_questions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _optionIndexMeta = const VerificationMeta(
    'optionIndex',
  );
  late final GeneratedColumn<int> optionIndex = GeneratedColumn<int>(
    'option_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (option_index BETWEEN 0 AND 3)',
  );
  static const VerificationMeta _optionTextMeta = const VerificationMeta(
    'optionText',
  );
  late final GeneratedColumn<String> optionText = GeneratedColumn<String>(
    'option_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [questionId, optionIndex, optionText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_question_options';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizQuestionOption> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('option_index')) {
      context.handle(
        _optionIndexMeta,
        optionIndex.isAcceptableOrUnknown(
          data['option_index']!,
          _optionIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_optionIndexMeta);
    }
    if (data.containsKey('option_text')) {
      context.handle(
        _optionTextMeta,
        optionText.isAcceptableOrUnknown(data['option_text']!, _optionTextMeta),
      );
    } else if (isInserting) {
      context.missing(_optionTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId, optionIndex};
  @override
  QuizQuestionOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizQuestionOption(
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      optionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}option_index'],
      )!,
      optionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}option_text'],
      )!,
    );
  }

  @override
  QuizQuestionOptions createAlias(String alias) {
    return QuizQuestionOptions(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(question_id, option_index)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class QuizQuestionOption extends DataClass
    implements Insertable<QuizQuestionOption> {
  final String questionId;
  final int optionIndex;
  final String optionText;
  const QuizQuestionOption({
    required this.questionId,
    required this.optionIndex,
    required this.optionText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<String>(questionId);
    map['option_index'] = Variable<int>(optionIndex);
    map['option_text'] = Variable<String>(optionText);
    return map;
  }

  QuizQuestionOptionsCompanion toCompanion(bool nullToAbsent) {
    return QuizQuestionOptionsCompanion(
      questionId: Value(questionId),
      optionIndex: Value(optionIndex),
      optionText: Value(optionText),
    );
  }

  factory QuizQuestionOption.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizQuestionOption(
      questionId: serializer.fromJson<String>(json['question_id']),
      optionIndex: serializer.fromJson<int>(json['option_index']),
      optionText: serializer.fromJson<String>(json['option_text']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'question_id': serializer.toJson<String>(questionId),
      'option_index': serializer.toJson<int>(optionIndex),
      'option_text': serializer.toJson<String>(optionText),
    };
  }

  QuizQuestionOption copyWith({
    String? questionId,
    int? optionIndex,
    String? optionText,
  }) => QuizQuestionOption(
    questionId: questionId ?? this.questionId,
    optionIndex: optionIndex ?? this.optionIndex,
    optionText: optionText ?? this.optionText,
  );
  QuizQuestionOption copyWithCompanion(QuizQuestionOptionsCompanion data) {
    return QuizQuestionOption(
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      optionIndex: data.optionIndex.present
          ? data.optionIndex.value
          : this.optionIndex,
      optionText: data.optionText.present
          ? data.optionText.value
          : this.optionText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionOption(')
          ..write('questionId: $questionId, ')
          ..write('optionIndex: $optionIndex, ')
          ..write('optionText: $optionText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(questionId, optionIndex, optionText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizQuestionOption &&
          other.questionId == this.questionId &&
          other.optionIndex == this.optionIndex &&
          other.optionText == this.optionText);
}

class QuizQuestionOptionsCompanion extends UpdateCompanion<QuizQuestionOption> {
  final Value<String> questionId;
  final Value<int> optionIndex;
  final Value<String> optionText;
  const QuizQuestionOptionsCompanion({
    this.questionId = const Value.absent(),
    this.optionIndex = const Value.absent(),
    this.optionText = const Value.absent(),
  });
  QuizQuestionOptionsCompanion.insert({
    required String questionId,
    required int optionIndex,
    required String optionText,
  }) : questionId = Value(questionId),
       optionIndex = Value(optionIndex),
       optionText = Value(optionText);
  static Insertable<QuizQuestionOption> custom({
    Expression<String>? questionId,
    Expression<int>? optionIndex,
    Expression<String>? optionText,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (optionIndex != null) 'option_index': optionIndex,
      if (optionText != null) 'option_text': optionText,
    });
  }

  QuizQuestionOptionsCompanion copyWith({
    Value<String>? questionId,
    Value<int>? optionIndex,
    Value<String>? optionText,
  }) {
    return QuizQuestionOptionsCompanion(
      questionId: questionId ?? this.questionId,
      optionIndex: optionIndex ?? this.optionIndex,
      optionText: optionText ?? this.optionText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (optionIndex.present) {
      map['option_index'] = Variable<int>(optionIndex.value);
    }
    if (optionText.present) {
      map['option_text'] = Variable<String>(optionText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizQuestionOptionsCompanion(')
          ..write('questionId: $questionId, ')
          ..write('optionIndex: $optionIndex, ')
          ..write('optionText: $optionText')
          ..write(')'))
        .toString();
  }
}

class QuestDefinitions extends Table
    with TableInfo<QuestDefinitions, QuestDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuestDefinitions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _questTypeMeta = const VerificationMeta(
    'questType',
  );
  late final GeneratedColumn<String> questType = GeneratedColumn<String>(
    'quest_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'DAILY\'',
    defaultValue: const CustomExpression('\'DAILY\''),
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    title,
    questType,
    frequency,
    targetValue,
    xpReward,
    iconName,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quest_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('quest_type')) {
      context.handle(
        _questTypeMeta,
        questType.isAcceptableOrUnknown(data['quest_type']!, _questTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_questTypeMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    } else if (isInserting) {
      context.missing(_xpRewardMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      questType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_type'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_value'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  QuestDefinitions createAlias(String alias) {
    return QuestDefinitions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class QuestDefinition extends DataClass implements Insertable<QuestDefinition> {
  final String id;
  final String code;
  final String title;
  final String questType;
  final String frequency;
  final int targetValue;
  final int xpReward;
  final String iconName;
  final int isActive;

  /// 0: đã tắt, chỉ giữ cho user_quests cũ
  final int sortOrder;
  const QuestDefinition({
    required this.id,
    required this.code,
    required this.title,
    required this.questType,
    required this.frequency,
    required this.targetValue,
    required this.xpReward,
    required this.iconName,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    map['quest_type'] = Variable<String>(questType);
    map['frequency'] = Variable<String>(frequency);
    map['target_value'] = Variable<int>(targetValue);
    map['xp_reward'] = Variable<int>(xpReward);
    map['icon_name'] = Variable<String>(iconName);
    map['is_active'] = Variable<int>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuestDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return QuestDefinitionsCompanion(
      id: Value(id),
      code: Value(code),
      title: Value(title),
      questType: Value(questType),
      frequency: Value(frequency),
      targetValue: Value(targetValue),
      xpReward: Value(xpReward),
      iconName: Value(iconName),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuestDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestDefinition(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      questType: serializer.fromJson<String>(json['quest_type']),
      frequency: serializer.fromJson<String>(json['frequency']),
      targetValue: serializer.fromJson<int>(json['target_value']),
      xpReward: serializer.fromJson<int>(json['xp_reward']),
      iconName: serializer.fromJson<String>(json['icon_name']),
      isActive: serializer.fromJson<int>(json['is_active']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'quest_type': serializer.toJson<String>(questType),
      'frequency': serializer.toJson<String>(frequency),
      'target_value': serializer.toJson<int>(targetValue),
      'xp_reward': serializer.toJson<int>(xpReward),
      'icon_name': serializer.toJson<String>(iconName),
      'is_active': serializer.toJson<int>(isActive),
      'sort_order': serializer.toJson<int>(sortOrder),
    };
  }

  QuestDefinition copyWith({
    String? id,
    String? code,
    String? title,
    String? questType,
    String? frequency,
    int? targetValue,
    int? xpReward,
    String? iconName,
    int? isActive,
    int? sortOrder,
  }) => QuestDefinition(
    id: id ?? this.id,
    code: code ?? this.code,
    title: title ?? this.title,
    questType: questType ?? this.questType,
    frequency: frequency ?? this.frequency,
    targetValue: targetValue ?? this.targetValue,
    xpReward: xpReward ?? this.xpReward,
    iconName: iconName ?? this.iconName,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QuestDefinition copyWithCompanion(QuestDefinitionsCompanion data) {
    return QuestDefinition(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      questType: data.questType.present ? data.questType.value : this.questType,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestDefinition(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('questType: $questType, ')
          ..write('frequency: $frequency, ')
          ..write('targetValue: $targetValue, ')
          ..write('xpReward: $xpReward, ')
          ..write('iconName: $iconName, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    title,
    questType,
    frequency,
    targetValue,
    xpReward,
    iconName,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestDefinition &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.questType == this.questType &&
          other.frequency == this.frequency &&
          other.targetValue == this.targetValue &&
          other.xpReward == this.xpReward &&
          other.iconName == this.iconName &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class QuestDefinitionsCompanion extends UpdateCompanion<QuestDefinition> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> title;
  final Value<String> questType;
  final Value<String> frequency;
  final Value<int> targetValue;
  final Value<int> xpReward;
  final Value<String> iconName;
  final Value<int> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const QuestDefinitionsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.questType = const Value.absent(),
    this.frequency = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.iconName = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestDefinitionsCompanion.insert({
    required String id,
    required String code,
    required String title,
    required String questType,
    this.frequency = const Value.absent(),
    required int targetValue,
    required int xpReward,
    required String iconName,
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       title = Value(title),
       questType = Value(questType),
       targetValue = Value(targetValue),
       xpReward = Value(xpReward),
       iconName = Value(iconName);
  static Insertable<QuestDefinition> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? questType,
    Expression<String>? frequency,
    Expression<int>? targetValue,
    Expression<int>? xpReward,
    Expression<String>? iconName,
    Expression<int>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (questType != null) 'quest_type': questType,
      if (frequency != null) 'frequency': frequency,
      if (targetValue != null) 'target_value': targetValue,
      if (xpReward != null) 'xp_reward': xpReward,
      if (iconName != null) 'icon_name': iconName,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? title,
    Value<String>? questType,
    Value<String>? frequency,
    Value<int>? targetValue,
    Value<int>? xpReward,
    Value<String>? iconName,
    Value<int>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return QuestDefinitionsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      questType: questType ?? this.questType,
      frequency: frequency ?? this.frequency,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      iconName: iconName ?? this.iconName,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (questType.present) {
      map['quest_type'] = Variable<String>(questType.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('questType: $questType, ')
          ..write('frequency: $frequency, ')
          ..write('targetValue: $targetValue, ')
          ..write('xpReward: $xpReward, ')
          ..write('iconName: $iconName, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class RewardItems extends Table with TableInfo<RewardItems, RewardItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  RewardItems(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (item_type IN (\'BORDER\', \'AVATAR\'))',
  );
  static const VerificationMeta _xpCostMeta = const VerificationMeta('xpCost');
  late final GeneratedColumn<int> xpCost = GeneratedColumn<int>(
    'xp_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _borderColorsMeta = const VerificationMeta(
    'borderColors',
  );
  late final GeneratedColumn<String> borderColors = GeneratedColumn<String>(
    'border_colors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _imageUrlMeta = const VerificationMeta(
    'imageUrl',
  );
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
    'image_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _requiredRankMeta = const VerificationMeta(
    'requiredRank',
  );
  late final GeneratedColumn<int> requiredRank = GeneratedColumn<int>(
    'required_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _rankBoardMeta = const VerificationMeta(
    'rankBoard',
  );
  late final GeneratedColumn<String> rankBoard = GeneratedColumn<String>(
    'rank_board',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'XP\'',
    defaultValue: const CustomExpression('\'XP\''),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1))',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _serverUpdatedAtMeta = const VerificationMeta(
    'serverUpdatedAt',
  );
  late final GeneratedColumn<int> serverUpdatedAt = GeneratedColumn<int>(
    'server_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    itemType,
    xpCost,
    borderColors,
    imageUrl,
    requiredRank,
    rankBoard,
    isActive,
    sortOrder,
    serverUpdatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reward_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<RewardItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('xp_cost')) {
      context.handle(
        _xpCostMeta,
        xpCost.isAcceptableOrUnknown(data['xp_cost']!, _xpCostMeta),
      );
    }
    if (data.containsKey('border_colors')) {
      context.handle(
        _borderColorsMeta,
        borderColors.isAcceptableOrUnknown(
          data['border_colors']!,
          _borderColorsMeta,
        ),
      );
    }
    if (data.containsKey('image_url')) {
      context.handle(
        _imageUrlMeta,
        imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta),
      );
    }
    if (data.containsKey('required_rank')) {
      context.handle(
        _requiredRankMeta,
        requiredRank.isAcceptableOrUnknown(
          data['required_rank']!,
          _requiredRankMeta,
        ),
      );
    }
    if (data.containsKey('rank_board')) {
      context.handle(
        _rankBoardMeta,
        rankBoard.isAcceptableOrUnknown(data['rank_board']!, _rankBoardMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('server_updated_at')) {
      context.handle(
        _serverUpdatedAtMeta,
        serverUpdatedAt.isAcceptableOrUnknown(
          data['server_updated_at']!,
          _serverUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serverUpdatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RewardItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RewardItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      xpCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_cost'],
      )!,
      borderColors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}border_colors'],
      ),
      imageUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_url'],
      ),
      requiredRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}required_rank'],
      )!,
      rankBoard: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rank_board'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      serverUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}server_updated_at'],
      )!,
    );
  }

  @override
  RewardItems createAlias(String alias) {
    return RewardItems(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class RewardItem extends DataClass implements Insertable<RewardItem> {
  final String id;
  final String code;
  final String name;
  final String itemType;
  final int xpCost;
  final String? borderColors;

  /// JSON array ARGB int, VD: "[4294198070,4294940672]"
  final String? imageUrl;
  final int requiredRank;
  final String rankBoard;
  final int isActive;

  /// 0: gỡ khỏi shop, vẫn hiện trong kho đồ
  final int sortOrder;
  final int serverUpdatedAt;
  const RewardItem({
    required this.id,
    required this.code,
    required this.name,
    required this.itemType,
    required this.xpCost,
    this.borderColors,
    this.imageUrl,
    required this.requiredRank,
    required this.rankBoard,
    required this.isActive,
    required this.sortOrder,
    required this.serverUpdatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['item_type'] = Variable<String>(itemType);
    map['xp_cost'] = Variable<int>(xpCost);
    if (!nullToAbsent || borderColors != null) {
      map['border_colors'] = Variable<String>(borderColors);
    }
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['required_rank'] = Variable<int>(requiredRank);
    map['rank_board'] = Variable<String>(rankBoard);
    map['is_active'] = Variable<int>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['server_updated_at'] = Variable<int>(serverUpdatedAt);
    return map;
  }

  RewardItemsCompanion toCompanion(bool nullToAbsent) {
    return RewardItemsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      itemType: Value(itemType),
      xpCost: Value(xpCost),
      borderColors: borderColors == null && nullToAbsent
          ? const Value.absent()
          : Value(borderColors),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      requiredRank: Value(requiredRank),
      rankBoard: Value(rankBoard),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      serverUpdatedAt: Value(serverUpdatedAt),
    );
  }

  factory RewardItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RewardItem(
      id: serializer.fromJson<String>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      itemType: serializer.fromJson<String>(json['item_type']),
      xpCost: serializer.fromJson<int>(json['xp_cost']),
      borderColors: serializer.fromJson<String?>(json['border_colors']),
      imageUrl: serializer.fromJson<String?>(json['image_url']),
      requiredRank: serializer.fromJson<int>(json['required_rank']),
      rankBoard: serializer.fromJson<String>(json['rank_board']),
      isActive: serializer.fromJson<int>(json['is_active']),
      sortOrder: serializer.fromJson<int>(json['sort_order']),
      serverUpdatedAt: serializer.fromJson<int>(json['server_updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'item_type': serializer.toJson<String>(itemType),
      'xp_cost': serializer.toJson<int>(xpCost),
      'border_colors': serializer.toJson<String?>(borderColors),
      'image_url': serializer.toJson<String?>(imageUrl),
      'required_rank': serializer.toJson<int>(requiredRank),
      'rank_board': serializer.toJson<String>(rankBoard),
      'is_active': serializer.toJson<int>(isActive),
      'sort_order': serializer.toJson<int>(sortOrder),
      'server_updated_at': serializer.toJson<int>(serverUpdatedAt),
    };
  }

  RewardItem copyWith({
    String? id,
    String? code,
    String? name,
    String? itemType,
    int? xpCost,
    Value<String?> borderColors = const Value.absent(),
    Value<String?> imageUrl = const Value.absent(),
    int? requiredRank,
    String? rankBoard,
    int? isActive,
    int? sortOrder,
    int? serverUpdatedAt,
  }) => RewardItem(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    itemType: itemType ?? this.itemType,
    xpCost: xpCost ?? this.xpCost,
    borderColors: borderColors.present ? borderColors.value : this.borderColors,
    imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
    requiredRank: requiredRank ?? this.requiredRank,
    rankBoard: rankBoard ?? this.rankBoard,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
  );
  RewardItem copyWithCompanion(RewardItemsCompanion data) {
    return RewardItem(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      xpCost: data.xpCost.present ? data.xpCost.value : this.xpCost,
      borderColors: data.borderColors.present
          ? data.borderColors.value
          : this.borderColors,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      requiredRank: data.requiredRank.present
          ? data.requiredRank.value
          : this.requiredRank,
      rankBoard: data.rankBoard.present ? data.rankBoard.value : this.rankBoard,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      serverUpdatedAt: data.serverUpdatedAt.present
          ? data.serverUpdatedAt.value
          : this.serverUpdatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RewardItem(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('itemType: $itemType, ')
          ..write('xpCost: $xpCost, ')
          ..write('borderColors: $borderColors, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('requiredRank: $requiredRank, ')
          ..write('rankBoard: $rankBoard, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    itemType,
    xpCost,
    borderColors,
    imageUrl,
    requiredRank,
    rankBoard,
    isActive,
    sortOrder,
    serverUpdatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RewardItem &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.itemType == this.itemType &&
          other.xpCost == this.xpCost &&
          other.borderColors == this.borderColors &&
          other.imageUrl == this.imageUrl &&
          other.requiredRank == this.requiredRank &&
          other.rankBoard == this.rankBoard &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.serverUpdatedAt == this.serverUpdatedAt);
}

class RewardItemsCompanion extends UpdateCompanion<RewardItem> {
  final Value<String> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> itemType;
  final Value<int> xpCost;
  final Value<String?> borderColors;
  final Value<String?> imageUrl;
  final Value<int> requiredRank;
  final Value<String> rankBoard;
  final Value<int> isActive;
  final Value<int> sortOrder;
  final Value<int> serverUpdatedAt;
  final Value<int> rowid;
  const RewardItemsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.itemType = const Value.absent(),
    this.xpCost = const Value.absent(),
    this.borderColors = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.requiredRank = const Value.absent(),
    this.rankBoard = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.serverUpdatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RewardItemsCompanion.insert({
    required String id,
    required String code,
    required String name,
    required String itemType,
    this.xpCost = const Value.absent(),
    this.borderColors = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.requiredRank = const Value.absent(),
    this.rankBoard = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required int serverUpdatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       code = Value(code),
       name = Value(name),
       itemType = Value(itemType),
       serverUpdatedAt = Value(serverUpdatedAt);
  static Insertable<RewardItem> custom({
    Expression<String>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? itemType,
    Expression<int>? xpCost,
    Expression<String>? borderColors,
    Expression<String>? imageUrl,
    Expression<int>? requiredRank,
    Expression<String>? rankBoard,
    Expression<int>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? serverUpdatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (itemType != null) 'item_type': itemType,
      if (xpCost != null) 'xp_cost': xpCost,
      if (borderColors != null) 'border_colors': borderColors,
      if (imageUrl != null) 'image_url': imageUrl,
      if (requiredRank != null) 'required_rank': requiredRank,
      if (rankBoard != null) 'rank_board': rankBoard,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (serverUpdatedAt != null) 'server_updated_at': serverUpdatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RewardItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? itemType,
    Value<int>? xpCost,
    Value<String?>? borderColors,
    Value<String?>? imageUrl,
    Value<int>? requiredRank,
    Value<String>? rankBoard,
    Value<int>? isActive,
    Value<int>? sortOrder,
    Value<int>? serverUpdatedAt,
    Value<int>? rowid,
  }) {
    return RewardItemsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      itemType: itemType ?? this.itemType,
      xpCost: xpCost ?? this.xpCost,
      borderColors: borderColors ?? this.borderColors,
      imageUrl: imageUrl ?? this.imageUrl,
      requiredRank: requiredRank ?? this.requiredRank,
      rankBoard: rankBoard ?? this.rankBoard,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      serverUpdatedAt: serverUpdatedAt ?? this.serverUpdatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (xpCost.present) {
      map['xp_cost'] = Variable<int>(xpCost.value);
    }
    if (borderColors.present) {
      map['border_colors'] = Variable<String>(borderColors.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (requiredRank.present) {
      map['required_rank'] = Variable<int>(requiredRank.value);
    }
    if (rankBoard.present) {
      map['rank_board'] = Variable<String>(rankBoard.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (serverUpdatedAt.present) {
      map['server_updated_at'] = Variable<int>(serverUpdatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RewardItemsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('itemType: $itemType, ')
          ..write('xpCost: $xpCost, ')
          ..write('borderColors: $borderColors, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('requiredRank: $requiredRank, ')
          ..write('rankBoard: $rankBoard, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('serverUpdatedAt: $serverUpdatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LeaderboardCache extends Table
    with TableInfo<LeaderboardCache, LeaderboardCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LeaderboardCache(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _boardMeta = const VerificationMeta('board');
  late final GeneratedColumn<String> board = GeneratedColumn<String>(
    'board',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (board IN (\'XP\', \'STREAK\'))',
  );
  static const VerificationMeta _rankNoMeta = const VerificationMeta('rankNo');
  late final GeneratedColumn<int> rankNo = GeneratedColumn<int>(
    'rank_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  late final GeneratedColumn<int> fetchedAt = GeneratedColumn<int>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    board,
    rankNo,
    userId,
    fullName,
    avatarUrl,
    score,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leaderboard_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaderboardCacheData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('board')) {
      context.handle(
        _boardMeta,
        board.isAcceptableOrUnknown(data['board']!, _boardMeta),
      );
    } else if (isInserting) {
      context.missing(_boardMeta);
    }
    if (data.containsKey('rank_no')) {
      context.handle(
        _rankNoMeta,
        rankNo.isAcceptableOrUnknown(data['rank_no']!, _rankNoMeta),
      );
    } else if (isInserting) {
      context.missing(_rankNoMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {board, userId};
  @override
  LeaderboardCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaderboardCacheData(
      board: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}board'],
      )!,
      rankNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rank_no'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  LeaderboardCache createAlias(String alias) {
    return LeaderboardCache(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const ['PRIMARY KEY(board, user_id)'];
  @override
  bool get dontWriteConstraints => true;
}

class LeaderboardCacheData extends DataClass
    implements Insertable<LeaderboardCacheData> {
  final String board;
  final int rankNo;
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final int score;
  final int fetchedAt;
  const LeaderboardCacheData({
    required this.board,
    required this.rankNo,
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.score,
    required this.fetchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['board'] = Variable<String>(board);
    map['rank_no'] = Variable<int>(rankNo);
    map['user_id'] = Variable<String>(userId);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['score'] = Variable<int>(score);
    map['fetched_at'] = Variable<int>(fetchedAt);
    return map;
  }

  LeaderboardCacheCompanion toCompanion(bool nullToAbsent) {
    return LeaderboardCacheCompanion(
      board: Value(board),
      rankNo: Value(rankNo),
      userId: Value(userId),
      fullName: Value(fullName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      score: Value(score),
      fetchedAt: Value(fetchedAt),
    );
  }

  factory LeaderboardCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaderboardCacheData(
      board: serializer.fromJson<String>(json['board']),
      rankNo: serializer.fromJson<int>(json['rank_no']),
      userId: serializer.fromJson<String>(json['user_id']),
      fullName: serializer.fromJson<String>(json['full_name']),
      avatarUrl: serializer.fromJson<String?>(json['avatar_url']),
      score: serializer.fromJson<int>(json['score']),
      fetchedAt: serializer.fromJson<int>(json['fetched_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'board': serializer.toJson<String>(board),
      'rank_no': serializer.toJson<int>(rankNo),
      'user_id': serializer.toJson<String>(userId),
      'full_name': serializer.toJson<String>(fullName),
      'avatar_url': serializer.toJson<String?>(avatarUrl),
      'score': serializer.toJson<int>(score),
      'fetched_at': serializer.toJson<int>(fetchedAt),
    };
  }

  LeaderboardCacheData copyWith({
    String? board,
    int? rankNo,
    String? userId,
    String? fullName,
    Value<String?> avatarUrl = const Value.absent(),
    int? score,
    int? fetchedAt,
  }) => LeaderboardCacheData(
    board: board ?? this.board,
    rankNo: rankNo ?? this.rankNo,
    userId: userId ?? this.userId,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    score: score ?? this.score,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  LeaderboardCacheData copyWithCompanion(LeaderboardCacheCompanion data) {
    return LeaderboardCacheData(
      board: data.board.present ? data.board.value : this.board,
      rankNo: data.rankNo.present ? data.rankNo.value : this.rankNo,
      userId: data.userId.present ? data.userId.value : this.userId,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      score: data.score.present ? data.score.value : this.score,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheData(')
          ..write('board: $board, ')
          ..write('rankNo: $rankNo, ')
          ..write('userId: $userId, ')
          ..write('fullName: $fullName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('score: $score, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(board, rankNo, userId, fullName, avatarUrl, score, fetchedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaderboardCacheData &&
          other.board == this.board &&
          other.rankNo == this.rankNo &&
          other.userId == this.userId &&
          other.fullName == this.fullName &&
          other.avatarUrl == this.avatarUrl &&
          other.score == this.score &&
          other.fetchedAt == this.fetchedAt);
}

class LeaderboardCacheCompanion extends UpdateCompanion<LeaderboardCacheData> {
  final Value<String> board;
  final Value<int> rankNo;
  final Value<String> userId;
  final Value<String> fullName;
  final Value<String?> avatarUrl;
  final Value<int> score;
  final Value<int> fetchedAt;
  const LeaderboardCacheCompanion({
    this.board = const Value.absent(),
    this.rankNo = const Value.absent(),
    this.userId = const Value.absent(),
    this.fullName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.score = const Value.absent(),
    this.fetchedAt = const Value.absent(),
  });
  LeaderboardCacheCompanion.insert({
    required String board,
    required int rankNo,
    required String userId,
    required String fullName,
    this.avatarUrl = const Value.absent(),
    required int score,
    required int fetchedAt,
  }) : board = Value(board),
       rankNo = Value(rankNo),
       userId = Value(userId),
       fullName = Value(fullName),
       score = Value(score),
       fetchedAt = Value(fetchedAt);
  static Insertable<LeaderboardCacheData> custom({
    Expression<String>? board,
    Expression<int>? rankNo,
    Expression<String>? userId,
    Expression<String>? fullName,
    Expression<String>? avatarUrl,
    Expression<int>? score,
    Expression<int>? fetchedAt,
  }) {
    return RawValuesInsertable({
      if (board != null) 'board': board,
      if (rankNo != null) 'rank_no': rankNo,
      if (userId != null) 'user_id': userId,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (score != null) 'score': score,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
    });
  }

  LeaderboardCacheCompanion copyWith({
    Value<String>? board,
    Value<int>? rankNo,
    Value<String>? userId,
    Value<String>? fullName,
    Value<String?>? avatarUrl,
    Value<int>? score,
    Value<int>? fetchedAt,
  }) {
    return LeaderboardCacheCompanion(
      board: board ?? this.board,
      rankNo: rankNo ?? this.rankNo,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      score: score ?? this.score,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (board.present) {
      map['board'] = Variable<String>(board.value);
    }
    if (rankNo.present) {
      map['rank_no'] = Variable<int>(rankNo.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<int>(fetchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaderboardCacheCompanion(')
          ..write('board: $board, ')
          ..write('rankNo: $rankNo, ')
          ..write('userId: $userId, ')
          ..write('fullName: $fullName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('score: $score, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }
}

class UserProfile extends Table with TableInfo<UserProfile, UserProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserProfile(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _avatarUrlMeta = const VerificationMeta(
    'avatarUrl',
  );
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
    'avatar_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'A1\'',
    defaultValue: const CustomExpression('\'A1\''),
  );
  static const VerificationMeta _sloganMeta = const VerificationMeta('slogan');
  late final GeneratedColumn<String> slogan = GeneratedColumn<String>(
    'slogan',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'Học, học nữa, học mãi!\'',
    defaultValue: const CustomExpression('\'Học, học nữa, học mãi!\''),
  );
  static const VerificationMeta _currentXpMeta = const VerificationMeta(
    'currentXp',
  );
  late final GeneratedColumn<int> currentXp = GeneratedColumn<int>(
    'current_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _pendingXpMeta = const VerificationMeta(
    'pendingXp',
  );
  late final GeneratedColumn<int> pendingXp = GeneratedColumn<int>(
    'pending_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _targetXpMeta = const VerificationMeta(
    'targetXp',
  );
  late final GeneratedColumn<int> targetXp = GeneratedColumn<int>(
    'target_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 100',
    defaultValue: const CustomExpression('100'),
  );
  static const VerificationMeta _totalLifetimeXpMeta = const VerificationMeta(
    'totalLifetimeXp',
  );
  late final GeneratedColumn<int> totalLifetimeXp = GeneratedColumn<int>(
    'total_lifetime_xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _streakDaysMeta = const VerificationMeta(
    'streakDays',
  );
  late final GeneratedColumn<int> streakDays = GeneratedColumn<int>(
    'streak_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _longestStreakMeta = const VerificationMeta(
    'longestStreak',
  );
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
    'longest_streak',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  late final GeneratedColumn<String> lastActiveDate = GeneratedColumn<String>(
    'last_active_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _totalWordsLearnedMeta = const VerificationMeta(
    'totalWordsLearned',
  );
  late final GeneratedColumn<int> totalWordsLearned = GeneratedColumn<int>(
    'total_words_learned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _completedLessonsMeta = const VerificationMeta(
    'completedLessons',
  );
  late final GeneratedColumn<int> completedLessons = GeneratedColumn<int>(
    'completed_lessons',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  late final GeneratedColumn<int> clientUpdatedAt = GeneratedColumn<int>(
    'client_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    fullName,
    avatarUrl,
    level,
    slogan,
    currentXp,
    pendingXp,
    targetXp,
    totalLifetimeXp,
    streakDays,
    longestStreak,
    lastActiveDate,
    totalWordsLearned,
    completedLessons,
    version,
    clientUpdatedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserProfileData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('avatar_url')) {
      context.handle(
        _avatarUrlMeta,
        avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('slogan')) {
      context.handle(
        _sloganMeta,
        slogan.isAcceptableOrUnknown(data['slogan']!, _sloganMeta),
      );
    }
    if (data.containsKey('current_xp')) {
      context.handle(
        _currentXpMeta,
        currentXp.isAcceptableOrUnknown(data['current_xp']!, _currentXpMeta),
      );
    }
    if (data.containsKey('pending_xp')) {
      context.handle(
        _pendingXpMeta,
        pendingXp.isAcceptableOrUnknown(data['pending_xp']!, _pendingXpMeta),
      );
    }
    if (data.containsKey('target_xp')) {
      context.handle(
        _targetXpMeta,
        targetXp.isAcceptableOrUnknown(data['target_xp']!, _targetXpMeta),
      );
    }
    if (data.containsKey('total_lifetime_xp')) {
      context.handle(
        _totalLifetimeXpMeta,
        totalLifetimeXp.isAcceptableOrUnknown(
          data['total_lifetime_xp']!,
          _totalLifetimeXpMeta,
        ),
      );
    }
    if (data.containsKey('streak_days')) {
      context.handle(
        _streakDaysMeta,
        streakDays.isAcceptableOrUnknown(data['streak_days']!, _streakDaysMeta),
      );
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
        _longestStreakMeta,
        longestStreak.isAcceptableOrUnknown(
          data['longest_streak']!,
          _longestStreakMeta,
        ),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    }
    if (data.containsKey('total_words_learned')) {
      context.handle(
        _totalWordsLearnedMeta,
        totalWordsLearned.isAcceptableOrUnknown(
          data['total_words_learned']!,
          _totalWordsLearnedMeta,
        ),
      );
    }
    if (data.containsKey('completed_lessons')) {
      context.handle(
        _completedLessonsMeta,
        completedLessons.isAcceptableOrUnknown(
          data['completed_lessons']!,
          _completedLessonsMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      avatarUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_url'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      slogan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slogan'],
      )!,
      currentXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_xp'],
      )!,
      pendingXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_xp'],
      )!,
      targetXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_xp'],
      )!,
      totalLifetimeXp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_lifetime_xp'],
      )!,
      streakDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}streak_days'],
      )!,
      longestStreak: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_streak'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_active_date'],
      ),
      totalWordsLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_words_learned'],
      )!,
      completedLessons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_lessons'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_updated_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserProfile createAlias(String alias) {
    return UserProfile(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserProfileData extends DataClass implements Insertable<UserProfileData> {
  final String id;
  final String email;
  final String fullName;
  final String? avatarUrl;
  final String level;
  final String slogan;
  final int currentXp;
  final int pendingXp;

  /// XP dự kiến từ thao tác chưa sync (chỉ để hiển thị)
  final int targetXp;
  final int totalLifetimeXp;
  final int streakDays;
  final int longestStreak;
  final String? lastActiveDate;

  /// 'YYYY-MM-DD'
  final int totalWordsLearned;
  final int completedLessons;

  /// sync
  final int version;
  final int? clientUpdatedAt;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserProfileData({
    required this.id,
    required this.email,
    required this.fullName,
    this.avatarUrl,
    required this.level,
    required this.slogan,
    required this.currentXp,
    required this.pendingXp,
    required this.targetXp,
    required this.totalLifetimeXp,
    required this.streakDays,
    required this.longestStreak,
    this.lastActiveDate,
    required this.totalWordsLearned,
    required this.completedLessons,
    required this.version,
    this.clientUpdatedAt,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    map['level'] = Variable<String>(level);
    map['slogan'] = Variable<String>(slogan);
    map['current_xp'] = Variable<int>(currentXp);
    map['pending_xp'] = Variable<int>(pendingXp);
    map['target_xp'] = Variable<int>(targetXp);
    map['total_lifetime_xp'] = Variable<int>(totalLifetimeXp);
    map['streak_days'] = Variable<int>(streakDays);
    map['longest_streak'] = Variable<int>(longestStreak);
    if (!nullToAbsent || lastActiveDate != null) {
      map['last_active_date'] = Variable<String>(lastActiveDate);
    }
    map['total_words_learned'] = Variable<int>(totalWordsLearned);
    map['completed_lessons'] = Variable<int>(completedLessons);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || clientUpdatedAt != null) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt);
    }
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserProfileCompanion toCompanion(bool nullToAbsent) {
    return UserProfileCompanion(
      id: Value(id),
      email: Value(email),
      fullName: Value(fullName),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      level: Value(level),
      slogan: Value(slogan),
      currentXp: Value(currentXp),
      pendingXp: Value(pendingXp),
      targetXp: Value(targetXp),
      totalLifetimeXp: Value(totalLifetimeXp),
      streakDays: Value(streakDays),
      longestStreak: Value(longestStreak),
      lastActiveDate: lastActiveDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActiveDate),
      totalWordsLearned: Value(totalWordsLearned),
      completedLessons: Value(completedLessons),
      version: Value(version),
      clientUpdatedAt: clientUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clientUpdatedAt),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserProfileData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileData(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      fullName: serializer.fromJson<String>(json['full_name']),
      avatarUrl: serializer.fromJson<String?>(json['avatar_url']),
      level: serializer.fromJson<String>(json['level']),
      slogan: serializer.fromJson<String>(json['slogan']),
      currentXp: serializer.fromJson<int>(json['current_xp']),
      pendingXp: serializer.fromJson<int>(json['pending_xp']),
      targetXp: serializer.fromJson<int>(json['target_xp']),
      totalLifetimeXp: serializer.fromJson<int>(json['total_lifetime_xp']),
      streakDays: serializer.fromJson<int>(json['streak_days']),
      longestStreak: serializer.fromJson<int>(json['longest_streak']),
      lastActiveDate: serializer.fromJson<String?>(json['last_active_date']),
      totalWordsLearned: serializer.fromJson<int>(json['total_words_learned']),
      completedLessons: serializer.fromJson<int>(json['completed_lessons']),
      version: serializer.fromJson<int>(json['version']),
      clientUpdatedAt: serializer.fromJson<int?>(json['client_updated_at']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'full_name': serializer.toJson<String>(fullName),
      'avatar_url': serializer.toJson<String?>(avatarUrl),
      'level': serializer.toJson<String>(level),
      'slogan': serializer.toJson<String>(slogan),
      'current_xp': serializer.toJson<int>(currentXp),
      'pending_xp': serializer.toJson<int>(pendingXp),
      'target_xp': serializer.toJson<int>(targetXp),
      'total_lifetime_xp': serializer.toJson<int>(totalLifetimeXp),
      'streak_days': serializer.toJson<int>(streakDays),
      'longest_streak': serializer.toJson<int>(longestStreak),
      'last_active_date': serializer.toJson<String?>(lastActiveDate),
      'total_words_learned': serializer.toJson<int>(totalWordsLearned),
      'completed_lessons': serializer.toJson<int>(completedLessons),
      'version': serializer.toJson<int>(version),
      'client_updated_at': serializer.toJson<int?>(clientUpdatedAt),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserProfileData copyWith({
    String? id,
    String? email,
    String? fullName,
    Value<String?> avatarUrl = const Value.absent(),
    String? level,
    String? slogan,
    int? currentXp,
    int? pendingXp,
    int? targetXp,
    int? totalLifetimeXp,
    int? streakDays,
    int? longestStreak,
    Value<String?> lastActiveDate = const Value.absent(),
    int? totalWordsLearned,
    int? completedLessons,
    int? version,
    Value<int?> clientUpdatedAt = const Value.absent(),
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserProfileData(
    id: id ?? this.id,
    email: email ?? this.email,
    fullName: fullName ?? this.fullName,
    avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
    level: level ?? this.level,
    slogan: slogan ?? this.slogan,
    currentXp: currentXp ?? this.currentXp,
    pendingXp: pendingXp ?? this.pendingXp,
    targetXp: targetXp ?? this.targetXp,
    totalLifetimeXp: totalLifetimeXp ?? this.totalLifetimeXp,
    streakDays: streakDays ?? this.streakDays,
    longestStreak: longestStreak ?? this.longestStreak,
    lastActiveDate: lastActiveDate.present
        ? lastActiveDate.value
        : this.lastActiveDate,
    totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
    completedLessons: completedLessons ?? this.completedLessons,
    version: version ?? this.version,
    clientUpdatedAt: clientUpdatedAt.present
        ? clientUpdatedAt.value
        : this.clientUpdatedAt,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserProfileData copyWithCompanion(UserProfileCompanion data) {
    return UserProfileData(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      level: data.level.present ? data.level.value : this.level,
      slogan: data.slogan.present ? data.slogan.value : this.slogan,
      currentXp: data.currentXp.present ? data.currentXp.value : this.currentXp,
      pendingXp: data.pendingXp.present ? data.pendingXp.value : this.pendingXp,
      targetXp: data.targetXp.present ? data.targetXp.value : this.targetXp,
      totalLifetimeXp: data.totalLifetimeXp.present
          ? data.totalLifetimeXp.value
          : this.totalLifetimeXp,
      streakDays: data.streakDays.present
          ? data.streakDays.value
          : this.streakDays,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
      totalWordsLearned: data.totalWordsLearned.present
          ? data.totalWordsLearned.value
          : this.totalWordsLearned,
      completedLessons: data.completedLessons.present
          ? data.completedLessons.value
          : this.completedLessons,
      version: data.version.present ? data.version.value : this.version,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileData(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('fullName: $fullName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('level: $level, ')
          ..write('slogan: $slogan, ')
          ..write('currentXp: $currentXp, ')
          ..write('pendingXp: $pendingXp, ')
          ..write('targetXp: $targetXp, ')
          ..write('totalLifetimeXp: $totalLifetimeXp, ')
          ..write('streakDays: $streakDays, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('totalWordsLearned: $totalWordsLearned, ')
          ..write('completedLessons: $completedLessons, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    fullName,
    avatarUrl,
    level,
    slogan,
    currentXp,
    pendingXp,
    targetXp,
    totalLifetimeXp,
    streakDays,
    longestStreak,
    lastActiveDate,
    totalWordsLearned,
    completedLessons,
    version,
    clientUpdatedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileData &&
          other.id == this.id &&
          other.email == this.email &&
          other.fullName == this.fullName &&
          other.avatarUrl == this.avatarUrl &&
          other.level == this.level &&
          other.slogan == this.slogan &&
          other.currentXp == this.currentXp &&
          other.pendingXp == this.pendingXp &&
          other.targetXp == this.targetXp &&
          other.totalLifetimeXp == this.totalLifetimeXp &&
          other.streakDays == this.streakDays &&
          other.longestStreak == this.longestStreak &&
          other.lastActiveDate == this.lastActiveDate &&
          other.totalWordsLearned == this.totalWordsLearned &&
          other.completedLessons == this.completedLessons &&
          other.version == this.version &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserProfileCompanion extends UpdateCompanion<UserProfileData> {
  final Value<String> id;
  final Value<String> email;
  final Value<String> fullName;
  final Value<String?> avatarUrl;
  final Value<String> level;
  final Value<String> slogan;
  final Value<int> currentXp;
  final Value<int> pendingXp;
  final Value<int> targetXp;
  final Value<int> totalLifetimeXp;
  final Value<int> streakDays;
  final Value<int> longestStreak;
  final Value<String?> lastActiveDate;
  final Value<int> totalWordsLearned;
  final Value<int> completedLessons;
  final Value<int> version;
  final Value<int?> clientUpdatedAt;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserProfileCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.fullName = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.level = const Value.absent(),
    this.slogan = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.pendingXp = const Value.absent(),
    this.targetXp = const Value.absent(),
    this.totalLifetimeXp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.totalWordsLearned = const Value.absent(),
    this.completedLessons = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfileCompanion.insert({
    required String id,
    required String email,
    required String fullName,
    this.avatarUrl = const Value.absent(),
    this.level = const Value.absent(),
    this.slogan = const Value.absent(),
    this.currentXp = const Value.absent(),
    this.pendingXp = const Value.absent(),
    this.targetXp = const Value.absent(),
    this.totalLifetimeXp = const Value.absent(),
    this.streakDays = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.totalWordsLearned = const Value.absent(),
    this.completedLessons = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       fullName = Value(fullName);
  static Insertable<UserProfileData> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? fullName,
    Expression<String>? avatarUrl,
    Expression<String>? level,
    Expression<String>? slogan,
    Expression<int>? currentXp,
    Expression<int>? pendingXp,
    Expression<int>? targetXp,
    Expression<int>? totalLifetimeXp,
    Expression<int>? streakDays,
    Expression<int>? longestStreak,
    Expression<String>? lastActiveDate,
    Expression<int>? totalWordsLearned,
    Expression<int>? completedLessons,
    Expression<int>? version,
    Expression<int>? clientUpdatedAt,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (fullName != null) 'full_name': fullName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (level != null) 'level': level,
      if (slogan != null) 'slogan': slogan,
      if (currentXp != null) 'current_xp': currentXp,
      if (pendingXp != null) 'pending_xp': pendingXp,
      if (targetXp != null) 'target_xp': targetXp,
      if (totalLifetimeXp != null) 'total_lifetime_xp': totalLifetimeXp,
      if (streakDays != null) 'streak_days': streakDays,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
      if (totalWordsLearned != null) 'total_words_learned': totalWordsLearned,
      if (completedLessons != null) 'completed_lessons': completedLessons,
      if (version != null) 'version': version,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfileCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String>? fullName,
    Value<String?>? avatarUrl,
    Value<String>? level,
    Value<String>? slogan,
    Value<int>? currentXp,
    Value<int>? pendingXp,
    Value<int>? targetXp,
    Value<int>? totalLifetimeXp,
    Value<int>? streakDays,
    Value<int>? longestStreak,
    Value<String?>? lastActiveDate,
    Value<int>? totalWordsLearned,
    Value<int>? completedLessons,
    Value<int>? version,
    Value<int?>? clientUpdatedAt,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserProfileCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      level: level ?? this.level,
      slogan: slogan ?? this.slogan,
      currentXp: currentXp ?? this.currentXp,
      pendingXp: pendingXp ?? this.pendingXp,
      targetXp: targetXp ?? this.targetXp,
      totalLifetimeXp: totalLifetimeXp ?? this.totalLifetimeXp,
      streakDays: streakDays ?? this.streakDays,
      longestStreak: longestStreak ?? this.longestStreak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      completedLessons: completedLessons ?? this.completedLessons,
      version: version ?? this.version,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (slogan.present) {
      map['slogan'] = Variable<String>(slogan.value);
    }
    if (currentXp.present) {
      map['current_xp'] = Variable<int>(currentXp.value);
    }
    if (pendingXp.present) {
      map['pending_xp'] = Variable<int>(pendingXp.value);
    }
    if (targetXp.present) {
      map['target_xp'] = Variable<int>(targetXp.value);
    }
    if (totalLifetimeXp.present) {
      map['total_lifetime_xp'] = Variable<int>(totalLifetimeXp.value);
    }
    if (streakDays.present) {
      map['streak_days'] = Variable<int>(streakDays.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<String>(lastActiveDate.value);
    }
    if (totalWordsLearned.present) {
      map['total_words_learned'] = Variable<int>(totalWordsLearned.value);
    }
    if (completedLessons.present) {
      map['completed_lessons'] = Variable<int>(completedLessons.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('fullName: $fullName, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('level: $level, ')
          ..write('slogan: $slogan, ')
          ..write('currentXp: $currentXp, ')
          ..write('pendingXp: $pendingXp, ')
          ..write('targetXp: $targetXp, ')
          ..write('totalLifetimeXp: $totalLifetimeXp, ')
          ..write('streakDays: $streakDays, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('totalWordsLearned: $totalWordsLearned, ')
          ..write('completedLessons: $completedLessons, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserFlashcardProgress extends Table
    with TableInfo<UserFlashcardProgress, UserFlashcardProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserFlashcardProgress(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES flashcards(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _boxMeta = const VerificationMeta('box');
  late final GeneratedColumn<int> box = GeneratedColumn<int>(
    'box',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (box BETWEEN 0 AND 5)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _repetitionsMeta = const VerificationMeta(
    'repetitions',
  );
  late final GeneratedColumn<int> repetitions = GeneratedColumn<int>(
    'repetitions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _againCountMeta = const VerificationMeta(
    'againCount',
  );
  late final GeneratedColumn<int> againCount = GeneratedColumn<int>(
    'again_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _knowCountMeta = const VerificationMeta(
    'knowCount',
  );
  late final GeneratedColumn<int> knowCount = GeneratedColumn<int>(
    'know_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastRatingMeta = const VerificationMeta(
    'lastRating',
  );
  late final GeneratedColumn<String> lastRating = GeneratedColumn<String>(
    'last_rating',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (last_rating IN (\'AGAIN\', \'KNOW\'))',
  );
  static const VerificationMeta _isLearnedMeta = const VerificationMeta(
    'isLearned',
  );
  late final GeneratedColumn<int> isLearned = GeneratedColumn<int>(
    'is_learned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_learned IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastReviewedAtMeta = const VerificationMeta(
    'lastReviewedAt',
  );
  late final GeneratedColumn<int> lastReviewedAt = GeneratedColumn<int>(
    'last_reviewed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  late final GeneratedColumn<int> clientUpdatedAt = GeneratedColumn<int>(
    'client_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    flashcardId,
    box,
    repetitions,
    againCount,
    knowCount,
    lastRating,
    isLearned,
    lastReviewedAt,
    dueAt,
    version,
    clientUpdatedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_flashcard_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFlashcardProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('box')) {
      context.handle(
        _boxMeta,
        box.isAcceptableOrUnknown(data['box']!, _boxMeta),
      );
    }
    if (data.containsKey('repetitions')) {
      context.handle(
        _repetitionsMeta,
        repetitions.isAcceptableOrUnknown(
          data['repetitions']!,
          _repetitionsMeta,
        ),
      );
    }
    if (data.containsKey('again_count')) {
      context.handle(
        _againCountMeta,
        againCount.isAcceptableOrUnknown(data['again_count']!, _againCountMeta),
      );
    }
    if (data.containsKey('know_count')) {
      context.handle(
        _knowCountMeta,
        knowCount.isAcceptableOrUnknown(data['know_count']!, _knowCountMeta),
      );
    }
    if (data.containsKey('last_rating')) {
      context.handle(
        _lastRatingMeta,
        lastRating.isAcceptableOrUnknown(data['last_rating']!, _lastRatingMeta),
      );
    }
    if (data.containsKey('is_learned')) {
      context.handle(
        _isLearnedMeta,
        isLearned.isAcceptableOrUnknown(data['is_learned']!, _isLearnedMeta),
      );
    }
    if (data.containsKey('last_reviewed_at')) {
      context.handle(
        _lastReviewedAtMeta,
        lastReviewedAt.isAcceptableOrUnknown(
          data['last_reviewed_at']!,
          _lastReviewedAtMeta,
        ),
      );
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flashcardId};
  @override
  UserFlashcardProgressData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFlashcardProgressData(
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      box: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box'],
      )!,
      repetitions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repetitions'],
      )!,
      againCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}again_count'],
      )!,
      knowCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}know_count'],
      )!,
      lastRating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_rating'],
      ),
      isLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_learned'],
      )!,
      lastReviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_reviewed_at'],
      ),
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}due_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_updated_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserFlashcardProgress createAlias(String alias) {
    return UserFlashcardProgress(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserFlashcardProgressData extends DataClass
    implements Insertable<UserFlashcardProgressData> {
  final String flashcardId;
  final int box;
  final int repetitions;
  final int againCount;
  final int knowCount;
  final String? lastRating;
  final int isLearned;
  final int? lastReviewedAt;
  final int? dueAt;

  /// sync
  final int version;
  final int? clientUpdatedAt;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserFlashcardProgressData({
    required this.flashcardId,
    required this.box,
    required this.repetitions,
    required this.againCount,
    required this.knowCount,
    this.lastRating,
    required this.isLearned,
    this.lastReviewedAt,
    this.dueAt,
    required this.version,
    this.clientUpdatedAt,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['box'] = Variable<int>(box);
    map['repetitions'] = Variable<int>(repetitions);
    map['again_count'] = Variable<int>(againCount);
    map['know_count'] = Variable<int>(knowCount);
    if (!nullToAbsent || lastRating != null) {
      map['last_rating'] = Variable<String>(lastRating);
    }
    map['is_learned'] = Variable<int>(isLearned);
    if (!nullToAbsent || lastReviewedAt != null) {
      map['last_reviewed_at'] = Variable<int>(lastReviewedAt);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || clientUpdatedAt != null) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt);
    }
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserFlashcardProgressCompanion toCompanion(bool nullToAbsent) {
    return UserFlashcardProgressCompanion(
      flashcardId: Value(flashcardId),
      box: Value(box),
      repetitions: Value(repetitions),
      againCount: Value(againCount),
      knowCount: Value(knowCount),
      lastRating: lastRating == null && nullToAbsent
          ? const Value.absent()
          : Value(lastRating),
      isLearned: Value(isLearned),
      lastReviewedAt: lastReviewedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewedAt),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      version: Value(version),
      clientUpdatedAt: clientUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clientUpdatedAt),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserFlashcardProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFlashcardProgressData(
      flashcardId: serializer.fromJson<String>(json['flashcard_id']),
      box: serializer.fromJson<int>(json['box']),
      repetitions: serializer.fromJson<int>(json['repetitions']),
      againCount: serializer.fromJson<int>(json['again_count']),
      knowCount: serializer.fromJson<int>(json['know_count']),
      lastRating: serializer.fromJson<String?>(json['last_rating']),
      isLearned: serializer.fromJson<int>(json['is_learned']),
      lastReviewedAt: serializer.fromJson<int?>(json['last_reviewed_at']),
      dueAt: serializer.fromJson<int?>(json['due_at']),
      version: serializer.fromJson<int>(json['version']),
      clientUpdatedAt: serializer.fromJson<int?>(json['client_updated_at']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flashcard_id': serializer.toJson<String>(flashcardId),
      'box': serializer.toJson<int>(box),
      'repetitions': serializer.toJson<int>(repetitions),
      'again_count': serializer.toJson<int>(againCount),
      'know_count': serializer.toJson<int>(knowCount),
      'last_rating': serializer.toJson<String?>(lastRating),
      'is_learned': serializer.toJson<int>(isLearned),
      'last_reviewed_at': serializer.toJson<int?>(lastReviewedAt),
      'due_at': serializer.toJson<int?>(dueAt),
      'version': serializer.toJson<int>(version),
      'client_updated_at': serializer.toJson<int?>(clientUpdatedAt),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserFlashcardProgressData copyWith({
    String? flashcardId,
    int? box,
    int? repetitions,
    int? againCount,
    int? knowCount,
    Value<String?> lastRating = const Value.absent(),
    int? isLearned,
    Value<int?> lastReviewedAt = const Value.absent(),
    Value<int?> dueAt = const Value.absent(),
    int? version,
    Value<int?> clientUpdatedAt = const Value.absent(),
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserFlashcardProgressData(
    flashcardId: flashcardId ?? this.flashcardId,
    box: box ?? this.box,
    repetitions: repetitions ?? this.repetitions,
    againCount: againCount ?? this.againCount,
    knowCount: knowCount ?? this.knowCount,
    lastRating: lastRating.present ? lastRating.value : this.lastRating,
    isLearned: isLearned ?? this.isLearned,
    lastReviewedAt: lastReviewedAt.present
        ? lastReviewedAt.value
        : this.lastReviewedAt,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    version: version ?? this.version,
    clientUpdatedAt: clientUpdatedAt.present
        ? clientUpdatedAt.value
        : this.clientUpdatedAt,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserFlashcardProgressData copyWithCompanion(
    UserFlashcardProgressCompanion data,
  ) {
    return UserFlashcardProgressData(
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      box: data.box.present ? data.box.value : this.box,
      repetitions: data.repetitions.present
          ? data.repetitions.value
          : this.repetitions,
      againCount: data.againCount.present
          ? data.againCount.value
          : this.againCount,
      knowCount: data.knowCount.present ? data.knowCount.value : this.knowCount,
      lastRating: data.lastRating.present
          ? data.lastRating.value
          : this.lastRating,
      isLearned: data.isLearned.present ? data.isLearned.value : this.isLearned,
      lastReviewedAt: data.lastReviewedAt.present
          ? data.lastReviewedAt.value
          : this.lastReviewedAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      version: data.version.present ? data.version.value : this.version,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFlashcardProgressData(')
          ..write('flashcardId: $flashcardId, ')
          ..write('box: $box, ')
          ..write('repetitions: $repetitions, ')
          ..write('againCount: $againCount, ')
          ..write('knowCount: $knowCount, ')
          ..write('lastRating: $lastRating, ')
          ..write('isLearned: $isLearned, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    flashcardId,
    box,
    repetitions,
    againCount,
    knowCount,
    lastRating,
    isLearned,
    lastReviewedAt,
    dueAt,
    version,
    clientUpdatedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFlashcardProgressData &&
          other.flashcardId == this.flashcardId &&
          other.box == this.box &&
          other.repetitions == this.repetitions &&
          other.againCount == this.againCount &&
          other.knowCount == this.knowCount &&
          other.lastRating == this.lastRating &&
          other.isLearned == this.isLearned &&
          other.lastReviewedAt == this.lastReviewedAt &&
          other.dueAt == this.dueAt &&
          other.version == this.version &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserFlashcardProgressCompanion
    extends UpdateCompanion<UserFlashcardProgressData> {
  final Value<String> flashcardId;
  final Value<int> box;
  final Value<int> repetitions;
  final Value<int> againCount;
  final Value<int> knowCount;
  final Value<String?> lastRating;
  final Value<int> isLearned;
  final Value<int?> lastReviewedAt;
  final Value<int?> dueAt;
  final Value<int> version;
  final Value<int?> clientUpdatedAt;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserFlashcardProgressCompanion({
    this.flashcardId = const Value.absent(),
    this.box = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.againCount = const Value.absent(),
    this.knowCount = const Value.absent(),
    this.lastRating = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFlashcardProgressCompanion.insert({
    required String flashcardId,
    this.box = const Value.absent(),
    this.repetitions = const Value.absent(),
    this.againCount = const Value.absent(),
    this.knowCount = const Value.absent(),
    this.lastRating = const Value.absent(),
    this.isLearned = const Value.absent(),
    this.lastReviewedAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : flashcardId = Value(flashcardId);
  static Insertable<UserFlashcardProgressData> custom({
    Expression<String>? flashcardId,
    Expression<int>? box,
    Expression<int>? repetitions,
    Expression<int>? againCount,
    Expression<int>? knowCount,
    Expression<String>? lastRating,
    Expression<int>? isLearned,
    Expression<int>? lastReviewedAt,
    Expression<int>? dueAt,
    Expression<int>? version,
    Expression<int>? clientUpdatedAt,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (box != null) 'box': box,
      if (repetitions != null) 'repetitions': repetitions,
      if (againCount != null) 'again_count': againCount,
      if (knowCount != null) 'know_count': knowCount,
      if (lastRating != null) 'last_rating': lastRating,
      if (isLearned != null) 'is_learned': isLearned,
      if (lastReviewedAt != null) 'last_reviewed_at': lastReviewedAt,
      if (dueAt != null) 'due_at': dueAt,
      if (version != null) 'version': version,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFlashcardProgressCompanion copyWith({
    Value<String>? flashcardId,
    Value<int>? box,
    Value<int>? repetitions,
    Value<int>? againCount,
    Value<int>? knowCount,
    Value<String?>? lastRating,
    Value<int>? isLearned,
    Value<int?>? lastReviewedAt,
    Value<int?>? dueAt,
    Value<int>? version,
    Value<int?>? clientUpdatedAt,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserFlashcardProgressCompanion(
      flashcardId: flashcardId ?? this.flashcardId,
      box: box ?? this.box,
      repetitions: repetitions ?? this.repetitions,
      againCount: againCount ?? this.againCount,
      knowCount: knowCount ?? this.knowCount,
      lastRating: lastRating ?? this.lastRating,
      isLearned: isLearned ?? this.isLearned,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      dueAt: dueAt ?? this.dueAt,
      version: version ?? this.version,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (box.present) {
      map['box'] = Variable<int>(box.value);
    }
    if (repetitions.present) {
      map['repetitions'] = Variable<int>(repetitions.value);
    }
    if (againCount.present) {
      map['again_count'] = Variable<int>(againCount.value);
    }
    if (knowCount.present) {
      map['know_count'] = Variable<int>(knowCount.value);
    }
    if (lastRating.present) {
      map['last_rating'] = Variable<String>(lastRating.value);
    }
    if (isLearned.present) {
      map['is_learned'] = Variable<int>(isLearned.value);
    }
    if (lastReviewedAt.present) {
      map['last_reviewed_at'] = Variable<int>(lastReviewedAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFlashcardProgressCompanion(')
          ..write('flashcardId: $flashcardId, ')
          ..write('box: $box, ')
          ..write('repetitions: $repetitions, ')
          ..write('againCount: $againCount, ')
          ..write('knowCount: $knowCount, ')
          ..write('lastRating: $lastRating, ')
          ..write('isLearned: $isLearned, ')
          ..write('lastReviewedAt: $lastReviewedAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class FlashcardReviewLogs extends Table
    with TableInfo<FlashcardReviewLogs, FlashcardReviewLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  FlashcardReviewLogs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES flashcards(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  late final GeneratedColumn<String> rating = GeneratedColumn<String>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (rating IN (\'AGAIN\', \'KNOW\'))',
  );
  static const VerificationMeta _boxBeforeMeta = const VerificationMeta(
    'boxBefore',
  );
  late final GeneratedColumn<int> boxBefore = GeneratedColumn<int>(
    'box_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _boxAfterMeta = const VerificationMeta(
    'boxAfter',
  );
  late final GeneratedColumn<int> boxAfter = GeneratedColumn<int>(
    'box_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _responseTimeMsMeta = const VerificationMeta(
    'responseTimeMs',
  );
  late final GeneratedColumn<int> responseTimeMs = GeneratedColumn<int>(
    'response_time_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _reviewedAtMeta = const VerificationMeta(
    'reviewedAt',
  );
  late final GeneratedColumn<int> reviewedAt = GeneratedColumn<int>(
    'reviewed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pending_create\' CHECK (sync_status IN (\'synced\', \'pending_create\'))',
    defaultValue: const CustomExpression('\'pending_create\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    flashcardId,
    rating,
    boxBefore,
    boxAfter,
    responseTimeMs,
    reviewedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcard_review_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<FlashcardReviewLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    } else if (isInserting) {
      context.missing(_ratingMeta);
    }
    if (data.containsKey('box_before')) {
      context.handle(
        _boxBeforeMeta,
        boxBefore.isAcceptableOrUnknown(data['box_before']!, _boxBeforeMeta),
      );
    } else if (isInserting) {
      context.missing(_boxBeforeMeta);
    }
    if (data.containsKey('box_after')) {
      context.handle(
        _boxAfterMeta,
        boxAfter.isAcceptableOrUnknown(data['box_after']!, _boxAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_boxAfterMeta);
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
        _responseTimeMsMeta,
        responseTimeMs.isAcceptableOrUnknown(
          data['response_time_ms']!,
          _responseTimeMsMeta,
        ),
      );
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
        _reviewedAtMeta,
        reviewedAt.isAcceptableOrUnknown(data['reviewed_at']!, _reviewedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FlashcardReviewLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FlashcardReviewLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rating'],
      )!,
      boxBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box_before'],
      )!,
      boxAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}box_after'],
      )!,
      responseTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}response_time_ms'],
      ),
      reviewedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reviewed_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  FlashcardReviewLogs createAlias(String alias) {
    return FlashcardReviewLogs(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class FlashcardReviewLog extends DataClass
    implements Insertable<FlashcardReviewLog> {
  final String id;

  /// UUID v4 sinh tại client
  final String flashcardId;
  final String rating;
  final int boxBefore;
  final int boxAfter;
  final int? responseTimeMs;
  final int reviewedAt;

  /// sync
  final String syncStatus;
  final int? lastSyncedAt;
  const FlashcardReviewLog({
    required this.id,
    required this.flashcardId,
    required this.rating,
    required this.boxBefore,
    required this.boxAfter,
    this.responseTimeMs,
    required this.reviewedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['rating'] = Variable<String>(rating);
    map['box_before'] = Variable<int>(boxBefore);
    map['box_after'] = Variable<int>(boxAfter);
    if (!nullToAbsent || responseTimeMs != null) {
      map['response_time_ms'] = Variable<int>(responseTimeMs);
    }
    map['reviewed_at'] = Variable<int>(reviewedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  FlashcardReviewLogsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardReviewLogsCompanion(
      id: Value(id),
      flashcardId: Value(flashcardId),
      rating: Value(rating),
      boxBefore: Value(boxBefore),
      boxAfter: Value(boxAfter),
      responseTimeMs: responseTimeMs == null && nullToAbsent
          ? const Value.absent()
          : Value(responseTimeMs),
      reviewedAt: Value(reviewedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory FlashcardReviewLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FlashcardReviewLog(
      id: serializer.fromJson<String>(json['id']),
      flashcardId: serializer.fromJson<String>(json['flashcard_id']),
      rating: serializer.fromJson<String>(json['rating']),
      boxBefore: serializer.fromJson<int>(json['box_before']),
      boxAfter: serializer.fromJson<int>(json['box_after']),
      responseTimeMs: serializer.fromJson<int?>(json['response_time_ms']),
      reviewedAt: serializer.fromJson<int>(json['reviewed_at']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'flashcard_id': serializer.toJson<String>(flashcardId),
      'rating': serializer.toJson<String>(rating),
      'box_before': serializer.toJson<int>(boxBefore),
      'box_after': serializer.toJson<int>(boxAfter),
      'response_time_ms': serializer.toJson<int?>(responseTimeMs),
      'reviewed_at': serializer.toJson<int>(reviewedAt),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  FlashcardReviewLog copyWith({
    String? id,
    String? flashcardId,
    String? rating,
    int? boxBefore,
    int? boxAfter,
    Value<int?> responseTimeMs = const Value.absent(),
    int? reviewedAt,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => FlashcardReviewLog(
    id: id ?? this.id,
    flashcardId: flashcardId ?? this.flashcardId,
    rating: rating ?? this.rating,
    boxBefore: boxBefore ?? this.boxBefore,
    boxAfter: boxAfter ?? this.boxAfter,
    responseTimeMs: responseTimeMs.present
        ? responseTimeMs.value
        : this.responseTimeMs,
    reviewedAt: reviewedAt ?? this.reviewedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  FlashcardReviewLog copyWithCompanion(FlashcardReviewLogsCompanion data) {
    return FlashcardReviewLog(
      id: data.id.present ? data.id.value : this.id,
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      rating: data.rating.present ? data.rating.value : this.rating,
      boxBefore: data.boxBefore.present ? data.boxBefore.value : this.boxBefore,
      boxAfter: data.boxAfter.present ? data.boxAfter.value : this.boxAfter,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
      reviewedAt: data.reviewedAt.present
          ? data.reviewedAt.value
          : this.reviewedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardReviewLog(')
          ..write('id: $id, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('rating: $rating, ')
          ..write('boxBefore: $boxBefore, ')
          ..write('boxAfter: $boxAfter, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    flashcardId,
    rating,
    boxBefore,
    boxAfter,
    responseTimeMs,
    reviewedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FlashcardReviewLog &&
          other.id == this.id &&
          other.flashcardId == this.flashcardId &&
          other.rating == this.rating &&
          other.boxBefore == this.boxBefore &&
          other.boxAfter == this.boxAfter &&
          other.responseTimeMs == this.responseTimeMs &&
          other.reviewedAt == this.reviewedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class FlashcardReviewLogsCompanion extends UpdateCompanion<FlashcardReviewLog> {
  final Value<String> id;
  final Value<String> flashcardId;
  final Value<String> rating;
  final Value<int> boxBefore;
  final Value<int> boxAfter;
  final Value<int?> responseTimeMs;
  final Value<int> reviewedAt;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const FlashcardReviewLogsCompanion({
    this.id = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.rating = const Value.absent(),
    this.boxBefore = const Value.absent(),
    this.boxAfter = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FlashcardReviewLogsCompanion.insert({
    required String id,
    required String flashcardId,
    required String rating,
    required int boxBefore,
    required int boxAfter,
    this.responseTimeMs = const Value.absent(),
    required int reviewedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       flashcardId = Value(flashcardId),
       rating = Value(rating),
       boxBefore = Value(boxBefore),
       boxAfter = Value(boxAfter),
       reviewedAt = Value(reviewedAt);
  static Insertable<FlashcardReviewLog> custom({
    Expression<String>? id,
    Expression<String>? flashcardId,
    Expression<String>? rating,
    Expression<int>? boxBefore,
    Expression<int>? boxAfter,
    Expression<int>? responseTimeMs,
    Expression<int>? reviewedAt,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (rating != null) 'rating': rating,
      if (boxBefore != null) 'box_before': boxBefore,
      if (boxAfter != null) 'box_after': boxAfter,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FlashcardReviewLogsCompanion copyWith({
    Value<String>? id,
    Value<String>? flashcardId,
    Value<String>? rating,
    Value<int>? boxBefore,
    Value<int>? boxAfter,
    Value<int?>? responseTimeMs,
    Value<int>? reviewedAt,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return FlashcardReviewLogsCompanion(
      id: id ?? this.id,
      flashcardId: flashcardId ?? this.flashcardId,
      rating: rating ?? this.rating,
      boxBefore: boxBefore ?? this.boxBefore,
      boxAfter: boxAfter ?? this.boxAfter,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (rating.present) {
      map['rating'] = Variable<String>(rating.value);
    }
    if (boxBefore.present) {
      map['box_before'] = Variable<int>(boxBefore.value);
    }
    if (boxAfter.present) {
      map['box_after'] = Variable<int>(boxAfter.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<int>(responseTimeMs.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<int>(reviewedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardReviewLogsCompanion(')
          ..write('id: $id, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('rating: $rating, ')
          ..write('boxBefore: $boxBefore, ')
          ..write('boxAfter: $boxAfter, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserFlashcardNotes extends Table
    with TableInfo<UserFlashcardNotes, UserFlashcardNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserFlashcardNotes(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL UNIQUE REFERENCES flashcards(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  late final GeneratedColumn<int> clientUpdatedAt = GeneratedColumn<int>(
    'client_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    flashcardId,
    content,
    version,
    clientUpdatedAt,
    deletedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_flashcard_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserFlashcardNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserFlashcardNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserFlashcardNote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserFlashcardNotes createAlias(String alias) {
    return UserFlashcardNotes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserFlashcardNote extends DataClass
    implements Insertable<UserFlashcardNote> {
  final String id;
  final String flashcardId;
  final String content;
  final int version;
  final int clientUpdatedAt;
  final int? deletedAt;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserFlashcardNote({
    required this.id,
    required this.flashcardId,
    required this.content,
    required this.version,
    required this.clientUpdatedAt,
    this.deletedAt,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['content'] = Variable<String>(content);
    map['version'] = Variable<int>(version);
    map['client_updated_at'] = Variable<int>(clientUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserFlashcardNotesCompanion toCompanion(bool nullToAbsent) {
    return UserFlashcardNotesCompanion(
      id: Value(id),
      flashcardId: Value(flashcardId),
      content: Value(content),
      version: Value(version),
      clientUpdatedAt: Value(clientUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserFlashcardNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserFlashcardNote(
      id: serializer.fromJson<String>(json['id']),
      flashcardId: serializer.fromJson<String>(json['flashcard_id']),
      content: serializer.fromJson<String>(json['content']),
      version: serializer.fromJson<int>(json['version']),
      clientUpdatedAt: serializer.fromJson<int>(json['client_updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'flashcard_id': serializer.toJson<String>(flashcardId),
      'content': serializer.toJson<String>(content),
      'version': serializer.toJson<int>(version),
      'client_updated_at': serializer.toJson<int>(clientUpdatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserFlashcardNote copyWith({
    String? id,
    String? flashcardId,
    String? content,
    int? version,
    int? clientUpdatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserFlashcardNote(
    id: id ?? this.id,
    flashcardId: flashcardId ?? this.flashcardId,
    content: content ?? this.content,
    version: version ?? this.version,
    clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserFlashcardNote copyWithCompanion(UserFlashcardNotesCompanion data) {
    return UserFlashcardNote(
      id: data.id.present ? data.id.value : this.id,
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      content: data.content.present ? data.content.value : this.content,
      version: data.version.present ? data.version.value : this.version,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserFlashcardNote(')
          ..write('id: $id, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('content: $content, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    flashcardId,
    content,
    version,
    clientUpdatedAt,
    deletedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserFlashcardNote &&
          other.id == this.id &&
          other.flashcardId == this.flashcardId &&
          other.content == this.content &&
          other.version == this.version &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserFlashcardNotesCompanion extends UpdateCompanion<UserFlashcardNote> {
  final Value<String> id;
  final Value<String> flashcardId;
  final Value<String> content;
  final Value<int> version;
  final Value<int> clientUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserFlashcardNotesCompanion({
    this.id = const Value.absent(),
    this.flashcardId = const Value.absent(),
    this.content = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFlashcardNotesCompanion.insert({
    required String id,
    required String flashcardId,
    required String content,
    this.version = const Value.absent(),
    required int clientUpdatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       flashcardId = Value(flashcardId),
       content = Value(content),
       clientUpdatedAt = Value(clientUpdatedAt);
  static Insertable<UserFlashcardNote> custom({
    Expression<String>? id,
    Expression<String>? flashcardId,
    Expression<String>? content,
    Expression<int>? version,
    Expression<int>? clientUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (content != null) 'content': content,
      if (version != null) 'version': version,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFlashcardNotesCompanion copyWith({
    Value<String>? id,
    Value<String>? flashcardId,
    Value<String>? content,
    Value<int>? version,
    Value<int>? clientUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserFlashcardNotesCompanion(
      id: id ?? this.id,
      flashcardId: flashcardId ?? this.flashcardId,
      content: content ?? this.content,
      version: version ?? this.version,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFlashcardNotesCompanion(')
          ..write('id: $id, ')
          ..write('flashcardId: $flashcardId, ')
          ..write('content: $content, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserBookmarks extends Table with TableInfo<UserBookmarks, UserBookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserBookmarks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flashcardIdMeta = const VerificationMeta(
    'flashcardId',
  );
  late final GeneratedColumn<String> flashcardId = GeneratedColumn<String>(
    'flashcard_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES flashcards(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  late final GeneratedColumn<int> clientUpdatedAt = GeneratedColumn<int>(
    'client_updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  late final GeneratedColumn<int> deletedAt = GeneratedColumn<int>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    flashcardId,
    createdAt,
    version,
    clientUpdatedAt,
    deletedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserBookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flashcard_id')) {
      context.handle(
        _flashcardIdMeta,
        flashcardId.isAcceptableOrUnknown(
          data['flashcard_id']!,
          _flashcardIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_flashcardIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_clientUpdatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flashcardId};
  @override
  UserBookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserBookmark(
      flashcardId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flashcard_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserBookmarks createAlias(String alias) {
    return UserBookmarks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserBookmark extends DataClass implements Insertable<UserBookmark> {
  final String flashcardId;
  final int createdAt;
  final int version;
  final int clientUpdatedAt;
  final int? deletedAt;

  /// tombstone: bỏ bookmark khi offline
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserBookmark({
    required this.flashcardId,
    required this.createdAt,
    required this.version,
    required this.clientUpdatedAt,
    this.deletedAt,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flashcard_id'] = Variable<String>(flashcardId);
    map['created_at'] = Variable<int>(createdAt);
    map['version'] = Variable<int>(version);
    map['client_updated_at'] = Variable<int>(clientUpdatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(deletedAt);
    }
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserBookmarksCompanion toCompanion(bool nullToAbsent) {
    return UserBookmarksCompanion(
      flashcardId: Value(flashcardId),
      createdAt: Value(createdAt),
      version: Value(version),
      clientUpdatedAt: Value(clientUpdatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserBookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserBookmark(
      flashcardId: serializer.fromJson<String>(json['flashcard_id']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      version: serializer.fromJson<int>(json['version']),
      clientUpdatedAt: serializer.fromJson<int>(json['client_updated_at']),
      deletedAt: serializer.fromJson<int?>(json['deleted_at']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flashcard_id': serializer.toJson<String>(flashcardId),
      'created_at': serializer.toJson<int>(createdAt),
      'version': serializer.toJson<int>(version),
      'client_updated_at': serializer.toJson<int>(clientUpdatedAt),
      'deleted_at': serializer.toJson<int?>(deletedAt),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserBookmark copyWith({
    String? flashcardId,
    int? createdAt,
    int? version,
    int? clientUpdatedAt,
    Value<int?> deletedAt = const Value.absent(),
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserBookmark(
    flashcardId: flashcardId ?? this.flashcardId,
    createdAt: createdAt ?? this.createdAt,
    version: version ?? this.version,
    clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserBookmark copyWithCompanion(UserBookmarksCompanion data) {
    return UserBookmark(
      flashcardId: data.flashcardId.present
          ? data.flashcardId.value
          : this.flashcardId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      version: data.version.present ? data.version.value : this.version,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserBookmark(')
          ..write('flashcardId: $flashcardId, ')
          ..write('createdAt: $createdAt, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    flashcardId,
    createdAt,
    version,
    clientUpdatedAt,
    deletedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBookmark &&
          other.flashcardId == this.flashcardId &&
          other.createdAt == this.createdAt &&
          other.version == this.version &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.deletedAt == this.deletedAt &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserBookmarksCompanion extends UpdateCompanion<UserBookmark> {
  final Value<String> flashcardId;
  final Value<int> createdAt;
  final Value<int> version;
  final Value<int> clientUpdatedAt;
  final Value<int?> deletedAt;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserBookmarksCompanion({
    this.flashcardId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserBookmarksCompanion.insert({
    required String flashcardId,
    required int createdAt,
    this.version = const Value.absent(),
    required int clientUpdatedAt,
    this.deletedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : flashcardId = Value(flashcardId),
       createdAt = Value(createdAt),
       clientUpdatedAt = Value(clientUpdatedAt);
  static Insertable<UserBookmark> custom({
    Expression<String>? flashcardId,
    Expression<int>? createdAt,
    Expression<int>? version,
    Expression<int>? clientUpdatedAt,
    Expression<int>? deletedAt,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (createdAt != null) 'created_at': createdAt,
      if (version != null) 'version': version,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserBookmarksCompanion copyWith({
    Value<String>? flashcardId,
    Value<int>? createdAt,
    Value<int>? version,
    Value<int>? clientUpdatedAt,
    Value<int?>? deletedAt,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserBookmarksCompanion(
      flashcardId: flashcardId ?? this.flashcardId,
      createdAt: createdAt ?? this.createdAt,
      version: version ?? this.version,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<String>(flashcardId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(deletedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBookmarksCompanion(')
          ..write('flashcardId: $flashcardId, ')
          ..write('createdAt: $createdAt, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserTopicProgress extends Table
    with TableInfo<UserTopicProgress, UserTopicProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserTopicProgress(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES topics(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _learnedWordsMeta = const VerificationMeta(
    'learnedWords',
  );
  late final GeneratedColumn<int> learnedWords = GeneratedColumn<int>(
    'learned_words',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'NOT_STARTED\' CHECK (status IN (\'NOT_STARTED\', \'IN_PROGRESS\', \'COMPLETED\'))',
    defaultValue: const CustomExpression('\'NOT_STARTED\''),
  );
  static const VerificationMeta _lastStudiedAtMeta = const VerificationMeta(
    'lastStudiedAt',
  );
  late final GeneratedColumn<int> lastStudiedAt = GeneratedColumn<int>(
    'last_studied_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    topicId,
    learnedWords,
    status,
    lastStudiedAt,
    completedAt,
    version,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_topic_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserTopicProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('learned_words')) {
      context.handle(
        _learnedWordsMeta,
        learnedWords.isAcceptableOrUnknown(
          data['learned_words']!,
          _learnedWordsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
        _lastStudiedAtMeta,
        lastStudiedAt.isAcceptableOrUnknown(
          data['last_studied_at']!,
          _lastStudiedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {topicId};
  @override
  UserTopicProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserTopicProgressData(
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      learnedWords: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}learned_words'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      lastStudiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_studied_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserTopicProgress createAlias(String alias) {
    return UserTopicProgress(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserTopicProgressData extends DataClass
    implements Insertable<UserTopicProgressData> {
  final String topicId;
  final int learnedWords;
  final String status;
  final int? lastStudiedAt;
  final int? completedAt;
  final int version;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserTopicProgressData({
    required this.topicId,
    required this.learnedWords,
    required this.status,
    this.lastStudiedAt,
    this.completedAt,
    required this.version,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['topic_id'] = Variable<String>(topicId);
    map['learned_words'] = Variable<int>(learnedWords);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['version'] = Variable<int>(version);
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserTopicProgressCompanion toCompanion(bool nullToAbsent) {
    return UserTopicProgressCompanion(
      topicId: Value(topicId),
      learnedWords: Value(learnedWords),
      status: Value(status),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      version: Value(version),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserTopicProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserTopicProgressData(
      topicId: serializer.fromJson<String>(json['topic_id']),
      learnedWords: serializer.fromJson<int>(json['learned_words']),
      status: serializer.fromJson<String>(json['status']),
      lastStudiedAt: serializer.fromJson<int?>(json['last_studied_at']),
      completedAt: serializer.fromJson<int?>(json['completed_at']),
      version: serializer.fromJson<int>(json['version']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'topic_id': serializer.toJson<String>(topicId),
      'learned_words': serializer.toJson<int>(learnedWords),
      'status': serializer.toJson<String>(status),
      'last_studied_at': serializer.toJson<int?>(lastStudiedAt),
      'completed_at': serializer.toJson<int?>(completedAt),
      'version': serializer.toJson<int>(version),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserTopicProgressData copyWith({
    String? topicId,
    int? learnedWords,
    String? status,
    Value<int?> lastStudiedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? version,
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserTopicProgressData(
    topicId: topicId ?? this.topicId,
    learnedWords: learnedWords ?? this.learnedWords,
    status: status ?? this.status,
    lastStudiedAt: lastStudiedAt.present
        ? lastStudiedAt.value
        : this.lastStudiedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    version: version ?? this.version,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserTopicProgressData copyWithCompanion(UserTopicProgressCompanion data) {
    return UserTopicProgressData(
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      learnedWords: data.learnedWords.present
          ? data.learnedWords.value
          : this.learnedWords,
      status: data.status.present ? data.status.value : this.status,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      version: data.version.present ? data.version.value : this.version,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserTopicProgressData(')
          ..write('topicId: $topicId, ')
          ..write('learnedWords: $learnedWords, ')
          ..write('status: $status, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    topicId,
    learnedWords,
    status,
    lastStudiedAt,
    completedAt,
    version,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserTopicProgressData &&
          other.topicId == this.topicId &&
          other.learnedWords == this.learnedWords &&
          other.status == this.status &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.completedAt == this.completedAt &&
          other.version == this.version &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserTopicProgressCompanion
    extends UpdateCompanion<UserTopicProgressData> {
  final Value<String> topicId;
  final Value<int> learnedWords;
  final Value<String> status;
  final Value<int?> lastStudiedAt;
  final Value<int?> completedAt;
  final Value<int> version;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserTopicProgressCompanion({
    this.topicId = const Value.absent(),
    this.learnedWords = const Value.absent(),
    this.status = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserTopicProgressCompanion.insert({
    required String topicId,
    this.learnedWords = const Value.absent(),
    this.status = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : topicId = Value(topicId);
  static Insertable<UserTopicProgressData> custom({
    Expression<String>? topicId,
    Expression<int>? learnedWords,
    Expression<String>? status,
    Expression<int>? lastStudiedAt,
    Expression<int>? completedAt,
    Expression<int>? version,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (topicId != null) 'topic_id': topicId,
      if (learnedWords != null) 'learned_words': learnedWords,
      if (status != null) 'status': status,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (version != null) 'version': version,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserTopicProgressCompanion copyWith({
    Value<String>? topicId,
    Value<int>? learnedWords,
    Value<String>? status,
    Value<int?>? lastStudiedAt,
    Value<int?>? completedAt,
    Value<int>? version,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserTopicProgressCompanion(
      topicId: topicId ?? this.topicId,
      learnedWords: learnedWords ?? this.learnedWords,
      status: status ?? this.status,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      completedAt: completedAt ?? this.completedAt,
      version: version ?? this.version,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (learnedWords.present) {
      map['learned_words'] = Variable<int>(learnedWords.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserTopicProgressCompanion(')
          ..write('topicId: $topicId, ')
          ..write('learnedWords: $learnedWords, ')
          ..write('status: $status, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserGrammarProgress extends Table
    with TableInfo<UserGrammarProgress, UserGrammarProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserGrammarProgress(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _grammarLessonIdMeta = const VerificationMeta(
    'grammarLessonId',
  );
  late final GeneratedColumn<String> grammarLessonId = GeneratedColumn<String>(
    'grammar_lesson_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL PRIMARY KEY REFERENCES grammar_lessons(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (progress BETWEEN 0 AND 1)',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'NOT_STARTED\' CHECK (status IN (\'NOT_STARTED\', \'IN_PROGRESS\', \'COMPLETED\'))',
    defaultValue: const CustomExpression('\'NOT_STARTED\''),
  );
  static const VerificationMeta _bestScorePercentMeta = const VerificationMeta(
    'bestScorePercent',
  );
  late final GeneratedColumn<int> bestScorePercent = GeneratedColumn<int>(
    'best_score_percent',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastStudiedAtMeta = const VerificationMeta(
    'lastStudiedAt',
  );
  late final GeneratedColumn<int> lastStudiedAt = GeneratedColumn<int>(
    'last_studied_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    grammarLessonId,
    progress,
    status,
    bestScorePercent,
    lastStudiedAt,
    completedAt,
    version,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_grammar_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserGrammarProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('grammar_lesson_id')) {
      context.handle(
        _grammarLessonIdMeta,
        grammarLessonId.isAcceptableOrUnknown(
          data['grammar_lesson_id']!,
          _grammarLessonIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_grammarLessonIdMeta);
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('best_score_percent')) {
      context.handle(
        _bestScorePercentMeta,
        bestScorePercent.isAcceptableOrUnknown(
          data['best_score_percent']!,
          _bestScorePercentMeta,
        ),
      );
    }
    if (data.containsKey('last_studied_at')) {
      context.handle(
        _lastStudiedAtMeta,
        lastStudiedAt.isAcceptableOrUnknown(
          data['last_studied_at']!,
          _lastStudiedAtMeta,
        ),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {grammarLessonId};
  @override
  UserGrammarProgressData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserGrammarProgressData(
      grammarLessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_lesson_id'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      bestScorePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_score_percent'],
      ),
      lastStudiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_studied_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserGrammarProgress createAlias(String alias) {
    return UserGrammarProgress(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserGrammarProgressData extends DataClass
    implements Insertable<UserGrammarProgressData> {
  final String grammarLessonId;
  final double progress;
  final String status;
  final int? bestScorePercent;
  final int? lastStudiedAt;
  final int? completedAt;
  final int version;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserGrammarProgressData({
    required this.grammarLessonId,
    required this.progress,
    required this.status,
    this.bestScorePercent,
    this.lastStudiedAt,
    this.completedAt,
    required this.version,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['grammar_lesson_id'] = Variable<String>(grammarLessonId);
    map['progress'] = Variable<double>(progress);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || bestScorePercent != null) {
      map['best_score_percent'] = Variable<int>(bestScorePercent);
    }
    if (!nullToAbsent || lastStudiedAt != null) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['version'] = Variable<int>(version);
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserGrammarProgressCompanion toCompanion(bool nullToAbsent) {
    return UserGrammarProgressCompanion(
      grammarLessonId: Value(grammarLessonId),
      progress: Value(progress),
      status: Value(status),
      bestScorePercent: bestScorePercent == null && nullToAbsent
          ? const Value.absent()
          : Value(bestScorePercent),
      lastStudiedAt: lastStudiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastStudiedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      version: Value(version),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserGrammarProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserGrammarProgressData(
      grammarLessonId: serializer.fromJson<String>(json['grammar_lesson_id']),
      progress: serializer.fromJson<double>(json['progress']),
      status: serializer.fromJson<String>(json['status']),
      bestScorePercent: serializer.fromJson<int?>(json['best_score_percent']),
      lastStudiedAt: serializer.fromJson<int?>(json['last_studied_at']),
      completedAt: serializer.fromJson<int?>(json['completed_at']),
      version: serializer.fromJson<int>(json['version']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'grammar_lesson_id': serializer.toJson<String>(grammarLessonId),
      'progress': serializer.toJson<double>(progress),
      'status': serializer.toJson<String>(status),
      'best_score_percent': serializer.toJson<int?>(bestScorePercent),
      'last_studied_at': serializer.toJson<int?>(lastStudiedAt),
      'completed_at': serializer.toJson<int?>(completedAt),
      'version': serializer.toJson<int>(version),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserGrammarProgressData copyWith({
    String? grammarLessonId,
    double? progress,
    String? status,
    Value<int?> bestScorePercent = const Value.absent(),
    Value<int?> lastStudiedAt = const Value.absent(),
    Value<int?> completedAt = const Value.absent(),
    int? version,
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserGrammarProgressData(
    grammarLessonId: grammarLessonId ?? this.grammarLessonId,
    progress: progress ?? this.progress,
    status: status ?? this.status,
    bestScorePercent: bestScorePercent.present
        ? bestScorePercent.value
        : this.bestScorePercent,
    lastStudiedAt: lastStudiedAt.present
        ? lastStudiedAt.value
        : this.lastStudiedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    version: version ?? this.version,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserGrammarProgressData copyWithCompanion(UserGrammarProgressCompanion data) {
    return UserGrammarProgressData(
      grammarLessonId: data.grammarLessonId.present
          ? data.grammarLessonId.value
          : this.grammarLessonId,
      progress: data.progress.present ? data.progress.value : this.progress,
      status: data.status.present ? data.status.value : this.status,
      bestScorePercent: data.bestScorePercent.present
          ? data.bestScorePercent.value
          : this.bestScorePercent,
      lastStudiedAt: data.lastStudiedAt.present
          ? data.lastStudiedAt.value
          : this.lastStudiedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      version: data.version.present ? data.version.value : this.version,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserGrammarProgressData(')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('progress: $progress, ')
          ..write('status: $status, ')
          ..write('bestScorePercent: $bestScorePercent, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    grammarLessonId,
    progress,
    status,
    bestScorePercent,
    lastStudiedAt,
    completedAt,
    version,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserGrammarProgressData &&
          other.grammarLessonId == this.grammarLessonId &&
          other.progress == this.progress &&
          other.status == this.status &&
          other.bestScorePercent == this.bestScorePercent &&
          other.lastStudiedAt == this.lastStudiedAt &&
          other.completedAt == this.completedAt &&
          other.version == this.version &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserGrammarProgressCompanion
    extends UpdateCompanion<UserGrammarProgressData> {
  final Value<String> grammarLessonId;
  final Value<double> progress;
  final Value<String> status;
  final Value<int?> bestScorePercent;
  final Value<int?> lastStudiedAt;
  final Value<int?> completedAt;
  final Value<int> version;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserGrammarProgressCompanion({
    this.grammarLessonId = const Value.absent(),
    this.progress = const Value.absent(),
    this.status = const Value.absent(),
    this.bestScorePercent = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserGrammarProgressCompanion.insert({
    required String grammarLessonId,
    this.progress = const Value.absent(),
    this.status = const Value.absent(),
    this.bestScorePercent = const Value.absent(),
    this.lastStudiedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : grammarLessonId = Value(grammarLessonId);
  static Insertable<UserGrammarProgressData> custom({
    Expression<String>? grammarLessonId,
    Expression<double>? progress,
    Expression<String>? status,
    Expression<int>? bestScorePercent,
    Expression<int>? lastStudiedAt,
    Expression<int>? completedAt,
    Expression<int>? version,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (grammarLessonId != null) 'grammar_lesson_id': grammarLessonId,
      if (progress != null) 'progress': progress,
      if (status != null) 'status': status,
      if (bestScorePercent != null) 'best_score_percent': bestScorePercent,
      if (lastStudiedAt != null) 'last_studied_at': lastStudiedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (version != null) 'version': version,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserGrammarProgressCompanion copyWith({
    Value<String>? grammarLessonId,
    Value<double>? progress,
    Value<String>? status,
    Value<int?>? bestScorePercent,
    Value<int?>? lastStudiedAt,
    Value<int?>? completedAt,
    Value<int>? version,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserGrammarProgressCompanion(
      grammarLessonId: grammarLessonId ?? this.grammarLessonId,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      bestScorePercent: bestScorePercent ?? this.bestScorePercent,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      completedAt: completedAt ?? this.completedAt,
      version: version ?? this.version,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (grammarLessonId.present) {
      map['grammar_lesson_id'] = Variable<String>(grammarLessonId.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (bestScorePercent.present) {
      map['best_score_percent'] = Variable<int>(bestScorePercent.value);
    }
    if (lastStudiedAt.present) {
      map['last_studied_at'] = Variable<int>(lastStudiedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserGrammarProgressCompanion(')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('progress: $progress, ')
          ..write('status: $status, ')
          ..write('bestScorePercent: $bestScorePercent, ')
          ..write('lastStudiedAt: $lastStudiedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class LessonCompletions extends Table
    with TableInfo<LessonCompletions, LessonCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  LessonCompletions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _lessonTypeMeta = const VerificationMeta(
    'lessonType',
  );
  late final GeneratedColumn<String> lessonType = GeneratedColumn<String>(
    'lesson_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL CHECK (lesson_type IN (\'TOPIC\', \'GRAMMAR\'))',
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES topics(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _grammarLessonIdMeta = const VerificationMeta(
    'grammarLessonId',
  );
  late final GeneratedColumn<String> grammarLessonId = GeneratedColumn<String>(
    'grammar_lesson_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES grammar_lessons(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _cardsReviewedMeta = const VerificationMeta(
    'cardsReviewed',
  );
  late final GeneratedColumn<int> cardsReviewed = GeneratedColumn<int>(
    'cards_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pending_create\' CHECK (sync_status IN (\'synced\', \'pending_create\'))',
    defaultValue: const CustomExpression('\'pending_create\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    lessonType,
    topicId,
    grammarLessonId,
    cardsReviewed,
    durationSeconds,
    completedAt,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lesson_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LessonCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('lesson_type')) {
      context.handle(
        _lessonTypeMeta,
        lessonType.isAcceptableOrUnknown(data['lesson_type']!, _lessonTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_lessonTypeMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    }
    if (data.containsKey('grammar_lesson_id')) {
      context.handle(
        _grammarLessonIdMeta,
        grammarLessonId.isAcceptableOrUnknown(
          data['grammar_lesson_id']!,
          _grammarLessonIdMeta,
        ),
      );
    }
    if (data.containsKey('cards_reviewed')) {
      context.handle(
        _cardsReviewedMeta,
        cardsReviewed.isAcceptableOrUnknown(
          data['cards_reviewed']!,
          _cardsReviewedMeta,
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
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LessonCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LessonCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      lessonType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}lesson_type'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      ),
      grammarLessonId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grammar_lesson_id'],
      ),
      cardsReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cards_reviewed'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  LessonCompletions createAlias(String alias) {
    return LessonCompletions(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'CHECK((topic_id IS NULL)<>(grammar_lesson_id IS NULL))',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class LessonCompletion extends DataClass
    implements Insertable<LessonCompletion> {
  final String id;
  final String lessonType;
  final String? topicId;
  final String? grammarLessonId;
  final int cardsReviewed;
  final int durationSeconds;
  final int completedAt;
  final String syncStatus;
  final int? lastSyncedAt;
  const LessonCompletion({
    required this.id,
    required this.lessonType,
    this.topicId,
    this.grammarLessonId,
    required this.cardsReviewed,
    required this.durationSeconds,
    required this.completedAt,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['lesson_type'] = Variable<String>(lessonType);
    if (!nullToAbsent || topicId != null) {
      map['topic_id'] = Variable<String>(topicId);
    }
    if (!nullToAbsent || grammarLessonId != null) {
      map['grammar_lesson_id'] = Variable<String>(grammarLessonId);
    }
    map['cards_reviewed'] = Variable<int>(cardsReviewed);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['completed_at'] = Variable<int>(completedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  LessonCompletionsCompanion toCompanion(bool nullToAbsent) {
    return LessonCompletionsCompanion(
      id: Value(id),
      lessonType: Value(lessonType),
      topicId: topicId == null && nullToAbsent
          ? const Value.absent()
          : Value(topicId),
      grammarLessonId: grammarLessonId == null && nullToAbsent
          ? const Value.absent()
          : Value(grammarLessonId),
      cardsReviewed: Value(cardsReviewed),
      durationSeconds: Value(durationSeconds),
      completedAt: Value(completedAt),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory LessonCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LessonCompletion(
      id: serializer.fromJson<String>(json['id']),
      lessonType: serializer.fromJson<String>(json['lesson_type']),
      topicId: serializer.fromJson<String?>(json['topic_id']),
      grammarLessonId: serializer.fromJson<String?>(json['grammar_lesson_id']),
      cardsReviewed: serializer.fromJson<int>(json['cards_reviewed']),
      durationSeconds: serializer.fromJson<int>(json['duration_seconds']),
      completedAt: serializer.fromJson<int>(json['completed_at']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'lesson_type': serializer.toJson<String>(lessonType),
      'topic_id': serializer.toJson<String?>(topicId),
      'grammar_lesson_id': serializer.toJson<String?>(grammarLessonId),
      'cards_reviewed': serializer.toJson<int>(cardsReviewed),
      'duration_seconds': serializer.toJson<int>(durationSeconds),
      'completed_at': serializer.toJson<int>(completedAt),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  LessonCompletion copyWith({
    String? id,
    String? lessonType,
    Value<String?> topicId = const Value.absent(),
    Value<String?> grammarLessonId = const Value.absent(),
    int? cardsReviewed,
    int? durationSeconds,
    int? completedAt,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => LessonCompletion(
    id: id ?? this.id,
    lessonType: lessonType ?? this.lessonType,
    topicId: topicId.present ? topicId.value : this.topicId,
    grammarLessonId: grammarLessonId.present
        ? grammarLessonId.value
        : this.grammarLessonId,
    cardsReviewed: cardsReviewed ?? this.cardsReviewed,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    completedAt: completedAt ?? this.completedAt,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  LessonCompletion copyWithCompanion(LessonCompletionsCompanion data) {
    return LessonCompletion(
      id: data.id.present ? data.id.value : this.id,
      lessonType: data.lessonType.present
          ? data.lessonType.value
          : this.lessonType,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      grammarLessonId: data.grammarLessonId.present
          ? data.grammarLessonId.value
          : this.grammarLessonId,
      cardsReviewed: data.cardsReviewed.present
          ? data.cardsReviewed.value
          : this.cardsReviewed,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LessonCompletion(')
          ..write('id: $id, ')
          ..write('lessonType: $lessonType, ')
          ..write('topicId: $topicId, ')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lessonType,
    topicId,
    grammarLessonId,
    cardsReviewed,
    durationSeconds,
    completedAt,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LessonCompletion &&
          other.id == this.id &&
          other.lessonType == this.lessonType &&
          other.topicId == this.topicId &&
          other.grammarLessonId == this.grammarLessonId &&
          other.cardsReviewed == this.cardsReviewed &&
          other.durationSeconds == this.durationSeconds &&
          other.completedAt == this.completedAt &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class LessonCompletionsCompanion extends UpdateCompanion<LessonCompletion> {
  final Value<String> id;
  final Value<String> lessonType;
  final Value<String?> topicId;
  final Value<String?> grammarLessonId;
  final Value<int> cardsReviewed;
  final Value<int> durationSeconds;
  final Value<int> completedAt;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const LessonCompletionsCompanion({
    this.id = const Value.absent(),
    this.lessonType = const Value.absent(),
    this.topicId = const Value.absent(),
    this.grammarLessonId = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LessonCompletionsCompanion.insert({
    required String id,
    required String lessonType,
    this.topicId = const Value.absent(),
    this.grammarLessonId = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required int completedAt,
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       lessonType = Value(lessonType),
       completedAt = Value(completedAt);
  static Insertable<LessonCompletion> custom({
    Expression<String>? id,
    Expression<String>? lessonType,
    Expression<String>? topicId,
    Expression<String>? grammarLessonId,
    Expression<int>? cardsReviewed,
    Expression<int>? durationSeconds,
    Expression<int>? completedAt,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lessonType != null) 'lesson_type': lessonType,
      if (topicId != null) 'topic_id': topicId,
      if (grammarLessonId != null) 'grammar_lesson_id': grammarLessonId,
      if (cardsReviewed != null) 'cards_reviewed': cardsReviewed,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LessonCompletionsCompanion copyWith({
    Value<String>? id,
    Value<String>? lessonType,
    Value<String?>? topicId,
    Value<String?>? grammarLessonId,
    Value<int>? cardsReviewed,
    Value<int>? durationSeconds,
    Value<int>? completedAt,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return LessonCompletionsCompanion(
      id: id ?? this.id,
      lessonType: lessonType ?? this.lessonType,
      topicId: topicId ?? this.topicId,
      grammarLessonId: grammarLessonId ?? this.grammarLessonId,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (lessonType.present) {
      map['lesson_type'] = Variable<String>(lessonType.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (grammarLessonId.present) {
      map['grammar_lesson_id'] = Variable<String>(grammarLessonId.value);
    }
    if (cardsReviewed.present) {
      map['cards_reviewed'] = Variable<int>(cardsReviewed.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LessonCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('lessonType: $lessonType, ')
          ..write('topicId: $topicId, ')
          ..write('grammarLessonId: $grammarLessonId, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class QuizAttempts extends Table with TableInfo<QuizAttempts, QuizAttempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuizAttempts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _quizIdMeta = const VerificationMeta('quizId');
  late final GeneratedColumn<String> quizId = GeneratedColumn<String>(
    'quiz_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES quizzes(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _totalQuestionsMeta = const VerificationMeta(
    'totalQuestions',
  );
  late final GeneratedColumn<int> totalQuestions = GeneratedColumn<int>(
    'total_questions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _wrongAnswersMeta = const VerificationMeta(
    'wrongAnswers',
  );
  late final GeneratedColumn<int> wrongAnswers = GeneratedColumn<int>(
    'wrong_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _scorePercentMeta = const VerificationMeta(
    'scorePercent',
  );
  late final GeneratedColumn<int> scorePercent = GeneratedColumn<int>(
    'score_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _timeTakenSecondsMeta = const VerificationMeta(
    'timeTakenSeconds',
  );
  late final GeneratedColumn<int> timeTakenSeconds = GeneratedColumn<int>(
    'time_taken_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  late final GeneratedColumn<int> submittedAt = GeneratedColumn<int>(
    'submitted_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _xpAwardedMeta = const VerificationMeta(
    'xpAwarded',
  );
  late final GeneratedColumn<int> xpAwarded = GeneratedColumn<int>(
    'xp_awarded',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pending_create\' CHECK (sync_status IN (\'synced\', \'pending_create\'))',
    defaultValue: const CustomExpression('\'pending_create\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quizId,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    scorePercent,
    timeTakenSeconds,
    startedAt,
    submittedAt,
    xpAwarded,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizAttempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quiz_id')) {
      context.handle(
        _quizIdMeta,
        quizId.isAcceptableOrUnknown(data['quiz_id']!, _quizIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quizIdMeta);
    }
    if (data.containsKey('total_questions')) {
      context.handle(
        _totalQuestionsMeta,
        totalQuestions.isAcceptableOrUnknown(
          data['total_questions']!,
          _totalQuestionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalQuestionsMeta);
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctAnswersMeta);
    }
    if (data.containsKey('wrong_answers')) {
      context.handle(
        _wrongAnswersMeta,
        wrongAnswers.isAcceptableOrUnknown(
          data['wrong_answers']!,
          _wrongAnswersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_wrongAnswersMeta);
    }
    if (data.containsKey('score_percent')) {
      context.handle(
        _scorePercentMeta,
        scorePercent.isAcceptableOrUnknown(
          data['score_percent']!,
          _scorePercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scorePercentMeta);
    }
    if (data.containsKey('time_taken_seconds')) {
      context.handle(
        _timeTakenSecondsMeta,
        timeTakenSeconds.isAcceptableOrUnknown(
          data['time_taken_seconds']!,
          _timeTakenSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeTakenSecondsMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_submittedAtMeta);
    }
    if (data.containsKey('xp_awarded')) {
      context.handle(
        _xpAwardedMeta,
        xpAwarded.isAcceptableOrUnknown(data['xp_awarded']!, _xpAwardedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuizAttempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      quizId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quiz_id'],
      )!,
      totalQuestions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_questions'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      wrongAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}wrong_answers'],
      )!,
      scorePercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_percent'],
      )!,
      timeTakenSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}time_taken_seconds'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}submitted_at'],
      )!,
      xpAwarded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_awarded'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  QuizAttempts createAlias(String alias) {
    return QuizAttempts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class QuizAttempt extends DataClass implements Insertable<QuizAttempt> {
  final String id;
  final String quizId;
  final int totalQuestions;
  final int correctAnswers;

  /// chấm tạm ở client; server chấm lại và ghi đè
  final int wrongAnswers;
  final int scorePercent;
  final int timeTakenSeconds;
  final int startedAt;
  final int submittedAt;
  final int? xpAwarded;

  /// NULL cho tới khi server xác nhận
  final String syncStatus;
  final int? lastSyncedAt;
  const QuizAttempt({
    required this.id,
    required this.quizId,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.scorePercent,
    required this.timeTakenSeconds,
    required this.startedAt,
    required this.submittedAt,
    this.xpAwarded,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quiz_id'] = Variable<String>(quizId);
    map['total_questions'] = Variable<int>(totalQuestions);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['wrong_answers'] = Variable<int>(wrongAnswers);
    map['score_percent'] = Variable<int>(scorePercent);
    map['time_taken_seconds'] = Variable<int>(timeTakenSeconds);
    map['started_at'] = Variable<int>(startedAt);
    map['submitted_at'] = Variable<int>(submittedAt);
    if (!nullToAbsent || xpAwarded != null) {
      map['xp_awarded'] = Variable<int>(xpAwarded);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  QuizAttemptsCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptsCompanion(
      id: Value(id),
      quizId: Value(quizId),
      totalQuestions: Value(totalQuestions),
      correctAnswers: Value(correctAnswers),
      wrongAnswers: Value(wrongAnswers),
      scorePercent: Value(scorePercent),
      timeTakenSeconds: Value(timeTakenSeconds),
      startedAt: Value(startedAt),
      submittedAt: Value(submittedAt),
      xpAwarded: xpAwarded == null && nullToAbsent
          ? const Value.absent()
          : Value(xpAwarded),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory QuizAttempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttempt(
      id: serializer.fromJson<String>(json['id']),
      quizId: serializer.fromJson<String>(json['quiz_id']),
      totalQuestions: serializer.fromJson<int>(json['total_questions']),
      correctAnswers: serializer.fromJson<int>(json['correct_answers']),
      wrongAnswers: serializer.fromJson<int>(json['wrong_answers']),
      scorePercent: serializer.fromJson<int>(json['score_percent']),
      timeTakenSeconds: serializer.fromJson<int>(json['time_taken_seconds']),
      startedAt: serializer.fromJson<int>(json['started_at']),
      submittedAt: serializer.fromJson<int>(json['submitted_at']),
      xpAwarded: serializer.fromJson<int?>(json['xp_awarded']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quiz_id': serializer.toJson<String>(quizId),
      'total_questions': serializer.toJson<int>(totalQuestions),
      'correct_answers': serializer.toJson<int>(correctAnswers),
      'wrong_answers': serializer.toJson<int>(wrongAnswers),
      'score_percent': serializer.toJson<int>(scorePercent),
      'time_taken_seconds': serializer.toJson<int>(timeTakenSeconds),
      'started_at': serializer.toJson<int>(startedAt),
      'submitted_at': serializer.toJson<int>(submittedAt),
      'xp_awarded': serializer.toJson<int?>(xpAwarded),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  QuizAttempt copyWith({
    String? id,
    String? quizId,
    int? totalQuestions,
    int? correctAnswers,
    int? wrongAnswers,
    int? scorePercent,
    int? timeTakenSeconds,
    int? startedAt,
    int? submittedAt,
    Value<int?> xpAwarded = const Value.absent(),
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => QuizAttempt(
    id: id ?? this.id,
    quizId: quizId ?? this.quizId,
    totalQuestions: totalQuestions ?? this.totalQuestions,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    wrongAnswers: wrongAnswers ?? this.wrongAnswers,
    scorePercent: scorePercent ?? this.scorePercent,
    timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
    startedAt: startedAt ?? this.startedAt,
    submittedAt: submittedAt ?? this.submittedAt,
    xpAwarded: xpAwarded.present ? xpAwarded.value : this.xpAwarded,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  QuizAttempt copyWithCompanion(QuizAttemptsCompanion data) {
    return QuizAttempt(
      id: data.id.present ? data.id.value : this.id,
      quizId: data.quizId.present ? data.quizId.value : this.quizId,
      totalQuestions: data.totalQuestions.present
          ? data.totalQuestions.value
          : this.totalQuestions,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      wrongAnswers: data.wrongAnswers.present
          ? data.wrongAnswers.value
          : this.wrongAnswers,
      scorePercent: data.scorePercent.present
          ? data.scorePercent.value
          : this.scorePercent,
      timeTakenSeconds: data.timeTakenSeconds.present
          ? data.timeTakenSeconds.value
          : this.timeTakenSeconds,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
      xpAwarded: data.xpAwarded.present ? data.xpAwarded.value : this.xpAwarded,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttempt(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('wrongAnswers: $wrongAnswers, ')
          ..write('scorePercent: $scorePercent, ')
          ..write('timeTakenSeconds: $timeTakenSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('xpAwarded: $xpAwarded, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    quizId,
    totalQuestions,
    correctAnswers,
    wrongAnswers,
    scorePercent,
    timeTakenSeconds,
    startedAt,
    submittedAt,
    xpAwarded,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttempt &&
          other.id == this.id &&
          other.quizId == this.quizId &&
          other.totalQuestions == this.totalQuestions &&
          other.correctAnswers == this.correctAnswers &&
          other.wrongAnswers == this.wrongAnswers &&
          other.scorePercent == this.scorePercent &&
          other.timeTakenSeconds == this.timeTakenSeconds &&
          other.startedAt == this.startedAt &&
          other.submittedAt == this.submittedAt &&
          other.xpAwarded == this.xpAwarded &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class QuizAttemptsCompanion extends UpdateCompanion<QuizAttempt> {
  final Value<String> id;
  final Value<String> quizId;
  final Value<int> totalQuestions;
  final Value<int> correctAnswers;
  final Value<int> wrongAnswers;
  final Value<int> scorePercent;
  final Value<int> timeTakenSeconds;
  final Value<int> startedAt;
  final Value<int> submittedAt;
  final Value<int?> xpAwarded;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const QuizAttemptsCompanion({
    this.id = const Value.absent(),
    this.quizId = const Value.absent(),
    this.totalQuestions = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.wrongAnswers = const Value.absent(),
    this.scorePercent = const Value.absent(),
    this.timeTakenSeconds = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.xpAwarded = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuizAttemptsCompanion.insert({
    required String id,
    required String quizId,
    required int totalQuestions,
    required int correctAnswers,
    required int wrongAnswers,
    required int scorePercent,
    required int timeTakenSeconds,
    required int startedAt,
    required int submittedAt,
    this.xpAwarded = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quizId = Value(quizId),
       totalQuestions = Value(totalQuestions),
       correctAnswers = Value(correctAnswers),
       wrongAnswers = Value(wrongAnswers),
       scorePercent = Value(scorePercent),
       timeTakenSeconds = Value(timeTakenSeconds),
       startedAt = Value(startedAt),
       submittedAt = Value(submittedAt);
  static Insertable<QuizAttempt> custom({
    Expression<String>? id,
    Expression<String>? quizId,
    Expression<int>? totalQuestions,
    Expression<int>? correctAnswers,
    Expression<int>? wrongAnswers,
    Expression<int>? scorePercent,
    Expression<int>? timeTakenSeconds,
    Expression<int>? startedAt,
    Expression<int>? submittedAt,
    Expression<int>? xpAwarded,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quizId != null) 'quiz_id': quizId,
      if (totalQuestions != null) 'total_questions': totalQuestions,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (wrongAnswers != null) 'wrong_answers': wrongAnswers,
      if (scorePercent != null) 'score_percent': scorePercent,
      if (timeTakenSeconds != null) 'time_taken_seconds': timeTakenSeconds,
      if (startedAt != null) 'started_at': startedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (xpAwarded != null) 'xp_awarded': xpAwarded,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuizAttemptsCompanion copyWith({
    Value<String>? id,
    Value<String>? quizId,
    Value<int>? totalQuestions,
    Value<int>? correctAnswers,
    Value<int>? wrongAnswers,
    Value<int>? scorePercent,
    Value<int>? timeTakenSeconds,
    Value<int>? startedAt,
    Value<int>? submittedAt,
    Value<int?>? xpAwarded,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return QuizAttemptsCompanion(
      id: id ?? this.id,
      quizId: quizId ?? this.quizId,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      wrongAnswers: wrongAnswers ?? this.wrongAnswers,
      scorePercent: scorePercent ?? this.scorePercent,
      timeTakenSeconds: timeTakenSeconds ?? this.timeTakenSeconds,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      xpAwarded: xpAwarded ?? this.xpAwarded,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (quizId.present) {
      map['quiz_id'] = Variable<String>(quizId.value);
    }
    if (totalQuestions.present) {
      map['total_questions'] = Variable<int>(totalQuestions.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (wrongAnswers.present) {
      map['wrong_answers'] = Variable<int>(wrongAnswers.value);
    }
    if (scorePercent.present) {
      map['score_percent'] = Variable<int>(scorePercent.value);
    }
    if (timeTakenSeconds.present) {
      map['time_taken_seconds'] = Variable<int>(timeTakenSeconds.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<int>(submittedAt.value);
    }
    if (xpAwarded.present) {
      map['xp_awarded'] = Variable<int>(xpAwarded.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptsCompanion(')
          ..write('id: $id, ')
          ..write('quizId: $quizId, ')
          ..write('totalQuestions: $totalQuestions, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('wrongAnswers: $wrongAnswers, ')
          ..write('scorePercent: $scorePercent, ')
          ..write('timeTakenSeconds: $timeTakenSeconds, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('xpAwarded: $xpAwarded, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class QuizAttemptAnswers extends Table
    with TableInfo<QuizAttemptAnswers, QuizAttemptAnswer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  QuizAttemptAnswers(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES quiz_attempts(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES quiz_questions(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _selectedOptionIndexMeta =
      const VerificationMeta('selectedOptionIndex');
  late final GeneratedColumn<int> selectedOptionIndex = GeneratedColumn<int>(
    'selected_option_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (selected_option_index IS NULL OR selected_option_index BETWEEN 0 AND 3)',
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  late final GeneratedColumn<int> isCorrect = GeneratedColumn<int>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (is_correct IN (0, 1))',
  );
  static const VerificationMeta _answeredAtMeta = const VerificationMeta(
    'answeredAt',
  );
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
    'answered_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    attemptId,
    questionId,
    selectedOptionIndex,
    isCorrect,
    answeredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quiz_attempt_answers';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuizAttemptAnswer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('selected_option_index')) {
      context.handle(
        _selectedOptionIndexMeta,
        selectedOptionIndex.isAcceptableOrUnknown(
          data['selected_option_index']!,
          _selectedOptionIndexMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('answered_at')) {
      context.handle(
        _answeredAtMeta,
        answeredAt.isAcceptableOrUnknown(data['answered_at']!, _answeredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {attemptId, questionId};
  @override
  QuizAttemptAnswer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuizAttemptAnswer(
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      )!,
      selectedOptionIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_option_index'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_correct'],
      )!,
      answeredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}answered_at'],
      ),
    );
  }

  @override
  QuizAttemptAnswers createAlias(String alias) {
    return QuizAttemptAnswers(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(attempt_id, question_id)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class QuizAttemptAnswer extends DataClass
    implements Insertable<QuizAttemptAnswer> {
  final String attemptId;
  final String questionId;
  final int? selectedOptionIndex;
  final int isCorrect;
  final int? answeredAt;
  const QuizAttemptAnswer({
    required this.attemptId,
    required this.questionId,
    this.selectedOptionIndex,
    required this.isCorrect,
    this.answeredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attempt_id'] = Variable<String>(attemptId);
    map['question_id'] = Variable<String>(questionId);
    if (!nullToAbsent || selectedOptionIndex != null) {
      map['selected_option_index'] = Variable<int>(selectedOptionIndex);
    }
    map['is_correct'] = Variable<int>(isCorrect);
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<int>(answeredAt);
    }
    return map;
  }

  QuizAttemptAnswersCompanion toCompanion(bool nullToAbsent) {
    return QuizAttemptAnswersCompanion(
      attemptId: Value(attemptId),
      questionId: Value(questionId),
      selectedOptionIndex: selectedOptionIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedOptionIndex),
      isCorrect: Value(isCorrect),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
    );
  }

  factory QuizAttemptAnswer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuizAttemptAnswer(
      attemptId: serializer.fromJson<String>(json['attempt_id']),
      questionId: serializer.fromJson<String>(json['question_id']),
      selectedOptionIndex: serializer.fromJson<int?>(
        json['selected_option_index'],
      ),
      isCorrect: serializer.fromJson<int>(json['is_correct']),
      answeredAt: serializer.fromJson<int?>(json['answered_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attempt_id': serializer.toJson<String>(attemptId),
      'question_id': serializer.toJson<String>(questionId),
      'selected_option_index': serializer.toJson<int?>(selectedOptionIndex),
      'is_correct': serializer.toJson<int>(isCorrect),
      'answered_at': serializer.toJson<int?>(answeredAt),
    };
  }

  QuizAttemptAnswer copyWith({
    String? attemptId,
    String? questionId,
    Value<int?> selectedOptionIndex = const Value.absent(),
    int? isCorrect,
    Value<int?> answeredAt = const Value.absent(),
  }) => QuizAttemptAnswer(
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId ?? this.questionId,
    selectedOptionIndex: selectedOptionIndex.present
        ? selectedOptionIndex.value
        : this.selectedOptionIndex,
    isCorrect: isCorrect ?? this.isCorrect,
    answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
  );
  QuizAttemptAnswer copyWithCompanion(QuizAttemptAnswersCompanion data) {
    return QuizAttemptAnswer(
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      selectedOptionIndex: data.selectedOptionIndex.present
          ? data.selectedOptionIndex.value
          : this.selectedOptionIndex,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      answeredAt: data.answeredAt.present
          ? data.answeredAt.value
          : this.answeredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptAnswer(')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOptionIndex: $selectedOptionIndex, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attemptId,
    questionId,
    selectedOptionIndex,
    isCorrect,
    answeredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuizAttemptAnswer &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.selectedOptionIndex == this.selectedOptionIndex &&
          other.isCorrect == this.isCorrect &&
          other.answeredAt == this.answeredAt);
}

class QuizAttemptAnswersCompanion extends UpdateCompanion<QuizAttemptAnswer> {
  final Value<String> attemptId;
  final Value<String> questionId;
  final Value<int?> selectedOptionIndex;
  final Value<int> isCorrect;
  final Value<int?> answeredAt;
  const QuizAttemptAnswersCompanion({
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.selectedOptionIndex = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.answeredAt = const Value.absent(),
  });
  QuizAttemptAnswersCompanion.insert({
    required String attemptId,
    required String questionId,
    this.selectedOptionIndex = const Value.absent(),
    required int isCorrect,
    this.answeredAt = const Value.absent(),
  }) : attemptId = Value(attemptId),
       questionId = Value(questionId),
       isCorrect = Value(isCorrect);
  static Insertable<QuizAttemptAnswer> custom({
    Expression<String>? attemptId,
    Expression<String>? questionId,
    Expression<int>? selectedOptionIndex,
    Expression<int>? isCorrect,
    Expression<int>? answeredAt,
  }) {
    return RawValuesInsertable({
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (selectedOptionIndex != null)
        'selected_option_index': selectedOptionIndex,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (answeredAt != null) 'answered_at': answeredAt,
    });
  }

  QuizAttemptAnswersCompanion copyWith({
    Value<String>? attemptId,
    Value<String>? questionId,
    Value<int?>? selectedOptionIndex,
    Value<int>? isCorrect,
    Value<int?>? answeredAt,
  }) {
    return QuizAttemptAnswersCompanion(
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      answeredAt: answeredAt ?? this.answeredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (selectedOptionIndex.present) {
      map['selected_option_index'] = Variable<int>(selectedOptionIndex.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<int>(isCorrect.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuizAttemptAnswersCompanion(')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('selectedOptionIndex: $selectedOptionIndex, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('answeredAt: $answeredAt')
          ..write(')'))
        .toString();
  }
}

class UserQuests extends Table with TableInfo<UserQuests, UserQuest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserQuests(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _questDefinitionIdMeta = const VerificationMeta(
    'questDefinitionId',
  );
  late final GeneratedColumn<String> questDefinitionId =
      GeneratedColumn<String>(
        'quest_definition_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL REFERENCES quest_definitions(id)ON DELETE CASCADE',
      );
  static const VerificationMeta _periodStartMeta = const VerificationMeta(
    'periodStart',
  );
  late final GeneratedColumn<String> periodStart = GeneratedColumn<String>(
    'period_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _currentValueMeta = const VerificationMeta(
    'currentValue',
  );
  late final GeneratedColumn<int> currentValue = GeneratedColumn<int>(
    'current_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _targetValueMeta = const VerificationMeta(
    'targetValue',
  );
  late final GeneratedColumn<int> targetValue = GeneratedColumn<int>(
    'target_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _xpRewardMeta = const VerificationMeta(
    'xpReward',
  );
  late final GeneratedColumn<int> xpReward = GeneratedColumn<int>(
    'xp_reward',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isClaimedMeta = const VerificationMeta(
    'isClaimed',
  );
  late final GeneratedColumn<int> isClaimed = GeneratedColumn<int>(
    'is_claimed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_claimed IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _claimedAtMeta = const VerificationMeta(
    'claimedAt',
  );
  late final GeneratedColumn<int> claimedAt = GeneratedColumn<int>(
    'claimed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questDefinitionId,
    periodStart,
    currentValue,
    targetValue,
    xpReward,
    completedAt,
    isClaimed,
    claimedAt,
    version,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserQuest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('quest_definition_id')) {
      context.handle(
        _questDefinitionIdMeta,
        questDefinitionId.isAcceptableOrUnknown(
          data['quest_definition_id']!,
          _questDefinitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questDefinitionIdMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
        _periodStartMeta,
        periodStart.isAcceptableOrUnknown(
          data['period_start']!,
          _periodStartMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('current_value')) {
      context.handle(
        _currentValueMeta,
        currentValue.isAcceptableOrUnknown(
          data['current_value']!,
          _currentValueMeta,
        ),
      );
    }
    if (data.containsKey('target_value')) {
      context.handle(
        _targetValueMeta,
        targetValue.isAcceptableOrUnknown(
          data['target_value']!,
          _targetValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetValueMeta);
    }
    if (data.containsKey('xp_reward')) {
      context.handle(
        _xpRewardMeta,
        xpReward.isAcceptableOrUnknown(data['xp_reward']!, _xpRewardMeta),
      );
    } else if (isInserting) {
      context.missing(_xpRewardMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_claimed')) {
      context.handle(
        _isClaimedMeta,
        isClaimed.isAcceptableOrUnknown(data['is_claimed']!, _isClaimedMeta),
      );
    }
    if (data.containsKey('claimed_at')) {
      context.handle(
        _claimedAtMeta,
        claimedAt.isAcceptableOrUnknown(data['claimed_at']!, _claimedAtMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {questDefinitionId, periodStart},
  ];
  @override
  UserQuest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserQuest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      questDefinitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quest_definition_id'],
      )!,
      periodStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_start'],
      )!,
      currentValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_value'],
      )!,
      targetValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_value'],
      )!,
      xpReward: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_reward'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      isClaimed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_claimed'],
      )!,
      claimedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}claimed_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserQuests createAlias(String alias) {
    return UserQuests(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'UNIQUE(quest_definition_id, period_start)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class UserQuest extends DataClass implements Insertable<UserQuest> {
  final String id;
  final String questDefinitionId;
  final String periodStart;

  /// 'YYYY-MM-DD'
  final int currentValue;
  final int targetValue;
  final int xpReward;
  final int? completedAt;
  final int isClaimed;
  final int? claimedAt;
  final int version;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserQuest({
    required this.id,
    required this.questDefinitionId,
    required this.periodStart,
    required this.currentValue,
    required this.targetValue,
    required this.xpReward,
    this.completedAt,
    required this.isClaimed,
    this.claimedAt,
    required this.version,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['quest_definition_id'] = Variable<String>(questDefinitionId);
    map['period_start'] = Variable<String>(periodStart);
    map['current_value'] = Variable<int>(currentValue);
    map['target_value'] = Variable<int>(targetValue);
    map['xp_reward'] = Variable<int>(xpReward);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['is_claimed'] = Variable<int>(isClaimed);
    if (!nullToAbsent || claimedAt != null) {
      map['claimed_at'] = Variable<int>(claimedAt);
    }
    map['version'] = Variable<int>(version);
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserQuestsCompanion toCompanion(bool nullToAbsent) {
    return UserQuestsCompanion(
      id: Value(id),
      questDefinitionId: Value(questDefinitionId),
      periodStart: Value(periodStart),
      currentValue: Value(currentValue),
      targetValue: Value(targetValue),
      xpReward: Value(xpReward),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isClaimed: Value(isClaimed),
      claimedAt: claimedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(claimedAt),
      version: Value(version),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserQuest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserQuest(
      id: serializer.fromJson<String>(json['id']),
      questDefinitionId: serializer.fromJson<String>(
        json['quest_definition_id'],
      ),
      periodStart: serializer.fromJson<String>(json['period_start']),
      currentValue: serializer.fromJson<int>(json['current_value']),
      targetValue: serializer.fromJson<int>(json['target_value']),
      xpReward: serializer.fromJson<int>(json['xp_reward']),
      completedAt: serializer.fromJson<int?>(json['completed_at']),
      isClaimed: serializer.fromJson<int>(json['is_claimed']),
      claimedAt: serializer.fromJson<int?>(json['claimed_at']),
      version: serializer.fromJson<int>(json['version']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'quest_definition_id': serializer.toJson<String>(questDefinitionId),
      'period_start': serializer.toJson<String>(periodStart),
      'current_value': serializer.toJson<int>(currentValue),
      'target_value': serializer.toJson<int>(targetValue),
      'xp_reward': serializer.toJson<int>(xpReward),
      'completed_at': serializer.toJson<int?>(completedAt),
      'is_claimed': serializer.toJson<int>(isClaimed),
      'claimed_at': serializer.toJson<int?>(claimedAt),
      'version': serializer.toJson<int>(version),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserQuest copyWith({
    String? id,
    String? questDefinitionId,
    String? periodStart,
    int? currentValue,
    int? targetValue,
    int? xpReward,
    Value<int?> completedAt = const Value.absent(),
    int? isClaimed,
    Value<int?> claimedAt = const Value.absent(),
    int? version,
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserQuest(
    id: id ?? this.id,
    questDefinitionId: questDefinitionId ?? this.questDefinitionId,
    periodStart: periodStart ?? this.periodStart,
    currentValue: currentValue ?? this.currentValue,
    targetValue: targetValue ?? this.targetValue,
    xpReward: xpReward ?? this.xpReward,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    isClaimed: isClaimed ?? this.isClaimed,
    claimedAt: claimedAt.present ? claimedAt.value : this.claimedAt,
    version: version ?? this.version,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserQuest copyWithCompanion(UserQuestsCompanion data) {
    return UserQuest(
      id: data.id.present ? data.id.value : this.id,
      questDefinitionId: data.questDefinitionId.present
          ? data.questDefinitionId.value
          : this.questDefinitionId,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      currentValue: data.currentValue.present
          ? data.currentValue.value
          : this.currentValue,
      targetValue: data.targetValue.present
          ? data.targetValue.value
          : this.targetValue,
      xpReward: data.xpReward.present ? data.xpReward.value : this.xpReward,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      isClaimed: data.isClaimed.present ? data.isClaimed.value : this.isClaimed,
      claimedAt: data.claimedAt.present ? data.claimedAt.value : this.claimedAt,
      version: data.version.present ? data.version.value : this.version,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserQuest(')
          ..write('id: $id, ')
          ..write('questDefinitionId: $questDefinitionId, ')
          ..write('periodStart: $periodStart, ')
          ..write('currentValue: $currentValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('xpReward: $xpReward, ')
          ..write('completedAt: $completedAt, ')
          ..write('isClaimed: $isClaimed, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    questDefinitionId,
    periodStart,
    currentValue,
    targetValue,
    xpReward,
    completedAt,
    isClaimed,
    claimedAt,
    version,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserQuest &&
          other.id == this.id &&
          other.questDefinitionId == this.questDefinitionId &&
          other.periodStart == this.periodStart &&
          other.currentValue == this.currentValue &&
          other.targetValue == this.targetValue &&
          other.xpReward == this.xpReward &&
          other.completedAt == this.completedAt &&
          other.isClaimed == this.isClaimed &&
          other.claimedAt == this.claimedAt &&
          other.version == this.version &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserQuestsCompanion extends UpdateCompanion<UserQuest> {
  final Value<String> id;
  final Value<String> questDefinitionId;
  final Value<String> periodStart;
  final Value<int> currentValue;
  final Value<int> targetValue;
  final Value<int> xpReward;
  final Value<int?> completedAt;
  final Value<int> isClaimed;
  final Value<int?> claimedAt;
  final Value<int> version;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserQuestsCompanion({
    this.id = const Value.absent(),
    this.questDefinitionId = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.currentValue = const Value.absent(),
    this.targetValue = const Value.absent(),
    this.xpReward = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isClaimed = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserQuestsCompanion.insert({
    required String id,
    required String questDefinitionId,
    required String periodStart,
    this.currentValue = const Value.absent(),
    required int targetValue,
    required int xpReward,
    this.completedAt = const Value.absent(),
    this.isClaimed = const Value.absent(),
    this.claimedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       questDefinitionId = Value(questDefinitionId),
       periodStart = Value(periodStart),
       targetValue = Value(targetValue),
       xpReward = Value(xpReward);
  static Insertable<UserQuest> custom({
    Expression<String>? id,
    Expression<String>? questDefinitionId,
    Expression<String>? periodStart,
    Expression<int>? currentValue,
    Expression<int>? targetValue,
    Expression<int>? xpReward,
    Expression<int>? completedAt,
    Expression<int>? isClaimed,
    Expression<int>? claimedAt,
    Expression<int>? version,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questDefinitionId != null) 'quest_definition_id': questDefinitionId,
      if (periodStart != null) 'period_start': periodStart,
      if (currentValue != null) 'current_value': currentValue,
      if (targetValue != null) 'target_value': targetValue,
      if (xpReward != null) 'xp_reward': xpReward,
      if (completedAt != null) 'completed_at': completedAt,
      if (isClaimed != null) 'is_claimed': isClaimed,
      if (claimedAt != null) 'claimed_at': claimedAt,
      if (version != null) 'version': version,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserQuestsCompanion copyWith({
    Value<String>? id,
    Value<String>? questDefinitionId,
    Value<String>? periodStart,
    Value<int>? currentValue,
    Value<int>? targetValue,
    Value<int>? xpReward,
    Value<int?>? completedAt,
    Value<int>? isClaimed,
    Value<int?>? claimedAt,
    Value<int>? version,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserQuestsCompanion(
      id: id ?? this.id,
      questDefinitionId: questDefinitionId ?? this.questDefinitionId,
      periodStart: periodStart ?? this.periodStart,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      xpReward: xpReward ?? this.xpReward,
      completedAt: completedAt ?? this.completedAt,
      isClaimed: isClaimed ?? this.isClaimed,
      claimedAt: claimedAt ?? this.claimedAt,
      version: version ?? this.version,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (questDefinitionId.present) {
      map['quest_definition_id'] = Variable<String>(questDefinitionId.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<String>(periodStart.value);
    }
    if (currentValue.present) {
      map['current_value'] = Variable<int>(currentValue.value);
    }
    if (targetValue.present) {
      map['target_value'] = Variable<int>(targetValue.value);
    }
    if (xpReward.present) {
      map['xp_reward'] = Variable<int>(xpReward.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (isClaimed.present) {
      map['is_claimed'] = Variable<int>(isClaimed.value);
    }
    if (claimedAt.present) {
      map['claimed_at'] = Variable<int>(claimedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserQuestsCompanion(')
          ..write('id: $id, ')
          ..write('questDefinitionId: $questDefinitionId, ')
          ..write('periodStart: $periodStart, ')
          ..write('currentValue: $currentValue, ')
          ..write('targetValue: $targetValue, ')
          ..write('xpReward: $xpReward, ')
          ..write('completedAt: $completedAt, ')
          ..write('isClaimed: $isClaimed, ')
          ..write('claimedAt: $claimedAt, ')
          ..write('version: $version, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class UserInventories extends Table
    with TableInfo<UserInventories, UserInventory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  UserInventories(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _rewardItemIdMeta = const VerificationMeta(
    'rewardItemId',
  );
  late final GeneratedColumn<String> rewardItemId = GeneratedColumn<String>(
    'reward_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL UNIQUE REFERENCES reward_items(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _isEquippedMeta = const VerificationMeta(
    'isEquipped',
  );
  late final GeneratedColumn<int> isEquipped = GeneratedColumn<int>(
    'is_equipped',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_equipped IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _unlockedAtMeta = const VerificationMeta(
    'unlockedAt',
  );
  late final GeneratedColumn<int> unlockedAt = GeneratedColumn<int>(
    'unlocked_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _clientUpdatedAtMeta = const VerificationMeta(
    'clientUpdatedAt',
  );
  late final GeneratedColumn<int> clientUpdatedAt = GeneratedColumn<int>(
    'client_updated_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'synced\' CHECK (sync_status IN (\'synced\', \'pending_create\', \'pending_update\', \'pending_delete\'))',
    defaultValue: const CustomExpression('\'synced\''),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rewardItemId,
    isEquipped,
    unlockedAt,
    version,
    clientUpdatedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_inventories';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserInventory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('reward_item_id')) {
      context.handle(
        _rewardItemIdMeta,
        rewardItemId.isAcceptableOrUnknown(
          data['reward_item_id']!,
          _rewardItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_rewardItemIdMeta);
    }
    if (data.containsKey('is_equipped')) {
      context.handle(
        _isEquippedMeta,
        isEquipped.isAcceptableOrUnknown(data['is_equipped']!, _isEquippedMeta),
      );
    }
    if (data.containsKey('unlocked_at')) {
      context.handle(
        _unlockedAtMeta,
        unlockedAt.isAcceptableOrUnknown(data['unlocked_at']!, _unlockedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_unlockedAtMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('client_updated_at')) {
      context.handle(
        _clientUpdatedAtMeta,
        clientUpdatedAt.isAcceptableOrUnknown(
          data['client_updated_at']!,
          _clientUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserInventory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserInventory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      rewardItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reward_item_id'],
      )!,
      isEquipped: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_equipped'],
      )!,
      unlockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unlocked_at'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      clientUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}client_updated_at'],
      ),
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  UserInventories createAlias(String alias) {
    return UserInventories(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class UserInventory extends DataClass implements Insertable<UserInventory> {
  final String id;
  final String rewardItemId;
  final int isEquipped;
  final int unlockedAt;
  final int version;
  final int? clientUpdatedAt;
  final int isDirty;
  final String syncStatus;
  final int? lastSyncedAt;
  const UserInventory({
    required this.id,
    required this.rewardItemId,
    required this.isEquipped,
    required this.unlockedAt,
    required this.version,
    this.clientUpdatedAt,
    required this.isDirty,
    required this.syncStatus,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['reward_item_id'] = Variable<String>(rewardItemId);
    map['is_equipped'] = Variable<int>(isEquipped);
    map['unlocked_at'] = Variable<int>(unlockedAt);
    map['version'] = Variable<int>(version);
    if (!nullToAbsent || clientUpdatedAt != null) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt);
    }
    map['is_dirty'] = Variable<int>(isDirty);
    map['sync_status'] = Variable<String>(syncStatus);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  UserInventoriesCompanion toCompanion(bool nullToAbsent) {
    return UserInventoriesCompanion(
      id: Value(id),
      rewardItemId: Value(rewardItemId),
      isEquipped: Value(isEquipped),
      unlockedAt: Value(unlockedAt),
      version: Value(version),
      clientUpdatedAt: clientUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(clientUpdatedAt),
      isDirty: Value(isDirty),
      syncStatus: Value(syncStatus),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory UserInventory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserInventory(
      id: serializer.fromJson<String>(json['id']),
      rewardItemId: serializer.fromJson<String>(json['reward_item_id']),
      isEquipped: serializer.fromJson<int>(json['is_equipped']),
      unlockedAt: serializer.fromJson<int>(json['unlocked_at']),
      version: serializer.fromJson<int>(json['version']),
      clientUpdatedAt: serializer.fromJson<int?>(json['client_updated_at']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      syncStatus: serializer.fromJson<String>(json['sync_status']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'reward_item_id': serializer.toJson<String>(rewardItemId),
      'is_equipped': serializer.toJson<int>(isEquipped),
      'unlocked_at': serializer.toJson<int>(unlockedAt),
      'version': serializer.toJson<int>(version),
      'client_updated_at': serializer.toJson<int?>(clientUpdatedAt),
      'is_dirty': serializer.toJson<int>(isDirty),
      'sync_status': serializer.toJson<String>(syncStatus),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  UserInventory copyWith({
    String? id,
    String? rewardItemId,
    int? isEquipped,
    int? unlockedAt,
    int? version,
    Value<int?> clientUpdatedAt = const Value.absent(),
    int? isDirty,
    String? syncStatus,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => UserInventory(
    id: id ?? this.id,
    rewardItemId: rewardItemId ?? this.rewardItemId,
    isEquipped: isEquipped ?? this.isEquipped,
    unlockedAt: unlockedAt ?? this.unlockedAt,
    version: version ?? this.version,
    clientUpdatedAt: clientUpdatedAt.present
        ? clientUpdatedAt.value
        : this.clientUpdatedAt,
    isDirty: isDirty ?? this.isDirty,
    syncStatus: syncStatus ?? this.syncStatus,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  UserInventory copyWithCompanion(UserInventoriesCompanion data) {
    return UserInventory(
      id: data.id.present ? data.id.value : this.id,
      rewardItemId: data.rewardItemId.present
          ? data.rewardItemId.value
          : this.rewardItemId,
      isEquipped: data.isEquipped.present
          ? data.isEquipped.value
          : this.isEquipped,
      unlockedAt: data.unlockedAt.present
          ? data.unlockedAt.value
          : this.unlockedAt,
      version: data.version.present ? data.version.value : this.version,
      clientUpdatedAt: data.clientUpdatedAt.present
          ? data.clientUpdatedAt.value
          : this.clientUpdatedAt,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserInventory(')
          ..write('id: $id, ')
          ..write('rewardItemId: $rewardItemId, ')
          ..write('isEquipped: $isEquipped, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rewardItemId,
    isEquipped,
    unlockedAt,
    version,
    clientUpdatedAt,
    isDirty,
    syncStatus,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserInventory &&
          other.id == this.id &&
          other.rewardItemId == this.rewardItemId &&
          other.isEquipped == this.isEquipped &&
          other.unlockedAt == this.unlockedAt &&
          other.version == this.version &&
          other.clientUpdatedAt == this.clientUpdatedAt &&
          other.isDirty == this.isDirty &&
          other.syncStatus == this.syncStatus &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class UserInventoriesCompanion extends UpdateCompanion<UserInventory> {
  final Value<String> id;
  final Value<String> rewardItemId;
  final Value<int> isEquipped;
  final Value<int> unlockedAt;
  final Value<int> version;
  final Value<int?> clientUpdatedAt;
  final Value<int> isDirty;
  final Value<String> syncStatus;
  final Value<int?> lastSyncedAt;
  final Value<int> rowid;
  const UserInventoriesCompanion({
    this.id = const Value.absent(),
    this.rewardItemId = const Value.absent(),
    this.isEquipped = const Value.absent(),
    this.unlockedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserInventoriesCompanion.insert({
    required String id,
    required String rewardItemId,
    this.isEquipped = const Value.absent(),
    required int unlockedAt,
    this.version = const Value.absent(),
    this.clientUpdatedAt = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       rewardItemId = Value(rewardItemId),
       unlockedAt = Value(unlockedAt);
  static Insertable<UserInventory> custom({
    Expression<String>? id,
    Expression<String>? rewardItemId,
    Expression<int>? isEquipped,
    Expression<int>? unlockedAt,
    Expression<int>? version,
    Expression<int>? clientUpdatedAt,
    Expression<int>? isDirty,
    Expression<String>? syncStatus,
    Expression<int>? lastSyncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rewardItemId != null) 'reward_item_id': rewardItemId,
      if (isEquipped != null) 'is_equipped': isEquipped,
      if (unlockedAt != null) 'unlocked_at': unlockedAt,
      if (version != null) 'version': version,
      if (clientUpdatedAt != null) 'client_updated_at': clientUpdatedAt,
      if (isDirty != null) 'is_dirty': isDirty,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserInventoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? rewardItemId,
    Value<int>? isEquipped,
    Value<int>? unlockedAt,
    Value<int>? version,
    Value<int?>? clientUpdatedAt,
    Value<int>? isDirty,
    Value<String>? syncStatus,
    Value<int?>? lastSyncedAt,
    Value<int>? rowid,
  }) {
    return UserInventoriesCompanion(
      id: id ?? this.id,
      rewardItemId: rewardItemId ?? this.rewardItemId,
      isEquipped: isEquipped ?? this.isEquipped,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      version: version ?? this.version,
      clientUpdatedAt: clientUpdatedAt ?? this.clientUpdatedAt,
      isDirty: isDirty ?? this.isDirty,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rewardItemId.present) {
      map['reward_item_id'] = Variable<String>(rewardItemId.value);
    }
    if (isEquipped.present) {
      map['is_equipped'] = Variable<int>(isEquipped.value);
    }
    if (unlockedAt.present) {
      map['unlocked_at'] = Variable<int>(unlockedAt.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (clientUpdatedAt.present) {
      map['client_updated_at'] = Variable<int>(clientUpdatedAt.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserInventoriesCompanion(')
          ..write('id: $id, ')
          ..write('rewardItemId: $rewardItemId, ')
          ..write('isEquipped: $isEquipped, ')
          ..write('unlockedAt: $unlockedAt, ')
          ..write('version: $version, ')
          ..write('clientUpdatedAt: $clientUpdatedAt, ')
          ..write('isDirty: $isDirty, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('lastSyncedAt: $lastSyncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DailyStatistics extends Table
    with TableInfo<DailyStatistics, DailyStatistic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DailyStatistics(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _statDateMeta = const VerificationMeta(
    'statDate',
  );
  late final GeneratedColumn<String> statDate = GeneratedColumn<String>(
    'stat_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _wordsLearnedMeta = const VerificationMeta(
    'wordsLearned',
  );
  late final GeneratedColumn<int> wordsLearned = GeneratedColumn<int>(
    'words_learned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _cardsReviewedMeta = const VerificationMeta(
    'cardsReviewed',
  );
  late final GeneratedColumn<int> cardsReviewed = GeneratedColumn<int>(
    'cards_reviewed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _xpGainedMeta = const VerificationMeta(
    'xpGained',
  );
  late final GeneratedColumn<int> xpGained = GeneratedColumn<int>(
    'xp_gained',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lessonsCompletedMeta = const VerificationMeta(
    'lessonsCompleted',
  );
  late final GeneratedColumn<int> lessonsCompleted = GeneratedColumn<int>(
    'lessons_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _quizzesCompletedMeta = const VerificationMeta(
    'quizzesCompleted',
  );
  late final GeneratedColumn<int> quizzesCompleted = GeneratedColumn<int>(
    'quizzes_completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _correctAnswersMeta = const VerificationMeta(
    'correctAnswers',
  );
  late final GeneratedColumn<int> correctAnswers = GeneratedColumn<int>(
    'correct_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _totalAnswersMeta = const VerificationMeta(
    'totalAnswers',
  );
  late final GeneratedColumn<int> totalAnswers = GeneratedColumn<int>(
    'total_answers',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _studySecondsMeta = const VerificationMeta(
    'studySeconds',
  );
  late final GeneratedColumn<int> studySeconds = GeneratedColumn<int>(
    'study_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _isDirtyMeta = const VerificationMeta(
    'isDirty',
  );
  late final GeneratedColumn<int> isDirty = GeneratedColumn<int>(
    'is_dirty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0 CHECK (is_dirty IN (0, 1))',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastSyncedAtMeta = const VerificationMeta(
    'lastSyncedAt',
  );
  late final GeneratedColumn<int> lastSyncedAt = GeneratedColumn<int>(
    'last_synced_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    statDate,
    id,
    wordsLearned,
    cardsReviewed,
    xpGained,
    lessonsCompleted,
    quizzesCompleted,
    correctAnswers,
    totalAnswers,
    studySeconds,
    isDirty,
    lastSyncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_statistics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyStatistic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('stat_date')) {
      context.handle(
        _statDateMeta,
        statDate.isAcceptableOrUnknown(data['stat_date']!, _statDateMeta),
      );
    } else if (isInserting) {
      context.missing(_statDateMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('words_learned')) {
      context.handle(
        _wordsLearnedMeta,
        wordsLearned.isAcceptableOrUnknown(
          data['words_learned']!,
          _wordsLearnedMeta,
        ),
      );
    }
    if (data.containsKey('cards_reviewed')) {
      context.handle(
        _cardsReviewedMeta,
        cardsReviewed.isAcceptableOrUnknown(
          data['cards_reviewed']!,
          _cardsReviewedMeta,
        ),
      );
    }
    if (data.containsKey('xp_gained')) {
      context.handle(
        _xpGainedMeta,
        xpGained.isAcceptableOrUnknown(data['xp_gained']!, _xpGainedMeta),
      );
    }
    if (data.containsKey('lessons_completed')) {
      context.handle(
        _lessonsCompletedMeta,
        lessonsCompleted.isAcceptableOrUnknown(
          data['lessons_completed']!,
          _lessonsCompletedMeta,
        ),
      );
    }
    if (data.containsKey('quizzes_completed')) {
      context.handle(
        _quizzesCompletedMeta,
        quizzesCompleted.isAcceptableOrUnknown(
          data['quizzes_completed']!,
          _quizzesCompletedMeta,
        ),
      );
    }
    if (data.containsKey('correct_answers')) {
      context.handle(
        _correctAnswersMeta,
        correctAnswers.isAcceptableOrUnknown(
          data['correct_answers']!,
          _correctAnswersMeta,
        ),
      );
    }
    if (data.containsKey('total_answers')) {
      context.handle(
        _totalAnswersMeta,
        totalAnswers.isAcceptableOrUnknown(
          data['total_answers']!,
          _totalAnswersMeta,
        ),
      );
    }
    if (data.containsKey('study_seconds')) {
      context.handle(
        _studySecondsMeta,
        studySeconds.isAcceptableOrUnknown(
          data['study_seconds']!,
          _studySecondsMeta,
        ),
      );
    }
    if (data.containsKey('is_dirty')) {
      context.handle(
        _isDirtyMeta,
        isDirty.isAcceptableOrUnknown(data['is_dirty']!, _isDirtyMeta),
      );
    }
    if (data.containsKey('last_synced_at')) {
      context.handle(
        _lastSyncedAtMeta,
        lastSyncedAt.isAcceptableOrUnknown(
          data['last_synced_at']!,
          _lastSyncedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {statDate};
  @override
  DailyStatistic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyStatistic(
      statDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stat_date'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      wordsLearned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}words_learned'],
      )!,
      cardsReviewed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cards_reviewed'],
      )!,
      xpGained: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp_gained'],
      )!,
      lessonsCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lessons_completed'],
      )!,
      quizzesCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quizzes_completed'],
      )!,
      correctAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_answers'],
      )!,
      totalAnswers: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_answers'],
      )!,
      studySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}study_seconds'],
      )!,
      isDirty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_dirty'],
      )!,
      lastSyncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced_at'],
      ),
    );
  }

  @override
  DailyStatistics createAlias(String alias) {
    return DailyStatistics(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class DailyStatistic extends DataClass implements Insertable<DailyStatistic> {
  final String statDate;

  /// 'YYYY-MM-DD' theo giờ địa phương
  final String? id;

  /// id server, NULL nếu chưa sync
  final int wordsLearned;
  final int cardsReviewed;
  final int xpGained;
  final int lessonsCompleted;
  final int quizzesCompleted;
  final int correctAnswers;
  final int totalAnswers;
  final int studySeconds;
  final int isDirty;
  final int? lastSyncedAt;
  const DailyStatistic({
    required this.statDate,
    this.id,
    required this.wordsLearned,
    required this.cardsReviewed,
    required this.xpGained,
    required this.lessonsCompleted,
    required this.quizzesCompleted,
    required this.correctAnswers,
    required this.totalAnswers,
    required this.studySeconds,
    required this.isDirty,
    this.lastSyncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['stat_date'] = Variable<String>(statDate);
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['words_learned'] = Variable<int>(wordsLearned);
    map['cards_reviewed'] = Variable<int>(cardsReviewed);
    map['xp_gained'] = Variable<int>(xpGained);
    map['lessons_completed'] = Variable<int>(lessonsCompleted);
    map['quizzes_completed'] = Variable<int>(quizzesCompleted);
    map['correct_answers'] = Variable<int>(correctAnswers);
    map['total_answers'] = Variable<int>(totalAnswers);
    map['study_seconds'] = Variable<int>(studySeconds);
    map['is_dirty'] = Variable<int>(isDirty);
    if (!nullToAbsent || lastSyncedAt != null) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt);
    }
    return map;
  }

  DailyStatisticsCompanion toCompanion(bool nullToAbsent) {
    return DailyStatisticsCompanion(
      statDate: Value(statDate),
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      wordsLearned: Value(wordsLearned),
      cardsReviewed: Value(cardsReviewed),
      xpGained: Value(xpGained),
      lessonsCompleted: Value(lessonsCompleted),
      quizzesCompleted: Value(quizzesCompleted),
      correctAnswers: Value(correctAnswers),
      totalAnswers: Value(totalAnswers),
      studySeconds: Value(studySeconds),
      isDirty: Value(isDirty),
      lastSyncedAt: lastSyncedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncedAt),
    );
  }

  factory DailyStatistic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyStatistic(
      statDate: serializer.fromJson<String>(json['stat_date']),
      id: serializer.fromJson<String?>(json['id']),
      wordsLearned: serializer.fromJson<int>(json['words_learned']),
      cardsReviewed: serializer.fromJson<int>(json['cards_reviewed']),
      xpGained: serializer.fromJson<int>(json['xp_gained']),
      lessonsCompleted: serializer.fromJson<int>(json['lessons_completed']),
      quizzesCompleted: serializer.fromJson<int>(json['quizzes_completed']),
      correctAnswers: serializer.fromJson<int>(json['correct_answers']),
      totalAnswers: serializer.fromJson<int>(json['total_answers']),
      studySeconds: serializer.fromJson<int>(json['study_seconds']),
      isDirty: serializer.fromJson<int>(json['is_dirty']),
      lastSyncedAt: serializer.fromJson<int?>(json['last_synced_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'stat_date': serializer.toJson<String>(statDate),
      'id': serializer.toJson<String?>(id),
      'words_learned': serializer.toJson<int>(wordsLearned),
      'cards_reviewed': serializer.toJson<int>(cardsReviewed),
      'xp_gained': serializer.toJson<int>(xpGained),
      'lessons_completed': serializer.toJson<int>(lessonsCompleted),
      'quizzes_completed': serializer.toJson<int>(quizzesCompleted),
      'correct_answers': serializer.toJson<int>(correctAnswers),
      'total_answers': serializer.toJson<int>(totalAnswers),
      'study_seconds': serializer.toJson<int>(studySeconds),
      'is_dirty': serializer.toJson<int>(isDirty),
      'last_synced_at': serializer.toJson<int?>(lastSyncedAt),
    };
  }

  DailyStatistic copyWith({
    String? statDate,
    Value<String?> id = const Value.absent(),
    int? wordsLearned,
    int? cardsReviewed,
    int? xpGained,
    int? lessonsCompleted,
    int? quizzesCompleted,
    int? correctAnswers,
    int? totalAnswers,
    int? studySeconds,
    int? isDirty,
    Value<int?> lastSyncedAt = const Value.absent(),
  }) => DailyStatistic(
    statDate: statDate ?? this.statDate,
    id: id.present ? id.value : this.id,
    wordsLearned: wordsLearned ?? this.wordsLearned,
    cardsReviewed: cardsReviewed ?? this.cardsReviewed,
    xpGained: xpGained ?? this.xpGained,
    lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
    quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
    correctAnswers: correctAnswers ?? this.correctAnswers,
    totalAnswers: totalAnswers ?? this.totalAnswers,
    studySeconds: studySeconds ?? this.studySeconds,
    isDirty: isDirty ?? this.isDirty,
    lastSyncedAt: lastSyncedAt.present ? lastSyncedAt.value : this.lastSyncedAt,
  );
  DailyStatistic copyWithCompanion(DailyStatisticsCompanion data) {
    return DailyStatistic(
      statDate: data.statDate.present ? data.statDate.value : this.statDate,
      id: data.id.present ? data.id.value : this.id,
      wordsLearned: data.wordsLearned.present
          ? data.wordsLearned.value
          : this.wordsLearned,
      cardsReviewed: data.cardsReviewed.present
          ? data.cardsReviewed.value
          : this.cardsReviewed,
      xpGained: data.xpGained.present ? data.xpGained.value : this.xpGained,
      lessonsCompleted: data.lessonsCompleted.present
          ? data.lessonsCompleted.value
          : this.lessonsCompleted,
      quizzesCompleted: data.quizzesCompleted.present
          ? data.quizzesCompleted.value
          : this.quizzesCompleted,
      correctAnswers: data.correctAnswers.present
          ? data.correctAnswers.value
          : this.correctAnswers,
      totalAnswers: data.totalAnswers.present
          ? data.totalAnswers.value
          : this.totalAnswers,
      studySeconds: data.studySeconds.present
          ? data.studySeconds.value
          : this.studySeconds,
      isDirty: data.isDirty.present ? data.isDirty.value : this.isDirty,
      lastSyncedAt: data.lastSyncedAt.present
          ? data.lastSyncedAt.value
          : this.lastSyncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatistic(')
          ..write('statDate: $statDate, ')
          ..write('id: $id, ')
          ..write('wordsLearned: $wordsLearned, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('xpGained: $xpGained, ')
          ..write('lessonsCompleted: $lessonsCompleted, ')
          ..write('quizzesCompleted: $quizzesCompleted, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalAnswers: $totalAnswers, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('isDirty: $isDirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    statDate,
    id,
    wordsLearned,
    cardsReviewed,
    xpGained,
    lessonsCompleted,
    quizzesCompleted,
    correctAnswers,
    totalAnswers,
    studySeconds,
    isDirty,
    lastSyncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyStatistic &&
          other.statDate == this.statDate &&
          other.id == this.id &&
          other.wordsLearned == this.wordsLearned &&
          other.cardsReviewed == this.cardsReviewed &&
          other.xpGained == this.xpGained &&
          other.lessonsCompleted == this.lessonsCompleted &&
          other.quizzesCompleted == this.quizzesCompleted &&
          other.correctAnswers == this.correctAnswers &&
          other.totalAnswers == this.totalAnswers &&
          other.studySeconds == this.studySeconds &&
          other.isDirty == this.isDirty &&
          other.lastSyncedAt == this.lastSyncedAt);
}

class DailyStatisticsCompanion extends UpdateCompanion<DailyStatistic> {
  final Value<String> statDate;
  final Value<String?> id;
  final Value<int> wordsLearned;
  final Value<int> cardsReviewed;
  final Value<int> xpGained;
  final Value<int> lessonsCompleted;
  final Value<int> quizzesCompleted;
  final Value<int> correctAnswers;
  final Value<int> totalAnswers;
  final Value<int> studySeconds;
  final Value<int> isDirty;
  final Value<int?> lastSyncedAt;
  const DailyStatisticsCompanion({
    this.statDate = const Value.absent(),
    this.id = const Value.absent(),
    this.wordsLearned = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.xpGained = const Value.absent(),
    this.lessonsCompleted = const Value.absent(),
    this.quizzesCompleted = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalAnswers = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  });
  DailyStatisticsCompanion.insert({
    required String statDate,
    this.id = const Value.absent(),
    this.wordsLearned = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.xpGained = const Value.absent(),
    this.lessonsCompleted = const Value.absent(),
    this.quizzesCompleted = const Value.absent(),
    this.correctAnswers = const Value.absent(),
    this.totalAnswers = const Value.absent(),
    this.studySeconds = const Value.absent(),
    this.isDirty = const Value.absent(),
    this.lastSyncedAt = const Value.absent(),
  }) : statDate = Value(statDate);
  static Insertable<DailyStatistic> custom({
    Expression<String>? statDate,
    Expression<String>? id,
    Expression<int>? wordsLearned,
    Expression<int>? cardsReviewed,
    Expression<int>? xpGained,
    Expression<int>? lessonsCompleted,
    Expression<int>? quizzesCompleted,
    Expression<int>? correctAnswers,
    Expression<int>? totalAnswers,
    Expression<int>? studySeconds,
    Expression<int>? isDirty,
    Expression<int>? lastSyncedAt,
  }) {
    return RawValuesInsertable({
      if (statDate != null) 'stat_date': statDate,
      if (id != null) 'id': id,
      if (wordsLearned != null) 'words_learned': wordsLearned,
      if (cardsReviewed != null) 'cards_reviewed': cardsReviewed,
      if (xpGained != null) 'xp_gained': xpGained,
      if (lessonsCompleted != null) 'lessons_completed': lessonsCompleted,
      if (quizzesCompleted != null) 'quizzes_completed': quizzesCompleted,
      if (correctAnswers != null) 'correct_answers': correctAnswers,
      if (totalAnswers != null) 'total_answers': totalAnswers,
      if (studySeconds != null) 'study_seconds': studySeconds,
      if (isDirty != null) 'is_dirty': isDirty,
      if (lastSyncedAt != null) 'last_synced_at': lastSyncedAt,
    });
  }

  DailyStatisticsCompanion copyWith({
    Value<String>? statDate,
    Value<String?>? id,
    Value<int>? wordsLearned,
    Value<int>? cardsReviewed,
    Value<int>? xpGained,
    Value<int>? lessonsCompleted,
    Value<int>? quizzesCompleted,
    Value<int>? correctAnswers,
    Value<int>? totalAnswers,
    Value<int>? studySeconds,
    Value<int>? isDirty,
    Value<int?>? lastSyncedAt,
  }) {
    return DailyStatisticsCompanion(
      statDate: statDate ?? this.statDate,
      id: id ?? this.id,
      wordsLearned: wordsLearned ?? this.wordsLearned,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      xpGained: xpGained ?? this.xpGained,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      quizzesCompleted: quizzesCompleted ?? this.quizzesCompleted,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      studySeconds: studySeconds ?? this.studySeconds,
      isDirty: isDirty ?? this.isDirty,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (statDate.present) {
      map['stat_date'] = Variable<String>(statDate.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (wordsLearned.present) {
      map['words_learned'] = Variable<int>(wordsLearned.value);
    }
    if (cardsReviewed.present) {
      map['cards_reviewed'] = Variable<int>(cardsReviewed.value);
    }
    if (xpGained.present) {
      map['xp_gained'] = Variable<int>(xpGained.value);
    }
    if (lessonsCompleted.present) {
      map['lessons_completed'] = Variable<int>(lessonsCompleted.value);
    }
    if (quizzesCompleted.present) {
      map['quizzes_completed'] = Variable<int>(quizzesCompleted.value);
    }
    if (correctAnswers.present) {
      map['correct_answers'] = Variable<int>(correctAnswers.value);
    }
    if (totalAnswers.present) {
      map['total_answers'] = Variable<int>(totalAnswers.value);
    }
    if (studySeconds.present) {
      map['study_seconds'] = Variable<int>(studySeconds.value);
    }
    if (isDirty.present) {
      map['is_dirty'] = Variable<int>(isDirty.value);
    }
    if (lastSyncedAt.present) {
      map['last_synced_at'] = Variable<int>(lastSyncedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyStatisticsCompanion(')
          ..write('statDate: $statDate, ')
          ..write('id: $id, ')
          ..write('wordsLearned: $wordsLearned, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('xpGained: $xpGained, ')
          ..write('lessonsCompleted: $lessonsCompleted, ')
          ..write('quizzesCompleted: $quizzesCompleted, ')
          ..write('correctAnswers: $correctAnswers, ')
          ..write('totalAnswers: $totalAnswers, ')
          ..write('studySeconds: $studySeconds, ')
          ..write('isDirty: $isDirty, ')
          ..write('lastSyncedAt: $lastSyncedAt')
          ..write(')'))
        .toString();
  }
}

class SyncQueue extends Table with TableInfo<SyncQueue, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncQueue(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _opIdMeta = const VerificationMeta('opId');
  late final GeneratedColumn<String> opId = GeneratedColumn<String>(
    'op_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _opTypeMeta = const VerificationMeta('opType');
  late final GeneratedColumn<String> opType = GeneratedColumn<String>(
    'op_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL CHECK (op_type IN (\'FLASHCARD_REVIEW\', \'LESSON_COMPLETE\', \'QUIZ_SUBMIT\', \'NOTE_UPSERT\', \'NOTE_DELETE\', \'BOOKMARK_SET\', \'QUEST_CLAIM\', \'PROFILE_UPDATE\', \'ITEM_EQUIP\', \'SHOP_PURCHASE\', \'SETTINGS_UPDATE\'))',
  );
  static const VerificationMeta _entityTableMeta = const VerificationMeta(
    'entityTable',
  );
  late final GeneratedColumn<String> entityTable = GeneratedColumn<String>(
    'entity_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pending\' CHECK (status IN (\'pending\', \'in_flight\', \'failed\', \'dead\'))',
    defaultValue: const CustomExpression('\'pending\''),
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  late final GeneratedColumn<int> nextRetryAt = GeneratedColumn<int>(
    'next_retry_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    opId,
    opType,
    entityTable,
    entityId,
    payload,
    status,
    attemptCount,
    nextRetryAt,
    lastError,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('op_id')) {
      context.handle(
        _opIdMeta,
        opId.isAcceptableOrUnknown(data['op_id']!, _opIdMeta),
      );
    } else if (isInserting) {
      context.missing(_opIdMeta);
    }
    if (data.containsKey('op_type')) {
      context.handle(
        _opTypeMeta,
        opType.isAcceptableOrUnknown(data['op_type']!, _opTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_opTypeMeta);
    }
    if (data.containsKey('entity_table')) {
      context.handle(
        _entityTableMeta,
        entityTable.isAcceptableOrUnknown(
          data['entity_table']!,
          _entityTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entityTableMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      opId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_id'],
      )!,
      opType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op_type'],
      )!,
      entityTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_table'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_retry_at'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  SyncQueue createAlias(String alias) {
    return SyncQueue(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final int id;

  /// thứ tự FIFO
  final String opId;

  /// UUID, idempotency key gửi lên server
  final String opType;
  final String entityTable;
  final String entityId;
  final String payload;

  /// JSON
  final String status;
  final int attemptCount;
  final int nextRetryAt;
  final String? lastError;
  final int createdAt;
  const SyncQueueData({
    required this.id,
    required this.opId,
    required this.opType,
    required this.entityTable,
    required this.entityId,
    required this.payload,
    required this.status,
    required this.attemptCount,
    required this.nextRetryAt,
    this.lastError,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['op_id'] = Variable<String>(opId);
    map['op_type'] = Variable<String>(opType);
    map['entity_table'] = Variable<String>(entityTable);
    map['entity_id'] = Variable<String>(entityId);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['attempt_count'] = Variable<int>(attemptCount);
    map['next_retry_at'] = Variable<int>(nextRetryAt);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      id: Value(id),
      opId: Value(opId),
      opType: Value(opType),
      entityTable: Value(entityTable),
      entityId: Value(entityId),
      payload: Value(payload),
      status: Value(status),
      attemptCount: Value(attemptCount),
      nextRetryAt: Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAt: Value(createdAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      id: serializer.fromJson<int>(json['id']),
      opId: serializer.fromJson<String>(json['op_id']),
      opType: serializer.fromJson<String>(json['op_type']),
      entityTable: serializer.fromJson<String>(json['entity_table']),
      entityId: serializer.fromJson<String>(json['entity_id']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      attemptCount: serializer.fromJson<int>(json['attempt_count']),
      nextRetryAt: serializer.fromJson<int>(json['next_retry_at']),
      lastError: serializer.fromJson<String?>(json['last_error']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'op_id': serializer.toJson<String>(opId),
      'op_type': serializer.toJson<String>(opType),
      'entity_table': serializer.toJson<String>(entityTable),
      'entity_id': serializer.toJson<String>(entityId),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'attempt_count': serializer.toJson<int>(attemptCount),
      'next_retry_at': serializer.toJson<int>(nextRetryAt),
      'last_error': serializer.toJson<String?>(lastError),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  SyncQueueData copyWith({
    int? id,
    String? opId,
    String? opType,
    String? entityTable,
    String? entityId,
    String? payload,
    String? status,
    int? attemptCount,
    int? nextRetryAt,
    Value<String?> lastError = const Value.absent(),
    int? createdAt,
  }) => SyncQueueData(
    id: id ?? this.id,
    opId: opId ?? this.opId,
    opType: opType ?? this.opType,
    entityTable: entityTable ?? this.entityTable,
    entityId: entityId ?? this.entityId,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    attemptCount: attemptCount ?? this.attemptCount,
    nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAt: createdAt ?? this.createdAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      id: data.id.present ? data.id.value : this.id,
      opId: data.opId.present ? data.opId.value : this.opId,
      opType: data.opType.present ? data.opType.value : this.opType,
      entityTable: data.entityTable.present
          ? data.entityTable.value
          : this.entityTable,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('opType: $opType, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    opId,
    opType,
    entityTable,
    entityId,
    payload,
    status,
    attemptCount,
    nextRetryAt,
    lastError,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.id == this.id &&
          other.opId == this.opId &&
          other.opType == this.opType &&
          other.entityTable == this.entityTable &&
          other.entityId == this.entityId &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.attemptCount == this.attemptCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.createdAt == this.createdAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<int> id;
  final Value<String> opId;
  final Value<String> opType;
  final Value<String> entityTable;
  final Value<String> entityId;
  final Value<String> payload;
  final Value<String> status;
  final Value<int> attemptCount;
  final Value<int> nextRetryAt;
  final Value<String?> lastError;
  final Value<int> createdAt;
  const SyncQueueCompanion({
    this.id = const Value.absent(),
    this.opId = const Value.absent(),
    this.opType = const Value.absent(),
    this.entityTable = const Value.absent(),
    this.entityId = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    this.id = const Value.absent(),
    required String opId,
    required String opType,
    required String entityTable,
    required String entityId,
    required String payload,
    this.status = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAt,
  }) : opId = Value(opId),
       opType = Value(opType),
       entityTable = Value(entityTable),
       entityId = Value(entityId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<SyncQueueData> custom({
    Expression<int>? id,
    Expression<String>? opId,
    Expression<String>? opType,
    Expression<String>? entityTable,
    Expression<String>? entityId,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? attemptCount,
    Expression<int>? nextRetryAt,
    Expression<String>? lastError,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (opId != null) 'op_id': opId,
      if (opType != null) 'op_type': opType,
      if (entityTable != null) 'entity_table': entityTable,
      if (entityId != null) 'entity_id': entityId,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncQueueCompanion copyWith({
    Value<int>? id,
    Value<String>? opId,
    Value<String>? opType,
    Value<String>? entityTable,
    Value<String>? entityId,
    Value<String>? payload,
    Value<String>? status,
    Value<int>? attemptCount,
    Value<int>? nextRetryAt,
    Value<String?>? lastError,
    Value<int>? createdAt,
  }) {
    return SyncQueueCompanion(
      id: id ?? this.id,
      opId: opId ?? this.opId,
      opType: opType ?? this.opType,
      entityTable: entityTable ?? this.entityTable,
      entityId: entityId ?? this.entityId,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      attemptCount: attemptCount ?? this.attemptCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (opId.present) {
      map['op_id'] = Variable<String>(opId.value);
    }
    if (opType.present) {
      map['op_type'] = Variable<String>(opType.value);
    }
    if (entityTable.present) {
      map['entity_table'] = Variable<String>(entityTable.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<int>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('id: $id, ')
          ..write('opId: $opId, ')
          ..write('opType: $opType, ')
          ..write('entityTable: $entityTable, ')
          ..write('entityId: $entityId, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class SyncMeta extends Table with TableInfo<SyncMeta, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  SyncMeta(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _serverCursorMeta = const VerificationMeta(
    'serverCursor',
  );
  late final GeneratedColumn<String> serverCursor = GeneratedColumn<String>(
    'server_cursor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastPulledAtMeta = const VerificationMeta(
    'lastPulledAt',
  );
  late final GeneratedColumn<int> lastPulledAt = GeneratedColumn<int>(
    'last_pulled_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastPushedAtMeta = const VerificationMeta(
    'lastPushedAt',
  );
  late final GeneratedColumn<int> lastPushedAt = GeneratedColumn<int>(
    'last_pushed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    scope,
    serverCursor,
    lastPulledAt,
    lastPushedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('server_cursor')) {
      context.handle(
        _serverCursorMeta,
        serverCursor.isAcceptableOrUnknown(
          data['server_cursor']!,
          _serverCursorMeta,
        ),
      );
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
        _lastPulledAtMeta,
        lastPulledAt.isAcceptableOrUnknown(
          data['last_pulled_at']!,
          _lastPulledAtMeta,
        ),
      );
    }
    if (data.containsKey('last_pushed_at')) {
      context.handle(
        _lastPushedAtMeta,
        lastPushedAt.isAcceptableOrUnknown(
          data['last_pushed_at']!,
          _lastPushedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {scope};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      serverCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_cursor'],
      ),
      lastPulledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pulled_at'],
      ),
      lastPushedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_pushed_at'],
      ),
    );
  }

  @override
  SyncMeta createAlias(String alias) {
    return SyncMeta(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
  @override
  bool get dontWriteConstraints => true;
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String scope;

  /// 'content', 'user_data', 'leaderboard'...
  final String? serverCursor;

  /// giá trị serverTime/cursor server trả về
  final int? lastPulledAt;
  final int? lastPushedAt;
  const SyncMetaData({
    required this.scope,
    this.serverCursor,
    this.lastPulledAt,
    this.lastPushedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || serverCursor != null) {
      map['server_cursor'] = Variable<String>(serverCursor);
    }
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt);
    }
    if (!nullToAbsent || lastPushedAt != null) {
      map['last_pushed_at'] = Variable<int>(lastPushedAt);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      scope: Value(scope),
      serverCursor: serverCursor == null && nullToAbsent
          ? const Value.absent()
          : Value(serverCursor),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
      lastPushedAt: lastPushedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPushedAt),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      scope: serializer.fromJson<String>(json['scope']),
      serverCursor: serializer.fromJson<String?>(json['server_cursor']),
      lastPulledAt: serializer.fromJson<int?>(json['last_pulled_at']),
      lastPushedAt: serializer.fromJson<int?>(json['last_pushed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'scope': serializer.toJson<String>(scope),
      'server_cursor': serializer.toJson<String?>(serverCursor),
      'last_pulled_at': serializer.toJson<int?>(lastPulledAt),
      'last_pushed_at': serializer.toJson<int?>(lastPushedAt),
    };
  }

  SyncMetaData copyWith({
    String? scope,
    Value<String?> serverCursor = const Value.absent(),
    Value<int?> lastPulledAt = const Value.absent(),
    Value<int?> lastPushedAt = const Value.absent(),
  }) => SyncMetaData(
    scope: scope ?? this.scope,
    serverCursor: serverCursor.present ? serverCursor.value : this.serverCursor,
    lastPulledAt: lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
    lastPushedAt: lastPushedAt.present ? lastPushedAt.value : this.lastPushedAt,
  );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      scope: data.scope.present ? data.scope.value : this.scope,
      serverCursor: data.serverCursor.present
          ? data.serverCursor.value
          : this.serverCursor,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
      lastPushedAt: data.lastPushedAt.present
          ? data.lastPushedAt.value
          : this.lastPushedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('scope: $scope, ')
          ..write('serverCursor: $serverCursor, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(scope, serverCursor, lastPulledAt, lastPushedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.scope == this.scope &&
          other.serverCursor == this.serverCursor &&
          other.lastPulledAt == this.lastPulledAt &&
          other.lastPushedAt == this.lastPushedAt);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> scope;
  final Value<String?> serverCursor;
  final Value<int?> lastPulledAt;
  final Value<int?> lastPushedAt;
  const SyncMetaCompanion({
    this.scope = const Value.absent(),
    this.serverCursor = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String scope,
    this.serverCursor = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.lastPushedAt = const Value.absent(),
  }) : scope = Value(scope);
  static Insertable<SyncMetaData> custom({
    Expression<String>? scope,
    Expression<String>? serverCursor,
    Expression<int>? lastPulledAt,
    Expression<int>? lastPushedAt,
  }) {
    return RawValuesInsertable({
      if (scope != null) 'scope': scope,
      if (serverCursor != null) 'server_cursor': serverCursor,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (lastPushedAt != null) 'last_pushed_at': lastPushedAt,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? scope,
    Value<String?>? serverCursor,
    Value<int?>? lastPulledAt,
    Value<int?>? lastPushedAt,
  }) {
    return SyncMetaCompanion(
      scope: scope ?? this.scope,
      serverCursor: serverCursor ?? this.serverCursor,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      lastPushedAt: lastPushedAt ?? this.lastPushedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (serverCursor.present) {
      map['server_cursor'] = Variable<String>(serverCursor.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<int>(lastPulledAt.value);
    }
    if (lastPushedAt.present) {
      map['last_pushed_at'] = Variable<int>(lastPushedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('scope: $scope, ')
          ..write('serverCursor: $serverCursor, ')
          ..write('lastPulledAt: $lastPulledAt, ')
          ..write('lastPushedAt: $lastPushedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final Topics topics = Topics(this);
  late final Index idxTopicsSort = Index(
    'idx_topics_sort',
    'CREATE INDEX idx_topics_sort ON topics (sort_order)',
  );
  late final Flashcards flashcards = Flashcards(this);
  late final Index idxFlashcardsTopic = Index(
    'idx_flashcards_topic',
    'CREATE INDEX idx_flashcards_topic ON flashcards (topic_id, sort_order)',
  );
  late final Index idxFlashcardsWord = Index(
    'idx_flashcards_word',
    'CREATE INDEX idx_flashcards_word ON flashcards (word COLLATE NOCASE)',
  );
  late final GrammarLessons grammarLessons = GrammarLessons(this);
  late final GrammarExamples grammarExamples = GrammarExamples(this);
  late final Index idxGeLesson = Index(
    'idx_ge_lesson',
    'CREATE INDEX idx_ge_lesson ON grammar_examples (grammar_lesson_id, sort_order)',
  );
  late final Quizzes quizzes = Quizzes(this);
  late final Index idxQuizzesTopic = Index(
    'idx_quizzes_topic',
    'CREATE INDEX idx_quizzes_topic ON quizzes (topic_id)',
  );
  late final Index idxQuizzesGrammar = Index(
    'idx_quizzes_grammar',
    'CREATE INDEX idx_quizzes_grammar ON quizzes (grammar_lesson_id)',
  );
  late final QuizQuestions quizQuestions = QuizQuestions(this);
  late final Index idxQqQuiz = Index(
    'idx_qq_quiz',
    'CREATE INDEX idx_qq_quiz ON quiz_questions (quiz_id, sort_order)',
  );
  late final QuizQuestionOptions quizQuestionOptions = QuizQuestionOptions(
    this,
  );
  late final QuestDefinitions questDefinitions = QuestDefinitions(this);
  late final RewardItems rewardItems = RewardItems(this);
  late final LeaderboardCache leaderboardCache = LeaderboardCache(this);
  late final Index idxLbRank = Index(
    'idx_lb_rank',
    'CREATE INDEX idx_lb_rank ON leaderboard_cache (board, rank_no)',
  );
  late final UserProfile userProfile = UserProfile(this);
  late final UserFlashcardProgress userFlashcardProgress =
      UserFlashcardProgress(this);
  late final Index idxUfpDue = Index(
    'idx_ufp_due',
    'CREATE INDEX idx_ufp_due ON user_flashcard_progress (due_at)',
  );
  late final Index idxUfpDirty = Index(
    'idx_ufp_dirty',
    'CREATE INDEX idx_ufp_dirty ON user_flashcard_progress (is_dirty)',
  );
  late final FlashcardReviewLogs flashcardReviewLogs = FlashcardReviewLogs(
    this,
  );
  late final Index idxFrlTime = Index(
    'idx_frl_time',
    'CREATE INDEX idx_frl_time ON flashcard_review_logs (reviewed_at)',
  );
  late final Index idxFrlSync = Index(
    'idx_frl_sync',
    'CREATE INDEX idx_frl_sync ON flashcard_review_logs (sync_status)',
  );
  late final UserFlashcardNotes userFlashcardNotes = UserFlashcardNotes(this);
  late final Index idxUfnDirty = Index(
    'idx_ufn_dirty',
    'CREATE INDEX idx_ufn_dirty ON user_flashcard_notes (is_dirty)',
  );
  late final UserBookmarks userBookmarks = UserBookmarks(this);
  late final Index idxUbList = Index(
    'idx_ub_list',
    'CREATE INDEX idx_ub_list ON user_bookmarks (deleted_at, created_at)',
  );
  late final UserTopicProgress userTopicProgress = UserTopicProgress(this);
  late final Index idxUtpStatus = Index(
    'idx_utp_status',
    'CREATE INDEX idx_utp_status ON user_topic_progress (status)',
  );
  late final UserGrammarProgress userGrammarProgress = UserGrammarProgress(
    this,
  );
  late final LessonCompletions lessonCompletions = LessonCompletions(this);
  late final Index idxLcTime = Index(
    'idx_lc_time',
    'CREATE INDEX idx_lc_time ON lesson_completions (completed_at)',
  );
  late final QuizAttempts quizAttempts = QuizAttempts(this);
  late final Index idxQaQuizTime = Index(
    'idx_qa_quiz_time',
    'CREATE INDEX idx_qa_quiz_time ON quiz_attempts (quiz_id, submitted_at)',
  );
  late final QuizAttemptAnswers quizAttemptAnswers = QuizAttemptAnswers(this);
  late final UserQuests userQuests = UserQuests(this);
  late final Index idxUqPeriod = Index(
    'idx_uq_period',
    'CREATE INDEX idx_uq_period ON user_quests (period_start)',
  );
  late final UserInventories userInventories = UserInventories(this);
  late final DailyStatistics dailyStatistics = DailyStatistics(this);
  late final SyncQueue syncQueue = SyncQueue(this);
  late final Index idxSqReady = Index(
    'idx_sq_ready',
    'CREATE INDEX idx_sq_ready ON sync_queue (status, next_retry_at, id)',
  );
  late final Index idxSqEntity = Index(
    'idx_sq_entity',
    'CREATE INDEX idx_sq_entity ON sync_queue (entity_table, entity_id, status)',
  );
  late final SyncMeta syncMeta = SyncMeta(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    topics,
    idxTopicsSort,
    flashcards,
    idxFlashcardsTopic,
    idxFlashcardsWord,
    grammarLessons,
    grammarExamples,
    idxGeLesson,
    quizzes,
    idxQuizzesTopic,
    idxQuizzesGrammar,
    quizQuestions,
    idxQqQuiz,
    quizQuestionOptions,
    questDefinitions,
    rewardItems,
    leaderboardCache,
    idxLbRank,
    userProfile,
    userFlashcardProgress,
    idxUfpDue,
    idxUfpDirty,
    flashcardReviewLogs,
    idxFrlTime,
    idxFrlSync,
    userFlashcardNotes,
    idxUfnDirty,
    userBookmarks,
    idxUbList,
    userTopicProgress,
    idxUtpStatus,
    userGrammarProgress,
    lessonCompletions,
    idxLcTime,
    quizAttempts,
    idxQaQuizTime,
    quizAttemptAnswers,
    userQuests,
    idxUqPeriod,
    userInventories,
    dailyStatistics,
    syncQueue,
    idxSqReady,
    idxSqEntity,
    syncMeta,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcards', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_lessons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('grammar_examples', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quizzes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_lessons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quizzes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quizzes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_questions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quiz_questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_question_options', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_flashcard_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('flashcard_review_logs', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_flashcard_notes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'flashcards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_topic_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_lessons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_grammar_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'topics',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lesson_completions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'grammar_lessons',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lesson_completions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quizzes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_attempts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quiz_attempts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_attempt_answers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quiz_questions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quiz_attempt_answers', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quest_definitions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_quests', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'reward_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_inventories', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $TopicsCreateCompanionBuilder = TopicsCompanion Function({
  required String id,
  required String title,
  Value<String?> description,
  required String iconPath,
  Value<String> level,
  Value<int?> coverColor,
  Value<int> estimatedMinutes,
  Value<int> totalWords,
  Value<int> sortOrder,
  required int serverUpdatedAt,
  Value<int> rowid,
});
typedef $TopicsUpdateCompanionBuilder = TopicsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> description,
  Value<String> iconPath,
  Value<String> level,
  Value<int?> coverColor,
  Value<int> estimatedMinutes,
  Value<int> totalWords,
  Value<int> sortOrder,
  Value<int> serverUpdatedAt,
  Value<int> rowid,
});

final class $TopicsReferences
    extends BaseReferences<_$AppDatabase, Topics, Topic> {
  $TopicsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Flashcards, List<Flashcard>> _flashcardsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.flashcards,
    aliasName: 'topics__id__flashcards__topic_id',
  );

  $FlashcardsProcessedTableManager get flashcardsRefs {
    final manager = $FlashcardsTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Quizzes, List<Quizze>> _quizzesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quizzes,
    aliasName: 'topics__id__quizzes__topic_id',
  );

  $QuizzesProcessedTableManager get quizzesRefs {
    final manager = $QuizzesTableManager(
      $_db,
      $_db.quizzes,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quizzesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<UserTopicProgress, List<UserTopicProgressData>>
  _userTopicProgressRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userTopicProgress,
        aliasName: 'topics__id__user_topic_progress__topic_id',
      );

  $UserTopicProgressProcessedTableManager get userTopicProgressRefs {
    final manager = $UserTopicProgressTableManager(
      $_db,
      $_db.userTopicProgress,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userTopicProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<LessonCompletions, List<LessonCompletion>>
  _lessonCompletionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lessonCompletions,
        aliasName: 'topics__id__lesson_completions__topic_id',
      );

  $LessonCompletionsProcessedTableManager get lessonCompletionsRefs {
    final manager = $LessonCompletionsTableManager(
      $_db,
      $_db.lessonCompletions,
    ).filter((f) => f.topicId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _lessonCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $TopicsFilterComposer extends Composer<_$AppDatabase, Topics> {
  $TopicsFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> flashcardsRefs(
    Expression<bool> Function($FlashcardsFilterComposer f) f,
  ) {
    final $FlashcardsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quizzesRefs(
    Expression<bool> Function($QuizzesFilterComposer f) f,
  ) {
    final $QuizzesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesFilterComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userTopicProgressRefs(
    Expression<bool> Function($UserTopicProgressFilterComposer f) f,
  ) {
    final $UserTopicProgressFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTopicProgress,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserTopicProgressFilterComposer(
            $db: $db,
            $table: $db.userTopicProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lessonCompletionsRefs(
    Expression<bool> Function($LessonCompletionsFilterComposer f) f,
  ) {
    final $LessonCompletionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonCompletions,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LessonCompletionsFilterComposer(
            $db: $db,
            $table: $db.lessonCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TopicsOrderingComposer extends Composer<_$AppDatabase, Topics> {
  $TopicsOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TopicsAnnotationComposer extends Composer<_$AppDatabase, Topics> {
  $TopicsAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWords => $composableBuilder(
    column: $table.totalWords,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  Expression<T> flashcardsRefs<T extends Object>(
    Expression<T> Function($FlashcardsAnnotationComposer a) f,
  ) {
    final $FlashcardsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quizzesRefs<T extends Object>(
    Expression<T> Function($QuizzesAnnotationComposer a) f,
  ) {
    final $QuizzesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesAnnotationComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userTopicProgressRefs<T extends Object>(
    Expression<T> Function($UserTopicProgressAnnotationComposer a) f,
  ) {
    final $UserTopicProgressAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userTopicProgress,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserTopicProgressAnnotationComposer(
            $db: $db,
            $table: $db.userTopicProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lessonCompletionsRefs<T extends Object>(
    Expression<T> Function($LessonCompletionsAnnotationComposer a) f,
  ) {
    final $LessonCompletionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonCompletions,
      getReferencedColumn: (t) => t.topicId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LessonCompletionsAnnotationComposer(
            $db: $db,
            $table: $db.lessonCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $TopicsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Topics,
          Topic,
          $TopicsFilterComposer,
          $TopicsOrderingComposer,
          $TopicsAnnotationComposer,
          $TopicsCreateCompanionBuilder,
          $TopicsUpdateCompanionBuilder,
          (Topic, $TopicsReferences),
          Topic,
          PrefetchHooks Function({
            bool flashcardsRefs,
            bool quizzesRefs,
            bool userTopicProgressRefs,
            bool lessonCompletionsRefs,
          })
        > {
  $TopicsTableManager(_$AppDatabase db, Topics table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TopicsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TopicsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TopicsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> iconPath = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int?> coverColor = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> totalWords = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion(
                id: id,
                title: title,
                description: description,
                iconPath: iconPath,
                level: level,
                coverColor: coverColor,
                estimatedMinutes: estimatedMinutes,
                totalWords: totalWords,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required String iconPath,
                Value<String> level = const Value.absent(),
                Value<int?> coverColor = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> totalWords = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int serverUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TopicsCompanion.insert(
                id: id,
                title: title,
                description: description,
                iconPath: iconPath,
                level: level,
                coverColor: coverColor,
                estimatedMinutes: estimatedMinutes,
                totalWords: totalWords,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Topics, Topic>(table),
                  $TopicsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                flashcardsRefs = false,
                quizzesRefs = false,
                userTopicProgressRefs = false,
                lessonCompletionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (flashcardsRefs) db.flashcards,
                    if (quizzesRefs) db.quizzes,
                    if (userTopicProgressRefs) db.userTopicProgress,
                    if (lessonCompletionsRefs) db.lessonCompletions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (flashcardsRefs)
                        await $_getPrefetchedData<Topic, Topics, Flashcard>(
                          currentTable: table,
                          referencedTable: $TopicsReferences
                              ._flashcardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $TopicsReferences(db, table, p0).flashcardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quizzesRefs)
                        await $_getPrefetchedData<Topic, Topics, Quizze>(
                          currentTable: table,
                          referencedTable: $TopicsReferences._quizzesRefsTable(
                            db,
                          ),
                          managerFromTypedResult: (p0) =>
                              $TopicsReferences(db, table, p0).quizzesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userTopicProgressRefs)
                        await $_getPrefetchedData<
                          Topic,
                          Topics,
                          UserTopicProgressData
                        >(
                          currentTable: table,
                          referencedTable: $TopicsReferences
                              ._userTopicProgressRefsTable(db),
                          managerFromTypedResult: (p0) => $TopicsReferences(
                            db,
                            table,
                            p0,
                          ).userTopicProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lessonCompletionsRefs)
                        await $_getPrefetchedData<
                          Topic,
                          Topics,
                          LessonCompletion
                        >(
                          currentTable: table,
                          referencedTable: $TopicsReferences
                              ._lessonCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) => $TopicsReferences(
                            db,
                            table,
                            p0,
                          ).lessonCompletionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.topicId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $TopicsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Topics,
      Topic,
      $TopicsFilterComposer,
      $TopicsOrderingComposer,
      $TopicsAnnotationComposer,
      $TopicsCreateCompanionBuilder,
      $TopicsUpdateCompanionBuilder,
      (Topic, $TopicsReferences),
      Topic,
      PrefetchHooks Function({
        bool flashcardsRefs,
        bool quizzesRefs,
        bool userTopicProgressRefs,
        bool lessonCompletionsRefs,
      })
    >;
typedef $FlashcardsCreateCompanionBuilder = FlashcardsCompanion Function({
  required String id,
  required String topicId,
  required String word,
  required String partOfSpeech,
  required String pronunciation,
  required String meaning,
  Value<String?> example,
  Value<String?> exampleTranslation,
  Value<String?> audioUrl,
  Value<String?> imageUrl,
  Value<int> sortOrder,
  required int serverUpdatedAt,
  Value<int> rowid,
});
typedef $FlashcardsUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<String> id,
  Value<String> topicId,
  Value<String> word,
  Value<String> partOfSpeech,
  Value<String> pronunciation,
  Value<String> meaning,
  Value<String?> example,
  Value<String?> exampleTranslation,
  Value<String?> audioUrl,
  Value<String?> imageUrl,
  Value<int> sortOrder,
  Value<int> serverUpdatedAt,
  Value<int> rowid,
});

final class $FlashcardsReferences
    extends BaseReferences<_$AppDatabase, Flashcards, Flashcard> {
  $FlashcardsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Topics _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('flashcards__topic_id__topics__id');

  $TopicsProcessedTableManager get topicId {
    final $_column = $_itemColumn<String>('topic_id')!;

    final manager = $TopicsTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    UserFlashcardProgress,
    List<UserFlashcardProgressData>
  >
  _userFlashcardProgressRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userFlashcardProgress,
        aliasName: 'flashcards__id__user_flashcard_progress__flashcard_id',
      );

  $UserFlashcardProgressProcessedTableManager get userFlashcardProgressRefs {
    final manager = $UserFlashcardProgressTableManager(
      $_db,
      $_db.userFlashcardProgress,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userFlashcardProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<FlashcardReviewLogs, List<FlashcardReviewLog>>
  _flashcardReviewLogsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.flashcardReviewLogs,
        aliasName: 'flashcards__id__flashcard_review_logs__flashcard_id',
      );

  $FlashcardReviewLogsProcessedTableManager get flashcardReviewLogsRefs {
    final manager = $FlashcardReviewLogsTableManager(
      $_db,
      $_db.flashcardReviewLogs,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _flashcardReviewLogsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<UserFlashcardNotes, List<UserFlashcardNote>>
  _userFlashcardNotesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userFlashcardNotes,
        aliasName: 'flashcards__id__user_flashcard_notes__flashcard_id',
      );

  $UserFlashcardNotesProcessedTableManager get userFlashcardNotesRefs {
    final manager = $UserFlashcardNotesTableManager(
      $_db,
      $_db.userFlashcardNotes,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userFlashcardNotesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<UserBookmarks, List<UserBookmark>>
  _userBookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userBookmarks,
    aliasName: 'flashcards__id__user_bookmarks__flashcard_id',
  );

  $UserBookmarksProcessedTableManager get userBookmarksRefs {
    final manager = $UserBookmarksTableManager(
      $_db,
      $_db.userBookmarks,
    ).filter((f) => f.flashcardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userBookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $FlashcardsFilterComposer extends Composer<_$AppDatabase, Flashcards> {
  $FlashcardsFilterComposer({
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

  ColumnFilters<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
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

  ColumnFilters<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $TopicsFilterComposer get topicId {
    final $TopicsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> userFlashcardProgressRefs(
    Expression<bool> Function($UserFlashcardProgressFilterComposer f) f,
  ) {
    final $UserFlashcardProgressFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFlashcardProgress,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserFlashcardProgressFilterComposer(
            $db: $db,
            $table: $db.userFlashcardProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> flashcardReviewLogsRefs(
    Expression<bool> Function($FlashcardReviewLogsFilterComposer f) f,
  ) {
    final $FlashcardReviewLogsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcardReviewLogs,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardReviewLogsFilterComposer(
            $db: $db,
            $table: $db.flashcardReviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userFlashcardNotesRefs(
    Expression<bool> Function($UserFlashcardNotesFilterComposer f) f,
  ) {
    final $UserFlashcardNotesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFlashcardNotes,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserFlashcardNotesFilterComposer(
            $db: $db,
            $table: $db.userFlashcardNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userBookmarksRefs(
    Expression<bool> Function($UserBookmarksFilterComposer f) f,
  ) {
    final $UserBookmarksFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBookmarks,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserBookmarksFilterComposer(
            $db: $db,
            $table: $db.userBookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FlashcardsOrderingComposer extends Composer<_$AppDatabase, Flashcards> {
  $FlashcardsOrderingComposer({
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

  ColumnOrderings<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
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

  ColumnOrderings<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $TopicsOrderingComposer get topicId {
    final $TopicsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FlashcardsAnnotationComposer
    extends Composer<_$AppDatabase, Flashcards> {
  $FlashcardsAnnotationComposer({
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

  GeneratedColumn<String> get partOfSpeech => $composableBuilder(
    column: $table.partOfSpeech,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pronunciation => $composableBuilder(
    column: $table.pronunciation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get meaning =>
      $composableBuilder(column: $table.meaning, builder: (column) => column);

  GeneratedColumn<String> get example =>
      $composableBuilder(column: $table.example, builder: (column) => column);

  GeneratedColumn<String> get exampleTranslation => $composableBuilder(
    column: $table.exampleTranslation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  $TopicsAnnotationComposer get topicId {
    final $TopicsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> userFlashcardProgressRefs<T extends Object>(
    Expression<T> Function($UserFlashcardProgressAnnotationComposer a) f,
  ) {
    final $UserFlashcardProgressAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFlashcardProgress,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserFlashcardProgressAnnotationComposer(
            $db: $db,
            $table: $db.userFlashcardProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> flashcardReviewLogsRefs<T extends Object>(
    Expression<T> Function($FlashcardReviewLogsAnnotationComposer a) f,
  ) {
    final $FlashcardReviewLogsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.flashcardReviewLogs,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardReviewLogsAnnotationComposer(
            $db: $db,
            $table: $db.flashcardReviewLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userFlashcardNotesRefs<T extends Object>(
    Expression<T> Function($UserFlashcardNotesAnnotationComposer a) f,
  ) {
    final $UserFlashcardNotesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userFlashcardNotes,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserFlashcardNotesAnnotationComposer(
            $db: $db,
            $table: $db.userFlashcardNotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userBookmarksRefs<T extends Object>(
    Expression<T> Function($UserBookmarksAnnotationComposer a) f,
  ) {
    final $UserBookmarksAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userBookmarks,
      getReferencedColumn: (t) => t.flashcardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserBookmarksAnnotationComposer(
            $db: $db,
            $table: $db.userBookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FlashcardsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Flashcards,
          Flashcard,
          $FlashcardsFilterComposer,
          $FlashcardsOrderingComposer,
          $FlashcardsAnnotationComposer,
          $FlashcardsCreateCompanionBuilder,
          $FlashcardsUpdateCompanionBuilder,
          (Flashcard, $FlashcardsReferences),
          Flashcard,
          PrefetchHooks Function({
            bool topicId,
            bool userFlashcardProgressRefs,
            bool flashcardReviewLogsRefs,
            bool userFlashcardNotesRefs,
            bool userBookmarksRefs,
          })
        > {
  $FlashcardsTableManager(_$AppDatabase db, Flashcards table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FlashcardsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FlashcardsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FlashcardsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> partOfSpeech = const Value.absent(),
                Value<String> pronunciation = const Value.absent(),
                Value<String> meaning = const Value.absent(),
                Value<String?> example = const Value.absent(),
                Value<String?> exampleTranslation = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion(
                id: id,
                topicId: topicId,
                word: word,
                partOfSpeech: partOfSpeech,
                pronunciation: pronunciation,
                meaning: meaning,
                example: example,
                exampleTranslation: exampleTranslation,
                audioUrl: audioUrl,
                imageUrl: imageUrl,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String topicId,
                required String word,
                required String partOfSpeech,
                required String pronunciation,
                required String meaning,
                Value<String?> example = const Value.absent(),
                Value<String?> exampleTranslation = const Value.absent(),
                Value<String?> audioUrl = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int serverUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FlashcardsCompanion.insert(
                id: id,
                topicId: topicId,
                word: word,
                partOfSpeech: partOfSpeech,
                pronunciation: pronunciation,
                meaning: meaning,
                example: example,
                exampleTranslation: exampleTranslation,
                audioUrl: audioUrl,
                imageUrl: imageUrl,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Flashcards, Flashcard>(table),
                  $FlashcardsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                topicId = false,
                userFlashcardProgressRefs = false,
                flashcardReviewLogsRefs = false,
                userFlashcardNotesRefs = false,
                userBookmarksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (userFlashcardProgressRefs) db.userFlashcardProgress,
                    if (flashcardReviewLogsRefs) db.flashcardReviewLogs,
                    if (userFlashcardNotesRefs) db.userFlashcardNotes,
                    if (userBookmarksRefs) db.userBookmarks,
                  ],
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
                        if (topicId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.topicId,
                            referencedTable: $FlashcardsReferences
                                ._topicIdTable(db),
                            referencedColumn: $FlashcardsReferences
                                ._topicIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (userFlashcardProgressRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          Flashcards,
                          UserFlashcardProgressData
                        >(
                          currentTable: table,
                          referencedTable: $FlashcardsReferences
                              ._userFlashcardProgressRefsTable(db),
                          managerFromTypedResult: (p0) => $FlashcardsReferences(
                            db,
                            table,
                            p0,
                          ).userFlashcardProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (flashcardReviewLogsRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          Flashcards,
                          FlashcardReviewLog
                        >(
                          currentTable: table,
                          referencedTable: $FlashcardsReferences
                              ._flashcardReviewLogsRefsTable(db),
                          managerFromTypedResult: (p0) => $FlashcardsReferences(
                            db,
                            table,
                            p0,
                          ).flashcardReviewLogsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userFlashcardNotesRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          Flashcards,
                          UserFlashcardNote
                        >(
                          currentTable: table,
                          referencedTable: $FlashcardsReferences
                              ._userFlashcardNotesRefsTable(db),
                          managerFromTypedResult: (p0) => $FlashcardsReferences(
                            db,
                            table,
                            p0,
                          ).userFlashcardNotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userBookmarksRefs)
                        await $_getPrefetchedData<
                          Flashcard,
                          Flashcards,
                          UserBookmark
                        >(
                          currentTable: table,
                          referencedTable: $FlashcardsReferences
                              ._userBookmarksRefsTable(db),
                          managerFromTypedResult: (p0) => $FlashcardsReferences(
                            db,
                            table,
                            p0,
                          ).userBookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.flashcardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $FlashcardsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Flashcards,
      Flashcard,
      $FlashcardsFilterComposer,
      $FlashcardsOrderingComposer,
      $FlashcardsAnnotationComposer,
      $FlashcardsCreateCompanionBuilder,
      $FlashcardsUpdateCompanionBuilder,
      (Flashcard, $FlashcardsReferences),
      Flashcard,
      PrefetchHooks Function({
        bool topicId,
        bool userFlashcardProgressRefs,
        bool flashcardReviewLogsRefs,
        bool userFlashcardNotesRefs,
        bool userBookmarksRefs,
      })
    >;
typedef $GrammarLessonsCreateCompanionBuilder =
    GrammarLessonsCompanion Function({
      required String id,
      required String title,
      Value<String?> description,
      required String structure,
      Value<String?> content,
      Value<String?> usageNotes,
      required String iconName,
      Value<String> level,
      Value<int?> coverColor,
      Value<int> estimatedMinutes,
      Value<int> sortOrder,
      required int serverUpdatedAt,
      Value<int> rowid,
    });
typedef $GrammarLessonsUpdateCompanionBuilder =
    GrammarLessonsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String?> description,
      Value<String> structure,
      Value<String?> content,
      Value<String?> usageNotes,
      Value<String> iconName,
      Value<String> level,
      Value<int?> coverColor,
      Value<int> estimatedMinutes,
      Value<int> sortOrder,
      Value<int> serverUpdatedAt,
      Value<int> rowid,
    });

final class $GrammarLessonsReferences
    extends BaseReferences<_$AppDatabase, GrammarLessons, GrammarLesson> {
  $GrammarLessonsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<GrammarExamples, List<GrammarExample>>
  _grammarExamplesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.grammarExamples,
    aliasName: 'grammar_lessons__id__grammar_examples__grammar_lesson_id',
  );

  $GrammarExamplesProcessedTableManager get grammarExamplesRefs {
    final manager = $GrammarExamplesTableManager($_db, $_db.grammarExamples)
        .filter(
          (f) => f.grammarLessonId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _grammarExamplesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<Quizzes, List<Quizze>> _quizzesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quizzes,
    aliasName: 'grammar_lessons__id__quizzes__grammar_lesson_id',
  );

  $QuizzesProcessedTableManager get quizzesRefs {
    final manager = $QuizzesTableManager($_db, $_db.quizzes).filter(
      (f) => f.grammarLessonId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_quizzesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<UserGrammarProgress, List<UserGrammarProgressData>>
  _userGrammarProgressRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userGrammarProgress,
        aliasName:
            'grammar_lessons__id__user_grammar_progress__grammar_lesson_id',
      );

  $UserGrammarProgressProcessedTableManager get userGrammarProgressRefs {
    final manager =
        $UserGrammarProgressTableManager($_db, $_db.userGrammarProgress).filter(
          (f) => f.grammarLessonId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _userGrammarProgressRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<LessonCompletions, List<LessonCompletion>>
  _lessonCompletionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.lessonCompletions,
        aliasName: 'grammar_lessons__id__lesson_completions__grammar_lesson_id',
      );

  $LessonCompletionsProcessedTableManager get lessonCompletionsRefs {
    final manager = $LessonCompletionsTableManager($_db, $_db.lessonCompletions)
        .filter(
          (f) => f.grammarLessonId.id.sqlEquals($_itemColumn<String>('id')!),
        );

    final cache = $_typedResult.readTableOrNull(
      _lessonCompletionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $GrammarLessonsFilterComposer
    extends Composer<_$AppDatabase, GrammarLessons> {
  $GrammarLessonsFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageNotes => $composableBuilder(
    column: $table.usageNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> grammarExamplesRefs(
    Expression<bool> Function($GrammarExamplesFilterComposer f) f,
  ) {
    final $GrammarExamplesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarExamples,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarExamplesFilterComposer(
            $db: $db,
            $table: $db.grammarExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quizzesRefs(
    Expression<bool> Function($QuizzesFilterComposer f) f,
  ) {
    final $QuizzesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesFilterComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> userGrammarProgressRefs(
    Expression<bool> Function($UserGrammarProgressFilterComposer f) f,
  ) {
    final $UserGrammarProgressFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGrammarProgress,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserGrammarProgressFilterComposer(
            $db: $db,
            $table: $db.userGrammarProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lessonCompletionsRefs(
    Expression<bool> Function($LessonCompletionsFilterComposer f) f,
  ) {
    final $LessonCompletionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonCompletions,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LessonCompletionsFilterComposer(
            $db: $db,
            $table: $db.lessonCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $GrammarLessonsOrderingComposer
    extends Composer<_$AppDatabase, GrammarLessons> {
  $GrammarLessonsOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get structure => $composableBuilder(
    column: $table.structure,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageNotes => $composableBuilder(
    column: $table.usageNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $GrammarLessonsAnnotationComposer
    extends Composer<_$AppDatabase, GrammarLessons> {
  $GrammarLessonsAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get structure =>
      $composableBuilder(column: $table.structure, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get usageNotes => $composableBuilder(
    column: $table.usageNotes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get coverColor => $composableBuilder(
    column: $table.coverColor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  Expression<T> grammarExamplesRefs<T extends Object>(
    Expression<T> Function($GrammarExamplesAnnotationComposer a) f,
  ) {
    final $GrammarExamplesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.grammarExamples,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarExamplesAnnotationComposer(
            $db: $db,
            $table: $db.grammarExamples,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quizzesRefs<T extends Object>(
    Expression<T> Function($QuizzesAnnotationComposer a) f,
  ) {
    final $QuizzesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesAnnotationComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> userGrammarProgressRefs<T extends Object>(
    Expression<T> Function($UserGrammarProgressAnnotationComposer a) f,
  ) {
    final $UserGrammarProgressAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userGrammarProgress,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserGrammarProgressAnnotationComposer(
            $db: $db,
            $table: $db.userGrammarProgress,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lessonCompletionsRefs<T extends Object>(
    Expression<T> Function($LessonCompletionsAnnotationComposer a) f,
  ) {
    final $LessonCompletionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lessonCompletions,
      getReferencedColumn: (t) => t.grammarLessonId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $LessonCompletionsAnnotationComposer(
            $db: $db,
            $table: $db.lessonCompletions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $GrammarLessonsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          GrammarLessons,
          GrammarLesson,
          $GrammarLessonsFilterComposer,
          $GrammarLessonsOrderingComposer,
          $GrammarLessonsAnnotationComposer,
          $GrammarLessonsCreateCompanionBuilder,
          $GrammarLessonsUpdateCompanionBuilder,
          (GrammarLesson, $GrammarLessonsReferences),
          GrammarLesson,
          PrefetchHooks Function({
            bool grammarExamplesRefs,
            bool quizzesRefs,
            bool userGrammarProgressRefs,
            bool lessonCompletionsRefs,
          })
        > {
  $GrammarLessonsTableManager(_$AppDatabase db, GrammarLessons table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GrammarLessonsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GrammarLessonsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GrammarLessonsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> structure = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<String?> usageNotes = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<int?> coverColor = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarLessonsCompanion(
                id: id,
                title: title,
                description: description,
                structure: structure,
                content: content,
                usageNotes: usageNotes,
                iconName: iconName,
                level: level,
                coverColor: coverColor,
                estimatedMinutes: estimatedMinutes,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                Value<String?> description = const Value.absent(),
                required String structure,
                Value<String?> content = const Value.absent(),
                Value<String?> usageNotes = const Value.absent(),
                required String iconName,
                Value<String> level = const Value.absent(),
                Value<int?> coverColor = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int serverUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => GrammarLessonsCompanion.insert(
                id: id,
                title: title,
                description: description,
                structure: structure,
                content: content,
                usageNotes: usageNotes,
                iconName: iconName,
                level: level,
                coverColor: coverColor,
                estimatedMinutes: estimatedMinutes,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<GrammarLessons, GrammarLesson>(table),
                  $GrammarLessonsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                grammarExamplesRefs = false,
                quizzesRefs = false,
                userGrammarProgressRefs = false,
                lessonCompletionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (grammarExamplesRefs) db.grammarExamples,
                    if (quizzesRefs) db.quizzes,
                    if (userGrammarProgressRefs) db.userGrammarProgress,
                    if (lessonCompletionsRefs) db.lessonCompletions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (grammarExamplesRefs)
                        await $_getPrefetchedData<
                          GrammarLesson,
                          GrammarLessons,
                          GrammarExample
                        >(
                          currentTable: table,
                          referencedTable: $GrammarLessonsReferences
                              ._grammarExamplesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GrammarLessonsReferences(
                                db,
                                table,
                                p0,
                              ).grammarExamplesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarLessonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quizzesRefs)
                        await $_getPrefetchedData<
                          GrammarLesson,
                          GrammarLessons,
                          Quizze
                        >(
                          currentTable: table,
                          referencedTable: $GrammarLessonsReferences
                              ._quizzesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GrammarLessonsReferences(
                                db,
                                table,
                                p0,
                              ).quizzesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarLessonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (userGrammarProgressRefs)
                        await $_getPrefetchedData<
                          GrammarLesson,
                          GrammarLessons,
                          UserGrammarProgressData
                        >(
                          currentTable: table,
                          referencedTable: $GrammarLessonsReferences
                              ._userGrammarProgressRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GrammarLessonsReferences(
                                db,
                                table,
                                p0,
                              ).userGrammarProgressRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarLessonId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (lessonCompletionsRefs)
                        await $_getPrefetchedData<
                          GrammarLesson,
                          GrammarLessons,
                          LessonCompletion
                        >(
                          currentTable: table,
                          referencedTable: $GrammarLessonsReferences
                              ._lessonCompletionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $GrammarLessonsReferences(
                                db,
                                table,
                                p0,
                              ).lessonCompletionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.grammarLessonId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $GrammarLessonsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      GrammarLessons,
      GrammarLesson,
      $GrammarLessonsFilterComposer,
      $GrammarLessonsOrderingComposer,
      $GrammarLessonsAnnotationComposer,
      $GrammarLessonsCreateCompanionBuilder,
      $GrammarLessonsUpdateCompanionBuilder,
      (GrammarLesson, $GrammarLessonsReferences),
      GrammarLesson,
      PrefetchHooks Function({
        bool grammarExamplesRefs,
        bool quizzesRefs,
        bool userGrammarProgressRefs,
        bool lessonCompletionsRefs,
      })
    >;
typedef $GrammarExamplesCreateCompanionBuilder =
    GrammarExamplesCompanion Function({
      required String id,
      required String grammarLessonId,
      required String sentence,
      Value<String?> translation,
      Value<String?> highlight,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $GrammarExamplesUpdateCompanionBuilder =
    GrammarExamplesCompanion Function({
      Value<String> id,
      Value<String> grammarLessonId,
      Value<String> sentence,
      Value<String?> translation,
      Value<String?> highlight,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $GrammarExamplesReferences
    extends BaseReferences<_$AppDatabase, GrammarExamples, GrammarExample> {
  $GrammarExamplesReferences(super.$_db, super.$_table, super.$_typedResult);

  static GrammarLessons _grammarLessonIdTable(_$AppDatabase db) => db
      .grammarLessons
      .createAlias('grammar_examples__grammar_lesson_id__grammar_lessons__id');

  $GrammarLessonsProcessedTableManager get grammarLessonId {
    final $_column = $_itemColumn<String>('grammar_lesson_id')!;

    final manager = $GrammarLessonsTableManager(
      $_db,
      $_db.grammarLessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarLessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $GrammarExamplesFilterComposer
    extends Composer<_$AppDatabase, GrammarExamples> {
  $GrammarExamplesFilterComposer({
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

  ColumnFilters<String> get sentence => $composableBuilder(
    column: $table.sentence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get highlight => $composableBuilder(
    column: $table.highlight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $GrammarLessonsFilterComposer get grammarLessonId {
    final $GrammarLessonsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsFilterComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GrammarExamplesOrderingComposer
    extends Composer<_$AppDatabase, GrammarExamples> {
  $GrammarExamplesOrderingComposer({
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

  ColumnOrderings<String> get sentence => $composableBuilder(
    column: $table.sentence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get highlight => $composableBuilder(
    column: $table.highlight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $GrammarLessonsOrderingComposer get grammarLessonId {
    final $GrammarLessonsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsOrderingComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GrammarExamplesAnnotationComposer
    extends Composer<_$AppDatabase, GrammarExamples> {
  $GrammarExamplesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sentence =>
      $composableBuilder(column: $table.sentence, builder: (column) => column);

  GeneratedColumn<String> get translation => $composableBuilder(
    column: $table.translation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get highlight =>
      $composableBuilder(column: $table.highlight, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $GrammarLessonsAnnotationComposer get grammarLessonId {
    final $GrammarLessonsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsAnnotationComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $GrammarExamplesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          GrammarExamples,
          GrammarExample,
          $GrammarExamplesFilterComposer,
          $GrammarExamplesOrderingComposer,
          $GrammarExamplesAnnotationComposer,
          $GrammarExamplesCreateCompanionBuilder,
          $GrammarExamplesUpdateCompanionBuilder,
          (GrammarExample, $GrammarExamplesReferences),
          GrammarExample,
          PrefetchHooks Function({bool grammarLessonId})
        > {
  $GrammarExamplesTableManager(_$AppDatabase db, GrammarExamples table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $GrammarExamplesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $GrammarExamplesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $GrammarExamplesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> grammarLessonId = const Value.absent(),
                Value<String> sentence = const Value.absent(),
                Value<String?> translation = const Value.absent(),
                Value<String?> highlight = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarExamplesCompanion(
                id: id,
                grammarLessonId: grammarLessonId,
                sentence: sentence,
                translation: translation,
                highlight: highlight,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String grammarLessonId,
                required String sentence,
                Value<String?> translation = const Value.absent(),
                Value<String?> highlight = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GrammarExamplesCompanion.insert(
                id: id,
                grammarLessonId: grammarLessonId,
                sentence: sentence,
                translation: translation,
                highlight: highlight,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<GrammarExamples, GrammarExample>(table),
                  $GrammarExamplesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarLessonId = false}) {
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
                    if (grammarLessonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.grammarLessonId,
                        referencedTable: $GrammarExamplesReferences
                            ._grammarLessonIdTable(db),
                        referencedColumn: $GrammarExamplesReferences
                            ._grammarLessonIdTable(db)
                            .id,
                      ) as T;
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

typedef $GrammarExamplesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      GrammarExamples,
      GrammarExample,
      $GrammarExamplesFilterComposer,
      $GrammarExamplesOrderingComposer,
      $GrammarExamplesAnnotationComposer,
      $GrammarExamplesCreateCompanionBuilder,
      $GrammarExamplesUpdateCompanionBuilder,
      (GrammarExample, $GrammarExamplesReferences),
      GrammarExample,
      PrefetchHooks Function({bool grammarLessonId})
    >;
typedef $QuizzesCreateCompanionBuilder = QuizzesCompanion Function({
  required String id,
  required String title,
  required String quizType,
  Value<String?> topicId,
  Value<String?> grammarLessonId,
  Value<int?> timeLimitSeconds,
  Value<int> passScorePercent,
  required int serverUpdatedAt,
  Value<int> rowid,
});
typedef $QuizzesUpdateCompanionBuilder = QuizzesCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> quizType,
  Value<String?> topicId,
  Value<String?> grammarLessonId,
  Value<int?> timeLimitSeconds,
  Value<int> passScorePercent,
  Value<int> serverUpdatedAt,
  Value<int> rowid,
});

final class $QuizzesReferences
    extends BaseReferences<_$AppDatabase, Quizzes, Quizze> {
  $QuizzesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Topics _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('quizzes__topic_id__topics__id');

  $TopicsProcessedTableManager? get topicId {
    final $_column = $_itemColumn<String>('topic_id');
    if ($_column == null) return null;
    final manager = $TopicsTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static GrammarLessons _grammarLessonIdTable(_$AppDatabase db) => db
      .grammarLessons
      .createAlias('quizzes__grammar_lesson_id__grammar_lessons__id');

  $GrammarLessonsProcessedTableManager? get grammarLessonId {
    final $_column = $_itemColumn<String>('grammar_lesson_id');
    if ($_column == null) return null;
    final manager = $GrammarLessonsTableManager(
      $_db,
      $_db.grammarLessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarLessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<QuizQuestions, List<QuizQuestion>>
  _quizQuestionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quizQuestions,
    aliasName: 'quizzes__id__quiz_questions__quiz_id',
  );

  $QuizQuestionsProcessedTableManager get quizQuestionsRefs {
    final manager = $QuizQuestionsTableManager(
      $_db,
      $_db.quizQuestions,
    ).filter((f) => f.quizId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quizQuestionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<QuizAttempts, List<QuizAttempt>>
  _quizAttemptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quizAttempts,
    aliasName: 'quizzes__id__quiz_attempts__quiz_id',
  );

  $QuizAttemptsProcessedTableManager get quizAttemptsRefs {
    final manager = $QuizAttemptsTableManager(
      $_db,
      $_db.quizAttempts,
    ).filter((f) => f.quizId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quizAttemptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $QuizzesFilterComposer extends Composer<_$AppDatabase, Quizzes> {
  $QuizzesFilterComposer({
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

  ColumnFilters<String> get quizType => $composableBuilder(
    column: $table.quizType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeLimitSeconds => $composableBuilder(
    column: $table.timeLimitSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passScorePercent => $composableBuilder(
    column: $table.passScorePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $TopicsFilterComposer get topicId {
    final $TopicsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GrammarLessonsFilterComposer get grammarLessonId {
    final $GrammarLessonsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsFilterComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> quizQuestionsRefs(
    Expression<bool> Function($QuizQuestionsFilterComposer f) f,
  ) {
    final $QuizQuestionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.quizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsFilterComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quizAttemptsRefs(
    Expression<bool> Function($QuizAttemptsFilterComposer f) f,
  ) {
    final $QuizAttemptsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.quizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptsFilterComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuizzesOrderingComposer extends Composer<_$AppDatabase, Quizzes> {
  $QuizzesOrderingComposer({
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

  ColumnOrderings<String> get quizType => $composableBuilder(
    column: $table.quizType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeLimitSeconds => $composableBuilder(
    column: $table.timeLimitSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passScorePercent => $composableBuilder(
    column: $table.passScorePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $TopicsOrderingComposer get topicId {
    final $TopicsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GrammarLessonsOrderingComposer get grammarLessonId {
    final $GrammarLessonsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsOrderingComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizzesAnnotationComposer extends Composer<_$AppDatabase, Quizzes> {
  $QuizzesAnnotationComposer({
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

  GeneratedColumn<String> get quizType =>
      $composableBuilder(column: $table.quizType, builder: (column) => column);

  GeneratedColumn<int> get timeLimitSeconds => $composableBuilder(
    column: $table.timeLimitSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passScorePercent => $composableBuilder(
    column: $table.passScorePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  $TopicsAnnotationComposer get topicId {
    final $TopicsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GrammarLessonsAnnotationComposer get grammarLessonId {
    final $GrammarLessonsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsAnnotationComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> quizQuestionsRefs<T extends Object>(
    Expression<T> Function($QuizQuestionsAnnotationComposer a) f,
  ) {
    final $QuizQuestionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.quizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsAnnotationComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quizAttemptsRefs<T extends Object>(
    Expression<T> Function($QuizAttemptsAnnotationComposer a) f,
  ) {
    final $QuizAttemptsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.quizId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptsAnnotationComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuizzesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          Quizzes,
          Quizze,
          $QuizzesFilterComposer,
          $QuizzesOrderingComposer,
          $QuizzesAnnotationComposer,
          $QuizzesCreateCompanionBuilder,
          $QuizzesUpdateCompanionBuilder,
          (Quizze, $QuizzesReferences),
          Quizze,
          PrefetchHooks Function({
            bool topicId,
            bool grammarLessonId,
            bool quizQuestionsRefs,
            bool quizAttemptsRefs,
          })
        > {
  $QuizzesTableManager(_$AppDatabase db, Quizzes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuizzesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuizzesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuizzesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> quizType = const Value.absent(),
                Value<String?> topicId = const Value.absent(),
                Value<String?> grammarLessonId = const Value.absent(),
                Value<int?> timeLimitSeconds = const Value.absent(),
                Value<int> passScorePercent = const Value.absent(),
                Value<int> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizzesCompanion(
                id: id,
                title: title,
                quizType: quizType,
                topicId: topicId,
                grammarLessonId: grammarLessonId,
                timeLimitSeconds: timeLimitSeconds,
                passScorePercent: passScorePercent,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String quizType,
                Value<String?> topicId = const Value.absent(),
                Value<String?> grammarLessonId = const Value.absent(),
                Value<int?> timeLimitSeconds = const Value.absent(),
                Value<int> passScorePercent = const Value.absent(),
                required int serverUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => QuizzesCompanion.insert(
                id: id,
                title: title,
                quizType: quizType,
                topicId: topicId,
                grammarLessonId: grammarLessonId,
                timeLimitSeconds: timeLimitSeconds,
                passScorePercent: passScorePercent,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<Quizzes, Quizze>(table),
                  $QuizzesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                topicId = false,
                grammarLessonId = false,
                quizQuestionsRefs = false,
                quizAttemptsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (quizQuestionsRefs) db.quizQuestions,
                    if (quizAttemptsRefs) db.quizAttempts,
                  ],
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
                        if (topicId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.topicId,
                            referencedTable: $QuizzesReferences._topicIdTable(
                              db,
                            ),
                            referencedColumn: $QuizzesReferences
                                ._topicIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (grammarLessonId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.grammarLessonId,
                            referencedTable: $QuizzesReferences
                                ._grammarLessonIdTable(db),
                            referencedColumn: $QuizzesReferences
                                ._grammarLessonIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (quizQuestionsRefs)
                        await $_getPrefetchedData<
                          Quizze,
                          Quizzes,
                          QuizQuestion
                        >(
                          currentTable: table,
                          referencedTable: $QuizzesReferences
                              ._quizQuestionsRefsTable(db),
                          managerFromTypedResult: (p0) => $QuizzesReferences(
                            db,
                            table,
                            p0,
                          ).quizQuestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.quizId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quizAttemptsRefs)
                        await $_getPrefetchedData<Quizze, Quizzes, QuizAttempt>(
                          currentTable: table,
                          referencedTable: $QuizzesReferences
                              ._quizAttemptsRefsTable(db),
                          managerFromTypedResult: (p0) => $QuizzesReferences(
                            db,
                            table,
                            p0,
                          ).quizAttemptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.quizId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $QuizzesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      Quizzes,
      Quizze,
      $QuizzesFilterComposer,
      $QuizzesOrderingComposer,
      $QuizzesAnnotationComposer,
      $QuizzesCreateCompanionBuilder,
      $QuizzesUpdateCompanionBuilder,
      (Quizze, $QuizzesReferences),
      Quizze,
      PrefetchHooks Function({
        bool topicId,
        bool grammarLessonId,
        bool quizQuestionsRefs,
        bool quizAttemptsRefs,
      })
    >;
typedef $QuizQuestionsCreateCompanionBuilder = QuizQuestionsCompanion Function({
  required String id,
  required String quizId,
  Value<String?> flashcardId,
  required String questionText,
  required int correctOptionIndex,
  Value<String?> explanation,
  Value<int> sortOrder,
  Value<int> rowid,
});
typedef $QuizQuestionsUpdateCompanionBuilder = QuizQuestionsCompanion Function({
  Value<String> id,
  Value<String> quizId,
  Value<String?> flashcardId,
  Value<String> questionText,
  Value<int> correctOptionIndex,
  Value<String?> explanation,
  Value<int> sortOrder,
  Value<int> rowid,
});

final class $QuizQuestionsReferences
    extends BaseReferences<_$AppDatabase, QuizQuestions, QuizQuestion> {
  $QuizQuestionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Quizzes _quizIdTable(_$AppDatabase db) =>
      db.quizzes.createAlias('quiz_questions__quiz_id__quizzes__id');

  $QuizzesProcessedTableManager get quizId {
    final $_column = $_itemColumn<String>('quiz_id')!;

    final manager = $QuizzesTableManager(
      $_db,
      $_db.quizzes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quizIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<QuizQuestionOptions, List<QuizQuestionOption>>
  _quizQuestionOptionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.quizQuestionOptions,
        aliasName: 'quiz_questions__id__quiz_question_options__question_id',
      );

  $QuizQuestionOptionsProcessedTableManager get quizQuestionOptionsRefs {
    final manager = $QuizQuestionOptionsTableManager(
      $_db,
      $_db.quizQuestionOptions,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _quizQuestionOptionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<QuizAttemptAnswers, List<QuizAttemptAnswer>>
  _quizAttemptAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.quizAttemptAnswers,
        aliasName: 'quiz_questions__id__quiz_attempt_answers__question_id',
      );

  $QuizAttemptAnswersProcessedTableManager get quizAttemptAnswersRefs {
    final manager = $QuizAttemptAnswersTableManager(
      $_db,
      $_db.quizAttemptAnswers,
    ).filter((f) => f.questionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _quizAttemptAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $QuizQuestionsFilterComposer
    extends Composer<_$AppDatabase, QuizQuestions> {
  $QuizQuestionsFilterComposer({
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

  ColumnFilters<String> get flashcardId => $composableBuilder(
    column: $table.flashcardId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctOptionIndex => $composableBuilder(
    column: $table.correctOptionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $QuizzesFilterComposer get quizId {
    final $QuizzesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesFilterComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> quizQuestionOptionsRefs(
    Expression<bool> Function($QuizQuestionOptionsFilterComposer f) f,
  ) {
    final $QuizQuestionOptionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizQuestionOptions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionOptionsFilterComposer(
            $db: $db,
            $table: $db.quizQuestionOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quizAttemptAnswersRefs(
    Expression<bool> Function($QuizAttemptAnswersFilterComposer f) f,
  ) {
    final $QuizAttemptAnswersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAttemptAnswers,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptAnswersFilterComposer(
            $db: $db,
            $table: $db.quizAttemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuizQuestionsOrderingComposer
    extends Composer<_$AppDatabase, QuizQuestions> {
  $QuizQuestionsOrderingComposer({
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

  ColumnOrderings<String> get flashcardId => $composableBuilder(
    column: $table.flashcardId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctOptionIndex => $composableBuilder(
    column: $table.correctOptionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $QuizzesOrderingComposer get quizId {
    final $QuizzesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesOrderingComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizQuestionsAnnotationComposer
    extends Composer<_$AppDatabase, QuizQuestions> {
  $QuizQuestionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get flashcardId => $composableBuilder(
    column: $table.flashcardId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctOptionIndex => $composableBuilder(
    column: $table.correctOptionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get explanation => $composableBuilder(
    column: $table.explanation,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $QuizzesAnnotationComposer get quizId {
    final $QuizzesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesAnnotationComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> quizQuestionOptionsRefs<T extends Object>(
    Expression<T> Function($QuizQuestionOptionsAnnotationComposer a) f,
  ) {
    final $QuizQuestionOptionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizQuestionOptions,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionOptionsAnnotationComposer(
            $db: $db,
            $table: $db.quizQuestionOptions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quizAttemptAnswersRefs<T extends Object>(
    Expression<T> Function($QuizAttemptAnswersAnnotationComposer a) f,
  ) {
    final $QuizAttemptAnswersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAttemptAnswers,
      getReferencedColumn: (t) => t.questionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptAnswersAnnotationComposer(
            $db: $db,
            $table: $db.quizAttemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuizQuestionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          QuizQuestions,
          QuizQuestion,
          $QuizQuestionsFilterComposer,
          $QuizQuestionsOrderingComposer,
          $QuizQuestionsAnnotationComposer,
          $QuizQuestionsCreateCompanionBuilder,
          $QuizQuestionsUpdateCompanionBuilder,
          (QuizQuestion, $QuizQuestionsReferences),
          QuizQuestion,
          PrefetchHooks Function({
            bool quizId,
            bool quizQuestionOptionsRefs,
            bool quizAttemptAnswersRefs,
          })
        > {
  $QuizQuestionsTableManager(_$AppDatabase db, QuizQuestions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuizQuestionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuizQuestionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuizQuestionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> quizId = const Value.absent(),
                Value<String?> flashcardId = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<int> correctOptionIndex = const Value.absent(),
                Value<String?> explanation = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizQuestionsCompanion(
                id: id,
                quizId: quizId,
                flashcardId: flashcardId,
                questionText: questionText,
                correctOptionIndex: correctOptionIndex,
                explanation: explanation,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String quizId,
                Value<String?> flashcardId = const Value.absent(),
                required String questionText,
                required int correctOptionIndex,
                Value<String?> explanation = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizQuestionsCompanion.insert(
                id: id,
                quizId: quizId,
                flashcardId: flashcardId,
                questionText: questionText,
                correctOptionIndex: correctOptionIndex,
                explanation: explanation,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<QuizQuestions, QuizQuestion>(table),
                  $QuizQuestionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                quizId = false,
                quizQuestionOptionsRefs = false,
                quizAttemptAnswersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (quizQuestionOptionsRefs) db.quizQuestionOptions,
                    if (quizAttemptAnswersRefs) db.quizAttemptAnswers,
                  ],
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
                        if (quizId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.quizId,
                            referencedTable: $QuizQuestionsReferences
                                ._quizIdTable(db),
                            referencedColumn: $QuizQuestionsReferences
                                ._quizIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (quizQuestionOptionsRefs)
                        await $_getPrefetchedData<
                          QuizQuestion,
                          QuizQuestions,
                          QuizQuestionOption
                        >(
                          currentTable: table,
                          referencedTable: $QuizQuestionsReferences
                              ._quizQuestionOptionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $QuizQuestionsReferences(
                                db,
                                table,
                                p0,
                              ).quizQuestionOptionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quizAttemptAnswersRefs)
                        await $_getPrefetchedData<
                          QuizQuestion,
                          QuizQuestions,
                          QuizAttemptAnswer
                        >(
                          currentTable: table,
                          referencedTable: $QuizQuestionsReferences
                              ._quizAttemptAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $QuizQuestionsReferences(
                                db,
                                table,
                                p0,
                              ).quizAttemptAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.questionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $QuizQuestionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      QuizQuestions,
      QuizQuestion,
      $QuizQuestionsFilterComposer,
      $QuizQuestionsOrderingComposer,
      $QuizQuestionsAnnotationComposer,
      $QuizQuestionsCreateCompanionBuilder,
      $QuizQuestionsUpdateCompanionBuilder,
      (QuizQuestion, $QuizQuestionsReferences),
      QuizQuestion,
      PrefetchHooks Function({
        bool quizId,
        bool quizQuestionOptionsRefs,
        bool quizAttemptAnswersRefs,
      })
    >;
typedef $QuizQuestionOptionsCreateCompanionBuilder =
    QuizQuestionOptionsCompanion Function({
      required String questionId,
      required int optionIndex,
      required String optionText,
    });
typedef $QuizQuestionOptionsUpdateCompanionBuilder =
    QuizQuestionOptionsCompanion Function({
      Value<String> questionId,
      Value<int> optionIndex,
      Value<String> optionText,
    });

final class $QuizQuestionOptionsReferences
    extends
        BaseReferences<_$AppDatabase, QuizQuestionOptions, QuizQuestionOption> {
  $QuizQuestionOptionsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static QuizQuestions _questionIdTable(_$AppDatabase db) => db.quizQuestions
      .createAlias('quiz_question_options__question_id__quiz_questions__id');

  $QuizQuestionsProcessedTableManager get questionId {
    final $_column = $_itemColumn<String>('question_id')!;

    final manager = $QuizQuestionsTableManager(
      $_db,
      $_db.quizQuestions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $QuizQuestionOptionsFilterComposer
    extends Composer<_$AppDatabase, QuizQuestionOptions> {
  $QuizQuestionOptionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get optionIndex => $composableBuilder(
    column: $table.optionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnFilters(column),
  );

  $QuizQuestionsFilterComposer get questionId {
    final $QuizQuestionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsFilterComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizQuestionOptionsOrderingComposer
    extends Composer<_$AppDatabase, QuizQuestionOptions> {
  $QuizQuestionOptionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get optionIndex => $composableBuilder(
    column: $table.optionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => ColumnOrderings(column),
  );

  $QuizQuestionsOrderingComposer get questionId {
    final $QuizQuestionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsOrderingComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizQuestionOptionsAnnotationComposer
    extends Composer<_$AppDatabase, QuizQuestionOptions> {
  $QuizQuestionOptionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get optionIndex => $composableBuilder(
    column: $table.optionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get optionText => $composableBuilder(
    column: $table.optionText,
    builder: (column) => column,
  );

  $QuizQuestionsAnnotationComposer get questionId {
    final $QuizQuestionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsAnnotationComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizQuestionOptionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          QuizQuestionOptions,
          QuizQuestionOption,
          $QuizQuestionOptionsFilterComposer,
          $QuizQuestionOptionsOrderingComposer,
          $QuizQuestionOptionsAnnotationComposer,
          $QuizQuestionOptionsCreateCompanionBuilder,
          $QuizQuestionOptionsUpdateCompanionBuilder,
          (QuizQuestionOption, $QuizQuestionOptionsReferences),
          QuizQuestionOption,
          PrefetchHooks Function({bool questionId})
        > {
  $QuizQuestionOptionsTableManager(_$AppDatabase db, QuizQuestionOptions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuizQuestionOptionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuizQuestionOptionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuizQuestionOptionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> questionId = const Value.absent(),
                Value<int> optionIndex = const Value.absent(),
                Value<String> optionText = const Value.absent(),
              }) => QuizQuestionOptionsCompanion(
                questionId: questionId,
                optionIndex: optionIndex,
                optionText: optionText,
              ),
          createCompanionCallback:
              ({
                required String questionId,
                required int optionIndex,
                required String optionText,
              }) => QuizQuestionOptionsCompanion.insert(
                questionId: questionId,
                optionIndex: optionIndex,
                optionText: optionText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<QuizQuestionOptions, QuizQuestionOption>(table),
                  $QuizQuestionOptionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
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
                    if (questionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questionId,
                        referencedTable: $QuizQuestionOptionsReferences
                            ._questionIdTable(db),
                        referencedColumn: $QuizQuestionOptionsReferences
                            ._questionIdTable(db)
                            .id,
                      ) as T;
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

typedef $QuizQuestionOptionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      QuizQuestionOptions,
      QuizQuestionOption,
      $QuizQuestionOptionsFilterComposer,
      $QuizQuestionOptionsOrderingComposer,
      $QuizQuestionOptionsAnnotationComposer,
      $QuizQuestionOptionsCreateCompanionBuilder,
      $QuizQuestionOptionsUpdateCompanionBuilder,
      (QuizQuestionOption, $QuizQuestionOptionsReferences),
      QuizQuestionOption,
      PrefetchHooks Function({bool questionId})
    >;
typedef $QuestDefinitionsCreateCompanionBuilder =
    QuestDefinitionsCompanion Function({
      required String id,
      required String code,
      required String title,
      required String questType,
      Value<String> frequency,
      required int targetValue,
      required int xpReward,
      required String iconName,
      Value<int> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $QuestDefinitionsUpdateCompanionBuilder =
    QuestDefinitionsCompanion Function({
      Value<String> id,
      Value<String> code,
      Value<String> title,
      Value<String> questType,
      Value<String> frequency,
      Value<int> targetValue,
      Value<int> xpReward,
      Value<String> iconName,
      Value<int> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $QuestDefinitionsReferences
    extends BaseReferences<_$AppDatabase, QuestDefinitions, QuestDefinition> {
  $QuestDefinitionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<UserQuests, List<UserQuest>> _userQuestsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.userQuests,
    aliasName: 'quest_definitions__id__user_quests__quest_definition_id',
  );

  $UserQuestsProcessedTableManager get userQuestsRefs {
    final manager = $UserQuestsTableManager($_db, $_db.userQuests).filter(
      (f) => f.questDefinitionId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_userQuestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $QuestDefinitionsFilterComposer
    extends Composer<_$AppDatabase, QuestDefinitions> {
  $QuestDefinitionsFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questType => $composableBuilder(
    column: $table.questType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userQuestsRefs(
    Expression<bool> Function($UserQuestsFilterComposer f) f,
  ) {
    final $UserQuestsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userQuests,
      getReferencedColumn: (t) => t.questDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserQuestsFilterComposer(
            $db: $db,
            $table: $db.userQuests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuestDefinitionsOrderingComposer
    extends Composer<_$AppDatabase, QuestDefinitions> {
  $QuestDefinitionsOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questType => $composableBuilder(
    column: $table.questType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $QuestDefinitionsAnnotationComposer
    extends Composer<_$AppDatabase, QuestDefinitions> {
  $QuestDefinitionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get questType =>
      $composableBuilder(column: $table.questType, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> userQuestsRefs<T extends Object>(
    Expression<T> Function($UserQuestsAnnotationComposer a) f,
  ) {
    final $UserQuestsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userQuests,
      getReferencedColumn: (t) => t.questDefinitionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserQuestsAnnotationComposer(
            $db: $db,
            $table: $db.userQuests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuestDefinitionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          QuestDefinitions,
          QuestDefinition,
          $QuestDefinitionsFilterComposer,
          $QuestDefinitionsOrderingComposer,
          $QuestDefinitionsAnnotationComposer,
          $QuestDefinitionsCreateCompanionBuilder,
          $QuestDefinitionsUpdateCompanionBuilder,
          (QuestDefinition, $QuestDefinitionsReferences),
          QuestDefinition,
          PrefetchHooks Function({bool userQuestsRefs})
        > {
  $QuestDefinitionsTableManager(_$AppDatabase db, QuestDefinitions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuestDefinitionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuestDefinitionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuestDefinitionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> questType = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<String> iconName = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestDefinitionsCompanion(
                id: id,
                code: code,
                title: title,
                questType: questType,
                frequency: frequency,
                targetValue: targetValue,
                xpReward: xpReward,
                iconName: iconName,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String title,
                required String questType,
                Value<String> frequency = const Value.absent(),
                required int targetValue,
                required int xpReward,
                required String iconName,
                Value<int> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestDefinitionsCompanion.insert(
                id: id,
                code: code,
                title: title,
                questType: questType,
                frequency: frequency,
                targetValue: targetValue,
                xpReward: xpReward,
                iconName: iconName,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<QuestDefinitions, QuestDefinition>(table),
                  $QuestDefinitionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userQuestsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userQuestsRefs) db.userQuests],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userQuestsRefs)
                    await $_getPrefetchedData<
                      QuestDefinition,
                      QuestDefinitions,
                      UserQuest
                    >(
                      currentTable: table,
                      referencedTable: $QuestDefinitionsReferences
                          ._userQuestsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $QuestDefinitionsReferences(
                            db,
                            table,
                            p0,
                          ).userQuestsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.questDefinitionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $QuestDefinitionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      QuestDefinitions,
      QuestDefinition,
      $QuestDefinitionsFilterComposer,
      $QuestDefinitionsOrderingComposer,
      $QuestDefinitionsAnnotationComposer,
      $QuestDefinitionsCreateCompanionBuilder,
      $QuestDefinitionsUpdateCompanionBuilder,
      (QuestDefinition, $QuestDefinitionsReferences),
      QuestDefinition,
      PrefetchHooks Function({bool userQuestsRefs})
    >;
typedef $RewardItemsCreateCompanionBuilder = RewardItemsCompanion Function({
  required String id,
  required String code,
  required String name,
  required String itemType,
  Value<int> xpCost,
  Value<String?> borderColors,
  Value<String?> imageUrl,
  Value<int> requiredRank,
  Value<String> rankBoard,
  Value<int> isActive,
  Value<int> sortOrder,
  required int serverUpdatedAt,
  Value<int> rowid,
});
typedef $RewardItemsUpdateCompanionBuilder = RewardItemsCompanion Function({
  Value<String> id,
  Value<String> code,
  Value<String> name,
  Value<String> itemType,
  Value<int> xpCost,
  Value<String?> borderColors,
  Value<String?> imageUrl,
  Value<int> requiredRank,
  Value<String> rankBoard,
  Value<int> isActive,
  Value<int> sortOrder,
  Value<int> serverUpdatedAt,
  Value<int> rowid,
});

final class $RewardItemsReferences
    extends BaseReferences<_$AppDatabase, RewardItems, RewardItem> {
  $RewardItemsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<UserInventories, List<UserInventory>>
  _userInventoriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.userInventories,
    aliasName: 'reward_items__id__user_inventories__reward_item_id',
  );

  $UserInventoriesProcessedTableManager get userInventoriesRefs {
    final manager = $UserInventoriesTableManager(
      $_db,
      $_db.userInventories,
    ).filter((f) => f.rewardItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userInventoriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $RewardItemsFilterComposer extends Composer<_$AppDatabase, RewardItems> {
  $RewardItemsFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpCost => $composableBuilder(
    column: $table.xpCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get borderColors => $composableBuilder(
    column: $table.borderColors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requiredRank => $composableBuilder(
    column: $table.requiredRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rankBoard => $composableBuilder(
    column: $table.rankBoard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userInventoriesRefs(
    Expression<bool> Function($UserInventoriesFilterComposer f) f,
  ) {
    final $UserInventoriesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userInventories,
      getReferencedColumn: (t) => t.rewardItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserInventoriesFilterComposer(
            $db: $db,
            $table: $db.userInventories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $RewardItemsOrderingComposer
    extends Composer<_$AppDatabase, RewardItems> {
  $RewardItemsOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpCost => $composableBuilder(
    column: $table.xpCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get borderColors => $composableBuilder(
    column: $table.borderColors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imageUrl => $composableBuilder(
    column: $table.imageUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requiredRank => $composableBuilder(
    column: $table.requiredRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rankBoard => $composableBuilder(
    column: $table.rankBoard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $RewardItemsAnnotationComposer
    extends Composer<_$AppDatabase, RewardItems> {
  $RewardItemsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get xpCost =>
      $composableBuilder(column: $table.xpCost, builder: (column) => column);

  GeneratedColumn<String> get borderColors => $composableBuilder(
    column: $table.borderColors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<int> get requiredRank => $composableBuilder(
    column: $table.requiredRank,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rankBoard =>
      $composableBuilder(column: $table.rankBoard, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get serverUpdatedAt => $composableBuilder(
    column: $table.serverUpdatedAt,
    builder: (column) => column,
  );

  Expression<T> userInventoriesRefs<T extends Object>(
    Expression<T> Function($UserInventoriesAnnotationComposer a) f,
  ) {
    final $UserInventoriesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userInventories,
      getReferencedColumn: (t) => t.rewardItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $UserInventoriesAnnotationComposer(
            $db: $db,
            $table: $db.userInventories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $RewardItemsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          RewardItems,
          RewardItem,
          $RewardItemsFilterComposer,
          $RewardItemsOrderingComposer,
          $RewardItemsAnnotationComposer,
          $RewardItemsCreateCompanionBuilder,
          $RewardItemsUpdateCompanionBuilder,
          (RewardItem, $RewardItemsReferences),
          RewardItem,
          PrefetchHooks Function({bool userInventoriesRefs})
        > {
  $RewardItemsTableManager(_$AppDatabase db, RewardItems table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $RewardItemsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $RewardItemsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $RewardItemsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> xpCost = const Value.absent(),
                Value<String?> borderColors = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> requiredRank = const Value.absent(),
                Value<String> rankBoard = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> serverUpdatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RewardItemsCompanion(
                id: id,
                code: code,
                name: name,
                itemType: itemType,
                xpCost: xpCost,
                borderColors: borderColors,
                imageUrl: imageUrl,
                requiredRank: requiredRank,
                rankBoard: rankBoard,
                isActive: isActive,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String code,
                required String name,
                required String itemType,
                Value<int> xpCost = const Value.absent(),
                Value<String?> borderColors = const Value.absent(),
                Value<String?> imageUrl = const Value.absent(),
                Value<int> requiredRank = const Value.absent(),
                Value<String> rankBoard = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required int serverUpdatedAt,
                Value<int> rowid = const Value.absent(),
              }) => RewardItemsCompanion.insert(
                id: id,
                code: code,
                name: name,
                itemType: itemType,
                xpCost: xpCost,
                borderColors: borderColors,
                imageUrl: imageUrl,
                requiredRank: requiredRank,
                rankBoard: rankBoard,
                isActive: isActive,
                sortOrder: sortOrder,
                serverUpdatedAt: serverUpdatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<RewardItems, RewardItem>(table),
                  $RewardItemsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userInventoriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userInventoriesRefs) db.userInventories,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userInventoriesRefs)
                    await $_getPrefetchedData<
                      RewardItem,
                      RewardItems,
                      UserInventory
                    >(
                      currentTable: table,
                      referencedTable: $RewardItemsReferences
                          ._userInventoriesRefsTable(db),
                      managerFromTypedResult: (p0) => $RewardItemsReferences(
                        db,
                        table,
                        p0,
                      ).userInventoriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.rewardItemId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $RewardItemsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      RewardItems,
      RewardItem,
      $RewardItemsFilterComposer,
      $RewardItemsOrderingComposer,
      $RewardItemsAnnotationComposer,
      $RewardItemsCreateCompanionBuilder,
      $RewardItemsUpdateCompanionBuilder,
      (RewardItem, $RewardItemsReferences),
      RewardItem,
      PrefetchHooks Function({bool userInventoriesRefs})
    >;
typedef $LeaderboardCacheCreateCompanionBuilder =
    LeaderboardCacheCompanion Function({
      required String board,
      required int rankNo,
      required String userId,
      required String fullName,
      Value<String?> avatarUrl,
      required int score,
      required int fetchedAt,
    });
typedef $LeaderboardCacheUpdateCompanionBuilder =
    LeaderboardCacheCompanion Function({
      Value<String> board,
      Value<int> rankNo,
      Value<String> userId,
      Value<String> fullName,
      Value<String?> avatarUrl,
      Value<int> score,
      Value<int> fetchedAt,
    });

class $LeaderboardCacheFilterComposer
    extends Composer<_$AppDatabase, LeaderboardCache> {
  $LeaderboardCacheFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get board => $composableBuilder(
    column: $table.board,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rankNo => $composableBuilder(
    column: $table.rankNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $LeaderboardCacheOrderingComposer
    extends Composer<_$AppDatabase, LeaderboardCache> {
  $LeaderboardCacheOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get board => $composableBuilder(
    column: $table.board,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rankNo => $composableBuilder(
    column: $table.rankNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $LeaderboardCacheAnnotationComposer
    extends Composer<_$AppDatabase, LeaderboardCache> {
  $LeaderboardCacheAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get board =>
      $composableBuilder(column: $table.board, builder: (column) => column);

  GeneratedColumn<int> get rankNo =>
      $composableBuilder(column: $table.rankNo, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);
}

class $LeaderboardCacheTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LeaderboardCache,
          LeaderboardCacheData,
          $LeaderboardCacheFilterComposer,
          $LeaderboardCacheOrderingComposer,
          $LeaderboardCacheAnnotationComposer,
          $LeaderboardCacheCreateCompanionBuilder,
          $LeaderboardCacheUpdateCompanionBuilder,
          (
            LeaderboardCacheData,
            BaseReferences<
              _$AppDatabase,
              LeaderboardCache,
              LeaderboardCacheData
            >,
          ),
          LeaderboardCacheData,
          PrefetchHooks Function()
        > {
  $LeaderboardCacheTableManager(_$AppDatabase db, LeaderboardCache table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LeaderboardCacheFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LeaderboardCacheOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LeaderboardCacheAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> board = const Value.absent(),
                Value<int> rankNo = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<int> fetchedAt = const Value.absent(),
              }) => LeaderboardCacheCompanion(
                board: board,
                rankNo: rankNo,
                userId: userId,
                fullName: fullName,
                avatarUrl: avatarUrl,
                score: score,
                fetchedAt: fetchedAt,
              ),
          createCompanionCallback:
              ({
                required String board,
                required int rankNo,
                required String userId,
                required String fullName,
                Value<String?> avatarUrl = const Value.absent(),
                required int score,
                required int fetchedAt,
              }) => LeaderboardCacheCompanion.insert(
                board: board,
                rankNo: rankNo,
                userId: userId,
                fullName: fullName,
                avatarUrl: avatarUrl,
                score: score,
                fetchedAt: fetchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LeaderboardCache, LeaderboardCacheData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    LeaderboardCache,
                    LeaderboardCacheData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $LeaderboardCacheProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LeaderboardCache,
      LeaderboardCacheData,
      $LeaderboardCacheFilterComposer,
      $LeaderboardCacheOrderingComposer,
      $LeaderboardCacheAnnotationComposer,
      $LeaderboardCacheCreateCompanionBuilder,
      $LeaderboardCacheUpdateCompanionBuilder,
      (
        LeaderboardCacheData,
        BaseReferences<_$AppDatabase, LeaderboardCache, LeaderboardCacheData>,
      ),
      LeaderboardCacheData,
      PrefetchHooks Function()
    >;
typedef $UserProfileCreateCompanionBuilder = UserProfileCompanion Function({
  required String id,
  required String email,
  required String fullName,
  Value<String?> avatarUrl,
  Value<String> level,
  Value<String> slogan,
  Value<int> currentXp,
  Value<int> pendingXp,
  Value<int> targetXp,
  Value<int> totalLifetimeXp,
  Value<int> streakDays,
  Value<int> longestStreak,
  Value<String?> lastActiveDate,
  Value<int> totalWordsLearned,
  Value<int> completedLessons,
  Value<int> version,
  Value<int?> clientUpdatedAt,
  Value<int> isDirty,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});
typedef $UserProfileUpdateCompanionBuilder = UserProfileCompanion Function({
  Value<String> id,
  Value<String> email,
  Value<String> fullName,
  Value<String?> avatarUrl,
  Value<String> level,
  Value<String> slogan,
  Value<int> currentXp,
  Value<int> pendingXp,
  Value<int> targetXp,
  Value<int> totalLifetimeXp,
  Value<int> streakDays,
  Value<int> longestStreak,
  Value<String?> lastActiveDate,
  Value<int> totalWordsLearned,
  Value<int> completedLessons,
  Value<int> version,
  Value<int?> clientUpdatedAt,
  Value<int> isDirty,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});

class $UserProfileFilterComposer extends Composer<_$AppDatabase, UserProfile> {
  $UserProfileFilterComposer({
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

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slogan => $composableBuilder(
    column: $table.slogan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentXp => $composableBuilder(
    column: $table.currentXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingXp => $composableBuilder(
    column: $table.pendingXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetXp => $composableBuilder(
    column: $table.targetXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalLifetimeXp => $composableBuilder(
    column: $table.totalLifetimeXp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalWordsLearned => $composableBuilder(
    column: $table.totalWordsLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedLessons => $composableBuilder(
    column: $table.completedLessons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $UserProfileOrderingComposer
    extends Composer<_$AppDatabase, UserProfile> {
  $UserProfileOrderingComposer({
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

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
    column: $table.avatarUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slogan => $composableBuilder(
    column: $table.slogan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentXp => $composableBuilder(
    column: $table.currentXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingXp => $composableBuilder(
    column: $table.pendingXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetXp => $composableBuilder(
    column: $table.targetXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalLifetimeXp => $composableBuilder(
    column: $table.totalLifetimeXp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalWordsLearned => $composableBuilder(
    column: $table.totalWordsLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedLessons => $composableBuilder(
    column: $table.completedLessons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $UserProfileAnnotationComposer
    extends Composer<_$AppDatabase, UserProfile> {
  $UserProfileAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get slogan =>
      $composableBuilder(column: $table.slogan, builder: (column) => column);

  GeneratedColumn<int> get currentXp =>
      $composableBuilder(column: $table.currentXp, builder: (column) => column);

  GeneratedColumn<int> get pendingXp =>
      $composableBuilder(column: $table.pendingXp, builder: (column) => column);

  GeneratedColumn<int> get targetXp =>
      $composableBuilder(column: $table.targetXp, builder: (column) => column);

  GeneratedColumn<int> get totalLifetimeXp => $composableBuilder(
    column: $table.totalLifetimeXp,
    builder: (column) => column,
  );

  GeneratedColumn<int> get streakDays => $composableBuilder(
    column: $table.streakDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestStreak => $composableBuilder(
    column: $table.longestStreak,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalWordsLearned => $composableBuilder(
    column: $table.totalWordsLearned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedLessons => $composableBuilder(
    column: $table.completedLessons,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $UserProfileTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserProfile,
          UserProfileData,
          $UserProfileFilterComposer,
          $UserProfileOrderingComposer,
          $UserProfileAnnotationComposer,
          $UserProfileCreateCompanionBuilder,
          $UserProfileUpdateCompanionBuilder,
          (
            UserProfileData,
            BaseReferences<_$AppDatabase, UserProfile, UserProfileData>,
          ),
          UserProfileData,
          PrefetchHooks Function()
        > {
  $UserProfileTableManager(_$AppDatabase db, UserProfile table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserProfileFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserProfileOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserProfileAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> slogan = const Value.absent(),
                Value<int> currentXp = const Value.absent(),
                Value<int> pendingXp = const Value.absent(),
                Value<int> targetXp = const Value.absent(),
                Value<int> totalLifetimeXp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastActiveDate = const Value.absent(),
                Value<int> totalWordsLearned = const Value.absent(),
                Value<int> completedLessons = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> clientUpdatedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfileCompanion(
                id: id,
                email: email,
                fullName: fullName,
                avatarUrl: avatarUrl,
                level: level,
                slogan: slogan,
                currentXp: currentXp,
                pendingXp: pendingXp,
                targetXp: targetXp,
                totalLifetimeXp: totalLifetimeXp,
                streakDays: streakDays,
                longestStreak: longestStreak,
                lastActiveDate: lastActiveDate,
                totalWordsLearned: totalWordsLearned,
                completedLessons: completedLessons,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                required String fullName,
                Value<String?> avatarUrl = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> slogan = const Value.absent(),
                Value<int> currentXp = const Value.absent(),
                Value<int> pendingXp = const Value.absent(),
                Value<int> targetXp = const Value.absent(),
                Value<int> totalLifetimeXp = const Value.absent(),
                Value<int> streakDays = const Value.absent(),
                Value<int> longestStreak = const Value.absent(),
                Value<String?> lastActiveDate = const Value.absent(),
                Value<int> totalWordsLearned = const Value.absent(),
                Value<int> completedLessons = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> clientUpdatedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserProfileCompanion.insert(
                id: id,
                email: email,
                fullName: fullName,
                avatarUrl: avatarUrl,
                level: level,
                slogan: slogan,
                currentXp: currentXp,
                pendingXp: pendingXp,
                targetXp: targetXp,
                totalLifetimeXp: totalLifetimeXp,
                streakDays: streakDays,
                longestStreak: longestStreak,
                lastActiveDate: lastActiveDate,
                totalWordsLearned: totalWordsLearned,
                completedLessons: completedLessons,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserProfile, UserProfileData>(table),
                  BaseReferences<_$AppDatabase, UserProfile, UserProfileData>(
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

typedef $UserProfileProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserProfile,
      UserProfileData,
      $UserProfileFilterComposer,
      $UserProfileOrderingComposer,
      $UserProfileAnnotationComposer,
      $UserProfileCreateCompanionBuilder,
      $UserProfileUpdateCompanionBuilder,
      (
        UserProfileData,
        BaseReferences<_$AppDatabase, UserProfile, UserProfileData>,
      ),
      UserProfileData,
      PrefetchHooks Function()
    >;
typedef $UserFlashcardProgressCreateCompanionBuilder =
    UserFlashcardProgressCompanion Function({
      required String flashcardId,
      Value<int> box,
      Value<int> repetitions,
      Value<int> againCount,
      Value<int> knowCount,
      Value<String?> lastRating,
      Value<int> isLearned,
      Value<int?> lastReviewedAt,
      Value<int?> dueAt,
      Value<int> version,
      Value<int?> clientUpdatedAt,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $UserFlashcardProgressUpdateCompanionBuilder =
    UserFlashcardProgressCompanion Function({
      Value<String> flashcardId,
      Value<int> box,
      Value<int> repetitions,
      Value<int> againCount,
      Value<int> knowCount,
      Value<String?> lastRating,
      Value<int> isLearned,
      Value<int?> lastReviewedAt,
      Value<int?> dueAt,
      Value<int> version,
      Value<int?> clientUpdatedAt,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $UserFlashcardProgressReferences
    extends
        BaseReferences<
          _$AppDatabase,
          UserFlashcardProgress,
          UserFlashcardProgressData
        > {
  $UserFlashcardProgressReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Flashcards _flashcardIdTable(_$AppDatabase db) => db.flashcards
      .createAlias('user_flashcard_progress__flashcard_id__flashcards__id');

  $FlashcardsProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $FlashcardsTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserFlashcardProgressFilterComposer
    extends Composer<_$AppDatabase, UserFlashcardProgress> {
  $UserFlashcardProgressFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get againCount => $composableBuilder(
    column: $table.againCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get knowCount => $composableBuilder(
    column: $table.knowCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastRating => $composableBuilder(
    column: $table.lastRating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $FlashcardsFilterComposer get flashcardId {
    final $FlashcardsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserFlashcardProgressOrderingComposer
    extends Composer<_$AppDatabase, UserFlashcardProgress> {
  $UserFlashcardProgressOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get box => $composableBuilder(
    column: $table.box,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get againCount => $composableBuilder(
    column: $table.againCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get knowCount => $composableBuilder(
    column: $table.knowCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastRating => $composableBuilder(
    column: $table.lastRating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isLearned => $composableBuilder(
    column: $table.isLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $FlashcardsOrderingComposer get flashcardId {
    final $FlashcardsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserFlashcardProgressAnnotationComposer
    extends Composer<_$AppDatabase, UserFlashcardProgress> {
  $UserFlashcardProgressAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get box =>
      $composableBuilder(column: $table.box, builder: (column) => column);

  GeneratedColumn<int> get repetitions => $composableBuilder(
    column: $table.repetitions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get againCount => $composableBuilder(
    column: $table.againCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get knowCount =>
      $composableBuilder(column: $table.knowCount, builder: (column) => column);

  GeneratedColumn<String> get lastRating => $composableBuilder(
    column: $table.lastRating,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isLearned =>
      $composableBuilder(column: $table.isLearned, builder: (column) => column);

  GeneratedColumn<int> get lastReviewedAt => $composableBuilder(
    column: $table.lastReviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $FlashcardsAnnotationComposer get flashcardId {
    final $FlashcardsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserFlashcardProgressTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserFlashcardProgress,
          UserFlashcardProgressData,
          $UserFlashcardProgressFilterComposer,
          $UserFlashcardProgressOrderingComposer,
          $UserFlashcardProgressAnnotationComposer,
          $UserFlashcardProgressCreateCompanionBuilder,
          $UserFlashcardProgressUpdateCompanionBuilder,
          (UserFlashcardProgressData, $UserFlashcardProgressReferences),
          UserFlashcardProgressData,
          PrefetchHooks Function({bool flashcardId})
        > {
  $UserFlashcardProgressTableManager(
    _$AppDatabase db,
    UserFlashcardProgress table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserFlashcardProgressFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserFlashcardProgressOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserFlashcardProgressAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> flashcardId = const Value.absent(),
                Value<int> box = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> againCount = const Value.absent(),
                Value<int> knowCount = const Value.absent(),
                Value<String?> lastRating = const Value.absent(),
                Value<int> isLearned = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> clientUpdatedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFlashcardProgressCompanion(
                flashcardId: flashcardId,
                box: box,
                repetitions: repetitions,
                againCount: againCount,
                knowCount: knowCount,
                lastRating: lastRating,
                isLearned: isLearned,
                lastReviewedAt: lastReviewedAt,
                dueAt: dueAt,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String flashcardId,
                Value<int> box = const Value.absent(),
                Value<int> repetitions = const Value.absent(),
                Value<int> againCount = const Value.absent(),
                Value<int> knowCount = const Value.absent(),
                Value<String?> lastRating = const Value.absent(),
                Value<int> isLearned = const Value.absent(),
                Value<int?> lastReviewedAt = const Value.absent(),
                Value<int?> dueAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> clientUpdatedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFlashcardProgressCompanion.insert(
                flashcardId: flashcardId,
                box: box,
                repetitions: repetitions,
                againCount: againCount,
                knowCount: knowCount,
                lastRating: lastRating,
                isLearned: isLearned,
                lastReviewedAt: lastReviewedAt,
                dueAt: dueAt,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserFlashcardProgress, UserFlashcardProgressData>(
                    table,
                  ),
                  $UserFlashcardProgressReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
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
                    if (flashcardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.flashcardId,
                        referencedTable: $UserFlashcardProgressReferences
                            ._flashcardIdTable(db),
                        referencedColumn: $UserFlashcardProgressReferences
                            ._flashcardIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserFlashcardProgressProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserFlashcardProgress,
      UserFlashcardProgressData,
      $UserFlashcardProgressFilterComposer,
      $UserFlashcardProgressOrderingComposer,
      $UserFlashcardProgressAnnotationComposer,
      $UserFlashcardProgressCreateCompanionBuilder,
      $UserFlashcardProgressUpdateCompanionBuilder,
      (UserFlashcardProgressData, $UserFlashcardProgressReferences),
      UserFlashcardProgressData,
      PrefetchHooks Function({bool flashcardId})
    >;
typedef $FlashcardReviewLogsCreateCompanionBuilder =
    FlashcardReviewLogsCompanion Function({
      required String id,
      required String flashcardId,
      required String rating,
      required int boxBefore,
      required int boxAfter,
      Value<int?> responseTimeMs,
      required int reviewedAt,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $FlashcardReviewLogsUpdateCompanionBuilder =
    FlashcardReviewLogsCompanion Function({
      Value<String> id,
      Value<String> flashcardId,
      Value<String> rating,
      Value<int> boxBefore,
      Value<int> boxAfter,
      Value<int?> responseTimeMs,
      Value<int> reviewedAt,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $FlashcardReviewLogsReferences
    extends
        BaseReferences<_$AppDatabase, FlashcardReviewLogs, FlashcardReviewLog> {
  $FlashcardReviewLogsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static Flashcards _flashcardIdTable(_$AppDatabase db) => db.flashcards
      .createAlias('flashcard_review_logs__flashcard_id__flashcards__id');

  $FlashcardsProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $FlashcardsTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $FlashcardReviewLogsFilterComposer
    extends Composer<_$AppDatabase, FlashcardReviewLogs> {
  $FlashcardReviewLogsFilterComposer({
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

  ColumnFilters<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get boxBefore => $composableBuilder(
    column: $table.boxBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get boxAfter => $composableBuilder(
    column: $table.boxAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $FlashcardsFilterComposer get flashcardId {
    final $FlashcardsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FlashcardReviewLogsOrderingComposer
    extends Composer<_$AppDatabase, FlashcardReviewLogs> {
  $FlashcardReviewLogsOrderingComposer({
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

  ColumnOrderings<String> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get boxBefore => $composableBuilder(
    column: $table.boxBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get boxAfter => $composableBuilder(
    column: $table.boxAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $FlashcardsOrderingComposer get flashcardId {
    final $FlashcardsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FlashcardReviewLogsAnnotationComposer
    extends Composer<_$AppDatabase, FlashcardReviewLogs> {
  $FlashcardReviewLogsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<int> get boxBefore =>
      $composableBuilder(column: $table.boxBefore, builder: (column) => column);

  GeneratedColumn<int> get boxAfter =>
      $composableBuilder(column: $table.boxAfter, builder: (column) => column);

  GeneratedColumn<int> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reviewedAt => $composableBuilder(
    column: $table.reviewedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $FlashcardsAnnotationComposer get flashcardId {
    final $FlashcardsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $FlashcardReviewLogsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          FlashcardReviewLogs,
          FlashcardReviewLog,
          $FlashcardReviewLogsFilterComposer,
          $FlashcardReviewLogsOrderingComposer,
          $FlashcardReviewLogsAnnotationComposer,
          $FlashcardReviewLogsCreateCompanionBuilder,
          $FlashcardReviewLogsUpdateCompanionBuilder,
          (FlashcardReviewLog, $FlashcardReviewLogsReferences),
          FlashcardReviewLog,
          PrefetchHooks Function({bool flashcardId})
        > {
  $FlashcardReviewLogsTableManager(_$AppDatabase db, FlashcardReviewLogs table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $FlashcardReviewLogsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $FlashcardReviewLogsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $FlashcardReviewLogsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> flashcardId = const Value.absent(),
                Value<String> rating = const Value.absent(),
                Value<int> boxBefore = const Value.absent(),
                Value<int> boxAfter = const Value.absent(),
                Value<int?> responseTimeMs = const Value.absent(),
                Value<int> reviewedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardReviewLogsCompanion(
                id: id,
                flashcardId: flashcardId,
                rating: rating,
                boxBefore: boxBefore,
                boxAfter: boxAfter,
                responseTimeMs: responseTimeMs,
                reviewedAt: reviewedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String flashcardId,
                required String rating,
                required int boxBefore,
                required int boxAfter,
                Value<int?> responseTimeMs = const Value.absent(),
                required int reviewedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FlashcardReviewLogsCompanion.insert(
                id: id,
                flashcardId: flashcardId,
                rating: rating,
                boxBefore: boxBefore,
                boxAfter: boxAfter,
                responseTimeMs: responseTimeMs,
                reviewedAt: reviewedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<FlashcardReviewLogs, FlashcardReviewLog>(table),
                  $FlashcardReviewLogsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
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
                    if (flashcardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.flashcardId,
                        referencedTable: $FlashcardReviewLogsReferences
                            ._flashcardIdTable(db),
                        referencedColumn: $FlashcardReviewLogsReferences
                            ._flashcardIdTable(db)
                            .id,
                      ) as T;
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

typedef $FlashcardReviewLogsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      FlashcardReviewLogs,
      FlashcardReviewLog,
      $FlashcardReviewLogsFilterComposer,
      $FlashcardReviewLogsOrderingComposer,
      $FlashcardReviewLogsAnnotationComposer,
      $FlashcardReviewLogsCreateCompanionBuilder,
      $FlashcardReviewLogsUpdateCompanionBuilder,
      (FlashcardReviewLog, $FlashcardReviewLogsReferences),
      FlashcardReviewLog,
      PrefetchHooks Function({bool flashcardId})
    >;
typedef $UserFlashcardNotesCreateCompanionBuilder =
    UserFlashcardNotesCompanion Function({
      required String id,
      required String flashcardId,
      required String content,
      Value<int> version,
      required int clientUpdatedAt,
      Value<int?> deletedAt,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $UserFlashcardNotesUpdateCompanionBuilder =
    UserFlashcardNotesCompanion Function({
      Value<String> id,
      Value<String> flashcardId,
      Value<String> content,
      Value<int> version,
      Value<int> clientUpdatedAt,
      Value<int?> deletedAt,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $UserFlashcardNotesReferences
    extends
        BaseReferences<_$AppDatabase, UserFlashcardNotes, UserFlashcardNote> {
  $UserFlashcardNotesReferences(super.$_db, super.$_table, super.$_typedResult);

  static Flashcards _flashcardIdTable(_$AppDatabase db) => db.flashcards
      .createAlias('user_flashcard_notes__flashcard_id__flashcards__id');

  $FlashcardsProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $FlashcardsTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserFlashcardNotesFilterComposer
    extends Composer<_$AppDatabase, UserFlashcardNotes> {
  $UserFlashcardNotesFilterComposer({
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

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $FlashcardsFilterComposer get flashcardId {
    final $FlashcardsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserFlashcardNotesOrderingComposer
    extends Composer<_$AppDatabase, UserFlashcardNotes> {
  $UserFlashcardNotesOrderingComposer({
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

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $FlashcardsOrderingComposer get flashcardId {
    final $FlashcardsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserFlashcardNotesAnnotationComposer
    extends Composer<_$AppDatabase, UserFlashcardNotes> {
  $UserFlashcardNotesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $FlashcardsAnnotationComposer get flashcardId {
    final $FlashcardsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserFlashcardNotesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserFlashcardNotes,
          UserFlashcardNote,
          $UserFlashcardNotesFilterComposer,
          $UserFlashcardNotesOrderingComposer,
          $UserFlashcardNotesAnnotationComposer,
          $UserFlashcardNotesCreateCompanionBuilder,
          $UserFlashcardNotesUpdateCompanionBuilder,
          (UserFlashcardNote, $UserFlashcardNotesReferences),
          UserFlashcardNote,
          PrefetchHooks Function({bool flashcardId})
        > {
  $UserFlashcardNotesTableManager(_$AppDatabase db, UserFlashcardNotes table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserFlashcardNotesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserFlashcardNotesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserFlashcardNotesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> flashcardId = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> clientUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFlashcardNotesCompanion(
                id: id,
                flashcardId: flashcardId,
                content: content,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String flashcardId,
                required String content,
                Value<int> version = const Value.absent(),
                required int clientUpdatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFlashcardNotesCompanion.insert(
                id: id,
                flashcardId: flashcardId,
                content: content,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserFlashcardNotes, UserFlashcardNote>(table),
                  $UserFlashcardNotesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
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
                    if (flashcardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.flashcardId,
                        referencedTable: $UserFlashcardNotesReferences
                            ._flashcardIdTable(db),
                        referencedColumn: $UserFlashcardNotesReferences
                            ._flashcardIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserFlashcardNotesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserFlashcardNotes,
      UserFlashcardNote,
      $UserFlashcardNotesFilterComposer,
      $UserFlashcardNotesOrderingComposer,
      $UserFlashcardNotesAnnotationComposer,
      $UserFlashcardNotesCreateCompanionBuilder,
      $UserFlashcardNotesUpdateCompanionBuilder,
      (UserFlashcardNote, $UserFlashcardNotesReferences),
      UserFlashcardNote,
      PrefetchHooks Function({bool flashcardId})
    >;
typedef $UserBookmarksCreateCompanionBuilder = UserBookmarksCompanion Function({
  required String flashcardId,
  required int createdAt,
  Value<int> version,
  required int clientUpdatedAt,
  Value<int?> deletedAt,
  Value<int> isDirty,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});
typedef $UserBookmarksUpdateCompanionBuilder = UserBookmarksCompanion Function({
  Value<String> flashcardId,
  Value<int> createdAt,
  Value<int> version,
  Value<int> clientUpdatedAt,
  Value<int?> deletedAt,
  Value<int> isDirty,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});

final class $UserBookmarksReferences
    extends BaseReferences<_$AppDatabase, UserBookmarks, UserBookmark> {
  $UserBookmarksReferences(super.$_db, super.$_table, super.$_typedResult);

  static Flashcards _flashcardIdTable(_$AppDatabase db) =>
      db.flashcards.createAlias('user_bookmarks__flashcard_id__flashcards__id');

  $FlashcardsProcessedTableManager get flashcardId {
    final $_column = $_itemColumn<String>('flashcard_id')!;

    final manager = $FlashcardsTableManager(
      $_db,
      $_db.flashcards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserBookmarksFilterComposer
    extends Composer<_$AppDatabase, UserBookmarks> {
  $UserBookmarksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $FlashcardsFilterComposer get flashcardId {
    final $FlashcardsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsFilterComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserBookmarksOrderingComposer
    extends Composer<_$AppDatabase, UserBookmarks> {
  $UserBookmarksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $FlashcardsOrderingComposer get flashcardId {
    final $FlashcardsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsOrderingComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserBookmarksAnnotationComposer
    extends Composer<_$AppDatabase, UserBookmarks> {
  $UserBookmarksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $FlashcardsAnnotationComposer get flashcardId {
    final $FlashcardsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.flashcardId,
      referencedTable: $db.flashcards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FlashcardsAnnotationComposer(
            $db: $db,
            $table: $db.flashcards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserBookmarksTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserBookmarks,
          UserBookmark,
          $UserBookmarksFilterComposer,
          $UserBookmarksOrderingComposer,
          $UserBookmarksAnnotationComposer,
          $UserBookmarksCreateCompanionBuilder,
          $UserBookmarksUpdateCompanionBuilder,
          (UserBookmark, $UserBookmarksReferences),
          UserBookmark,
          PrefetchHooks Function({bool flashcardId})
        > {
  $UserBookmarksTableManager(_$AppDatabase db, UserBookmarks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserBookmarksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserBookmarksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserBookmarksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> flashcardId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> clientUpdatedAt = const Value.absent(),
                Value<int?> deletedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBookmarksCompanion(
                flashcardId: flashcardId,
                createdAt: createdAt,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String flashcardId,
                required int createdAt,
                Value<int> version = const Value.absent(),
                required int clientUpdatedAt,
                Value<int?> deletedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserBookmarksCompanion.insert(
                flashcardId: flashcardId,
                createdAt: createdAt,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                deletedAt: deletedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserBookmarks, UserBookmark>(table),
                  $UserBookmarksReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
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
                    if (flashcardId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.flashcardId,
                        referencedTable: $UserBookmarksReferences
                            ._flashcardIdTable(db),
                        referencedColumn: $UserBookmarksReferences
                            ._flashcardIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserBookmarksProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserBookmarks,
      UserBookmark,
      $UserBookmarksFilterComposer,
      $UserBookmarksOrderingComposer,
      $UserBookmarksAnnotationComposer,
      $UserBookmarksCreateCompanionBuilder,
      $UserBookmarksUpdateCompanionBuilder,
      (UserBookmark, $UserBookmarksReferences),
      UserBookmark,
      PrefetchHooks Function({bool flashcardId})
    >;
typedef $UserTopicProgressCreateCompanionBuilder =
    UserTopicProgressCompanion Function({
      required String topicId,
      Value<int> learnedWords,
      Value<String> status,
      Value<int?> lastStudiedAt,
      Value<int?> completedAt,
      Value<int> version,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $UserTopicProgressUpdateCompanionBuilder =
    UserTopicProgressCompanion Function({
      Value<String> topicId,
      Value<int> learnedWords,
      Value<String> status,
      Value<int?> lastStudiedAt,
      Value<int?> completedAt,
      Value<int> version,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $UserTopicProgressReferences
    extends
        BaseReferences<
          _$AppDatabase,
          UserTopicProgress,
          UserTopicProgressData
        > {
  $UserTopicProgressReferences(super.$_db, super.$_table, super.$_typedResult);

  static Topics _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('user_topic_progress__topic_id__topics__id');

  $TopicsProcessedTableManager get topicId {
    final $_column = $_itemColumn<String>('topic_id')!;

    final manager = $TopicsTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserTopicProgressFilterComposer
    extends Composer<_$AppDatabase, UserTopicProgress> {
  $UserTopicProgressFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get learnedWords => $composableBuilder(
    column: $table.learnedWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $TopicsFilterComposer get topicId {
    final $TopicsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserTopicProgressOrderingComposer
    extends Composer<_$AppDatabase, UserTopicProgress> {
  $UserTopicProgressOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get learnedWords => $composableBuilder(
    column: $table.learnedWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $TopicsOrderingComposer get topicId {
    final $TopicsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserTopicProgressAnnotationComposer
    extends Composer<_$AppDatabase, UserTopicProgress> {
  $UserTopicProgressAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get learnedWords => $composableBuilder(
    column: $table.learnedWords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $TopicsAnnotationComposer get topicId {
    final $TopicsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserTopicProgressTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserTopicProgress,
          UserTopicProgressData,
          $UserTopicProgressFilterComposer,
          $UserTopicProgressOrderingComposer,
          $UserTopicProgressAnnotationComposer,
          $UserTopicProgressCreateCompanionBuilder,
          $UserTopicProgressUpdateCompanionBuilder,
          (UserTopicProgressData, $UserTopicProgressReferences),
          UserTopicProgressData,
          PrefetchHooks Function({bool topicId})
        > {
  $UserTopicProgressTableManager(_$AppDatabase db, UserTopicProgress table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserTopicProgressFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserTopicProgressOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserTopicProgressAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> topicId = const Value.absent(),
                Value<int> learnedWords = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTopicProgressCompanion(
                topicId: topicId,
                learnedWords: learnedWords,
                status: status,
                lastStudiedAt: lastStudiedAt,
                completedAt: completedAt,
                version: version,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String topicId,
                Value<int> learnedWords = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserTopicProgressCompanion.insert(
                topicId: topicId,
                learnedWords: learnedWords,
                status: status,
                lastStudiedAt: lastStudiedAt,
                completedAt: completedAt,
                version: version,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserTopicProgress, UserTopicProgressData>(table),
                  $UserTopicProgressReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicId = false}) {
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
                    if (topicId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicId,
                        referencedTable: $UserTopicProgressReferences
                            ._topicIdTable(db),
                        referencedColumn: $UserTopicProgressReferences
                            ._topicIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserTopicProgressProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserTopicProgress,
      UserTopicProgressData,
      $UserTopicProgressFilterComposer,
      $UserTopicProgressOrderingComposer,
      $UserTopicProgressAnnotationComposer,
      $UserTopicProgressCreateCompanionBuilder,
      $UserTopicProgressUpdateCompanionBuilder,
      (UserTopicProgressData, $UserTopicProgressReferences),
      UserTopicProgressData,
      PrefetchHooks Function({bool topicId})
    >;
typedef $UserGrammarProgressCreateCompanionBuilder =
    UserGrammarProgressCompanion Function({
      required String grammarLessonId,
      Value<double> progress,
      Value<String> status,
      Value<int?> bestScorePercent,
      Value<int?> lastStudiedAt,
      Value<int?> completedAt,
      Value<int> version,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $UserGrammarProgressUpdateCompanionBuilder =
    UserGrammarProgressCompanion Function({
      Value<String> grammarLessonId,
      Value<double> progress,
      Value<String> status,
      Value<int?> bestScorePercent,
      Value<int?> lastStudiedAt,
      Value<int?> completedAt,
      Value<int> version,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $UserGrammarProgressReferences
    extends
        BaseReferences<
          _$AppDatabase,
          UserGrammarProgress,
          UserGrammarProgressData
        > {
  $UserGrammarProgressReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static GrammarLessons _grammarLessonIdTable(_$AppDatabase db) =>
      db.grammarLessons.createAlias(
        'user_grammar_progress__grammar_lesson_id__grammar_lessons__id',
      );

  $GrammarLessonsProcessedTableManager get grammarLessonId {
    final $_column = $_itemColumn<String>('grammar_lesson_id')!;

    final manager = $GrammarLessonsTableManager(
      $_db,
      $_db.grammarLessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarLessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserGrammarProgressFilterComposer
    extends Composer<_$AppDatabase, UserGrammarProgress> {
  $UserGrammarProgressFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestScorePercent => $composableBuilder(
    column: $table.bestScorePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $GrammarLessonsFilterComposer get grammarLessonId {
    final $GrammarLessonsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsFilterComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserGrammarProgressOrderingComposer
    extends Composer<_$AppDatabase, UserGrammarProgress> {
  $UserGrammarProgressOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestScorePercent => $composableBuilder(
    column: $table.bestScorePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $GrammarLessonsOrderingComposer get grammarLessonId {
    final $GrammarLessonsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsOrderingComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserGrammarProgressAnnotationComposer
    extends Composer<_$AppDatabase, UserGrammarProgress> {
  $UserGrammarProgressAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get bestScorePercent => $composableBuilder(
    column: $table.bestScorePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastStudiedAt => $composableBuilder(
    column: $table.lastStudiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $GrammarLessonsAnnotationComposer get grammarLessonId {
    final $GrammarLessonsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsAnnotationComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserGrammarProgressTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserGrammarProgress,
          UserGrammarProgressData,
          $UserGrammarProgressFilterComposer,
          $UserGrammarProgressOrderingComposer,
          $UserGrammarProgressAnnotationComposer,
          $UserGrammarProgressCreateCompanionBuilder,
          $UserGrammarProgressUpdateCompanionBuilder,
          (UserGrammarProgressData, $UserGrammarProgressReferences),
          UserGrammarProgressData,
          PrefetchHooks Function({bool grammarLessonId})
        > {
  $UserGrammarProgressTableManager(_$AppDatabase db, UserGrammarProgress table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserGrammarProgressFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserGrammarProgressOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserGrammarProgressAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> grammarLessonId = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> bestScorePercent = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGrammarProgressCompanion(
                grammarLessonId: grammarLessonId,
                progress: progress,
                status: status,
                bestScorePercent: bestScorePercent,
                lastStudiedAt: lastStudiedAt,
                completedAt: completedAt,
                version: version,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String grammarLessonId,
                Value<double> progress = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> bestScorePercent = const Value.absent(),
                Value<int?> lastStudiedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserGrammarProgressCompanion.insert(
                grammarLessonId: grammarLessonId,
                progress: progress,
                status: status,
                bestScorePercent: bestScorePercent,
                lastStudiedAt: lastStudiedAt,
                completedAt: completedAt,
                version: version,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserGrammarProgress, UserGrammarProgressData>(
                    table,
                  ),
                  $UserGrammarProgressReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({grammarLessonId = false}) {
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
                    if (grammarLessonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.grammarLessonId,
                        referencedTable: $UserGrammarProgressReferences
                            ._grammarLessonIdTable(db),
                        referencedColumn: $UserGrammarProgressReferences
                            ._grammarLessonIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserGrammarProgressProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserGrammarProgress,
      UserGrammarProgressData,
      $UserGrammarProgressFilterComposer,
      $UserGrammarProgressOrderingComposer,
      $UserGrammarProgressAnnotationComposer,
      $UserGrammarProgressCreateCompanionBuilder,
      $UserGrammarProgressUpdateCompanionBuilder,
      (UserGrammarProgressData, $UserGrammarProgressReferences),
      UserGrammarProgressData,
      PrefetchHooks Function({bool grammarLessonId})
    >;
typedef $LessonCompletionsCreateCompanionBuilder =
    LessonCompletionsCompanion Function({
      required String id,
      required String lessonType,
      Value<String?> topicId,
      Value<String?> grammarLessonId,
      Value<int> cardsReviewed,
      Value<int> durationSeconds,
      required int completedAt,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $LessonCompletionsUpdateCompanionBuilder =
    LessonCompletionsCompanion Function({
      Value<String> id,
      Value<String> lessonType,
      Value<String?> topicId,
      Value<String?> grammarLessonId,
      Value<int> cardsReviewed,
      Value<int> durationSeconds,
      Value<int> completedAt,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $LessonCompletionsReferences
    extends BaseReferences<_$AppDatabase, LessonCompletions, LessonCompletion> {
  $LessonCompletionsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Topics _topicIdTable(_$AppDatabase db) =>
      db.topics.createAlias('lesson_completions__topic_id__topics__id');

  $TopicsProcessedTableManager? get topicId {
    final $_column = $_itemColumn<String>('topic_id');
    if ($_column == null) return null;
    final manager = $TopicsTableManager(
      $_db,
      $_db.topics,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static GrammarLessons _grammarLessonIdTable(_$AppDatabase db) =>
      db.grammarLessons.createAlias(
        'lesson_completions__grammar_lesson_id__grammar_lessons__id',
      );

  $GrammarLessonsProcessedTableManager? get grammarLessonId {
    final $_column = $_itemColumn<String>('grammar_lesson_id');
    if ($_column == null) return null;
    final manager = $GrammarLessonsTableManager(
      $_db,
      $_db.grammarLessons,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_grammarLessonIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $LessonCompletionsFilterComposer
    extends Composer<_$AppDatabase, LessonCompletions> {
  $LessonCompletionsFilterComposer({
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

  ColumnFilters<String> get lessonType => $composableBuilder(
    column: $table.lessonType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $TopicsFilterComposer get topicId {
    final $TopicsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsFilterComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GrammarLessonsFilterComposer get grammarLessonId {
    final $GrammarLessonsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsFilterComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LessonCompletionsOrderingComposer
    extends Composer<_$AppDatabase, LessonCompletions> {
  $LessonCompletionsOrderingComposer({
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

  ColumnOrderings<String> get lessonType => $composableBuilder(
    column: $table.lessonType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $TopicsOrderingComposer get topicId {
    final $TopicsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsOrderingComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GrammarLessonsOrderingComposer get grammarLessonId {
    final $GrammarLessonsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsOrderingComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LessonCompletionsAnnotationComposer
    extends Composer<_$AppDatabase, LessonCompletions> {
  $LessonCompletionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get lessonType => $composableBuilder(
    column: $table.lessonType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $TopicsAnnotationComposer get topicId {
    final $TopicsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.topicId,
      referencedTable: $db.topics,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TopicsAnnotationComposer(
            $db: $db,
            $table: $db.topics,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $GrammarLessonsAnnotationComposer get grammarLessonId {
    final $GrammarLessonsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.grammarLessonId,
      referencedTable: $db.grammarLessons,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $GrammarLessonsAnnotationComposer(
            $db: $db,
            $table: $db.grammarLessons,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $LessonCompletionsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          LessonCompletions,
          LessonCompletion,
          $LessonCompletionsFilterComposer,
          $LessonCompletionsOrderingComposer,
          $LessonCompletionsAnnotationComposer,
          $LessonCompletionsCreateCompanionBuilder,
          $LessonCompletionsUpdateCompanionBuilder,
          (LessonCompletion, $LessonCompletionsReferences),
          LessonCompletion,
          PrefetchHooks Function({bool topicId, bool grammarLessonId})
        > {
  $LessonCompletionsTableManager(_$AppDatabase db, LessonCompletions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $LessonCompletionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $LessonCompletionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $LessonCompletionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> lessonType = const Value.absent(),
                Value<String?> topicId = const Value.absent(),
                Value<String?> grammarLessonId = const Value.absent(),
                Value<int> cardsReviewed = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonCompletionsCompanion(
                id: id,
                lessonType: lessonType,
                topicId: topicId,
                grammarLessonId: grammarLessonId,
                cardsReviewed: cardsReviewed,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String lessonType,
                Value<String?> topicId = const Value.absent(),
                Value<String?> grammarLessonId = const Value.absent(),
                Value<int> cardsReviewed = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                required int completedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LessonCompletionsCompanion.insert(
                id: id,
                lessonType: lessonType,
                topicId: topicId,
                grammarLessonId: grammarLessonId,
                cardsReviewed: cardsReviewed,
                durationSeconds: durationSeconds,
                completedAt: completedAt,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<LessonCompletions, LessonCompletion>(table),
                  $LessonCompletionsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({topicId = false, grammarLessonId = false}) {
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
                    if (topicId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.topicId,
                        referencedTable: $LessonCompletionsReferences
                            ._topicIdTable(db),
                        referencedColumn: $LessonCompletionsReferences
                            ._topicIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (grammarLessonId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.grammarLessonId,
                        referencedTable: $LessonCompletionsReferences
                            ._grammarLessonIdTable(db),
                        referencedColumn: $LessonCompletionsReferences
                            ._grammarLessonIdTable(db)
                            .id,
                      ) as T;
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

typedef $LessonCompletionsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      LessonCompletions,
      LessonCompletion,
      $LessonCompletionsFilterComposer,
      $LessonCompletionsOrderingComposer,
      $LessonCompletionsAnnotationComposer,
      $LessonCompletionsCreateCompanionBuilder,
      $LessonCompletionsUpdateCompanionBuilder,
      (LessonCompletion, $LessonCompletionsReferences),
      LessonCompletion,
      PrefetchHooks Function({bool topicId, bool grammarLessonId})
    >;
typedef $QuizAttemptsCreateCompanionBuilder = QuizAttemptsCompanion Function({
  required String id,
  required String quizId,
  required int totalQuestions,
  required int correctAnswers,
  required int wrongAnswers,
  required int scorePercent,
  required int timeTakenSeconds,
  required int startedAt,
  required int submittedAt,
  Value<int?> xpAwarded,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});
typedef $QuizAttemptsUpdateCompanionBuilder = QuizAttemptsCompanion Function({
  Value<String> id,
  Value<String> quizId,
  Value<int> totalQuestions,
  Value<int> correctAnswers,
  Value<int> wrongAnswers,
  Value<int> scorePercent,
  Value<int> timeTakenSeconds,
  Value<int> startedAt,
  Value<int> submittedAt,
  Value<int?> xpAwarded,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});

final class $QuizAttemptsReferences
    extends BaseReferences<_$AppDatabase, QuizAttempts, QuizAttempt> {
  $QuizAttemptsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Quizzes _quizIdTable(_$AppDatabase db) =>
      db.quizzes.createAlias('quiz_attempts__quiz_id__quizzes__id');

  $QuizzesProcessedTableManager get quizId {
    final $_column = $_itemColumn<String>('quiz_id')!;

    final manager = $QuizzesTableManager(
      $_db,
      $_db.quizzes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quizIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<QuizAttemptAnswers, List<QuizAttemptAnswer>>
  _quizAttemptAnswersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.quizAttemptAnswers,
        aliasName: 'quiz_attempts__id__quiz_attempt_answers__attempt_id',
      );

  $QuizAttemptAnswersProcessedTableManager get quizAttemptAnswersRefs {
    final manager = $QuizAttemptAnswersTableManager(
      $_db,
      $_db.quizAttemptAnswers,
    ).filter((f) => f.attemptId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _quizAttemptAnswersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $QuizAttemptsFilterComposer
    extends Composer<_$AppDatabase, QuizAttempts> {
  $QuizAttemptsFilterComposer({
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

  ColumnFilters<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wrongAnswers => $composableBuilder(
    column: $table.wrongAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeTakenSeconds => $composableBuilder(
    column: $table.timeTakenSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpAwarded => $composableBuilder(
    column: $table.xpAwarded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $QuizzesFilterComposer get quizId {
    final $QuizzesFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesFilterComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> quizAttemptAnswersRefs(
    Expression<bool> Function($QuizAttemptAnswersFilterComposer f) f,
  ) {
    final $QuizAttemptAnswersFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAttemptAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptAnswersFilterComposer(
            $db: $db,
            $table: $db.quizAttemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuizAttemptsOrderingComposer
    extends Composer<_$AppDatabase, QuizAttempts> {
  $QuizAttemptsOrderingComposer({
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

  ColumnOrderings<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wrongAnswers => $composableBuilder(
    column: $table.wrongAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeTakenSeconds => $composableBuilder(
    column: $table.timeTakenSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpAwarded => $composableBuilder(
    column: $table.xpAwarded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $QuizzesOrderingComposer get quizId {
    final $QuizzesOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesOrderingComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizAttemptsAnnotationComposer
    extends Composer<_$AppDatabase, QuizAttempts> {
  $QuizAttemptsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get totalQuestions => $composableBuilder(
    column: $table.totalQuestions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get wrongAnswers => $composableBuilder(
    column: $table.wrongAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scorePercent => $composableBuilder(
    column: $table.scorePercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeTakenSeconds => $composableBuilder(
    column: $table.timeTakenSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpAwarded =>
      $composableBuilder(column: $table.xpAwarded, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $QuizzesAnnotationComposer get quizId {
    final $QuizzesAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quizId,
      referencedTable: $db.quizzes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizzesAnnotationComposer(
            $db: $db,
            $table: $db.quizzes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> quizAttemptAnswersRefs<T extends Object>(
    Expression<T> Function($QuizAttemptAnswersAnnotationComposer a) f,
  ) {
    final $QuizAttemptAnswersAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quizAttemptAnswers,
      getReferencedColumn: (t) => t.attemptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptAnswersAnnotationComposer(
            $db: $db,
            $table: $db.quizAttemptAnswers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $QuizAttemptsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          QuizAttempts,
          QuizAttempt,
          $QuizAttemptsFilterComposer,
          $QuizAttemptsOrderingComposer,
          $QuizAttemptsAnnotationComposer,
          $QuizAttemptsCreateCompanionBuilder,
          $QuizAttemptsUpdateCompanionBuilder,
          (QuizAttempt, $QuizAttemptsReferences),
          QuizAttempt,
          PrefetchHooks Function({bool quizId, bool quizAttemptAnswersRefs})
        > {
  $QuizAttemptsTableManager(_$AppDatabase db, QuizAttempts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuizAttemptsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuizAttemptsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuizAttemptsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> quizId = const Value.absent(),
                Value<int> totalQuestions = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> wrongAnswers = const Value.absent(),
                Value<int> scorePercent = const Value.absent(),
                Value<int> timeTakenSeconds = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int> submittedAt = const Value.absent(),
                Value<int?> xpAwarded = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizAttemptsCompanion(
                id: id,
                quizId: quizId,
                totalQuestions: totalQuestions,
                correctAnswers: correctAnswers,
                wrongAnswers: wrongAnswers,
                scorePercent: scorePercent,
                timeTakenSeconds: timeTakenSeconds,
                startedAt: startedAt,
                submittedAt: submittedAt,
                xpAwarded: xpAwarded,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String quizId,
                required int totalQuestions,
                required int correctAnswers,
                required int wrongAnswers,
                required int scorePercent,
                required int timeTakenSeconds,
                required int startedAt,
                required int submittedAt,
                Value<int?> xpAwarded = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuizAttemptsCompanion.insert(
                id: id,
                quizId: quizId,
                totalQuestions: totalQuestions,
                correctAnswers: correctAnswers,
                wrongAnswers: wrongAnswers,
                scorePercent: scorePercent,
                timeTakenSeconds: timeTakenSeconds,
                startedAt: startedAt,
                submittedAt: submittedAt,
                xpAwarded: xpAwarded,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<QuizAttempts, QuizAttempt>(table),
                  $QuizAttemptsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({quizId = false, quizAttemptAnswersRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (quizAttemptAnswersRefs) db.quizAttemptAnswers,
                  ],
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
                        if (quizId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.quizId,
                            referencedTable: $QuizAttemptsReferences
                                ._quizIdTable(db),
                            referencedColumn: $QuizAttemptsReferences
                                ._quizIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (quizAttemptAnswersRefs)
                        await $_getPrefetchedData<
                          QuizAttempt,
                          QuizAttempts,
                          QuizAttemptAnswer
                        >(
                          currentTable: table,
                          referencedTable: $QuizAttemptsReferences
                              ._quizAttemptAnswersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $QuizAttemptsReferences(
                                db,
                                table,
                                p0,
                              ).quizAttemptAnswersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.attemptId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $QuizAttemptsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      QuizAttempts,
      QuizAttempt,
      $QuizAttemptsFilterComposer,
      $QuizAttemptsOrderingComposer,
      $QuizAttemptsAnnotationComposer,
      $QuizAttemptsCreateCompanionBuilder,
      $QuizAttemptsUpdateCompanionBuilder,
      (QuizAttempt, $QuizAttemptsReferences),
      QuizAttempt,
      PrefetchHooks Function({bool quizId, bool quizAttemptAnswersRefs})
    >;
typedef $QuizAttemptAnswersCreateCompanionBuilder =
    QuizAttemptAnswersCompanion Function({
      required String attemptId,
      required String questionId,
      Value<int?> selectedOptionIndex,
      required int isCorrect,
      Value<int?> answeredAt,
    });
typedef $QuizAttemptAnswersUpdateCompanionBuilder =
    QuizAttemptAnswersCompanion Function({
      Value<String> attemptId,
      Value<String> questionId,
      Value<int?> selectedOptionIndex,
      Value<int> isCorrect,
      Value<int?> answeredAt,
    });

final class $QuizAttemptAnswersReferences
    extends
        BaseReferences<_$AppDatabase, QuizAttemptAnswers, QuizAttemptAnswer> {
  $QuizAttemptAnswersReferences(super.$_db, super.$_table, super.$_typedResult);

  static QuizAttempts _attemptIdTable(_$AppDatabase db) => db.quizAttempts
      .createAlias('quiz_attempt_answers__attempt_id__quiz_attempts__id');

  $QuizAttemptsProcessedTableManager get attemptId {
    final $_column = $_itemColumn<String>('attempt_id')!;

    final manager = $QuizAttemptsTableManager(
      $_db,
      $_db.quizAttempts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_attemptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static QuizQuestions _questionIdTable(_$AppDatabase db) => db.quizQuestions
      .createAlias('quiz_attempt_answers__question_id__quiz_questions__id');

  $QuizQuestionsProcessedTableManager get questionId {
    final $_column = $_itemColumn<String>('question_id')!;

    final manager = $QuizQuestionsTableManager(
      $_db,
      $_db.quizQuestions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $QuizAttemptAnswersFilterComposer
    extends Composer<_$AppDatabase, QuizAttemptAnswers> {
  $QuizAttemptAnswersFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get selectedOptionIndex => $composableBuilder(
    column: $table.selectedOptionIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnFilters(column),
  );

  $QuizAttemptsFilterComposer get attemptId {
    final $QuizAttemptsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptsFilterComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $QuizQuestionsFilterComposer get questionId {
    final $QuizQuestionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsFilterComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizAttemptAnswersOrderingComposer
    extends Composer<_$AppDatabase, QuizAttemptAnswers> {
  $QuizAttemptAnswersOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get selectedOptionIndex => $composableBuilder(
    column: $table.selectedOptionIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $QuizAttemptsOrderingComposer get attemptId {
    final $QuizAttemptsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptsOrderingComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $QuizQuestionsOrderingComposer get questionId {
    final $QuizQuestionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsOrderingComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizAttemptAnswersAnnotationComposer
    extends Composer<_$AppDatabase, QuizAttemptAnswers> {
  $QuizAttemptAnswersAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get selectedOptionIndex => $composableBuilder(
    column: $table.selectedOptionIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get answeredAt => $composableBuilder(
    column: $table.answeredAt,
    builder: (column) => column,
  );

  $QuizAttemptsAnnotationComposer get attemptId {
    final $QuizAttemptsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.attemptId,
      referencedTable: $db.quizAttempts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizAttemptsAnnotationComposer(
            $db: $db,
            $table: $db.quizAttempts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $QuizQuestionsAnnotationComposer get questionId {
    final $QuizQuestionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questionId,
      referencedTable: $db.quizQuestions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuizQuestionsAnnotationComposer(
            $db: $db,
            $table: $db.quizQuestions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $QuizAttemptAnswersTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          QuizAttemptAnswers,
          QuizAttemptAnswer,
          $QuizAttemptAnswersFilterComposer,
          $QuizAttemptAnswersOrderingComposer,
          $QuizAttemptAnswersAnnotationComposer,
          $QuizAttemptAnswersCreateCompanionBuilder,
          $QuizAttemptAnswersUpdateCompanionBuilder,
          (QuizAttemptAnswer, $QuizAttemptAnswersReferences),
          QuizAttemptAnswer,
          PrefetchHooks Function({bool attemptId, bool questionId})
        > {
  $QuizAttemptAnswersTableManager(_$AppDatabase db, QuizAttemptAnswers table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $QuizAttemptAnswersFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $QuizAttemptAnswersOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $QuizAttemptAnswersAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> attemptId = const Value.absent(),
                Value<String> questionId = const Value.absent(),
                Value<int?> selectedOptionIndex = const Value.absent(),
                Value<int> isCorrect = const Value.absent(),
                Value<int?> answeredAt = const Value.absent(),
              }) => QuizAttemptAnswersCompanion(
                attemptId: attemptId,
                questionId: questionId,
                selectedOptionIndex: selectedOptionIndex,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
              ),
          createCompanionCallback:
              ({
                required String attemptId,
                required String questionId,
                Value<int?> selectedOptionIndex = const Value.absent(),
                required int isCorrect,
                Value<int?> answeredAt = const Value.absent(),
              }) => QuizAttemptAnswersCompanion.insert(
                attemptId: attemptId,
                questionId: questionId,
                selectedOptionIndex: selectedOptionIndex,
                isCorrect: isCorrect,
                answeredAt: answeredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<QuizAttemptAnswers, QuizAttemptAnswer>(table),
                  $QuizAttemptAnswersReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({attemptId = false, questionId = false}) {
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
                    if (attemptId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.attemptId,
                        referencedTable: $QuizAttemptAnswersReferences
                            ._attemptIdTable(db),
                        referencedColumn: $QuizAttemptAnswersReferences
                            ._attemptIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (questionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questionId,
                        referencedTable: $QuizAttemptAnswersReferences
                            ._questionIdTable(db),
                        referencedColumn: $QuizAttemptAnswersReferences
                            ._questionIdTable(db)
                            .id,
                      ) as T;
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

typedef $QuizAttemptAnswersProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      QuizAttemptAnswers,
      QuizAttemptAnswer,
      $QuizAttemptAnswersFilterComposer,
      $QuizAttemptAnswersOrderingComposer,
      $QuizAttemptAnswersAnnotationComposer,
      $QuizAttemptAnswersCreateCompanionBuilder,
      $QuizAttemptAnswersUpdateCompanionBuilder,
      (QuizAttemptAnswer, $QuizAttemptAnswersReferences),
      QuizAttemptAnswer,
      PrefetchHooks Function({bool attemptId, bool questionId})
    >;
typedef $UserQuestsCreateCompanionBuilder = UserQuestsCompanion Function({
  required String id,
  required String questDefinitionId,
  required String periodStart,
  Value<int> currentValue,
  required int targetValue,
  required int xpReward,
  Value<int?> completedAt,
  Value<int> isClaimed,
  Value<int?> claimedAt,
  Value<int> version,
  Value<int> isDirty,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});
typedef $UserQuestsUpdateCompanionBuilder = UserQuestsCompanion Function({
  Value<String> id,
  Value<String> questDefinitionId,
  Value<String> periodStart,
  Value<int> currentValue,
  Value<int> targetValue,
  Value<int> xpReward,
  Value<int?> completedAt,
  Value<int> isClaimed,
  Value<int?> claimedAt,
  Value<int> version,
  Value<int> isDirty,
  Value<String> syncStatus,
  Value<int?> lastSyncedAt,
  Value<int> rowid,
});

final class $UserQuestsReferences
    extends BaseReferences<_$AppDatabase, UserQuests, UserQuest> {
  $UserQuestsReferences(super.$_db, super.$_table, super.$_typedResult);

  static QuestDefinitions _questDefinitionIdTable(_$AppDatabase db) => db
      .questDefinitions
      .createAlias('user_quests__quest_definition_id__quest_definitions__id');

  $QuestDefinitionsProcessedTableManager get questDefinitionId {
    final $_column = $_itemColumn<String>('quest_definition_id')!;

    final manager = $QuestDefinitionsTableManager(
      $_db,
      $_db.questDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questDefinitionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserQuestsFilterComposer extends Composer<_$AppDatabase, UserQuests> {
  $UserQuestsFilterComposer({
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

  ColumnFilters<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isClaimed => $composableBuilder(
    column: $table.isClaimed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $QuestDefinitionsFilterComposer get questDefinitionId {
    final $QuestDefinitionsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questDefinitionId,
      referencedTable: $db.questDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuestDefinitionsFilterComposer(
            $db: $db,
            $table: $db.questDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserQuestsOrderingComposer extends Composer<_$AppDatabase, UserQuests> {
  $UserQuestsOrderingComposer({
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

  ColumnOrderings<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpReward => $composableBuilder(
    column: $table.xpReward,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isClaimed => $composableBuilder(
    column: $table.isClaimed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get claimedAt => $composableBuilder(
    column: $table.claimedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $QuestDefinitionsOrderingComposer get questDefinitionId {
    final $QuestDefinitionsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questDefinitionId,
      referencedTable: $db.questDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuestDefinitionsOrderingComposer(
            $db: $db,
            $table: $db.questDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserQuestsAnnotationComposer
    extends Composer<_$AppDatabase, UserQuests> {
  $UserQuestsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentValue => $composableBuilder(
    column: $table.currentValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetValue => $composableBuilder(
    column: $table.targetValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpReward =>
      $composableBuilder(column: $table.xpReward, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isClaimed =>
      $composableBuilder(column: $table.isClaimed, builder: (column) => column);

  GeneratedColumn<int> get claimedAt =>
      $composableBuilder(column: $table.claimedAt, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $QuestDefinitionsAnnotationComposer get questDefinitionId {
    final $QuestDefinitionsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questDefinitionId,
      referencedTable: $db.questDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $QuestDefinitionsAnnotationComposer(
            $db: $db,
            $table: $db.questDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserQuestsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserQuests,
          UserQuest,
          $UserQuestsFilterComposer,
          $UserQuestsOrderingComposer,
          $UserQuestsAnnotationComposer,
          $UserQuestsCreateCompanionBuilder,
          $UserQuestsUpdateCompanionBuilder,
          (UserQuest, $UserQuestsReferences),
          UserQuest,
          PrefetchHooks Function({bool questDefinitionId})
        > {
  $UserQuestsTableManager(_$AppDatabase db, UserQuests table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserQuestsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserQuestsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserQuestsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> questDefinitionId = const Value.absent(),
                Value<String> periodStart = const Value.absent(),
                Value<int> currentValue = const Value.absent(),
                Value<int> targetValue = const Value.absent(),
                Value<int> xpReward = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> isClaimed = const Value.absent(),
                Value<int?> claimedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserQuestsCompanion(
                id: id,
                questDefinitionId: questDefinitionId,
                periodStart: periodStart,
                currentValue: currentValue,
                targetValue: targetValue,
                xpReward: xpReward,
                completedAt: completedAt,
                isClaimed: isClaimed,
                claimedAt: claimedAt,
                version: version,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String questDefinitionId,
                required String periodStart,
                Value<int> currentValue = const Value.absent(),
                required int targetValue,
                required int xpReward,
                Value<int?> completedAt = const Value.absent(),
                Value<int> isClaimed = const Value.absent(),
                Value<int?> claimedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserQuestsCompanion.insert(
                id: id,
                questDefinitionId: questDefinitionId,
                periodStart: periodStart,
                currentValue: currentValue,
                targetValue: targetValue,
                xpReward: xpReward,
                completedAt: completedAt,
                isClaimed: isClaimed,
                claimedAt: claimedAt,
                version: version,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserQuests, UserQuest>(table),
                  $UserQuestsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questDefinitionId = false}) {
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
                    if (questDefinitionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questDefinitionId,
                        referencedTable: $UserQuestsReferences
                            ._questDefinitionIdTable(db),
                        referencedColumn: $UserQuestsReferences
                            ._questDefinitionIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserQuestsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserQuests,
      UserQuest,
      $UserQuestsFilterComposer,
      $UserQuestsOrderingComposer,
      $UserQuestsAnnotationComposer,
      $UserQuestsCreateCompanionBuilder,
      $UserQuestsUpdateCompanionBuilder,
      (UserQuest, $UserQuestsReferences),
      UserQuest,
      PrefetchHooks Function({bool questDefinitionId})
    >;
typedef $UserInventoriesCreateCompanionBuilder =
    UserInventoriesCompanion Function({
      required String id,
      required String rewardItemId,
      Value<int> isEquipped,
      required int unlockedAt,
      Value<int> version,
      Value<int?> clientUpdatedAt,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });
typedef $UserInventoriesUpdateCompanionBuilder =
    UserInventoriesCompanion Function({
      Value<String> id,
      Value<String> rewardItemId,
      Value<int> isEquipped,
      Value<int> unlockedAt,
      Value<int> version,
      Value<int?> clientUpdatedAt,
      Value<int> isDirty,
      Value<String> syncStatus,
      Value<int?> lastSyncedAt,
      Value<int> rowid,
    });

final class $UserInventoriesReferences
    extends BaseReferences<_$AppDatabase, UserInventories, UserInventory> {
  $UserInventoriesReferences(super.$_db, super.$_table, super.$_typedResult);

  static RewardItems _rewardItemIdTable(_$AppDatabase db) => db.rewardItems
      .createAlias('user_inventories__reward_item_id__reward_items__id');

  $RewardItemsProcessedTableManager get rewardItemId {
    final $_column = $_itemColumn<String>('reward_item_id')!;

    final manager = $RewardItemsTableManager(
      $_db,
      $_db.rewardItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rewardItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $UserInventoriesFilterComposer
    extends Composer<_$AppDatabase, UserInventories> {
  $UserInventoriesFilterComposer({
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

  ColumnFilters<int> get isEquipped => $composableBuilder(
    column: $table.isEquipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );

  $RewardItemsFilterComposer get rewardItemId {
    final $RewardItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardItemId,
      referencedTable: $db.rewardItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RewardItemsFilterComposer(
            $db: $db,
            $table: $db.rewardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserInventoriesOrderingComposer
    extends Composer<_$AppDatabase, UserInventories> {
  $UserInventoriesOrderingComposer({
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

  ColumnOrderings<int> get isEquipped => $composableBuilder(
    column: $table.isEquipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $RewardItemsOrderingComposer get rewardItemId {
    final $RewardItemsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardItemId,
      referencedTable: $db.rewardItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RewardItemsOrderingComposer(
            $db: $db,
            $table: $db.rewardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserInventoriesAnnotationComposer
    extends Composer<_$AppDatabase, UserInventories> {
  $UserInventoriesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get isEquipped => $composableBuilder(
    column: $table.isEquipped,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unlockedAt => $composableBuilder(
    column: $table.unlockedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get clientUpdatedAt => $composableBuilder(
    column: $table.clientUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );

  $RewardItemsAnnotationComposer get rewardItemId {
    final $RewardItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rewardItemId,
      referencedTable: $db.rewardItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $RewardItemsAnnotationComposer(
            $db: $db,
            $table: $db.rewardItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $UserInventoriesTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          UserInventories,
          UserInventory,
          $UserInventoriesFilterComposer,
          $UserInventoriesOrderingComposer,
          $UserInventoriesAnnotationComposer,
          $UserInventoriesCreateCompanionBuilder,
          $UserInventoriesUpdateCompanionBuilder,
          (UserInventory, $UserInventoriesReferences),
          UserInventory,
          PrefetchHooks Function({bool rewardItemId})
        > {
  $UserInventoriesTableManager(_$AppDatabase db, UserInventories table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $UserInventoriesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $UserInventoriesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $UserInventoriesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> rewardItemId = const Value.absent(),
                Value<int> isEquipped = const Value.absent(),
                Value<int> unlockedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int?> clientUpdatedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInventoriesCompanion(
                id: id,
                rewardItemId: rewardItemId,
                isEquipped: isEquipped,
                unlockedAt: unlockedAt,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String rewardItemId,
                Value<int> isEquipped = const Value.absent(),
                required int unlockedAt,
                Value<int> version = const Value.absent(),
                Value<int?> clientUpdatedAt = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserInventoriesCompanion.insert(
                id: id,
                rewardItemId: rewardItemId,
                isEquipped: isEquipped,
                unlockedAt: unlockedAt,
                version: version,
                clientUpdatedAt: clientUpdatedAt,
                isDirty: isDirty,
                syncStatus: syncStatus,
                lastSyncedAt: lastSyncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<UserInventories, UserInventory>(table),
                  $UserInventoriesReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rewardItemId = false}) {
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
                    if (rewardItemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.rewardItemId,
                        referencedTable: $UserInventoriesReferences
                            ._rewardItemIdTable(db),
                        referencedColumn: $UserInventoriesReferences
                            ._rewardItemIdTable(db)
                            .id,
                      ) as T;
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

typedef $UserInventoriesProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      UserInventories,
      UserInventory,
      $UserInventoriesFilterComposer,
      $UserInventoriesOrderingComposer,
      $UserInventoriesAnnotationComposer,
      $UserInventoriesCreateCompanionBuilder,
      $UserInventoriesUpdateCompanionBuilder,
      (UserInventory, $UserInventoriesReferences),
      UserInventory,
      PrefetchHooks Function({bool rewardItemId})
    >;
typedef $DailyStatisticsCreateCompanionBuilder =
    DailyStatisticsCompanion Function({
      required String statDate,
      Value<String?> id,
      Value<int> wordsLearned,
      Value<int> cardsReviewed,
      Value<int> xpGained,
      Value<int> lessonsCompleted,
      Value<int> quizzesCompleted,
      Value<int> correctAnswers,
      Value<int> totalAnswers,
      Value<int> studySeconds,
      Value<int> isDirty,
      Value<int?> lastSyncedAt,
    });
typedef $DailyStatisticsUpdateCompanionBuilder =
    DailyStatisticsCompanion Function({
      Value<String> statDate,
      Value<String?> id,
      Value<int> wordsLearned,
      Value<int> cardsReviewed,
      Value<int> xpGained,
      Value<int> lessonsCompleted,
      Value<int> quizzesCompleted,
      Value<int> correctAnswers,
      Value<int> totalAnswers,
      Value<int> studySeconds,
      Value<int> isDirty,
      Value<int?> lastSyncedAt,
    });

class $DailyStatisticsFilterComposer
    extends Composer<_$AppDatabase, DailyStatistics> {
  $DailyStatisticsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get statDate => $composableBuilder(
    column: $table.statDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get wordsLearned => $composableBuilder(
    column: $table.wordsLearned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xpGained => $composableBuilder(
    column: $table.xpGained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lessonsCompleted => $composableBuilder(
    column: $table.lessonsCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quizzesCompleted => $composableBuilder(
    column: $table.quizzesCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalAnswers => $composableBuilder(
    column: $table.totalAnswers,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $DailyStatisticsOrderingComposer
    extends Composer<_$AppDatabase, DailyStatistics> {
  $DailyStatisticsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get statDate => $composableBuilder(
    column: $table.statDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get wordsLearned => $composableBuilder(
    column: $table.wordsLearned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xpGained => $composableBuilder(
    column: $table.xpGained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lessonsCompleted => $composableBuilder(
    column: $table.lessonsCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quizzesCompleted => $composableBuilder(
    column: $table.quizzesCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalAnswers => $composableBuilder(
    column: $table.totalAnswers,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isDirty => $composableBuilder(
    column: $table.isDirty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DailyStatisticsAnnotationComposer
    extends Composer<_$AppDatabase, DailyStatistics> {
  $DailyStatisticsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get statDate =>
      $composableBuilder(column: $table.statDate, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get wordsLearned => $composableBuilder(
    column: $table.wordsLearned,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cardsReviewed => $composableBuilder(
    column: $table.cardsReviewed,
    builder: (column) => column,
  );

  GeneratedColumn<int> get xpGained =>
      $composableBuilder(column: $table.xpGained, builder: (column) => column);

  GeneratedColumn<int> get lessonsCompleted => $composableBuilder(
    column: $table.lessonsCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quizzesCompleted => $composableBuilder(
    column: $table.quizzesCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<int> get correctAnswers => $composableBuilder(
    column: $table.correctAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalAnswers => $composableBuilder(
    column: $table.totalAnswers,
    builder: (column) => column,
  );

  GeneratedColumn<int> get studySeconds => $composableBuilder(
    column: $table.studySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isDirty =>
      $composableBuilder(column: $table.isDirty, builder: (column) => column);

  GeneratedColumn<int> get lastSyncedAt => $composableBuilder(
    column: $table.lastSyncedAt,
    builder: (column) => column,
  );
}

class $DailyStatisticsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          DailyStatistics,
          DailyStatistic,
          $DailyStatisticsFilterComposer,
          $DailyStatisticsOrderingComposer,
          $DailyStatisticsAnnotationComposer,
          $DailyStatisticsCreateCompanionBuilder,
          $DailyStatisticsUpdateCompanionBuilder,
          (
            DailyStatistic,
            BaseReferences<_$AppDatabase, DailyStatistics, DailyStatistic>,
          ),
          DailyStatistic,
          PrefetchHooks Function()
        > {
  $DailyStatisticsTableManager(_$AppDatabase db, DailyStatistics table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DailyStatisticsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DailyStatisticsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DailyStatisticsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> statDate = const Value.absent(),
                Value<String?> id = const Value.absent(),
                Value<int> wordsLearned = const Value.absent(),
                Value<int> cardsReviewed = const Value.absent(),
                Value<int> xpGained = const Value.absent(),
                Value<int> lessonsCompleted = const Value.absent(),
                Value<int> quizzesCompleted = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalAnswers = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
              }) => DailyStatisticsCompanion(
                statDate: statDate,
                id: id,
                wordsLearned: wordsLearned,
                cardsReviewed: cardsReviewed,
                xpGained: xpGained,
                lessonsCompleted: lessonsCompleted,
                quizzesCompleted: quizzesCompleted,
                correctAnswers: correctAnswers,
                totalAnswers: totalAnswers,
                studySeconds: studySeconds,
                isDirty: isDirty,
                lastSyncedAt: lastSyncedAt,
              ),
          createCompanionCallback:
              ({
                required String statDate,
                Value<String?> id = const Value.absent(),
                Value<int> wordsLearned = const Value.absent(),
                Value<int> cardsReviewed = const Value.absent(),
                Value<int> xpGained = const Value.absent(),
                Value<int> lessonsCompleted = const Value.absent(),
                Value<int> quizzesCompleted = const Value.absent(),
                Value<int> correctAnswers = const Value.absent(),
                Value<int> totalAnswers = const Value.absent(),
                Value<int> studySeconds = const Value.absent(),
                Value<int> isDirty = const Value.absent(),
                Value<int?> lastSyncedAt = const Value.absent(),
              }) => DailyStatisticsCompanion.insert(
                statDate: statDate,
                id: id,
                wordsLearned: wordsLearned,
                cardsReviewed: cardsReviewed,
                xpGained: xpGained,
                lessonsCompleted: lessonsCompleted,
                quizzesCompleted: quizzesCompleted,
                correctAnswers: correctAnswers,
                totalAnswers: totalAnswers,
                studySeconds: studySeconds,
                isDirty: isDirty,
                lastSyncedAt: lastSyncedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<DailyStatistics, DailyStatistic>(table),
                  BaseReferences<
                    _$AppDatabase,
                    DailyStatistics,
                    DailyStatistic
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DailyStatisticsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      DailyStatistics,
      DailyStatistic,
      $DailyStatisticsFilterComposer,
      $DailyStatisticsOrderingComposer,
      $DailyStatisticsAnnotationComposer,
      $DailyStatisticsCreateCompanionBuilder,
      $DailyStatisticsUpdateCompanionBuilder,
      (
        DailyStatistic,
        BaseReferences<_$AppDatabase, DailyStatistics, DailyStatistic>,
      ),
      DailyStatistic,
      PrefetchHooks Function()
    >;
typedef $SyncQueueCreateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  required String opId,
  required String opType,
  required String entityTable,
  required String entityId,
  required String payload,
  Value<String> status,
  Value<int> attemptCount,
  Value<int> nextRetryAt,
  Value<String?> lastError,
  required int createdAt,
});
typedef $SyncQueueUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<int> id,
  Value<String> opId,
  Value<String> opType,
  Value<String> entityTable,
  Value<String> entityId,
  Value<String> payload,
  Value<String> status,
  Value<int> attemptCount,
  Value<int> nextRetryAt,
  Value<String?> lastError,
  Value<int> createdAt,
});

class $SyncQueueFilterComposer extends Composer<_$AppDatabase, SyncQueue> {
  $SyncQueueFilterComposer({
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

  ColumnFilters<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncQueueOrderingComposer extends Composer<_$AppDatabase, SyncQueue> {
  $SyncQueueOrderingComposer({
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

  ColumnOrderings<String> get opId => $composableBuilder(
    column: $table.opId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opType => $composableBuilder(
    column: $table.opType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncQueueAnnotationComposer extends Composer<_$AppDatabase, SyncQueue> {
  $SyncQueueAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get opId =>
      $composableBuilder(column: $table.opId, builder: (column) => column);

  GeneratedColumn<String> get opType =>
      $composableBuilder(column: $table.opType, builder: (column) => column);

  GeneratedColumn<String> get entityTable => $composableBuilder(
    column: $table.entityTable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $SyncQueueTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncQueue,
          SyncQueueData,
          $SyncQueueFilterComposer,
          $SyncQueueOrderingComposer,
          $SyncQueueAnnotationComposer,
          $SyncQueueCreateCompanionBuilder,
          $SyncQueueUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, SyncQueue, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $SyncQueueTableManager(_$AppDatabase db, SyncQueue table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncQueueFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncQueueOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncQueueAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> opId = const Value.absent(),
                Value<String> opType = const Value.absent(),
                Value<String> entityTable = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => SyncQueueCompanion(
                id: id,
                opId: opId,
                opType: opType,
                entityTable: entityTable,
                entityId: entityId,
                payload: payload,
                status: status,
                attemptCount: attemptCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String opId,
                required String opType,
                required String entityTable,
                required String entityId,
                required String payload,
                Value<String> status = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<int> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int createdAt,
              }) => SyncQueueCompanion.insert(
                id: id,
                opId: opId,
                opType: opType,
                entityTable: entityTable,
                entityId: entityId,
                payload: payload,
                status: status,
                attemptCount: attemptCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncQueue, SyncQueueData>(table),
                  BaseReferences<_$AppDatabase, SyncQueue, SyncQueueData>(
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

typedef $SyncQueueProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncQueue,
      SyncQueueData,
      $SyncQueueFilterComposer,
      $SyncQueueOrderingComposer,
      $SyncQueueAnnotationComposer,
      $SyncQueueCreateCompanionBuilder,
      $SyncQueueUpdateCompanionBuilder,
      (SyncQueueData, BaseReferences<_$AppDatabase, SyncQueue, SyncQueueData>),
      SyncQueueData,
      PrefetchHooks Function()
    >;
typedef $SyncMetaCreateCompanionBuilder = SyncMetaCompanion Function({
  required String scope,
  Value<String?> serverCursor,
  Value<int?> lastPulledAt,
  Value<int?> lastPushedAt,
});
typedef $SyncMetaUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> scope,
  Value<String?> serverCursor,
  Value<int?> lastPulledAt,
  Value<int?> lastPushedAt,
});

class $SyncMetaFilterComposer extends Composer<_$AppDatabase, SyncMeta> {
  $SyncMetaFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SyncMetaOrderingComposer extends Composer<_$AppDatabase, SyncMeta> {
  $SyncMetaOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SyncMetaAnnotationComposer extends Composer<_$AppDatabase, SyncMeta> {
  $SyncMetaAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get serverCursor => $composableBuilder(
    column: $table.serverCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPulledAt => $composableBuilder(
    column: $table.lastPulledAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPushedAt => $composableBuilder(
    column: $table.lastPushedAt,
    builder: (column) => column,
  );
}

class $SyncMetaTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          SyncMeta,
          SyncMetaData,
          $SyncMetaFilterComposer,
          $SyncMetaOrderingComposer,
          $SyncMetaAnnotationComposer,
          $SyncMetaCreateCompanionBuilder,
          $SyncMetaUpdateCompanionBuilder,
          (SyncMetaData, BaseReferences<_$AppDatabase, SyncMeta, SyncMetaData>),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $SyncMetaTableManager(_$AppDatabase db, SyncMeta table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SyncMetaFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SyncMetaOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SyncMetaAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> scope = const Value.absent(),
                Value<String?> serverCursor = const Value.absent(),
                Value<int?> lastPulledAt = const Value.absent(),
                Value<int?> lastPushedAt = const Value.absent(),
              }) => SyncMetaCompanion(
                scope: scope,
                serverCursor: serverCursor,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
              ),
          createCompanionCallback:
              ({
                required String scope,
                Value<String?> serverCursor = const Value.absent(),
                Value<int?> lastPulledAt = const Value.absent(),
                Value<int?> lastPushedAt = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                scope: scope,
                serverCursor: serverCursor,
                lastPulledAt: lastPulledAt,
                lastPushedAt: lastPushedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<SyncMeta, SyncMetaData>(table),
                  BaseReferences<_$AppDatabase, SyncMeta, SyncMetaData>(
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

typedef $SyncMetaProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      SyncMeta,
      SyncMetaData,
      $SyncMetaFilterComposer,
      $SyncMetaOrderingComposer,
      $SyncMetaAnnotationComposer,
      $SyncMetaCreateCompanionBuilder,
      $SyncMetaUpdateCompanionBuilder,
      (SyncMetaData, BaseReferences<_$AppDatabase, SyncMeta, SyncMetaData>),
      SyncMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $TopicsTableManager get topics => $TopicsTableManager(_db, _db.topics);
  $FlashcardsTableManager get flashcards =>
      $FlashcardsTableManager(_db, _db.flashcards);
  $GrammarLessonsTableManager get grammarLessons =>
      $GrammarLessonsTableManager(_db, _db.grammarLessons);
  $GrammarExamplesTableManager get grammarExamples =>
      $GrammarExamplesTableManager(_db, _db.grammarExamples);
  $QuizzesTableManager get quizzes => $QuizzesTableManager(_db, _db.quizzes);
  $QuizQuestionsTableManager get quizQuestions =>
      $QuizQuestionsTableManager(_db, _db.quizQuestions);
  $QuizQuestionOptionsTableManager get quizQuestionOptions =>
      $QuizQuestionOptionsTableManager(_db, _db.quizQuestionOptions);
  $QuestDefinitionsTableManager get questDefinitions =>
      $QuestDefinitionsTableManager(_db, _db.questDefinitions);
  $RewardItemsTableManager get rewardItems =>
      $RewardItemsTableManager(_db, _db.rewardItems);
  $LeaderboardCacheTableManager get leaderboardCache =>
      $LeaderboardCacheTableManager(_db, _db.leaderboardCache);
  $UserProfileTableManager get userProfile =>
      $UserProfileTableManager(_db, _db.userProfile);
  $UserFlashcardProgressTableManager get userFlashcardProgress =>
      $UserFlashcardProgressTableManager(_db, _db.userFlashcardProgress);
  $FlashcardReviewLogsTableManager get flashcardReviewLogs =>
      $FlashcardReviewLogsTableManager(_db, _db.flashcardReviewLogs);
  $UserFlashcardNotesTableManager get userFlashcardNotes =>
      $UserFlashcardNotesTableManager(_db, _db.userFlashcardNotes);
  $UserBookmarksTableManager get userBookmarks =>
      $UserBookmarksTableManager(_db, _db.userBookmarks);
  $UserTopicProgressTableManager get userTopicProgress =>
      $UserTopicProgressTableManager(_db, _db.userTopicProgress);
  $UserGrammarProgressTableManager get userGrammarProgress =>
      $UserGrammarProgressTableManager(_db, _db.userGrammarProgress);
  $LessonCompletionsTableManager get lessonCompletions =>
      $LessonCompletionsTableManager(_db, _db.lessonCompletions);
  $QuizAttemptsTableManager get quizAttempts =>
      $QuizAttemptsTableManager(_db, _db.quizAttempts);
  $QuizAttemptAnswersTableManager get quizAttemptAnswers =>
      $QuizAttemptAnswersTableManager(_db, _db.quizAttemptAnswers);
  $UserQuestsTableManager get userQuests =>
      $UserQuestsTableManager(_db, _db.userQuests);
  $UserInventoriesTableManager get userInventories =>
      $UserInventoriesTableManager(_db, _db.userInventories);
  $DailyStatisticsTableManager get dailyStatistics =>
      $DailyStatisticsTableManager(_db, _db.dailyStatistics);
  $SyncQueueTableManager get syncQueue =>
      $SyncQueueTableManager(_db, _db.syncQueue);
  $SyncMetaTableManager get syncMeta =>
      $SyncMetaTableManager(_db, _db.syncMeta);
}
