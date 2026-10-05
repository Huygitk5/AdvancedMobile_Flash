import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../data/admin_repository.dart';
import '../../models/admin_models.dart';
import '../../models/quest_model.dart';
import '../../models/reward_item_model.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';

class AdminEconomyScreen extends StatefulWidget {
  const AdminEconomyScreen({super.key});

  @override
  State<AdminEconomyScreen> createState() => _AdminEconomyScreenState();
}

class _AdminEconomyScreenState extends State<AdminEconomyScreen> {
  List<RewardItem> _items = const [];
  List<QuestDefinition> _quests = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await Future.wait([AdminRepository.rewardItems(), AdminRepository.questDefinitions()]);
      if (!mounted) return;
      setState(() {
        _items = results[0] as List<RewardItem>;
        _quests = results[1] as List<QuestDefinition>;
        _error = null;
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

  Future<void> _openForm(Widget screen) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => screen));
    if (saved == true) _load();
  }

  Future<void> _delete(String name, Future<void> Function() action, String success) async {
    if (!await confirmDelete(context, name)) return;
    try {
      await action();
      if (!mounted) return;
      showAppSnack(context, success);
      _load();
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(tr('Hệ thống Kinh tế'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: TabBar(
            labelColor: AppTheme.primaryColor,
            unselectedLabelColor: AppTheme.greyColor,
            tabs: [Tab(text: tr('Cửa hàng')), Tab(text: tr('Nhiệm vụ'))],
          ),
        ),
        body: _loading
            ? const LoadingView()
            : _error != null
                ? ErrorView(message: _error!, onRetry: _load)
                : TabBarView(children: [_shopTab(), _questTab()]),
      ),
    );
  }

  Widget _shell(List<Widget> items, Color fab, VoidCallback onAdd) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: _load,
        child: items.isEmpty
            ? ListView(children: [SizedBox(height: 260, child: EmptyView(message: tr('Không có dữ liệu'), icon: Icons.inbox_outlined))])
            : ListView(padding: const EdgeInsets.fromLTRB(20, 20, 20, 90), children: items),
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: fab, onPressed: onAdd, child: const Icon(Icons.add, color: Colors.white)),
    );
  }

  Widget _shopTab() {
    return _shell(
      [
        for (final item in _items)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: item.borderColors.length >= 2 ? LinearGradient(colors: item.colors) : null,
                  color: item.borderColors.length >= 2 ? null : Colors.grey.shade300,
                ),
              ),
              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${item.isBorder ? tr('Viền') : tr('Avatar')}  •  ${item.xpCost} XP${item.requiredRank > 0 ? '  •  Top ${item.requiredRank}' : ''}${item.isActive ? '' : '  •  ${tr('Đã ẩn')}'}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openForm(RewardItemFormScreen(existing: item))),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(item.name, () => AdminRepository.deleteRewardItem(item.id), tr('Đã xóa vật phẩm!'))),
                ],
              ),
            ),
          ),
      ],
      AppTheme.primaryColor,
      () => _openForm(const RewardItemFormScreen()),
    );
  }

  Widget _questTab() {
    return _shell(
      [
        for (final q in _quests)
          Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(questIcon(q.iconName), color: AppTheme.primaryColor)),
              title: Text(q.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${q.questType}  •  ${q.targetValue}  •  +${q.xpReward} XP${q.isActive ? '' : '  •  ${tr('Đã ẩn')}'}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.amber), onPressed: () => _openForm(QuestFormScreen(existing: q))),
                  IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _delete(q.title, () => AdminRepository.deleteQuest(q.id), tr('Đã xóa nhiệm vụ!'))),
                ],
              ),
            ),
          ),
      ],
      Colors.orange,
      () => _openForm(const QuestFormScreen()),
    );
  }
}

// ================= FORM VẬT PHẨM =================
class RewardItemFormScreen extends StatefulWidget {
  final RewardItem? existing;

  const RewardItemFormScreen({super.key, this.existing});

  @override
  State<RewardItemFormScreen> createState() => _RewardItemFormScreenState();
}

