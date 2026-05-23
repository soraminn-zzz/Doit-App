import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; 

class RemainingTimeWidget extends StatefulWidget {
  const RemainingTimeWidget({super.key});

  @override
  State<RemainingTimeWidget> createState() => _RemainingTimeWidgetState();
}

class _RemainingTimeWidgetState extends State<RemainingTimeWidget> with TickerProviderStateMixin {
  TimeOfDay _sleepTime = const TimeOfDay(hour: 1, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 8, minute: 0);

  String _sleepTimeString = "計 算 中";
  String _actionTimeString = "-- : --";
  String _currentQuote = ""; 
  String _statusTitle = "分 析 中";
  String _statusDesc = "状況を確認しています";
  String _statusDetail = "短い時間で区切って、まずは1つの作業に集中するのがおすすめです。"; 
  
  double _finalEnergy = 0.0;
  bool _isStatusExpanded = false; 
  late Timer _timer;

  late AnimationController _floatController; 
  late AnimationController _fadeController;
  late AnimationController _shimmerController; 

  final List<String> _quotes = [
    "まだ時間は残されてる。自分のペースでいこう。",
    "25分だけでも前進。小さな一歩で大成功。",
    "今日はここからでOK。ハードルは地面まで下げていい。",
    "仕切り直そう。ここからの数時間、可能性は無限。",
    "完璧じゃなくていい。まずは1分だけ、軽くいこう。",
    "今日を生きただけで満点。リラックスして始めよう。",
  ];

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    _calculateActionTime();

    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500), 
      vsync: this,
    )..forward();

    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      _calculateActionTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _floatController.dispose();
    _fadeController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  void _calculateActionTime() {
    final now = DateTime.now();
    
    DateTime targetSleepTime = DateTime(now.year, now.month, now.day, _sleepTime.hour, _sleepTime.minute, 0);
    if (now.isAfter(targetSleepTime)) {
      targetSleepTime = targetSleepTime.add(const Duration(days: 1));
    }

    final difference = targetSleepTime.difference(now);
    final totalRemainingMinutes = difference.inMinutes;

    bool isSleepingZone = false;
    
    if (_sleepTime.hour > _wakeTime.hour) {
      if (now.hour >= _sleepTime.hour || now.hour < _wakeTime.hour) {
        isSleepingZone = true;
      }
    } else {
      if (now.hour >= _sleepTime.hour && now.hour < _wakeTime.hour) {
        isSleepingZone = true;
      }
    }

    if (totalRemainingMinutes <= 0 || isSleepingZone) {
      if (mounted) {
        setState(() {
          _sleepTimeString = "休息の時間";
          _actionTimeString = "Good Night";
          _statusTitle = "💤 休息モード";
          _statusDesc = "今日もお疲れ様でした";
          _statusDetail = "明日のあなたにバトンを渡して、ゆっくり休みましょう。";
          _finalEnergy = 0.0;
        });
      }
      return;
    }

    double coefficient = 0.6;
    final hoursUntilSleep = totalRemainingMinutes / 60;

    if (hoursUntilSleep > 12) {
      coefficient = 0.7;
      _statusTitle = "🌅 朝モード";
      _statusDesc = "ここからゆっくりエンジンをかけよう";
      _statusDetail = "午前中は無理せず、今日やりたいことを頭の中で整理するだけで十分です。";
    } else if (hoursUntilSleep > 6) {
      coefficient = 0.7;
      _statusTitle = "☀️ 昼〜夕方モード";
      _statusDesc = "無理のない範囲で、やりたいことを1つだけ";
      _statusDetail = "一番動きやすい時間帯。重いタスクではなく、15分で終わる簡単なことからリスタート。";
    } else if (hoursUntilSleep > 2) {
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
          _actionTimeString = "約 $actionHours 時間 $actionMinutes 分";
        } else {
          _actionTimeString = "約 $actionMinutes 分";
        }

        _finalEnergy = (totalRemainingMinutes / (24 * 60)).clamp(0.0, 1.0);
      });
    }
  }

  void _showTimePickerSheet(BuildContext context, bool isSleepTime) {
    final hour = DateTime.now().hour;
    final isDark = hour >= 17 || hour < 5;
    
    TimeOfDay initialTime = isSleepTime ? _sleepTime : _wakeTime;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF16162A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (BuildContext builder) {
        return SizedBox(
          height: 280,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Text(
                isSleepTime ? "睡眠時間の調整" : "起床時間の調整",
                style: TextStyle(
                  fontSize: 14, 
                  fontWeight: FontWeight.bold, 
                  color: isDark ? Colors.white : const Color(0xFF151B54),
                  letterSpacing: 0.5
                ),
              ),
              Expanded(
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: isDark ? Brightness.dark : Brightness.light,
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(2026, 1, 1, initialTime.hour, initialTime.minute),
                    onDateTimeChanged: (DateTime newDateTime) {
                      setState(() {
                        if (isSleepTime) {
                          _sleepTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                        } else {
                          _wakeTime = TimeOfDay(hour: newDateTime.hour, minute: newDateTime.minute);
                        }
                        _calculateActionTime(); 
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hourStr = time.hour.toString().padLeft(2, '0');
    final minStr = time.minute.toString().padLeft(2, '0');
    return "$hourStr:$minStr";
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final isDark = hour >= 17 || hour < 5;

    Color cardBgColor = isDark ? const Color(0xFF111122) : Colors.white;
    Color textColor = isDark ? Colors.white : const Color(0xFF151B54);
    Color subTextColor = isDark ? Colors.white.withValues(alpha: 0.55) : Colors.blueGrey[600]!;
    Color accentColor = isDark ? const Color(0xFF9966FF) : const Color(0xFF6200EE);

    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final double floatOffsetY = sin(_floatController.value * pi) * 8; 
        return Transform.translate(
          offset: Offset(0, floatOffsetY),
          child: child,
        );
      },
      child: FadeTransition(
        opacity: _fadeController,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520), 
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: cardBgColor.withValues(alpha: isDark ? 0.82 : 0.95),
            borderRadius: BorderRadius.circular(38), 
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withValues(alpha: 0.45) : accentColor.withValues(alpha: 0.05),
                blurRadius: 45,
                offset: const Offset(0, 22),
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
                    "ENERGY",
                    style: TextStyle(fontSize: 10.5, color: subTextColor, fontWeight: FontWeight.w800, letterSpacing: 2.5),
                  ),
                  Text(
                    "${(_finalEnergy * 100).toStringAsFixed(0)} %", 
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentColor, letterSpacing: 0.5),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: _finalEnergy),
                duration: const Duration(milliseconds: 1800),
                curve: Curves.easeOutQuint, 
                builder: (context, barValue, child) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 7,
                          child: LinearProgressIndicator(
                            value: barValue, 
                            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                            valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return FractionalTranslation(
                                translation: Offset(-1.0 + (_shimmerController.value * 2.0), 0.0),
                                child: child,
                              );
                            },
                            child: FractionallySizedBox(
                              widthFactor: 0.25, 
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: isDark ? 0.22 : 0.4),
                                      Colors.white.withValues(alpha: 0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 40),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 600),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: Column(
                  key: ValueKey<String>(_actionTimeString), 
                  children: [
                    Text(
                      _sleepTimeString,
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: subTextColor, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _actionTimeString,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40, 
                        fontWeight: FontWeight.w900,
                        color: textColor,
                        letterSpacing: -1.2,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 6),
              Text(
                "＊食事や休憩を含めない時間", 
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.blueGrey[300],
                  letterSpacing: 0.4,
                ),
              ),
              
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PuniTouchable(
                    onTap: () => _showTimePickerSheet(context, true),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.dark_mode_outlined, size: 12, color: accentColor.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(_sleepTime),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    "⟶",
                    style: TextStyle(fontSize: 12, color: subTextColor.withValues(alpha: 0.4)),
                  ),
                  PuniTouchable(
                    onTap: () => _showTimePickerSheet(context, false),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: Row(
                        children: [
                          Icon(Icons.light_mode_outlined, size: 12, color: Colors.orange.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(_wakeTime),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: textColor.withValues(alpha: 0.8)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24), 

              PuniTouchable(
                onTap: () {
                  setState(() {
                    _isStatusExpanded = !_isStatusExpanded; 
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.fastOutSlowIn,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: BoxDecoration(
                    color: _isStatusExpanded 
                        ? accentColor.withValues(alpha: 0.04) 
                        : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey[50]),
                    borderRadius: BorderRadius.circular(22), 
                    border: Border.all(
                      color: _isStatusExpanded 
                          ? accentColor.withValues(alpha: 0.18) 
                          : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04)),
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
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: textColor, letterSpacing: 0.5),
                          ),
                          const SizedBox(width: 6),
                          AnimatedRotation(
                            turns: _isStatusExpanded ? 0.5 : 0.0, 
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            child: Icon(Icons.keyboard_arrow_down, size: 16, color: subTextColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusDesc,
                        style: TextStyle(fontSize: 11, color: subTextColor, fontWeight: FontWeight.w500),
                      ),
                      AnimatedCrossFade(
                        firstChild: const SizedBox.shrink(),
                        secondChild: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            _statusDetail,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12, 
                              color: isDark ? Colors.white.withValues(alpha: 0.7) : accentColor.withValues(alpha: 0.75), 
                              height: 1.55, 
                              fontWeight: FontWeight.w500
                            ),
                          ),
                        ),
                        crossFadeState: _isStatusExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 300),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              PuniTouchable(
                onTap: () {
                  setState(() {
                    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: isDark ? 0.07 : 0.03),
                    borderRadius: BorderRadius.circular(22), 
                    border: Border.all(color: accentColor.withValues(alpha: 0.06), width: 1),
                  ),
                  child: Text(
                    _currentQuote,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : accentColor.withValues(alpha: 0.8),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    final isDark = DateTime.now().hour >= 17 || DateTime.now().hour < 5;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0, 
        duration: const Duration(milliseconds: 100), 
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _isPressed ? 0.0 : (isDark ? 0.18 : 0.025)), 
                blurRadius: _isPressed ? 0 : 14,
                offset: _isPressed ? Offset.zero : const Offset(0, 6),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}