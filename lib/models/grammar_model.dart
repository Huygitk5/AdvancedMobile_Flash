import '../core/l10n.dart';
import '_json.dart';

class Grammar {
  final String id;
  final String title;
  final String? description;
  final String structure;
  final String iconName;
  final String level;
  final int? coverColor;
  final int estimatedMinutes;
  final double progress;

  /// 'NOT_STARTED' | 'IN_PROGRESS' | 'COMPLETED'
  final String status;
  final int? bestScorePercent;
  final int sortOrder;

  /// Chỉ có ở API admin.
  final bool isPublished;

  const Grammar({
    required this.id,
    required this.title,
    this.description,
    this.structure = '',
    required this.iconName,
    this.level = 'A1',
    this.coverColor,
    this.estimatedMinutes = 10,
    this.progress = 0,
    this.status = 'NOT_STARTED',
    this.bestScorePercent,
    this.sortOrder = 0,
    this.isPublished = true,
  });

  /// Nhãn trạng thái ở danh sách (VD "Đang học 60%"), theo ngôn ngữ giao diện.
  String get statusLabel {
    switch (status) {
      case 'COMPLETED':
        return trf('Đã học {p}%', {'p': 100});
      case 'IN_PROGRESS':
        return trf('Đang học {p}%', {'p': (progress * 100).round()});
      default:
        return trf('Chưa học {p}%', {'p': 0});
    }
  }

  /// `GrammarResponse` (admin).
  factory Grammar.fromJson(Map<String, dynamic> j) => Grammar(
        id: j['id'] as String,
        title: jStr(j['title']),
        description: j['description'] as String?,
        structure: jStr(j['structure']),
        iconName: jStr(j['iconName'], 'menu_book'),
        level: jStr(j['level'], 'A1'),
        coverColor: jIntN(j['coverColor']),
        estimatedMinutes: jInt(j['estimatedMinutes'], 10),
        progress: jDouble(j['progress']),
        status: jStr(j['status'], 'NOT_STARTED'),
        bestScorePercent: jIntN(j['bestScorePercent']),
        isPublished: jBool(j['isPublished'], true),
      );
}

class GrammarExample {
  final String id;
  final String sentence;
  final String? translation;

  /// Cụm cần in đậm trong [sentence].
  final String? highlight;
  final int sortOrder;

  const GrammarExample({
    required this.id,
    required this.sentence,
    this.translation,
    this.highlight,
    this.sortOrder = 0,
  });

  factory GrammarExample.fromJson(Map<String, dynamic> j) => GrammarExample(
        id: jStr(j['id']),
        sentence: jStr(j['sentence']),
        translation: j['translation'] as String?,
        highlight: j['highlight'] as String?,
        sortOrder: jInt(j['sortOrder']),
      );
}

class GrammarDetail {
  final Grammar grammar;
  final String? content;
  final String? usageNotes;
  final List<GrammarExample> examples;

  /// Quiz của chủ điểm, null nếu không có.
  final String? quizId;

  const GrammarDetail({
    required this.grammar,
    this.content,
    this.usageNotes,
    this.examples = const [],
    this.quizId,
  });

  /// `GrammarDetailResponse` (summary được unwrap cùng cấp).
  factory GrammarDetail.fromJson(Map<String, dynamic> j) => GrammarDetail(
        grammar: Grammar.fromJson(j),
        content: j['content'] as String?,
        usageNotes: j['usageNotes'] as String?,
        examples: (j['examples'] as List? ?? const [])
            .map((e) => GrammarExample.fromJson(e as Map<String, dynamic>))
            .toList(),
        quizId: j['quizId'] as String?,
      );
}
