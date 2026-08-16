import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HujanKataApp());
}

class HujanKataApp extends StatelessWidget {
  const HujanKataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hujan Kata',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5B8DEF),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.baloo2TextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
