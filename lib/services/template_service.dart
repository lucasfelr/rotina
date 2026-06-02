import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';

class TemplateService {
  static const String _templatesKey = 'templates';
  late SharedPreferences _prefs;

  // Inicializar o serviço
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Obter todos os templates
  List<Template> getAllTemplates() {
    final jsonString = _prefs.getString(_templatesKey);
    if (jsonString == null) return [];

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((item) => Template.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // Salvar todos os templates
  Future<void> _saveTemplates(List<Template> templates) async {
    final jsonString = jsonEncode(templates.map((t) => t.toJson()).toList());
    await _prefs.setString(_templatesKey, jsonString);
  }

  // Adicionar novo template
  Future<void> addTemplate(Template template) async {
    final templates = getAllTemplates();
    templates.add(template);
    await _saveTemplates(templates);
  }

  // Atualizar template
  Future<void> updateTemplate(Template template) async {
    final templates = getAllTemplates();
    final index = templates.indexWhere((t) => t.id == template.id);
    if (index != -1) {
      templates[index] = template;
      await _saveTemplates(templates);
    }
  }

  // Deletar template
  Future<void> deleteTemplate(String templateId) async {
    final templates = getAllTemplates();
    templates.removeWhere((t) => t.id == templateId);
    await _saveTemplates(templates);
  }

  // Duplicar template
  Future<void> duplicateTemplate(String templateId) async {
    final templates = getAllTemplates();
    final index = templates.indexWhere((t) => t.id == templateId);
    if (index != -1) {
      final original = templates[index];
      final duplicate = Template(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: '${original.name} (Cópia)',
        tasks: original.tasks.map((task) => task.copyWith()).toList(),
      );
      templates.add(duplicate);
      await _saveTemplates(templates);
    }
  }

  // Obter template por ID
  Template? getTemplateById(String id) {
    final templates = getAllTemplates();
    try {
      return templates.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }
}

