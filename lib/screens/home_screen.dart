import 'package:flutter/material.dart';
import '../models/index.dart';
import '../services/template_service.dart';
import '../services/daily_routine_service.dart';
import 'template_editor_screen.dart';
import 'apply_template_screen.dart';

class HomeScreen extends StatefulWidget {
  final TemplateService templateService;
  final DailyRoutineService dailyRoutineService;

  const HomeScreen({
    Key? key,
    required this.templateService,
    required this.dailyRoutineService,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  late List<Template> _templates;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTemplates();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadTemplates();
    }
  }

  void _loadTemplates() {
    setState(() {
      _templates = widget.templateService.getAllTemplates();
    });
  }

  void _openTemplateEditor({Template? template}) async {
    final result = await Navigator.of(context).push<Template>(
      MaterialPageRoute(
        builder: (context) => TemplateEditorScreen(template: template),
      ),
    );

    if (result != null) {
      if (template == null) {
        await widget.templateService.addTemplate(result);
      } else {
        await widget.templateService.updateTemplate(result);
      }
      _loadTemplates();
    }
  }

    void _deleteTemplate(Template template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Template'),
        content: Text('Deseja deletar o template "${template.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await widget.templateService.deleteTemplate(template.id);
              if (!mounted) return;
              Navigator.of(context).pop();
              _loadTemplates();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Template deletado com sucesso')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
  }

  void _duplicateTemplate(Template template) async {
    await widget.templateService.duplicateTemplate(template.id);
    _loadTemplates();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template "${template.name} (Cópia)" criado com sucesso')),
      );
    }
  }

  void _applyTemplate(Template template) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ApplyTemplateScreen(
          template: template,
          dailyRoutineService: widget.dailyRoutineService,
        ),
      ),
    );
    if (mounted) {
      _loadTemplates();
    }
  }

    @override
  Widget build(BuildContext context) {
    final hasDailyRoutine = widget.dailyRoutineService.hasDailyRoutine();
    final dailyRoutineData = hasDailyRoutine
        ? widget.dailyRoutineService.getDailyRoutine()
        : null;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rotinas'),
      ),
      body: _templates.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum template criado',
                    style: TextStyle(
                      fontSize: 18,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Crie seu primeiro template para começar',
                    style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (hasDailyRoutine && dailyRoutineData != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              final templateId = dailyRoutineData['templateId'];
                              final template =
                                  widget.templateService.getTemplateById(templateId);
                              if (template != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ApplyTemplateScreen(
                                      template: template,
                                      dailyRoutineService: widget.dailyRoutineService,
                                      isResuming: true,
                                    ),
                                  ),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorScheme.onPrimary.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.today,
                                      color: colorScheme.onPrimary,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Rotina de Hoje',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          dailyRoutineData['templateName'] ?? '',
                                          style: TextStyle(
                                            color: colorScheme.onPrimary.withOpacity(0.9),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: colorScheme.onPrimary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemCount: _templates.length,
                      itemBuilder: (context, index) {
                        final template = _templates[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              template.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '${template.tasks.length} tarefa${template.tasks.length != 1 ? 's' : ''}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14,
                              ),
                            ),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'apply') {
                                  _applyTemplate(template);
                                } else if (value == 'edit') {
                                  _openTemplateEditor(template: template);
                                } else if (value == 'duplicate') {
                                  _duplicateTemplate(template);
                                } else if (value == 'delete') {
                                  _deleteTemplate(template);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                PopupMenuItem(
                                  value: 'apply',
                                  child: Row(
                                    children: [
                                      Icon(Icons.play_arrow, size: 18, color: colorScheme.primary),
                                      const SizedBox(width: 8),
                                      const Text('Aplicar Hoje'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text('Editar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'duplicate',
                                  child: Row(
                                    children: [
                                      Icon(Icons.copy, size: 18),
                                      SizedBox(width: 8),
                                      Text('Duplicar'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 18, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Deletar', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTemplateEditor(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
