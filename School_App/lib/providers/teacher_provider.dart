import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class TeacherProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<Teacher> _teachers = [];
  bool _isLoading = false;

  List<Teacher> get teachers => _teachers;
  bool get isLoading => _isLoading;

  Future<void> loadTeachers() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _teachers = await _db.getTeachers();
    } catch (e) {
      debugPrint('Error loading teachers: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTeacher({
    required String name,
    required String subject,
    required String contact,
    String? email,
    required List<String> assignedClasses,
  }) async {
    final teacher = Teacher(
      id: _uuid.v4(),
      name: name,
      subject: subject,
      contact: contact,
      email: email,
      assignedClasses: assignedClasses,
      createdAt: DateTime.now(),
    );

    await _db.insertTeacher(teacher);
    await loadTeachers();
  }

  Future<void> updateTeacher(Teacher teacher) async {
    await _db.updateTeacher(teacher);
    await loadTeachers();
  }

  Future<void> deleteTeacher(String id) async {
    await _db.deleteTeacher(id);
    await loadTeachers();
  }

  Teacher? getTeacherById(String id) {
    try {
      return _teachers.firstWhere((teacher) => teacher.id == id);
    } catch (e) {
      return null;
    }
  }
}