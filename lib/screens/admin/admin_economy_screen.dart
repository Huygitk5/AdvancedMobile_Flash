import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/theme.dart';
import '../../models/quest_definition_model.dart';
import '../../models/reward_item_model.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';

typedef _Economy = ({List<RewardItem> items, List<QuestDefinition> quests});

class AdminEconomyScreen extends ConsumerStatefulWidget {
  const AdminEconomyScreen({super.key});
  @override
  ConsumerState<AdminEconomyScreen> createState() => _AdminEconomyScreenState();
}

class _AdminEconomyScreenState extends ConsumerState<AdminEconomyScreen> {
  Future<_Economy>? _future;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => setState(() { _future = _fetch(); });

  Future<_Economy> _fetch() async {
    final api = ref.read(adminApiProvider);
    final r = await Future.wait([api.rewardItems(), api.questDefinitions()]);
    return (items: r[0] as List<RewardItem>, quests: r[1] as List<QuestDefinition>);
  }

  Future<void> _openFullScreenForm(Widget formScreen) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => formScreen));
    if (saved == true) _loadData();
  }

  Future<void> _delete(String what, Future<void> Function() call) async {
    if (!await confirmDelete(context, what)) return;
    if (!mounted) return;
    if (await adminRun(context, call, success: 'Đã xoá')) _loadData();
  }

  bool _match(String s) => s.toLowerCase().contains(searchQuery.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0, automaticallyImplyLeading: false,
          title: const Text('Kinh tế', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData)],
          bottom: const TabBar(labelColor: AppTheme.primaryColor, unselectedLabelColor: AppTheme.greyColor, tabs: [Tab(text: 'Shop'), Tab(text: 'Quests')]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(hintText: 'Tìm kiếm...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
            ),
            Expanded(
              child: AdminAsync<_Economy>(
                future: _future,
                onRetry: _loadData,
                builder: (e) => TabBarView(children: [_buildShopTab(e.items), _buildQuestsTab(e.quests)]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inactive(bool active) => active
      ? const SizedBox.shrink()
      : const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Text('(đã tắt)', style: TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        );

  Widget _buildShopTab(List<RewardItem> shopItems) {
    final filteredItems = shopItems.where((i) => _match(i.name)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          final colors = item.borderColors.map((c) => Color(c)).toList();
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: colors.length >= 2 ? LinearGradient(colors: colors) : null,
                ),
                child: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(item.isBorder ? Icons.lens_outlined : Icons.person, color: AppTheme.primaryColor)),
              ),
              title: Row(children: [Flexible(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))), _inactive(item.isActive)]),
              subtitle: Text('Giá: ${item.xpCost} XP${item.requiredRank > 0 ? ' • Top ${item.requiredRank} ${item.rankBoard}' : ''}', style: const TextStyle(color: Colors.orange)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(ShopItemFormScreen(existingItem: item))),
                if (item.isActive)
                  IconButton(
                    tooltip: 'Gỡ khỏi shop',
                    icon: const Icon(Icons.remove_shopping_cart, color: Colors.red),
                    onPressed: () => _delete('"${item.name}" khỏi shop (kho đồ của học viên vẫn giữ)', () => ref.read(adminApiProvider).deleteRewardItem(item.id)),
                  ),
              ]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(const ShopItemFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }

  Widget _buildQuestsTab(List<QuestDefinition> quests) {
    final filteredQuests = quests.where((q) => _match(q.title)).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredQuests.length,
        itemBuilder: (context, index) {
          final quest = filteredQuests[index];
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.amber.shade50, child: Icon(iconFor(quest.iconName), color: Colors.amber)),
              title: Row(children: [Flexible(child: Text(quest.title, style: const TextStyle(fontWeight: FontWeight.bold))), _inactive(quest.isActive)]),
              subtitle: Text('+${quest.xpReward} XP • ${quest.frequency} • ${quest.questType} ×${quest.targetValue}', style: const TextStyle(color: Colors.orange)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(QuestFormScreen(existingQuest: quest))),
                if (quest.isActive)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete('nhiệm vụ "${quest.title}"', () => ref.read(adminApiProvider).deleteQuest(quest.id)),
                  ),
              ]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(const QuestFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }
}

// ================= FORM FULL MÀN HÌNH SHOP =================
class ShopItemFormScreen extends ConsumerStatefulWidget {
  final RewardItem? existingItem;
  const ShopItemFormScreen({super.key, this.existingItem});
  @override
  ConsumerState<ShopItemFormScreen> createState() => _ShopItemFormScreenState();
}

