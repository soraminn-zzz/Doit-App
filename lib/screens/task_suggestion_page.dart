import 'package:flutter/material.dart';

class TaskSuggestionPage extends StatelessWidget {
  const TaskSuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ デバッグ用タスク（今は固定）
    final tasks = [
      {"name": "アニメ1話", "minutes": 24},
      {"name": "筋トレ", "minutes": 30},
      {"name": "ストレッチ", "minutes": 15},
      {"name": "読書", "minutes": 20},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("おすすめタスク"),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,

        itemBuilder: (context, index) {
          final task = tasks[index];

          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8),

            child: ListTile(
              leading: const Icon(
                Icons.check_circle_outline,
                color: Colors.blue,
              ),

              title: Text(task["name"].toString()),

              subtitle: Text("${task["minutes"].toString()}分"),

              trailing: const Icon(Icons.arrow_forward_ios, size: 16),

              // ✅ タップした時
              onTap: () {
                // 👇 ここが超重要！！
                Navigator.pop(
                  context,
                  task["name"], // ← NotificationBarに返す
                );
              },
            ),
          );
        },
      ),
    );
  }
}