// lib/services/notification_provider_new.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'type': type,
        'createdAt': Timestamp.fromDate(createdAt),
        'isRead': isRead,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        id: map['id'] ?? '',
        title: map['title'] ?? '',
        body: map['body'] ?? '',
        type: map['type'] ?? 'system',
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        isRead: map['isRead'] ?? false,
      );
}

class NotificationProvider extends ChangeNotifier {
  final List<AppNotification> _notifications = [];
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications.reversed.toList());

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  // ─── Load from Firestore ──────────────────────────────────────────────────
  Future<void> loadNotifications() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await _db.collection('users').doc(uid).get();
      final raw =
          List<Map<String, dynamic>>.from(doc.data()?['notifications'] ?? []);
      _notifications.clear();
      _notifications.addAll(raw.map((m) => AppNotification.fromMap(m)));
      notifyListeners();
    } catch (e) {
      // silently ignore on web
    }
  }

  // ─── Save to Firestore ────────────────────────────────────────────────────
  Future<void> _persist() async {
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final toSave = _notifications.length > 20
          ? _notifications.sublist(_notifications.length - 20)
          : _notifications;

      await _db.collection('users').doc(uid).set(
        {'notifications': toSave.map((n) => n.toMap()).toList()},
        SetOptions(merge: true),
      );
    } catch (e) {
      // silently ignore on web
    }
  }

  Future<void> addNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    _notifications.add(AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> markAllRead() async {
    for (final n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
    await _persist();
  }

  Future<void> markRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      _notifications[index].isRead = true;
      notifyListeners();
      await _persist();
    }
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }

  Future<void> notifyOrderPlaced(String orderSummary) async {
    await addNotification(
      title: '🎉 Order Placed Successfully!',
      body:
          'Your order for $orderSummary has been placed and is waiting to be shipped. Expected delivery in 3-5 business days.',
      type: 'order',
    );
  }

  Future<void> notifyOrderCancelled(String orderSummary) async {
    await addNotification(
      title: '❌ Order Cancelled',
      body:
          'Your order for $orderSummary has been cancelled. If you paid online, a refund will be processed within 3-5 business days.',
      type: 'order',
    );
  }
}
