List<Map<String, dynamic>> getAvailableTasks({
  required int safeMinutes,
  required List<Map<String, dynamic>> tasks,
}) {
  return tasks.where((task) {
    final minutes = (task['minutes'] is int)
        ? task['minutes'] as int
        : int.tryParse(task['minutes'].toString()) ?? 0;

    return minutes <= safeMinutes;
  }).toList();
}