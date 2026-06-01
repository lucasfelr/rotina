import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/index.dart';

class DailyRoutineService {
  static const String _dailyRoutineKey = 'daily_routine';
  static const String _dateKey = 'daily_routine_date';
  late SharedPreferences _prefs;

  // Inicializar o serviço
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Obter a rotina de hoje
  Map<String, dynamic>? getDailyRoutine() {
    final today = _getTodayDate();
    final savedDate = _prefs.getString(_dateKey);

    // Se a data salva não é hoje, limpar
    if (savedDate != today) {
      clearDailyRoutine();
      return null;
    }

    final jsonString = _prefs.getString(_dailyRoutineKey);
    if (jsonString == null) return null;

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Salvar rotina do dia
  Future<void> saveDailyRoutine(Template template, List<Task> tasks) async {
    final today = _getTodayDate();
    final data = {
      'templateId': template.id,
      'templateName': template.name,
      'tasks': tasks.map((t) => t.toJson()).toList(),
    };
    final jsonString = jsonEncode(data);
    await _prefs.setString(_dailyRoutineKey, jsonString);
    await _prefs.setString(_dateKey, today);
  }

  // Limpar rotina do dia
  Future<void> clearDailyRoutine() async {
    await _prefs.remove(_dailyRoutineKey);
    await _prefs.remove(_dateKey);
  }

  // Verificar se há rotina para hoje
  bool hasDailyRoutine() {
    final today = _getTodayDate();
    final savedDate = _prefs.getString(_dateKey);

    if (savedDate != today) {
      return false;
    }

    return _prefs.getString(_dailyRoutineKey) != null;
  }

  // Obter data de hoje no formato YYYY-MM-DD
  String _getTodayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
