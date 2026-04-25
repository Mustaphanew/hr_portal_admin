// notification_fcm_service_mobile.dart

import 'dart:convert';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hr_portal_admin/core/services/awesome_notification_service.dart';
import 'package:hr_portal_admin/core/services/db/db_helper.dart';
import 'package:hr_portal_admin/core/services/notification_fcm/topic_service.dart';
import 'package:hr_portal_admin/core/services/notifications_bus.dart';

class NotificationFCMService {
  static const String _defaultTopic = 'hr_portal_admin';
  static const String _tableNotifications = 'notifications';

  RemoteMessage? _initialMessage;
  bool _inited = false;

  static bool _isFcmServiceUnavailableError(Object e) {
    return e.toString().toUpperCase().contains('SERVICE_NOT_AVAILABLE');
  }

  /// جلب [getToken] دون رفع ضجيج في الكونسول لحالات البيئة الشائعة (مثل محاكي بلا GMS).
  Future<void> _tryGetFcmTokenAndSubscribe() async {
    try {
      final token = await FirebaseMessaging.instance
          .getToken()
          .timeout(const Duration(seconds: 15), onTimeout: () => null);
      if (kDebugMode && token != null && token.isNotEmpty) {
        log('fcmToken: $token');
      }
      if (token != null && token.isNotEmpty) {
        TopicService.subscribe(_defaultTopic);
      }
    } catch (e, s) {
      if (_isFcmServiceUnavailableError(e)) {
        if (kDebugMode) {
          debugPrint(
            '[FCM] getToken: SERVICE_NOT_AVAILABLE (استخدم صورة Google Play في المحاكي أو جهاز بلا حجب Google).',
          );
        }
        return;
      }
      log('FCM getToken failed: $e', stackTrace: s);
    }
  }

  Future<void> initFCM() async {
    if (_inited) return;
    _inited = true;

    try {
      // 1) Permissions
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // iOS: show local notification via Awesome, so disable system presentation
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );

      // 2) FCM token — may fail on emulator without GMS, offline, etc. Non-fatal.
      await _tryGetFcmTokenAndSubscribe();

      FirebaseMessaging.instance.onTokenRefresh.listen((t) async {
        if (kDebugMode) {
          log('fcmToken refreshed: $t');
        }
        await TopicService.subscribe(_defaultTopic);
      });

      // 3) Terminated / foreground / opened — always register
      _initialMessage = await FirebaseMessaging.instance.getInitialMessage();

      FirebaseMessaging.onMessage.listen((m) async {
        await _onForegroundMessage(m);
      });

      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenSafely);
    } catch (e, s) {
      log('initFCM error: $e', stackTrace: s);
    }
  }

  Future<void> handleInitialMessageAfterAppReady() async {
    final msg = _initialMessage;
    if (msg == null) return;
    _initialMessage = null;
    await _handleOpen(msg);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final d = message.data;

    final id =
        (d['id'] ??
                message.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString())
            .toString();

    final titleEn = (d['title_en'] ?? d['title'] ?? 'Notification').toString();
    final bodyEn = (d['body_en'] ?? d['body'] ?? '').toString();
    final titleAr = (d['title_ar'] ?? titleEn).toString();
    final bodyAr = (d['body_ar'] ?? bodyEn).toString();

    if (titleEn.isEmpty && bodyEn.isEmpty) return;

    // 1) Save to SQLite
    final inserted = await _saveToLocalDb(
      id: id,
      titleAr: titleAr,
      bodyAr: bodyAr,
      titleEn: titleEn,
      bodyEn: bodyEn,
      img: d['image']?.toString(),
      url: d['url']?.toString(),
      route: d['route']?.toString(),
      payload: d,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Don't show duplicate notification (same ID)
    if (!inserted) return;

    // 2) Show local notification via Awesome
    await AwesomeNotificationService.showLocalizedNotification(
      titleAr: titleAr,
      bodyAr: bodyAr,
      titleEn: titleEn,
      bodyEn: bodyEn,
      imageUrl: d['image']?.toString(),
      payload: d.map((k, v) => MapEntry(k, v.toString())),
    );
  }

  Future<bool> _saveToLocalDb({
    required String id,
    required String titleAr,
    required String bodyAr,
    required String titleEn,
    required String bodyEn,
    String? img,
    String? url,
    String? route,
    Map<String, dynamic>? payload,
    required int createdAt,
  }) async {
    try {
      final obj = <String, Object?>{
        'id': id,
        'title_ar': titleAr,
        'body_ar': bodyAr,
        'title_en': titleEn,
        'body_en': bodyEn,
        'img': img,
        'url': url,
        'route': route,
        'payload': payload == null ? null : jsonEncode(payload),
        'is_read': 0,
        'created_at': createdAt,
      }..removeWhere((k, v) => v == null);

      final inserted = await DbHelper().insertOrIgnore(
        table: _tableNotifications,
        obj: obj,
      );

      if (inserted == 1) {
        NotificationsBus.notifyChanged();
        return true;
      }
    } catch (e, s) {
      log('save notification failed: $e', stackTrace: s);
    }

    return false;
  }

  void _handleOpenSafely(RemoteMessage message) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _handleOpen(message);
    });
  }

  Future<void> _handleOpen(RemoteMessage message) async {
    final d = message.data;

    final id = d['id']?.toString();
    if (id != null && id.isNotEmpty) {
      try {
        await DbHelper().update(
          table: _tableNotifications,
          obj: {'is_read': 1},
          condition: 'id = ?',
          conditionParams: [id],
        );
        NotificationsBus.notifyChanged();
      } catch (_) {}
    }

    final route = d['route']?.toString();
    if (route != null && route.isNotEmpty) {
      // Navigate via GoRouter if needed
    } else {
      log('FCM open without route: data=$d');
    }
  }
}
