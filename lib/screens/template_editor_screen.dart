import 'package:flutter/material.dart';
import '../models/index.dart';
import '../widgets/task_tile.dart';
import '../widgets/task_dialog.dart';

class TemplateEditorScreen extends StatefulWidget {
  final Template? template;

  const TemplateEditorScreen({Key? key, this.template}) : super(key: key);

  @override
  State<TemplateEditorScreen> createState() => _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends State<TemplateEditorScreen> {
  late TextEditingController _templateNameController;
  late List<Task> _tasks;

    @override
  void initState() {
    super.initState();
    _templateNameController = TextEditingController(text: widget.template?.name ?? '');
    _tasks = List.from(widget.template?.tasks ?? []);
    _tasks.sort((a, b) => a.time.compareTo(b.time)); // Ordenar por horário
  }

  @override
  void dispose() {
    _templateNameController.dispose();
    super.dispose();
  }

  void _addOrEditTask(Task? task) {
    showDialog(
      context: context,
      builder: (context) => TaskDialog(
        task: task,
        onSave: (newTask) {
          setState(() {
            if (task == null) {
              _tasks.add(newTask);
            } else {
              final index = _tasks.indexWhere((t) => t.id == task.id);
              if (index != -1) {
                _tasks[index] = newTask;
              }
            }
            _tasks.sort((a, b) => a.time.compareTo(b.time)); // Ordenar após salvar
          });
        },
      ),
    );
  }

  void _deleteTask(Task task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
    });
  }

    @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template == null ? 'Novo Template' : 'Editar Template'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _templateNameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Template',
                  hintText: 'Ex: Rotina Matinal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tarefas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => _addOrEditTask(null),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _tasks.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.task_alt, size: 48, color: colorScheme.outline),
                            const SizedBox(height: 8),
                            Text(
                              'Nenhuma tarefa adicionada',
                              style: TextStyle(color: colorScheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: _tasks
                          .map((task) => TaskTile(
                                task: task,
                                onToggle: () {},
                                onEdit: () => _addOrEditTask(task),
                                onDelete: () => _deleteTask(task),
                              ))
                          .toList(),
                    ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_templateNameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Dê um nome ao template')),
                      );
                      return;
                    }

                    final template = Template(
                      id: widget.template?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _templateNameController.text,
                      tasks: _tasks,
                    );

                    Navigator.of(context).pop(template);
                  },
                  child: Text(widget.template == null ? 'Criar Template' : 'Salvar Alterações'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
