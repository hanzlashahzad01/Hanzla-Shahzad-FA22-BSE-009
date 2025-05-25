import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:student_portal/services/auth_service.dart';
import 'package:student_portal/services/task_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final AuthService _authService = AuthService();
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _progress = [];
  int _streak = 0;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    print('DashboardScreen initState: User = ${_authService.currentUser?.id}');
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    print('DashboardScreen disposed');
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      print('Loading data for user: ${user?.id}');
      if (user == null || user.id == null) {
        print('No user logged in, redirecting to login');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
        return;
      }

      // Fetch tasks
      _tasks = await _taskService.getStudentTasks(user.id) ?? [];
      print('Tasks fetched: $_tasks');

      // Fetch progress data from Supabase reports table
      final progressResponse = await _supabase
          .from('reports')
          .select()
          .eq('student_id', user.id);
      _progress = (progressResponse as List<dynamic>?)?.cast<Map<String, dynamic>>() ?? [
        {'subject': 'Math', 'score': 85},
        {'subject': 'Physics', 'score': 90},
        {'subject': 'English', 'score': 78},
      ];
      print('Progress fetched: $_progress');

      // Calculate streak based on task completion dates
      _streak = await _calculateStreak(user.id);
      print('Streak calculated: $_streak');
    } catch (e, stackTrace) {
      print('Error loading data: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    }
  }

  Future<int> _calculateStreak(String userId) async {
    try {
      final completedTasks = await _supabase
          .from('tasks')
          .select('updated_at')
          .eq('assigned_to', userId)
          .eq('status', 'completed')
          .order('updated_at', ascending: false);
      if (completedTasks.isEmpty) return 0;

      int streak = 0;
      DateTime? lastDate;
      for (var task in completedTasks) {
        final updatedAt = DateTime.parse(task['updated_at']);
        final taskDate = DateTime(updatedAt.year, updatedAt.month, updatedAt.day);
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);

        if (lastDate == null) {
          if (taskDate.isAtSameMomentAs(todayDate) || taskDate.isAtSameMomentAs(todayDate.subtract(const Duration(days: 1)))) {
            streak++;
            lastDate = taskDate;
          } else {
            break;
          }
        } else {
          final previousDay = lastDate.subtract(const Duration(days: 1));
          if (taskDate.isAtSameMomentAs(previousDay)) {
            streak++;
            lastDate = taskDate;
          } else {
            break;
          }
        }
      }
      return streak;
    } catch (e, stackTrace) {
      print('Error calculating streak: $e\n$stackTrace');
      return 0;
    }
  }

  Future<void> _markTaskComplete(String taskId) async {
    try {
      await _taskService.markTaskComplete(taskId);
      await _loadData();
    } catch (e, stackTrace) {
      print('Error marking task complete: $e\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking task: $e')),
        );
      }
    }
  }

  Widget getTitlesWidget(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index % 20 == 0) {
      return Text(
        index.toString(),
        style: const TextStyle(fontSize: 12, color: Colors.white70),
      );
    }
    return const Text('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = _tasks.where((t) => t['status'] == 'completed').length;
    final total = _tasks.length;
    final progress = total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFE0EAFC),
      appBar: AppBar(
        title: const Text('Student Dashboard'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _authService.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProgressCard(
                  context: context,
                  progress: progress,
                  completed: completed,
                  total: total,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.0, // Adjusted to fit content without overflow
                    children: [
                      _buildFeatureCard(
                        context,
                        icon: Icons.person_rounded,
                        title: 'My Profile',
                        color: Colors.blue.shade100,
                        iconColor: Colors.blue.shade800,
                        onTap: () => Navigator.pushNamed(context, '/profile'),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.assignment_rounded,
                        title: 'My Tasks',
                        count: _tasks.length,
                        color: Colors.purple.shade100,
                        iconColor: Colors.purple.shade800,
                        onTap: () => _showTasks(context),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.check_circle_rounded,
                        title: 'Complete Tasks',
                        count: completed,
                        color: Colors.green.shade100,
                        iconColor: Colors.green.shade800,
                        onTap: () {},
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.analytics_rounded,
                        title: 'Progress',
                        color: Colors.orange.shade100,
                        iconColor: Colors.orange.shade800,
                        onTap: () => _showProgressReport(context),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.star_rounded,
                        title: 'My Streaks',
                        count: _streak,
                        color: Colors.red.shade100,
                        iconColor: Colors.red.shade800,
                        onTap: () => _showStreaks(context),
                      ),
                      _buildFeatureCard(
                        context,
                        icon: Icons.refresh_rounded,
                        title: 'Refresh',
                        color: Colors.teal.shade100,
                        iconColor: Colors.teal.shade800,
                        onTap: _loadData,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard({
    required BuildContext context,
    required double progress,
    required int completed,
    required int total,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF3E5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ) ??
                          const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Progress',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ) ??
                          const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completed out of $total tasks completed',
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700) ??
                          TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        int? count,
        required Color color,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: color,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.2),
                ),
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ) ??
                    const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
              ),
              if (count != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ) ??
                        TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showTasks(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'My Tasks',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _tasks.isEmpty
                  ? const Center(child: Text('No tasks available', style: TextStyle(color: Colors.grey)))
                  : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tasks.length,
                separatorBuilder: (context, index) => const Divider(height: 16),
                itemBuilder: (context, index) {
                  final task = _tasks[index];
                  return ListTile(
                    leading: Checkbox(
                      value: task['status'] == 'completed',
                      onChanged: (value) => _markTaskComplete(task['id']),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      activeColor: Colors.green,
                    ),
                    title: Text(
                      task['title'] ?? 'Untitled Task',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        decoration: task['status'] == 'completed' ? TextDecoration.lineThrough : null,
                        color: task['status'] == 'completed' ? Colors.grey : Colors.black87,
                      ),
                    ),
                    subtitle: task['description'] != null ? Text(task['description'], style: const TextStyle(color: Colors.grey)) : null,
                    trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: Colors.grey.shade100,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProgressReport(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Progress Report',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ) ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 24),
              _progress.isEmpty
                  ? const Text(
                'No progress data available',
                style: TextStyle(color: Colors.white70),
              )
                  : SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barGroups: _progress.asMap().entries.map((entry) {
                      final index = entry.key;
                      final data = entry.value;
                      final score = (data['score'] is num)
                          ? (data['score'] as num).toDouble().clamp(0.0, 100.0)
                          : 0.0;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: score,
                            color: Colors.white,
                            width: 20,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      );
                    }).toList(),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: getTitlesWidget,
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < _progress.length) {
                              return Text(
                                _progress[index]['subject'] ?? 'Unknown',
                                style: const TextStyle(fontSize: 12, color: Colors.white70),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(150, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                ),
                child: const Text('Close', style: TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStreaks(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.redAccent, Colors.orangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                'Current Streak',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ) ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_streak ${_streak == 1 ? "day" : "days"}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ) ??
                    const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(150, 50),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.redAccent,
                ),
                child: const Text('Great!', style: TextStyle(color: Colors.redAccent)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}