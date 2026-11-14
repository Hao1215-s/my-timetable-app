import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  final DateTime semesterStartDate;
  final ValueChanged<DateTime> onUpdateStartDate;
  final VoidCallback onClearAllCourses;
  final int totalCourseCount;

  const SettingsPage({
    super.key,
    required this.semesterStartDate,
    required this.onUpdateStartDate,
    required this.onClearAllCourses,
    required this.totalCourseCount,
  });

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: semesterStartDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
      helpText: '选择开学第一周的周一日期',
    );
    if (picked != null) {
      onUpdateStartDate(picked);
    }
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清空所有课程？'),
        content: const Text('此操作将删除本地数据库中的所有课程数据，且不可恢复。是否继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              onClearAllCourses();
            },
            child: const Text('确认清空'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${semesterStartDate.year}-${semesterStartDate.month.toString().padLeft(2, '0')}-${semesterStartDate.day.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '设置',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.event_available_rounded),
                  title: const Text(
                    '开学第一周周一',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('当前设定：$dateStr'),
                  trailing: FilledButton.tonal(
                    onPressed: () => _pickStartDate(context),
                    child: const Text('修改日期'),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.storage_rounded),
                  title: const Text(
                    '本地已存课程条目数',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('共 $totalCourseCount 条课程安排记录'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              foregroundColor: Colors.red.shade700,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => _confirmClearAll(context),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text(
              '一键清空所有课程数据',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
