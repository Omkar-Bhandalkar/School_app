import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../services/database_helper.dart';
import '../providers/student_provider.dart';
import '../providers/teacher_provider.dart';
import '../models/models.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _databasePath = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadDatabaseInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadDatabaseInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get database path
      final dbPath = await getDatabasesPath();
      final fullPath = join(dbPath, 'school_app.db');
      setState(() {
        _databasePath = fullPath;
      });
    } catch (e) {
      setState(() {
        _databasePath = 'Web/In-Memory Database';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Viewer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Info'),
            Tab(text: 'Students'),
            Tab(text: 'Teachers'),
            Tab(text: 'Attendance'),
            Tab(text: 'Events'),
            Tab(text: 'Export'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _DatabaseInfoTab(databasePath: _databasePath),
                _StudentsDataTab(),
                _TeachersDataTab(),
                _AttendanceDataTab(),
                _EventsDataTab(),
                _ExportDataTab(databasePath: _databasePath),
              ],
            ),
    );
  }

  void _refreshData() {
    // Refresh data when user taps refresh button
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
      
      // Reload student and teacher data
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      
      _loadDatabaseInfo();
    }
  }
}

class _DatabaseInfoTab extends StatelessWidget {
  final String databasePath;

  const _DatabaseInfoTab({required this.databasePath});

  @override
  Widget build(BuildContext context) {
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
                  const Row(
                    children: [
                      Icon(Icons.storage, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Database Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Database Type', databasePath.contains('Web') ? 'In-Memory (Web)' : 'SQLite'),
                  _buildInfoRow('Database Path', databasePath),
                  _buildInfoRow('Database File', databasePath.contains('Web') ? 'N/A (Browser Memory)' : 'school_app.db'),
                  _buildInfoRow('Platform', databasePath.contains('Web') ? 'Web Browser' : 'Mobile/Desktop'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.table_chart, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Database Tables',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTableInfo('students', 'Student information and class details'),
                  _buildTableInfo('teachers', 'Teacher profiles and subject assignments'),
                  _buildTableInfo('attendance', 'Daily attendance records'),
                  _buildTableInfo('timetable', 'Class schedules and periods'),
                  _buildTableInfo('exams', 'Exam schedules and details'),
                  _buildTableInfo('exam_results', 'Student exam results and grades'),
                  _buildTableInfo('events', 'School events and notices'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label + ':',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableInfo(String tableName, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          const Icon(Icons.table_rows, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              tableName,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentsDataTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StudentProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.school, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Students Data (${provider.students.length} records)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: provider.students.isEmpty
                    ? const Center(
                        child: Text(
                          'No student data found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.students.length,
                        itemBuilder: (context, index) {
                          final student = provider.students[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Text(
                                  student.rollNo,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                              title: Text(student.name),
                              subtitle: Text('${student.className} - ${student.section}'),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDataRow('ID', student.id),
                                      _buildDataRow('Class', student.className),
                                      _buildDataRow('Section', student.section),
                                      _buildDataRow('Roll No', student.rollNo),
                                      _buildDataRow('Contact', student.contact),
                                      _buildDataRow('Parent Contact', student.parentContact ?? 'N/A'),
                                      _buildDataRow('Created At', student.createdAt.toString()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeachersDataTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        'Teachers Data (${provider.teachers.length} records)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: provider.teachers.isEmpty
                    ? const Center(
                        child: Text(
                          'No teacher data found',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: provider.teachers.length,
                        itemBuilder: (context, index) {
                          final teacher = provider.teachers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 4),
                            child: ExpansionTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.green,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(teacher.name),
                              subtitle: Text(teacher.subject),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildDataRow('ID', teacher.id),
                                      _buildDataRow('Subject', teacher.subject),
                                      _buildDataRow('Contact', teacher.contact),
                                      _buildDataRow('Email', teacher.email ?? 'N/A'),
                                      _buildDataRow('Assigned Classes', teacher.assignedClasses.join(', ')),
                                      _buildDataRow('Created At', teacher.createdAt.toString()),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label + ':',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDataTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Attendance Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Attendance records will be shown here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventsDataTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Events Data',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Events and notices will be shown here',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportDataTab extends StatelessWidget {
  final String databasePath;

  const _ExportDataTab({required this.databasePath});

  @override
  Widget build(BuildContext context) {
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
                  const Row(
                    children: [
                      Icon(Icons.download, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Export Database',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Database Location:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    databasePath,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'How to Access Your Database:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (databasePath.contains('Web'))
                    const Text(
                      '• Web: Data is stored in browser memory only\n'
                      '• Use browser developer tools to inspect data\n'
                      '• Data will be lost when browser is closed',
                      style: TextStyle(fontSize: 12),
                    )
                  else
                    const Text(
                      '• Mobile: Use SQLite viewer apps\n'
                      '• Desktop: Use DB Browser for SQLite\n'
                      '• Copy the database file from the path above\n'
                      '• File name: school_app.db',
                      style: TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Recommended Tools',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildToolRow('DB Browser for SQLite', 'Desktop SQLite viewer and editor'),
                  _buildToolRow('SQLite Expert', 'Professional SQLite management tool'),
                  _buildToolRow('Android SQLite Viewer', 'For viewing on Android devices'),
                  _buildToolRow('VS Code SQLite Extension', 'SQLite viewer for VS Code'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolRow(String toolName, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.build, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toolName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}