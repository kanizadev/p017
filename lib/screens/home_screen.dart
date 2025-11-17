import 'package:flutter/material.dart';
import 'sudoku_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedGridSize = 9;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F8F6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 60),
              // Logo/Title
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8BA893), Color(0xFF6B8E6F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF6B8E6F).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      selectedGridSize.toString(),
                      style: TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Title
              Text(
                'Sudoku Master',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B8E6F),
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 12),
              // Subtitle
              Text(
                'Challenge Your Mind',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF8BA893),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 48),
              // Grid Size Selection
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Grid Size',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B8E6F),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildGridSizeButton(6, '6×6'),
                        _buildGridSizeButton(9, '9×9'),
                        _buildGridSizeButton(16, '16×16'),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 48),
              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'How to Play',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B8E6F),
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Fill the $selectedGridSize×$selectedGridSize grid so that every row, column, and box contains the required digits without repetition.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeature('Undo', Icons.undo),
                          _buildFeature('Hints', Icons.lightbulb),
                          _buildFeature('Notes', Icons.edit),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 48),
              // Difficulty Selection
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Difficulty',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6B8E6F),
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDifficultyButton(
                      context,
                      'Easy',
                      'For Beginners',
                      Color(0xFF9FD882),
                    ),
                    SizedBox(height: 12),
                    _buildDifficultyButton(
                      context,
                      'Medium',
                      'Intermediate',
                      Color(0xFF8BA893),
                    ),
                    SizedBox(height: 12),
                    _buildDifficultyButton(
                      context,
                      'Hard',
                      'Challenging',
                      Color(0xFF6B8E6F),
                    ),
                    SizedBox(height: 12),
                    _buildDifficultyButton(
                      context,
                      'Expert',
                      'Master Level',
                      Color(0xFF5A7A5E),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridSizeButton(int size, String label) {
    final isSelected = selectedGridSize == size;
    return GestureDetector(
      onTap: () {
        setState(() => selectedGridSize = size);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Color(0xFF8BA893), Color(0xFF6B8E6F)]
                : [Color(0xFFE8F1EB), Color(0xFFD4E4D8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Color(0xFF6B8E6F).withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 6 : 3),
            ),
          ],
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Color(0xFF6B8E6F),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Grid',
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white70 : Color(0xFF8BA893),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFE8F1EB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Icon(icon, color: Color(0xFF6B8E6F), size: 24)),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B8E6F),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyButton(
    BuildContext context,
    String title,
    String subtitle,
    Color color,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => SudokuGame(
              difficulty: title.toLowerCase(),
              gridSize: selectedGridSize,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            Icon(Icons.play_arrow, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}
