import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class AttendanceProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<AttendanceRecord> _attendanceRecords = [];
  DateTime _selectedDate = DateTime.now();
  String _selectedClass = '';
  bool _isLoading = false;

  List<AttendanceRecord> get attendanceRecords => _attendanceRecords;
  DateTime get selectedDate => _selectedDate;
  String get selectedClass => _selectedClass;
  bool get isLoading => _isLoading;

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
    loadAttendanceForDate(date);
  }

  void updateSelectedClass(String className) {
    _selectedClass = className;
    notifyListeners();
  }

  Future<void> loadAttendanceForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _attendanceRecords = await _db.getAttendanceByDate(date);
    } catch (e) {
      debugPrint('Error loading attendance: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAttendance(List<Student> students, List<bool> attendanceStatus) async {
    try {
      for (int i = 0; i < students.length; i++) {
        final record = AttendanceRecord(
          id: _uuid.v4(),
          studentId: students[i].id,
          date: _selectedDate,
          isPresent: attendanceStatus[i],
        );
        await _db.insertAttendanceRecord(record);
      }
      await loadAttendanceForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error marking attendance: $e');
      rethrow;
    }
  }

  Future<double> getAttendancePercentageForStudent(String studentId, DateTime month) async {
    try {
      final startOfMonth = DateTime(month.year, month.month, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      // For now, calculate from loaded records
      final studentRecords = _attendanceRecords
          .where((record) => 
              record.studentId == studentId &&
              record.date.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
              record.date.isBefore(endOfMonth.add(const Duration(days: 1))))
          .toList();
      
      if (studentRecords.isEmpty) return 0.0;
      
      final presentDays = studentRecords.where((r) => r.isPresent).length;
      return (presentDays / studentRecords.length) * 100;
    } catch (e) {
      debugPrint('Error calculating attendance percentage: $e');
      return 0.0;
    }
  }

  Future<Map<String, double>> getClassAttendanceSummary(String className, DateTime month) async {
    try {
      // This would need more complex database queries in a real implementation
      // For now, return sample data
      return {
        'Overall': 85.5,
        'Present Students': 25,
        'Total Students': 30,
      };
    } catch (e) {
      debugPrint('Error getting class attendance summary: $e');
      return {};
    }
  }
}