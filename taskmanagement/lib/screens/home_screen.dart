import 'package:flutter/material.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tasks = [
    {
      'title': 'Complete project proposal',
      'category': 'Work',
      'completed': false,
      'priority': 2, // High
      'dueDate': DateTime.now().add(const Duration(days: 1)),
      'repeatEnabled': true,
      'repeatDays': [1, 3, 5],
    },
    {
      'title': 'Buy groceries',
      'category': 'Personal',
      'completed': true,
      'priority': 1, // Medium
      'dueDate': DateTime.now().subtract(const Duration(days: 1)),
      'repeatEnabled': false,
    },
    {
      'title': 'Morning workout',
      'category': 'Health',
      'completed': false,
      'priority': 0, // Low
      'dueDate': DateTime.now(),
      'repeatEnabled': true,
      'repeatDays': [0, 1, 2, 3, 4, 5, 6],
    },
    {
      'title': 'Team meeting',
      'category': 'Work',
      'completed': false,
      'priority': 1, // Medium
      'dueDate': DateTime.now().add(const Duration(days: 2)),
      'repeatEnabled': false,
    },
  ];

  int _currentTabIndex = 0;
  int? _currentPriorityFilter;

  // Enhanced Color Scheme
  final Color primaryColor = const Color(0xFF6A1B9A);
  final Color secondaryColor = const Color(0xFF9C27B0);
  final Color accentColor = const Color(0xFF00BFA5);
  final Color backgroundColor = const Color(0xFFFAFAFA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF212121);
  final Color lightTextColor = const Color(0xFF757575);
  final Color filterActiveColor = const Color(0xFFE1BEE7);

  List<Map<String, dynamic>> get _filteredTasks {
    return tasks.where((task) {
      final tabFilter = _currentTabIndex == 0 ||
          (_currentTabIndex == 1 && task['completed']) ||
          (_currentTabIndex == 2 && task['repeatEnabled']);

      final priorityFilter = _currentPriorityFilter == null ||
          task['priority'] == _currentPriorityFilter;

      return tabFilter && priorityFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTabBar(),
          _buildStatsHeader(),
          Expanded(child: _buildTaskList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
        onPressed: _navigateToAddTask,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Task Manager',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          )),
      backgroundColor: primaryColor,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: _currentPriorityFilter != null
                ? filterActiveColor.withOpacity(0.9)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _currentPriorityFilter != null ? primaryColor : Colors.white,
            ),
            onPressed: _showFilterOptions,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    final completedCount = tasks.where((t) => t['completed']).length;
    final pendingCount = tasks.length - completedCount;
    final repeatingCount = tasks.where((t) => t['repeatEnabled']).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', tasks.length, primaryColor),
          _buildStatItem('Done', completedCount, Colors.green),
          _buildStatItem('Pending', pendingCount, Colors.orange),
          _buildStatItem('Repeat', repeatingCount, accentColor),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('All', 0),
          _buildTabButton('Completed', 1),
          _buildTabButton('Repeating', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = _currentTabIndex == index;
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _currentTabIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border(
                bottom: BorderSide(
                  color: primaryColor,
                  width: 3,
                ),
              )
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isSelected ? primaryColor : lightTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final taskList = _filteredTasks;

    if (taskList.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_outlined,
                size: 72,
                color: Colors.grey.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                _currentTabIndex == 1
                    ? 'No completed tasks yet!'
                    : _currentTabIndex == 2
                    ? 'No repeating tasks!'
                    : 'No tasks found!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: lightTextColor,
                ),
              ),
              const SizedBox(height: 8),
              if (_currentTabIndex == 0)
                Text(
                  'Tap + to add a new task',
                  style: TextStyle(
                    fontSize: 14,
                    color: lightTextColor.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => await Future.delayed(const Duration(seconds: 1)),
      color: primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.75, // Adjusted to prevent overflow
        ),
        itemCount: taskList.length,
        itemBuilder: (context, index) => _buildTaskCard(taskList[index], index),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, int index) {
    final isCompleted = task['completed'];
    final priority = task['priority'];
    final dueDate = task['dueDate'] as DateTime?;
    final isOverdue = _isTaskOverdue(dueDate, isCompleted);
    final isRepeating = task['repeatEnabled'] ?? false;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showTaskOptions(index),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Priority & Checkbox Row
              SizedBox(
                height: 32,
                child: Row(
                  children: [
                    Flexible(
                      child: _buildPriorityIndicator(priority),
                    ),
                    const Spacer(),
                    Transform.scale(
                      scale: 1.2,
                      child: Checkbox(
                        value: isCompleted,
                        onChanged: (value) => _toggleTaskCompletion(index),
                        activeColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Task Title
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 48),
                  child: Text(
                    task['title'],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? lightTextColor : textColor,
                    ),
                  ),
                ),
              ),

              // Category & Date
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.category, size: 16, color: lightTextColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            task['category'],
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: lightTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: isOverdue ? Colors.red : lightTextColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDate(dueDate),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: isOverdue ? Colors.red : lightTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Badges
              if (isOverdue || isRepeating) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (isOverdue)
                      _buildStatusBadge('Overdue', Icons.warning_amber_rounded, Colors.red),
                    if (isRepeating)
                      _buildStatusBadge('Repeating', Icons.repeat, accentColor),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    final Map<int, Map<String, dynamic>> priorityData = {
      0: {'color': Colors.green, 'label': 'Low', 'icon': Icons.arrow_downward},
      1: {'color': Colors.orange, 'label': 'Med', 'icon': Icons.arrow_forward}, // Shortened label
      2: {'color': Colors.red, 'label': 'High', 'icon': Icons.arrow_upward},
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 80), // Added max width
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), // Reduced padding
      decoration: BoxDecoration(
        color: priorityData[priority]!['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: priorityData[priority]!['color'].withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            priorityData[priority]!['icon'],
            size: 14,
            color: priorityData[priority]!['color'],
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              priorityData[priority]!['label'],
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: priorityData[priority]!['color'],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No deadline';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    if (date.year == today.year && date.month == today.month && date.day == today.day) {
      return 'Today';
    } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
      return 'Tomorrow';
    }
    return '${_monthAbbreviations[date.month - 1]} ${date.day}';
  }

  static const List<String> _monthAbbreviations = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  bool _isTaskOverdue(DateTime? dueDate, bool completed) {
    return !completed && dueDate != null && dueDate.isBefore(DateTime.now());
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      tasks[index]['completed'] = !tasks[index]['completed'];
    });
  }

  void _showTaskOptions(int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.edit, color: primaryColor),
                title: Text('Edit Task', style: TextStyle(color: textColor)),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToEditTask(index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete Task', style: TextStyle(color: Colors.red)),
                onTap: () {
                  final deletedTask = tasks[index];
                  setState(() => tasks.removeAt(index));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: primaryColor,
                        onPressed: () {
                          setState(() => tasks.insert(index, deletedTask));
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateToAddTask() async {
    final newTask = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
    if (newTask != null && mounted) {
      setState(() => tasks.add(newTask));
    }
  }

  void _navigateToEditTask(int index) async {
    final updatedTask = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(task: tasks[index]),
      ),
    );
    if (updatedTask != null && mounted) {
      setState(() => tasks[index] = updatedTask);
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Filter by Priority',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              _buildPriorityFilterOption('All Priorities', null),
              _buildPriorityFilterOption('High Priority', 2),
              _buildPriorityFilterOption('Medium Priority', 1),
              _buildPriorityFilterOption('Low Priority', 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPriorityFilterOption(String title, int? priority) {
    final isSelected = _currentPriorityFilter == priority;
    return ListTile(
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? primaryColor : lightTextColor,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? textColor : lightTextColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        setState(() => _currentPriorityFilter = priority);
        Navigator.pop(context);
      },
    );
  }
}