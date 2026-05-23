import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/notification_logic.dart';
import '../widgets/notification_button.dart';
import '../widgets/notification_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomePage());
  }
}

class HomePage extends StatefulWidget {
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

    prefs.setString("tasks", jsonEncode(userTasks));
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
    final name = taskNameController.text;

    final minutes = taskMinutesController.text;

    if (name.isEmpty || minutes.isEmpty) {
      return;
    }

    final now = DateTime.now();

    final today =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

    setState(() {
      userTasks.add({
        "name": name,
        "minutes": int.parse(minutes),
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

      final sleepHours = int.parse(parts[0]);

      final sleepMinutes = int.parse(parts[1]);

      final sleepTotal = sleepHours * 60 + sleepMinutes;

      remaining = sleepTotal - currentTotal;
    }

    final remainingHours = remaining ~/ 60;

    final remainingMinutes = remaining % 60;

    setState(() {
      remainingText = "�c�� ${remainingHours}���� ${remainingMinutes}��";
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

      appBar: AppBar(title: const Text("�c�莞�ԃA�v��")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Text(
              todayDate,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            
            const SizedBox(height: 20),

            
            NotificationBar(),

            const SizedBox(height: 10),

            
            const NotificationButton(),

            const SizedBox(height: 20),


            TextField(
              controller: sleepTimeController,
              decoration: const InputDecoration(
                labelText: "�Q�鎞�� (�� 23:00)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: showSuggestions,
              child: const Text("Do it!"),
            ),

            const SizedBox(height: 8),
            

            const SizedBox(height: 20),

            Text(remainingText, style: const TextStyle(fontSize: 22)),

            const SizedBox(height: 20),

            const Text(
              "��������",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            ...actions.map((action) {
              return Card(
                child: ListTile(
                  title: Text(action["name"]),
                  trailing: Text("${action["minutes"]}��"),
                ),
              );
            }),

            const SizedBox(height: 30),

            const Text(
              "�^�X�N�o�^",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(
                labelText: "�^�X�N��",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: taskMinutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "�z�莞�ԁi���j",
                border: OutlineInputBorder(),
              ),
            ),

            CheckboxListTile(
              value: fixedTask,
              title: const Text("�Œ�^�X�N"),
              onChanged: (value) {
                setState(() {
                  fixedTask = value!;
                });
              },
            ),

            ElevatedButton(onPressed: addTask, child: const Text("�^�X�N�ǉ�")),

            const SizedBox(height: 20),

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

                      Text("${task["minutes"]}��"),

                      Text(task["fixed"] ? "����" : task["date"]),

                      ElevatedButton(
                        onPressed: () {
                          deleteTask(index);
                        },
                        child: const Text("�폜"),
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
