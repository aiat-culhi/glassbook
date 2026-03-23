// lib/models/book.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final double price;
  final double rating;
  final int reviewCount;
  final String category;
  final List<String> tags;
  final bool isBestseller;
  final bool isNew;
  final int pageCount;
  final String isbn;
  final DateTime publishedDate;
  final int stockCount;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.tags,
    required this.isBestseller,
    required this.isNew,
    required this.pageCount,
    required this.isbn,
    required this.publishedDate,
    required this.stockCount,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      description: data['description'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      category: data['category'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      isBestseller: data['isBestseller'] ?? false,
      isNew: data['isNew'] ?? false,
      pageCount: data['pageCount'] ?? 0,
      isbn: data['isbn'] ?? '',
      publishedDate:
          (data['publishedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      stockCount: data['stockCount'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'price': price,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'tags': tags,
      'isBestseller': isBestseller,
      'isNew': isNew,
      'pageCount': pageCount,
      'isbn': isbn,
      'publishedDate': Timestamp.fromDate(publishedDate),
      'stockCount': stockCount,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    double? price,
    double? rating,
    int? reviewCount,
    String? category,
    List<String>? tags,
    bool? isBestseller,
    bool? isNew,
    int? pageCount,
    String? isbn,
    DateTime? publishedDate,
    int? stockCount,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      price: price ?? this.price,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isBestseller: isBestseller ?? this.isBestseller,
      isNew: isNew ?? this.isNew,
      pageCount: pageCount ?? this.pageCount,
      isbn: isbn ?? this.isbn,
      publishedDate: publishedDate ?? this.publishedDate,
      stockCount: stockCount ?? this.stockCount,
    );
  }
}

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});

  double get total => book.price * quantity;
}

class BookOrder {
  final String id;
  final String userId;
  final List<CartItem> items;
  final double totalAmount;
  final DateTime createdAt;
  final String status; // pending, processing, shipped, delivered
  final String address;

  BookOrder({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
    required this.address,
  });

  factory BookOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookOrder(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: data['status'] ?? 'pending',
      address: data['address'] ?? '',
    );
  }
}
