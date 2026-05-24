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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
  // AI提�?
  final List<String> aiSuggestions = [
    "5分だけ机を片付けよう",
    "水を飲んで休憩しよう?",
    "スマホを裏返して10分中",
    "軽くストレッチしよう",
    "本を2ページだけ読む",
    "外の空気を吸いに行く",
    "明日の準備を少し進める",
    "メールを1件だけ返す",
    "部屋のゴミを1つ捨てる",
    "タイマー15分だけ頑張る",
  ];

  String currentSuggestion = "";

  List<Map<String, dynamic>> userTasks = [];

  bool showRecommendations = false;

  String selectedViewDate = "";

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedViewDate =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

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

  Future<void> selectViewDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedViewDate =
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, "0")}-${pickedDate.day.toString().padLeft(2, "0")}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTasks = userTasks.where((task) {
      return task["fixed"] == true || task["date"] == selectedViewDate;
    }).toList();

    final noTasks = visibleTasks.isEmpty;

    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        title: const Text("残り時間アプリ"),

        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: selectViewDate,
          ),

          // 設�?
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(userTasks: userTasks),
                ),
              );

              loadTasks();
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
              onPressed: () {
                setState(() {
                  showRecommendations = true;

                  aiSuggestions.shuffle();

                  currentSuggestion = aiSuggestions.first;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("AIが提案を生成しました")),
                );
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

            // ===== AI提�? =====
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

            // ===== 今日のタスク =====
            if (visibleTasks.isNotEmpty)
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "今日のタスク",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 15),

            ...visibleTasks.map((task) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),

                child: Padding(
                  padding: const EdgeInsets.all(16),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              task["name"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "${task["minutes"]}分",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                            ),

                            if (task["fixed"])
                              Padding(
                                padding: const EdgeInsets.only(top: 6),

                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),

                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),

                                  child: const Text(
                                    "固定タスク",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
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

// ================= SETTINGS =================

class SettingsPage extends StatefulWidget {
  final List<Map<String, dynamic>> userTasks;

  const SettingsPage({super.key, required this.userTasks});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final taskNameController = TextEditingController();

  final taskMinutesController = TextEditingController();

  bool fixedTask = false;

  String selectedTaskDate = "";

  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    tasks = widget.userTasks;

    final now = DateTime.now();

    selectedTaskDate =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";
  }

  Future<void> saveTasks() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("tasks", jsonEncode(tasks));
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
            "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, "0")}-${pickedDate.day.toString().padLeft(2, "0")}";
      });
    }
  }

  void addTask() {
    final name = taskNameController.text.trim();

    final minutes = taskMinutesController.text.trim();

    if (name.isEmpty || minutes.isEmpty) {
      return;
    }

    setState(() {
      tasks.add({
        "name": name,
        "minutes": int.parse(minutes),
        "date": selectedTaskDate,
        "fixed": fixedTask,
      });
    });

    saveTasks();

    taskNameController.clear();
    taskMinutesController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("タスク追加完了")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],

      appBar: AppBar(title: const Text("設定")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const Text(
              "タスク登録",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: taskNameController,

              decoration: const InputDecoration(
                labelText: "タスク名",
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
                labelText: "想定時間（分）",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

            const SizedBox(height: 15),

            ListTile(
              tileColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              title: const Text("タスクの日付"),

              subtitle: Text(selectedTaskDate),

              trailing: const Icon(Icons.calendar_month),

              onTap: selectTaskDate,
            ),

            const SizedBox(height: 10),

            CheckboxListTile(
              value: fixedTask,

              title: const Text("固定タスク"),

              tileColor: Colors.white,

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),

              onChanged: (value) {
                setState(() {
                  fixedTask = value!;
                });
              },
            ),

            const SizedBox(height: 15),

            ElevatedButton(onPressed: addTask, child: const Text("タスク追加")),
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

      appBar: AppBar(
        title: const Text("懺悔室"),
        backgroundColor: Colors.black,
      ),

      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(30),

          child: Text(
            "ここに今日サボったことを書きなさい…",
            textAlign: TextAlign.center,

            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
