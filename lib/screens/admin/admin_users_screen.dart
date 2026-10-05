import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/l10n.dart';
import '../../core/theme.dart';
import '../../core/utils.dart';
import '../../data/admin_repository.dart';
import '../../data/app_state.dart';
import '../../models/user_model.dart';
import '../../widgets/common.dart';
import 'admin_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _role = 'USER';
  String _keyword = '';
  Timer? _debounce;
  List<UserModel> _users = const [];
  int _page = 0;
  int _totalPages = 1;
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (more) {
      setState(() => _loadingMore = true);
    } else {
      setState(() {
        _loading = true;
        _error = null;
        _page = 0;
      });
    }
    try {
      final next = more ? _page + 1 : 0;
      final result = await AdminRepository.users(role: _role, keyword: _keyword, page: next);
      if (!mounted) return;
      setState(() {
        _users = more ? [..._users, ...result.items] : result.items;
        _page = result.page;
        _totalPages = result.totalPages;
        _total = result.totalElements;
        _loading = false;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      if (more) {
        showAppSnack(context, errorMessage(e), error: true);
        setState(() => _loadingMore = false);
      } else {
        setState(() {
          _error = errorMessage(e);
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm([UserModel? user]) async {
    final saved = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => UserFormScreen(existingUser: user)));
    if (saved == true) _load();
  }

  Future<void> _toggleLock(UserModel user) async {
    final lock = user.status != 'LOCKED';
    try {
      await AdminRepository.updateUser(user.id, status: lock ? 'LOCKED' : 'ACTIVE');
      if (!mounted) return;
      showAppSnack(context, lock ? tr('Đã khóa tài khoản') : tr('Đã mở khóa tài khoản'));
      _load();
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  Future<void> _delete(UserModel user) async {
    if (user.id == AppState.I.user?.id) {
      showAppSnack(context, tr('Không thể tự xóa tài khoản của chính mình!'), error: true);
      return;
    }
    if (!await confirmDelete(context, user.fullName)) return;
    try {
      await AdminRepository.deleteUser(user.id);
      if (!mounted) return;
      showAppSnack(context, tr('Đã xóa người dùng!'));
      _load();
    } catch (e) {
      if (mounted) showAppSnack(context, errorMessage(e), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(_role == 'USER' ? tr('Quản lý Học viên') : tr('Quản trị viên'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: adminSearchField(context, hint: tr('Tìm theo tên hoặc email...'), onChanged: (v) {
              _keyword = v;
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 350), _load);
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _roleChip(tr('Học viên'), 'USER'),
                const SizedBox(width: 10),
                _roleChip(tr('Quản trị viên'), 'ADMIN'),
                const Spacer(),
                Text(trf('{n} tài khoản', {'n': _total}), style: const TextStyle(color: AppTheme.greyColor, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryColor,
        onPressed: () => _openForm(),
        child: const Icon(Icons.person_add, color: Colors.white),
      ),
    );
  }

  Widget _roleChip(String label, String role) {
    final active = _role == role;
    return GestureDetector(
      onTap: () {
        if (_role == role) return;
        setState(() => _role = role);
        _load();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: active ? Colors.white : AppTheme.greyColor, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  Widget _body() {
    if (_loading) return const LoadingView();
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);
    if (_users.isEmpty) return EmptyView(message: tr('Không có tài khoản nào'), icon: Icons.people_outline);
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
        itemCount: _users.length + (_page + 1 < _totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : TextButton(onPressed: () => _load(more: true), child: Text(tr('Tải thêm'))),
              ),
            );
          }
          return _userCard(_users[index]);
        },
      ),
    );
  }

  Widget _userCard(UserModel user) {
    final isAdmin = user.isAdmin;
    final locked = user.status == 'LOCKED';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(15),
        leading: CircleAvatar(
          backgroundColor: isAdmin ? Colors.amber.shade100 : Colors.blue.shade50,
          child: Text(initialsOf(user.fullName),
              style: TextStyle(color: isAdmin ? Colors.amber.shade800 : AppTheme.primaryColor, fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        title: Row(
          children: [
            Expanded(child: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
            if (locked) _badge(tr('Đã khóa'), Colors.red),
            if (user.status == 'PENDING_VERIFY') _badge(tr('Chờ xác thực'), Colors.orange),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 5),
            Text(user.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.greyColor, fontSize: 13)),
            const SizedBox(height: 5),
            Text(
              isAdmin ? 'ADMIN  •  ${tr('Đăng ký')}: ${user.createdAt == null ? '-' : formatDate(user.createdAt!.toLocal())}'
                  : 'Level: ${user.level}  •  XP: ${user.totalLifetimeXp}  •  Streak: ${user.streakDays}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') _openForm(user);
            if (value == 'lock') _toggleLock(user);
            if (value == 'delete') _delete(user);
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Row(children: [const Icon(Icons.edit, color: Colors.amber, size: 20), const SizedBox(width: 10), Text(tr('Chỉnh sửa'))])),
            PopupMenuItem(
              value: 'lock',
              child: Row(children: [
                Icon(locked ? Icons.lock_open : Icons.lock, color: Colors.orange, size: 20),
                const SizedBox(width: 10),
                Text(locked ? tr('Mở khóa') : tr('Khóa tài khoản')),
              ]),
            ),
            PopupMenuItem(value: 'delete', child: Row(children: [const Icon(Icons.delete, color: Colors.red, size: 20), const SizedBox(width: 10), Text(tr('Xóa user'))])),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) => Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
        child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
      );
}

// ================= FORM TẠO / SỬA TÀI KHOẢN =================
class UserFormScreen extends StatefulWidget {
  final UserModel? existingUser;

  const UserFormScreen({super.key, this.existingUser});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  late final TextEditingController _name = TextEditingController(text: widget.existingUser?.fullName ?? '');
  late final TextEditingController _email = TextEditingController(text: widget.existingUser?.email ?? '');
  final _password = TextEditingController();
  late String _role = widget.existingUser?.role ?? 'USER';
  late String _level = widget.existingUser?.level ?? 'A1';
  late String _status = widget.existingUser?.status == 'LOCKED' ? 'LOCKED' : 'ACTIVE';
  bool _saving = false;

  bool get _isEdit => widget.existingUser != null;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) {
      showAppSnack(context, tr('Vui lòng nhập họ và tên'), error: true);
      return;
    }
    if (!_isEdit) {
      if (!isEmail(_email.text)) {
        showAppSnack(context, tr('Email không hợp lệ'), error: true);
        return;
      }
      if (_password.text.length < 8) {
        showAppSnack(context, tr('Mật khẩu phải có ít nhất 8 ký tự'), error: true);
        return;
      }
    }
    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await AdminRepository.updateUser(widget.existingUser!.id,
            fullName: _name.text.trim(), level: _level, role: _role, status: widget.existingUser!.status == 'PENDING_VERIFY' && _status == 'ACTIVE' ? null : _status);
      } else {
        await AdminRepository.createUser(
            fullName: _name.text.trim(), email: _email.text.trim(), password: _password.text, role: _role, level: _level);
      }
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
      title: _isEdit ? tr('Sửa Thông tin') : tr('Thêm Người dùng'),
      saving: _saving,
      onSave: _save,
      children: [
        TextField(controller: _name, decoration: formDecoration(tr('Họ và Tên'))),
        formGap(),
        TextField(controller: _email, enabled: !_isEdit, keyboardType: TextInputType.emailAddress, decoration: formDecoration('Email')),
        if (!_isEdit) ...[
          formGap(),
          TextField(controller: _password, obscureText: true, decoration: formDecoration(tr('Mật khẩu'), hint: tr('Ít nhất 8 ký tự'))),
        ],
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _role,
          decoration: formDecoration(tr('Phân quyền')),
          items: [
            DropdownMenuItem(value: 'USER', child: Text(tr('Học viên (USER)'))),
            DropdownMenuItem(value: 'ADMIN', child: Text(tr('Quản trị viên (ADMIN)'))),
          ],
          onChanged: (v) => setState(() => _role = v ?? _role),
        ),
        formGap(),
        DropdownButtonFormField<String>(
          initialValue: _level,
          decoration: formDecoration(tr('Cấp độ')),
          items: cefrLevels.map((l) => DropdownMenuItem(value: l, child: Text('Level $l'))).toList(),
          onChanged: (v) => setState(() => _level = v ?? _level),
        ),
        if (_isEdit) ...[
          formGap(),
          DropdownButtonFormField<String>(
            initialValue: _status,
            decoration: formDecoration(tr('Trạng thái')),
            items: [
              DropdownMenuItem(value: 'ACTIVE', child: Text(tr('Hoạt động'))),
              DropdownMenuItem(value: 'LOCKED', child: Text(tr('Đã khóa'))),
            ],
            onChanged: (v) => setState(() => _status = v ?? _status),
          ),
        ],
      ],
    );
  }
}
