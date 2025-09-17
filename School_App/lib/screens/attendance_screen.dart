import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/attendance_provider.dart';
import '../providers/student_provider.dart';
import '../models/models.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().loadStudents();
      context.read<AttendanceProvider>().loadAttendanceForDate(DateTime.now());
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
        title: const Text('Attendance Management'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.check_circle), text: 'Mark Attendance'),
            Tab(icon: Icon(Icons.summarize), text: 'Daily Summary'),
            Tab(icon: Icon(Icons.analytics), text: 'Monthly Report'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MarkAttendanceTab(),
          _DailySummaryTab(),
          _MonthlyReportTab(),
        ],
      ),
    );
  }
}

class _MarkAttendanceTab extends StatefulWidget {
  @override
  State<_MarkAttendanceTab> createState() => _MarkAttendanceTabState();
}

class _MarkAttendanceTabState extends State<_MarkAttendanceTab> {
  String _selectedClass = '';
  List<bool> _attendanceStatus = [];
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Consumer2<StudentProvider, AttendanceProvider>(
      builder: (context, studentProvider, attendanceProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateSelector(attendanceProvider),
              const SizedBox(height: 16),
              _buildClassSelector(studentProvider),
              const SizedBox(height: 16),
              if (_selectedClass.isNotEmpty) ...[
                _buildAttendanceHeader(),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildStudentList(studentProvider),
                ),
                const SizedBox(height: 16),
                _buildActionButtons(studentProvider, attendanceProvider),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDateSelector(AttendanceProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Date',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDate),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                  provider.updateSelectedDate(date);
                }
              },
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassSelector(StudentProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.class_, color: Colors.green),
            const SizedBox(width: 12),
            const Text(
              'Select Class:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButton<String>(
                value: _selectedClass.isEmpty ? null : _selectedClass,
                hint: const Text('Choose a class'),
                isExpanded: true,
                items: provider.uniqueClasses
                    .map((className) => DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value ?? '';
                    _attendanceStatus = [];
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceHeader() {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Expanded(
              flex: 3,
              child: Text(
                'Student Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              child: Text(
                'Present',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const Expanded(
              child: Text(
                'Absent',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList(StudentProvider provider) {
    final students = provider.getStudentsByClass(_selectedClass);
    
    if (students.isEmpty) {
      return const Center(
        child: Text('No students found in this class'),
      );
    }

    // Initialize attendance status if needed
    if (_attendanceStatus.length != students.length) {
      _attendanceStatus = List.filled(students.length, true);
    }

    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 4),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Roll: ${student.rollNo} | Section: ${student.section}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Radio<bool>(
                    value: true,
                    groupValue: _attendanceStatus[index],
                    onChanged: (value) {
                      setState(() {
                        _attendanceStatus[index] = true;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ),
                Expanded(
                  child: Radio<bool>(
                    value: false,
                    groupValue: _attendanceStatus[index],
                    onChanged: (value) {
                      setState(() {
                        _attendanceStatus[index] = false;
                      });
                    },
                    activeColor: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(StudentProvider studentProvider, AttendanceProvider attendanceProvider) {
    final students = studentProvider.getStudentsByClass(_selectedClass);
    final presentCount = _attendanceStatus.where((status) => status).length;
    final absentCount = students.length - presentCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      presentCount.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const Text('Present'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      absentCount.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const Text('Absent'),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${((presentCount / students.length) * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('Attendance'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _attendanceStatus = List.filled(students.length, true);
                      });
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark All Present'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await attendanceProvider.markAttendance(students, _attendanceStatus);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Attendance marked successfully!'),
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
                    icon: const Icon(Icons.save),
                    label: const Text('Save Attendance'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySummaryTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, child) {
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
                      Text(
                        'Daily Summary - ${DateFormat('MMMM d, y').format(provider.selectedDate)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (provider.attendanceRecords.isEmpty)
                        const Center(
                          child: Text(
                            'No attendance records for this date',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Text(
                          'Total Records: ${provider.attendanceRecords.length}',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MonthlyReportTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Attendance Report',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Feature coming soon...\n\nThis will show:\n• Monthly attendance percentage per class\n• Student-wise attendance summary\n• Class-wise comparison charts',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}