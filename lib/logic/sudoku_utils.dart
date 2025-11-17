class SudokuUtils {
  static List<int> getBoxDimensions(int gridSize) {
    switch (gridSize) {
      case 6:
        return [2, 3]; // 2 rows, 3 cols
      case 9:
        return [3, 3]; // 3 rows, 3 cols
      case 16:
        return [4, 4]; // 4 rows, 4 cols
      default:
        return [3, 3];
    }
  }

  static int getBoxSize(int gridSize) {
    switch (gridSize) {
      case 6:
        return 3; // 2x3 boxes
      case 9:
        return 3; // 3x3 boxes
      case 16:
        return 4; // 4x4 boxes
      default:
        return 3;
    }
  }
}
