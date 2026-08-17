import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'services/admob_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AdMobService.init();
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
        scaffoldBackgroundColor: const Color(0xFF141724),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF10B981),
          secondary: Color(0xFFF59E0B),
          surface: Color(0xFF1E2338),
        ),
        textTheme: GoogleFonts.plusJakartaSansTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
