# 大学生课程表 App (Flutter Material 3)

本项目是根据您的完整需求开发的 **Flutter (Material 3)** 大学生课程表项目，已预置您的 22 条课程安排与固定作息时间表。

## 一、 核心特性
1. **周次自动计算**：
   - 公式：`int currentWeek = (当前日期 - 设定日期).inDays ~/ 7 + 1`
   - 自动识别“未开学”、“第 X 周”、“学期已结束（>20周）”，并支持手动切换预览任意周次。
2. **固定 1-12 节作息时间**：
   - 内置第 1 节 (`08:00-08:50`) 至第 12 节 (`21:25-22:15`) 完整时间映射。
3. **跨节次自适应与待定课程分区**：
   - 周一至周日网格自动按 `endPeriod - startPeriod + 1` 撑开卡片高度。
   - `weekday == 0` 的课程（如《体育 (1)》）自动归类展示在课表底部的“其它课程 / 待定”区域。
4. **AI 智能导入与防崩溃清洗**：
   - 一键复制 AI 解析提示词，自动剔除 ```json 代码块包裹并校验字段类型。

## 二、 如何零代码获取 APK 安装包

由于云端沙盒环境处于无外网隔离状态且未预装 Android SDK，本项目已为您配置好 **GitHub Actions 全自动云端打包脚本** (`.github/workflows/build_apk.yml`)：

### 方式 A：使用 GitHub 自动打包（无需电脑安装任何开发环境）
1. 在 GitHub 创建一个新仓库，将本压缩包解压后的全部文件上传到仓库中。
2. 点击仓库顶部的 **Actions** 标签页，等待 `Build Android APK` 任务运行完成（约 2~3 分钟）。
3. 在任务底部的 **Artifacts** 区域点击 `college-timetable-release-apk` 即可直接下载编译好的 `app-release.apk` 到手机安装。

### 方式 B：本地 Flutter 命令行打包
如果您电脑上装有 Flutter 环境，解压后在目录内运行：
```bash
flutter create --platforms=android .
flutter pub get
flutter build apk --release
```
生成的 APK 位于 `build/app/outputs/flutter-apk/app-release.apk`。
