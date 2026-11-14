import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/auth_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/qr_scanner_screen.dart';
import 'screens/regex_defense_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const CampusLostFoundApp(),
    ),
  );
}

class CampusLostFoundApp extends StatelessWidget {
  const CampusLostFoundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Lost & Found',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
          secondary: const Color(0xFF26A69A),
          surface: Colors.grey.shade50,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 2,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AppGuard(),
        '/auth': (context) => const AuthScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/admin': (context) => const AdminScreen(),
        '/qr_scanner': (context) => const QrScannerScreen(),
        '/regex_defense': (context) => const RegexDefenseScreen(),
      },
    );
  }
}

class AppGuard extends StatelessWidget {
  const AppGuard({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    if (!state.isLoggedIn) {
      return const AuthScreen();
    }
    return const DashboardScreen();
  }
}
