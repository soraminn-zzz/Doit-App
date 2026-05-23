import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/notification_bar.dart';
import 'widgets/remaining_time.dart';
import 'utils/notification_logic.dart';

void main() {
  runApp(const MyApp());
}

// ================= APP =================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO IT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Noto Sans JP',
      ),
      home: const MainContainer(),
    );
  }
}

// ================= MAIN =================

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final pages = const [HomePage(), TaskPage(), FocusPage(), SettingsPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_outlined),
            label: 'Focus',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ================= HOME =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> userTasks = [];
  String notificationMessage = '';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tasks');
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List;

    setState(() {
      userTasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  int _remainingMinutes() {
    final now = DateTime.now();
    return 1440 - (now.hour * 60 + now.minute);
  }

  void _notify() {
    final today = DateTime.now();
    final key =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final visible = userTasks.where((t) {
      return t['fixed'] == true || t['date'] == key;
    }).toList();

    final msg = buildNotification(
      remainingMinutes: _remainingMinutes(),
      tasks: visible,
    );

    setState(() => notificationMessage = msg);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade900, Colors.indigo.shade600],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              const NotificationBar(),
              const SizedBox(height: 16),
              const RemainingTimeWidget(),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _notify, child: const Text("通知生成")),
              if (notificationMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(notificationMessage),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= TASK PAGE =================

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];
  bool show = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tasks');
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List;

    setState(() {
      tasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => setState(() => show = !show),
            child: const Text("Do it!"),
          ),
          const SizedBox(height: 10),
          if (show)
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, i) {
                  final t = tasks[i];
                  final fixed = t['fixed'] == true;

                  return ListTile(
                    leading: Icon(fixed ? Icons.repeat : Icons.task_alt),
                    title: Text(t['name'] ?? ''),
                    subtitle: Text(
                      fixed
                          ? "固定 / ${t['minutes']}分"
                          : "${t['date']} / ${t['minutes']}分",
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// ================= FOCUS =================

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Focus")));
  }
}

// ================= SETTINGS =================

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final name = TextEditingController();
  final min = TextEditingController();

  DateTime date = DateTime.now(); // ★ここが変更点（デフォルト今日）
  bool fixed = false;

  List<Map<String, dynamic>> tasks = [];

  String fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  void addTask() async {
    if (name.text.isEmpty || min.text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    tasks.add({
      "name": name.text,
      "minutes": int.parse(min.text),
      "date": fmt(date), // ★常に今日 or 選択日
      "fixed": fixed,
    });

    await prefs.setString('tasks', jsonEncode(tasks));

    setState(() {
      name.clear();
      min.clear();
      fixed = false;
      date = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "タスク名"),
            ),
            TextField(
              controller: min,
              decoration: const InputDecoration(labelText: "時間"),
            ),

            Row(
              children: [
                Text(fmt(date)),
                ElevatedButton(
                  onPressed: () async {
                    final d = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: date,
                    );
                    if (d != null) setState(() => date = d);
                  },
                  child: const Text("日付"),
                ),
              ],
            ),

            SwitchListTile(
              title: const Text("固定"),
              value: fixed,
              onChanged: (v) => setState(() => fixed = v),
            ),

            ElevatedButton(onPressed: addTask, child: const Text("追加")),
          ],
        ),
      ),
    );
  }
}