class _ShopItemFormScreenState extends ConsumerState<ShopItemFormScreen> {
  late final TextEditingController codeCtrl, nameCtrl, descCtrl, xpCtrl, colorsCtrl, imageCtrl, rankCtrl, sortCtrl;
  late String itemType;
  late String rankBoard;
  late bool active;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final i = widget.existingItem;
    codeCtrl = TextEditingController(text: i?.code ?? '');
    nameCtrl = TextEditingController(text: i?.name ?? '');
    descCtrl = TextEditingController(text: i?.description ?? '');
    xpCtrl = TextEditingController(text: '${i?.xpCost ?? 0}');
    colorsCtrl = TextEditingController(
        text: (i?.borderColors ?? const []).map((c) => c.toRadixString(16).toUpperCase().padLeft(8, '0')).join(', '));
    imageCtrl = TextEditingController(text: i?.imageUrl ?? '');
    rankCtrl = TextEditingController(text: '${i?.requiredRank ?? 0}');
    sortCtrl = TextEditingController(text: '${i?.sortOrder ?? 0}');
    itemType = i?.type ?? 'BORDER';
    rankBoard = i?.rankBoard ?? 'XP';
    active = i?.isActive ?? true;
  }

  /// "FFFF4D4F, FFFF7A45" -> [4294921551, ...] (ARGB). Thiếu kênh alpha (6 ký tự) thì thêm FF.
  List<int>? _parseColors() {
    final parts = colorsCtrl.text.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return null;
    final out = <int>[];
    for (var p in parts) {
      p = p.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      if (p.length == 6) p = 'FF$p';
      final v = int.tryParse(p, radix: 16);
      if (v == null) throw Exception('Màu không hợp lệ: $p');
      out.add(v);
    }
    return out;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ok = await adminRun(context, () async {
      final colors = _parseColors();
      if (itemType == 'BORDER' && (colors == null || colors.length < 2)) {
        throw Exception('Viền cần 2–5 màu ARGB, VD: FFFF4D4F, FFFF7A45');
      }
      final body = {
        'code': codeCtrl.text.trim().toUpperCase(),
        'name': nameCtrl.text.trim(),
        'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
        'itemType': itemType,
        'xpCost': parseIntOrNull(xpCtrl.text) ?? 0,
        'borderColors': itemType == 'BORDER' ? colors : null,
        'imageUrl': imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
        'requiredRank': parseIntOrNull(rankCtrl.text) ?? 0,
        'rankBoard': rankBoard,
        'isActive': active,
        'sortOrder': parseIntOrNull(sortCtrl.text) ?? 0,
      };
      final api = ref.read(adminApiProvider);
      widget.existingItem == null ? await api.createRewardItem(body) : await api.updateRewardItem(widget.existingItem!.id, body);
    }, success: 'Đã lưu vật phẩm');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(widget.existingItem == null ? 'Thêm Vật phẩm' : 'Sửa Vật phẩm'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(controller: codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Mã (VD: BORDER_FIRE)')),
                  const SizedBox(height: 16),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên vật phẩm')),
                  const SizedBox(height: 16),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: itemType,
                    decoration: const InputDecoration(labelText: 'Loại'),
                    items: const [
                      DropdownMenuItem(value: 'BORDER', child: Text('Viền avatar (BORDER)')),
                      DropdownMenuItem(value: 'AVATAR', child: Text('Ảnh đại diện (AVATAR)')),
                    ],
                    onChanged: (v) => setState(() => itemType = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: xpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Giá XP')),
                  const SizedBox(height: 16),
                  if (itemType == 'BORDER')
                    TextField(controller: colorsCtrl, decoration: const InputDecoration(labelText: 'Màu viền ARGB (2–5 màu, cách nhau dấu phẩy)'))
                  else
                    TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: 'URL ảnh')),
                  const SizedBox(height: 16),
                  TextField(controller: rankCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Yêu cầu hạng (0 = không yêu cầu)')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: rankBoard,
                    decoration: const InputDecoration(labelText: 'Bảng xếp hạng dùng để xét'),
                    items: const [
                      DropdownMenuItem(value: 'XP', child: Text('XP')),
                      DropdownMenuItem(value: 'STREAK', child: Text('Streak')),
                    ],
                    onChanged: (v) => setState(() => rankBoard = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: sortCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thứ tự hiển thị')),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Đang bán'),
                    value: active,
                    onChanged: (v) => setState(() => active = v),
                  ),
                ],
              ),
            ),
            adminDoneButton(context, onPressed: _save, loading: _saving),
          ],
        ),
      ),
    );
  }
}

