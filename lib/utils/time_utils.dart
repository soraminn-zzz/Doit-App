// lib/utils/time_utils.dart
/// 時間ユーティリティ（テストしやすく、安全に扱う）
///
/// DateTime の比較はタイムゾーンの差で挙動が変わるため UTC に正規化して計算する。

int remainingMinutes(DateTime bedtime, {DateTime? now}) {
  final current = (now ?? DateTime.now()).toUtc();
  final bd = bedtime.toUtc();
  final diff = bd.difference(current);
  return diff.isNegative ? 0 : diff.inMinutes;
}

Duration remainingDuration(DateTime bedtime, {DateTime? now}) {
  final current = (now ?? DateTime.now()).toUtc();
  final bd = bedtime.toUtc();
  final diff = bd.difference(current);
  return diff.isNegative ? Duration.zero : diff;
}

/// タスク所要時間（Duration）でベッドタイムまで完了可能か
bool canComplete(Duration taskDuration, DateTime bedtime, {DateTime? now}) {
  return remainingDuration(bedtime, now: now) >= taskDuration;
}

/// Duration を「1時間30分」など日本語で整形
String formatDurationJapanese(Duration d) {
  if (d <= Duration.zero) return '0分';
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0 && m > 0) return '${h}時間${m}分';
  if (h > 0) return '${h}時間';
  return '${m}分';
}

Duration minutesToDuration(int minutes) {
  final m = minutes < 0 ? 0 : (minutes > 1000000 ? 1000000 : minutes);
  return Duration(minutes: m);
}

int durationToMinutes(Duration d) => d.inMinutes;
