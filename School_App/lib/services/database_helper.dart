import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import 'web_database_helper.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;
  static WebDatabaseHelper? _webHelper;

  // Use web helper for web platform
  bool get isWeb => kIsWeb;

  Future<dynamic> get database async {
    if (isWeb) {
      _webHelper ??= WebDatabaseHelper();
      await _webHelper!.initializeSampleData();
      return _webHelper;
    }
    
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'school_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Students table
    await db.execute('''
      CREATE TABLE students(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        className TEXT NOT NULL,
        section TEXT NOT NULL,
        rollNo TEXT NOT NULL,
        contact TEXT NOT NULL,
        parentContact TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Teachers table
    await db.execute('''
      CREATE TABLE teachers(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        subject TEXT NOT NULL,
        contact TEXT NOT NULL,
        email TEXT,
        assignedClasses TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Attendance table
    await db.execute('''
      CREATE TABLE attendance(
        id TEXT PRIMARY KEY,
        studentId TEXT NOT NULL,
        date INTEGER NOT NULL,
        isPresent INTEGER NOT NULL,
        remarks TEXT,
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    // Timetable table
    await db.execute('''
      CREATE TABLE timetable(
        id TEXT PRIMARY KEY,
        className TEXT NOT NULL,
        section TEXT NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        period INTEGER NOT NULL,
        subject TEXT NOT NULL,
        teacherId TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        FOREIGN KEY (teacherId) REFERENCES teachers (id)
      )
    ''');

    // Exams table
    await db.execute('''
      CREATE TABLE exams(
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        date INTEGER NOT NULL,
        className TEXT NOT NULL,
        subject TEXT NOT NULL,
        totalMarks INTEGER NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // Exam Results table
    await db.execute('''
      CREATE TABLE exam_results(
        id TEXT PRIMARY KEY,
        examId TEXT NOT NULL,
        studentId TEXT NOT NULL,
        marksObtained INTEGER NOT NULL,
        grade TEXT,
        remarks TEXT,
        FOREIGN KEY (examId) REFERENCES exams (id),
        FOREIGN KEY (studentId) REFERENCES students (id)
      )
    ''');

    // Events table
    await db.execute('''
      CREATE TABLE events(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date INTEGER NOT NULL,
        type TEXT NOT NULL,
        targetAudience TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');
  }

  // Student CRUD operations
  Future<int> insertStudent(Student student) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).insertStudent(student);
    }
    return await (db as Database).insert('students', student.toMap());
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getStudents();
    }
    final List<Map<String, dynamic>> maps = await (db as Database).query('students');
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<List<Student>> getStudentsByClass(String className) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getStudentsByClass(className);
    }
    final List<Map<String, dynamic>> maps = await (db as Database).query(
      'students',
      where: 'className = ?',
      whereArgs: [className],
    );
    return List.generate(maps.length, (i) => Student.fromMap(maps[i]));
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).updateStudent(student);
    }
    return await (db as Database).update(
      'students',
      student.toMap(),
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(String id) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).deleteStudent(id);
    }
    return await (db as Database).delete(
      'students',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Teacher CRUD operations
  Future<int> insertTeacher(Teacher teacher) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).insertTeacher(teacher);
    }
    return await (db as Database).insert('teachers', teacher.toMap());
  }

  Future<List<Teacher>> getTeachers() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getTeachers();
    }
    final List<Map<String, dynamic>> maps = await (db as Database).query('teachers');
    return List.generate(maps.length, (i) => Teacher.fromMap(maps[i]));
  }

  Future<int> updateTeacher(Teacher teacher) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).updateTeacher(teacher);
    }
    return await (db as Database).update(
      'teachers',
      teacher.toMap(),
      where: 'id = ?',
      whereArgs: [teacher.id],
    );
  }

  Future<int> deleteTeacher(String id) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).deleteTeacher(id);
    }
    return await (db as Database).delete(
      'teachers',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Attendance operations
  Future<int> insertAttendanceRecord(AttendanceRecord record) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).insertAttendanceRecord(record);
    }
    return await (db as Database).insert('attendance', record.toMap());
  }

  Future<List<AttendanceRecord>> getAttendanceByDate(DateTime date) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getAttendanceByDate(date);
    }
    final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final List<Map<String, dynamic>> maps = await (db as Database).query(
      'attendance',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startOfDay, endOfDay],
    );
    return List.generate(maps.length, (i) => AttendanceRecord.fromMap(maps[i]));
  }

  // Events operations
  Future<int> insertEvent(SchoolEvent event) async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).insertEvent(event);
    }
    return await (db as Database).insert('events', event.toMap());
  }

  Future<List<SchoolEvent>> getEvents() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getEvents();
    }
    final List<Map<String, dynamic>> maps = await (db as Database).query('events', orderBy: 'date DESC');
    return List.generate(maps.length, (i) => SchoolEvent.fromMap(maps[i]));
  }

  Future<List<SchoolEvent>> getUpcomingEvents() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getUpcomingEvents();
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final List<Map<String, dynamic>> maps = await (db as Database).query(
      'events',
      where: 'date >= ?',
      whereArgs: [now],
      orderBy: 'date ASC',
      limit: 5,
    );
    return List.generate(maps.length, (i) => SchoolEvent.fromMap(maps[i]));
  }

  // Utility methods
  Future<int> getTotalStudents() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getTotalStudents();
    }
    final result = await (db as Database).rawQuery('SELECT COUNT(*) as count FROM students');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getTotalTeachers() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getTotalTeachers();
    }
    final result = await (db as Database).rawQuery('SELECT COUNT(*) as count FROM teachers');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<double> getTodayAttendancePercentage() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).getTodayAttendancePercentage();
    }
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day).millisecondsSinceEpoch;
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59).millisecondsSinceEpoch;
    
    final totalResult = await (db as Database).rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE date >= ? AND date <= ?',
      [startOfDay, endOfDay]
    );
    final presentResult = await (db as Database).rawQuery(
      'SELECT COUNT(*) as count FROM attendance WHERE date >= ? AND date <= ? AND isPresent = 1',
      [startOfDay, endOfDay]
    );
    
    final total = Sqflite.firstIntValue(totalResult) ?? 0;
    final present = Sqflite.firstIntValue(presentResult) ?? 0;
    
    if (total == 0) return 0.0;
    return (present / total) * 100;
  }

  Future<void> clearAllData() async {
    final db = await database;
    if (isWeb) {
      return await (db as WebDatabaseHelper).clearAllData();
    }
    await (db as Database).delete('students');
    await (db as Database).delete('teachers');
    await (db as Database).delete('attendance');
    await (db as Database).delete('timetable');
    await (db as Database).delete('exams');
    await (db as Database).delete('exam_results');
    await (db as Database).delete('events');
  }
}