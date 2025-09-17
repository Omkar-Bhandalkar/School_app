class Student {
  final String id;
  final String name;
  final String className;
  final String section;
  final String rollNo;
  final String contact;
  final String? parentContact;
  final DateTime createdAt;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.section,
    required this.rollNo,
    required this.contact,
    this.parentContact,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'className': className,
      'section': section,
      'rollNo': rollNo,
      'contact': contact,
      'parentContact': parentContact,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      className: map['className'],
      section: map['section'],
      rollNo: map['rollNo'],
      contact: map['contact'],
      parentContact: map['parentContact'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Student copyWith({
    String? id,
    String? name,
    String? className,
    String? section,
    String? rollNo,
    String? contact,
    String? parentContact,
    DateTime? createdAt,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      className: className ?? this.className,
      section: section ?? this.section,
      rollNo: rollNo ?? this.rollNo,
      contact: contact ?? this.contact,
      parentContact: parentContact ?? this.parentContact,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}