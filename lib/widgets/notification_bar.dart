import 'package:flutter/material.dart';
import '../utils/notification_logic.dart';

class NotificationBar extends StatefulWidget {
  const NotificationBar({super.key});

  @override
  State<NotificationBar> createState() => _NotificationBarState();
}

class _NotificationBarState extends State<NotificationBar>
    with SingleTickerProviderStateMixin {
  String message = '';
  String lastMessage = '';
  bool visible = true;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // ✅ アニメーション設定（ゆっくり）
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _loadNotification();
  }

  Future<void> _loadNotification() async {
    final msg =
        await NotificationService().buildNotificationFromStorage();

    if (!mounted) return;

    setState(() {
      message = msg;
      lastMessage = msg;
      visible = true;
    });

    if (message.isNotEmpty) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 何もなければ表示しない
    if (message.isEmpty && lastMessage.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        // ✅ 通知カード
        if (visible && message.isNotEmpty)
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications,
                        color: Colors.blue, size: 26),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '今のおすすめ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ✅ 閉じるボタン（フェードアウト付き）
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _controller.reverse().then((_) {
                          setState(() {
                            visible = false;
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

        // ✅ 再表示ボタン
        if (!visible && lastMessage.isNotEmpty)
          TextButton(
            onPressed: () {
              setState(() {
                message = lastMessage;
                visible = true;
              });

              _controller.forward(from: 0);
            },
            child: const Text("通知を再表示"),
          ),
      ],
    );
  }
}