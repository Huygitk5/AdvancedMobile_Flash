import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/icons.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../models/quest_definition_model.dart';
import '../../models/reward_item_model.dart';
import '../../providers/providers.dart';
import '../../widgets/common.dart';
import 'admin_common.dart';

typedef _Economy = ({List<RewardItem> items, List<QuestDefinition> quests});

class AdminEconomyScreen extends ConsumerStatefulWidget {
  const AdminEconomyScreen({super.key});

  @override
  ConsumerState<AdminEconomyScreen> createState() => _AdminEconomyScreenState();
}

class _AdminEconomyScreenState extends ConsumerState<AdminEconomyScreen> {
  Future<_Economy>? _future;
  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() => setState(() {
        _future = _fetch();
      });

  Future<_Economy> _fetch() async {
    final api = ref.read(adminApiProvider);
    final r = await Future.wait([api.rewardItems(), api.questDefinitions()]);
    return (items: r[0] as List<RewardItem>, quests: r[1] as List<QuestDefinition>);
  }

  Future<void> _openForm(Widget formScreen) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => formScreen));
    if (saved == true) _loadData();
  }

  Future<void> _delete(String what, Future<void> Function() call, String success) async {
    if (!await confirmDelete(context, what)) return;
    if (!mounted) return;
    if (await adminRun(context, call, success: success)) _loadData();
  }

  bool _match(String s) => s.toLowerCase().contains(_keyword.toLowerCase());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(tr('Hệ thống Kinh tế'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          actions: [IconButton(tooltip: tr('Làm mới'), icon: const Icon(Icons.refresh), onPressed: _loadData)],
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            tabs: [Tab(text: tr('Cửa hàng')), Tab(text: tr('Nhiệm vụ'))],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: adminSearchField(context, hint: tr('Tìm kiếm...'), onChanged: (v) => setState(() => _keyword = v)),
            ),
            Expanded(
              child: AdminAsync<_Economy>(
                future: _future,
                onRetry: _loadData,
                builder: (e) => TabBarView(children: [_shopTab(e.items), _questTab(e.quests)]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shell(List<Widget> items, Color fab, VoidCallback onAdd) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
          await _future;
        },
        child: items.isEmpty
            ? ListView(children: [SizedBox(height: 260, child: EmptyView(message: tr('Không có dữ liệu'), icon: Icons.inbox_outlined))])
            : ListView(padding: const EdgeInsets.fromLTRB(20, 0, 20, 90), children: items),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: fab, onPressed: onAdd, child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _inactive(bool active) => active
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(tr('(đã tắt)'), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
        );

  Widget _shopTab(List<RewardItem> all) {
    return _shell(
      [
        for (final item in all.where((i) => _match(i.name)))
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: UserAvatar(
                size: 46,
                ringWidth: 2.5,
                borderColors: item.borderColors.length >= 2
                    ? item.borderColors.map((c) => Color(c)).toList()
                    : [Colors.grey.shade300, Colors.grey.shade300],
                imageUrl: item.isAvatar ? item.imageUrl : null,
              ),
              title: Row(children: [Flexible(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold))), _inactive(item.isActive)]),
              subtitle: Text(
                '${item.isBorder ? tr('Viền') : tr('Avatar')}  •  ${item.xpCost} XP'
                '${item.requiredRank > 0 ? '  •  Top ${item.requiredRank} ${item.rankBoard}' : ''}',
                style: const TextStyle(color: Colors.orange),
              ),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openForm(ShopItemFormScreen(existingItem: item))),
                if (item.isActive)
                  IconButton(
                    tooltip: tr('Gỡ khỏi shop'),
                    icon: const Icon(Icons.remove_shopping_cart, color: Colors.red),
                    onPressed: () => _delete(
                      trf('{name} khỏi shop (kho đồ của học viên vẫn giữ)', {'name': item.name}),
                      () => ref.read(adminApiProvider).deleteRewardItem(item.id),
                      tr('Đã xóa vật phẩm!'),
                    ),
                  ),
              ]),
            ),
          ),
      ],
      AppTheme.primaryColor,
      () => _openForm(const ShopItemFormScreen()),
    );
  }

  Widget _questTab(List<QuestDefinition> all) {
    return _shell(
      [
        for (final quest in all.where((q) => _match(q.title)))
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.amber.shade50, child: Icon(iconFor(quest.iconName), color: Colors.amber)),
              title: Row(children: [Flexible(child: Text(quest.title, style: const TextStyle(fontWeight: FontWeight.bold))), _inactive(quest.isActive)]),
              subtitle: Text('+${quest.xpReward} XP • ${quest.frequency} • ${quest.questType} ×${quest.targetValue}',
                  style: const TextStyle(color: Colors.orange)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openForm(QuestFormScreen(existingQuest: quest))),
                if (quest.isActive)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _delete(quest.title, () => ref.read(adminApiProvider).deleteQuest(quest.id), tr('Đã xóa nhiệm vụ!')),
                  ),
              ]),
            ),
          ),
      ],
      Colors.orange,
      () => _openForm(const QuestFormScreen()),
    );
  }
}

