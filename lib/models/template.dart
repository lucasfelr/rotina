import 'task.dart';

class Template {
  final String id;
  String name;
  List<Task> tasks;

  Template({
    required this.id,
    required this.name,
    required this.tasks,
  });

  // Converter para JSON para armazenamento
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tasks': tasks.map((task) => task.toJson()).toList(),
  };

  // Converter de JSON para objeto
  factory Template.fromJson(Map<String, dynamic> json) => Template(
    id: json['id'] as String,
    name: json['name'] as String,
    tasks: List<Task>.from(
      (json['tasks'] as List<dynamic>).map((task) => Task.fromJson(task as Map<String, dynamic>))
    ),
  );

  // Criar cópia com mudanças
  Template copyWith({
    String? id,
    String? name,
    List<Task>? tasks,
  }) => Template(
    id: id ?? this.id,
    name: name ?? this.name,
    tasks: tasks ?? this.tasks,
  );
}
