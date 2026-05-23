import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/notification_logic.dart';
import 'widgets/notification_bar.dart';
import 'widgets/remaining_time.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/notification_bar.dart';

void main() {
  runApp(const MyApp());
}

// =====================================
// アプリ本体
// =====================================
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

// =====================================
// ページ切り替え（ナビゲーション）
// =====================================
class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MainScreen(),
    const Scaffold(
      body: Center(child: Text("Tasks")),
    ),
    const Scaffold(
      body: Center(child: Text("Focus")),
    ),
    const Scaffold(
      body: Center(child: Text("Settings")),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Tasks"),
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: "Focus"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

// =====================================
// ホーム画面（あなたの担当部分）
// =====================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Map<String, dynamic>> userTasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  // タスク読み込み
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tasks');

    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);

    if (decoded is List) {
      setState(() {
        userTasks =
            decoded.whereType<Map<String, dynamic>>().toList();
      });
    }
  }

  // 背景グラデーション
  List<Color> _getBackgroundGradient() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return [const Color(0xFFF3F9FB), const Color(0xFFE8F1F5)];
    } else if (hour >= 12 && hour < 17) {
      return [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)];
    } else if (hour >= 17 && hour < 20) {
      return [const Color(0xFFFFF3E0), const Color(0xFFFFE0B2)];
    } else {
      return [const Color(0xFFEDE7F6), const Color(0xFFE1BEE7)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getBackgroundGradient(),
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // ✅ 通知UI（あなたが作った）
            const NotificationBar(),

            const SizedBox(height: 20),

            const Text(
              "Home",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "ここにホーム画面のUIを追加できます",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

  int _calculateRemainingMinutes() {
    final now = DateTime.now();
    final currentTotal = now.hour * 60 + now.minute;
    return 1440 - currentTotal;
  }

  void _showPageNotification() {
    final remainingMinutes = _calculateRemainingMinutes();
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final visibleTasks = userTasks.where((task) {
      final fixed = task['fixed'] == true;
      final date = task['date']?.toString() ?? '';
      return fixed || date == todayKey;
    }).toList();

    final message = buildNotification(
      remainingMinutes: remainingMinutes,
      tasks: visibleTasks,
    );

    setState(() {
      notificationMessage = message;
    });

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画面に表示するおすすめタスクが見つかりませんでした')),
      );
    }
  }

@override
Widget build(BuildContext context) {
  final isDark =
      DateTime.now().hour >= 17 ||
      DateTime.now().hour < 5;

  return Scaffold(
    extendBody: true,

    // ✅ ページ切り替え（develop側を採用）
    body: IndexedStack(
      index: _currentIndex,
      children: [
        // ✅ あなたのホーム画面（ここに統合）
        MainScreen(),
        const Scaffold(
          body: Center(child: Text("Tasks")),
        ),
        const Scaffold(
          body: Center(child: Text("Focus")),
        ),
        const Scaffold(
          body: Center(child: Text("Settings")),
        ),
      ],
    ),

    // ✅ 下のナビゲーション（develop側そのまま）
    bottomNavigationBar: Container(
      margin: const EdgeInsets.fromLTRB(40, 0, 40, 24),

      decoration: BoxDecoration(
        color: (isDark ? Colors.white : Colors.black)
            .withValues(alpha: 0.05),

        borderRadius: BorderRadius.circular(30),

        border: Border.all(
          color: (isDark ? Colors.white : Colors.black)
              .withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),

        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 10,
            sigmaY: 10,
          ),

          child: BottomNavigationBar(
            currentIndex: _currentIndex,

            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },

            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,

            showSelectedLabels: false,
            showUnselectedLabels: false,

            selectedItemColor:
                isDark ? Colors.white : const Color(0xFF151B54),

            unselectedItemColor:
                (isDark ? Colors.white : Colors.black)
                    .withValues(alpha: 0.3),

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle_outline),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.timer_outlined),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.settings_outlined),
                label: "",
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// ================= MAIN SCREEN =================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {

  late AnimationController _bgController;
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      duration: const Duration(seconds: 15),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _floatController.dispose();

    super.dispose();
  }
}
 @override
void initState() {
  super.initState();

  _bgController = AnimationController(
    duration: const Duration(seconds: 15),
    vsync: this,
  )..repeat(reverse: true);

  _floatController = AnimationController(
    duration: const Duration(seconds: 10),
    vsync: this,
  )..repeat(reverse: true);
}

@override
void dispose() {
  _bgController.dispose();
  _floatController.dispose();

  super.dispose();
}

@override
Widget build(BuildContext context) {
  final hour = DateTime.now().hour;

  final isDark =
      hour >= 17 || hour < 5;

  List<Color> themeStart;
  List<Color> themeEnd;

  if (hour >= 5 && hour < 12) {
    themeStart = [
      const Color(0xFFF4F7F9),
      const Color(0xFFE2ECF4),
    ];

    themeEnd = [
      const Color(0xFFFBF4EC),
      const Color(0xFFF3E1D3),
    ];
  } else if (hour >= 12 && hour < 17) {
    themeStart = [
      const Color(0xFFE6F6FF),
      const Color(0xFFCBEBFC),
    ];

    themeEnd = [
      const Color(0xFFEDF7ED),
      const Color(0xFFD0EBD2),
    ];
  } else {
    themeStart = [
      const Color(0xFF1E1E2E),
      const Color(0xFF2A2A3D),
    ];

    themeEnd = [
      const Color(0xFF252538),
      const Color(0xFF1A1A2E),
    ];
  }

  return AnimatedBuilder(
    animation: Listenable.merge([
      _bgController,
      _floatController,
    ]),

    builder: (context, child) {
      final t = _bgController.value;

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              Color.lerp(
                themeStart[0],
                themeEnd[0],
                t,
              )!,

              Color.lerp(
                themeStart[1],
                themeEnd[1],
                t,
              )!,
            ],
          ),
        ),

        child: child,
      );
    },

    child: Stack(
      children: [
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,

          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: 5,
                sigmaY: 5,
              ),

              child: Text(
                'DO IT',

                style: TextStyle(
                  fontSize: 180,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 20,

                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : Colors.indigo.shade900.withValues(alpha: 0.08),
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                ),

                child: Column(
                  children: [
                    Text(
                      'D O  I T',

                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 8,

                        color: isDark
                            ? Colors.white.withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.4),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      DateTime.now()
                          .toString()
                          .substring(0, 10)
                          .replaceAll('-', '.'),

                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 4,

                        color: isDark
                            ? Colors.white.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.25),
                      ),
                    ),
                  ],
                ),
              ),

              const Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),

                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 40,
                      ),

                      child: RemainingTimeWidget(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
      ),
    );
  }
}