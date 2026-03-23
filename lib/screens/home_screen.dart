// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import '../services/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';
import 'book_detail_screen.dart';
import 'cart_screen.dart';
import 'search_screen.dart';
import 'profile_screen.dart';
import 'admin_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final BookService _bookService = BookService();
  String _selectedCategory = 'All';
  late AnimationController _headerAnim;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final List<String> _categories = [
    'All',
    'Fiction',
    'Self-Help',
    'Sci-Fi',
    'Mystery',
    'Biography',
    'History',
    'Technology',
  ];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ─── App Bar ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GlassBook',
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(fontSize: 28),
                              ),
                              Text(
                                'Find your next great read',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const Spacer(),
                          NeuIconButton(
                            icon: Icons.search_rounded,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const SearchScreen())),
                            size: 40,
                          ),
                          const SizedBox(width: 8),
                          if (FirebaseAuth.instance.currentUser?.email ==
                              'test@test.com')
                            NeuIconButton(
                              icon: Icons.admin_panel_settings_outlined,
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const AdminScreen())),
                              size: 40,
                            ),
                          const SizedBox(width: 8),
                          NeuIconButton(
                            icon: Icons.person_outline_rounded,
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const ProfileScreen())),
                            size: 40,
                          ),
                          const SizedBox(width: 8),
                          Stack(
                            children: [
                              NeuIconButton(
                                icon: Icons.shopping_bag_outlined,
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const CartScreen())),
                                size: 40,
                              ),
                              if (cart.itemCount > 0)
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: const BoxDecoration(
                                      color: AppColors.accentRose,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${cart.itemCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ─── Hero Banner ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: _HeroBanner(
                      onBrowse: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SearchScreen()),
                          )),
                ),
              ),

              // ─── Categories ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 28, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Categories',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, i) {
                            final cat = _categories[i];
                            final selected = cat == _selectedCategory;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedCategory = cat),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: selected
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.accentViolet,
                                            AppColors.accentCyan,
                                          ],
                                        )
                                      : null,
                                  color: selected ? null : AppColors.neuBase,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: selected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accentViolet
                                                .withOpacity(0.4),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ]
                                      : [
                                          BoxShadow(
                                            color: AppColors.neuShadowDark
                                                .withOpacity(0.9),
                                            offset: const Offset(3, 3),
                                            blurRadius: 8,
                                          ),
                                          BoxShadow(
                                            color: AppColors.neuShadowLight
                                                .withOpacity(0.6),
                                            offset: const Offset(-3, -3),
                                            blurRadius: 8,
                                          ),
                                        ],
                                ),
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: selected
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Book Grid ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory == 'All'
                            ? 'All Books'
                            : _selectedCategory,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ),

              StreamBuilder<List<Book>>(
                stream: _bookService.getBooksStream(
                    category:
                        _selectedCategory == 'All' ? null : _selectedCategory),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, __) => _BookCardShimmer(),
                          childCount: 6,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.62,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                      ),
                    );
                  }

                  final books = snapshot.data ?? [];

                  if (books.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(Icons.menu_book_rounded,
                                  size: 48, color: AppColors.textMuted),
                              const SizedBox(height: 12),
                              Text(
                                'No books found',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _BookCard(
                          book: books[i],
                          index: i,
                        ),
                        childCount: books.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.62,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  final VoidCallback onBrowse;
  const _HeroBanner({required this.onBrowse});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      tintColor: AppColors.accentViolet.withOpacity(0.1),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GlassBadge(
                  label: 'NEW RELEASE',
                  color: AppColors.accentCyan,
                  icon: Icons.auto_awesome,
                ),
                const SizedBox(height: 12),
                Text(
                  'Discover\nWorlds in\nWords',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 30,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 16),
                GlassButton(
                  label: 'Browse Now',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onBrowse,
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Decorative book stack visualization
          SizedBox(
            width: 100,
            height: 150,
            child: Stack(
              children: [
                Positioned(
                  right: 10,
                  bottom: 0,
                  child: _MiniBookCover(
                    color: AppColors.accentRose,
                    angle: 0.15,
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 15,
                  child: _MiniBookCover(
                    color: AppColors.accentViolet,
                    angle: -0.05,
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 30,
                  child: _MiniBookCover(
                    color: AppColors.accentCyan,
                    angle: 0.08,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBookCover extends StatelessWidget {
  final Color color;
  final double angle;

  const _MiniBookCover({required this.color, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 58,
        height: 82,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, color: color, size: 28),
          ],
        ),
      ),
    );
  }
}

class _BookCard extends StatefulWidget {
  final Book book;
  final int index;

  const _BookCard({required this.book, required this.index});

  @override
  State<_BookCard> createState() => _BookCardState();
}

class _BookCardState extends State<_BookCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400 + widget.index * 60),
    )..forward();
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    final isWishlisted = cart.isWishlisted(widget.book.id);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: NeuCard(
          padding: EdgeInsets.zero,
          style: NeuStyle.convex,
          onTap: () => Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, anim, __) => BookDetailScreen(book: widget.book),
              transitionsBuilder: (_, anim, __, child) => FadeTransition(
                opacity: anim,
                child: child,
              ),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cover
                Expanded(
                  flex: 5,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      widget.book.coverUrl.isNotEmpty
                          ? Image.network(
                              widget.book.coverUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _PlaceholderCover(book: widget.book),
                            )
                          : _PlaceholderCover(book: widget.book),
                      // Gradient overlay
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xAA0D0E1A)],
                            stops: [0.5, 1.0],
                          ),
                        ),
                      ),
                      // Badges
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Column(
                          children: [
                            if (widget.book.isBestseller)
                              GlassBadge(
                                  label: 'BESTSELLER',
                                  color: AppColors.accentAmber),
                            if (widget.book.isNew)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: GlassBadge(
                                    label: 'NEW', color: AppColors.accentCyan),
                              ),
                          ],
                        ),
                      ),
                      // Wishlist
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => cart.toggleWishlist(widget.book.id),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Icon(
                              isWishlisted
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: isWishlisted
                                  ? AppColors.accentRose
                                  : Colors.white,
                              size: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Info
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontSize: 13,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.book.author,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(fontSize: 11),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Text(
                              '₱${widget.book.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.accentCyan,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => cart.addToCart(widget.book),
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accentViolet,
                                      AppColors.accentCyan,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accentViolet
                                          .withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _PlaceholderCover extends StatelessWidget {
  final Book book;
  const _PlaceholderCover({required this.book});

  Color _colorForCategory(String cat) {
    switch (cat) {
      case 'Fiction':
        return AppColors.accentViolet;
      case 'Sci-Fi':
        return AppColors.accentCyan;
      case 'Self-Help':
        return AppColors.accentAmber;
      case 'Mystery':
        return AppColors.accentRose;
      default:
        return AppColors.accentViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForCategory(book.category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.6),
            color.withOpacity(0.2),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.menu_book_rounded, color: color, size: 36),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                book.title,
                textAlign: TextAlign.center,
                maxLines: 3,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.neuBase,
      highlightColor: AppColors.neuShadowLight,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.neuBase,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
