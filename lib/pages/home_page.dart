import 'package:flutter/material.dart';
import '../widgets/notification_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doit App'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column( // ← Columnに変更
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Welcome to Doit App!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),

              // 👇 これを追加
              NotificationBar(
                message: 'あと45分あるので、このタスクができます',
              ),
            ],
          ),
        ),
      ),
    );
  }
}