import 'package:flutter/material.dart';
import 'package:runhero/game/presentation/pages/run_hero_page.dart';

class RunHeroApp extends StatelessWidget {
  const RunHeroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Run Hero',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xfff6b83f),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xff101521),
        useMaterial3: true,
      ),
      home: const RunHeroPage(),
    );
  }
}
