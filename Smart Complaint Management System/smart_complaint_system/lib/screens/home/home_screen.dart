import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import '../admin/admin_dashboard.dart';
import '../hod/hod_dashboard.dart';
import '../advisor/advisor_dashboard.dart';
import '../student/student_dashboard.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return const LoginScreen();
    }

    return Scaffold(
      body: _buildRoleBasedScreen(user),
    );
  }

  Widget _buildRoleBasedScreen(UserModel user) {
    switch (user.role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.hod:
        return const HodDashboard();
      case UserRole.batchAdvisor:
        return const AdvisorDashboard();
      case UserRole.student:
        return const StudentDashboard();
      default:
        return const Center(
          child: Text('Unknown role'),
        );
    }
  }
}



class DashboardScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;
  final Widget? floatingActionButton;
  final int selectedIndex;
  final Function(int) onNavigationItemSelected;

  const DashboardScaffold({
    super.key,
    required this.title,
    this.actions = const [],
    required this.body,
    this.floatingActionButton,
    required this.selectedIndex,
    required this.onNavigationItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          ...actions,
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        await authProvider.signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onNavigationItemSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
} 