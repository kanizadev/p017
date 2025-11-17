import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p017/logic/sudoku_generator.dart';
import 'package:p017/widgets/number_pad.dart';
import 'package:p017/widgets/sudoku_grid.dart';
import 'package:p017/services/storage_service.dart';
import 'package:p017/models/game_statistics.dart';

class SudokuGame extends StatefulWidget {
  final String? difficulty;
  final int gridSize;
  final int hints;
  final int undoLimit;
  final bool enableTimer;
  final bool enableSound;

  const SudokuGame({
    super.key,
    this.difficulty,
    this.gridSize = 9,
    this.hints = 3,
    this.undoLimit = 20,
    this.enableTimer = true,
    this.enableSound = true,
  });

  @override
  State<SudokuGame> createState() => _SudokuGameState();
}

class _SudokuGameState extends State<SudokuGame>
    with SingleTickerProviderStateMixin {
  late List<List<int>> _puzzle;
  late List<List<int>> _solution;
  late List<List<bool>> _isFixed;
  late List<List<Set<int>>> _notes;
  late List<List<bool>> _conflicts;
  late List<List<List<int>>> _history;
  int? _selectedRow;
  int? _selectedCol;
  int? _selectedNumber;
  String _message = '';
  bool _isSolved = false;
  String _difficulty = 'medium';
  int _elapsedSeconds = 0;
  int _hintsRemaining = 3;
  bool _showNotes = false;
  int _moveCount = 0;
  double _completionPercentage = 0.0;
  late AnimationController _animationController;
  GameStatistics? _statistics;
  int _hintsUsedThisGame = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Initialize all late fields immediately to prevent LateInitializationError
    _puzzle = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => 0),
    );
    _solution = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => 0),
    );
    _isFixed = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => false),
    );
    _notes = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => <int>{}),
    );
    _conflicts = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => false),
    );
    _history = [];
    // Generate puzzle immediately to ensure _puzzle is always initialized
    _generateNewPuzzle(widget.difficulty ?? 'medium');
    _loadStatistics();
    _loadGameState();
    _startTimer();
  }

  Future<void> _loadStatistics() async {
    _statistics = await StorageService.loadStatistics();
  }

  Future<void> _loadGameState() async {
    final savedState = await StorageService.loadGameState();
    if (savedState != null && savedState['puzzle'] != null) {
      // Load saved game state
      if (mounted) {
        setState(() {
          _puzzle = List<List<int>>.from(
            (savedState['puzzle'] as List).map((row) => List<int>.from(row)),
          );
          _solution = List<List<int>>.from(
            (savedState['solution'] as List).map((row) => List<int>.from(row)),
          );
          _isFixed = List<List<bool>>.from(
            (savedState['isFixed'] as List).map((row) => List<bool>.from(row)),
          );
          _notes = List<List<Set<int>>>.from(
            (savedState['notes'] as List).map(
              (row) => List<Set<int>>.from(
                (row as List).map((cell) => Set<int>.from(cell)),
              ),
            ),
          );
          _elapsedSeconds = savedState['elapsedSeconds'] ?? 0;
          _hintsRemaining = savedState['hintsRemaining'] ?? widget.hints;
          _moveCount = savedState['moveCount'] ?? 0;
          _difficulty = savedState['difficulty'] ?? 'medium';
          _hintsUsedThisGame = savedState['hintsUsedThisGame'] ?? 0;
          _conflicts = List.generate(
            widget.gridSize,
            (i) => List.generate(widget.gridSize, (j) => false),
          );
          _history = savedState['history'] != null
              ? List<List<List<int>>>.from(
                  (savedState['history'] as List).map(
                    (state) => List<List<int>>.from(
                      (state as List).map((row) => List<int>.from(row)),
                    ),
                  ),
                )
              : [_puzzle.map((row) => List<int>.from(row)).toList()];
          _updateCompletionPercentage();
        });
      }
    }
    // Note: Puzzle is already generated in initState, so we don't need to generate again here
  }

  Future<void> _saveGameState() async {
    await StorageService.saveGameState({
      'puzzle': _puzzle,
      'solution': _solution,
      'isFixed': _isFixed,
      'notes': _notes
          .map((row) => row.map((cell) => cell.toList()).toList())
          .toList(),
      'elapsedSeconds': _elapsedSeconds,
      'hintsRemaining': _hintsRemaining,
      'moveCount': _moveCount,
      'difficulty': _difficulty,
      'hintsUsedThisGame': _hintsUsedThisGame,
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    if (!widget.enableTimer) return;
    Future.delayed(const Duration(seconds: 1), () {
      if (!_isSolved && mounted) {
        setState(() => _elapsedSeconds++);
        _startTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _generateNewPuzzle(String difficulty) {
    _difficulty = difficulty;
    final generator = SudokuGenerator();
    final puzzle = generator.generate(difficulty, widget.gridSize);
    _puzzle = puzzle['puzzle']!;
    _solution = puzzle['solution']!;
    _isFixed = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => _puzzle[i][j] != 0),
    );
    _notes = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => <int>{}),
    );
    _conflicts = List.generate(
      widget.gridSize,
      (i) => List.generate(widget.gridSize, (j) => false),
    );
    _history = [_puzzle.map((row) => List<int>.from(row)).toList()];
    _selectedRow = null;
    _selectedCol = null;
    _selectedNumber = null;
    _message = '';
    _isSolved = false;
    _elapsedSeconds = 0;
    _hintsRemaining = widget.hints;
    _moveCount = 0;
    _hintsUsedThisGame = 0;
    _updateCompletionPercentage();
    if (_statistics != null) {
      _statistics!.recordGamePlayed(difficulty);
      StorageService.saveStatistics(_statistics!);
    }
    StorageService.clearGameState();
  }

  int _countFilledCells(List<List<int>> grid) {
    int count = 0;
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        if (grid[i][j] != 0) count++;
      }
    }
    return count;
  }

  void _updateCompletionPercentage() {
    final filledCells = _countFilledCells(_puzzle);
    _completionPercentage =
        (filledCells / (widget.gridSize * widget.gridSize)) * 100;
  }

  void _checkConflicts() {
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        _conflicts[i][j] = false;
      }
    }

    if (_selectedRow == null || _selectedCol == null) return;

    final value = _puzzle[_selectedRow!][_selectedCol!];
    if (value == 0) return;

    for (int j = 0; j < widget.gridSize; j++) {
      if (j != _selectedCol && _puzzle[_selectedRow!][j] == value) {
        _conflicts[_selectedRow!][j] = true;
      }
    }

    for (int i = 0; i < widget.gridSize; i++) {
      if (i != _selectedRow && _puzzle[i][_selectedCol!] == value) {
        _conflicts[i][_selectedCol!] = true;
      }
    }

    final boxSize = widget.gridSize == 6 ? 2 : (widget.gridSize == 16 ? 4 : 3);
    final boxRow = (_selectedRow! ~/ boxSize) * boxSize;
    final boxCol = (_selectedCol! ~/ boxSize) * boxSize;
    for (int i = boxRow; i < boxRow + boxSize; i++) {
      for (int j = boxCol; j < boxCol + boxSize; j++) {
        if ((i != _selectedRow || j != _selectedCol) &&
            _puzzle[i][j] == value) {
          _conflicts[i][j] = true;
        }
      }
    }
  }

  void _selectCell(int row, int col) {
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      _checkConflicts();
    });
    _saveGameState();
  }

  void _selectNumber(int number) {
    if (_selectedRow == null || _selectedCol == null) return;
    if (_isFixed[_selectedRow!][_selectedCol!]) return;

    setState(() {
      if (_showNotes) {
        if (_notes[_selectedRow!][_selectedCol!].contains(number)) {
          _notes[_selectedRow!][_selectedCol!].remove(number);
        } else {
          _notes[_selectedRow!][_selectedCol!].add(number);
        }
      } else {
        _puzzle[_selectedRow!][_selectedCol!] = number;
        _notes[_selectedRow!][_selectedCol!].clear();
        _message = '';
        _moveCount++;
        _addToHistory();
        _updateCompletionPercentage();
        _checkConflicts();
        _checkWin();
        if (_statistics != null) {
          _statistics!.recordMove();
        }
      }
    });
    _saveGameState();
  }

  void _clearCell() {
    if (_selectedRow != null &&
        _selectedCol != null &&
        !_isFixed[_selectedRow!][_selectedCol!]) {
      setState(() {
        _puzzle[_selectedRow!][_selectedCol!] = 0;
        _notes[_selectedRow!][_selectedCol!].clear();
        _message = '';
        _addToHistory();
        _updateCompletionPercentage();
      });
      _saveGameState();
    }
  }

  void _addToHistory() {
    _history.add(_puzzle.map((row) => List<int>.from(row)).toList());
    if (_history.length > widget.undoLimit) _history.removeAt(0);
  }

  void _undo() {
    if (_history.length > 1) {
      setState(() {
        _history.removeLast();
        _puzzle = _history.last.map((row) => List<int>.from(row)).toList();
        _message = 'Move undone';
        _updateCompletionPercentage();
        _checkConflicts();
      });
      _saveGameState();
    }
  }

  void _giveHint() {
    if (_hintsRemaining <= 0) {
      setState(() => _message = 'No more hints available!');
      return;
    }

    // Simple hint: Reveal the answer for selected cell
    if (_selectedRow == null || _selectedCol == null) {
      setState(() => _message = 'Select a cell first!');
      return;
    }

    if (_isFixed[_selectedRow!][_selectedCol!]) {
      setState(() => _message = 'Cannot hint fixed cells!');
      return;
    }

    if (_puzzle[_selectedRow!][_selectedCol!] != 0) {
      setState(() => _message = 'Cell already filled!');
      return;
    }

    setState(() {
      _puzzle[_selectedRow!][_selectedCol!] =
          _solution[_selectedRow!][_selectedCol!];
      _notes[_selectedRow!][_selectedCol!].clear();
      _hintsRemaining--;
      _hintsUsedThisGame++;
      _message = 'Hint used! $_hintsRemaining remaining';
      _addToHistory();
      _updateCompletionPercentage();
      _checkWin();
      if (_statistics != null) {
        _statistics!.recordHintUsed();
      }
    });
    _saveGameState();
  }

  void _checkWin() {
    for (int i = 0; i < widget.gridSize; i++) {
      for (int j = 0; j < widget.gridSize; j++) {
        if (_puzzle[i][j] != _solution[i][j]) return;
      }
    }
    setState(() {
      _isSolved = true;
      final efficiency = _moveCount > 0
          ? (_completionPercentage / _moveCount)
          : 0;
      _message =
          'Solved in ${_formatTime(_elapsedSeconds)}! Efficiency: ${efficiency.toStringAsFixed(1)}%';
      if (_statistics != null) {
        _statistics!.recordGameWon(_difficulty, _elapsedSeconds);
        _statistics!.addTime(_elapsedSeconds);
        _statistics!.checkAchievements(
          _difficulty,
          _elapsedSeconds,
          _hintsUsedThisGame,
        );
        StorageService.saveStatistics(_statistics!);
      }
    });
    StorageService.clearGameState();
  }

  void _showDifficultyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Color(0xFF6B8E6F), size: 32),
            SizedBox(width: 12),
            Text(
              'Select Difficulty',
              style: GoogleFonts.fredoka(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A5C4D),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['easy', 'medium', 'hard', 'expert']
              .map(
                (d) => Container(
                  margin: EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [Color(0xFFF5F8F6), Color(0xFFE8F1EB)],
                    ),
                    border: Border.all(color: Color(0xFFD4E4D8), width: 1.5),
                  ),
                  child: ListTile(
                    leading: Icon(
                      d == 'easy'
                          ? Icons.emoji_emotions
                          : d == 'medium'
                          ? Icons.sentiment_satisfied_alt
                          : d == 'hard'
                          ? Icons.sentiment_dissatisfied
                          : Icons.mood_bad,
                      color: Color(0xFF6B8E6F),
                      size: 32,
                    ),
                    title: Text(
                      '${d[0].toUpperCase()}${d.substring(1)}',
                      style: GoogleFonts.comfortaa(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF4A5C4D),
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: Color(0xFF6B8E6F),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _generateNewPuzzle(d));
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, color: Colors.white, size: 32),
            SizedBox(width: 10),
            Text(
              'Sudoku',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            SizedBox(width: 10),
            Icon(Icons.auto_awesome, color: Colors.white, size: 32),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Color(0xFF6B8E6F),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF8BA893), Color(0xFF6B8E6F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
      backgroundColor: Color(0xFFF5F8F6),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8BA893), Color(0xFF6B8E6F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF6B8E6F).withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    Icons.timer,
                    'Time',
                    _formatTime(_elapsedSeconds),
                  ),
                  _buildStatItem(Icons.touch_app, 'Moves', '$_moveCount'),
                  _buildStatItem(
                    Icons.lightbulb_outline,
                    'Hints',
                    '$_hintsRemaining',
                  ),
                  _buildStatItem(
                    Icons.star_outline,
                    'Level',
                    '${_difficulty[0].toUpperCase()}${_difficulty.substring(1)}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.trending_up,
                            size: 16,
                            color: Color(0xFF6B8E6F),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Progress',
                            style: GoogleFonts.comfortaa(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B8E6F),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${_completionPercentage.toStringAsFixed(0)}%',
                        style: GoogleFonts.comfortaa(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6B8E6F),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: Color(0xFFD4E4D8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          begin: 0.0,
                          end: _completionPercentage / 100,
                        ),
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return LinearProgressIndicator(
                            value: value,
                            minHeight: 10,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation(
                              Color(0xFF6B8E6F),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_message.isNotEmpty)
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSolved
                        ? [Color(0xFF6B8E6F), Color(0xFF5A7A5D)]
                        : [Color(0xFFC4A06B), Color(0xFFB8905A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (_isSolved ? Color(0xFF6B8E6F) : Color(0xFFC4A06B))
                          .withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: Offset(0, 6),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSolved
                          ? Icons.celebration_rounded
                          : Icons.emoji_events_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _message,
                        style: GoogleFonts.comfortaa(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          letterSpacing: 0.8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            SudokuGrid(
              puzzle: _puzzle,
              isFixed: _isFixed,
              selectedRow: _selectedRow,
              selectedCol: _selectedCol,
              notes: _notes,
              showNotes: _showNotes,
              conflicts: _conflicts,
              onCellSelected: _selectCell,
              gridSize: widget.gridSize,
            ),
            const SizedBox(height: 16),
            NumberPad(
              selectedNumber: _selectedNumber,
              onNumberSelected: _selectNumber,
              gridSize: widget.gridSize,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                    spreadRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    icon: Icons.backspace_rounded,
                    color: Color(0xFF6B8E6F),
                    onPressed: _clearCell,
                    tooltip: 'Clear',
                  ),
                  _buildActionButton(
                    icon: Icons.undo_rounded,
                    color: Color(0xFF6B8E6F),
                    onPressed: _undo,
                    tooltip: 'Undo',
                  ),
                  _buildActionButton(
                    icon: Icons.lightbulb_circle_rounded,
                    color: Color(0xFFC4A06B),
                    onPressed: _giveHint,
                    tooltip: 'Hint',
                    isHighlighted: true,
                  ),
                  _buildActionButton(
                    icon: _showNotes
                        ? Icons.edit_note_rounded
                        : Icons.edit_off_rounded,
                    color: Color(0xFF6B8E6F),
                    onPressed: () => setState(() => _showNotes = !_showNotes),
                    tooltip: 'Notes',
                    isActive: _showNotes,
                  ),
                  _buildActionButton(
                    icon: Icons.refresh_rounded,
                    color: Color(0xFF6B8E6F),
                    onPressed: _showDifficultyDialog,
                    tooltip: 'New Game',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: GoogleFonts.comfortaa(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.comfortaa(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    bool isActive = false,
    bool isHighlighted = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? color.withValues(alpha: 0.15)
                  : isHighlighted
                  ? color.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: color, width: 2)
                  : Border.all(color: Colors.transparent, width: 2),
            ),
            child: Icon(
              icon,
              color: isActive || isHighlighted
                  ? color
                  : color.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}
