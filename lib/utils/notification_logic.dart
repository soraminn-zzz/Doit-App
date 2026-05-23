String getNotificationMessage(int minutes) {
  if (minutes > 60) {
    return '';
  } else if (minutes > 30) {
    return 'あと1時間以内です';
  } else if (minutes > 10) {
    return '短いタスクができます！';
  } else {
    return 'そろそろ終了準備をしましょう';
  }
}