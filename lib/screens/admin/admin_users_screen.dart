import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme.dart';
import '../../data/remote/dto/page_dto.dart';
import '../../models/user_model.dart';
import '../../providers/providers.dart';
import 'admin_common.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  Future<PageDto<UserModel>>? _future;
  String searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _loadData() => setState(() {
        _future = ref.read(adminApiProvider).users(keyword: searchQuery.trim().isEmpty ? null : searchQuery.trim(), size: 100);
      });

  void _onSearch(String v) {
    searchQuery = v;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _loadData);
  }

  Future<void> _openFullScreenForm([UserModel? existingUser]) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => UserFormScreen(existingUser: existingUser)));
    if (saved == true) _loadData();
  }

  /// Server chặn tự xoá chính mình (422).
  Future<void> _deleteUser(UserModel user) async {
    if (!await confirmDelete(context, 'người dùng ${user.fullName}')) return;
    if (!mounted) return;
    final ok = await adminRun(context, () => ref.read(adminApiProvider).deleteUser(user.id), success: 'Đã xóa người dùng!');
    if (ok) _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0, automaticallyImplyLeading: false,
        title: const Text('Quản lý Học viên', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              onChanged: _onSearch,
              decoration: InputDecoration(hintText: 'Tìm theo tên hoặc email...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Theme.of(context).cardColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
            ),
          ),
          Expanded(
            child: AdminAsync<PageDto<UserModel>>(
              future: _future,
              onRetry: _loadData,
              builder: (page) => page.items.isEmpty
                  ? const Center(child: Text('Không có người dùng nào.', style: TextStyle(color: AppTheme.greyColor)))
                  : RefreshIndicator(
                      onRefresh: () async => _loadData(),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: page.items.length,
                        itemBuilder: (context, index) => _buildUser(page.items[index]),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor, onPressed: () => _openFullScreenForm(), child: Icon(Icons.person_add, color: Theme.of(context).cardColor),
      ),
    );
  }

  Widget _buildUser(UserModel user) {
    final isAdmin = user.role == 'ADMIN';
    final locked = user.status == 'LOCKED';
    return Card(
      elevation: 2, margin: const EdgeInsets.only(bottom: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(backgroundColor: isAdmin ? Colors.amber.shade100 : Colors.blue.shade50, child: Text(user.fullName.isEmpty ? '?' : user.fullName[0].toUpperCase(), style: TextStyle(color: isAdmin ? Colors.amber.shade800 : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20))),
        title: Row(
          children: [
            Expanded(child: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (isAdmin) _badge('ADMIN', Colors.amber),
            if (locked) _badge('KHOÁ', Colors.red),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5), Text(user.email, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
            const SizedBox(height: 5), Text('Level: ${user.level}  •  XP: ${user.totalLifetimeXp}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 12))
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _openFullScreenForm(user);
            if (value == 'delete') _deleteUser(user);
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.amber, size: 20), SizedBox(width: 10), Text('Chỉnh sửa')])),
            PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 20), SizedBox(width: 10), Text('Xóa user')])),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: Theme.of(context).cardColor, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}

// ================= FORM TẠO/SỬA USER FULL MÀN HÌNH =================
class UserFormScreen extends ConsumerStatefulWidget {
  final UserModel? existingUser;
  const UserFormScreen({super.key, this.existingUser});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  late final TextEditingController nameCtrl, emailCtrl, passwordCtrl;
  String selectedRole = 'USER';
  String selectedLevel = 'A1';
  String selectedStatus = 'ACTIVE';
  bool _saving = false;

  bool get _isEdit => widget.existingUser != null;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.existingUser?.fullName ?? '');
    emailCtrl = TextEditingController(text: widget.existingUser?.email ?? '');
    passwordCtrl = TextEditingController();
    selectedRole = widget.existingUser?.role ?? 'USER';
    selectedLevel = widget.existingUser?.level ?? 'A1';
    selectedStatus = widget.existingUser?.status ?? 'ACTIVE';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final api = ref.read(adminApiProvider);
    setState(() => _saving = true);
    final ok = await adminRun(context, () async {
      if (_isEdit) {
        // Không tự khoá / hạ quyền chính mình: server trả 422.
        await api.updateUser(widget.existingUser!.id, {
          'fullName': nameCtrl.text.trim(),
          'level': selectedLevel,
          'role': selectedRole,
          'status': selectedStatus,
        });
      } else {
        await api.createUser({
          'fullName': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text,
          'role': selectedRole,
          'level': selectedLevel,
        });
      }
    }, success: 'Đã lưu người dùng');
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text(_isEdit ? 'Sửa Thông tin' : 'Thêm Người dùng'),
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
                  TextField(controller: emailCtrl, enabled: !_isEdit, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email')),
                  if (!_isEdit) ...[
                    const SizedBox(height: 20),
                    TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu (tối thiểu 8 ký tự)')),
                  ],
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole, decoration: const InputDecoration(labelText: 'Phân quyền'),
                    items: const [DropdownMenuItem(value: 'USER', child: Text('Học viên (USER)')), DropdownMenuItem(value: 'ADMIN', child: Text('Quản trị viên (ADMIN)'))],
                    onChanged: (val) => setState(() => selectedRole = val!),
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    initialValue: selectedLevel, decoration: const InputDecoration(labelText: 'Cấp độ'),
                    items: cefrLevels.map((l) => DropdownMenuItem(value: l, child: Text('Level $l'))).toList(),
                    onChanged: (val) => setState(() => selectedLevel = val!),
                  ),
                  if (_isEdit) ...[
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: selectedStatus == 'LOCKED' ? 'LOCKED' : 'ACTIVE', decoration: const InputDecoration(labelText: 'Trạng thái'),
                      items: const [
                        DropdownMenuItem(value: 'ACTIVE', child: Text('Hoạt động (ACTIVE)')),
                        DropdownMenuItem(value: 'LOCKED', child: Text('Khoá (LOCKED)')),
                      ],
                      onChanged: (val) => setState(() => selectedStatus = val!),
                    ),
                  ],
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
