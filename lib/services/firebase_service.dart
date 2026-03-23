// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class BookService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Books ───────────────────────────────────────────────────────────────

  Stream<List<Book>> getBooksStream({String? category}) {
    Query<Map<String, dynamic>> query = _db.collection('books');
    if (category != null && category != 'All') {
      query = query.where('category', isEqualTo: category);
    }
    return query.snapshots().map(
          (snap) => snap.docs.map((d) => Book.fromFirestore(d)).toList(),
        );
  }

  Stream<List<Book>> getBestsellers() {
    return _db
        .collection('books')
        .where('isBestseller', isEqualTo: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromFirestore(d)).toList());
  }

  Stream<List<Book>> getNewArrivals() {
    return _db
        .collection('books')
        .where('isNew', isEqualTo: true)
        .orderBy('publishedDate', descending: true)
        .limit(10)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromFirestore(d)).toList());
  }

  Future<List<Book>> searchBooks(String query) async {
    final lower = query.toLowerCase();
    final snap = await _db.collection('books').get();
    final all = snap.docs.map((d) => Book.fromFirestore(d)).toList();
    return all
        .where((book) =>
            book.title.toLowerCase().contains(lower) ||
            book.author.toLowerCase().contains(lower) ||
            book.category.toLowerCase().contains(lower))
        .toList();
  }

  Future<Book?> getBookById(String id) async {
    final doc = await _db.collection('books').doc(id).get();
    if (!doc.exists) return null;
    return Book.fromFirestore(doc);
  }

  // ─── Orders ──────────────────────────────────────────────────────────────

  Future<void> placeOrder({
    required String userId,
    required List<CartItem> items,
    required double totalAmount,
    required String address,
  }) async {
    final batch = _db.batch();

    final orderRef = _db.collection('orders').doc();
    batch.set(orderRef, {
      'userId': userId,
      'items': items
          .map((i) => {
                'bookId': i.book.id,
                'title': i.book.title,
                'price': i.book.price,
                'quantity': i.quantity,
              })
          .toList(),
      'totalAmount': totalAmount,
      'status': 'pending',
      'address': address,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Decrement stock
    for (final item in items) {
      final bookRef = _db.collection('books').doc(item.book.id);
      batch.update(bookRef, {
        'stockCount': FieldValue.increment(-item.quantity),
      });
    }

    await batch.commit();
  }

  Stream<List<BookOrder>> getUserOrders(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => BookOrder.fromFirestore(d)).toList());
  }

  // ─── Wishlist (Firestore-persisted) ──────────────────────────────────────

  Future<void> toggleWishlist(String userId, String bookId) async {
    final ref = _db.collection('users').doc(userId);
    final doc = await ref.get();
    final wishlist = List<String>.from(doc.data()?['wishlist'] ?? []);

    if (wishlist.contains(bookId)) {
      wishlist.remove(bookId);
    } else {
      wishlist.add(bookId);
    }

    await ref.set({'wishlist': wishlist}, SetOptions(merge: true));
  }

  // ─── Seed data helper ────────────────────────────────────────────────────
  Future<void> seedSampleBooks() async {
    final books = [
      {
        'title': 'The Midnight Library',
        'author': 'Matt Haig',
        'description':
            'Between life and death there is a library, and within that library, the shelves go on forever.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780525559474-L.jpg',
        'price': 14.99,
        'rating': 4.5,
        'reviewCount': 3200,
        'category': 'Fiction',
        'tags': ['bestseller', 'philosophy'],
        'isBestseller': true,
        'isNew': false,
        'pageCount': 304,
        'isbn': '9780525559474',
        'publishedDate': Timestamp.fromDate(DateTime(2020, 9, 29)),
        'stockCount': 42,
      },
      {
        'title': 'Atomic Habits',
        'author': 'James Clear',
        'description':
            'An easy and proven way to build good habits and break bad ones.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg',
        'price': 16.99,
        'rating': 4.8,
        'reviewCount': 12000,
        'category': 'Self-Help',
        'tags': ['habits', 'productivity'],
        'isBestseller': true,
        'isNew': false,
        'pageCount': 320,
        'isbn': '9780735211292',
        'publishedDate': Timestamp.fromDate(DateTime(2018, 10, 16)),
        'stockCount': 87,
      },
      {
        'title': 'Project Hail Mary',
        'author': 'Andy Weir',
        'description':
            'A lone astronaut must save the earth from disaster in this propulsive adventure.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780593135204-L.jpg',
        'price': 18.99,
        'rating': 4.9,
        'reviewCount': 8500,
        'category': 'Sci-Fi',
        'tags': ['space', 'adventure'],
        'isBestseller': false,
        'isNew': true,
        'pageCount': 480,
        'isbn': '9780593135204',
        'publishedDate': Timestamp.fromDate(DateTime(2021, 5, 4)),
        'stockCount': 23,
      },
      {
        'title': 'The Psychology of Money',
        'author': 'Morgan Housel',
        'description': 'Timeless lessons on wealth, greed, and happiness.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780857197689-L.jpg',
        'price': 15.99,
        'rating': 4.7,
        'reviewCount': 9200,
        'category': 'Self-Help',
        'tags': ['finance', 'psychology'],
        'isBestseller': true,
        'isNew': false,
        'pageCount': 256,
        'isbn': '9780857197689',
        'publishedDate': Timestamp.fromDate(DateTime(2020, 9, 8)),
        'stockCount': 60,
      },
      {
        'title': 'Dune',
        'author': 'Frank Herbert',
        'description':
            'Set in the distant future amidst a feudal interstellar society.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780441013593-L.jpg',
        'price': 12.99,
        'rating': 4.8,
        'reviewCount': 25000,
        'category': 'Sci-Fi',
        'tags': ['classic', 'space', 'epic'],
        'isBestseller': true,
        'isNew': false,
        'pageCount': 688,
        'isbn': '9780441013593',
        'publishedDate': Timestamp.fromDate(DateTime(1965, 8, 1)),
        'stockCount': 55,
      },
      {
        'title': 'It Ends with Us',
        'author': 'Colleen Hoover',
        'description':
            'A brave and heartbreaking novel that digs its claws into you.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9781501110368-L.jpg',
        'price': 13.99,
        'rating': 4.6,
        'reviewCount': 18000,
        'category': 'Fiction',
        'tags': ['romance', 'emotional'],
        'isBestseller': true,
        'isNew': false,
        'pageCount': 384,
        'isbn': '9781501110368',
        'publishedDate': Timestamp.fromDate(DateTime(2016, 8, 2)),
        'stockCount': 70,
      },
      {
        'title': 'Sapiens',
        'author': 'Yuval Noah Harari',
        'description':
            'A brief history of humankind from the Stone Age to the present.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780062316097-L.jpg',
        'price': 17.99,
        'rating': 4.6,
        'reviewCount': 22000,
        'category': 'History',
        'tags': ['history', 'science', 'philosophy'],
        'isBestseller': false,
        'isNew': false,
        'pageCount': 443,
        'isbn': '9780062316097',
        'publishedDate': Timestamp.fromDate(DateTime(2015, 2, 10)),
        'stockCount': 38,
      },
      {
        'title': 'The 48 Laws of Power',
        'author': 'Robert Greene',
        'description':
            'Amoral, cunning, ruthless, and instructive, this piercing work distills 3,000 years of history.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780140280197-L.jpg',
        'price': 19.99,
        'rating': 4.5,
        'reviewCount': 15000,
        'category': 'Self-Help',
        'tags': ['power', 'strategy', 'psychology'],
        'isBestseller': false,
        'isNew': false,
        'pageCount': 452,
        'isbn': '9780140280197',
        'publishedDate': Timestamp.fromDate(DateTime(2000, 9, 1)),
        'stockCount': 45,
      },
      {
        'title': 'Gone Girl',
        'author': 'Gillian Flynn',
        'description':
            'A dark and compulsively readable thriller about a marriage gone wrong.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780307588364-L.jpg',
        'price': 13.49,
        'rating': 4.3,
        'reviewCount': 11000,
        'category': 'Mystery',
        'tags': ['thriller', 'mystery', 'dark'],
        'isBestseller': false,
        'isNew': false,
        'pageCount': 422,
        'isbn': '9780307588364',
        'publishedDate': Timestamp.fromDate(DateTime(2012, 6, 5)),
        'stockCount': 33,
      },
      {
        'title': 'Clean Code',
        'author': 'Robert C. Martin',
        'description':
            'A handbook of agile software craftsmanship every developer should read.',
        'coverUrl': 'https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg',
        'price': 35.99,
        'rating': 4.7,
        'reviewCount': 8000,
        'category': 'Technology',
        'tags': ['programming', 'software', 'coding'],
        'isBestseller': false,
        'isNew': false,
        'pageCount': 431,
        'isbn': '9780132350884',
        'publishedDate': Timestamp.fromDate(DateTime(2008, 8, 1)),
        'stockCount': 28,
      },
    ];

    for (final book in books) {
      await _db.collection('books').add(book);
    }
  }
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpWithEmail(
      String email, String password, String name) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await cred.user?.updateDisplayName(name);
    await _db.collection('users').doc(cred.user!.uid).set({
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'wishlist': [],
    });
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());
}
