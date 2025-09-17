import 'package:flutter/foundation.dart';
import '../models/models.dart';

// Mock database helper for web platform
class WebDatabaseHelper {
  static final WebDatabaseHelper _instance = WebDatabaseHelper._internal();
  factory WebDatabaseHelper() => _instance;
  WebDatabaseHelper._internal();

  // In-memory storage for web
  List<Student> _students = [];
  List<Teacher> _teachers = [];
  List<AttendanceRecord> _attendanceRecords = [];
  List<TimetableEntry> _timetableEntries = [];
  List<Exam> _exams = [];
  List<ExamResult> _examResults = [];
  List<SchoolEvent> _events = [];

  // Student operations
  Future<int> insertStudent(Student student) async {
    _students.add(student);
    return 1;
  }

  Future<List<Student>> getStudents() async {
    return List.from(_students);
  }

  Future<List<Student>> getStudentsByClass(String className) async {
    return _students.where((student) => student.className == className).toList();
  }

  Future<int> updateStudent(Student student) async {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      return 1;
    }
    return 0;
  }

  Future<int> deleteStudent(String id) async {
    final initialLength = _students.length;
    _students.removeWhere((student) => student.id == id);
    return initialLength - _students.length;
  }

  // Teacher operations
  Future<int> insertTeacher(Teacher teacher) async {
    _teachers.add(teacher);
    return 1;
  }

  Future<List<Teacher>> getTeachers() async {
    return List.from(_teachers);
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final index = _teachers.indexWhere((t) => t.id == teacher.id);
    if (index != -1) {
      _teachers[index] = teacher;
      return 1;
    }
    return 0;
  }

  Future<int> deleteTeacher(String id) async {
    final initialLength = _teachers.length;
    _teachers.removeWhere((teacher) => teacher.id == id);
    return initialLength - _teachers.length;
  }

  // Attendance operations
  Future<int> insertAttendanceRecord(AttendanceRecord record) async {
    _attendanceRecords.add(record);
    return 1;
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
    
    return _attendanceRecords
        .where((record) => 
            record.date.isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
            record.date.isBefore(endOfDay.add(const Duration(seconds: 1))))
        .toList();
  }

  // Events operations
  Future<int> insertEvent(SchoolEvent event) async {
    _events.add(event);
    return 1;
  }

  Future<List<SchoolEvent>> getEvents() async {
    final sortedEvents = List<SchoolEvent>.from(_events);
    sortedEvents.sort((a, b) => b.date.compareTo(a.date));
    return sortedEvents;
  }

  Future<List<SchoolEvent>> getUpcomingEvents() async {
    final now = DateTime.now();
    final upcomingEvents = _events
        .where((event) => event.date.isAfter(now))
        .toList();
    upcomingEvents.sort((a, b) => a.date.compareTo(b.date));
    return upcomingEvents.take(5).toList();
  }

  // Utility methods
  Future<int> getTotalStudents() async {
    return _students.length;
  }

  Future<int> getTotalTeachers() async {
    return _teachers.length;
  }

  Future<double> getTodayAttendancePercentage() async {
    final today = DateTime.now();
    final todayRecords = await getAttendanceByDate(today);
    
    if (todayRecords.isEmpty) return 0.0;
    
    final presentCount = todayRecords.where((record) => record.isPresent).length;
    return (presentCount / todayRecords.length) * 100;
  }

  Future<void> clearAllData() async {
    _students.clear();
    _teachers.clear();
    _attendanceRecords.clear();
    _timetableEntries.clear();
    _exams.clear();
    _examResults.clear();
    _events.clear();
  }

  // Initialize with sample data
  Future<void> initializeSampleData() async {
    if (_students.isEmpty) {
      // Add sample students
      await insertStudent(Student(
        id: '1',
        name: 'John Doe',
        className: '10th',
        section: 'A',
        rollNo: '001',
        contact: '+1234567890',
        createdAt: DateTime.now(),
      ));
      
      await insertStudent(Student(
        id: '2',
        name: 'Jane Smith',
        className: '10th',
        section: 'A',
        rollNo: '002',
        contact: '+1234567891',
        createdAt: DateTime.now(),
      ));

      // Add sample teachers
      await insertTeacher(Teacher(
        id: '1',
        name: 'Dr. Alice Johnson',
        subject: 'Mathematics',
        contact: '+1234567892',
        email: 'alice@school.com',
        assignedClasses: ['10th', '9th'],
        createdAt: DateTime.now(),
      ));

      await insertTeacher(Teacher(
        id: '2',
        name: 'Mr. Bob Wilson',
        subject: 'English',
        contact: '+1234567893',
        email: 'bob@school.com',
        assignedClasses: ['10th'],
        createdAt: DateTime.now(),
      ));

      // Add sample events
      await insertEvent(SchoolEvent(
        id: '1',
        title: 'Annual Sports Day',
        description: 'Annual sports competition for all classes',
        date: DateTime.now().add(const Duration(days: 15)),
        type: EventType.event,
        targetAudience: 'all',
        createdAt: DateTime.now(),
      ));

      await insertEvent(SchoolEvent(
        id: '2',
        title: 'Parent-Teacher Meeting',
        description: 'Monthly meeting with parents',
        date: DateTime.now().add(const Duration(days: 7)),
        type: EventType.notice,
        targetAudience: 'all',
        createdAt: DateTime.now(),
      ));
    }
  }
}