// ================= FORM VẬT PHẨM =================
class ShopItemFormScreen extends ConsumerStatefulWidget {
  final RewardItem? existingItem;

  const ShopItemFormScreen({super.key, this.existingItem});

  @override
  ConsumerState<ShopItemFormScreen> createState() => _ShopItemFormScreenState();
}

class _ShopItemFormScreenState extends ConsumerState<ShopItemFormScreen> {
  late final RewardItem? _i = widget.existingItem;
  late final TextEditingController _code = TextEditingController(text: _i?.code ?? '');
  late final TextEditingController _name = TextEditingController(text: _i?.name ?? '');
  late final TextEditingController _desc = TextEditingController(text: _i?.description ?? '');
  late final TextEditingController _cost = TextEditingController(text: '${_i?.xpCost ?? 0}');
  late final TextEditingController _colors = TextEditingController(text: (_i?.borderColors ?? const []).map(_hex).join(', '));
  late final TextEditingController _image = TextEditingController(text: _i?.imageUrl ?? '');
  late final TextEditingController _rank = TextEditingController(text: '${_i?.requiredRank ?? 0}');
  late final TextEditingController _sort = TextEditingController(text: '${_i?.sortOrder ?? 0}');
  late String _type = _i?.type ?? 'BORDER';
  late String _rankBoard = _i?.rankBoard ?? 'XP';
  late bool _active = _i?.isActive ?? true;
  bool _saving = false;

  /// ARGB -> "#RRGGBB" (đục hoàn toàn) hoặc "AARRGGBB" (có trong suốt).
  static String _hex(int argb) => (argb >>> 24) == 0xFF
      ? '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}'
      : argb.toRadixString(16).padLeft(8, '0').toUpperCase();

