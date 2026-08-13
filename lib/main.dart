import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/services/ad_service.dart';
import 'screens/main_menu_screen.dart';
import 'services/gemini_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Trava orientação em Paisagem (Landscape) e Ativa Tela Cheia
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  await GeminiService().init();
  await AdService().init();

  runApp(const RastrosSnakeApp());
}

class RastrosSnakeApp extends StatelessWidget {
  const RastrosSnakeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rastros Snake',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E293B),
      ),
      home: const MainMenuScreen(),
    );
  }
}
