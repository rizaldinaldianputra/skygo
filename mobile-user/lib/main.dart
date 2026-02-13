import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; // Added import for Material widgets
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';
import 'session/session_manager.dart';
import 'services/notification_service.dart'; // Ensure this import is present for NotificationService

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  runApp(const SkyGoUserApp());
}

class SkyGoUserApp extends StatelessWidget {
  const SkyGoUserApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkyGo User',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00BFFF),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF87CEEB),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  void _checkSession() async {
    final isLoggedIn = await SessionManager().isLoggedIn();
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF00BFFF)),
        ),
      );
    }
    return _isLoggedIn! ? const DashboardPage() : const LoginPage();
  }
}
