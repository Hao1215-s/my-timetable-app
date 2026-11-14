class ScheduleConstants {
  /// 固定作息时间常量 Map (第1到第12节)
  static const Map<int, String> periodTimes = {
    1: '08:00-08:50',
    2: '08:55-09:45',
    3: '10:00-10:50',
    4: '10:55-11:45',
    5: '13:45-14:35',
    6: '14:40-15:30',
    7: '15:45-16:35',
    8: '16:40-17:30',
    9: '18:30-19:20',
    10: '19:25-20:15',
    11: '20:30-21:20',
    12: '21:25-22:15',
  };

  /// 星期名称映射
  static const Map<int, String> weekdayNames = {
    1: '周一',
    2: '周二',
    3: '周三',
    4: '周四',
    5: '周五',
    6: '周六',
    7: '周日',
    0: '其它/待定',
  };

  /// AI 解析提示词（严格按需求硬编码）
  static const String aiPromptText =
      '请帮我将以下课程表图片转换为标准 JSON 格式。请严格输出一个 JSON 数组，不要包含任何其他说明文字。\n'
      '字段说明：\n'
      '- courseName: 课程名称\n'
      '- teacher: 教师姓名\n'
      '- weekday: 星期几(1-7的整数)\n'
      '- startPeriod: 开始节次(整数)\n'
      '- endPeriod: 结束节次(整数)\n'
      '- weeks: 包含具体周数的数组(如果是单双周请手动展开，如[5,7,9])\n'
      '- classroom: 教室\n\n'
      '注意：如果不在正常表格内的课(如体育课)，请将 weekday 设为 0，startPeriod 和 endPeriod 也设为 0。\n\n'
      '请解析我接下来发送的图片：';

  /// 预置默认课程表 JSON 字符串
  static const String defaultCoursesJson = '''[
  {
    "courseName": "数学分析 (1)",
    "teacher": "苏颖",
    "weekday": 1,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    "classroom": "B21"
  },
  {
    "courseName": "计算思维与人工智能A",
    "teacher": "李雪",
    "weekday": 1,
    "startPeriod": 5,
    "endPeriod": 6,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    "classroom": "B11"
  },
  {
    "courseName": "代数与几何x",
    "teacher": "赵晓雪",
    "weekday": 1,
    "startPeriod": 7,
    "endPeriod": 8,
    "weeks": [3],
    "classroom": "B12"
  },
  {
    "courseName": "陶笛演奏",
    "teacher": "王超",
    "weekday": 1,
    "startPeriod": 9,
    "endPeriod": 10,
    "weeks": [7, 8, 9, 10],
    "classroom": "电机楼30029"
  },
  {
    "courseName": "陶笛演奏",
    "teacher": "王超",
    "weekday": 1,
    "startPeriod": 11,
    "endPeriod": 12,
    "weeks": [7, 8, 9, 10],
    "classroom": "电机楼30029"
  },
  {
    "courseName": "代数与几何x",
    "teacher": "赵晓雪",
    "weekday": 2,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    "classroom": "B307"
  },
  {
    "courseName": "公共汉语 (1)",
    "teacher": "丛蕊",
    "weekday": 2,
    "startPeriod": 7,
    "endPeriod": 8,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
    "classroom": "B617"
  },
  {
    "courseName": "数学分析 (1)",
    "teacher": "苏颖",
    "weekday": 3,
    "startPeriod": 1,
    "endPeriod": 2,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    "classroom": "B21"
  },
  {
    "courseName": "代数与几何x",
    "teacher": "赵晓雪",
    "weekday": 4,
    "startPeriod": 1,
    "endPeriod": 2,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    "classroom": "B22"
  },
  {
    "courseName": "代数与几何x",
    "teacher": "赵晓雪",
    "weekday": 4,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [3],
    "classroom": "B12"
  },
  {
    "courseName": "公共汉语 (1)",
    "teacher": "丛蕊",
    "weekday": 4,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
    "classroom": "B617"
  },
  {
    "courseName": "计算思维与人工智能A",
    "teacher": "李雪",
    "weekday": 4,
    "startPeriod": 5,
    "endPeriod": 6,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16],
    "classroom": "B41"
  },
  {
    "courseName": "陶笛演奏",
    "teacher": "王超",
    "weekday": 4,
    "startPeriod": 9,
    "endPeriod": 10,
    "weeks": [7, 8, 9, 10],
    "classroom": "电机楼30029"
  },
  {
    "courseName": "陶笛演奏",
    "teacher": "王超",
    "weekday": 4,
    "startPeriod": 11,
    "endPeriod": 12,
    "weeks": [7, 8, 9, 10],
    "classroom": "电机楼30029"
  },
  {
    "courseName": "数学分析 (1)",
    "teacher": "苏颖",
    "weekday": 5,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
    "classroom": "B21"
  },
  {
    "courseName": "代数与几何x",
    "teacher": "赵晓雪",
    "weekday": 5,
    "startPeriod": 5,
    "endPeriod": 6,
    "weeks": [13, 14, 15, 16],
    "classroom": "B11"
  },
  {
    "courseName": "数学分析 (1)",
    "teacher": "苏颖",
    "weekday": 5,
    "startPeriod": 7,
    "endPeriod": 8,
    "weeks": [3],
    "classroom": "B21"
  },
  {
    "courseName": "从灵感到造物：巧用AI做文创",
    "teacher": "王未",
    "weekday": 6,
    "startPeriod": 1,
    "endPeriod": 2,
    "weeks": [7, 8],
    "classroom": "正心306"
  },
  {
    "courseName": "从灵感到造物：巧用AI做文创",
    "teacher": "王未",
    "weekday": 6,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [7, 8],
    "classroom": "正心306"
  },
  {
    "courseName": "从灵感到造物：巧用AI做文创",
    "teacher": "王未",
    "weekday": 7,
    "startPeriod": 1,
    "endPeriod": 2,
    "weeks": [7, 8],
    "classroom": "正心306"
  },
  {
    "courseName": "从灵感到造物：巧用AI做文创",
    "teacher": "王未",
    "weekday": 7,
    "startPeriod": 3,
    "endPeriod": 4,
    "weeks": [7, 8],
    "classroom": "正心306"
  },
  {
    "courseName": "体育 (1)",
    "teacher": "（未注明）",
    "weekday": 0,
    "startPeriod": 0,
    "endPeriod": 0,
    "weeks": [6, 8, 10, 12, 14, 16],
    "classroom": "一校区正心楼乒乓球室"
  }
]''';
}
