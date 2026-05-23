import 'package:flutter/material.dart';
import 'widgets/remaining_time.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    final backgroundColors = _getBackgroundGradient();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("残り時間アプリ 開発画面"),
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🌟 ここに UniqueKey() を追加しました！
                // これがあることで、リロードした時に必ず 0% からアニメーションがやり直されます
                RemainingTimeWidget(key: UniqueKey()),

                const SizedBox(height: 45),

                Text(
                  "DO IT",
                  style: TextStyle(
                    fontSize: 85, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 15,
                    color: Colors.black.withAlpha((0.06 * 255).round()), 
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "今日を少しだけ進めよう",
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
