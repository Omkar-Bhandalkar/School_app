import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';

class DashboardProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  
  int _totalStudents = 0;
  int _totalTeachers = 0;
  double _todayAttendance = 0.0;
  List<SchoolEvent> _upcomingEvents = [];
  bool _isLoading = false;

  int get totalStudents => _totalStudents;
  int get totalTeachers => _totalTeachers;
  double get todayAttendance => _todayAttendance;
  List<SchoolEvent> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _totalStudents = await _db.getTotalStudents();
      _totalTeachers = await _db.getTotalTeachers();
      _todayAttendance = await _db.getTodayAttendancePercentage();
      _upcomingEvents = await _db.getUpcomingEvents();
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }
}