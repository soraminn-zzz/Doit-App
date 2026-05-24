import 'dart:math';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

String buildNotification({
  required int remainingMinutes,
  required List<Map<String, dynamic>> tasks,
}) {
  if (tasks.isEmpty) return "タスクがありません";

  final selected = tasks[Random().nextInt(tasks.length)];

  return "あと$remainingMinutes分あります。「${selected['name']}」をやりましょう！";
}

class NotificationService {
  Future<String> buildNotificationFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');

    if (data == null) return "タスク未登録";

    final List<dynamic> decoded = jsonDecode(data);

    final tasks =
        decoded.map((e) => Map<String, dynamic>.from(e)).toList();

    final remainingMinutes = 120; // 仮固定

    return buildNotification(
      remainingMinutes: remainingMinutes,
      tasks: tasks,
    );
  }
}