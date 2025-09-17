import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class TimetableProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<TimetableEntry> _timetableEntries = [];
  String _selectedClass = '';
  String _selectedSection = '';
  bool _isLoading = false;

  List<TimetableEntry> get timetableEntries => _timetableEntries;
  String get selectedClass => _selectedClass;
  String get selectedSection => _selectedSection;
  bool get isLoading => _isLoading;

  void updateSelectedClass(String className, String section) {
    _selectedClass = className;
    _selectedSection = section;
    notifyListeners();
    loadTimetableForClass(className, section);
  }

  Future<void> loadTimetableForClass(String className, String section) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // In a real implementation, this would query the database
      // For now, we'll create sample data
      _timetableEntries = _generateSampleTimetable(className, section);
    } catch (e) {
      debugPrint('Error loading timetable: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTimetableEntry({
    required String className,
    required String section,
    required int dayOfWeek,
    required int period,
    required String subject,
    required String teacherId,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final entry = TimetableEntry(
        id: _uuid.v4(),
        className: className,
        section: section,
        dayOfWeek: dayOfWeek,
        period: period,
        subject: subject,
        teacherId: teacherId,
        startTime: startTime,
        endTime: endTime,
      );

      // Note: Database insertion would be implemented here
      // await _db.insertTimetableEntry(entry);
      
      _timetableEntries.add(entry);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding timetable entry: $e');
      rethrow;
    }
  }

  Future<void> updateTimetableEntry(TimetableEntry entry) async {
    try {
      // Database update would be implemented here
      final index = _timetableEntries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _timetableEntries[index] = entry;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating timetable entry: $e');
      rethrow;
    }
  }

  Future<void> deleteTimetableEntry(String id) async {
    try {
      // Database deletion would be implemented here
      _timetableEntries.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting timetable entry: $e');
      rethrow;
    }
  }

  List<TimetableEntry> getTimetableForDay(int dayOfWeek) {
    return _timetableEntries
        .where((entry) => entry.dayOfWeek == dayOfWeek)
        .toList()
      ..sort((a, b) => a.period.compareTo(b.period));
  }

  List<TimetableEntry> _generateSampleTimetable(String className, String section) {
    // Generate sample timetable data
    final subjects = ['Math', 'English', 'Science', 'History', 'Geography', 'Art', 'PE', 'Music'];
    final times = [
      {'start': '9:00', 'end': '9:45'},
      {'start': '9:45', 'end': '10:30'},
      {'start': '10:45', 'end': '11:30'},
      {'start': '11:30', 'end': '12:15'},
      {'start': '1:00', 'end': '1:45'},
      {'start': '1:45', 'end': '2:30'},
    ];

    List<TimetableEntry> entries = [];
    
    for (int day = 1; day <= 5; day++) { // Monday to Friday
      for (int period = 1; period <= 6; period++) {
        if (period == 4 && day != 5) continue; // Skip lunch period except Friday
        
        entries.add(TimetableEntry(
          id: _uuid.v4(),
          className: className,
          section: section,
          dayOfWeek: day,
          period: period,
          subject: subjects[(day + period) % subjects.length],
          teacherId: 'teacher_${(day + period) % 3 + 1}',
          startTime: times[period - 1]['start']!,
          endTime: times[period - 1]['end']!,
        ));
      }
    }
    
    return entries;
  }

  String getDayName(int dayOfWeek) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[dayOfWeek];
  }
}