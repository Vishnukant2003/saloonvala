  import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/salon_provider.dart';
import 'providers/booking_provider.dart';
import 'screens/auth/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (add your firebase_options.dart later)
  // await Firebase.initializeApp();
  
  runApp(const SaloonValaApp());
}

class SaloonValaApp extends StatelessWidget {
  const SaloonValaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
      ],
      child: MaterialApp(
        title: 'SaloonVala',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainScreen(), // Start with main/welcome screen
        routes: AppRoutes.routes,
      ),
    );
  }
}

