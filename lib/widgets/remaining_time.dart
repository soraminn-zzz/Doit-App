import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class RemainingTimeWidget extends StatefulWidget {
  const RemainingTimeWidget({super.key});

  @override
  State<RemainingTimeWidget> createState() => _RemainingTimeWidgetState();
}

class _RemainingTimeWidgetState extends State<RemainingTimeWidget> with TickerProviderStateMixin {
  String _sleepTimeString = "計算中...";
  String _actionTimeString = "計算中...";
  String _currentQuote = ""; 
  String _statusTitle = "分析中";
  String _statusDesc = "状況を確認しています";
  String _statusDetail = "短い時間で区切って、まずは1つの作業に集中するのがおすすめです。"; 
  
  double _finalEnergy = 0.0;
  bool _isStatusExpanded = false; 
  late Timer _timer;

  late AnimationController _barController;
  late Animation<double> _barAnimation;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // 🌟 あなたが決めるオリジナル名言リスト
  final List<String> _quotes = [
    "まだ時間は残されてる。自分のペースでいこう。",
    "25分だけでも前進。小さな一歩で大成功。",
    "今日はここからでOK。ハードルは地面まで下げていい。",
    "仕切り直そう。ここからの数時間はあなたのもの。",
    "完璧じゃなくていい。まずは1分だけ、軽くいこう。",
    "今日を生きただけで満点。リラックスして始めよう。",
  ];

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    
    _calculateActionTime();

    // 🌟 バーのアニメーション：10秒かけてスーーッと伸びる
    _barController = AnimationController(
      duration: const Duration(milliseconds: 10000), 
      vsync: this,
    );
    
    _barAnimation = Tween<double>(begin: 0.0, end: _finalEnergy).animate(
      CurvedAnimation(parent: _barController, curve: Curves.easeOutQuint),
    );

