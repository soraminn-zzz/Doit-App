import 'dart:convert';

/// Task model used across the app.
/// Keep this file focused on the data structure only.
class Task {
  final String id;
  final String name;
  final int minutes; // duration in minutes
  final bool fixed; // whether task is fixed (recurring)
  final String date; // ISO date string YYYY-MM-DD, optional semantic

  Task({
    required this.id,
    required this.name,
    required this.minutes,
    this.fixed = false,
    required this.date,
  });

  /// Create a Task from a Map (defensive parsing).
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      name: map['name']?.toString() ?? '',
      minutes: map['minutes'] is int
          ? map['minutes'] as int
          : int.tryParse(map['minutes']?.toString() ?? '') ?? 0,
      fixed: map['fixed'] == true,
      date: map['date']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'minutes': minutes,
        'fixed': fixed,
        'date': date,
      };

  factory Task.fromJson(String source) => Task.fromMap(jsonDecode(source));

  String toJson() => jsonEncode(toMap());

  Task copyWith({
    String? id,
    String? name,
    int? minutes,
    bool? fixed,
    String? date,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      minutes: minutes ?? this.minutes,
      fixed: fixed ?? this.fixed,
      date: date ?? this.date,
    );
  }

  @override
  String toString() => 'Task(id: $id, name: $name, minutes: $minutes, fixed: $fixed, date: $date)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
