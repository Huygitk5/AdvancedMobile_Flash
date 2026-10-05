import 'json_helpers.dart';

class Grammar {
  final String id;
  final String title;
  final String description;
  final String structure;
  final String iconName;
  final String level;
  final int estimatedMinutes;
  final double progress;
  final String status; // NOT_STARTED | IN_PROGRESS | COMPLETED
  final int? bestScorePercent;
  final bool isPublished;

  const Grammar({
    required this.id,
    required this.title,
    this.description = '',
    this.structure = '',
    this.iconName = '',
    this.level = 'A1',
    this.estimatedMinutes = 10,
    this.progress = 0,
    this.status = 'NOT_STARTED',
    this.bestScorePercent,
    this.isPublished = true,
  });

  factory Grammar.fromJson(Map<String, dynamic> json) {
    return Grammar(
      id: jStr(json, 'id'),
      title: jStr(json, 'title'),
      description: jStr(json, 'description'),
      structure: jStr(json, 'structure'),
      iconName: jStr(json, 'iconName'),
      level: jStr(json, 'level', 'A1'),
      estimatedMinutes: jInt(json, 'estimatedMinutes', 10),
      progress: jDouble(json, 'progress').clamp(0.0, 1.0),
      status: jStr(json, 'status', 'NOT_STARTED'),
      bestScorePercent: json['bestScorePercent'] == null ? null : jInt(json, 'bestScorePercent'),
      isPublished: jBool(json, 'isPublished', true),
    );
  }
}

class GrammarExample {
  final String id;
  final String sentence;
  final String translation;
  final String highlight;

  const GrammarExample({required this.id, required this.sentence, this.translation = '', this.highlight = ''});

  factory GrammarExample.fromJson(Map<String, dynamic> json) => GrammarExample(
        id: jStr(json, 'id'),
        sentence: jStr(json, 'sentence'),
        translation: jStr(json, 'translation'),
        highlight: jStr(json, 'highlight'),
      );
}

class GrammarDetail {
  final Grammar summary;
  final String content;
  final String usageNotes;
  final List<GrammarExample> examples;
  final String? quizId;

  const GrammarDetail({
    required this.summary,
    this.content = '',
    this.usageNotes = '',
    this.examples = const [],
    this.quizId,
  });

  /// Server trả các trường của chủ điểm (id, title, structure, progress...) cùng cấp với content / examples / quizId.
  factory GrammarDetail.fromJson(Map<String, dynamic> json) => GrammarDetail(
        summary: Grammar.fromJson(json),
        content: jStr(json, 'content'),
        usageNotes: jStr(json, 'usageNotes'),
        examples: jList(json, 'examples').map(GrammarExample.fromJson).toList(),
        quizId: jStrOrNull(json, 'quizId'),
      );
}
