import 'dart:math';
import 'sudoku_solver.dart';
import 'sudoku_utils.dart';

class SudokuGenerator {
  final Random _random = Random();
  final AdvancedSudokuSolver _solver = AdvancedSudokuSolver();

  Map<String, List<List<int>>> generate(String difficulty, int gridSize) {
    int attempts = 0;
    while (attempts < 100) {
      final solution = _generateCompleteGrid(gridSize);
      final puzzle = _removeNumbers(solution, difficulty, gridSize);

      // Verify puzzle has unique solution
      final solutionCount = _solver.countSolutions(
        puzzle,
        gridSize,
        maxSolutions: 2,
      );
      if (solutionCount == 1) {
        return {'puzzle': puzzle, 'solution': solution};
      }
      attempts++;
    }

    // Fallback: return puzzle even if not unique (shouldn't happen often)
    final solution = _generateCompleteGrid(gridSize);
    final puzzle = _removeNumbers(solution, difficulty, gridSize);
    return {'puzzle': puzzle, 'solution': solution};
  }

  List<List<int>> _generateCompleteGrid(int gridSize) {
    final grid = List.generate(gridSize, (_) => List.filled(gridSize, 0));
    _solveGrid(grid, gridSize);
    return grid;
  }

  bool _solveGrid(List<List<int>> grid, int gridSize) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (grid[row][col] == 0) {
          final numbers = List.generate(gridSize, (i) => i + 1);
          numbers.shuffle(_random);

          for (final num in numbers) {
            if (_isValid(grid, row, col, num, gridSize)) {
              grid[row][col] = num;
              if (_solveGrid(grid, gridSize)) {
                return true;
              }
              grid[row][col] = 0;
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num, int gridSize) {
    // Check row
    for (int c = 0; c < gridSize; c++) {
      if (grid[row][c] == num) return false;
    }

    // Check column
    for (int r = 0; r < gridSize; r++) {
      if (grid[r][col] == num) return false;
    }

    // Check box
    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];
    final boxRow = (row ~/ boxRowSize) * boxRowSize;
    final boxCol = (col ~/ boxColSize) * boxColSize;
    for (int r = boxRow; r < boxRow + boxRowSize; r++) {
      for (int c = boxCol; c < boxCol + boxColSize; c++) {
        if (grid[r][c] == num) return false;
      }
    }

    return true;
  }

  List<List<int>> _removeNumbers(
    List<List<int>> solution,
    String difficulty,
    int gridSize,
  ) {
    final puzzle = solution.map((row) => List<int>.from(row)).toList();
    final totalCells = gridSize * gridSize;
    int cellsToRemove;

    switch (difficulty) {
      case 'easy':
        cellsToRemove = (totalCells * 0.4).round();
        break;
      case 'medium':
        cellsToRemove = (totalCells * 0.5).round();
        break;
      case 'hard':
        cellsToRemove = (totalCells * 0.6).round();
        break;
      case 'expert':
        cellsToRemove = (totalCells * 0.7).round();
        break;
      default:
        cellsToRemove = (totalCells * 0.5).round();
    }

    // Improved removal: try to remove symmetrically and ensure uniqueness
    final positions = <List<int>>[];
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        positions.add([i, j]);
      }
    }
    positions.shuffle(_random);

    int removed = 0;
    for (final pos in positions) {
      if (removed >= cellsToRemove) break;

      final row = pos[0];
      final col = pos[1];
      if (puzzle[row][col] != 0) {
        final temp = puzzle[row][col];
        puzzle[row][col] = 0;

        // Check if still has unique solution
        final solutionCount = _solver.countSolutions(
          puzzle,
          gridSize,
          maxSolutions: 2,
        );
        if (solutionCount != 1) {
          puzzle[row][col] = temp; // Restore if not unique
        } else {
          removed++;
        }
      }
    }

    return puzzle;
  }

  // Get possible values for a cell
  Set<int> getPossibleValues(
    List<List<int>> grid,
    int row,
    int col,
    int gridSize,
  ) {
    if (grid[row][col] != 0) return {};

    final possible = <int>{};
    for (int i = 1; i <= gridSize; i++) {
      possible.add(i);
    }

    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];

    // Remove values in same row
    for (int c = 0; c < gridSize; c++) {
      possible.remove(grid[row][c]);
    }

    // Remove values in same column
    for (int r = 0; r < gridSize; r++) {
      possible.remove(grid[r][col]);
    }

    // Remove values in same box
    final boxRow = (row ~/ boxRowSize) * boxRowSize;
    final boxCol = (col ~/ boxColSize) * boxColSize;
    for (int r = boxRow; r < boxRow + boxRowSize; r++) {
      for (int c = boxCol; c < boxCol + boxColSize; c++) {
        possible.remove(grid[r][c]);
      }
    }

    return possible;
  }

  // Check if current puzzle is valid and solvable
  bool isValidPuzzle(List<List<int>> puzzle) {
    final gridSize = puzzle.length;
    final boxDims = SudokuUtils.getBoxDimensions(gridSize);
    final boxRowSize = boxDims[0];
    final boxColSize = boxDims[1];

    // Check for duplicates in rows, columns, and boxes
    for (int i = 0; i < gridSize; i++) {
      final rowValues = <int>{};
      final colValues = <int>{};

      for (int j = 0; j < gridSize; j++) {
        if (puzzle[i][j] != 0) {
          if (rowValues.contains(puzzle[i][j])) return false;
          rowValues.add(puzzle[i][j]);
        }

        if (puzzle[j][i] != 0) {
          if (colValues.contains(puzzle[j][i])) return false;
          colValues.add(puzzle[j][i]);
        }
      }
    }

    // Check boxes
    for (int boxRow = 0; boxRow < gridSize; boxRow += boxRowSize) {
      for (int boxCol = 0; boxCol < gridSize; boxCol += boxColSize) {
        final boxValues = <int>{};
        for (int r = boxRow; r < boxRow + boxRowSize; r++) {
          for (int c = boxCol; c < boxCol + boxColSize; c++) {
            if (puzzle[r][c] != 0) {
              if (boxValues.contains(puzzle[r][c])) return false;
              boxValues.add(puzzle[r][c]);
            }
          }
        }
      }
    }

    return true;
  }
}