class _RewardItemFormScreenState extends State<RewardItemFormScreen> {
  late final TextEditingController _code = TextEditingController(text: widget.existing?.code ?? '');
  late final TextEditingController _name = TextEditingController(text: widget.existing?.name ?? '');
  late final TextEditingController _desc = TextEditingController(text: widget.existing?.description ?? '');
  late final TextEditingController _cost = TextEditingController(text: '${widget.existing?.xpCost ?? 0}');
  late final TextEditingController _rank = TextEditingController(text: '${widget.existing?.requiredRank ?? 0}');
  late final TextEditingController _image = TextEditingController(text: widget.existing?.imageUrl ?? '');
  late final TextEditingController _colors = TextEditingController(
      text: (widget.existing?.borderColors ?? const []).map((c) => '#${(c & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}').join(', '));
  late String _type = widget.existing?.type ?? 'BORDER';
  late bool _active = widget.existing?.isActive ?? true;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_code, _name, _desc, _cost, _rank, _image, _colors]) {
      c.dispose();
    }
    super.dispose();
  }

  /// "#FF4D4F, #FF7A45" -> [0xFFFF4D4F, 0xFFFF7A45]
  List<int>? _parseColors() {
    final parts = _colors.text.split(RegExp(r'[,\s]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return const [];
    final result = <int>[];
    for (final p in parts) {
      final hex = p.replaceAll('#', '');
      final value = int.tryParse(hex, radix: 16);
      if (value == null || (hex.length != 6 && hex.length != 8)) return null;
      result.add(hex.length == 6 ? (0xFF000000 | value) : value);
    }
    return result;
  }

  Future<void> _save() async {
    if (_code.text.trim().isEmpty || _name.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập mã và tên vật phẩm'), error: true);
      return;
    }
    final colors = _parseColors();
    if (colors == null || (_type == 'BORDER' && (colors.length < 2 || colors.length > 5))) {
      showAppSnack(context, tr('Viền cần 2-5 mã màu hợp lệ, VD: #FF4D4F, #FF7A45'), error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await AdminRepository.saveRewardItem(widget.existing?.id, {
        'code': _code.text.trim().toUpperCase(),
        'name': _name.text.trim(),
        'description': _desc.text.trim(),
        'itemType': _type,
        'xpCost': int.tryParse(_cost.text) ?? 0,
        'requiredRank': int.tryParse(_rank.text) ?? 0,
        'imageUrl': _image.text.trim().isEmpty ? null : _image.text.trim(),
        'borderColors': colors.length >= 2 ? colors : null,
        'isActive': _active,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormShell(
      title: widget.existing == null ? tr('Thêm Vật phẩm') : tr('Sửa Vật phẩm'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _code, decoration: formDecoration(tr('Mã (chữ IN HOA, số, _)'), hint: 'BORDER_FIRE')),
        formGap(),
        TextField(controller: _name, decoration: formDecoration(tr('Tên vật phẩm'))),
        formGap(),
        TextField(controller: _desc, decoration: formDecoration(tr('Mô tả'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _type,
          decoration: formDecoration(tr('Loại')),
          items: [
            DropdownMenuItem(value: 'BORDER', child: Text(tr('Viền avatar'))),
            DropdownMenuItem(value: 'AVATAR', child: Text(tr('Ảnh đại diện'))),
          ],
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        formGap(),
        TextField(controller: _cost, keyboardType: TextInputType.number, decoration: formDecoration(tr('Giá (XP)'))),
        formGap(),
        TextField(controller: _rank, keyboardType: TextInputType.number, decoration: formDecoration(tr('Yêu cầu hạng (0 = không yêu cầu)'))),
        formGap(),
        TextField(controller: _colors, decoration: formDecoration(tr('Màu viền (2-5 mã hex)'), hint: '#FF4D4F, #FF7A45, #FFA940')),
        formGap(),
        TextField(controller: _image, decoration: formDecoration(tr('Đường dẫn ảnh (cho avatar)'))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Đang bán')), value: _active, onChanged: (v) => setState(() => _active = v)),
      ],
    );
  }
}

// ================= FORM NHIỆM VỤ =================
class QuestFormScreen extends StatefulWidget {
  final QuestDefinition? existing;

  const QuestFormScreen({super.key, this.existing});

  @override
  State<QuestFormScreen> createState() => _QuestFormScreenState();
}

class _QuestFormScreenState extends State<QuestFormScreen> {
  static const List<String> _types = ['LEARN_WORDS', 'REVIEW_CARDS', 'COMPLETE_LESSON', 'COMPLETE_QUIZ', 'PERFECT_QUIZ', 'STUDY_MINUTES', 'KEEP_STREAK'];
  static const List<String> _frequencies = ['DAILY', 'WEEKLY', 'ONE_TIME'];

  late final TextEditingController _code = TextEditingController(text: widget.existing?.code ?? '');
  late final TextEditingController _title = TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _target = TextEditingController(text: '${widget.existing?.targetValue ?? 1}');
  late final TextEditingController _xp = TextEditingController(text: '${widget.existing?.xpReward ?? 10}');
  late final TextEditingController _icon = TextEditingController(text: widget.existing?.iconName ?? 'style');
  late String _type = widget.existing?.questType ?? 'LEARN_WORDS';
  late String _frequency = widget.existing?.frequency ?? 'DAILY';
  late bool _active = widget.existing?.isActive ?? true;
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_code, _title, _target, _xp, _icon]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_code.text.trim().isEmpty || _title.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập mã và tên nhiệm vụ'), error: true);
      return;
    }
    setState(() => _saving = true);
    try {
      await AdminRepository.saveQuest(widget.existing?.id, {
        'code': _code.text.trim().toUpperCase(),
        'title': _title.text.trim(),
        'questType': _type,
        'frequency': _frequency,
        'targetValue': (int.tryParse(_target.text) ?? 1).clamp(1, 100000),
        'xpReward': (int.tryParse(_xp.text) ?? 0).clamp(0, 100000),
        'iconName': _icon.text.trim().isEmpty ? 'style' : _icon.text.trim(),
        'isActive': _active,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showAppSnack(context, errorMessage(e), error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminFormShell(
      title: widget.existing == null ? tr('Thêm Nhiệm vụ') : tr('Sửa Nhiệm vụ'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _code, decoration: formDecoration(tr('Mã (chữ IN HOA, số, _)'), hint: 'DAILY_LEARN_20_WORDS')),
        formGap(),
        TextField(controller: _title, decoration: formDecoration(tr('Tên nhiệm vụ'))),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _type,
          isExpanded: true,
          decoration: formDecoration(tr('Loại nhiệm vụ')),
          items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _type = v ?? _type),
        ),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _frequency,
          decoration: formDecoration(tr('Chu kỳ')),
          items: _frequencies.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (v) => setState(() => _frequency = v ?? _frequency),
        ),
        formGap(),
        Row(
          children: [
            Expanded(child: TextField(controller: _target, keyboardType: TextInputType.number, decoration: formDecoration(tr('Mục tiêu')))),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _xp, keyboardType: TextInputType.number, decoration: formDecoration(tr('Thưởng (XP)')))),
          ],
        ),
        formGap(),
        TextField(controller: _icon, decoration: formDecoration(tr('Tên Icon (VD: style)'))),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: Text(tr('Đang hoạt động')), value: _active, onChanged: (v) => setState(() => _active = v)),
      ],
    );
  }
}
