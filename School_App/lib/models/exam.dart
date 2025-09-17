class Exam {
  final String id;
  final String name;
  final DateTime date;
  final String className;
  final String subject;
  final int totalMarks;
  final DateTime createdAt;

  Exam({
    required this.id,
    required this.name,
    required this.date,
    required this.className,
    required this.subject,
    required this.totalMarks,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.millisecondsSinceEpoch,
      'className': className,
      'subject': subject,
      'totalMarks': totalMarks,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Exam.fromMap(Map<String, dynamic> map) {
    return Exam(
      id: map['id'],
      name: map['name'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      className: map['className'],
      subject: map['subject'],
      totalMarks: map['totalMarks'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }
}

class ExamResult {
  final String id;
  final String examId;
  final String studentId;
  final int marksObtained;
  final String? grade;
  final String? remarks;

  ExamResult({
    required this.id,
    required this.examId,
    required this.studentId,
    required this.marksObtained,
    this.grade,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'examId': examId,
      'studentId': studentId,
      'marksObtained': marksObtained,
      'grade': grade,
      'remarks': remarks,
    };
  }

  factory ExamResult.fromMap(Map<String, dynamic> map) {
    return ExamResult(
      id: map['id'],
      examId: map['examId'],
      studentId: map['studentId'],
      marksObtained: map['marksObtained'],
      grade: map['grade'],
      remarks: map['remarks'],
    );
  }

  double getPercentage(int totalMarks) {
    if (totalMarks == 0) return 0.0;
    return (marksObtained / totalMarks) * 100;
  }

  ExamResult copyWith({
    String? id,
    String? examId,
    String? studentId,
    int? marksObtained,
    String? grade,
    String? remarks,
  }) {
    return ExamResult(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      studentId: studentId ?? this.studentId,
      marksObtained: marksObtained ?? this.marksObtained,
      grade: grade ?? this.grade,
      remarks: remarks ?? this.remarks,
    );
  }
}