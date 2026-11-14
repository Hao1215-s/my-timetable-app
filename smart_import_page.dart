import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/schedule_constants.dart';
import '../models/course.dart';

class SmartImportPage extends StatefulWidget {
  final Future<int> Function(List<Course>) onImportCourses;

  const SmartImportPage({
    super.key,
    required this.onImportCourses,
  });

  @override
  State<SmartImportPage> createState() => _SmartImportPageState();
}

class _SmartImportPageState extends State<SmartImportPage> {
  final TextEditingController _jsonController = TextEditingController();
  bool _isImporting = false;

  @override
  void dispose() {
    _jsonController.dispose();
    super.dispose();
  }

  Future<void> _copyPromptToClipboard() async {
    await Clipboard.setData(
      const ClipboardData(text: ScheduleConstants.aiPromptText),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制 AI 解析提示词到剪贴板！'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 防崩溃清洗与解析导入逻辑
  Future<void> _parseAndImport() async {
    final rawText = _jsonController.text.trim();
    if (rawText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先粘贴 AI 返回的 JSON 数据'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isImporting = true);

    try {
      // 1. 清洗文本：去掉可能存在的 ```json 和 ``` 标记以及首尾空白
      String cleaned = rawText
          .replaceAll(RegExp(r'```json', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();

      // 进一步容错：如果前后带有非 JSON 说明文字，截取第一个 '[' 到最后一个 ']'
      final firstBracket = cleaned.indexOf('[');
      final lastBracket = cleaned.lastIndexOf(']');
      if (firstBracket != -1 && lastBracket != -1 && lastBracket > firstBracket) {
        cleaned = cleaned.substring(firstBracket, lastBracket + 1);
      }

      // 2. jsonDecode 解析
      final decoded = jsonDecode(cleaned);
      if (decoded is! List) {
        throw const FormatException('根节点不是 JSON 数组');
      }

      final List<Course> parsedCourses = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          parsedCourses.add(Course.fromJson(item));
        } else if (item is Map) {
          parsedCourses.add(Course.fromJson(Map<String, dynamic>.from(item)));
        }
      }

      if (parsedCourses.isEmpty) {
        throw const FormatException('未能解析出任何有效课程记录');
      }

      // 3. 批量存入数据库并跳转刷新
      final count = await widget.onImportCourses(parsedCourses);
      if (!mounted) return;
      _jsonController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功导入 $count 门课程'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green.shade700,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('JSON 解析失败，请检查格式：${e.toString()}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _fillDefaultSampleJson() {
    _jsonController.text = ScheduleConstants.defaultCoursesJson;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已填入您的 22 条课程表 JSON 数据，点击下方按钮即可导入'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '智能导入',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 顶部显眼按钮：复制 AI 解析提示词
            FilledButton.icon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _copyPromptToClipboard,
              icon: const Icon(Icons.content_copy_rounded),
              label: const Text(
                '📋 复制 AI 解析提示词',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),

            // 提示词预览卡片
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  ScheduleConstants.aiPromptText,
                  style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.4),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '粘贴 AI 返回的 JSON 数组：',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: _fillDefaultSampleJson,
                  icon: const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text('一键填入预置课表 JSON'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // 多行 JSON 输入框
            TextField(
              controller: _jsonController,
              maxLines: 11,
              decoration: InputDecoration(
                hintText: '在此粘贴 JSON 数组 (支持自动过滤 ```json 代码块包裹)...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
            ),
            const SizedBox(height: 16),

            // 解析并导入按钮
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isImporting ? null : _parseAndImport,
              icon: _isImporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download_done_rounded),
              label: const Text(
                '解析并导入',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
