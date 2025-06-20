import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/complaint_service.dart';
import '../auth/login_screen.dart';

class HodDashboard extends StatefulWidget {
  const HodDashboard({super.key});

  @override
  State<HodDashboard> createState() => _HodDashboardState();
}

class _HodDashboardState extends State<HodDashboard> {
  List<ComplaintModel> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    // Fetch only complaints escalated to HOD
    final complaints = await ComplaintService().getAllComplaints();
    setState(() {
      _complaints = complaints.where((c) => c.status == ComplaintStatus.escalatedToHod).toList();
      _loading = false;
    });
  }

  Future<void> _solveComplaint(ComplaintModel complaint) async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    await ComplaintService().updateComplaintStatus(
      complaint.id,
      ComplaintStatus.resolved,
      user.id,
      user.name,
    );
    _fetchComplaints();
  }

  Future<void> _rejectComplaint(ComplaintModel complaint) async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    await ComplaintService().updateComplaintStatus(
      complaint.id,
      ComplaintStatus.rejected,
      user.id,
      user.name,
    );
    _fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOD Dashboard'),
        actions: [
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
              ? const Center(child: Text('No complaints assigned.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _complaints.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final c = _complaints[index];
                    return Card(
                      child: ListTile(
                        title: Text(c.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Description: ${c.description}'),
                            Text('Status: ${c.status.toString().split('.').last}'),
                            Text('Date: ${c.createdAt.toLocal().toString().split(".")[0]}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: c.status == ComplaintStatus.resolved || c.status == ComplaintStatus.rejected
                                  ? null
                                  : () => _solveComplaint(c),
                              child: const Text('Solve'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: c.status == ComplaintStatus.rejected || c.status == ComplaintStatus.resolved
                                  ? null
                                  : () => _rejectComplaint(c),
                              child: const Text('Reject'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 