  @override
  void dispose() {
    for (final c in [_code, _name, _desc, _cost, _colors, _image, _rank, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "#FF4D4F, FFFF7A45" -> [0xFFFF4D4F, 0xFFFF7A45]. 6 ký tự thì thêm kênh alpha FF. Sai định dạng trả null.
  List<int>? _parseColors() {
    final parts = _colors.text.split(RegExp(r'[,\s]+')).where((s) => s.isNotEmpty).toList();
    final out = <int>[];
    for (var p in parts) {
      p = p.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
      if (p.length != 6 && p.length != 8) return null;
      final v = int.tryParse(p.length == 6 ? 'FF$p' : p, radix: 16);
      if (v == null) return null;
      out.add(v);
    }
    return out;
  }

  Future<void> _save() async {
    if (_code.text.trim().isEmpty || _name.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập mã và tên vật phẩm'), error: true);
      return;
    }
    final colors = _parseColors();
    if (_type == 'BORDER' && (colors == null || colors.length < 2 || colors.length > 5)) {
      showAppSnack(context, tr('Viền cần 2-5 mã màu hợp lệ, VD: #FF4D4F, #FF7A45'), error: true);
      return;
    }
    final body = {
      'code': _code.text.trim().toUpperCase(),
      'name': _name.text.trim(),
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'itemType': _type,
      'xpCost': (parseIntOrNull(_cost.text) ?? 0).clamp(0, 1000000),
      'borderColors': _type == 'BORDER' ? colors : null,
      'imageUrl': _image.text.trim().isEmpty ? null : _image.text.trim(),
      'requiredRank': (parseIntOrNull(_rank.text) ?? 0).clamp(0, 1000),
      'rankBoard': _rankBoard,
      'isActive': _active,
      'sortOrder': parseIntOrNull(_sort.text) ?? 0,
    };
    final api = ref.read(adminApiProvider);
    setState(() => _saving = true);
    final ok = await adminRun(
        context, () => _i == null ? api.createRewardItem(body) : api.updateRewardItem(_i.id, body),
        success: tr('Đã lưu vật phẩm'));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormShell(
      title: _i == null ? tr('Thêm Vật phẩm') : tr('Sửa Vật phẩm'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            decoration: formDecoration(tr('Mã (chữ IN HOA, số, _)'), hint: 'BORDER_FIRE')),
        formGap(),
        TextField(controller: _name, decoration: formDecoration(tr('Tên vật phẩm'))),
        formGap(),
        TextField(controller: _desc, decoration: formDecoration(tr('Mô tả'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: formDecoration(tr('Loại')),
          items: [
            DropdownMenuItem(value: 'BORDER', child: Text(tr('Viền avatar (BORDER)'))),
            DropdownMenuItem(value: 'AVATAR', child: Text(tr('Ảnh đại diện (AVATAR)'))),
          ],
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        formGap(),
        TextField(controller: _cost, keyboardType: TextInputType.number, decoration: formDecoration(tr('Giá (XP)'))),
        formGap(),
        if (_type == 'BORDER')
          TextField(controller: _colors, decoration: formDecoration(tr('Màu viền (2-5 mã hex)'), hint: '#FF4D4F, #FF7A45, #FFA940'))
        else
          TextField(controller: _image, keyboardType: TextInputType.url, decoration: formDecoration(tr('Đường dẫn ảnh (cho avatar)'))),
        formGap(),
        TextField(controller: _rank, keyboardType: TextInputType.number, decoration: formDecoration(tr('Yêu cầu hạng (0 = không yêu cầu)'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _rankBoard,
          decoration: formDecoration(tr('Bảng xếp hạng dùng để xét')),
          items: const [
            DropdownMenuItem(value: 'XP', child: Text('XP')),
            DropdownMenuItem(value: 'STREAK', child: Text('Streak')),
          ],
          onChanged: (v) => setState(() => _rankBoard = v ?? _rankBoard),
        ),
        formGap(),
        TextField(controller: _sort, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thứ tự hiển thị'))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Đang bán')), value: _active, onChanged: (v) => setState(() => _active = v)),
      ],
    );
  }
}

// ================= FORM NHIỆM VỤ =================
class QuestFormScreen extends ConsumerStatefulWidget {
  final QuestDefinition? existingQuest;

  const QuestFormScreen({super.key, this.existingQuest});

  @override
  ConsumerState<QuestFormScreen> createState() => _QuestFormScreenState();
}

class _QuestFormScreenState extends ConsumerState<QuestFormScreen> {
  late final QuestDefinition? _q = widget.existingQuest;
  late final TextEditingController _code = TextEditingController(text: _q?.code ?? '');
  late final TextEditingController _title = TextEditingController(text: _q?.title ?? '');
  late final TextEditingController _desc = TextEditingController(text: _q?.description ?? '');
  late final TextEditingController _target = TextEditingController(text: '${_q?.targetValue ?? 1}');
  late final TextEditingController _xp = TextEditingController(text: '${_q?.xpReward ?? 10}');
  late final TextEditingController _icon = TextEditingController(text: _q?.iconName ?? 'style');
  late final TextEditingController _sort = TextEditingController(text: '${_q?.sortOrder ?? 0}');
  late String _type = _q?.questType ?? 'LEARN_WORDS';
  late String _frequency = _q?.frequency ?? 'DAILY';
  late bool _active = _q?.isActive ?? true;
  bool _saving = false;

  static Map<String, String> get _typeLabels => {
        'LEARN_WORDS': tr('Học thẻ mới'),
        'REVIEW_CARDS': tr('Ôn thẻ'),
        'COMPLETE_LESSON': tr('Hoàn thành bài học'),
        'COMPLETE_QUIZ': tr('Làm bài kiểm tra'),
        'PERFECT_QUIZ': tr('Đạt 100% bài kiểm tra'),
        'STUDY_MINUTES': tr('Số phút học'),
        'KEEP_STREAK': tr('Duy trì streak'),
      };

  static Map<String, String> get _freqLabels => {'DAILY': tr('Hằng ngày'), 'WEEKLY': tr('Hằng tuần'), 'ONE_TIME': tr('Một lần')};

  @override
  void dispose() {
    for (final c in [_code, _title, _desc, _target, _xp, _icon, _sort]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_code.text.trim().isEmpty || _title.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập mã và tên nhiệm vụ'), error: true);
      return;
    }
    final body = {
      'code': _code.text.trim().toUpperCase(),
      'title': _title.text.trim(),
      'description': _desc.text.trim().isEmpty ? null : _desc.text.trim(),
      'questType': _type,
      'frequency': _frequency,
      'targetValue': (parseIntOrNull(_target.text) ?? 1).clamp(1, 100000),
      'xpReward': (parseIntOrNull(_xp.text) ?? 0).clamp(0, 100000),
      'iconName': _icon.text.trim().isEmpty ? 'style' : _icon.text.trim(),
      'isActive': _active,
      'sortOrder': parseIntOrNull(_sort.text) ?? 0,
    };
    final api = ref.read(adminApiProvider);
    setState(() => _saving = true);
    final ok = await adminRun(context, () => _q == null ? api.createQuest(body) : api.updateQuest(_q.id, body),
        success: tr('Đã lưu nhiệm vụ'));
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormShell(
      title: _q == null ? tr('Thêm Nhiệm vụ') : tr('Sửa Nhiệm vụ'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            decoration: formDecoration(tr('Mã (chữ IN HOA, số, _)'), hint: 'DAILY_LEARN_20_WORDS')),
        formGap(),
        TextField(controller: _title, decoration: formDecoration(tr('Tên nhiệm vụ'))),
        formGap(),
        TextField(controller: _desc, decoration: formDecoration(tr('Mô tả'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: QuestDefinition.questTypes.contains(_type) ? _type : null,
          isExpanded: true,
          decoration: formDecoration(tr('Loại nhiệm vụ')),
          items: QuestDefinition.questTypes
              .map((t) => DropdownMenuItem(value: t, child: Text('${_typeLabels[t]} ($t)', overflow: TextOverflow.ellipsis)))
              .toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: QuestDefinition.frequencies.contains(_frequency) ? _frequency : null,
          decoration: formDecoration(tr('Chu kỳ')),
          items: QuestDefinition.frequencies.map((f) => DropdownMenuItem(value: f, child: Text(_freqLabels[f]!))).toList(),
          onChanged: (v) => setState(() => _frequency = v ?? _frequency),
        ),
        formGap(),
        Row(
          children: [
            Expanded(
                child: TextField(
                    controller: _target, keyboardType: TextInputType.number, decoration: formDecoration(tr('Mục tiêu (số lần / số phút)')))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _xp, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thưởng (XP)')))),
          ],
        ),
        formGap(),
        TextField(controller: _icon, decoration: formDecoration(tr('Tên Icon (VD: style)'), hint: 'style, fact_check, local_fire_department')),
        formGap(),
        TextField(controller: _sort, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thứ tự hiển thị'))),
        SwitchListTile(
            contentPadding: EdgeInsets.zero, title: Text(tr('Đang hoạt động')), value: _active, onChanged: (v) => setState(() => _active = v)),
      ],
    );
  }
}
