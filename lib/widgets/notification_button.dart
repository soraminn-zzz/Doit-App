import 'package:flutter/material.dart';
import '../utils/notification_logic.dart';

class NotificationButton extends StatelessWidget {
  const NotificationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final msg = await NotificationService()
            .buildNotificationFromStorage();

        if (msg.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('通知するタスクが見つかりません'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(msg)),
          );
        }
      },
      child: const Text('通知する'),
    );
  }
}