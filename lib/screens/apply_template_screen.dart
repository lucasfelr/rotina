import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/index.dart';
import '../services/daily_routine_service.dart';
import '../widgets/task_tile.dart';

class ApplyTemplateScreen extends StatefulWidget {
  final Template template;
  final DailyRoutineService dailyRoutineService;
  final bool isResuming;

  const ApplyTemplateScreen({
    Key? key,
    required this.template,
    required this.dailyRoutineService,
    this.isResuming = false,
  }) : super(key: key);

  @override
  State<ApplyTemplateScreen> createState() => _ApplyTemplateScreenState();
}

class _ApplyTemplateScreenState extends State<ApplyTemplateScreen> {
  late List<Task> _todayTasks;

  @override
  void initState() {
    super.initState();
    if (widget.isResuming) {
      // Carregar tarefas salvas de hoje
      final dailyRoutineData = widget.dailyRoutineService.getDailyRoutine();
      if (dailyRoutineData != null) {
        _todayTasks = (dailyRoutineData['tasks'] as List<dynamic>)
            .map((task) => Task.fromJson(task as Map<String, dynamic>))
            .toList();
      } else {
        _todayTasks = widget.template.tasks
            .map((task) => task.copyWith(isCompleted: false))
            .toList();
      }
    } else {
      // Criar nova rotina do dia
      _todayTasks = widget.template.tasks
          .map((task) => task.copyWith(isCompleted: false))
          .toList();
      _saveDailyRoutine();
    }
  }

  void _saveDailyRoutine() {
    widget.dailyRoutineService.saveDailyRoutine(widget.template, _todayTasks);
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _todayTasks[index] = _todayTasks[index].copyWith(
        isCompleted: !_todayTasks[index].isCompleted,
      );
      _saveDailyRoutine();
    });
  }

    @override
  Widget build(BuildContext context) {
    final todayDate = DateFormat('EEEE, d \'de\' MMMM', 'pt_BR').format(DateTime.now());
    final completedCount = _todayTasks.where((task) => task.isCompleted).length;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotina do Dia'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.template.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      todayDate,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$completedCount/${_todayTasks.length} concluídas',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              if (_todayTasks.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        Icon(Icons.task_alt, size: 48, color: colorScheme.outline),
                        const SizedBox(height: 8),
                        Text(
                          'Nenhuma tarefa neste template',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Column(
                  children: _todayTasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    return TaskTile(
                      task: task,
                      onToggle: () => _toggleTaskCompletion(index),
                      onEdit: () {},
                      onDelete: () {},
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
