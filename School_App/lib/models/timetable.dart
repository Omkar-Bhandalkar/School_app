class TimetableEntry {
  final String id;
  final String className;
  final String section;
  final int dayOfWeek; // 1-7 (Monday-Sunday)
  final int period; // 1-8
  final String subject;
  final String teacherId;
  final String startTime;
  final String endTime;

  TimetableEntry({
    required this.id,
    required this.className,
    required this.section,
    required this.dayOfWeek,
    required this.period,
    required this.subject,
    required this.teacherId,
    required this.startTime,
    required this.endTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'className': className,
      'section': section,
      'dayOfWeek': dayOfWeek,
      'period': period,
      'subject': subject,
      'teacherId': teacherId,
      'startTime': startTime,
      'endTime': endTime,
    };
  }

  factory TimetableEntry.fromMap(Map<String, dynamic> map) {
    return TimetableEntry(
      id: map['id'],
      className: map['className'],
      section: map['section'],
      dayOfWeek: map['dayOfWeek'],
      period: map['period'],
      subject: map['subject'],
      teacherId: map['teacherId'],
      startTime: map['startTime'],
      endTime: map['endTime'],
    );
  }
}