// lib/screens/search_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import '../services/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final BookService _service = BookService();
  List<Book> _results = [];
  List<Book> _allBooks = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadAllBooks();
  }

  Future<void> _loadAllBooks() async {
    setState(() => _loading = true);
    final all = await FirebaseFirestore.instance.collection('books').get();
    setState(() {
      _allBooks = all.docs.map((d) => Book.fromFirestore(d)).toList();
      _results = _allBooks;
      _loading = false;
    });
  }

  Future<void> _search(String q) async {
    if (q.trim().isEmpty) {
      setState(() => _results = _allBooks);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      _results = _allBooks
          .where((book) =>
              book.title.toLowerCase().contains(lower) ||
              book.author.toLowerCase().contains(lower) ||
              book.category.toLowerCase().contains(lower))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Search bar
                Row(
                  children: [
                    NeuIconButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onTap: () => Navigator.pop(context),
                      size: 40,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search books, authors...',
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 15,
                              ),
                              prefixIcon: const Icon(
                                Icons.search_rounded,
                                color: AppColors.textMuted,
                              ),
                              suffixIcon: _controller.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.close_rounded,
                                          color: AppColors.textMuted),
                                      onPressed: () {
                                        _controller.clear();
                                        setState(() => _results = _allBooks);
                                      },
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.glassFill,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: AppColors.glassBorder, width: 1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: AppColors.glassBorder, width: 1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: AppColors.accentViolet, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 14, horizontal: 16),
                            ),
                            onChanged: _search,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_loading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accentViolet,
                        strokeWidth: 2,
                      ),
                    ),
                  )
                else if (_results.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.search_off_rounded,
                              size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            'No results found',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final book = _results[i];
                        return GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => BookDetailScreen(book: book)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 50,
                                  height: 70,
                                  color: AppColors.neuBase,
                                  child: book.coverUrl.isNotEmpty
                                      ? Image.network(
                                          book.coverUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                  Icons.menu_book_rounded,
                                                  color: AppColors.textMuted),
                                        )
                                      : const Icon(Icons.menu_book_rounded,
                                          color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(book.title,
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
                                icon: Icons.add_shopping_cart_rounded,
                                onTap: () => cart.addToCart(book),
                                size: 36,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
