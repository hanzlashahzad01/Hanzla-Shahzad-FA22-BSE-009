import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/complaint_service.dart';
import 'complaint_details_screen.dart';

class StudentComplaintsScreen extends StatefulWidget {
  const StudentComplaintsScreen({super.key});

  @override
  State<StudentComplaintsScreen> createState() => _StudentComplaintsScreenState();
}

class _StudentComplaintsScreenState extends State<StudentComplaintsScreen> {
  final _complaintService = ComplaintService();
  List<ComplaintModel> _complaints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
      final complaints = await _complaintService.getStudentComplaints(user.id);

      setState(() {
        _complaints = complaints;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return AppTheme.primaryColor;
      case ComplaintStatus.in_progress:
        return AppTheme.warningColor;
      case ComplaintStatus.escalated_to_hod:
        return AppTheme.accentColor;
      case ComplaintStatus.resolved:
        return AppTheme.successColor;
      case ComplaintStatus.rejected:
        return AppTheme.errorColor;
      case ComplaintStatus.escalated_to_admin:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _getStatusText(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return 'Submitted';
      case ComplaintStatus.in_progress:
        return 'In Progress';
      case ComplaintStatus.escalated_to_hod:
        return 'Forwarded to HOD';
      case ComplaintStatus.resolved:
        return 'Solved';
      case ComplaintStatus.rejected:
        return 'Rejected';
      case ComplaintStatus.escalated_to_admin:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error loading complaints',
              style: AppTheme.bodyStyle,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadComplaints,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_complaints.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox,
              size: 64,
              color: AppTheme.textHintColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No complaints yet',
              style: AppTheme.subheadingStyle,
            ),
            const SizedBox(height: 8),
            Text(
              'Submit your first complaint',
              style: AppTheme.captionStyle,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComplaints,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _complaints.length,
        itemBuilder: (context, index) {
          final complaint = _complaints[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ComplaintDetailsScreen(
                      complaint: complaint,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            complaint.title,
                            style: AppTheme.subheadingStyle,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(complaint.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(complaint.status),
                            style: TextStyle(
                              color: _getStatusColor(complaint.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      complaint.description,
                      style: AppTheme.bodyStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppTheme.textSecondaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Submitted on ${_formatDate(complaint.createdAt)}',
                          style: AppTheme.captionStyle,
                        ),
                        const Spacer(),
                        if (complaint.currentHandlerName != null) ...[
                          Icon(
                            Icons.person,
                            size: 16,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Handled by ${complaint.currentHandlerName}',
                            style: AppTheme.captionStyle,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 