// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

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
                    Text(
                      'My Cart',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    const Spacer(),
                    if (cart.items.isNotEmpty)
                      TextButton(
                        onPressed: cart.clearCart,
                        child: const Text(
                          'Clear All',
                          style: TextStyle(
                            color: AppColors.accentRose,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              if (cart.items.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        NeuCard(
                          style: NeuStyle.convex,
                          padding: const EdgeInsets.all(24),
                          borderRadius: 24,
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 56,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Your cart is empty',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add some books to get started',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final item = cart.items[i];
                      return GlassCard(
                        borderRadius: 18,
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Cover thumb
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: 58,
                                height: 80,
                                color: AppColors.neuBase,
                                child: item.book.coverUrl.isNotEmpty
                                    ? Image.network(
                                        item.book.coverUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.menu_book_rounded,
                                                color: AppColors.textMuted),
                                      )
                                    : const Icon(Icons.menu_book_rounded,
                                        color: AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.book.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 14),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.book.author,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Text(
                                        '₱${item.total.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          color: AppColors.accentCyan,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Qty controls
                                      _QtyButton(
                                        icon: Icons.remove_rounded,
                                        onTap: () => cart.updateQuantity(
                                            item.book.id, item.quantity - 1),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        child: Text(
                                          '${item.quantity}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleLarge,
                                        ),
                                      ),
                                      _QtyButton(
                                        icon: Icons.add_rounded,
                                        onTap: () => cart.updateQuantity(
                                            item.book.id, item.quantity + 1),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Summary + Checkout
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: NeuCard(
                    style: NeuStyle.convex,
                    borderRadius: 24,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${cart.itemCount} item${cart.itemCount != 1 ? 's' : ''}',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            Text(
                              '₱${cart.totalAmount.toStringAsFixed(2)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(color: AppColors.accentCyan),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        GlassButton(
                          label: 'Proceed to Checkout',
                          icon: Icons.lock_outline_rounded,
                          width: double.infinity,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CheckoutScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: AppColors.neuBase,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: AppColors.neuShadowDark,
              offset: Offset(2, 2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: AppColors.neuShadowLight,
              offset: Offset(-2, -2),
              blurRadius: 6,
            ),
          ],
        ),
        child: Icon(icon, size: 16, color: AppColors.textSecondary),
      ),
    );
  }
}
