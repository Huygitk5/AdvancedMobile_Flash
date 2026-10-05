import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/clock.dart';
import '../../core/theme.dart';
import '../../models/grammar_model.dart';
import '../../providers/content_providers.dart';
import '../../providers/providers.dart';
import '../home/completion_screen.dart';
import '../quiz/quiz_screen.dart';

class GrammarDetailScreen extends ConsumerStatefulWidget {
  final String grammarId;
  final String title;

  const GrammarDetailScreen({super.key, required this.grammarId, required this.title});

  @override
  ConsumerState<GrammarDetailScreen> createState() => _GrammarDetailScreenState();
}

class _GrammarDetailScreenState extends ConsumerState<GrammarDetailScreen> {
  final DateTime _openedAt = Clock.now();

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
    final r = await _complete();
    if (!mounted) return;
    if (detail.quizId != null) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(quizId: detail.quizId!, title: detail.grammar.title)));
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompletionScreen(lessonCompletionId: r.id, xpEstimate: r.xpEstimate)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(grammarDetailProvider(widget.grammarId));

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: false,
      ),
      body: detail.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Không đọc được bài học: $e')),
        data: (d) => d == null
            ? const Center(child: Text('Bài ngữ pháp không còn tồn tại.', style: TextStyle(color: AppTheme.greyColor)))
            : _buildContent(d),
      ),
    );
  }

  Widget _buildContent(GrammarDetail d) {
    final g = d.grammar;
    final explanation = [g.description, d.content].whereType<String>().where((s) => s.trim().isNotEmpty).join('\n\n');
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
          const SizedBox(height: 20),

          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(g.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                    if (g.bestScorePercent != null) ...[
                      const SizedBox(height: 6),
                      Text('Điểm cao nhất: ${g.bestScorePercent}%', style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                    ],
                    const SizedBox(height: 20),
                    if (explanation.isNotEmpty)
                      Text(explanation, style: const TextStyle(fontSize: 16, height: 1.5)),
                    const SizedBox(height: 25),

                    // Cấu trúc
                    const Row(
                      children: [
                        Icon(Icons.grid_view_rounded, color: AppTheme.greyColor, size: 20),
                        SizedBox(width: 8),
                        Text('Cấu trúc', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Center(
                        child: Text(
                          g.structure,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor),
                        ),
                      ),
                    ),

                    if ((d.usageNotes ?? '').trim().isNotEmpty) ...[
                      const SizedBox(height: 30),
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppTheme.greyColor, size: 20),
                          SizedBox(width: 8),
                          Text('Lưu ý', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(d.usageNotes!, style: const TextStyle(fontSize: 15, height: 1.5)),
                    ],
                    const SizedBox(height: 30),

                    // Ví dụ
                    if (d.examples.isNotEmpty) ...[
                      const Row(
                        children: [
                          Icon(Icons.play_circle_outline, color: AppTheme.greyColor, size: 20),
                          SizedBox(width: 8),
                          Text('Ví dụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 15),
                      ...d.examples.map(_buildExampleItem),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () => _primaryAction(d),
                child: Text(d.quizId != null ? 'Tiếp theo (Làm bài tập)' : 'Hoàn thành',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Theme.of(context).cardColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Câu ví dụ, in đậm cụm `highlight` (nếu có trong câu).
  Widget _buildExampleItem(GrammarExample ex) {
    final base = Theme.of(context).textTheme.bodyLarge?.color;
    final spans = <TextSpan>[];
    final h = ex.highlight?.trim() ?? '';
    final idx = h.isEmpty ? -1 : ex.sentence.toLowerCase().indexOf(h.toLowerCase());
    if (idx < 0) {
      spans.add(TextSpan(text: ex.sentence));
    } else {
      spans
        ..add(TextSpan(text: ex.sentence.substring(0, idx)))
        ..add(TextSpan(
          text: ex.sentence.substring(idx, idx + h.length),
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.primaryColor),
        ))
        ..add(TextSpan(text: ex.sentence.substring(idx + h.length)));
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 8.0, right: 10.0),
            child: CircleAvatar(radius: 3, backgroundColor: Color(0xFF1E293B)),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: base, fontFamily: 'Roboto'),
                    children: spans,
                  ),
                ),
                if ((ex.translation ?? '').isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(ex.translation!, style: const TextStyle(color: AppTheme.greyColor, fontSize: 14)),
                ],
              ],
            ),
          )
        ],
      ),
    );
  }
}
