class Task {
  final String id;
  final String title;
  final Duration estimated;
  final int priority; // 大きいほど高優先
  final int casualness; // 大きいほど気軽
  final bool done;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.estimated,
    required this.priority,
    required this.casualness,
    this.done = false,
    DateTime? createdAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        assert(id != ''),
        assert(title != ''),
        assert(!estimated.isNegative),
        assert(priority >= 0),
        assert(casualness >= 0);

  Task copyWith({
    String? id,
    String? title,
    Duration? estimated,
    int? priority,
    int? casualness,
    bool? done,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      estimated: estimated ?? this.estimated,
      priority: priority ?? this.priority,
      casualness: casualness ?? this.casualness,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'estimatedMinutes': estimated.inMinutes,
    'priority': priority,
    'casualness': casualness,
    'done': done,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Task.fromJson(Map<String, dynamic> m) => Task(
    id: m['id'] as String,
    title: m['title'] as String,
    estimated: Duration(minutes: (m['estimatedMinutes'] as num).toInt()),
    priority: (m['priority'] as num).toInt(),
    casualness: (m['casualness'] as num).toInt(),
    done: (m['done'] as bool?) ?? false,
    createdAt: m['createdAt'] != null
        ? DateTime.parse(m['createdAt'] as String)
        : null,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Task &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              title == other.title &&
              estimated == other.estimated &&
              priority == other.priority &&
              casualness == other.casualness &&
              done == other.done;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      estimated.hashCode ^
      priority.hashCode ^
      casualness.hashCode ^
      done.hashCode;

  @override
  String toString() =>
      'Task($id, $title, ${estimated.inMinutes}min, p:$priority, c:$casualness, done:$done)';

  // 比較用ユーティリティ（優先度→気軽さの降順）
  static int compareByPriorityThenCasualness(Task a, Task b) {
    final p = b.priority.compareTo(a.priority);
    return p != 0 ? p : b.casualness.compareTo(a.casualness);
  }
}