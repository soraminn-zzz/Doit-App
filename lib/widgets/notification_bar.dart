import 'package:flutter/material.dart';
import '../utils/notification_logic.dart';
import '../screens/task_suggestion_page.dart';

class NotificationBar extends StatefulWidget {
  const NotificationBar({super.key});

  @override
  State<NotificationBar> createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar> {
  String message = '';
  bool isCompleted = false;
  bool showCenter = false;

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    final msg = await NotificationService().buildNotificationFromStorage();

    setState(() {
      message = msg;
    });
  }

  String getCharacter() {
    return isCompleted
        ? 'assets/101_20260524045934happy.jpg'
        : 'assets/IMG_0844normal.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TaskSuggestionPage(),
                  ),
                );

                if (result != null) {
                  setState(() {
                    message = "「$result」をやりましょう！";
                  });
                }
              },
              child: Container(
                margin: const EdgeInsets.all(10),
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Row(
                  children: [
                    Image.asset(getCharacter(), width: 120),

                    const SizedBox(width: 10),

                    Expanded(child: Text(message)),

                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isCompleted = true;
                          showCenter = true;
                        });

                        Future.delayed(const Duration(seconds: 2), () {
                          setState(() => showCenter = false);
                        });
                      },
                      child: const Text("完了"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        if (showCenter)
          Container(
            color: Colors.black.withOpacity(0.4),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(getCharacter(), width: 250),

                  const SizedBox(height: 10),

                  const Text(
                    "よくできました！",
                    style: TextStyle(color: Colors.white, fontSize: 28),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}