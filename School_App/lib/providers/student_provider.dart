import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class StudentProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<Student> _students = [];
  bool _isLoading = false;

  List<Student> get students => _students;
  bool get isLoading => _isLoading;

  Future<void> loadStudents() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _students = await _db.getStudents();
    } catch (e) {
      debugPrint('Error loading students: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addStudent({
    required String name,
    required String className,
    required String section,
    required String rollNo,
    required String contact,
    String? parentContact,
  }) async {
    final student = Student(
      id: _uuid.v4(),
      name: name,
      className: className,
      section: section,
      rollNo: rollNo,
      contact: contact,
      parentContact: parentContact,
      createdAt: DateTime.now(),
    );

    await _db.insertStudent(student);
    await loadStudents();
  }

  Future<void> updateStudent(Student student) async {
    await _db.updateStudent(student);
    await loadStudents();
  }

  Future<void> deleteStudent(String id) async {
    await _db.deleteStudent(id);
    await loadStudents();
  }

  List<Student> getStudentsByClass(String className) {
    return _students.where((student) => student.className == className).toList();
  }

  List<String> get uniqueClasses {
    return _students.map((s) => s.className).toSet().toList()..sort();
  }
}