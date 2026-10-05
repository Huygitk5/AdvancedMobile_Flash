import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';

/// Bọc màn hình của người học: kick đồng bộ khi mở, khi app quay lại foreground và khi có mạng trở lại.
/// Mọi trigger đi qua `SyncWorker.kick()` (debounce). Thông báo của sync hiện thành snackbar.
class SyncScope extends ConsumerStatefulWidget {
  const SyncScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<SyncScope> createState() => _SyncScopeState();
}

class _SyncScopeState extends ConsumerState<SyncScope> with WidgetsBindingObserver {
  StreamSubscription<List<ConnectivityResult>>? _net;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    ref.read(syncWorkerProvider).kick(delay: Duration.zero);
    try {
      _net = Connectivity().onConnectivityChanged.listen((r) {
        if (r.any((c) => c != ConnectivityResult.none)) ref.read(syncWorkerProvider).kick();
      }, onError: (_) {});
    } catch (_) {
      // Plugin không có (test): bỏ qua.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.read(syncWorkerProvider).kick();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _net?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(syncMessagesProvider, (_, next) {
      final msg = next.value;
      if (msg == null) return;
      ScaffoldMessenger.maybeOf(context)
        ?..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
    });
    return widget.child;
  }
}
