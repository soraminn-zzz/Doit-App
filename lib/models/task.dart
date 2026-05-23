import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> actions = [
    {"name": "�A�j��1�b", "minutes": 24},
    {"name": "�U��", "minutes": 30},
    {"name": "�؃g��", "minutes": 15},
    {"name": "�Ǐ�", "minutes": 20},
    {"name": "�ґz", "minutes": 10},
    {"name": "�f��1�{", "minutes": 120},
    {"name": "�ۑ�", "minutes": 90},
  ];

  List<Map<String, dynamic>> userTasks = [];

  final taskNameController = TextEditingController();
  final taskMinutesController = TextEditingController();
  final sleepTimeController = TextEditingController();

  bool fixedTask = false;

  String todayDate = "";
  String remainingText = "";

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    todayDate = "${now.year}/${now.month}/${now.day}";

    loadTasks();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("tasks", jsonEncode(userTasks));
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("tasks");

    if (data != null) {
      setState(() {
        userTasks = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void addTask() {
    final name = taskNameController.text.trim();

    final minutes = taskMinutesController.text.trim();

    if (name.isEmpty || minutes.isEmpty) {
      return;
    }

    final minuteValue = int.tryParse(minutes);

    if (minuteValue == null) {
      return;
    }

    final now = DateTime.now();

    final today =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

    setState(() {
      userTasks.add({
        "name": name,
        "minutes": minuteValue,
        "date": today,
        "fixed": fixedTask,
      });
    });

    saveTasks();

    taskNameController.clear();
    taskMinutesController.clear();
  }

  void deleteTask(int index) {
    setState(() {
      userTasks.removeAt(index);
    });

    saveTasks();
  }

  void showSuggestions() {
    final now = DateTime.now();

    final currentTotal = now.hour * 60 + now.minute;

    int remaining = 1440 - currentTotal;

    if (sleepTimeController.text.isNotEmpty) {
      final parts = sleepTimeController.text.split(":");

      if (parts.length == 2) {
        final sleepHours = int.tryParse(parts[0]) ?? 0;

        final sleepMinutes = int.tryParse(parts[1]) ?? 0;

        final sleepTotal = sleepHours * 60 + sleepMinutes;

        remaining = sleepTotal - currentTotal;
      }
    }

    if (remaining < 0) {
      remaining = 0;
    }

    final remainingHours = remaining ~/ 60;

    final remainingMinutes = remaining % 60;

    setState(() {
      remainingText = "残り ${remainingHours}時間 ${remainingMinutes}分";
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final today =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

    final visibleTasks = userTasks.where((task) {
      return task["fixed"] == true || task["date"] == today;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(title: const Text("残り時間アプリ")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [
            Text(
              todayDate,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: sleepTimeController,

              decoration: const InputDecoration(
                labelText: "寝る時間(例 23:00)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: showSuggestions,
              child: const Text("Do it!"),
            ),

            const SizedBox(height: 20),

            Text(
              remainingText,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            const Text(
              "おすすめ",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...actions.map((action) {
              return Card(
                child: ListTile(
                  title: Text(action["name"]),
                  trailing: Text("${action["minutes"]}分"),
                ),
              );
            }),

            const SizedBox(height: 30),

            const Text(
              "タスク登録",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: taskNameController,

              decoration: const InputDecoration(
                labelText: "タスク名",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: taskMinutesController,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(
                labelText: "想定時間",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            CheckboxListTile(
              value: fixedTask,
              title: const Text("固定タスク"),

              onChanged: (value) {
                setState(() {
                  fixedTask = value ?? false;
                });
              },
            ),

            ElevatedButton(onPressed: addTask, child: const Text("タスク追加")),

            const SizedBox(height: 30),

            const Text(
              "今日のタスク",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...visibleTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        task["name"],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text("${task["minutes"]}分"),

                      Text(task["fixed"] ? "毎日" : task["date"]),

                      const SizedBox(height: 10),

                      ElevatedButton(
                        onPressed: () {
                          deleteTask(index);
                        },
                        child: const Text("削除"),
                      ),
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
