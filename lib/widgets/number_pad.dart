import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumberPad extends StatelessWidget {
  final int? selectedNumber;
  final ValueChanged<int> onNumberSelected;
  final int gridSize;
  final Set<int>? validMoves;

  const NumberPad({
    super.key,
    required this.selectedNumber,
    required this.onNumberSelected,
    required this.gridSize,
    this.validMoves,
  });

  static String _symbolFor(int value) {
    if (value <= 9) return value.toString();
    return String.fromCharCode('A'.codeUnitAt(0) + (value - 10));
  }

  @override
  Widget build(BuildContext context) {
    final buttonSize = gridSize == 16 ? 40.0 : 50.0;
    final fontSize = gridSize == 16 ? 18.0 : 24.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6B8E6F).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: List.generate(gridSize, (index) {
          final number = index + 1;
          final isSelected = selectedNumber == number;
          final isValidMove =
              validMoves == null || validMoves!.contains(number);
          return GestureDetector(
            onTap: () => onNumberSelected(number),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: buttonSize,
              height: buttonSize,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Color(0xFF8BA893), Color(0xFF6B8E6F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : (validMoves != null && !isValidMove)
                    ? LinearGradient(
                        colors: [Color(0xFFE8E8E8), Color(0xFFD8D8D8)],
                      )
                    : LinearGradient(
                        colors: [Color(0xFFE8F1EB), Color(0xFFD4E4D8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.circular(14),
                border: isSelected
                    ? Border.all(color: Color(0xFF5A7A5D), width: 2)
                    : null,
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? Color(0xFF6B8E6F).withValues(alpha: 0.4)
                        : (validMoves != null && !isValidMove
                              ? Colors.grey.withValues(alpha: 0.1)
                              : Color(0xFF8BA893).withValues(alpha: 0.2)),
                    blurRadius: isSelected ? 12 : 8,
                    offset: Offset(0, isSelected ? 6 : 3),
                    spreadRadius: isSelected ? 1 : 0,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onNumberSelected(number),
                  borderRadius: BorderRadius.circular(12),
                  splashColor: Color(0xFF8BA893).withValues(alpha: 0.3),
                  child: Center(
                    child: Text(
                      _symbolFor(number),
                      style: GoogleFonts.comfortaa(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : (validMoves != null && !isValidMove
                                  ? Color(0xFFB0B0B0)
                                  : Color(0xFF6B8E6F)),
                        shadows: isSelected
                            ? [
                                Shadow(
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withValues(alpha: 0.2),
                                ),
                              ]
                            : [],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
