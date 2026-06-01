class Task {
  final String id;
  String title;
  String time;
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  // Converter para JSON para armazenamento
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': time,
    'isCompleted': isCompleted,
  };

  // Converter de JSON para objeto
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String,
    title: json['title'] as String,
    time: json['time'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );

  // Criar cópia com mudanças
  Task copyWith({
    String? id,
    String? title,
    String? time,
    bool? isCompleted,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    time: time ?? this.time,
    isCompleted: isCompleted ?? this.isCompleted,
  );
}