    // 文字のフェードイン（3秒）
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 3000), 
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    // 🌟 2秒じーーっと待ってからアニメーションをスタートさせる
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (mounted) {
          _barController.forward();   
          _fadeController.forward();  
        }
      });
    });

    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _calculateActionTime();
      if (mounted) {
        _barController.value = _finalEnergy;
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _barController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _calculateActionTime() {
    final now = DateTime.now();
    DateTime targetSleepTime = DateTime(now.year, now.month, now.day, 1, 0, 0);
    if (now.isAfter(targetSleepTime)) {
      targetSleepTime = targetSleepTime.add(const Duration(days: 1));
    }

    final difference = targetSleepTime.difference(now);
    final totalRemainingMinutes = difference.inMinutes;

    if (totalRemainingMinutes <= 0) {
      if (mounted) {
        setState(() {
          _sleepTimeString = "睡眠予定時間を迎えました";
          _actionTimeString = "しっかり休んで、また明日";
          _statusTitle = "💤 休息モード";
          _statusDesc = "今日もお疲れ様でした";
          _statusDetail = "明日のあなたにバトンを渡して、ゆっくり休みましょう。";
          _finalEnergy = 0.0;
        });
      }
      return;
    }

    double coefficient = 0.6;
    final currentHour = now.hour;

    if (currentHour >= 5 && currentHour < 12) {
      coefficient = 0.7;
      _statusTitle = "🌅 朝モード";
      _statusDesc = "ここからゆっくりエンジンをかけよう";
      _statusDetail = "午前中は無理せず、今日やりたいことを頭の中で整理するだけで十分です。";
    } else if (currentHour >= 12 && currentHour < 17) {
      coefficient = 0.7;
      _statusTitle = "☀️ 昼〜夕方モード";
      _statusDesc = "無理のない範囲で、やりたいことを1つだけ";
      _statusDetail = "一番動きやすい時間帯。重いタスクではなく、15分で終わる簡単なことからリスタート。";
    } else if (currentHour >= 17 && currentHour < 23) {
      coefficient = 0.6;
      _statusTitle = "🌇 夜モード";
      _statusDesc = "まだ数時間ある。小さく再開しよう";
      _statusDetail = "夜は短時間タスクがおすすめ。休憩や食事を挟みつつ、自分のペースを崩さずに。";
    } else {
      coefficient = 0.4;
      _statusTitle = "🌙 深夜モード";
      _statusDesc = "短時間タスク向き。無理は禁物";
      _statusDetail = "深夜はエネルギーが切れやすい時間。今日のうちに片付けたい小さなことだけサクッと。";
    }

    final actionMinutesTotal = (totalRemainingMinutes * coefficient).round();
    final sleepHours = totalRemainingMinutes ~/ 60;
    final sleepMinutes = totalRemainingMinutes % 60;
    final actionHours = actionMinutesTotal ~/ 60;
    final actionMinutes = actionMinutesTotal % 60;

    if (mounted) {
      setState(() {
        if (sleepHours > 0) {
          _sleepTimeString = "睡眠まで 約 $sleepHours 時間 $sleepMinutes 分";
        } else {
          _sleepTimeString = "睡眠まで 約 $sleepMinutes 分";
        }

        if (actionHours > 0) {
          _actionTimeString = "集中できそう 約 $actionHours 時間 $actionMinutes 分";
        } else {
          _actionTimeString = "集中できそう 約 $actionMinutes 分";
        }

        _finalEnergy = (totalRemainingMinutes / (24 * 60)).clamp(0.0, 1.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const List<Color> themeColors = [Color(0xFF5E35B1), Color(0xFF1A237E)];

    // 🌟 1. 時間帯によってカードの背景色をじんわり変える判定
    Color cardBgColor = Colors.white;
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      cardBgColor = const Color(0xFFFFFDF9); // 朝：爽やかな薄クリーム
    } else if (hour >= 12 && hour < 17) {
      cardBgColor = const Color(0xFFFAFAFA); // 昼：すっきりした白
    } else if (hour >= 17 && hour < 23) {
      cardBgColor = const Color(0xFFF5F5FA); // 夜：落ち着いた淡い青紫
    } else {
      cardBgColor = const Color(0xFFEDEBF5); // 深夜：目に優しいラベンダーグレー
    }

    return Container(
      padding: const EdgeInsets.all(25),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        // 時間帯ごとの背景色 ＋ 0.96の透明度
        color: cardBgColor.withAlpha((0.96 * 255).round()),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: themeColors.first.withAlpha((0.06 * 255).round()),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "🔋 行動可能エネルギー",
                style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              Text(
                "${(_finalEnergy * 100).toStringAsFixed(0)} %", 
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: themeColors.first),
              ),
            ],
          ),
          const SizedBox(height: 10),

          AnimatedBuilder(
            animation: _barAnimation,
            builder: (context, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: _barAnimation.value, 
                    backgroundColor: Colors.grey.withAlpha((0.12 * 255).round()),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF5E35B1)),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 25),

          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  Text(
                    _sleepTimeString,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.blueGrey[600]),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _actionTimeString,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF1A237E),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "※休憩や食事を含めた目安",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 25),

          // 🌟 2. 触ると「ぷにっ」と縮むステータスカード（夜モードなど）
          PuniTouchable(
            onTap: () {
              setState(() {
                _isStatusExpanded = !_isStatusExpanded; 
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _isStatusExpanded ? themeColors.first.withAlpha((0.03 * 255).round()) : Colors.grey[50],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isStatusExpanded ? themeColors.first.withAlpha((0.2 * 255).round()) : Colors.grey.withAlpha((0.15 * 255).round()),
                  width: 1
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _statusTitle,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A237E)),
                      ),
                      const SizedBox(width: 4),
                      // 🌟 3. 矢印がフワッと180度回転するアニメーション
                      AnimatedRotation(
                        turns: _isStatusExpanded ? 0.5 : 0.0, 
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _statusDesc,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        _statusDetail,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: themeColors.first.withAlpha((0.8 * 255).round()), height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ),
                    crossFadeState: _isStatusExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 15),
          
          // 🌟 4. 触ると「ぷにっ」と縮み、タップで名言が変わるカード
          PuniTouchable(
            onTap: () {
              setState(() {
                _currentQuote = _quotes[Random().nextInt(_quotes.length)];
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: themeColors.first.withAlpha((0.05 * 255).round()),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColors.first.withAlpha((0.08 * 255).round()), width: 1),
              ),
              child: Text(
                _currentQuote,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: themeColors.first.withAlpha((0.85 * 255).round()),
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 5. 上品なiOS風マイクロインタラクション（ぷにっエフェクト）の仕組み
class PuniTouchable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const PuniTouchable({super.key, required this.child, this.onTap});

  @override
  State<PuniTouchable> createState() => _PuniTouchableState();
}

class _PuniTouchableState extends State<PuniTouchable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0, 
        duration: const Duration(milliseconds: 120), 
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(_isPressed ? 12 : 0), 
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}