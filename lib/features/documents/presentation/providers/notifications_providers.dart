import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/services/notifications_bus.dart';
import '../../data/models/local_notification_model.dart';
import '../../data/repositories/local_notifications_repository.dart';

// ── State ──

class NotificationsState {
  final List<LocalNotification> all;
  final List<LocalNotification> visible;
  final bool isLoading;
  final bool hasMore;
  final int unreadCount;
  final String? error;

  const NotificationsState({
    this.all = const [],
    this.visible = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.unreadCount = 0,
    this.error,
  });

  NotificationsState copyWith({
    List<LocalNotification>? all,
    List<LocalNotification>? visible,
    bool? isLoading,
    bool? hasMore,
    int? unreadCount,
    String? error,
  }) {
    return NotificationsState(
      all: all ?? this.all,
      visible: visible ?? this.visible,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      unreadCount: unreadCount ?? this.unreadCount,
      error: error,
    );
  }
}

// ── Notifier ──

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final LocalNotificationsRepository _repo;
  StreamSubscription? _busSub;
  static const _pageSize = 30;

  NotificationsNotifier(this._repo) : super(const NotificationsState()) {
    _busSub = NotificationsBus.stream.listen((_) => _refresh());
    fetchFirstPage();
  }

  Future<void> fetchFirstPage() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final items = await _repo.fetchPage(limit: _pageSize, offset: 0);
      final unread = await _repo.countUnread();
      state = NotificationsState(
        all: items,
        visible: items,
        hasMore: items.length >= _pageSize,
        unreadCount: unread,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repo.fetchPage(
        limit: _pageSize,
        offset: state.all.length,
      );
      final merged = [...state.all, ...items];
      state = state.copyWith(
        all: merged,
        visible: merged,
        isLoading: false,
        hasMore: items.length >= _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String id) async {
    await _repo.markAsRead(id);
    final updated = state.all
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(all: updated, visible: updated, unreadCount: unread);
  }

  Future<void> markAllAsRead() async {
    await _repo.markAllAsRead();
    final updated = state.all.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(all: updated, visible: updated, unreadCount: 0);
  }

  Future<void> deleteById(String id) async {
    await _repo.deleteById(id);
    final updated = state.all.where((n) => n.id != id).toList();
    final unread = updated.where((n) => !n.isRead).length;
    state = state.copyWith(all: updated, visible: updated, unreadCount: unread);
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    state = const NotificationsState();
  }

  Future<void> _refresh() async {
    final items = await _repo.fetchPage(limit: state.all.length.clamp(_pageSize, 999), offset: 0);
    final unread = await _repo.countUnread();
    state = state.copyWith(
      all: items,
      visible: items,
      unreadCount: unread,
    );
  }

  @override
  void dispose() {
    _busSub?.cancel();
    super.dispose();
  }
}

// ── Providers ──

final localNotificationsRepoProvider = Provider<LocalNotificationsRepository>(
  (ref) => LocalNotificationsRepository(),
);

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>(
  (ref) => NotificationsNotifier(ref.watch(localNotificationsRepoProvider)),
);
