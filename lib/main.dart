import 'package:flutter/material.dart';
import 'dart:ui';
import 'widgets/remaining_time.dart'; // 既存のウィジェット
import 'widgets/task_list.dart'; // タスク画面を追加

void main() {
  runApp(const MyApp());
}

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

// ================= ページ管理 =================

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MainScreen(),
    const HomePage(),
    const Scaffold(
      body: Center(
        child: Text("Focus"),
      ),
    ),
    const Scaffold(
      body: Center(
        child: Text("Settings"),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isDark = hour >= 17 || hour < 5;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(40, 0, 40, 24),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
            width: 0.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              selectedItemColor: isDark ? Colors.white : const Color(0xFF151B54),
              unselectedItemColor: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: ''),
                BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: ''),
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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  late final AnimationController _bgController;
  late final AnimationController _floatController;

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
    final isDark = hour >= 17 || hour < 5;

    final themeStart = (hour >= 5 && hour < 12)
        ? [const Color(0xFFF4F7F9), const Color(0xFFE2ECF4)]
        : (hour >= 12 && hour < 17)
            ? [const Color(0xFFE6F6FF), const Color(0xFFCBEBFC)]
            : [const Color(0xFF1E1E2E), const Color(0xFF2A2A3D)];

    final themeEnd = (hour >= 5 && hour < 12)
        ? [const Color(0xFFFBF4EC), const Color(0xFFF3E1D3)]
        : (hour >= 12 && hour < 17)
            ? [const Color(0xFFEDF7ED), const Color(0xFFD0EBD2)]
            : [const Color(0xFF252538), const Color(0xFF1A1A2E)];

    return AnimatedBuilder(
      animation: Listenable.merge([_bgController, _floatController]),
      builder: (context, child) {
        final t = _bgController.value;
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(themeStart[0], themeEnd[0], t)!,
                Color.lerp(themeStart[1], themeEnd[1], t)!,
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
                imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Text(
                  'DO IT',
                  style: TextStyle(
                    fontSize: 180,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 20,
                    color: isDark
                        ? Colors.white.withOpacity(0.15)
                        : Colors.indigo.shade900.withOpacity(0.08),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Text(
                        'D O  I T',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 8,
                          color: isDark
                              ? Colors.white.withOpacity(0.35)
                              : Colors.black.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateTime.now().toString().substring(0, 10).replaceAll('-', '.'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w300,
                          letterSpacing: 4,
                          color: isDark
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.25),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40),
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
}