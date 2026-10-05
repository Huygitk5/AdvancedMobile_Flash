import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/content_repository.dart';
import '../../data/study_repository.dart';
import '../../models/grammar_model.dart';
import '../../widgets/common.dart';
import '../quiz/quiz_screen.dart';

/// Nội dung một chủ điểm ngữ pháp: giải thích, cấu trúc, ví dụ, rồi sang bài kiểm tra.
class GrammarDetailScreen extends StatefulWidget {
  final String grammarId;
  final String title;

  const GrammarDetailScreen({super.key, required this.grammarId, this.title = ''});

  @override
  State<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends State<GrammarDetailScreen> {
  GrammarDetail? _detail;
  bool _loading = true;
  bool _working = false;
  String? _error;
  final Stopwatch _reading = Stopwatch()..start();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final detail = await ContentRepository.grammarDetail(widget.grammarId);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = errorMessage(e);
        _loading = false;
      });
    }
  }

  Future<void> _next() async {
    final detail = _detail!;
    setState(() => _working = true);
    try {
      // Đọc xong thì ghi nhận bài học (server chống cộng XP trùng khi học lại)
      await StudyRepository.completeLesson(grammarLessonId: detail.summary.id, durationSeconds: _reading.elapsed.inSeconds);
    } catch (_) {
      // vẫn cho làm bài kiểm tra
    }
    if (!mounted) return;
    setState(() => _working = false);
    if (detail.quizId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => QuizScreen(quizId: detail.quizId!, title: detail.summary.title)),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _detail?.summary.title ?? widget.title;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    final detail = _detail!;
    final summary = detail.summary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paragraphs = detail.content.split('\n').where((p) => p.trim().isNotEmpty).toList();
    final notes = detail.usageNotes.split('\n').where((p) => p.trim().isNotEmpty).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: summary.progress,
                  backgroundColor: Colors.grey.shade200,
                  color: summary.status == 'COMPLETED' ? Colors.green : AppTheme.primaryColor,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 10),
              Text('${(summary.progress * 100).round()}%', style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(summary.title,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                      child: Text(summary.level, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (paragraphs.isEmpty && summary.description.isNotEmpty)
                  Text(summary.description, style: const TextStyle(fontSize: 16, height: 1.55)),
                for (final p in paragraphs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(p, style: const TextStyle(fontSize: 16, height: 1.55)),
                  ),
                const SizedBox(height: 16),
                _sectionTitle(Icons.grid_view_rounded, tr('Cấu trúc')),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF273449) : const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(summary.structure,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppTheme.primaryColor, height: 1.4)),
                ),
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 26),
                  _sectionTitle(Icons.lightbulb_outline, tr('Lưu ý')),
                  const SizedBox(height: 10),
                  for (final n in notes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 9, right: 10),
                            child: CircleAvatar(radius: 3, backgroundColor: AppTheme.primaryColor),
                          ),
                          Expanded(child: Text(n, style: const TextStyle(fontSize: 15, height: 1.5))),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: 26),
                _sectionTitle(Icons.play_circle_outline, tr('Ví dụ')),
                const SizedBox(height: 14),
                for (final ex in detail.examples) _exampleItem(ex),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: PrimaryButton(
            label: detail.quizId != null ? tr('Tiếp theo (Kiểm tra)') : tr('Hoàn thành'),
            loading: _working,
            onPressed: _next,
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.greyColor, size: 20),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  /// Câu ví dụ có tô đậm cụm từ chính (highlight).
  Widget _exampleItem(GrammarExample ex) {
    final base = TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4, color: Theme.of(context).textTheme.bodyLarge?.color);
    final spans = <TextSpan>[];
    final sentence = ex.sentence;
    final index = ex.highlight.isEmpty ? -1 : sentence.toLowerCase().indexOf(ex.highlight.toLowerCase());
    if (index < 0) {
      spans.add(TextSpan(text: sentence));
    } else {
      spans.add(TextSpan(text: sentence.substring(0, index)));
      spans.add(TextSpan(
        text: sentence.substring(index, index + ex.highlight.length),
        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
      ));
      spans.add(TextSpan(text: sentence.substring(index + ex.highlight.length)));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 10.0),
            child: CircleAvatar(radius: 3, backgroundColor: AppTheme.primaryColor),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(text: TextSpan(style: base, children: spans)),
                if (ex.translation.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(ex.translation, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
