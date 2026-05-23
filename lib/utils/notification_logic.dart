import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doitapp/widgets/available_tasks.dart';

/// 残り時間とタスク一覧から通知メッセージ生成
String buildNotification({
  required int remainingMinutes,
  required List<Map<String, dynamic>> tasks,
}) {
  // ✅ テスト用：時間条件を無視して強制表示
  if (remainingMinutes <= 5) {
    return 'テスト通知（時間無視）';
  }

  final safeMinutes = (remainingMinutes * 0.8).floor();

  final candidates = getAvailableTasks(
    safeMinutes: safeMinutes,
    tasks: tasks,
  );

  // ✅ 候補が無い場合も強制表示（UI確認しやすい）
  if (candidates.isEmpty) {
    return 'テスト通知（候補なし）';
  }

  final selected =
      candidates[Random().nextInt(candidates.length)];

  final title = selected['name'] ?? selected['title'] ?? 'タスク';

  return 'あと$remainingMinutes分あります。「$title」ができそうです';
}

/// storage から直接通知メッセージを作る
class NotificationService {
  Future<String> buildNotificationFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');

    // ✅ データが無い時もテスト表示
    if (data == null || data.isEmpty) {
      return 'テスト通知（タスク未登録）';
    }

    final List<dynamic> decoded = jsonDecode(data);
    final tasks = decoded
        .map((e) => Map<String, dynamic>.from(e))
        .toList();

    final now = DateTime.now();

    DateTime targetSleepTime =
        DateTime(now.year, now.month, now.day, 1, 0, 0);

    if (now.isAfter(targetSleepTime)) {
      targetSleepTime =
          targetSleepTime.add(const Duration(days: 1));
    }

    final remainingMinutes =
        targetSleepTime.difference(now).inMinutes;

    return buildNotification(
      remainingMinutes: remainingMinutes,
      tasks: tasks,
    );
  }
}