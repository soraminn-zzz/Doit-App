import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // AI風おすすめ
  final List<Map<String, dynamic>> aiSuggestions = [
    {"title": "5分だけ机を片付ける", "reason": "小さい行動から始めると集中しやすいです"},
    {"title": "軽くストレッチする", "reason": "体を動かすと気分転換になります"},
    {"title": "水を飲む", "reason": "集中力低下を防ぎます"},
    {"title": "10分だけ課題", "reason": "最初の10分が一番大事です"},
    {"title": "外を少し歩く", "reason": "脳がリフレッシュされます"},
    {"title": "今日やることを3つ書く", "reason": "頭の整理ができます"},
    {"title": "深呼吸を30秒", "reason": "焦りを落ち着かせます"},
  ];

  List<Map<String, dynamic>> userTasks = [];

  bool showRecommendations = false;

  String selectedViewDate = "";

  // AI提案
  Map<String, dynamic>? currentSuggestion;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    selectedViewDate =
        "${now.year}-${now.month.toString().padLeft(2, "0")}-${now.day.toString().padLeft(2, "0")}";

    loadTasks();
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

              loadTasks();
            },
          ),

          // 懺悔室
          IconButton(
            icon: const Icon(Icons.psychology),
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
                final random = Random();

                setState(() {
                  showRecommendations = true;

                  currentSuggestion =
                      aiSuggestions[random.nextInt(aiSuggestions.length)];
                });

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text("AIが行動を提案しました")));
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
            if (showRecommendations && noTasks && currentSuggestion != null)
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),

                elevation: 5,

                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    children: [
                      const Text(
                        "AI提案",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        currentSuggestion!["title"],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        currentSuggestion!["reason"],
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 30),

            // ===== タスク一覧 =====
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

                                  child: const Text("固定タスク"),
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

class ConfessionPage extends StatefulWidget {
  const ConfessionPage({super.key});

  @override
  State<ConfessionPage> createState() => _ConfessionPageState();
}

class _ConfessionPageState extends State<ConfessionPage> {
  final TextEditingController controller = TextEditingController();

  String message = "";

  void confess() {
    setState(() {
      message = controller.text;
    });

    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(backgroundColor: Colors.black, title: const Text("懺悔室")),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              "ここに全部置いていけ",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: controller,
              maxLines: 5,

              style: const TextStyle(color: Colors.white),

              decoration: InputDecoration(
                hintText: "懺悔を書く",
                hintStyle: const TextStyle(color: Colors.grey),

                filled: true,
                fillColor: Colors.grey[900],

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(onPressed: confess, child: const Text("浄化する")),

            const SizedBox(height: 30),

            if (message.isNotEmpty)
              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: const Text(
                  "受け取った。\nまた明日からやればいい。",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
