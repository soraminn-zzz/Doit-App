import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/notification_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> userTasks = [];

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("残り時間アプリ")),

      body: Column(
        children: [
          const NotificationBar(), // ✅ これ重要！

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: userTasks.map((task) {
                return ListTile(
                  title: Text(task["name"]),
                  subtitle: Text("${task["minutes"]}分"),
                );
              }).toList(),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SettingsPage(tasks: userTasks),
            ),
          );
          loadTasks();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ===== 設定画面 =====
class SettingsPage extends StatefulWidget {
  final List<Map<String, dynamic>> tasks;

  const SettingsPage({super.key, required this.tasks});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final nameController = TextEditingController();
  final minutesController = TextEditingController();

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("tasks", jsonEncode(widget.tasks));
  }

  void addTask() {
    final name = nameController.text;
    final minutes = int.tryParse(minutesController.text);

    if (name.isEmpty || minutes == null) return;

    setState(() {
      widget.tasks.add({
        "name": name,
        "minutes": minutes,
      });
    });

    saveTasks();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("タスク追加")),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "タスク名")),
            TextField(controller: minutesController, decoration: const InputDecoration(labelText: "時間（分）")),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: addTask,
              child: const Text("追加"),
            ),
          ],
        ),
      ),
    );
  }
}