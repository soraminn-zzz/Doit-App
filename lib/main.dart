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

  int _calculateRemainingMinutes() {
    final now = DateTime.now();
    return 1440 - (now.hour * 60 + now.minute);
  }

  void _showPageNotification() {
    final remaining = _calculateRemainingMinutes();

    final today = DateTime.now();

    final todayKey =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final visibleTasks = userTasks.where((task) {
      final isFixed = task['fixed'] == true;
      final date = task['date']?.toString() ?? '';

      return isFixed || date == todayKey;
    }).toList();

    final msg = buildNotification(
      remainingMinutes: remaining,
      tasks: visibleTasks,
    );

    setState(() {
      notificationMessage = msg;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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

                ElevatedButton(
                  onPressed: _showPageNotification,
                  child: const Text('通知を生成'),
                ),

                if (notificationMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      notificationMessage,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= TASK =================

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];

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

  // ================= 保存 =================

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('tasks', jsonEncode(tasks));
  }

  // ================= 削除 =================

  Future<void> _deleteTask(int index) async {
    setState(() {
      tasks.removeAt(index);
    });

    await _save();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("タスクを削除しました")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),

      body: ListView.builder(
        itemCount: tasks.length,

        itemBuilder: (context, i) {
          final t = tasks[i];

          final fixed = t['fixed'] == true;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),

            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),

            child: ListTile(
              leading: Icon(
                fixed ? Icons.repeat : Icons.task_alt,
                color: Colors.white,
              ),

              title: Text(
                t['name'] ?? '',
                style: const TextStyle(color: Colors.white),
              ),

              subtitle: Text(
                fixed
                    ? "固定 / ${t['minutes']}分"
                    : "${t['date']} / ${t['minutes']}分",
                style: const TextStyle(color: Colors.white70),
              ),

              // ================= 削除ボタン =================
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),

                onPressed: () {
                  _deleteTask(i);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

// ================= FOCUS =================

class FocusPage extends StatefulWidget {
  const FocusPage({super.key});

  @override
  State<FocusPage> createState() => _FocusPageState();
}

class _FocusPageState extends State<FocusPage> {
  List<Map<String, dynamic>> tasks = [];

  Map<String, dynamic>? selectedTask;

  int remainingSeconds = 0;

  bool isRunning = false;

  @override
  void initState() {
    super.initState();

    _loadTasks();

    _loadTimerState();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('tasks');

    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw) as List;

    setState(() {
      tasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> _saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'focus_timer',
      jsonEncode({
        "selectedTask": selectedTask,
        "remainingSeconds": remainingSeconds,
        "isRunning": isRunning,
      }),
    );
  }

  Future<void> _loadTimerState() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString('focus_timer');

    if (raw == null || raw.isEmpty) return;

    final data = jsonDecode(raw);

    setState(() {
      selectedTask = data["selectedTask"] != null
          ? Map<String, dynamic>.from(data["selectedTask"])
          : null;

      remainingSeconds = data["remainingSeconds"] ?? 0;

      isRunning = false;
    });
  }

  void _selectTask(Map<String, dynamic> task) {
    setState(() {
      selectedTask = task;

      remainingSeconds = (task['minutes'] ?? 0) * 60;

      isRunning = false;
    });

    _saveTimerState();
  }

  void _startTimer() {
    if (selectedTask == null) return;

    setState(() {
      isRunning = true;
    });

    _saveTimerState();

    Future.doWhile(() async {
      if (!isRunning || remainingSeconds <= 0) {
        return false;
      }

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        remainingSeconds--;
      });

      _saveTimerState();

      return true;
    });
  }

  void _stopTimer() {
    setState(() {
      isRunning = false;
    });

    _saveTimerState();
  }

  String _format(int s) {
    final m = s ~/ 60;

    final sec = s % 60;

    return "${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Focus Timer")),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];

                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    border: Border.all(color: Colors.white),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: ListTile(
                    title: Text(
                      t['name'] ?? '',
                      style: const TextStyle(color: Colors.white),
                    ),

                    subtitle: Text(
                      "${t['minutes']}分",
                      style: const TextStyle(color: Colors.white70),
                    ),

                    trailing: ElevatedButton(
                      onPressed: () => _selectTask(t),
                      child: const Text("選択"),
                    ),
                  ),
                );
              },
            ),
          ),

          if (selectedTask != null)
            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                children: [
                  Text(
                    selectedTask!['name'],
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    _format(remainingSeconds),
                    style: const TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _startTimer,
                        child: const Text("Start"),
                      ),

                      const SizedBox(width: 20),

                      ElevatedButton(
                        onPressed: _stopTimer,
                        child: const Text("Stop"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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

  DateTime date = DateTime.now();

  bool fixed = false;

  List<Map<String, dynamic>> tasks = [];

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
      tasks = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
    });
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('tasks', jsonEncode(tasks));
  }

  String fmt(DateTime d) {
    return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  void addTask() async {
    if (name.text.isEmpty || min.text.isEmpty) return;

    setState(() {
      tasks.add({
        "name": name.text,
        "minutes": int.parse(min.text),
        "date": fmt(date),
        "fixed": fixed,
      });
    });

    await _saveTasks();

    name.clear();

    min.clear();

    fixed = false;

    date = DateTime.now();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: date,
    );

    if (d != null) {
      setState(() {
        date = d;
      });
    }
  }

  void _openConfession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ConfessionPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _openConfession(context),
              icon: const Icon(Icons.church),
              label: const Text("懺悔室へ"),
            ),

            const Divider(height: 30),

            TextField(
              controller: name,
              decoration: const InputDecoration(labelText: "タスク名"),
            ),

            TextField(
              controller: min,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "時間（分）"),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Text(fmt(date)),

                const SizedBox(width: 10),

                ElevatedButton(onPressed: _pickDate, child: const Text("日付選択")),
              ],
            ),

            SwitchListTile(
              title: const Text("固定タスク"),
              value: fixed,
              onChanged: (v) {
                setState(() {
                  fixed = v;
                });
              },
            ),

            ElevatedButton(onPressed: addTask, child: const Text("タスク追加")),
          ],
        ),
      ),
    );
  }
}

// ================= 懺悔室 =================

class ConfessionPage extends StatefulWidget {
  const ConfessionPage({super.key});

  @override
  State<ConfessionPage> createState() => _ConfessionPageState();
}

class _ConfessionPageState extends State<ConfessionPage> {
  final controller = TextEditingController();

  String reply = "";

  void confess() {
    final text = controller.text;

    if (text.isEmpty) return;

    final responses = [
      "まあOK",
      "気づけたなら十分",
      "明日はもう少し楽になる",
      "それも経験",
      "悪くない選択",
      "たらればの話はやめな",
      "今日はもう寝よう",
    ];

    setState(() {
      reply =
          "「$text」\n→ ${responses[DateTime.now().second % responses.length]}";
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("懺悔室")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(labelText: "懺悔をかいて"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: confess, child: const Text("懺悔")),

            const SizedBox(height: 20),

            if (reply.isNotEmpty)
              Text(reply, style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}
