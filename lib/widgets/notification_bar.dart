import 'package:flutter/material.dart';
import '../utils/notification_logic.dart';
import '../screens/task_suggestion_page.dart';

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

  String selectedTask = '';
  bool isCompleted = false;

  // ✅ 中央表示用
  bool showCenterMessage = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

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
      selectedTask = '';
      isCompleted = false;
    });

    if (message.isNotEmpty) {
      _controller.forward(from: 0);
    }
  }

  String getCharacterImage() {
    if (isCompleted) {
      return 'assets/101_20260524045934happy.jpg';
    }
    return 'assets/IMG_0844normal.jpg';
  }

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty && lastMessage.isEmpty) {
      return const SizedBox();
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            // ✅ 通知カード
            if (visible && message.isNotEmpty)
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const TaskSuggestionPage(),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          selectedTask = result.toString();
                          message = "「$selectedTask」をやりましょう！";
                          isCompleted = false;
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
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
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ✅ キャラ大きくした！
                          Image.asset(
                            getCharacterImage(),
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
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
                                  isCompleted
                                      ? "よくできました！✨"
                                      : message,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(height: 10),

                                // ✅ 完了ボタン
                                if (selectedTask.isNotEmpty &&
                                    !isCompleted)
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isCompleted = true;
                                        showCenterMessage = true;
                                      });

                                      // ✅ 2秒後に消える
                                      Future.delayed(
                                          const Duration(
                                              seconds: 2),
                                          () {
                                        if (!mounted) return;
                                        setState(() {
                                          showCenterMessage =
                                              false;
                                        });
                                      });
                                    },
                                    child:
                                        const Text("完了！"),
                                  ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _controller
                                  .reverse()
                                  .then((_) {
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
              ),

            // ✅ 再表示ボタン
            if (!visible && lastMessage.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() {
                    message = lastMessage;
                    visible = true;
                    selectedTask = '';
                    isCompleted = false;
                  });

                  _controller.forward(from: 0);
                },
                child: const Text("通知を再表示"),
              ),
          ],
        ),

        // ✅ ✅ 中央「よくできました！」
       // ✅ ✅ 中央「よくできました！」＋キャラ
if (showCenterMessage)
  Container(
    color: Colors.black.withOpacity(0.4), // 背景ほんのり暗く
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ キャラ（大きく！）
          Image.asset(
            getCharacterImage(),
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),

          const SizedBox(height: 16),

          // ✅ テキスト
          const Text(
            "よくできました！✨",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  ),
      ],
    );
  }
}