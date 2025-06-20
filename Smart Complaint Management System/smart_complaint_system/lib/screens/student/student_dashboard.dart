import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_complaint_system/screens/student/student_profile_screen.dart';
import '../../constants/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'student_complaints_screen.dart';
//import 'student_profile_screen.dart';
import 'submit_complaint_screen.dart';
import '../admin/admin_dashboard.dart';
import '../hod/hod_dashboard.dart';
import '../advisor/advisor_dashboard.dart';
import '../student/student_dashboard.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;

    return DashboardScaffold(
      title: 'Student Dashboard',
      selectedIndex: _selectedIndex,
      onNavigationItemSelected: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SubmitComplaintScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(user),
          const StudentComplaintsScreen(),
          const StudentProfileScreen(),
        ],
      ),
    );
  }

  Widget _buildDashboard(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, ${user.name}!',
                    style: AppTheme.headingStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Batch: ${user.batch ?? 'Not assigned'}',
                    style: AppTheme.bodyStyle,
                  ),
                  Text(
                    'Advisor: ${user.batchAdvisorEmail ?? 'Not assigned'}',
                    style: AppTheme.bodyStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Quick Stats
          Text(
            'Quick Stats',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Complaints',
                  '0',
                  Icons.list_alt,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending',
                  '0',
                  Icons.pending_actions,
                  AppTheme.warningColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Resolved',
                  '0',
                  Icons.check_circle,
                  AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Rejected',
                  '0',
                  Icons.cancel,
                  AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Recent Activity
          Text(
            'Recent Activity',
            style: AppTheme.subheadingStyle,
          ),
          const SizedBox(height: 16),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 0, // TODO: Add recent activity items
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return const ListTile(
                  title: Text('No recent activity'),
                  subtitle: Text('Your recent complaints will appear here'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headingStyle.copyWith(
                color: color,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTheme.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}