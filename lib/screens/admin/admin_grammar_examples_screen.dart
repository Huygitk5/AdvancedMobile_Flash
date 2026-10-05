import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/grammar_model.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';

/// `examples[]` của GrammarRequest.
List<Map<String, dynamic>> grammarExamplesBody(List<GrammarExample> examples) => [
      for (final e in examples)
        {
          'sentence': e.sentence,
          'translation': (e.translation ?? '').isEmpty ? null : e.translation,
          'highlight': (e.highlight ?? '').isEmpty ? null : e.highlight,
        },
    ];

/// Server THAY TOÀN BỘ ví dụ mỗi lần update: sửa danh sách cục bộ rồi bấm "Lưu" gửi một lần.
class AdminGrammarExamplesScreen extends ConsumerStatefulWidget {
  final String grammarId;
  final String grammarTitle;

  const AdminGrammarExamplesScreen({super.key, required this.grammarId, required this.grammarTitle});

  @override
  ConsumerState<AdminGrammarExamplesScreen> createState() => _AdminGrammarExamplesScreenState();
}

class _AdminGrammarExamplesScreenState extends ConsumerState<AdminGrammarExamplesScreen> {
  Future<GrammarDetail>? _future;
  GrammarDetail? _detail;
  String structure = '';
  String content = '';
  String usageNotes = '';
  List<GrammarExample> examples = [];
  bool _dirty = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final f = ref.read(adminApiProvider).grammarDetail(widget.grammarId);
    setState(() {
      _future = f;
      _dirty = false;
    });
    f.then((d) {
      if (!mounted) return;
      setState(() {
        _detail = d;
        structure = d.grammar.structure;
        content = d.content ?? '';
        usageNotes = d.usageNotes ?? '';
        examples = List.of(d.examples);
      });
    }, onError: (_) {});
  }

  Future<void> _save() async {
    final d = _detail;
    if (d == null) return;
    final g = d.grammar;
    setState(() => _saving = true);
    final ok = await adminRun(context, () => ref.read(adminApiProvider).updateGrammar(widget.grammarId, {
          'title': g.title,
          'description': g.description,
          'structure': structure,
          'content': content.trim().isEmpty ? null : content.trim(),
          'usageNotes': usageNotes.trim().isEmpty ? null : usageNotes.trim(),
          'iconName': g.iconName,
          'level': g.level,
          'coverColor': g.coverColor,
          'estimatedMinutes': g.estimatedMinutes,
          'sortOrder': g.sortOrder,
          'isPublished': g.isPublished,
          'examples': grammarExamplesBody(examples),
        }), success: tr('Đã lưu chủ điểm'));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) _load();
  }

  void _showStructureDialog() {
    final structureCtrl = TextEditingController(text: structure);
    final contentCtrl = TextEditingController(text: content);
    final notesCtrl = TextEditingController(text: usageNotes);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(tr('Cấu trúc & Giải thích'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: structureCtrl, decoration: adminInputDeco(context, tr('Công thức'))),
            const SizedBox(height: 10),
            TextField(controller: contentCtrl, maxLines: 4, decoration: adminInputDeco(context, tr('Giải thích'))),
            const SizedBox(height: 10),
            TextField(controller: notesCtrl, maxLines: 3, decoration: adminInputDeco(context, tr('Lưu ý khi dùng'))),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                structure = structureCtrl.text.trim();
                content = contentCtrl.text;
                usageNotes = notesCtrl.text;
                _dirty = true;
              });
              Navigator.pop(dialogContext);
            },
            child: Text(tr('Xong'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showExampleFormDialog({GrammarExample? existingExample, int? index}) {
    final sentenceController = TextEditingController(text: existingExample?.sentence ?? '');
    final transController = TextEditingController(text: existingExample?.translation ?? '');
    final highlightController = TextEditingController(text: existingExample?.highlight ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(existingExample == null ? tr('Thêm Ví dụ') : tr('Sửa Ví dụ'), style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: sentenceController, decoration: adminInputDeco(context, tr('Câu tiếng Anh'))),
              const SizedBox(height: 10),
              TextField(controller: transController, decoration: adminInputDeco(context, tr('Nghĩa tiếng Việt'))),
              const SizedBox(height: 10),
              TextField(controller: highlightController, decoration: adminInputDeco(context, tr('Cụm từ cần in đậm (VD: am learning)'))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(tr('Hủy'), style: const TextStyle(color: AppTheme.greyColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            onPressed: () {
              if (sentenceController.text.trim().isEmpty) return;
              setState(() {
                final newExample = GrammarExample(
                  id: existingExample?.id ?? '',
                  sentence: sentenceController.text.trim(),
                  translation: transController.text.trim(),
                  highlight: highlightController.text.trim(),
                );
                if (index == null) {
                  examples.add(newExample);
                } else {
                  examples[index] = newExample;
                }
                _dirty = true;
              });
              Navigator.pop(dialogContext);
            },
            child: Text(tr('Xong'), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text(trf('Ngữ pháp: {t}', {'t': widget.grammarTitle}), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton.icon(
            onPressed: _dirty && !_saving ? _save : null,
            icon: _saving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.save_outlined),
            label: Text(tr('Lưu')),
          ),
        ],
      ),
      body: AdminAsync<GrammarDetail>(
        future: _future,
        onRetry: _load,
        builder: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
          children: [
            if (_dirty)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12)),
                child: Text(tr('Có thay đổi chưa lưu. Bấm "Lưu" để gửi toàn bộ lên server.'), style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
              ),
            Card(
              elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(tr('Cấu trúc & Giải thích'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        IconButton(icon: const Icon(Icons.edit, color: Colors.amber, size: 20), onPressed: _showStructureDialog),
                      ],
                    ),
                    const Divider(),
                    Text(tr('Công thức:'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    Text(structure, style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    Text(tr('Giải thích:'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                    Text(content.isEmpty ? tr('(chưa có)') : content, style: const TextStyle(fontSize: 14)),
                    if (usageNotes.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(tr('Lưu ý:'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
                      Text(usageNotes, style: const TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(tr('Danh sách Câu ví dụ'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),

            ...List.generate(examples.length, (index) {
              final ex = examples[index];
              return Card(
                elevation: 2, margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  title: Text(ex.sentence, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ex.translation ?? ''),
                        const SizedBox(height: 4),
                        Text('Highlight: ${ex.highlight ?? ''}', style: const TextStyle(color: AppTheme.primaryColor, fontSize: 12)),
                      ],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _showExampleFormDialog(existingExample: ex, index: index)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => setState(() {
                        examples.removeAt(index);
                        _dirty = true;
                      })),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.purple,
        onPressed: _detail == null ? null : () => _showExampleFormDialog(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(tr('Thêm Ví dụ'), style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
