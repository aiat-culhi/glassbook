// lib/screens/book_detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/book.dart';
import '../services/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';

class BookDetailScreen extends StatefulWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(widget.book.id);
    final isWishlisted = cart.isWishlisted(widget.book.id);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Cover Hero ─────────────────────────────────────────
              SizedBox(
                height: 320,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background blurred cover
                    widget.book.coverUrl.isNotEmpty
                        ? Image.network(
                            widget.book.coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildPlaceholderCover(),
                          )
                        : _buildPlaceholderCover(),
                    // Dark gradient overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.3),
                            AppColors.bgDark.withOpacity(0.98),
                          ],
                          stops: const [0.2, 1.0],
                        ),
                      ),
                    ),
                    // Back button top left
                    Positioned(
                      top: 48,
                      left: 16,
                      child: NeuIconButton(
                        icon: Icons.arrow_back_ios_rounded,
                        onTap: () => Navigator.pop(context),
                        size: 40,
                      ),
                    ),
                    // Wishlist top right
                    Positioned(
                      top: 48,
                      right: 16,
                      child: NeuIconButton(
                        icon: isWishlisted
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        iconColor: isWishlisted ? AppColors.accentRose : null,
                        isActive: isWishlisted,
                        onTap: () => cart.toggleWishlist(widget.book.id),
                        size: 40,
                      ),
                    ),
                    // Floating book cover card centered
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(6),
                          borderRadius: 14,
                          width: 110,
                          height: 155,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: widget.book.coverUrl.isNotEmpty
                                ? Image.network(
                                    widget.book.coverUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildSmallPlaceholder(),
                                  )
                                : _buildSmallPlaceholder(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── Book Info ──────────────────────────────────────────
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.book.title,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 6),
                        // Author
                        Text(
                          'by ${widget.book.author}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.accentCyan),
                        ),
                        const SizedBox(height: 16),
                        // Rating
                        Row(
                          children: [
                            NeuRatingBar(rating: widget.book.rating),
                            const SizedBox(width: 10),
                            Text(
                              '${widget.book.rating} (${widget.book.reviewCount} reviews)',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _StatChip(
                              icon: Icons.auto_stories_rounded,
                              label: '${widget.book.pageCount} pages',
                            ),
                            _StatChip(
                              icon: Icons.category_rounded,
                              label: widget.book.category,
                            ),
                            _StatChip(
                              icon: Icons.inventory_2_rounded,
                              label: '${widget.book.stockCount} in stock',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Tags
                        if (widget.book.tags.isNotEmpty) ...[
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: widget.book.tags
                                .map((t) => GlassBadge(
                                      label: '#$t',
                                      color: AppColors.accentViolet,
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 20),
                        ],
                        // Description
                        NeuCard(
                          style: NeuStyle.concave,
                          borderRadius: 18,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'About this book',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                widget.book.description,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ISBN / Published
                        GlassCard(
                          borderRadius: 18,
                          child: Row(
                            children: [
                              Expanded(
                                child: _InfoRow(
                                  label: 'ISBN',
                                  value: widget.book.isbn,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 40,
                                color: AppColors.glassBorder,
                              ),
                              Expanded(
                                child: _InfoRow(
                                  label: 'Published',
                                  value: _formatDate(widget.book.publishedDate),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ─── Price + Add to Cart ───────────────────────
                        NeuCard(
                          style: NeuStyle.convex,
                          borderRadius: 20,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Price',
                                    style: TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '₱${widget.book.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.accentCyan,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 24,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GlassButton(
                                  label: inCart ? 'In Cart ✓' : 'Add to Cart',
                                  icon: inCart
                                      ? Icons.check_circle_rounded
                                      : Icons.shopping_cart_rounded,
                                  onPressed: inCart
                                      ? null
                                      : () => cart.addToCart(widget.book),
                                  gradientColors: inCart
                                      ? [
                                          Colors.green.shade700,
                                          Colors.green.shade500,
                                        ]
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderCover() => Container(
        color: AppColors.bgMid,
        child: const Center(
          child: Icon(Icons.menu_book_rounded,
              size: 80, color: AppColors.textMuted),
        ),
      );

  Widget _buildSmallPlaceholder() => Container(
        color: AppColors.neuBase,
        child: const Center(
          child: Icon(Icons.menu_book_rounded,
              size: 40, color: AppColors.textMuted),
        ),
      );

  String _formatDate(DateTime d) => '${d.year} ${_months[d.month - 1]}';

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      style: NeuStyle.flat,
      borderRadius: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.accentViolet),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
