import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/app_theme.dart';
import '../../models/complaint_model.dart';
import '../../services/complaint_service.dart';

class ComplaintDetailsScreen extends StatefulWidget {
  final ComplaintModel complaint;

  const ComplaintDetailsScreen({
    super.key,
    required this.complaint,
  });

  @override
  State<ComplaintDetailsScreen> createState() => _ComplaintDetailsScreenState();
}

class _ComplaintDetailsScreenState extends State<ComplaintDetailsScreen> {
  final _complaintService = ComplaintService();
  final _commentController = TextEditingController();
  List<ComplaintComment> _comments = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final comments = await _complaintService.getComplaintComments(widget.complaint.id);

      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final comment = ComplaintComment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: widget.complaint.studentId,
        userName: widget.complaint.studentName,
        comment: _commentController.text.trim(),
        createdAt: DateTime.now(),
        userRole: 'student',
      );

      await _complaintService.addComment(widget.complaint.id, comment);
      _commentController.clear();
      _loadComments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding comment: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _getStatusIcon(widget.complaint.status),
                      color: _getStatusColor(widget.complaint.status),
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStatusText(widget.complaint.status),
                            style: AppTheme.subheadingStyle.copyWith(
                              color: _getStatusColor(widget.complaint.status),
                            ),
                          ),
                          if (widget.complaint.currentHandlerName != null)
                            Text(
                              'Handled by ${widget.complaint.currentHandlerName}',
                              style: AppTheme.captionStyle,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Complaint Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.complaint.title,
                      style: AppTheme.headingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.complaint.description,
                      style: AppTheme.bodyStyle,
                    ),
                    const SizedBox(height: 16),
                    // Media Section
                    if (widget.complaint.imageUrl != null ||
                        widget.complaint.videoUrl != null) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Media',
                        style: AppTheme.subheadingStyle,
                      ),
                      const SizedBox(height: 8),
                      if (widget.complaint.imageUrl != null)
                        ListTile(
                          leading: const Icon(Icons.image),
                          title: const Text('View Image'),
                          onTap: () => _launchUrl(widget.complaint.imageUrl!),
                        ),
                      if (widget.complaint.videoUrl != null)
                        ListTile(
                          leading: const Icon(Icons.video_library),
                          title: const Text('View Video'),
                          onTap: () => _launchUrl(widget.complaint.videoUrl!),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Comments Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Comments',
                      style: AppTheme.subheadingStyle,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      )
                    else if (_error != null)
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Error loading comments',
                              style: AppTheme.bodyStyle,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _loadComments,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (_comments.isEmpty)
                      Center(
                        child: Text(
                          'No comments yet',
                          style: AppTheme.captionStyle,
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _comments.length,
                        separatorBuilder: (context, index) => const Divider(),
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return ListTile(
                            title: Text(comment.userName),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(comment.comment),
                                const SizedBox(height: 4),
                                Text(
                                  _formatDate(comment.createdAt),
                                  style: AppTheme.captionStyle,
                                ),
                              ],
                            ),
                            trailing: Text(
                              comment.userRole.toUpperCase(),
                              style: AppTheme.captionStyle.copyWith(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    // Add Comment
                    TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _addComment,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(ComplaintStatus status) {
    switch (status) {
      case ComplaintStatus.submitted:
        return Icons.send;
      case ComplaintStatus.in_progress:
        return Icons.pending_actions;
      case ComplaintStatus.escalated_to_hod:
        return Icons.escalator_warning;
      case ComplaintStatus.resolved:
        return Icons.check_circle;
      case ComplaintStatus.rejected:
        return Icons.cancel;
      case ComplaintStatus.escalated_to_admin:
        // TODO: Handle this case.
        throw UnimplementedError();
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
        return 'Escalated to HOD';
      case ComplaintStatus.resolved:
        return 'Resolved';
      case ComplaintStatus.rejected:
        return 'Rejected';
      case ComplaintStatus.escalated_to_admin:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
} 