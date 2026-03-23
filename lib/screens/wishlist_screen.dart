// lib/screens/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../services/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';
import 'book_detail_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  Future<List<Book>> _loadWishlistBooks(Set<String> ids) async {
    if (ids.isEmpty) return [];
    final books = <Book>[];
    for (final id in ids) {
      final doc =
          await FirebaseFirestore.instance.collection('books').doc(id).get();
      if (doc.exists) books.add(Book.fromFirestore(doc));
    }
    return books;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    NeuIconButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onTap: () => Navigator.pop(context),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Text('Wishlist',
                        style: Theme.of(context).textTheme.headlineLarge),
                    const Spacer(),
                    GlassBadge(
                      label: '${cart.wishlist.length} books',
                      color: AppColors.accentRose,
                      icon: Icons.favorite_rounded,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: cart.wishlist.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            NeuCard(
                              style: NeuStyle.convex,
                              padding: const EdgeInsets.all(24),
                              borderRadius: 24,
                              child: const Icon(Icons.favorite_border_rounded,
                                  size: 56, color: AppColors.textMuted),
                            ),
                            const SizedBox(height: 20),
                            Text('No wishlisted books yet',
                                style:
                                    Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text('Tap the ❤️ on any book to save it',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      )
                    : FutureBuilder<List<Book>>(
                        future: _loadWishlistBooks(cart.wishlist),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.accentViolet,
                                strokeWidth: 2,
                              ),
                            );
                          }
                          final books = snapshot.data ?? [];
                          return ListView.separated(
                            padding: const EdgeInsets.all(20),
                            itemCount: books.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final book = books[i];
                              return GlassCard(
                                borderRadius: 16,
                                padding: const EdgeInsets.all(12),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          BookDetailScreen(book: book)),
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        width: 58,
                                        height: 80,
                                        color: AppColors.neuBase,
                                        child: book.coverUrl.isNotEmpty
                                            ? Image.network(book.coverUrl,
                                                fit: BoxFit.cover)
                                            : const Icon(
                                                Icons.menu_book_rounded,
                                                color: AppColors.textMuted),
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(book.title,
                                              maxLines: 2,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge),
                                          Text(book.author,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium),
                                          const SizedBox(height: 8),
                                          Text(
                                            '₱${book.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: AppColors.accentCyan,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    NeuIconButton(
                                      icon: Icons.favorite_rounded,
                                      iconColor: AppColors.accentRose,
                                      isActive: true,
                                      onTap: () => cart.toggleWishlist(book.id),
                                      size: 36,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
