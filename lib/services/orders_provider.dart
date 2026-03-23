// lib/services/orders_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class AppOrder {
  final String id;
  final List<CartItem> items;
  final double totalAmount;
  final String address;
  final String paymentMethod;
  final DateTime createdAt;
  String status;

  AppOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.createdAt,
    this.status = 'pending',
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  bool get canCancel => status == 'pending' || status == 'processing';
}

class OrdersProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<AppOrder> _orders = [];
  bool isLoading = false;

  List<AppOrder> get orders => List.unmodifiable(_orders.reversed.toList());

  List<AppOrder> get activeOrders =>
      _orders.where((o) => o.status != 'cancelled').toList().reversed.toList();

  List<AppOrder> get cancelledOrders =>
      _orders.where((o) => o.status == 'cancelled').toList().reversed.toList();

  // ─── Load orders from Firestore ───────────────────────────────────────────
  Future<void> loadOrders() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    isLoading = true;
    notifyListeners();

    try {
      final snap =
          await _db.collection('orders').where('userId', isEqualTo: uid).get();

      _orders = snap.docs.map((doc) {
        final data = doc.data();

        // Rebuild CartItems from saved data
        final rawItems = List<Map<String, dynamic>>.from(data['items'] ?? []);
        final items = rawItems.map((i) {
          final fakeBook = _bookFromMap(i);
          return CartItem(book: fakeBook, quantity: i['quantity'] ?? 1);
        }).toList();

        return AppOrder(
          id: data['orderId'] ?? doc.id,
          items: items,
          totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
          address: data['address'] ?? '',
          paymentMethod: data['paymentMethod'] ?? 'cod',
          createdAt:
              (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          status: data['status'] ?? 'pending',
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading orders: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // ─── Place order and save to Firestore ────────────────────────────────────
  Future<AppOrder> addOrder({
    required List<CartItem> items,
    required double totalAmount,
    required String address,
    required String paymentMethod,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final orderId =
        'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

    final order = AppOrder(
      id: orderId,
      items: List.from(items),
      totalAmount: totalAmount,
      address: address,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
    );

    // Save to Firestore
    await _db.collection('orders').add({
      'orderId': orderId,
      'userId': uid,
      'items': items
          .map((i) => {
                'bookId': i.book.id,
                'title': i.book.title,
                'author': i.book.author,
                'coverUrl': i.book.coverUrl,
                'price': i.book.price,
                'quantity': i.quantity,
              })
          .toList(),
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    _orders.add(order);
    notifyListeners();
    return order;
  }

  // ─── Cancel order in Firestore ────────────────────────────────────────────
  Future<void> cancelOrder(String orderId) async {
    // Update locally
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index >= 0) {
      _orders[index].status = 'cancelled';
      notifyListeners();
    }

    // Update in Firestore
    try {
      final snap = await _db
          .collection('orders')
          .where('orderId', isEqualTo: orderId)
          .get();
      for (final doc in snap.docs) {
        await doc.reference.update({'status': 'cancelled'});
      }
    } catch (e) {
      debugPrint('Error cancelling order: $e');
    }
  }

  String getOrderSummary(AppOrder order) {
    if (order.items.isEmpty) return 'your order';
    if (order.items.length == 1) return '"${order.items[0].book.title}"';
    return '"${order.items[0].book.title}" and ${order.items.length - 1} more';
  }

  // Helper to reconstruct a minimal Book from saved order data
  Book _bookFromMap(Map<String, dynamic> map) {
    return Book(
      id: map['bookId'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? '',
      description: '',
      coverUrl: map['coverUrl'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      rating: 0,
      reviewCount: 0,
      category: '',
      tags: [],
      isBestseller: false,
      isNew: false,
      pageCount: 0,
      isbn: '',
      publishedDate: DateTime.now(),
      stockCount: 0,
    );
  }
}
