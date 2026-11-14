import 'dart:convert';

class Course {
  final int? id;
  final String courseName;
  final String teacher;
  final int weekday; // 1-7 表示周一至周日，0 代表其它课
  final int startPeriod; // 1-12，0 代表待定
  final int endPeriod; // 1-12，0 代表待定
  final String weeks; // 存 JSON 数组字符串，如 "[4,5,6]"
  final String classroom;

  Course({
    this.id,
    required this.courseName,
    required this.teacher,
    required this.weekday,
    required this.startPeriod,
    required this.endPeriod,
    required this.weeks,
    required this.classroom,
  });

  /// 解析 weeks JSON 字符串为 List<int>，带防崩溃容错
  List<int> get weeksList {
    try {
      final decoded = jsonDecode(weeks);
      if (decoded is List) {
        return decoded
            .map((e) => int.tryParse(e.toString()) ?? -1)
            .where((w) => w > 0)
            .toList();
      }
    } catch (_) {}
    return [];
  }

  /// 判断该课程是否在指定周次上课
  bool isInWeek(int week) {
    return weeksList.contains(week);
  }

  /// 从 JSON Map 安全构建 Course 对象（防崩溃容错）
  factory Course.fromJson(Map<String, dynamic> json) {
    int parseSafeInt(dynamic val, int fallback) {
      if (val is int) return val;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val.trim()) ?? fallback;
      return fallback;
    }

    String parseWeeksString(dynamic rawWeeks) {
      if (rawWeeks is String) {
        try {
          final parsed = jsonDecode(rawWeeks);
          if (parsed is List) {
            return jsonEncode(
              parsed.map((e) => parseSafeInt(e, 0)).where((e) => e > 0).toList(),
            );
          }
        } catch (_) {}
        return '[]';
      } else if (rawWeeks is List) {
        final cleanList = rawWeeks
            .map((e) => parseSafeInt(e, 0))
            .where((e) => e > 0)
            .toList();
        return jsonEncode(cleanList);
      }
      return '[]';
    }

    int wd = parseSafeInt(json['weekday'], 0);
    if (wd < 0 || wd > 7) wd = 0;

    int sp = parseSafeInt(json['startPeriod'], 0);
    int ep = parseSafeInt(json['endPeriod'], sp);
    if (wd == 0 || sp <= 0 || sp > 12) {
      wd = 0;
      sp = 0;
      ep = 0;
    } else {
      if (ep < sp) ep = sp;
      if (ep > 12) ep = 12;
    }

    return Course(
      id: json['id'] != null ? parseSafeInt(json['id'], 0) : null,
      courseName: (json['courseName']?.toString() ?? '未命名课程').trim(),
      teacher: (json['teacher']?.toString() ?? '未知教师').trim(),
      weekday: wd,
      startPeriod: sp,
      endPeriod: ep,
      weeks: parseWeeksString(json['weeks']),
      classroom: (json['classroom']?.toString() ?? '待定').trim(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'courseName': courseName,
      'teacher': teacher,
      'weekday': weekday,
      'startPeriod': startPeriod,
      'endPeriod': endPeriod,
      'weeks': weeks,
      'classroom': classroom,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      courseName: map['courseName'] as String? ?? '未命名课程',
      teacher: map['teacher'] as String? ?? '未知教师',
      weekday: map['weekday'] as int? ?? 0,
      startPeriod: map['startPeriod'] as int? ?? 0,
      endPeriod: map['endPeriod'] as int? ?? 0,
      weeks: map['weeks'] as String? ?? '[]',
      classroom: map['classroom'] as String? ?? '待定',
    );
  }
}
