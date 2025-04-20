import 'package:flutter/material.dart';

class AddTaskScreen extends StatefulWidget {
  final Map<String, dynamic>? task;

  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late int _priority;
  late DateTime _dueDate;
  late bool _isEditMode;
  late bool _repeatEnabled;
  late bool _isCompleted;
  late List<bool> _selectedDays;

  // Color Scheme
  final Color primaryColor = const Color(0xFF6C63FF);
  final Color secondaryColor = const Color(0xFF4A90E2);
  final Color accentColor = const Color(0xFF00BFA5);
  final Color backgroundColor = const Color(0xFFF8F9FA);
  final Color cardColor = Colors.white;
  final Color textColor = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.task != null;
    _titleController = TextEditingController(text: widget.task?['title'] ?? '');
    _descriptionController = TextEditingController(
        text: widget.task?['description'] ?? '');
    _categoryController = TextEditingController(
        text: widget.task?['category'] ?? 'Personal');
    _priority = widget.task?['priority'] ?? 0;
    _dueDate = widget.task?['dueDate'] ?? DateTime.now();
    _repeatEnabled = widget.task?['repeatEnabled'] ?? false;
    _isCompleted = widget.task?['completed'] ?? false;
    _selectedDays = List<bool>.filled(7, false);

    if (_isEditMode && widget.task?['repeatDays'] != null) {
      final List<int> repeatDays = widget.task!['repeatDays'];
      for (int day in repeatDays) {
        if (day >= 0 && day < 7) {
          _selectedDays[day] = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Edit Task' : 'Add New Task',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              primaryColor.withOpacity(0.1),
              backgroundColor,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          labelText: 'Task Title*',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                        style: TextStyle(color: textColor),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                          alignLabelWithHint: true,
                        ),
                        style: TextStyle(color: textColor),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: textColor.withOpacity(0.8)),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: primaryColor),
                          ),
                        ),
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildCard(
                  child: Column(
                    children: [
                      _buildPrioritySelector(),
                      const SizedBox(height: 16),
                      _buildDatePicker(),
                      const SizedBox(height: 16),
                      _buildCompletionToggle(),
                      const SizedBox(height: 16),
                      _buildRepeatToggle(),
                      if (_repeatEnabled) ...[
                        const SizedBox(height: 16),
                        _buildDaySelector(),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          primaryColor,
                          secondaryColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _isEditMode ? 'Update Task' : 'Add Task',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildPriorityChip('Low', 0),
            _buildPriorityChip('Medium', 1),
            _buildPriorityChip('High', 2),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityChip(String label, int value) {
    final bool selected = _priority == value;
    Color chipColor;

    switch (value) {
      case 0:
        chipColor = Colors.green;
        break;
      case 1:
        chipColor = Colors.orange;
        break;
      case 2:
        chipColor = Colors.red;
        break;
      default:
        chipColor = primaryColor;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => setState(() => _priority = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? chipColor.withOpacity(0.2) : Colors.transparent,
            border: Border.all(
              color: selected ? chipColor : Colors.grey.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: chipColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? chipColor : textColor.withOpacity(0.7),
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 20, color: primaryColor),
              const SizedBox(width: 12),
              Text(
                '${_dueDate.day}/${_dueDate.month}/${_dueDate.year}',
                style: TextStyle(color: textColor),
              ),
              const Spacer(),
              Text(
                'Change',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCompleted = !_isCompleted;
        });
      },
      child: _buildToggle(
        title: 'Mark as Completed',
        value: _isCompleted,
        activeColor: accentColor,
      ),
    );
  }

  Widget _buildRepeatToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _repeatEnabled = !_repeatEnabled;
        });
      },
      child: _buildToggle(
        title: 'Repeat Task',
        value: _repeatEnabled,
        activeColor: secondaryColor,
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required bool value,
    required Color activeColor,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 28,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: value ? activeColor : Colors.grey.withOpacity(0.3),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  left: value ? 24 : 2,
                  top: 2,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    const List<String> dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Repeat on:',
          style: TextStyle(
            color: textColor.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDays[index] = !_selectedDays[index];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _selectedDays[index]
                        ? primaryColor.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    border: Border.all(
                      color: _selectedDays[index]
                          ? primaryColor
                          : Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    dayNames[index],
                    style: TextStyle(
                      color: _selectedDays[index] ? primaryColor : textColor,
                      fontWeight: _selectedDays[index]
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: textColor,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': _categoryController.text,
        'completed': _isCompleted,
        'priority': _priority,
        'dueDate': _dueDate,
        'repeatEnabled': _repeatEnabled,
        'repeatDays': _repeatEnabled
            ? _selectedDays.asMap().entries
            .where((entry) => entry.value)
            .map((entry) => entry.key)
            .toList()
            : null,
      };
      Navigator.pop(context, task);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}