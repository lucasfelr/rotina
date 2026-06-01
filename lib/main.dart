import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'services/template_service.dart';
import 'services/daily_routine_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final templateService = TemplateService();
  await templateService.init();
  final dailyRoutineService = DailyRoutineService();
  await dailyRoutineService.init();
  runApp(MyApp(
    templateService: templateService,
    dailyRoutineService: dailyRoutineService,
  ));
}

class MyApp extends StatelessWidget {
  final TemplateService templateService;
  final DailyRoutineService dailyRoutineService;

  const MyApp({
    Key? key,
    required this.templateService,
    required this.dailyRoutineService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rotinas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
      home: HomeScreen(
        templateService: templateService,
        dailyRoutineService: dailyRoutineService,
      ),
    );
  }
}

