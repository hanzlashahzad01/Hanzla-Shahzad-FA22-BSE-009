import 'package:flutter/material.dart';
import 'package:student_portal/screens/dashboard_screen.dart';
import 'package:student_portal/screens/login_screen.dart';
import 'package:student_portal/screens/profile_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://tzfficfqbnfmdyrxkjxo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR6ZmZpY2ZxYm5mbWR5cnhranhvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDc2MzQ1OTQsImV4cCI6MjA2MzIxMDU5NH0.vN2QPztwJwl8osfG6j6-ljboogMpJNmxrb1C3YnYzyA',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if user is logged in
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          return const DashboardScreen();
        }

        // If no user, show login screen
        return const LoginScreen();
      },
    );
  }
}