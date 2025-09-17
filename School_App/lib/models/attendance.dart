class AttendanceRecord {
  final String id;
  final String studentId;
  final DateTime date;
  final bool isPresent;
  final String? remarks;

  AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.date,
    required this.isPresent,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'date': date.millisecondsSinceEpoch,
      'isPresent': isPresent ? 1 : 0,
      'remarks': remarks,
    };
  }

  factory AttendanceRecord.fromMap(Map<String, dynamic> map) {
    return AttendanceRecord(
      id: map['id'],
      studentId: map['studentId'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      isPresent: map['isPresent'] == 1,
      remarks: map['remarks'],
    );
  }
}

class DailyAttendance {
  final DateTime date;
  final String className;
  final List<AttendanceRecord> records;

  DailyAttendance({
    required this.date,
    required this.className,
    required this.records,
  });

  double get attendancePercentage {
    if (records.isEmpty) return 0.0;
    final presentCount = records.where((r) => r.isPresent).length;
    return (presentCount / records.length) * 100;
  }
}