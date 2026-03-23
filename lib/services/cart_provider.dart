// lib/services/cart_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  final Set<String> _wishlist = {};
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  List<CartItem> get items => List.unmodifiable(_items);
  Set<String> get wishlist => Set.unmodifiable(_wishlist);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.total);

  bool isInCart(String bookId) => _items.any((item) => item.book.id == bookId);
  bool isWishlisted(String bookId) => _wishlist.contains(bookId);

  void addToCart(Book book) {
    final index = _items.indexWhere((item) => item.book.id == book.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(book: book));
    }
    notifyListeners();
  }

  void removeFromCart(String bookId) {
    _items.removeWhere((item) => item.book.id == bookId);
    notifyListeners();
  }

  void updateQuantity(String bookId, int quantity) {
    final index = _items.indexWhere((item) => item.book.id == bookId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> loadWishlist() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final doc = await _db.collection('users').doc(uid).get();
      final wishlistData = List<String>.from(doc.data()?['wishlist'] ?? []);
      _wishlist.clear();
      _wishlist.addAll(wishlistData);
      notifyListeners();
    } catch (e) {
      // silently ignore on web
    }
  }

  Future<void> toggleWishlist(String bookId) async {
    if (_wishlist.contains(bookId)) {
      _wishlist.remove(bookId);
    } else {
      _wishlist.add(bookId);
    }
    notifyListeners();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await _db.collection('users').doc(uid).set(
        {'wishlist': _wishlist.toList()},
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error saving wishlist: $e');
    }
  }
}
