// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final BookService bookService = BookService();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                    Expanded(
                      child: Text(
                        'Admin — Books',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    GlassButton(
                      label: 'Add Book',
                      icon: Icons.add_rounded,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddEditBookScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Book list
              Expanded(
                child: StreamBuilder<List<Book>>(
                  stream: bookService.getBooksStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentViolet,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    final books = snapshot.data ?? [];

                    if (books.isEmpty) {
                      return Center(
                        child: Text(
                          'No books yet',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: books.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final book = books[i];
                        return GlassCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Cover
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 48,
                                  height: 68,
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
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      book.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 13),
                                    ),
                                    Text(
                                      book.author,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        GlassBadge(
                                          label: book.category,
                                          color: AppColors.accentViolet,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '₱${book.price.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.accentCyan,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // Actions
                              Column(
                                children: [
                                  NeuIconButton(
                                    icon: Icons.edit_rounded,
                                    iconColor: AppColors.accentCyan,
                                    size: 36,
                                    onTap: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddEditBookScreen(book: book),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  NeuIconButton(
                                    icon: Icons.delete_outline_rounded,
                                    iconColor: AppColors.accentRose,
                                    size: 36,
                                    onTap: () => _confirmDelete(context, book),
                                  ),
                                ],
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

  void _confirmDelete(BuildContext context, Book book) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Book',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${book.title}"?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('books')
                  .doc(book.id)
                  .delete();
            },
            child: const Text('Delete',
                style: TextStyle(color: AppColors.accentRose)),
          ),
        ],
      ),
    );
  }
}

// ─── Add / Edit Book Screen ───────────────────────────────────────────────────
class AddEditBookScreen extends StatefulWidget {
  final Book? book;
  const AddEditBookScreen({super.key, this.book});

  @override
  State<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends State<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  late TextEditingController _titleCtrl;
  late TextEditingController _authorCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _coverCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _pageCtrl;
  late TextEditingController _isbnCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _ratingCtrl;

  String _category = 'Fiction';
  bool _isBestseller = false;
  bool _isNew = false;

  final List<String> _categories = [
    'Fiction',
    'Self-Help',
    'Sci-Fi',
    'Mystery',
    'Biography',
    'History',
    'Technology',
  ];

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final b = widget.book;
    _titleCtrl = TextEditingController(text: b?.title ?? '');
    _authorCtrl = TextEditingController(text: b?.author ?? '');
    _descCtrl = TextEditingController(text: b?.description ?? '');
    _coverCtrl = TextEditingController(text: b?.coverUrl ?? '');
    _priceCtrl = TextEditingController(text: b?.price.toString() ?? '');
    _pageCtrl = TextEditingController(text: b?.pageCount.toString() ?? '');
    _isbnCtrl = TextEditingController(text: b?.isbn ?? '');
    _stockCtrl = TextEditingController(text: b?.stockCount.toString() ?? '');
    _ratingCtrl = TextEditingController(text: b?.rating.toString() ?? '4.0');
    _category = b?.category ?? 'Fiction';
    _isBestseller = b?.isBestseller ?? false;
    _isNew = b?.isNew ?? false;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _descCtrl.dispose();
    _coverCtrl.dispose();
    _priceCtrl.dispose();
    _pageCtrl.dispose();
    _isbnCtrl.dispose();
    _stockCtrl.dispose();
    _ratingCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      final data = {
        'title': _titleCtrl.text.trim(),
        'author': _authorCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'coverUrl': _coverCtrl.text.trim(),
        'price': double.tryParse(_priceCtrl.text) ?? 0.0,
        'rating': double.tryParse(_ratingCtrl.text) ?? 4.0,
        'reviewCount': 0,
        'category': _category,
        'tags': [],
        'isBestseller': _isBestseller,
        'isNew': _isNew,
        'pageCount': int.tryParse(_pageCtrl.text) ?? 0,
        'isbn': _isbnCtrl.text.trim(),
        'stockCount': int.tryParse(_stockCtrl.text) ?? 0,
        'publishedDate': Timestamp.now(),
      };

      if (_isEditing) {
        await FirebaseFirestore.instance
            .collection('books')
            .doc(widget.book!.id)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('books').add(data);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.accentRose,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(
                      _isEditing ? 'Edit Book' : 'Add New Book',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Cover preview
                        if (_coverCtrl.text.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _coverCtrl.text,
                                height: 140,
                                errorBuilder: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ),

                        NeuCard(
                          style: NeuStyle.concave,
                          borderRadius: 20,
                          child: Column(
                            children: [
                              _field(_titleCtrl, 'Title', Icons.title_rounded),
                              const SizedBox(height: 12),
                              _field(_authorCtrl, 'Author',
                                  Icons.person_outline_rounded),
                              const SizedBox(height: 12),
                              _field(
                                _descCtrl,
                                'Description',
                                Icons.description_outlined,
                                maxLines: 3,
                              ),
                              const SizedBox(height: 12),
                              _field(
                                _coverCtrl,
                                'Cover Image URL',
                                Icons.image_outlined,
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Tip: https://covers.openlibrary.org/b/isbn/ISBN-L.jpg',
                                  style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        NeuCard(
                          style: NeuStyle.concave,
                          borderRadius: 20,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      _priceCtrl,
                                      'Price (₱)',
                                      Icons.payments_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _field(
                                      _ratingCtrl,
                                      'Rating',
                                      Icons.star_outline_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _field(
                                      _pageCtrl,
                                      'Pages',
                                      Icons.menu_book_rounded,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _field(
                                      _stockCtrl,
                                      'Stock',
                                      Icons.inventory_2_outlined,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _field(_isbnCtrl, 'ISBN', Icons.qr_code_rounded),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        NeuCard(
                          style: NeuStyle.flat,
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Category',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _categories.map((cat) {
                                  final selected = cat == _category;
                                  return GestureDetector(
                                    onTap: () =>
                                        setState(() => _category = cat),
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        gradient: selected
                                            ? const LinearGradient(colors: [
                                                AppColors.accentViolet,
                                                AppColors.accentCyan,
                                              ])
                                            : null,
                                        color:
                                            selected ? null : AppColors.bgMid,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: selected
                                              ? Colors.transparent
                                              : AppColors.glassBorder,
                                        ),
                                      ),
                                      child: Text(
                                        cat,
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              // Toggles
                              _Toggle(
                                label: 'Mark as Bestseller',
                                icon: Icons.trending_up_rounded,
                                color: AppColors.accentAmber,
                                value: _isBestseller,
                                onChanged: (v) =>
                                    setState(() => _isBestseller = v),
                              ),
                              const SizedBox(height: 10),
                              _Toggle(
                                label: 'Mark as New Arrival',
                                icon: Icons.fiber_new_rounded,
                                color: AppColors.accentCyan,
                                value: _isNew,
                                onChanged: (v) => setState(() => _isNew = v),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        GlassButton(
                          label: _isEditing ? 'Save Changes' : 'Add Book',
                          icon: _isEditing
                              ? Icons.save_rounded
                              : Icons.add_rounded,
                          isLoading: _loading,
                          width: double.infinity,
                          onPressed: _save,
                        ),
                        const SizedBox(height: 20),
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

  Widget _field(
    TextEditingController ctrl,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: maxLines == 1
            ? Icon(icon, color: AppColors.textMuted, size: 18)
            : null,
        filled: true,
        fillColor: AppColors.bgMid,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accentViolet, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          inactiveThumbColor: AppColors.textMuted,
          inactiveTrackColor: AppColors.neuShadowDark,
        ),
      ],
    );
  }
}
