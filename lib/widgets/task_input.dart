import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskInputPage extends StatefulWidget {
  const TaskInputPage({super.key});

  @override
  State<TaskInputPage> createState() => _TaskInputPageState();
}

class _TaskInputPageState extends State<TaskInputPage> {
  final List<Map<String, dynamic>> actions = [
    {"name": "メール返信", "minutes": 24},
    {"name": "洗濯", "minutes": 30},
    {"name": "掃除", "minutes": 15},
    {"name": "買い物", "minutes": 20},
    {"name": "料理", "minutes": 10},
    {"name": "勉強", "minutes": 120},
    {"name": "運動", "minutes": 90},
  ];

  List<Task> userTasks = [];

  final taskNameController = TextEditingController();
  final taskMinutesController = TextEditingController();

  bool fixedTask = false;

  String todayDate = "";

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();
    todayDate = "${now.year}/${now.month}/${now.day}";

    loadTasks();
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskMinutesController.dispose();
    super.dispose();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(userTasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', encoded);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasks');
    if (data != null) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        setState(() {
          userTasks = decoded
              .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        });
      }
    }
  }

  Future<void> addTask() async {
    final name = taskNameController.text.trim();
    final minutesText = taskMinutesController.text.trim();
    if (name.isEmpty || minutesText.isEmpty) return;
    final minutes = int.tryParse(minutesText) ?? 0;

    final now = DateTime.now();
    final today = "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      minutes: minutes,
      fixed: fixedTask,
      date: today,
    );

    setState(() {
      userTasks.add(newTask);
    });

    await saveTasks();

    taskNameController.clear();
    taskMinutesController.clear();

    // Close input page and return to task list
    if (mounted) Navigator.pop(context);
  }

  void deleteTask(int index) {
    setState(() {
      userTasks.removeAt(index);
    });
    saveTasks();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
    final visibleTasks = userTasks.where((t) => t.fixed || t.date == today).toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('タスク入力')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(todayDate, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            const Text('おすすめタスク', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...actions.map((action) => Card(
                  child: ListTile(
                    title: Text(action['name']),
                    trailing: Text('${action['minutes']}分'),
                  ),
                )),
            const SizedBox(height: 30),
            const Text('タスク追加', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(labelText: 'タスク名', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: taskMinutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: '所要時間（分）', border: OutlineInputBorder()),
            ),
            CheckboxListTile(
              value: fixedTask,
              title: const Text('固定タスク'),
              onChanged: (v) => setState(() => fixedTask = v ?? false),
            ),
            ElevatedButton(onPressed: addTask, child: const Text('タスク追加')),
            const SizedBox(height: 20),
            ...visibleTasks.asMap().entries.map((entry) {
              final idx = entry.key;
              final t = entry.value;
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text('${t.minutes}分'),
                      Text(t.fixed ? '固定' : t.date),
                      ElevatedButton(onPressed: () => deleteTask(idx), child: const Text('削除')),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
