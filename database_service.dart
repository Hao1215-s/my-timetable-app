import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/course.dart';
import '../constants/schedule_constants.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('courses_schedule.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        courseName TEXT NOT NULL,
        teacher TEXT NOT NULL,
        weekday INTEGER NOT NULL,
        startPeriod INTEGER NOT NULL,
        endPeriod INTEGER NOT NULL,
        weeks TEXT NOT NULL,
        classroom TEXT NOT NULL
      )
    ''');

    // 首次安装默认写入用户的 22 条课程记录
    try {
      final List<dynamic> defaultList =
          jsonDecode(ScheduleConstants.defaultCoursesJson);
      final batch = db.batch();
      for (final item in defaultList) {
        if (item is Map<String, dynamic>) {
          final course = Course.fromJson(item);
          batch.insert('courses', course.toMap());
        }
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }

  Future<List<Course>> getAllCourses() async {
    try {
      final db = await instance.database;
      final result = await db.query('courses', orderBy: 'weekday ASC, startPeriod ASC');
      return result.map((json) => Course.fromMap(json)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> insertCoursesBatch(List<Course> courses) async {
    try {
      final db = await instance.database;
      final batch = db.batch();
      for (final course in courses) {
        batch.insert('courses', course.toMap());
      }
      await batch.commit(noResult: true);
      return courses.length;
    } catch (_) {
      return 0;
    }
  }

  Future<int> deleteCourse(int id) async {
    try {
      final db = await instance.database;
      return await db.delete('courses', where: 'id = ?', whereArgs: [id]);
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearAllCourses() async {
    try {
      final db = await instance.database;
      await db.delete('courses');
    } catch (_) {}
  }
}
