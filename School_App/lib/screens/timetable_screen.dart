import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timetable_provider.dart';
import '../providers/teacher_provider.dart';
import '../providers/student_provider.dart';
import '../models/models.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedClass = '';
  String _selectedSection = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadStudents();
      context.read<TeacherProvider>().loadTeachers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timetable Management'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.schedule), text: 'View Timetable'),
            Tab(icon: Icon(Icons.edit_calendar), text: 'Manage Periods'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ViewTimetableTab(
            selectedClass: _selectedClass,
            selectedSection: _selectedSection,
            onClassSelected: (className, section) {
              setState(() {
                _selectedClass = className;
                _selectedSection = section;
              });
            },
          ),
          _ManagePeriodsTab(),
        ],
      ),
    );
  }
}

class _ViewTimetableTab extends StatefulWidget {
  final String selectedClass;
  final String selectedSection;
  final Function(String, String) onClassSelected;

  const _ViewTimetableTab({
    required this.selectedClass,
    required this.selectedSection,
    required this.onClassSelected,
  });

  @override
  State<_ViewTimetableTab> createState() => _ViewTimetableTabState();
}

class _ViewTimetableTabState extends State<_ViewTimetableTab> {
  int _selectedDay = DateTime.now().weekday; // 1 = Monday

  @override
  Widget build(BuildContext context) {
    return Consumer3<TimetableProvider, StudentProvider, TeacherProvider>(
      builder: (context, timetableProvider, studentProvider, teacherProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildClassSelector(studentProvider, timetableProvider),
              const SizedBox(height: 16),
              if (widget.selectedClass.isNotEmpty) ...[
                _buildDaySelector(),
                const SizedBox(height: 16),
                _buildTimetableView(timetableProvider, teacherProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildClassSelector(StudentProvider studentProvider, TimetableProvider timetableProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Class & Section',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: widget.selectedClass.isEmpty ? null : widget.selectedClass,
                    hint: const Text('Choose Class'),
                    isExpanded: true,
                    items: studentProvider.uniqueClasses
                        .map((className) => DropdownMenuItem(
                              value: className,
                              child: Text(className),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        widget.onClassSelected(value, 'A'); // Default section
                        timetableProvider.updateSelectedClass(value, 'A');
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<String>(
                    value: widget.selectedSection.isEmpty ? null : widget.selectedSection,
                    hint: const Text('Section'),
                    isExpanded: true,
                    items: ['A', 'B', 'C']
                        .map((section) => DropdownMenuItem(
                              value: section,
                              child: Text('Section $section'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null && widget.selectedClass.isNotEmpty) {
                        widget.onClassSelected(widget.selectedClass, value);
                        timetableProvider.updateSelectedClass(widget.selectedClass, value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Day',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.asMap().entries.map((entry) {
                final index = entry.key + 1; // Monday = 1
                final day = entry.value;
                return ChoiceChip(
                  label: Text(day),
                  selected: _selectedDay == index,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedDay = index;
                      });
                    }
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimetableView(TimetableProvider timetableProvider, TeacherProvider teacherProvider) {
    final dayEntries = timetableProvider.getTimetableForDay(_selectedDay);
    
    if (dayEntries.isEmpty) {
      return const Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.schedule, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No timetable entries for this day',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    '${timetableProvider.getDayName(_selectedDay)} - ${widget.selectedClass} ${widget.selectedSection}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: dayEntries.length,
                itemBuilder: (context, index) {
                  final entry = dayEntries[index];
                  final teacher = teacherProvider.getTeacherById(entry.teacherId);
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          entry.period.toString(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        entry.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Teacher: ${teacher?.name ?? 'Unknown'}\nTime: ${entry.startTime} - ${entry.endTime}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagePeriodsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer2<TimetableProvider, TeacherProvider>(
      builder: (context, timetableProvider, teacherProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.edit_calendar, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Timetable Management',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _showAddPeriodDialog(context, timetableProvider, teacherProvider),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Period'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Features Available:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Create class-wise period schedules\n'
                        '• Assign subjects and teachers to periods\n'
                        '• Set time slots for each period\n'
                        '• Manage weekly timetable offline\n'
                        '• Update periods as needed',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (timetableProvider.timetableEntries.isNotEmpty) ...[
                const Text(
                  'Current Entries',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    itemCount: timetableProvider.timetableEntries.length,
                    itemBuilder: (context, index) {
                      final entry = timetableProvider.timetableEntries[index];
                      final teacher = teacherProvider.getTeacherById(entry.teacherId);
                      
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Text(
                              entry.period.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text('${entry.className} ${entry.section} - ${entry.subject}'),
                          subtitle: Text(
                            '${timetableProvider.getDayName(entry.dayOfWeek)} | ${entry.startTime}-${entry.endTime}\n'
                            'Teacher: ${teacher?.name ?? 'Unknown'}',
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'delete') {
                                timetableProvider.deleteTimetableEntry(entry.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Period deleted successfully'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else
                const Expanded(
                  child: Center(
                    child: Text(
                      'No timetable entries yet.\nTap "Add Period" to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddPeriodDialog(BuildContext context, TimetableProvider timetableProvider, TeacherProvider teacherProvider) {
    final classController = TextEditingController();
    final sectionController = TextEditingController(text: 'A');
    final subjectController = TextEditingController();
    final startTimeController = TextEditingController();
    final endTimeController = TextEditingController();
    
    int selectedDay = 1;
    int selectedPeriod = 1;
    String? selectedTeacherId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Period'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: classController,
                            decoration: const InputDecoration(
                              labelText: 'Class',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: sectionController,
                            decoration: const InputDecoration(
                              labelText: 'Section',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: subjectController,
                      decoration: const InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: selectedDay,
                            decoration: const InputDecoration(
                              labelText: 'Day',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('Monday')),
                              DropdownMenuItem(value: 2, child: Text('Tuesday')),
                              DropdownMenuItem(value: 3, child: Text('Wednesday')),
                              DropdownMenuItem(value: 4, child: Text('Thursday')),
                              DropdownMenuItem(value: 5, child: Text('Friday')),
                            ],
                            onChanged: (value) {
                              setDialogState(() {
                                selectedDay = value!;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: selectedPeriod,
                            decoration: const InputDecoration(
                              labelText: 'Period',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(8, (index) => 
                              DropdownMenuItem(
                                value: index + 1,
                                child: Text('Period ${index + 1}'),
                              ),
                            ),
                            onChanged: (value) {
                              setDialogState(() {
                                selectedPeriod = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedTeacherId,
                      decoration: const InputDecoration(
                        labelText: 'Teacher',
                        border: OutlineInputBorder(),
                      ),
                      items: teacherProvider.teachers
                          .map((teacher) => DropdownMenuItem(
                                value: teacher.id,
                                child: Text('${teacher.name} (${teacher.subject})'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedTeacherId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: startTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Start Time (e.g., 9:00)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: endTimeController,
                            decoration: const InputDecoration(
                              labelText: 'End Time (e.g., 9:45)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (classController.text.trim().isEmpty ||
                        subjectController.text.trim().isEmpty ||
                        selectedTeacherId == null ||
                        startTimeController.text.trim().isEmpty ||
                        endTimeController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please fill all fields'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    try {
                      await timetableProvider.addTimetableEntry(
                        className: classController.text.trim(),
                        section: sectionController.text.trim(),
                        dayOfWeek: selectedDay,
                        period: selectedPeriod,
                        subject: subjectController.text.trim(),
                        teacherId: selectedTeacherId!,
                        startTime: startTimeController.text.trim(),
                        endTime: endTimeController.text.trim(),
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Period added successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Add Period'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}