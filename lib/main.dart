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

    setState(() => notificationMessage = msg);

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

    final decoded = jsonDecode(raw);

    setState(() {
      tasks = decoded
          .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tasks")),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isFixed = task['fixed'] == true;

          return ListTile(
            leading: Icon(isFixed ? Icons.repeat : Icons.task_alt),
            title: Text(task['name'] ?? ''),
            subtitle: Text(
              isFixed
                  ? "固定 / ${task['minutes']}分"
                  : "${task['date']} / ${task['minutes']}分",
            ),
          );
        },
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

// ================= SETTINGS（統合完成版） =================

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

  String fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

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

    if (d != null) setState(() => date = d);
  }

  Future<void> _clearTasks(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks');

    setState(() => tasks.clear());

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("タスクを削除しました")));
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
              onPressed: () => _clearTasks(context),
              icon: const Icon(Icons.delete_forever),
              label: const Text("タスク全削除"),
            ),

            const SizedBox(height: 10),

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
              onChanged: (v) => setState(() => fixed = v),
            ),

            ElevatedButton(onPressed: addTask, child: const Text("タスク追加")),

            const SizedBox(height: 20),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              itemBuilder: (context, i) {
                final t = tasks[i];
                final isFixed = t['fixed'] == true;

                return ListTile(
                  leading: Icon(isFixed ? Icons.repeat : Icons.task_alt),
                  title: Text(t['name'] ?? ''),
                  subtitle: Text(
                    isFixed
                        ? "固定 / ${t['minutes']}分"
                        : "${t['date']} / ${t['minutes']}分",
                  ),
                );
              },
            ),
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

    final responses = ["まあOK", "気づけたなら十分", "明日はもう少し楽になる", "それも経験", "悪くない選択"];

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
              decoration: const InputDecoration(labelText: "懺悔を書く"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: confess, child: const Text("送信")),
            const SizedBox(height: 20),
            if (reply.isNotEmpty) Text(reply),
          ],
        ),
      ),
    );
  }
}
