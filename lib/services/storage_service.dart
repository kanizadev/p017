import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_statistics.dart';

class StorageService {
  static const String _statsKey = 'sudoku_statistics';
  static const String _gameStateKey = 'sudoku_game_state';

  // Save statistics
  static Future<void> saveStatistics(GameStatistics stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_statsKey, jsonEncode(stats.toJson()));
  }

  // Load statistics
  static Future<GameStatistics> loadStatistics() async {
    final prefs = await SharedPreferences.getInstance();
    final statsJson = prefs.getString(_statsKey);
    if (statsJson != null) {
      try {
        return GameStatistics.fromJson(jsonDecode(statsJson));
      } catch (e) {
        debugPrint('Error loading statistics: $e');
      }
    }
    return GameStatistics();
  }

  // Save game state
  static Future<void> saveGameState(Map<String, dynamic> gameState) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_gameStateKey, jsonEncode(gameState));
  }

  // Load game state
  static Future<Map<String, dynamic>?> loadGameState() async {
    final prefs = await SharedPreferences.getInstance();
    final gameStateJson = prefs.getString(_gameStateKey);
    if (gameStateJson != null) {
      try {
        return jsonDecode(gameStateJson) as Map<String, dynamic>;
      } catch (e) {
        debugPrint('Error loading game state: $e');
      }
    }
    return null;
  }

  // Clear game state
  static Future<void> clearGameState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_gameStateKey);
  }
}
