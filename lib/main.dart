import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p017/screens/home_screen.dart';

void main() {
  runApp(const SudokuApp());
}

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        textTheme: GoogleFonts.comfortaaTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}
