import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/mock_data.dart';
import '../../models/user_model.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({Key? key}) : super(key: key);

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late List<UserModel> users;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    users = List.from(MockData.users);
  }

  void _openFullScreenForm([UserModel? existingUser]) async {
    await Navigator.push(context, MaterialPageRoute(builder: (context) => UserFormScreen(existingUser: existingUser)));
    setState(() => _loadData()); // Tải lại danh sách sau khi Lưu
  }

  void _deleteUser(String userId) {
    if (userId == MockData.currentUser.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể tự xóa tài khoản của chính mình!'), backgroundColor: Colors.red));
      return;
    }
    setState(() {
      MockData.users.removeWhere((u) => u.id == userId);
      _loadData();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa người dùng!'), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    // Logic tìm kiếm
    final filteredUsers = users.where((u) => u.fullName.toLowerCase().contains(searchQuery.toLowerCase()) || u.email.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0, automaticallyImplyLeading: false,
        title: Text('Quản lý Học viên', style: TextStyle( fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(hintText: 'Tìm theo tên hoặc email...', prefixIcon: Icon(Icons.search), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isAdmin = user.role == 'ADMIN';
                return Card(
                  elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: CircleAvatar(backgroundColor: isAdmin ? Colors.amber.shade100 : Colors.blue.shade50, child: Text(user.fullName[0].toUpperCase(), style: TextStyle(color: isAdmin ? Colors.amber.shade800 : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20))),
                    title: Row(
                      children: [
                        Expanded(child: Text(user.fullName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (isAdmin) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(10)), child: Text('ADMIN', style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.bold)))
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5), Text(user.email, style: TextStyle(color: AppTheme.greyColor, fontSize: 13)),
                        const SizedBox(height: 5), Text('Level: ${user.level}  •  XP: ${user.totalLifetimeXp}', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 12))
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _openFullScreenForm(user);
                        if (value == 'delete') _deleteUser(user.id);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.amber, size: 20), SizedBox(width: 10), Text('Chỉnh sửa')])),
                        const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 10), Text('Xóa user')])),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(), child: Icon(Icons.person_add, color: Theme.of(context).cardColor),
      ),
    );
  }
}

// ================= FORM TẠO/SỬA USER FULL MÀN HÌNH =================
class UserFormScreen extends StatefulWidget {
  final UserModel? existingUser;
  const UserFormScreen({Key? key, this.existingUser}) : super(key: key);

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  late TextEditingController nameCtrl, emailCtrl;
  String selectedRole = 'USER';
  String selectedLevel = 'A1';

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existingUser?.fullName ?? '');
    emailCtrl = TextEditingController(text: widget.existingUser?.email ?? '');
    selectedRole = widget.existingUser?.role ?? 'USER';
    selectedLevel = widget.existingUser?.level ?? 'A1';
  }

  void _save() {
    final newUser = UserModel(
      id: widget.existingUser?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: nameCtrl.text.trim(), email: emailCtrl.text.trim(), level: selectedLevel, role: selectedRole,
      currentXp: widget.existingUser?.currentXp ?? 0, targetXp: widget.existingUser?.targetXp ?? 100, streakDays: widget.existingUser?.streakDays ?? 0,
      totalWordsLearned: widget.existingUser?.totalWordsLearned ?? 0, completedLessons: widget.existingUser?.completedLessons ?? 0,
      totalLifetimeXp: widget.existingUser?.totalLifetimeXp ?? 0, longestStreak: widget.existingUser?.longestStreak ?? 0, slogan: widget.existingUser?.slogan ?? 'Xin chào, tôi là thành viên mới!',
    );

    if (widget.existingUser == null) {
      MockData.users.add(newUser);
    } else {
      MockData.users[MockData.users.indexWhere((u) => u.id == widget.existingUser!.id)] = newUser;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close, ), onPressed: () => Navigator.pop(context)),
        title: Text(widget.existingUser == null ? 'Thêm Người dùng' : 'Sửa Thông tin', style: TextStyle()),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Họ và Tên')),
                  const SizedBox(height: 20),
                  TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedRole, decoration: const InputDecoration(labelText: 'Phân quyền'),
                    items: const [DropdownMenuItem(value: 'USER', child: Text('Học viên (USER)')), DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên (ADMIN)'))],
                    onChanged: (val) => setState(() => selectedRole = val!),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: selectedLevel, decoration: const InputDecoration(labelText: 'Cấp độ'),
                    items: ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'].map((l) => DropdownMenuItem(value: l, child: Text('Level $l'))).toList(),
                    onChanged: (val) => setState(() => selectedLevel = val!),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 16)),
                onPressed: _save,
                child: Text('Xong (Done)', style: TextStyle(color: Theme.of(context).cardColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}