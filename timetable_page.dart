import 'package:flutter/material.dart';
import '../constants/schedule_constants.dart';
import '../models/course.dart';

class TimetablePage extends StatelessWidget {
  final DateTime semesterStartDate;
  final int? previewWeek;
  final List<Course> courses;
  final Function(int) onDeleteCourse;
  final Function(int?) onSelectPreviewWeek;

  const TimetablePage({
    super.key,
    required this.semesterStartDate,
    required this.previewWeek,
    required this.courses,
    required this.onDeleteCourse,
    required this.onSelectPreviewWeek,
  });

  /// 严格按照公式计算当前周次:
  /// int currentWeek = (当前日期 - 设定日期).inDays ~/ 7 + 1
  int _calculateAutoWeek() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
      semesterStartDate.year,
      semesterStartDate.month,
      semesterStartDate.day,
    );
    final diffDays = today.difference(start).inDays;
    if (diffDays < 0) {
      return 0; // 早于设定日期 -> 未开学
    }
    return (diffDays ~/ 7) + 1;
  }

  String _getHeaderStatusText(int autoWeek, int activeWeek) {
    if (previewWeek != null) {
      return '第 $activeWeek 周 (手动预览)';
    }
    if (autoWeek <= 0) {
      return '未开学';
    }
    if (autoWeek > 20) {
      return '学期已结束';
    }
    return '第 $autoWeek 周';
  }

  Color _getCourseColor(String courseName, BuildContext context) {
    final palette = [
      const Color(0xFF4F46E5),
      const Color(0xFF0891B2),
      const Color(0xFF059669),
      const Color(0xFFD97706),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
      const Color(0xFFDB2777),
      const Color(0xFF2563EB),
    ];
    final hash = courseName.codeUnits.fold(0, (prev, elem) => prev + elem);
    return palette[hash % palette.length];
  }

  void _showCourseDetailSheet(BuildContext context, Course course) {
    final weeks = course.weeksList;
    final weeksStr = weeks.isEmpty ? '无' : '第 ${weeks.join(', ')} 周';
    final periodStr = course.weekday == 0
        ? '时间待定 / 自由安排'
        : '${ScheduleConstants.weekdayNames[course.weekday]} 第${course.startPeriod}-${course.endPeriod}节 '
          '(${ScheduleConstants.periodTimes[course.startPeriod]?.split('-').first ?? ''} - '
          '${ScheduleConstants.periodTimes[course.endPeriod]?.split('-').last ?? ''})';

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.courseName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow(Icons.person_outline, '任课教师', course.teacher),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.location_on_outlined, '上课教室', course.classroom),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.access_time_outlined, '上课节次', periodStr),
                const SizedBox(height: 10),
                _buildDetailRow(Icons.date_range_outlined, '上课周次', weeksStr),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.red.shade50,
                      foregroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      if (course.id != null) {
                        onDeleteCourse(course.id!);
                      }
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('删除该课程'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.indigo),
        const SizedBox(width: 10),
        Text(
          '$label：',
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final autoWeek = _calculateAutoWeek();
    final activeWeek = previewWeek ?? (autoWeek >= 1 && autoWeek <= 20 ? autoWeek : -1);
    final headerText = _getHeaderStatusText(autoWeek, activeWeek);

    // 过滤当前周次包含的课程
    final currentWeekRegularCourses = courses
        .where((c) => c.weekday >= 1 && c.weekday <= 7 && activeWeek > 0 && c.isInWeek(activeWeek))
        .toList();

    // 底部展示 weekday == 0 的其它课程（当前周有效或展示全部待定课程并标注本周状态）
    final otherCourses = courses
        .where((c) => c.weekday == 0 && (activeWeek <= 0 || c.isInWeek(activeWeek)))
        .toList();

    const double periodHeight = 64.0;
    const double leftColWidth = 68.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            Text(
              '开学第一周周一: ${semesterStartDate.year}-${semesterStartDate.month.toString().padLeft(2, '0')}-${semesterStartDate.day.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          PopupMenuButton<int?>(
            tooltip: '切换查看周次',
            icon: const Icon(Icons.calendar_view_week_rounded),
            onSelected: onSelectPreviewWeek,
            itemBuilder: (context) => [
              const PopupMenuItem<int?>(
                value: null,
                child: Text('自动计算当前周'),
              ),
              const PopupMenuDivider(),
              ...List.generate(
                20,
                (index) => PopupMenuItem<int?>(
                  value: index + 1,
                  child: Text('查看第 ${index + 1} 周'),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 顶部星期栏 (周一至周日)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.45),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300, width: 0.8),
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: leftColWidth,
                  height: 40,
                  child: Center(
                    child: Text(
                      '节次/时间',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                ...List.generate(7, (index) {
                  final wd = index + 1;
                  final isToday = DateTime.now().weekday == wd && previewWeek == null;
                  return Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: isToday
                          ? BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            )
                          : null,
                      child: Text(
                        ScheduleConstants.weekdayNames[wd] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isToday ? FontWeight.bold : FontWeight.w600,
                          color: isToday
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          // 主体滚动区域：1-12节网格 + 底部其它课程
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: periodHeight * 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 左侧节次与作息时间列
                        SizedBox(
                          width: leftColWidth,
                          child: Column(
                            children: List.generate(12, (idx) {
                              final p = idx + 1;
                              final timeRange = ScheduleConstants.periodTimes[p] ?? '';
                              final parts = timeRange.split('-');
                              return Container(
                                height: periodHeight,
                                decoration: BoxDecoration(
                                  border: Border(
                                    right: BorderSide(color: Colors.grey.shade300, width: 0.8),
                                    bottom: BorderSide(color: Colors.grey.shade200, width: 0.6),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '第$p节',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      parts.isNotEmpty ? parts.first : '',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                    Text(
                                      parts.length > 1 ? parts.last : '',
                                      style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ),

                        // 右侧周一到周日 7 列
                        ...List.generate(7, (colIdx) {
                          final wd = colIdx + 1;
                          final dayCourses = currentWeekRegularCourses
                              .where((c) => c.weekday == wd)
                              .toList();

                          return Expanded(
                            child: Stack(
                              children: [
                                // 背景辅助网格线
                                Column(
                                  children: List.generate(12, (_) {
                                    return Container(
                                      height: periodHeight,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(color: Colors.grey.shade200, width: 0.5),
                                          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
                                        ),
                                      ),
                                    );
                                  }),
                                ),

                                // 跨节次自适应高度的课程块 Card
                                ...dayCourses.map((course) {
                                  final top = (course.startPeriod - 1) * periodHeight;
                                  final span = (course.endPeriod - course.startPeriod + 1).clamp(1, 12);
                                  final height = span * periodHeight;
                                  final bgColor = _getCourseColor(course.courseName, context);

                                  return Positioned(
                                    top: top + 2,
                                    left: 2,
                                    right: 2,
                                    height: height - 4,
                                    child: GestureDetector(
                                      onTap: () => _showCourseDetailSheet(context, course),
                                      child: Card(
                                        margin: EdgeInsets.zero,
                                        color: bgColor,
                                        elevation: 1.5,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                course.courseName,
                                                maxLines: span * 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2,
                                                ),
                                              ),
                                              const Spacer(),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 4,
                                                  vertical: 1.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.18),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  '@${course.classroom}',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  // 底部：其它课程 / 待定 (weekday == 0)
                  Container(
                    margin: const EdgeInsets.all(12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.bookmark_added_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              '其它课程 / 待定 (weekday = 0)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (otherCourses.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '当前周暂无其它/待定课程',
                              style: TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                          )
                        else
                          ...otherCourses.map((course) {
                            return Card(
                              elevation: 0,
                              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.6),
                              margin: const EdgeInsets.only(top: 6),
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  course.courseName,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '教师：${course.teacher}  |  教室：${course.classroom}  |  周次：${course.weeksList.join(",")}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showCourseDetailSheet(context, course),
                              ),
                            );
                          }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
