import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/notification_bar.dart';
import 'widgets/remaining_time.dart';
import 'utils/notification_logic.dart';

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

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const Scaffold(body: Center(child: Text('Tasks'))),
      const Scaffold(body: Center(child: Text('Focus'))),
      const Scaffold(body: Center(child: Text('Settings'))),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.timer_outlined), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Settings'),
        ],
      ),
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
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        setState(() {
          userTasks = decoded.whereType<Map<String, dynamic>>().toList();
        });
      }
    } catch (_) {}
  }

  int _calculateRemainingMinutes() {
    final now = DateTime.now();
    final currentTotal = now.hour * 60 + now.minute;
    return 1440 - currentTotal;
  }

  void _showPageNotification() {
    final remaining = _calculateRemainingMinutes();
    final today = DateTime.now();
    final todayKey = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final visibleTasks = userTasks.where((task) {
      final fixed = task['fixed'] == true;
      final date = task['date']?.toString() ?? '';
      return fixed || date == todayKey;
    }).toList();

    final msg = buildNotification(remainingMinutes: remaining, tasks: visibleTasks);

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
        child: Column(
          children: [
            const SizedBox(height: 16),
            const NotificationBar(),
            const SizedBox(height: 16),
            const RemainingTimeWidget(),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _showPageNotification, child: const Text('通知を生成')),
            if (notificationMessage.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(notificationMessage, textAlign: TextAlign.center),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
