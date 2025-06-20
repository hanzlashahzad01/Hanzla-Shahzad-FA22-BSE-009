import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/complaint_service.dart';

class AdvisorDashboard extends StatefulWidget {
  const AdvisorDashboard({super.key});

  @override
  State<AdvisorDashboard> createState() => _AdvisorDashboardState();
}

class _AdvisorDashboardState extends State<AdvisorDashboard> {
  List<ComplaintModel> _complaints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchComplaints();
  }

  Future<void> _fetchComplaints() async {
    print('Fetching all complaints...');
    try {
      final complaints = await ComplaintService().getAllComplaints();
      print('Complaints fetched: ${complaints.length}');
      for (var c in complaints) {
        print('Complaint: ${c.title}, Student: ${c.studentName}, Status: ${c.status}');
      }
      setState(() {
        _complaints = complaints;
        _loading = false;
      });
    } catch (e) {
      print('Error fetching complaints: $e');
      setState(() {
        _complaints = [];
        _loading = false;
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

  Future<void> _forwardToHod(ComplaintModel complaint) async {
    // For demo, just clear handler (in real, set HOD's id/name)
    await ComplaintService().updateComplaintStatus(
      complaint.id,
      ComplaintStatus.escalatedToHod,
      null,
      null,
    );
    _fetchComplaints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Advisor Dashboard')),
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
                            Text('Status: ${c.status.toString().split('.').last}'),
                            Text('Date: ${c.createdAt.toLocal().toString().split(".")[0]}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ElevatedButton(
                              onPressed: c.status == ComplaintStatus.resolved
                                  ? null
                                  : () => _solveComplaint(c),
                              child: const Text('Solve'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: c.status == ComplaintStatus.escalatedToHod || c.status == ComplaintStatus.resolved
                                  ? null
                                  : () => _forwardToHod(c),
                              child: const Text('Forward to HOD'),
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