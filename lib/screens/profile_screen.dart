// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';
import '../services/firebase_service.dart';
import '../services/cart_provider.dart';
import 'wishlist_screen.dart';
import 'address_screen.dart';
import 'orders_screen.dart';
import 'notification_screen.dart';
import 'faq_screen.dart';
import '../services/orders_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // ─── Header ───────────────────────────────────────────
                Row(
                  children: [
                    NeuIconButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onTap: () => Navigator.pop(context),
                      size: 40,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'My Profile',
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // ─── Avatar ───────────────────────────────────────────
                NeuCard(
                  style: NeuStyle.convex,
                  padding: const EdgeInsets.all(24),
                  borderRadius: 24,
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.accentViolet,
                              AppColors.accentCyan,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentViolet.withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            (user?.displayName?.isNotEmpty == true
                                    ? user!.displayName![0]
                                    : user?.email?[0] ?? 'U')
                                .toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.displayName ?? 'Book Lover',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      GlassBadge(
                        label: 'Spark Plan',
                        color: AppColors.accentAmber,
                        icon: Icons.auto_awesome,
                      ),
                      const SizedBox(height: 12),
                      GlassButton(
                        label: 'Edit Profile',
                        icon: Icons.edit_rounded,
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const EditProfileScreen()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Stats ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const OrdersScreen()),
                        ),
                        child: _StatCard(
                          icon: Icons.shopping_bag_rounded,
                          label: 'Orders',
                          value:
                              '${context.watch<OrdersProvider>().activeOrders.length}',
                          color: AppColors.accentViolet,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WishlistScreen()),
                        ),
                        child: _StatCard(
                          icon: Icons.favorite_rounded,
                          label: 'Wishlist',
                          value: '${cart.wishlist.length}',
                          color: AppColors.accentRose,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.menu_book_rounded,
                        label: 'Reading',
                        value: '0',
                        color: AppColors.accentCyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ─── Menu Items ───────────────────────────────────────
                NeuCard(
                  style: NeuStyle.flat,
                  borderRadius: 20,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _MenuItem(
                        icon: Icons.shopping_bag_outlined,
                        label: 'My Orders',
                        subtitle: 'Track your purchases',
                        color: AppColors.accentViolet,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OrdersScreen())),
                      ),
                      Divider(color: AppColors.glassBorder, height: 1),
                      _MenuItem(
                        icon: Icons.favorite_border_rounded,
                        label: 'Wishlist',
                        subtitle: '${cart.wishlist.length} books saved',
                        color: AppColors.accentRose,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WishlistScreen()),
                        ),
                      ),
                      Divider(color: AppColors.glassBorder, height: 1),
                      _MenuItem(
                        icon: Icons.location_on_outlined,
                        label: 'Delivery Address',
                        subtitle: 'Manage your addresses',
                        color: AppColors.accentCyan,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddressScreen()),
                        ),
                      ),
                      Divider(color: AppColors.glassBorder, height: 1),
                      _MenuItem(
                        icon: Icons.notifications_outlined,
                        label: 'Notifications',
                        subtitle: 'Manage alerts',
                        color: AppColors.accentAmber,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const NotificationsScreen())),
                      ),
                      Divider(color: AppColors.glassBorder, height: 1),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: 'Help & Support',
                        subtitle: 'FAQs and contact',
                        color: AppColors.textSecondary,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FaqScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Sign Out ─────────────────────────────────────────
                GlassButton(
                  label: 'Sign Out',
                  icon: Icons.logout_rounded,
                  width: double.infinity,
                  gradientColors: [
                    AppColors.accentRose,
                    Colors.red.shade700,
                  ],
                  onPressed: () async {
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      style: NeuStyle.convex,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: Theme.of(context).textTheme.titleLarge),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }
}
