import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/course.dart';
import 'services/database_service.dart';
import 'pages/timetable_page.dart';
import 'pages/smart_import_page.dart';
import 'pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CollegeTimetableApp());
}

class CollegeTimetableApp extends StatelessWidget {
  const CollegeTimetableApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '大学生课程表',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
        brightness: Brightness.light,
      ),
      home: const MainHomeScaffold(),
    );
  }
}

class MainHomeScaffold extends StatefulWidget {
  const MainHomeScaffold({super.key});

  @override
  State<MainHomeScaffold> createState() => _MainHomeScaffoldState();
}

class _MainHomeScaffoldState extends State<MainHomeScaffold> {
  static const String _prefStartDateKey = 'semester_start_monday';

  int _currentIndex = 0;
  DateTime _semesterStartDate = DateTime(2026, 8, 31); // 默认2026秋季学期第一周周一
  int? _previewWeek;
  List<Course> _courses = [];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDateStr = prefs.getString(_prefStartDateKey);
      if (savedDateStr != null) {
        final parsed = DateTime.tryParse(savedDateStr);
        if (parsed != null) {
          _semesterStartDate = parsed;
        }
      }
    } catch (_) {}

    await _refreshCourses();
  }

  Future<void> _refreshCourses() async {
    final list = await DatabaseService.instance.getAllCourses();
    if (mounted) {
      setState(() {
        _courses = list;
      });
    }
  }

  Future<void> _updateStartDate(DateTime newDate) async {
    setState(() {
      _semesterStartDate = DateTime(newDate.year, newDate.month, newDate.day);
      _previewWeek = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefStartDateKey, _semesterStartDate.toIso8601String());
    } catch (_) {}
  }

  Future<int> _handleImportCourses(List<Course> imported) async {
    final count = await DatabaseService.instance.insertCoursesBatch(imported);
    await _refreshCourses();
    if (mounted) {
      setState(() {
        _currentIndex = 0; // 导入成功后自动跳转到课程表页面刷新
      });
    }
    return count;
  }

  Future<void> _handleDeleteCourse(int id) async {
    await DatabaseService.instance.deleteCourse(id);
    await _refreshCourses();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已删除该课程'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleClearAllCourses() async {
    await DatabaseService.instance.clearAllCourses();
    await _refreshCourses();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已清空所有课程数据'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TimetablePage(
        semesterStartDate: _semesterStartDate,
        previewWeek: _previewWeek,
        courses: _courses,
        onDeleteCourse: _handleDeleteCourse,
        onSelectPreviewWeek: (w) => setState(() => _previewWeek = w),
      ),
      SmartImportPage(
        onImportCourses: _handleImportCourses,
      ),
      SettingsPage(
        semesterStartDate: _semesterStartDate,
        onUpdateStartDate: _updateStartDate,
        onClearAllCourses: _handleClearAllCourses,
        totalCourseCount: _courses.length,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: '课程表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome_rounded),
            label: '智能导入',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
