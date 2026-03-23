// lib/screens/checkout_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/neu_card.dart';
import '../widgets/animated_background.dart';
import '../services/orders_provider.dart';
import '../services/notification_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  // GCash
  final _gcashCtrl = TextEditingController();
  final _gcashNameCtrl = TextEditingController();

// Card
  final _cardNameCtrl = TextEditingController();
  final _cardNumberCtrl = TextEditingController();
  final _cardExpiryCtrl = TextEditingController();
  final _cardCvvCtrl = TextEditingController();

  String _paymentMethod = 'cod'; // cod = cash on delivery
  bool _loading = false;
  bool _orderPlaced = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _zipCtrl.dispose();
    _gcashCtrl.dispose();
    _gcashNameCtrl.dispose();
    _cardNameCtrl.dispose();
    _cardNumberCtrl.dispose();
    _cardExpiryCtrl.dispose();
    _cardCvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final address =
          '${_nameCtrl.text}, ${_phoneCtrl.text}, ${_addressCtrl.text}, ${_cityCtrl.text} ${_zipCtrl.text}';

      // Save to local orders provider
      final ordersProvider = context.read<OrdersProvider>();
      final notifProvider = context.read<NotificationProvider>();

      final order = await ordersProvider.addOrder(
        items: cart.items.toList(),
        totalAmount: cart.totalAmount,
        address: address,
        paymentMethod: _paymentMethod,
      );

