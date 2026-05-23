import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/notification_logic.dart';
import 'widgets/notification_bar.dart';
import 'widgets/remaining_time.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String notificationMessage = '';
  List<Map<String, dynamic>> userTasks = [];

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tasks');
    if (raw == null || raw.isEmpty) {
      return;
    }

    final decoded = jsonDecode(raw);
    if (decoded is List) {
      setState(() {
        userTasks = decoded
            .whereType<Map<String, dynamic>>()
            .toList();
      });
    }
  }

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
    final backgroundColors = _getBackgroundGradient();

    return Scaffold(
      appBar: AppBar(
        title: const Text('残り時間アプリ 開発画面'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: backgroundColors,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RemainingTimeWidget(key: UniqueKey()),

                const SizedBox(height: 24),
                NotificationBar(),

                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _showPageNotification,
                  child: const Text('画面通知を表示'),
                ),

                const SizedBox(height: 45),
                Text(
                  'DO IT',
                  style: TextStyle(
                    fontSize: 85,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 15,
                    color: Colors.black.withAlpha((0.06 * 255).round()),
                  ),
                ),

                const SizedBox(height: 5),
                Text(
                  '今日を少しだけ進めよう',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.blueGrey[400]!.withAlpha((0.7 * 255).round()),
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