// ================= FORM FULL MÀN HÌNH NHIỆM VỤ =================
class QuestFormScreen extends ConsumerStatefulWidget {
  final QuestDefinition? existingQuest;
  const QuestFormScreen({super.key, this.existingQuest});
  @override
  ConsumerState<QuestFormScreen> createState() => _QuestFormScreenState();
}

class _QuestFormScreenState extends ConsumerState<QuestFormScreen> {
  late final TextEditingController codeCtrl, titleCtrl, descCtrl, targetCtrl, xpCtrl, iconCtrl, sortCtrl;
  late String questType;
  late String frequency;
  late bool active;
  bool _saving = false;

  static const _typeLabels = {
    'LEARN_WORDS': 'Học thẻ mới',
    'REVIEW_CARDS': 'Ôn thẻ',
    'COMPLETE_LESSON': 'Hoàn thành bài học',
    'COMPLETE_QUIZ': 'Làm bài kiểm tra',
    'PERFECT_QUIZ': 'Đạt 100% bài kiểm tra',
    'STUDY_MINUTES': 'Số phút học',
    'KEEP_STREAK': 'Duy trì streak',
  };
  static const _freqLabels = {'DAILY': 'Hằng ngày', 'WEEKLY': 'Hằng tuần', 'ONE_TIME': 'Một lần'};

  @override
  void initState() {
    super.initState();
    final q = widget.existingQuest;
    codeCtrl = TextEditingController(text: q?.code ?? '');
    titleCtrl = TextEditingController(text: q?.title ?? '');
    descCtrl = TextEditingController(text: q?.description ?? '');
    targetCtrl = TextEditingController(text: '${q?.targetValue ?? 1}');
    xpCtrl = TextEditingController(text: '${q?.xpReward ?? 10}');
    iconCtrl = TextEditingController(text: q?.iconName ?? 'stars');
    sortCtrl = TextEditingController(text: '${q?.sortOrder ?? 0}');
    questType = q?.questType ?? 'REVIEW_CARDS';
    frequency = q?.frequency ?? 'DAILY';
    active = q?.isActive ?? true;
  }

  Future<void> _save() async {
    final body = {
      'code': codeCtrl.text.trim().toUpperCase(),
      'title': titleCtrl.text.trim(),
      'description': descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      'questType': questType,
      'frequency': frequency,
      'targetValue': parseIntOrNull(targetCtrl.text) ?? 1,
      'xpReward': parseIntOrNull(xpCtrl.text) ?? 0,
      'iconName': iconCtrl.text.trim(),
      'isActive': active,
      'sortOrder': parseIntOrNull(sortCtrl.text) ?? 0,
    };
    setState(() => _saving = true);
    final api = ref.read(adminApiProvider);
    final ok = await adminRun(context, () => widget.existingQuest == null
        ? api.createQuest(body)
        : api.updateQuest(widget.existingQuest!.id, body), success: 'Đã lưu nhiệm vụ');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          title: Text(widget.existingQuest == null ? 'Thêm Nhiệm vụ' : 'Sửa Nhiệm vụ'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: ListView(children: [
                  TextField(controller: codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Mã (VD: DAILY_REVIEW_20)')),
                  const SizedBox(height: 16),
                  TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tiêu đề')),
                  const SizedBox(height: 16),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Mô tả')),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: questType,
                    decoration: const InputDecoration(labelText: 'Loại nhiệm vụ'),
                    items: QuestDefinition.questTypes.map((t) => DropdownMenuItem(value: t, child: Text('${_typeLabels[t]} ($t)'))).toList(),
                    onChanged: (v) => setState(() => questType = v!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: frequency,
                    decoration: const InputDecoration(labelText: 'Tần suất'),
                    items: QuestDefinition.frequencies.map((f) => DropdownMenuItem(value: f, child: Text(_freqLabels[f]!))).toList(),
                    onChanged: (v) => setState(() => frequency = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: targetCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Mục tiêu (số lần / số phút)')),
                  const SizedBox(height: 16),
                  TextField(controller: xpCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thưởng XP')),
                  const SizedBox(height: 16),
                  TextField(controller: iconCtrl, decoration: const InputDecoration(labelText: 'Tên icon (VD: style, fact_check, local_fire_department)')),
                  const SizedBox(height: 16),
                  TextField(controller: sortCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Thứ tự hiển thị')),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Đang hoạt động'),
                    value: active,
                    onChanged: (v) => setState(() => active = v),
                  ),
                ]),
              ),
              adminDoneButton(context, onPressed: _save, loading: _saving),
            ],
          ),
        )
    );
  }
}
