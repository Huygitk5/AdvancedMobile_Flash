import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/reward_item_model.dart';
import '../../models/quest_model.dart';

class AdminEconomyScreen extends StatefulWidget {
  const AdminEconomyScreen({Key? key}) : super(key: key);
  @override
  State<AdminEconomyScreen> createState() => _AdminEconomyScreenState();
}

class _AdminEconomyScreenState extends State<AdminEconomyScreen> {
  late List<RewardItem> shopItems;
  late List<Quest> quests;
  String searchQuery = ''; // Biến để Filter

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    shopItems = List.from(MockData.shopItems);
    quests = List.from(MockData.quests);
  }

  // MỞ FORM FULL MÀN HÌNH
  void _openFullScreenForm(Widget formScreen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => formScreen));
    setState(() => _loadData()); // Cập nhật UI sau khi form đóng (Done)
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0, automaticallyImplyLeading: false,
          title: Text('Kinh tế', style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold)),
          bottom: const TabBar(labelColor: AppTheme.primaryColor, unselectedLabelColor: AppTheme.greyColor, tabs: [Tab(text: 'Shop'), Tab(text: 'Quests')]),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField( // BỘ LỌC TÌM KIẾM
                onChanged: (val) => setState(() => searchQuery = val),
                decoration: InputDecoration(hintText: 'Tìm kiếm...', prefixIcon: Icon(Icons.search), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildShopTab(),
                  _buildQuestsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShopTab() {
    // Logic Filter
    final filteredItems = shopItems.where((i) => i.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          final item = filteredItems[index];
          return Card(
            elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(item.type == 'border' ? Icons.lens_outlined : Icons.person, color: AppTheme.primaryColor)),
              title: Text(item.name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Giá: ${item.xpCost} XP', style: TextStyle(color: Colors.orange)),
              trailing: IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(ShopItemFormScreen(existingItem: item))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(const ShopItemFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }

  Widget _buildQuestsTab() {
    final filteredQuests = quests.where((q) => q.title.toLowerCase().contains(searchQuery.toLowerCase())).toList();
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
              leading: CircleAvatar(backgroundColor: Colors.amber.shade50, child: Icon(quest.icon, color: Colors.amber)),
              title: Text(quest.title, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('+${quest.xp} XP', style: TextStyle(color: Colors.orange)),
              trailing: IconButton(icon: Icon(Icons.edit, color: Colors.amber), onPressed: () => _openFullScreenForm(QuestFormScreen(existingQuest: quest))),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(const QuestFormScreen()), child: Icon(Icons.add, color: Theme.of(context).cardColor)),
    );
  }
}

// ================= FORM FULL MÀN HÌNH SHOP =================
class ShopItemFormScreen extends StatefulWidget {
  final RewardItem? existingItem;
  const ShopItemFormScreen({Key? key, this.existingItem}) : super(key: key);
  @override
  State<ShopItemFormScreen> createState() => _ShopItemFormScreenState();
}

class _ShopItemFormScreenState extends State<ShopItemFormScreen> {
  late TextEditingController nameCtrl, xpCtrl;
  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existingItem?.name ?? '');
    xpCtrl = TextEditingController(text: widget.existingItem?.xpCost.toString() ?? '');
  }

  void _save() {
    final newItem = RewardItem(id: widget.existingItem?.id ?? DateTime.now().millisecondsSinceEpoch.toString(), name: nameCtrl.text, type: 'border', xpCost: int.tryParse(xpCtrl.text) ?? 0, borderColors: [0xFF000000]);
    if (widget.existingItem == null) MockData.shopItems.add(newItem);
    else MockData.shopItems[MockData.shopItems.indexWhere((i) => i.id == widget.existingItem!.id)] = newItem;
    Navigator.pop(context); // Quay lại
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close, ), onPressed: () => Navigator.pop(context)), // QUAY LẠI GÓC TRÁI TRÊN
        title: Text(widget.existingItem == null ? 'Thêm Vật phẩm' : 'Sửa Vật phẩm', style: TextStyle()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Tên vật phẩm')),
                  const SizedBox(height: 20),
                  TextField(controller: xpCtrl, decoration: const InputDecoration(labelText: 'Giá XP')),
                ],
              ),
            ),
            SizedBox( // NÚT DONE DƯỚI CÙNG
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _save,
                child: Text('Xong (Done)', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Tương tự cho QuestFormScreen...
class QuestFormScreen extends StatelessWidget {
  final Quest? existingQuest;
  const QuestFormScreen({Key? key, this.existingQuest}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(leading: IconButton(icon: Icon(Icons.close, ), onPressed: () => Navigator.pop(context)), title: Text('Form Nhiệm vụ', style: TextStyle())),
        body: Column(
          children: [
            const Expanded(child: Center(child: Text("Màn hình Form Full size cho Nhiệm vụ"))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(width: double.infinity, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)), onPressed: () => Navigator.pop(context), child: Text('Xong (Done)', style: TextStyle(color: Theme.of(context).cardColor)))),
            )
          ],
        )
    );
  }
}