// Send notification
      notifProvider.notifyOrderPlaced(
        ordersProvider.getOrderSummary(order),
      );

      cart.clearCart();
      setState(() {
        _loading = false;
        _orderPlaced = true;
      });
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
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedBackground(
        child: SafeArea(
          child: _orderPlaced
              ? _OrderSuccessView(
                  onDone: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                )
              : Column(
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
                            'Checkout',
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ─── Order Summary ──────────────────────
                              Text(
                                'Order Summary',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              GlassCard(
                                borderRadius: 18,
                                child: Column(
                                  children: [
                                    ...cart.items.map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  item.book.title,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleLarge
                                                      ?.copyWith(fontSize: 13),
                                                ),
                                              ),
                                              Text(
                                                'x${item.quantity}',
                                                style: const TextStyle(
                                                  color: AppColors.textMuted,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                '₱${item.total.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: AppColors.accentCyan,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    const Divider(color: AppColors.glassBorder),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Total',
                                          style: TextStyle(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          '₱${cart.totalAmount.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            color: AppColors.accentCyan,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ─── Delivery Details ───────────────────
                              Text(
                                'Delivery Details',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              NeuCard(
                                style: NeuStyle.concave,
                                borderRadius: 18,
                                child: Column(
                                  children: [
                                    _buildField(
                                      controller: _nameCtrl,
                                      hint: 'Full Name',
                                      icon: Icons.person_outline_rounded,
                                      validator: (v) =>
                                          v!.isEmpty ? 'Enter your name' : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildField(
                                      controller: _phoneCtrl,
                                      hint: 'Phone Number',
                                      icon: Icons.phone_outlined,
                                      keyboardType: TextInputType.phone,
                                      validator: (v) => v!.isEmpty
                                          ? 'Enter your phone'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildField(
                                      controller: _addressCtrl,
                                      hint: 'Street Address',
                                      icon: Icons.home_outlined,
                                      validator: (v) => v!.isEmpty
                                          ? 'Enter your address'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: _buildField(
                                            controller: _cityCtrl,
                                            hint: 'City',
                                            icon: Icons.location_city_outlined,
                                            validator: (v) => v!.isEmpty
                                                ? 'Enter city'
                                                : null,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildField(
                                            controller: _zipCtrl,
                                            hint: 'ZIP',
                                            icon: Icons.pin_outlined,
                                            keyboardType: TextInputType.number,
                                            validator: (v) =>
                                                v!.isEmpty ? 'ZIP' : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ─── Payment Method ─────────────────────
                              Text(
                                'Payment Method',
                                style:
                                    Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              _PaymentOption(
                                value: 'cod',
                                groupValue: _paymentMethod,
                                icon: Icons.payments_outlined,
                                label: 'Cash on Delivery',
                                subtitle: 'Pay when your order arrives',
                                color: AppColors.accentAmber,
                                onChanged: (v) =>
                                    setState(() => _paymentMethod = v!),
                              ),
                              const SizedBox(height: 10),
                              _PaymentOption(
                                value: 'gcash',
                                groupValue: _paymentMethod,
                                icon: Icons.account_balance_wallet_outlined,
                                label: 'GCash',
                                subtitle: 'Pay via GCash mobile wallet',
                                color: AppColors.accentViolet,
                                onChanged: (v) =>
                                    setState(() => _paymentMethod = v!),
                              ),
                              const SizedBox(height: 10),
                              _PaymentOption(
                                value: 'card',
                                groupValue: _paymentMethod,
                                icon: Icons.credit_card_rounded,
                                label: 'Credit / Debit Card',
                                subtitle: 'Visa, Mastercard accepted',
                                color: AppColors.accentCyan,
                                onChanged: (v) =>
                                    setState(() => _paymentMethod = v!),
                              ),
                              const SizedBox(height: 30),

                              // ─── Place Order Button ─────────────────
                              // ─── Payment Details Form ───────────────────────────────────
                              if (_paymentMethod == 'gcash') ...[
                                Text(
                                  'GCash Details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const SizedBox(height: 12),
                                NeuCard(
                                  style: NeuStyle.concave,
                                  borderRadius: 18,
                                  child: Column(
                                    children: [
                                      _buildField(
                                        controller: _gcashCtrl,
                                        hint: 'GCash Mobile Number (09XX)',
                                        icon: Icons.phone_android_rounded,
                                        keyboardType: TextInputType.phone,
                                        validator: (v) {
                                          if (v!.isEmpty)
                                            return 'Enter GCash number';
                                          if (v.length != 11)
                                            return 'Must be 11 digits';
                                          if (!v.startsWith('09'))
                                            return 'Must start with 09';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      _buildField(
                                        controller: _gcashNameCtrl,
                                        hint: 'GCash Account Name',
                                        icon: Icons.person_outline_rounded,
                                        validator: (v) => v!.isEmpty
                                            ? 'Enter account name'
                                            : null,
                                      ),
                                      const SizedBox(height: 8),
                                      GlassCard(
                                        borderRadius: 12,
                                        tintColor: AppColors.accentViolet
                                            .withOpacity(0.08),
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            const Icon(
                                                Icons.info_outline_rounded,
                                                color: AppColors.accentViolet,
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'You will receive a GCash payment request on your number after placing the order.',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ] else if (_paymentMethod == 'card') ...[
                                Text(
                                  'Card Details',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                                const SizedBox(height: 12),
                                NeuCard(
                                  style: NeuStyle.concave,
                                  borderRadius: 18,
                                  child: Column(
                                    children: [
                                      _buildField(
                                        controller: _cardNameCtrl,
                                        hint: 'Cardholder Name',
                                        icon: Icons.person_outline_rounded,
                                        validator: (v) => v!.isEmpty
                                            ? 'Enter cardholder name'
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                      _buildField(
                                        controller: _cardNumberCtrl,
                                        hint: 'Card Number (16 digits)',
                                        icon: Icons.credit_card_rounded,
                                        keyboardType: TextInputType.number,
                                        validator: (v) {
                                          if (v!.isEmpty)
                                            return 'Enter card number';
                                          if (v.replaceAll(' ', '').length !=
                                              16) return 'Must be 16 digits';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _buildField(
                                              controller: _cardExpiryCtrl,
                                              hint: 'MM/YY',
                                              icon:
                                                  Icons.calendar_today_rounded,
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (v) {
                                                if (v!.isEmpty)
                                                  return 'Required';
                                                if (!RegExp(r'^\d{2}/\d{2}$')
                                                    .hasMatch(v))
                                                  return 'Use MM/YY';
                                                return null;
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: _buildField(
                                              controller: _cardCvvCtrl,
                                              hint: 'CVV',
                                              icon: Icons.lock_outline_rounded,
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (v) {
                                                if (v!.isEmpty)
                                                  return 'Required';
                                                if (v.length != 3)
                                                  return 'Must be 3 digits';
                                                return null;
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      GlassCard(
                                        borderRadius: 12,
                                        tintColor: AppColors.accentCyan
                                            .withOpacity(0.08),
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.shield_outlined,
                                                color: AppColors.accentCyan,
                                                size: 16),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Your card details are encrypted and secure. We never store your CVV.',
                                                style: const TextStyle(
                                                  color:
                                                      AppColors.textSecondary,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],

// ─── Place Order Button ─────────────────────────────────────
                              GlassButton(
                                label: _paymentMethod == 'cod'
                                    ? 'Place Order (Cash on Delivery)'
                                    : _paymentMethod == 'gcash'
                                        ? 'Pay with GCash'
                                        : 'Pay with Card',
                                icon: _paymentMethod == 'cod'
                                    ? Icons.check_circle_outline_rounded
                                    : _paymentMethod == 'gcash'
                                        ? Icons.account_balance_wallet_outlined
                                        : Icons.credit_card_rounded,
                                width: double.infinity,
                                isLoading: _loading,
                                onPressed: () => _placeOrder(cart),
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

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: Icon(icon, color: AppColors.textMuted, size: 18),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accentRose, width: 1),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : AppColors.neuBase,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : AppColors.glassBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: AppColors.neuShadowDark.withOpacity(0.9),
                    offset: const Offset(4, 4),
                    blurRadius: 10,
                  ),
                  BoxShadow(
                    color: AppColors.neuShadowLight.withOpacity(0.6),
                    offset: const Offset(-4, -4),
                    blurRadius: 10,
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? color : AppColors.textMuted,
                  width: 2,
                ),
                color: selected ? color : Colors.transparent,
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Order Success View ──────────────────────────────────────────────────────
class _OrderSuccessView extends StatefulWidget {
  final VoidCallback onDone;
  const _OrderSuccessView({required this.onDone});

  @override
  State<_OrderSuccessView> createState() => _OrderSuccessViewState();
}

class _OrderSuccessViewState extends State<_OrderSuccessView>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scale = CurvedAnimation(parent: _anim, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scale,
                child: NeuCard(
                  style: NeuStyle.convex,
                  padding: const EdgeInsets.all(32),
                  borderRadius: 32,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Colors.greenAccent,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Order Placed! 🎉',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your books are on their way.\nExpect delivery in 3-5 business days.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              GlassBadge(
                label: 'Cash on Delivery',
                color: AppColors.accentAmber,
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 40),
              GlassButton(
                label: 'Back to Home',
                icon: Icons.home_rounded,
                width: double.infinity,
                onPressed: widget.onDone,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
