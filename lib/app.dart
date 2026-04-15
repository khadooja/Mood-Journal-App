import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

class MindTrackApp extends StatelessWidget {
  const MindTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindTrack',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomeScreen(),
    );
  }

  ThemeData _buildTheme() {
    // Calm lavender-based color palette
    const seedColor = Color(0xFF7C6FCD); // Soft purple — the app's identity color

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
        surface: const Color(0xFFF8F7FF),   // Very light lavender background
        primary: seedColor,
      ),
    );

    return base.copyWith(
      // Apply Inter font globally — clean and modern
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      scaffoldBackgroundColor: const Color(0xFFF8F7FF),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFFF8F7FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF2D2B55),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2D2B55)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Color(0xFF7C6FCD),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),
    );
  }
}
