import 'sudoku_utils.dart';

enum SolvingTechnique {
  nakedSingle,
  hiddenSingle,
  nakedPair,
  hiddenPair,
  nakedTriple,
  hiddenTriple,
  pointingPair,
  boxLineReduction,
  xWing,
  yWing,
  swordfish,
  basicElimination,
}

class SolvingHint {
  final SolvingTechnique technique;
  final String description;
  final List<CellPosition> highlightCells;
  final int? value;
  final CellPosition? targetCell;

  SolvingHint({
    required this.technique,
    required this.description,
    required this.highlightCells,
    this.value,
    this.targetCell,
  });
}

class CellPosition {
  final int row;
  final int col;

  CellPosition(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}

class AdvancedSudokuSolver {
  // Count solutions to check uniqueness
  int countSolutions(
    List<List<int>> puzzle,
    int gridSize, {
    int maxSolutions = 2,
  }) {
    final grid = puzzle.map((row) => List<int>.from(row)).toList();
    return _countSolutionsRecursive(grid, gridSize, maxSolutions);
  }

  int _countSolutionsRecursive(
    List<List<int>> grid,
    int gridSize,
    int maxSolutions,
  ) {
    int solutions = 0;
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          final candidates = getCandidates(grid, row, col, gridSize);
          for (final num in candidates) {
            grid[row][col] = num;
            solutions += _countSolutionsRecursive(grid, gridSize, maxSolutions);
            if (solutions >= maxSolutions) {
              grid[row][col] = 0;
              return solutions;
            }
            grid[row][col] = 0;
          }
          return solutions;
        }
      }
    }
    return 1; // Complete solution found
  }

  Set<int> getCandidates(
    List<List<int>> grid,
    int row,
    int col,
    int gridSize,
  ) {
    final candidates = <int>{};
    for (int i = 1; i <= gridSize; i++) {
      candidates.add(i);
    }

    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];

    // Remove row values
    for (int c = 0; c < gridSize; c++) {
      candidates.remove(grid[row][c]);
    }

    // Remove column values
    for (int r = 0; r < gridSize; r++) {
      candidates.remove(grid[r][col]);
    }

    // Remove box values
    final boxRow = (row ~/ boxRowSize) * boxRowSize;
    final boxCol = (col ~/ boxColSize) * boxColSize;
    for (int r = boxRow; r < boxRow + boxRowSize; r++) {
      for (int c = boxCol; c < boxCol + boxColSize; c++) {
        candidates.remove(grid[r][c]);
      }
    }

    return candidates;
  }

  // Get all candidates for each cell
  List<List<Set<int>>> getAllCandidates(List<List<int>> grid, int gridSize) {
    final candidates = List.generate(
      gridSize,
      (i) => List.generate(gridSize, (j) => <int>{}),
    );

    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          candidates[row][col] = getCandidates(grid, row, col, gridSize);
        }
      }
    }

    return candidates;
  }

  // Find next solving hint
  SolvingHint? findNextHint(List<List<int>> puzzle, int gridSize) {
    final candidates = getAllCandidates(puzzle, gridSize);

    // 1. Naked Single
    final nakedSingle = _findNakedSingle(candidates, gridSize);
    if (nakedSingle != null) return nakedSingle;

    // 2. Hidden Single
    final hiddenSingle = _findHiddenSingle(puzzle, candidates, gridSize);
    if (hiddenSingle != null) return hiddenSingle;

    // 3. Naked Pair
    final nakedPair = _findNakedPair(candidates, gridSize);
    if (nakedPair != null) return nakedPair;

    // 4. Hidden Pair
    final hiddenPair = _findHiddenPair(candidates, gridSize);
    if (hiddenPair != null) return hiddenPair;

    // 5. Pointing Pair/Triple
    final pointing = _findPointingPair(candidates, gridSize);
    if (pointing != null) return pointing;

    // 6. Box Line Reduction
    final boxLine = _findBoxLineReduction(candidates, gridSize);
    if (boxLine != null) return boxLine;

    return null;
  }

  SolvingHint? _findNakedSingle(List<List<Set<int>>> candidates, int gridSize) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (candidates[row][col].length == 1) {
          final value = candidates[row][col].first;
          return SolvingHint(
            technique: SolvingTechnique.nakedSingle,
            description:
                'Naked Single: Cell ($row, $col) can only be $value. It\'s the only candidate.',
            highlightCells: [CellPosition(row, col)],
            value: value,
            targetCell: CellPosition(row, col),
          );
        }
      }
    }
    return null;
  }

  SolvingHint? _findHiddenSingle(
    List<List<int>> puzzle,
    List<List<Set<int>>> candidates,
    int gridSize,
  ) {
    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];

    // Check rows
    for (int row = 0; row < gridSize; row++) {
      final rowCandidates = <int, List<CellPosition>>{};
      for (int col = 0; col < gridSize; col++) {
        if (puzzle[row][col] == 0) {
          for (final candidate in candidates[row][col]) {
            rowCandidates
                .putIfAbsent(candidate, () => [])
                .add(CellPosition(row, col));
          }
        }
      }
      for (final entry in rowCandidates.entries) {
        if (entry.value.length == 1) {
          final pos = entry.value.first;
          return SolvingHint(
            technique: SolvingTechnique.hiddenSingle,
            description:
                'Hidden Single: In row $row, ${entry.key} can only go in cell (${pos.row}, ${pos.col}).',
            highlightCells: entry.value,
            value: entry.key,
            targetCell: pos,
          );
        }
      }
    }

    // Check columns
    for (int col = 0; col < gridSize; col++) {
      final colCandidates = <int, List<CellPosition>>{};
      for (int row = 0; row < gridSize; row++) {
        if (puzzle[row][col] == 0) {
          for (final candidate in candidates[row][col]) {
            colCandidates
                .putIfAbsent(candidate, () => [])
                .add(CellPosition(row, col));
          }
        }
      }
      for (final entry in colCandidates.entries) {
        if (entry.value.length == 1) {
          final pos = entry.value.first;
          return SolvingHint(
            technique: SolvingTechnique.hiddenSingle,
            description:
                'Hidden Single: In column $col, ${entry.key} can only go in cell (${pos.row}, ${pos.col}).',
            highlightCells: entry.value,
            value: entry.key,
            targetCell: pos,
          );
        }
      }
    }

    // Check boxes
    for (int boxRow = 0; boxRow < gridSize; boxRow += boxRowSize) {
      for (int boxCol = 0; boxCol < gridSize; boxCol += boxColSize) {
        final boxCandidates = <int, List<CellPosition>>{};
        for (int r = boxRow; r < boxRow + boxRowSize; r++) {
          for (int c = boxCol; c < boxCol + boxColSize; c++) {
            if (puzzle[r][c] == 0) {
              for (final candidate in candidates[r][c]) {
                boxCandidates
                    .putIfAbsent(candidate, () => [])
                    .add(CellPosition(r, c));
              }
            }
          }
        }
        for (final entry in boxCandidates.entries) {
          if (entry.value.length == 1) {
            final pos = entry.value.first;
            return SolvingHint(
              technique: SolvingTechnique.hiddenSingle,
              description:
                  'Hidden Single: In box ($boxRow, $boxCol), ${entry.key} can only go in cell (${pos.row}, ${pos.col}).',
              highlightCells: entry.value,
              value: entry.key,
              targetCell: pos,
            );
          }
        }
      }
    }

    return null;
  }

  SolvingHint? _findNakedPair(List<List<Set<int>>> candidates, int gridSize) {
    // Check rows
    for (int row = 0; row < gridSize; row++) {
      for (int col1 = 0; col1 < gridSize - 1; col1++) {
        if (candidates[row][col1].length == 2) {
          for (int col2 = col1 + 1; col2 < gridSize; col2++) {
            if (candidates[row][col2] == candidates[row][col1]) {
              final pair = candidates[row][col1];
              final highlightCells = [
                CellPosition(row, col1),
                CellPosition(row, col2),
              ];
              return SolvingHint(
                technique: SolvingTechnique.nakedPair,
                description:
                    'Naked Pair: Cells ($row, $col1) and ($row, $col2) form a pair with values $pair. These values can be removed from other cells in the row.',
                highlightCells: highlightCells,
              );
            }
          }
        }
      }
    }

    // Check columns
    for (int col = 0; col < gridSize; col++) {
      for (int row1 = 0; row1 < gridSize - 1; row1++) {
        if (candidates[row1][col].length == 2) {
          for (int row2 = row1 + 1; row2 < gridSize; row2++) {
            if (candidates[row2][col] == candidates[row1][col]) {
              final pair = candidates[row1][col];
              final highlightCells = [
                CellPosition(row1, col),
                CellPosition(row2, col),
              ];
              return SolvingHint(
                technique: SolvingTechnique.nakedPair,
                description:
                    'Naked Pair: Cells ($row1, $col) and ($row2, $col) form a pair with values $pair. These values can be removed from other cells in the column.',
                highlightCells: highlightCells,
              );
            }
          }
        }
      }
    }

    return null;
  }

  SolvingHint? _findHiddenPair(List<List<Set<int>>> candidates, int gridSize) {
    // Simplified hidden pair detection
    // Check rows
    for (int row = 0; row < gridSize; row++) {
      for (int num1 = 1; num1 < gridSize; num1++) {
        for (int num2 = num1 + 1; num2 <= gridSize; num2++) {
          final cellsWithBoth = <CellPosition>[];
          for (int col = 0; col < gridSize; col++) {
            if (candidates[row][col].contains(num1) &&
                candidates[row][col].contains(num2)) {
              cellsWithBoth.add(CellPosition(row, col));
            }
          }
          if (cellsWithBoth.length == 2) {
            final otherCells = <CellPosition>[];
            for (int col = 0; col < gridSize; col++) {
              if (!cellsWithBoth.contains(CellPosition(row, col)) &&
                  (candidates[row][col].contains(num1) ||
                      candidates[row][col].contains(num2))) {
                otherCells.add(CellPosition(row, col));
              }
            }
            if (otherCells.isNotEmpty) {
              return SolvingHint(
                technique: SolvingTechnique.hiddenPair,
                description:
                    'Hidden Pair: In row $row, $num1 and $num2 appear together only in two cells. Other candidates can be removed.',
                highlightCells: cellsWithBoth,
              );
            }
          }
        }
      }
    }
    return null;
  }

  SolvingHint? _findPointingPair(
    List<List<Set<int>>> candidates,
    int gridSize,
  ) {
    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];

    // Check boxes for pointing pairs
    for (int boxRow = 0; boxRow < gridSize; boxRow += boxRowSize) {
      for (int boxCol = 0; boxCol < gridSize; boxCol += boxColSize) {
        for (int num = 1; num <= gridSize; num++) {
          final cellsWithNum = <CellPosition>[];
          for (int r = boxRow; r < boxRow + boxRowSize; r++) {
            for (int c = boxCol; c < boxCol + boxColSize; c++) {
              if (candidates[r][c].contains(num)) {
                cellsWithNum.add(CellPosition(r, c));
              }
            }
          }

          if (cellsWithNum.length == 2) {
            final pos1 = cellsWithNum[0];
            final pos2 = cellsWithNum[1];

            // Check if they're in the same row
            if (pos1.row == pos2.row) {
              return SolvingHint(
                technique: SolvingTechnique.pointingPair,
                description:
                    'Pointing Pair: In box ($boxRow, $boxCol), $num appears only in row ${pos1.row}. It can be removed from other cells in that row.',
                highlightCells: cellsWithNum,
                value: num,
              );
            }

            // Check if they're in the same column
            if (pos1.col == pos2.col) {
              return SolvingHint(
                technique: SolvingTechnique.pointingPair,
                description:
                    'Pointing Pair: In box ($boxRow, $boxCol), $num appears only in column ${pos1.col}. It can be removed from other cells in that column.',
                highlightCells: cellsWithNum,
                value: num,
              );
            }
          }
        }
      }
    }
    return null;
  }

  SolvingHint? _findBoxLineReduction(
    List<List<Set<int>>> candidates,
    int gridSize,
  ) {
    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];

    // Check rows
    for (int row = 0; row < gridSize; row++) {
      for (int num = 1; num <= gridSize; num++) {
        final cellsWithNum = <CellPosition>[];
        for (int col = 0; col < gridSize; col++) {
          if (candidates[row][col].contains(num)) {
            cellsWithNum.add(CellPosition(row, col));
          }
        }

        if (cellsWithNum.length >= 2 && cellsWithNum.length <= 3) {
          // Check if all cells are in the same box
          final boxRow = (cellsWithNum[0].row ~/ boxRowSize) * boxRowSize;
          final boxCol = (cellsWithNum[0].col ~/ boxColSize) * boxColSize;
          bool allInSameBox = true;
          for (final pos in cellsWithNum) {
            if ((pos.row ~/ boxRowSize) * boxRowSize != boxRow ||
                (pos.col ~/ boxColSize) * boxColSize != boxCol) {
              allInSameBox = false;
              break;
            }
          }

          if (allInSameBox) {
            return SolvingHint(
              technique: SolvingTechnique.boxLineReduction,
              description:
                  'Box Line Reduction: In row $row, $num appears only in box ($boxRow, $boxCol). It can be removed from other cells in that box.',
              highlightCells: cellsWithNum,
              value: num,
            );
          }
        }
      }
    }

    // Check columns
    for (int col = 0; col < gridSize; col++) {
      for (int num = 1; num <= gridSize; num++) {
        final cellsWithNum = <CellPosition>[];
        for (int row = 0; row < gridSize; row++) {
          if (candidates[row][col].contains(num)) {
            cellsWithNum.add(CellPosition(row, col));
          }
        }

        if (cellsWithNum.length >= 2 && cellsWithNum.length <= 3) {
          final boxRow = (cellsWithNum[0].row ~/ boxRowSize) * boxRowSize;
          final boxCol = (cellsWithNum[0].col ~/ boxColSize) * boxColSize;
          bool allInSameBox = true;
          for (final pos in cellsWithNum) {
            if ((pos.row ~/ boxRowSize) * boxRowSize != boxRow ||
                (pos.col ~/ boxColSize) * boxColSize != boxCol) {
              allInSameBox = false;
              break;
            }
          }

          if (allInSameBox) {
            return SolvingHint(
              technique: SolvingTechnique.boxLineReduction,
              description:
                  'Box Line Reduction: In column $col, $num appears only in box ($boxRow, $boxCol). It can be removed from other cells in that box.',
              highlightCells: cellsWithNum,
              value: num,
            );
          }
        }
      }
    }

    return null;
  }
}
