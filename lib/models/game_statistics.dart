class GameStatistics {
  int totalGamesPlayed = 0;
  int totalGamesWon = 0;
  int totalGamesSolved = 0;
  Map<String, int> bestTimes = {}; // difficulty -> seconds
  Map<String, int> gamesPlayedByDifficulty = {};
  Map<String, int> gamesWonByDifficulty = {};
  int totalHintsUsed = 0;
  int totalMovesMade = 0;
  int totalTimePlayed = 0; // in seconds
  List<String> achievements = [];

  GameStatistics();

  GameStatistics.fromJson(Map<String, dynamic> json)
    : totalGamesPlayed = json['totalGamesPlayed'] ?? 0,
      totalGamesWon = json['totalGamesWon'] ?? 0,
      totalGamesSolved = json['totalGamesSolved'] ?? 0,
      bestTimes = Map<String, int>.from(json['bestTimes'] ?? {}),
      gamesPlayedByDifficulty = Map<String, int>.from(
        json['gamesPlayedByDifficulty'] ?? {},
      ),
      gamesWonByDifficulty = Map<String, int>.from(
        json['gamesWonByDifficulty'] ?? {},
      ),
      totalHintsUsed = json['totalHintsUsed'] ?? 0,
      totalMovesMade = json['totalMovesMade'] ?? 0,
      totalTimePlayed = json['totalTimePlayed'] ?? 0,
      achievements = List<String>.from(json['achievements'] ?? []);

  Map<String, dynamic> toJson() => {
    'totalGamesPlayed': totalGamesPlayed,
    'totalGamesWon': totalGamesWon,
    'totalGamesSolved': totalGamesSolved,
    'bestTimes': bestTimes,
    'gamesPlayedByDifficulty': gamesPlayedByDifficulty,
    'gamesWonByDifficulty': gamesWonByDifficulty,
    'totalHintsUsed': totalHintsUsed,
    'totalMovesMade': totalMovesMade,
    'totalTimePlayed': totalTimePlayed,
    'achievements': achievements,
  };

  void recordGamePlayed(String difficulty) {
    totalGamesPlayed++;
    gamesPlayedByDifficulty[difficulty] =
        (gamesPlayedByDifficulty[difficulty] ?? 0) + 1;
  }

  void recordGameWon(String difficulty, int timeSeconds) {
    totalGamesWon++;
    totalGamesSolved++;
    gamesWonByDifficulty[difficulty] =
        (gamesWonByDifficulty[difficulty] ?? 0) + 1;

    final currentBest = bestTimes[difficulty];
    if (currentBest == null || timeSeconds < currentBest) {
      bestTimes[difficulty] = timeSeconds;
    }
  }

  void recordHintUsed() {
    totalHintsUsed++;
  }

  void recordMove() {
    totalMovesMade++;
  }

  void addTime(int seconds) {
    totalTimePlayed += seconds;
  }

  void checkAchievements(String difficulty, int timeSeconds, int hintsUsed) {
    // First Win
    if (totalGamesWon == 1 && !achievements.contains('first_win')) {
      achievements.add('first_win');
    }

    // Speed Demon (solve in under 5 minutes)
    if (timeSeconds < 300 &&
        !achievements.contains('speed_demon_$difficulty')) {
      achievements.add('speed_demon_$difficulty');
    }

    // No Hints Challenge
    if (hintsUsed == 0 && !achievements.contains('no_hints_$difficulty')) {
      achievements.add('no_hints_$difficulty');
    }

    // Perfect Game (no mistakes)
    // This would need to be tracked separately

    // Master Solver (10 wins)
    if (totalGamesWon >= 10 && !achievements.contains('master_solver')) {
      achievements.add('master_solver');
    }

    // Expert Master (10 expert wins)
    if (difficulty == 'expert' &&
        (gamesWonByDifficulty['expert'] ?? 0) >= 10 &&
        !achievements.contains('expert_master')) {
      achievements.add('expert_master');
    }

    // Marathon Player (100 games)
    if (totalGamesPlayed >= 100 && !achievements.contains('marathon_player')) {
      achievements.add('marathon_player');
    }
  }

  String getAchievementName(String achievement) {
    switch (achievement) {
      case 'first_win':
        return 'First Victory';
      case 'speed_demon_easy':
        return 'Speed Demon (Easy)';
      case 'speed_demon_medium':
        return 'Speed Demon (Medium)';
      case 'speed_demon_hard':
        return 'Speed Demon (Hard)';
      case 'speed_demon_expert':
        return 'Speed Demon (Expert)';
      case 'no_hints_easy':
        return 'No Hints Needed (Easy)';
      case 'no_hints_medium':
        return 'No Hints Needed (Medium)';
      case 'no_hints_hard':
        return 'No Hints Needed (Hard)';
      case 'no_hints_expert':
        return 'No Hints Needed (Expert)';
      case 'master_solver':
        return 'Master Solver';
      case 'expert_master':
        return 'Expert Master';
      case 'marathon_player':
        return 'Marathon Player';
      default:
        return achievement;
    }
  }
}
