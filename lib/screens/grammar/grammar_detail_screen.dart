import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/feedback_model.dart';
import '../../models/grammar_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import '../../widgets/feedback_dialog.dart';
import '../home/completion_screen.dart';
import '../quiz/quiz_screen.dart';

/// Nội dung một chủ điểm ngữ pháp (đọc từ SQLite): giải thích, cấu trúc, lưu ý, ví dụ, rồi sang bài kiểm tra.
class GrammarDetailScreen extends ConsumerStatefulWidget {
  final String grammarId;
  final String title;

  const GrammarDetailScreen({super.key, required this.grammarId, this.title = ''});

  @override
  ConsumerState<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  final DateTime _openedAt = Clock.now();
  bool _working = false;

  /// LESSON_COMPLETE chỉ gửi 1 lần mỗi lượt mở màn (cuộn hết hoặc bấm nút).
  Future<({String id, int xpEstimate})>? _completion;

  Future<({String id, int xpEstimate})> _complete() => _completion ??= ref
      .read(lessonRepositoryProvider)
      .completeGrammar(widget.grammarId, durationSeconds: Clock.now().difference(_openedAt).inSeconds);

  bool _onScroll(ScrollNotification n) {
    if (_completion == null && n.metrics.maxScrollExtent > 0 && n.metrics.extentAfter < 24) _complete();
    return false;
  }

  Future<void> _primaryAction(GrammarDetail detail) async {
    setState(() => _working = true);
    try {
      final r = await _complete();
      if (!mounted) return;
      if (detail.quizId != null) {
        await Navigator.push(
            context, MaterialPageRoute(builder: (context) => QuizScreen(quizId: detail.quizId!, title: detail.grammar.title)));
      } else {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => CompletionScreen(lessonCompletionId: r.id, xpEstimate: r.xpEstimate, title: detail.grammar.title)),
        );
      }
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(grammarDetailProvider(widget.grammarId));
    final title = detail.value?.grammar.title ?? widget.title;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: detail.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorView(message: trf('Không đọc được bài học: {e}', {'e': e})),
        data: (d) => d == null
            ? EmptyView(message: tr('Bài ngữ pháp không còn tồn tại.'), icon: Icons.menu_book_outlined)
            : _buildContent(d),
      ),
    );
  }

  static List<String> _lines(String? text) =>
      (text ?? '').split('\n').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

  Widget _buildContent(GrammarDetail d) {
    final g = d.grammar;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final paragraphs = [..._lines(g.description), ..._lines(d.content)];
    final notes = _lines(d.usageNotes);

    return SafeArea(
      child: Column(
        children: [
          // Thanh tiến độ của chủ điểm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: g.progress,
                    backgroundColor: Colors.grey.shade200,
                    color: g.status == 'COMPLETED' ? Colors.green : AppTheme.primaryColor,
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${(g.progress * 100).round()}%', style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(g.title,
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(8)),
                          child: Text(g.level,
                              style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        FeedbackIconButton(type: FeedbackType.grammar, itemId: g.id, targetLabel: g.title),
                      ],
                    ),
                    if (g.bestScorePercent != null) ...[
                      const SizedBox(height: 6),
                      Text(trf('Điểm cao nhất: {n}%', {'n': g.bestScorePercent!}),
                          style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                    ],
                    const SizedBox(height: 16),
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
                      child: Text(g.structure,
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
                    if (d.examples.isNotEmpty) ...[
                      const SizedBox(height: 26),
                      _sectionTitle(Icons.play_circle_outline, tr('Ví dụ')),
                      const SizedBox(height: 14),
                      for (final ex in d.examples) _exampleItem(ex),
                    ],
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: PrimaryButton(
              label: d.quizId != null ? tr('Tiếp theo (Kiểm tra)') : tr('Hoàn thành'),
              loading: _working,
              onPressed: () => _primaryAction(d),
            ),
          ),
        ],
      ),
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

  /// Câu ví dụ có tô đậm cụm từ chính (highlight), nếu có trong câu.
  Widget _exampleItem(GrammarExample ex) {
    final base = TextStyle(fontWeight: FontWeight.w600, fontSize: 15, height: 1.4, color: Theme.of(context).textTheme.bodyLarge?.color);
    final spans = <TextSpan>[];
    final sentence = ex.sentence;
    final h = ex.highlight?.trim() ?? '';
    final index = h.isEmpty ? -1 : sentence.toLowerCase().indexOf(h.toLowerCase());
    if (index < 0) {
      spans.add(TextSpan(text: sentence));
    } else {
      spans
        ..add(TextSpan(text: sentence.substring(0, index)))
        ..add(TextSpan(
          text: sentence.substring(index, index + h.length),
          style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w900, decoration: TextDecoration.underline),
        ))
        ..add(TextSpan(text: sentence.substring(index + h.length)));
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
                if ((ex.translation ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(ex.translation!, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
