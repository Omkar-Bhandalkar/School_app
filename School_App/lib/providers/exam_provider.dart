import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/database_helper.dart';
import 'package:uuid/uuid.dart';

class ExamProvider with ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();
  
  List<Exam> _exams = [];
  List<ExamResult> _examResults = [];
  bool _isLoading = false;

  List<Exam> get exams => _exams;
  List<ExamResult> get examResults => _examResults;
  bool get isLoading => _isLoading;

  Future<void> loadExams() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // In a real implementation, this would query the database
      // For now, we'll create sample data
      _exams = _generateSampleExams();
    } catch (e) {
      debugPrint('Error loading exams: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadExamResults(String examId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // In a real implementation, this would query the database
      _examResults = _generateSampleResults(examId);
    } catch (e) {
      debugPrint('Error loading exam results: $e');
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addExam({
    required String name,
    required DateTime date,
    required String className,
    required String subject,
    required int totalMarks,
  }) async {
    try {
      final exam = Exam(
        id: _uuid.v4(),
        name: name,
        date: date,
        className: className,
        subject: subject,
        totalMarks: totalMarks,
        createdAt: DateTime.now(),
      );

      // Database insertion would be implemented here
      _exams.add(exam);
      _exams.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding exam: $e');
      rethrow;
    }
  }

  Future<void> updateExam(Exam exam) async {
    try {
      final index = _exams.indexWhere((e) => e.id == exam.id);
      if (index != -1) {
        _exams[index] = exam;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating exam: $e');
      rethrow;
    }
  }

  Future<void> deleteExam(String id) async {
    try {
      _exams.removeWhere((e) => e.id == id);
      _examResults.removeWhere((r) => r.examId == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting exam: $e');
      rethrow;
    }
  }

  Future<void> enterMarks({
    required String examId,
    required String studentId,
    required int marksObtained,
    String? grade,
    String? remarks,
  }) async {
    try {
      final result = ExamResult(
        id: _uuid.v4(),
        examId: examId,
        studentId: studentId,
        marksObtained: marksObtained,
        grade: grade,
        remarks: remarks,
      );

      // Check if result already exists and update, otherwise add
      final existingIndex = _examResults.indexWhere(
        (r) => r.examId == examId && r.studentId == studentId,
      );

      if (existingIndex != -1) {
        _examResults[existingIndex] = result.copyWith(id: _examResults[existingIndex].id);
      } else {
        _examResults.add(result);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error entering marks: $e');
      rethrow;
    }
  }

  List<ExamResult> getResultsForExam(String examId) {
    return _examResults.where((r) => r.examId == examId).toList();
  }

  List<ExamResult> getResultsForStudent(String studentId) {
    return _examResults.where((r) => r.studentId == studentId).toList();
  }

  double getClassAverage(String examId) {
    final results = getResultsForExam(examId);
    if (results.isEmpty) return 0.0;
    
    final totalMarks = results.fold(0, (sum, result) => sum + result.marksObtained);
    return totalMarks / results.length;
  }

  Map<String, int> getGradeDistribution(String examId) {
    final results = getResultsForExam(examId);
    final distribution = <String, int>{
      'A+': 0, 'A': 0, 'B+': 0, 'B': 0, 'C+': 0, 'C': 0, 'D': 0, 'F': 0,
    };

    for (final result in results) {
      final grade = result.grade ?? _calculateGrade(result.marksObtained, 100);
      distribution[grade] = (distribution[grade] ?? 0) + 1;
    }

    return distribution;
  }

  String _calculateGrade(int marks, int totalMarks) {
    final percentage = (marks / totalMarks) * 100;
    if (percentage >= 95) return 'A+';
    if (percentage >= 90) return 'A';
    if (percentage >= 85) return 'B+';
    if (percentage >= 80) return 'B';
    if (percentage >= 75) return 'C+';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  List<Exam> _generateSampleExams() {
    return [
      Exam(
        id: '1',
        name: 'Mid-Term Mathematics',
        date: DateTime.now().add(const Duration(days: 7)),
        className: '10th',
        subject: 'Mathematics',
        totalMarks: 100,
        createdAt: DateTime.now(),
      ),
      Exam(
        id: '2',
        name: 'Unit Test English',
        date: DateTime.now().add(const Duration(days: 14)),
        className: '9th',
        subject: 'English',
        totalMarks: 80,
        createdAt: DateTime.now(),
      ),
      Exam(
        id: '3',
        name: 'Science Practical',
        date: DateTime.now().subtract(const Duration(days: 5)),
        className: '8th',
        subject: 'Science',
        totalMarks: 50,
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<ExamResult> _generateSampleResults(String examId) {
    // Generate sample results
    return [
      ExamResult(
        id: '1',
        examId: examId,
        studentId: 'student_1',
        marksObtained: 85,
        grade: 'B+',
      ),
      ExamResult(
        id: '2',
        examId: examId,
        studentId: 'student_2',
        marksObtained: 92,
        grade: 'A',
      ),
      ExamResult(
        id: '3',
        examId: examId,
        studentId: 'student_3',
        marksObtained: 78,
        grade: 'C+',
      ),
    ];
  }
}