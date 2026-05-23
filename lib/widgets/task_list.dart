import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

String _formatDate(DateTime dt) => "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";

// ================= HOME =================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // AI提案
  final List<String> aiSuggestions = [
    "5分だけ机を片付けよう",
    "水を飲んで休憩しよう",
    "スマホを裏返して10分集中",
    "軽くストレッチしよう",
    "本を2ページだけ読む",
    "外の空気を吸いに行く",
    "明日の準備を少し進める",
    "メールを1件だけ返す",
    "部屋のゴミを1つ捨てる",
    "タイマー15分だけ頑張る",
  ];

  String currentSuggestion = "";

  List<Task> userTasks = [];
  List<Task> aiTasks = [];

  bool showRecommendations = false;

  String selectedViewDate = "";

  int remainingMinutes = 30;
  final TextEditingController remainingController = TextEditingController();

  int _parseMinutesFromSuggestion(String s) {
    final reg = RegExp(r"(\d+)");
    final m = reg.firstMatch(s);
    if (m != null) {
      return int.tryParse(m.group(0) ?? '') ?? remainingMinutes;
    }
    // If suggestion contains no explicit number, use the current remainingMinutes as the estimated duration.
    return remainingMinutes;
  }

  Future<void> saveAiTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(aiTasks.map((t) => t.toMap()).toList());
    await prefs.setString('ai_tasks', encoded);
  }

  Future<void> loadAiTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('ai_tasks');
    if (data != null) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        final loaded = decoded
            .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        setState(() {
          aiTasks = loaded;
        });
      }
    }
  }

  Future<void> deleteUserTask(String id) async {
    setState(() {
      userTasks.removeWhere((t) => t.id == id);
    });
    await saveTasks();
  }

  Future<void> deleteAiTask(String id) async {
    setState(() {
      aiTasks.removeWhere((t) => t.id == id);
    });
    await saveAiTasks();
  }

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedViewDate = _formatDate(now);

    remainingController.text = remainingMinutes.toString();

    _initAsync();
  }

  Future<void> _initAsync() async {
    await loadTasks();
    await loadAiTasks();
  }

  @override
  void dispose() {
    remainingController.dispose();
    super.dispose();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(userTasks.map((t) => t.toMap()).toList());
    await prefs.setString("tasks", encoded);
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString("tasks");

    if (data != null) {
      final decoded = jsonDecode(data);
      if (decoded is List) {
        final loaded = decoded
            .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
            .toList();
        setState(() {
          userTasks = loaded;
        });
      }
    }
  }

  Future<void> selectViewDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedViewDate = _formatDate(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleUserTasks = userTasks.where((task) {
      return task.fixed == true || task.date == selectedViewDate;
    }).toList();

    final noTasks = visibleUserTasks.isEmpty && aiTasks.where((t) => t.date == selectedViewDate).isEmpty;

    final quickTasks = visibleUserTasks.where((t) => t.minutes <= 10).toList();
    final withinTasks = aiTasks.where((t) => t.date == selectedViewDate && t.minutes <= remainingMinutes).toList();
    final addedTasks = visibleUserTasks;

    return Scaffold(
      backgroundColor: Colors.transparent,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("残り時間アプリ"),

        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: selectViewDate,
          ),

          // 設定
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(userTasks: userTasks),
                ),
              );

            await loadTasks();
            },
          ),

          // 懺悔室
          IconButton(
            icon: const Icon(Icons.sms),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ConfessionPage()),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 20),

            // ===== DO IT =====
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  showRecommendations = true;

                  aiSuggestions.shuffle();

                  currentSuggestion = aiSuggestions.first;
                });

                  // Create an AI task and persist it separately
                  final minutes = _parseMinutesFromSuggestion(currentSuggestion);
                  final aiTask = Task(
                    id: DateTime.now().microsecondsSinceEpoch.toString(),
                    name: currentSuggestion,
                    minutes: minutes,
                    fixed: false,
                    date: selectedViewDate,
                  );

                  setState(() {
                    aiTasks.add(aiTask);
                  });

                  await saveAiTasks();

                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("AIが提案を生成しました")));
                },

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 20,
                ),
              ),

              child: const Text(
                "DO IT",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 5,
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ===== AI提案 =====
            if (showRecommendations && noTasks) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "AI提案",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 15),

              Card(
                margin: const EdgeInsets.only(bottom: 10),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "AIおすすめ行動",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        currentSuggestion,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],

            // ===== 残り時間設定 =====
            Card(
              margin: const EdgeInsets.only(bottom: 12),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        '残り時間（分）',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(
                      width: 110,
                      child: TextField(
                        controller: remainingController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                        onSubmitted: (val) {
                          final v = int.tryParse(val) ?? remainingMinutes;
                          setState(() {
                            remainingMinutes = v;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: () async {
                        final v = int.tryParse(remainingController.text) ?? remainingMinutes;
                        setState(() => remainingMinutes = v);
                        // update AI tasks for the selected date to reflect applied remaining time
                        setState(() {
                          for (int i = 0; i < aiTasks.length; i++) {
                            if (aiTasks[i].date == selectedViewDate) {
                              aiTasks[i] = aiTasks[i].copyWith(minutes: remainingMinutes);
                            }
                          }
                        });
                        await saveAiTasks();
                      },
                      child: const Text('適用'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===== 今できるタスク =====
            if (quickTasks.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '今できるタスク',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              ...quickTasks.map((task) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(16),

                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                task.name,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),

                              const SizedBox(height: 6),

                              Text('${task.minutes}分', style: TextStyle(fontSize: 14, color: Colors.grey[700])),

                              if (task.fixed)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
                                    child: const Text('固定タスク', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.redAccent,
                          tooltip: 'タスクを削除',
                          onPressed: () async {
                            // delete user task
                            await deleteUserTask(task.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],

            // ===== 残り時間内でできるタスク =====
            if (withinTasks.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '残り時間内でできるタスク',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              ...withinTasks.map((task) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),

                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('${task.minutes}分', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                              if (task.fixed)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
                                    child: const Text('固定タスク', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.redAccent,
                          tooltip: 'AIタスクを削除',
                          onPressed: () async {
                            await deleteAiTask(task.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),
            ],

            // ===== 追加したタスク =====
            if (addedTasks.isNotEmpty) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '追加したタスク',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 10),

              ...addedTasks.map((task) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('${task.minutes}分', style: TextStyle(fontSize: 14, color: Colors.grey[700])),
                              if (task.fixed)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(20)),
                                    child: const Text('固定タスク', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: Colors.redAccent,
                          tooltip: 'タスクを削除',
                          onPressed: () async {
                            await deleteUserTask(task.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

// ================= SETTINGS =================

class SettingsPage extends StatefulWidget {
  final List<Task> userTasks;

  const SettingsPage({super.key, required this.userTasks});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final taskNameController = TextEditingController();
  final taskMinutesController = TextEditingController();

  bool fixedTask = false;
  String selectedTaskDate = '';
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    tasks = widget.userTasks.map((t) => t).toList();
    final now = DateTime.now();
    selectedTaskDate = _formatDate(now);
  }

  @override
  void dispose() {
    taskNameController.dispose();
    taskMinutesController.dispose();
    super.dispose();
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString('tasks', encoded);
  }

  Future<void> selectTaskDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        selectedTaskDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> addTask() async {
    final name = taskNameController.text.trim();
    final minutesText = taskMinutesController.text.trim();
    if (name.isEmpty || minutesText.isEmpty) return;

    final minutes = int.tryParse(minutesText) ?? 0;

    final newTask = Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      minutes: minutes,
      fixed: fixedTask,
      date: selectedTaskDate,
    );

    setState(() {
      tasks.add(newTask);
    });

    await saveTasks();
    taskNameController.clear();
    taskMinutesController.clear();

    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('タスク追加完了')));
    // After adding, close settings to return to task list
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(title: const Text('設定')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('タスク登録', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: taskNameController,
              decoration: const InputDecoration(
                labelText: 'タスク名',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: taskMinutesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '想定時間（分）',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            ListTile(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              title: const Text('タスクの日付'),
              subtitle: Text(selectedTaskDate),
              trailing: const Icon(Icons.calendar_month),
              onTap: selectTaskDate,
            ),
            const SizedBox(height: 10),
            CheckboxListTile(
              value: fixedTask,
              title: const Text('固定タスク'),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onChanged: (value) => setState(() => fixedTask = value ?? false),
            ),
            const SizedBox(height: 15),
            ElevatedButton(onPressed: addTask, child: const Text('タスク追加')),
          ],
        ),
      ),
    );
  }
}

// ================= 懺悔室 =================

class ConfessionPage extends StatelessWidget {
  const ConfessionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(title: const Text('懺悔室'), backgroundColor: Colors.black),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Text(
            'ここに今日サボったことを書きなさい…',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
