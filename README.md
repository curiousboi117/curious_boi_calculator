# Premium Cross-Platform Flutter Calculator

A modern, production-ready, premium cross-platform Calculator application built using **Flutter (Material 3)** and **Dart**. This application is structured under a clean architecture pattern and provides a highly responsive, pixel-perfect UI tailored for Android, iOS, Windows, macOS, Linux, and Web from a single codebase.

---

## Key Features

- **Premium Design System**: Fully implements Google Material 3 tokens. Features elegant glassmorphism styling, clean animations, smooth theme transitions (Light, Dark, System mode), and responsive typography.
- **Scientific Mode**: Expanding panel exposes trigonometric (`sin`, `cos`, `tan` and their inverses), logarithmic (`log`, `ln`), root (`sqrt`, `cbrt`), power ($x^y$, $x^2$, $x^3$, $10^x$), factorial ($x!$), constants ($\pi$, $e$), and absolute value (`abs`) functions.
- **Precedence-Aware Parser**: Utilizes a custom-built, zero-dependency tokenization and evaluation engine implementing the **Shunting-Yard algorithm** to resolve correct mathematical operator precedence (e.g., `5+3×2 = 11`, NOT `16`).
- **Memory Operations**: Fully functional memory register supporting `MC` (Memory Clear), `MR` (Memory Recall), `M+` (Memory Add), `M-` (Memory Subtract), and `MS` (Memory Store).
- **Advanced Calculation History**: Local database logs all equations. Includes search queries to filter calculations, pinning/favoriting systems, single-item deletes, copying answers, and loading past expressions back into the display.
- **Robust Physical Keyboard Integration**: Web and Desktop platforms listen directly to native hardware key inputs:
  - Digits `0-9` and decimals `.`.
  - Operations `+`, `-`, `*`, `/`, `%` (automatically mapped to `+`, `−`, `×`, `÷`, `%`).
  - `Enter` triggers evaluation, `Backspace` deletes, and `Escape` / `Delete` clears the display.
- **Material You Dynamic Coloring**: Integrates color personalization based on Android device system themes.
- **Responsive Layout Design**: Dynamically shifts between standard mobile configurations and split-column views on wide screens (desktop side-by-side active display/keyboard with history logs).

---

## Folder Structure

```
lib/
├── main.dart             # App Entry Point (Sets up global MultiProvider)
├── app.dart              # MaterialApp & AnimatedTheme definitions
│
├── models/
│   └── calculation.dart  # JSON-serializable history database model
│
├── services/
│   ├── expression_parser.dart # Shunting-Yard tokenizing & parser logic
│   └── calculator_engine.dart # Appends, deletes, formatting & memory logic
│
├── providers/
│   ├── theme_provider.dart    # User configs, haptics, theme switching states
│   └── calculator_provider.dart # Calculation, memory, and history states
│
├── widgets/
│   ├── calculator_button.dart # Animated responsive scaling keys
│   ├── display.dart           # Horizontally scrollable live previews & results
│   └── keyboard.dart          # Memory, scientific & standard key grids
│
├── screens/
│   ├── home_screen.dart       # Main desktop split / mobile screen shell
│   ├── history_screen.dart    # History panel with search and list views
│   └── settings_screen.dart   # Interactive preferences configurations
│
└── utils/
    ├── colors.dart            # Custom light/dark themes palette
    └── constants.dart         # Animation timings, storage keys, breakpoints
```

---

## Installation & Setup

Since native folder codebases (`android/`, `ios/`, `windows/`, etc.) vary widely by SDK version and system platforms, they are excluded from this repository to avoid environment conflicts. You can easily generate them for your current Flutter installation:

### Prerequisite
Ensure the Flutter SDK is installed and configured on your machine.
Verify with:
```bash
flutter --version
flutter doctor
```

### Steps to Run
1. Open your terminal and navigate to the project directory:
   ```bash
   cd flutter_calculator
   ```

2. Run the generator to automatically build local platform-specific runner folders:
   ```bash
   flutter create .
   ```

3. Download the packages declared in `pubspec.yaml`:
   ```bash
   flutter pub get
   ```

4. Run the unit test suite to verify the custom parser and engine calculation logic:
   ```bash
   flutter test
   ```

5. Launch the application:
   ```bash
   flutter run
   ```

---

## Keyboard Shortcuts Quick-Map

| Hardware Key | Action |
| --- | --- |
| `0` - `9` | Appends digits |
| `.` | Appends decimal point |
| `+` | Add |
| `-` | Subtract |
| `*` | Multiply (`×` symbol) |
| `/` | Divide (`÷` symbol) |
| `%` | Percent |
| `(` , `)` | Parentheses |
| `Backspace` | Deletes last character / function segment |
| `Enter` | Evaluates expression (`=`) |
| `Escape` / `Delete` | Clears display (`AC`) |

---

## Dependencies

- **Provider**: Multi-context state management.
- **Shared Preferences**: Persistent storage for theme configurations, memory values, and calculation histories.
- **Google Fonts**: Custom typeface typography (utilizes the Outfit font).

---

## License
Distributed under the MIT License.
