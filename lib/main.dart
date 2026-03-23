// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/cart_provider.dart';
import 'services/notification_provider.dart';
import 'services/orders_provider.dart';
import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GlassBookApp());
}

class GlassBookApp extends StatelessWidget {
  const GlassBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
      ],
      child: MaterialApp(
        title: 'GlassBook',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: (context, child) {
          return Container(
            color: Colors.black,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: ClipRect(child: child!),
              ),
            ),
          );
        },
        home: const _AppGate(),
      ),
    );
  }
}

class _AppGate extends StatelessWidget {
  const _AppGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }
        if (snapshot.hasData) {
          return _LoadUserData(child: const HomeScreen());
        }
        return const AuthScreen();
      },
    );
  }
}

class _LoadUserData extends StatefulWidget {
  final Widget child;
  const _LoadUserData({required this.child});

  @override
  State<_LoadUserData> createState() => _LoadUserDataState();
}

class _LoadUserDataState extends State<_LoadUserData> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await Future.wait([
      context.read<CartProvider>().loadWishlist(),
      context.read<NotificationProvider>().loadNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 64,
              color: AppColors.accentViolet,
            ),
            const SizedBox(height: 16),
            Text(
              'GlassBook',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.accentViolet,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
