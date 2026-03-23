// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/orders_provider.dart';
import '../services/notification_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Load orders from Firestore when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();

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
                    Text('My Orders',
                        style: Theme.of(context).textTheme.headlineLarge),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tab bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NeuCard(
                  style: NeuStyle.concave,
                  padding: const EdgeInsets.all(4),
                  borderRadius: 14,
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentViolet,
                          AppColors.accentCyan,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentViolet.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textMuted,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(
                        text: 'Active (${ordersProvider.activeOrders.length})',
                      ),
                      Tab(
                        text:
                            'Cancelled (${ordersProvider.cancelledOrders.length})',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _OrdersList(
                      orders: ordersProvider.activeOrders,
                      showCancel: true,
                      emptyMessage: 'No active orders',
                      emptySubtitle: 'Your orders will appear here',
                      emptyIcon: Icons.shopping_bag_outlined,
                    ),
                    _OrdersList(
                      orders: ordersProvider.cancelledOrders,
                      showCancel: false,
                      emptyMessage: 'No cancelled orders',
                      emptySubtitle: 'Cancelled orders will appear here',
                      emptyIcon: Icons.cancel_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrdersList extends StatelessWidget {
  final List<AppOrder> orders;
  final bool showCancel;
  final String emptyMessage;
  final String emptySubtitle;
  final IconData emptyIcon;

  const _OrdersList({
    required this.orders,
    required this.showCancel,
    required this.emptyMessage,
    required this.emptySubtitle,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeuCard(
              style: NeuStyle.convex,
              padding: const EdgeInsets.all(24),
              borderRadius: 24,
              child: Icon(emptyIcon, size: 56, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            Text(emptyMessage,
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(emptySubtitle, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final order = orders[i];
        return _OrderCard(order: order, showCancel: showCancel);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  final bool showCancel;

  const _OrderCard({required this.order, required this.showCancel});

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.accentAmber;
      case 'processing':
        return AppColors.accentCyan;
      case 'shipped':
        return AppColors.accentViolet;
      case 'delivered':
        return Colors.greenAccent;
      case 'cancelled':
        return AppColors.accentRose;
      default:
        return AppColors.textMuted;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.access_time_rounded;
      case 'processing':
        return Icons.settings_rounded;
      case 'shipped':
        return Icons.local_shipping_outlined;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  void _confirmCancel(BuildContext context, AppOrder order) {
    final ordersProvider = context.read<OrdersProvider>();
    final notifProvider = context.read<NotificationProvider>();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgMid,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Order',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to cancel order ${order.id}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ordersProvider.cancelOrder(order.id);
              notifProvider
                  .notifyOrderCancelled(ordersProvider.getOrderSummary(order));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Order cancelled'),
                  backgroundColor: AppColors.accentRose,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            child: const Text('Cancel Order',
                style: TextStyle(color: AppColors.accentRose)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(order.status);

    return NeuCard(
      style: NeuStyle.flat,
      borderRadius: 18,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order ID + Status
          Row(
            children: [
              Text(
                order.id,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: statusColor.withOpacity(0.4), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(order.status),
                        color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      order.statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Items
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        width: 36,
                        height: 50,
                        color: AppColors.bgMid,
                        child: item.book.coverUrl.isNotEmpty
                            ? Image.network(item.book.coverUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.menu_book_rounded,
                                    color: AppColors.textMuted,
                                    size: 16))
                            : const Icon(Icons.menu_book_rounded,
                                color: AppColors.textMuted, size: 16),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontSize: 12),
                      ),
                    ),
                    Text(
                      'x${item.quantity}',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₱${item.total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppColors.accentCyan,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )),

          const Divider(color: AppColors.glassBorder),

          // Total + date + payment
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(order.createdAt),
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        order.paymentMethod == 'cod'
                            ? Icons.payments_outlined
                            : order.paymentMethod == 'gcash'
                                ? Icons.account_balance_wallet_outlined
                                : Icons.credit_card_rounded,
                        size: 12,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.paymentMethod == 'cod'
                            ? 'Cash on Delivery'
                            : order.paymentMethod == 'gcash'
                                ? 'GCash'
                                : 'Card',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total',
                      style:
                          TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  Text(
                    '₱${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Cancel button
          if (showCancel && order.canCancel) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _confirmCancel(context, order),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentRose.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.accentRose.withOpacity(0.4), width: 1),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cancel_outlined,
                        color: AppColors.accentRose, size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Cancel Order',
                      style: TextStyle(
                        color: AppColors.accentRose,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final months = [
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
    return '${d.day} ${months[d.month - 1]} ${d.year} • ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
