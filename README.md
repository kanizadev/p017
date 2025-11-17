# 🎯 Sudoku Master

A beautiful and feature-rich Sudoku game built with Flutter. Challenge your mind with multiple grid sizes, difficulty levels, and advanced features like hints, notes, and conflict detection.

![Flutter](https://img.shields.io/badge/Flutter-3.9.2+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9.2+-0175C2?logo=dart&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

## ✨ Features

### 🎮 Game Features
- **Multiple Grid Sizes**: Play 6×6, 9×9, or 16×16 Sudoku puzzles
- **Difficulty Levels**: Choose from Easy, Medium, Hard, or Expert
- **Smart Hints**: Get help when you're stuck (limited hints available)
- **Undo Functionality**: Undo your moves and try different approaches
- **Notes Mode**: Take notes in cells to track possible numbers
- **Conflict Detection**: Real-time highlighting of conflicting numbers
- **Progress Tracking**: Visual progress bar showing completion percentage
- **Timer**: Track your solving time
- **Auto-save**: Your game progress is automatically saved

### 🎨 User Interface
- **Modern Design**: Beautiful gradient-based UI with smooth animations
- **Intuitive Controls**: Easy-to-use number pad and cell selection
- **Visual Feedback**: Color-coded cells for conflicts and selections
- **Responsive Layout**: Works seamlessly on different screen sizes

### 📊 Statistics & Achievements
- **Game Statistics**: Track your games played, wins, and solving times
- **Move Counter**: Monitor your efficiency
- **Achievement System**: Unlock achievements as you play

## 📸 Screenshots

<!-- Add your screenshots here -->
<!-- ![Home Screen](screenshots/home.png) -->
<!-- ![Game Screen](screenshots/game.png) -->

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- Dart SDK (3.9.2 or higher)
- Android Studio / VS Code with Flutter extensions
- Android SDK (for Android development)
- Xcode (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/p017.git
   cd p017
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Building for Production

**Android:**
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

**Web:**
```bash
flutter build web --release
```

**Windows:**
```bash
flutter build windows --release
```

**macOS:**
```bash
flutter build macos --release
```

**Linux:**
```bash
flutter build linux --release
```

## 🎯 How to Play

1. **Start the Game**: Launch the app and you'll see the home screen
2. **Select Grid Size**: Choose between 6×6, 9×9, or 16×16
3. **Choose Difficulty**: Pick Easy, Medium, Hard, or Expert
4. **Fill the Grid**: 
   - Tap a cell to select it
   - Use the number pad to enter a number
   - Toggle notes mode to add possible numbers
   - Use hints if you're stuck
   - Undo moves if you make a mistake
5. **Win**: Complete the grid correctly to win!

## 📁 Project Structure

```
lib/
├── logic/
│   ├── sudoku_generator.dart    # Puzzle generation logic
│   ├── sudoku_solver.dart       # Advanced solving algorithms
│   └── sudoku_utils.dart        # Utility functions
├── models/
│   └── game_statistics.dart     # Statistics and achievements model
├── screens/
│   ├── home_screen.dart         # Home screen with settings
│   └── sudoku_game_screen.dart  # Main game screen
├── services/
│   └── storage_service.dart     # Local storage for save/load
├── widgets/
│   ├── number_pad.dart         # Number input widget
│   └── sudoku_grid.dart         # Grid display widget
└── main.dart                    # App entry point
```

## 🛠️ Technologies Used

- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language
- **Google Fonts**: Custom typography (Comfortaa, Fredoka)
- **Shared Preferences**: Local data persistence

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
```

## 🎨 Features in Detail

### Grid Sizes
- **6×6**: Perfect for beginners, faster gameplay
- **9×9**: Classic Sudoku experience
- **16×16**: Ultimate challenge for experts

### Difficulty Levels
- **Easy**: More given numbers, perfect for learning
- **Medium**: Balanced challenge
- **Hard**: Fewer clues, requires advanced techniques
- **Expert**: Maximum difficulty, for Sudoku masters

### Game Mechanics
- **Conflict Detection**: Automatically highlights duplicate numbers in rows, columns, and boxes
- **Notes System**: Add multiple possible numbers in a cell
- **Undo Limit**: Configurable undo limit (default: 20 moves)
- **Hints**: Limited hints to help you progress
- **Auto-save**: Game state is saved automatically

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Google Fonts for beautiful typography
- The Sudoku community for inspiration

## 📧 Contact

For questions or suggestions, please open an issue on GitHub.

---

**Enjoy playing Sudoku Master! 🎉**
