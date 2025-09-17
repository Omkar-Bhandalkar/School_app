enum EventType { event, notice }

class SchoolEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final EventType type;
  final String? targetAudience; // 'all', 'students', 'teachers'
  final DateTime createdAt;

  SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    this.targetAudience,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'type': type.name,
      'targetAudience': targetAudience,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory SchoolEvent.fromMap(Map<String, dynamic> map) {
    return SchoolEvent(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      date: DateTime.fromMillisecondsSinceEpoch(map['date']),
      type: EventType.values.byName(map['type']),
      targetAudience: map['targetAudience'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  bool get isUpcoming {
    return date.isAfter(DateTime.now());
  }

  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
}