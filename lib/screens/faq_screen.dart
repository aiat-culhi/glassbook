// lib/screens/faq_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/neu_card.dart';
import '../widgets/glass_card.dart';
import '../widgets/animated_background.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  int? _expandedIndex;

  final List<Map<String, String>> _faqs = [
    {
      'category': 'Orders',
      'question': 'How do I place an order?',
      'answer':
          'Browse our collection, tap on a book you like, and press "Add to Cart". Once you\'re done shopping, go to your cart and tap "Proceed to Checkout". Fill in your delivery details and choose your payment method to complete your order.',
    },
    {
      'category': 'Orders',
      'question': 'Can I cancel my order?',
      'answer':
          'Yes! You can cancel your order as long as it hasn\'t been shipped yet. Go to Profile → My Orders, find the order you want to cancel, and tap the "Cancel Order" button. Orders with "Pending" or "Processing" status can be cancelled.',
    },
    {
      'category': 'Orders',
      'question': 'How long does delivery take?',
      'answer':
          'Standard delivery takes 3-5 business days within Metro Manila, and 5-10 business days for provincial areas. You\'ll receive a notification once your order has been shipped with a tracking number.',
    },
    {
      'category': 'Orders',
      'question': 'What happens after I place an order?',
      'answer':
          'After placing your order, it will appear in "My Orders" with a "Pending" status. Our team will process it within 24 hours and update the status to "Processing". You\'ll receive notifications at each stage of delivery.',
    },
    {
      'category': 'Payment',
      'question': 'What payment methods do you accept?',
      'answer':
          'We currently accept Cash on Delivery (COD), GCash, and Credit/Debit Cards (Visa and Mastercard). We are working on adding more payment options soon.',
    },
    {
      'category': 'Payment',
      'question': 'Is Cash on Delivery available everywhere?',
      'answer':
          'Cash on Delivery is available in most areas across the Philippines. However, some remote locations may not be covered. If COD is unavailable in your area, we\'ll notify you during checkout.',
    },
    {
      'category': 'Payment',
      'question': 'Is it safe to pay with my card?',
      'answer':
          'Absolutely! All card transactions are encrypted and processed securely. We do not store your card details on our servers. Your payment information is protected by industry-standard SSL encryption.',
    },
    {
      'category': 'Account',
      'question': 'How do I save my delivery address?',
      'answer':
          'Go to Profile → Delivery Address. Fill in your name, phone number, and complete address then tap "Save Address". Your address will be saved for future orders, making checkout faster.',
    },
    {
      'category': 'Account',
      'question': 'How does the Wishlist work?',
      'answer':
          'Tap the ❤️ heart icon on any book to add it to your wishlist. You can view all your wishlisted books by going to Profile → Wishlist. From there you can tap any book to view its details or remove it from your wishlist.',
    },
    {
      'category': 'Account',
      'question': 'Can I change my email or password?',
      'answer':
          'Currently, email changes require contacting our support team. For password changes, you can use the "Forgot Password" option on the login screen to reset your password via email.',
    },
    {
      'category': 'Books',
      'question': 'Are all books available for immediate purchase?',
      'answer':
          'Most books in our catalog are in stock and ready to ship. The stock count is displayed on each book\'s detail page. If a book is out of stock, you can add it to your wishlist and we\'ll notify you when it becomes available.',
    },
    {
      'category': 'Books',
      'question': 'Do you offer digital/eBook versions?',
      'answer':
          'Currently, GlassBook focuses on physical books only. We are exploring adding eBook options in the future. Stay tuned for updates!',
    },
    {
      'category': 'Books',
      'question': 'Can I return a book?',
      'answer':
          'Yes! We accept returns within 7 days of delivery if the book is in its original condition. Damaged or defective books can be returned within 14 days. Contact our support team to initiate a return.',
    },
  ];

  final List<String> _categories = ['Orders', 'Payment', 'Account', 'Books'];
  String _selectedCategory = 'Orders';

  List<Map<String, String>> get _filteredFaqs =>
      _faqs.where((f) => f['category'] == _selectedCategory).toList();

  @override
  Widget build(BuildContext context) {
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Help & Support',
                              style: Theme.of(context).textTheme.headlineLarge),
                          Text('Frequently Asked Questions',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category tabs
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final cat = _categories[i];
                    final selected = cat == _selectedCategory;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = cat;
                        _expandedIndex = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: selected
                              ? const LinearGradient(colors: [
                                  AppColors.accentViolet,
                                  AppColors.accentCyan,
                                ])
                              : null,
                          color: selected ? null : AppColors.neuBase,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color:
                                        AppColors.accentViolet.withOpacity(0.4),
                                    blurRadius: 10,
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
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // FAQ list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                  itemCount: _filteredFaqs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final faq = _filteredFaqs[i];
                    final isExpanded = _expandedIndex == i;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _expandedIndex = isExpanded ? null : i;
                      }),
                      child: NeuCard(
                        style: isExpanded ? NeuStyle.concave : NeuStyle.convex,
                        borderRadius: 16,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    faq['question']!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 14),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isExpanded
                                        ? AppColors.accentViolet
                                        : AppColors.textMuted,
                                    size: 22,
                                  ),
                                ),
                              ],
                            ),
                            AnimatedCrossFade(
                              firstChild: const SizedBox.shrink(),
                              secondChild: Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                        color: AppColors.glassBorder,
                                        height: 1),
                                    const SizedBox(height: 12),
                                    Text(
                                      faq['answer']!,
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              duration: const Duration(milliseconds: 250),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Contact support
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: GlassCard(
                  borderRadius: 16,
                  tintColor: AppColors.accentViolet.withOpacity(0.08),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accentViolet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.headset_mic_outlined,
                            color: AppColors.accentViolet, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Still need help?',
                                style: Theme.of(context).textTheme.titleLarge),
                            Text('Contact us at support@glassbook.ph',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted, size: 14),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
