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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    try {
      final complaints = await ComplaintService().getAllComplaints();
      setState(() {
        _complaints = complaints
            .where((c) => c.status == ComplaintStatus.escalated_to_hod)
            .toList();
        _loading = false;
        _errorMessage = null;
      });
    } catch (e, s) {
      print('Error fetching HOD complaints: $e');
      print('Stack trace: $s');
      setState(() {
        _loading = false;
        _errorMessage = 'Failed to load complaints.\n\nError: $e';
      });
    }
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

  Future<void> _forwardToAdmin(ComplaintModel complaint) async {
    print('Forwarding complaint to Director: ${complaint.id}');
    try {
      await ComplaintService().updateComplaintStatus(
        complaint.id,
        ComplaintStatus.escalated_to_admin,
        null,
        null,
      );
      print('Forwarded!');
    } catch (e) {
      print('Error forwarding to Director: $e');
    }
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
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : _complaints.isEmpty
                  ? const Center(child: Text('No complaints forwarded to you.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _complaints.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final c = _complaints[index];
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  title: Text(c.title),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Description: ${c.description}'),
                                      Text('Student: ${c.studentName}'),
                                      Text('Status: ${c.status?.toString().split('.').last ?? 'Unknown'}'),
                                      Text('Date: ${c.createdAt != null ? c.createdAt.toLocal().toString().split(".")[0] : 'Unknown'}'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  alignment: WrapAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: c.status == ComplaintStatus.resolved || c.status == ComplaintStatus.rejected
                                          ? null
                                          : () => _solveComplaint(c),
                                      child: const Text('Solve'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: c.status == ComplaintStatus.rejected || c.status == ComplaintStatus.resolved
                                          ? null
                                          : () => _rejectComplaint(c),
                                      child: const Text('Reject'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange,
                                      ),
                                      onPressed: c.status == ComplaintStatus.resolved || c.status == ComplaintStatus.rejected || c.status == ComplaintStatus.escalated_to_admin
                                          ? null
                                          : () => _forwardToAdmin(c),
                                      child: const Text('Forward to Director'),
                                    ),
                                  ],
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