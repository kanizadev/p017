import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/sudoku_solver.dart';
import '../logic/sudoku_utils.dart';

class SudokuGrid extends StatelessWidget {
  final List<List<int>> puzzle;
  final List<List<bool>> isFixed;
  final int? selectedRow;
  final int? selectedCol;
  final List<List<Set<int>>>? notes;
  final bool showNotes;
  final List<List<bool>>? conflicts;
  final List<CellPosition>? highlightCells;
  final Function(int, int) onCellSelected;
  final int gridSize;

  const SudokuGrid({
    super.key,
    required this.puzzle,
    required this.isFixed,
    required this.selectedRow,
    required this.selectedCol,
    this.notes,
    this.showNotes = false,
    this.conflicts,
    this.highlightCells,
    required this.onCellSelected,
    required this.gridSize,
  });

  static String _symbolFor(int value) {
    if (value <= 9) return value.toString();
    // 10 -> A, 11 -> B, ... 16 -> G
    return String.fromCharCode('A'.codeUnitAt(0) + (value - 10));
  }

  @override
  Widget build(BuildContext context) {
    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];
    final maxSize = gridSize == 16 ? 500.0 : 400.0;
    final fontSize = gridSize == 16 ? 16.0 : (gridSize == 6 ? 24.0 : 22.0);
    final noteFontSize = gridSize == 16 ? 6.0 : 8.0;
    final noteCrossAxis = gridSize == 16 ? 4 : (gridSize == 6 ? 2 : 3);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Color(0xFF6B8E6F).withValues(alpha: 0.4),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF6B8E6F).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8BA893).withValues(alpha: 0.06),
            Colors.transparent,
          ],
        ),
      ),
      constraints: BoxConstraints(maxHeight: maxSize, maxWidth: maxSize),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridSize,
          childAspectRatio: 1,
        ),
        itemCount: gridSize * gridSize,
        itemBuilder: (context, index) {
          final row = index ~/ gridSize;
          final col = index % gridSize;
          final isSelected = selectedRow == row && selectedCol == col;
          final isThickBorderRight =
              (col + 1) % boxColSize == 0 && col != gridSize - 1;
          final isThickBorderBottom =
              (row + 1) % boxRowSize == 0 && row != gridSize - 1;
          final cellNotes = notes != null ? notes![row][col] : <int>{};
          final hasConflict = conflicts != null && conflicts![row][col];
          final isHighlighted =
              highlightCells != null &&
              highlightCells!.any((pos) => pos.row == row && pos.col == col);

          Color cellColor;
          if (isSelected) {
            cellColor = const Color(0xFFD4E4D8); // Light sage
          } else if (hasConflict) {
            cellColor = Color(0xFFFFE0E0); // Light red
          } else if (isHighlighted) {
            cellColor = const Color(0xFFE8F1EB); // Very light sage
          } else if (isFixed[row][col]) {
            cellColor = Color(0xFFF5F8F6); // Off white
          } else {
            cellColor = Colors.white;
          }

          return GestureDetector(
            onTap: () => onCellSelected(row, col),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: cellColor,
                border: Border(
                  right: BorderSide(
                    color: isThickBorderRight
                        ? Color(0xFF6B8E6F).withValues(alpha: 0.5)
                        : Color(0xFFD4E4D8),
                    width: isThickBorderRight ? 3 : 1,
                  ),
                  bottom: BorderSide(
                    color: isThickBorderBottom
                        ? Color(0xFF6B8E6F).withValues(alpha: 0.5)
                        : Color(0xFFD4E4D8),
                    width: isThickBorderBottom ? 3 : 1,
                  ),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0xFF6B8E6F).withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                          spreadRadius: 1,
                        ),
                      ]
                    : hasConflict
                    ? [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onCellSelected(row, col),
                  splashColor: Color(0xFF8BA893).withValues(alpha: 0.2),
                  child: Center(
                    child: puzzle[row][col] == 0
                        ? (notes != null && cellNotes.isNotEmpty)
                              ? Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: noteCrossAxis,
                                        ),
                                    itemCount: gridSize,
                                    itemBuilder: (context, noteIndex) {
                                      final noteNum = noteIndex + 1;
                                      return Center(
                                        child: Text(
                                          cellNotes.contains(noteNum)
                                              ? _symbolFor(noteNum)
                                              : '',
                                          style: TextStyle(
                                            fontSize: noteFontSize,
                                            color: Color(0xFF8BA893),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : const SizedBox.shrink()
                        : Text(
                            _symbolFor(puzzle[row][col]),
                            style: GoogleFonts.comfortaa(
                              fontSize: fontSize,
                              fontWeight: isFixed[row][col]
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              color: hasConflict
                                  ? Colors.red.shade700
                                  : (isFixed[row][col]
                                        ? Color(0xFF4A5C4D)
                                        : Color(0xFF6B8E6F)),
                            ),
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
