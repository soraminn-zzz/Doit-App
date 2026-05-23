import 'package:flutter/material.dart';

class NotificationBar extends StatelessWidget {
  final String message;

  const NotificationBar({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) {
      return SizedBox(); // 何も表示しない
    }

    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}