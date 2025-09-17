class Teacher {
  final String id;
  final String name;
  final String subject;
  final String contact;
  final String? email;
  final List<String> assignedClasses;
  final DateTime createdAt;

  Teacher({
    required this.id,
    required this.name,
    required this.subject,
    required this.contact,
    this.email,
    required this.assignedClasses,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'subject': subject,
      'contact': contact,
      'email': email,
      'assignedClasses': assignedClasses.join(','),
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Teacher.fromMap(Map<String, dynamic> map) {
    return Teacher(
      id: map['id'],
      name: map['name'],
      subject: map['subject'],
      contact: map['contact'],
      email: map['email'],
      assignedClasses: map['assignedClasses'] != null 
          ? map['assignedClasses'].split(',').cast<String>()
          : <String>[],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Teacher copyWith({
    String? id,
    String? name,
    String? subject,
    String? contact,
    String? email,
    List<String>? assignedClasses,
    DateTime? createdAt,
  }) {
    return Teacher(
      id: id ?? this.id,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}