<div align="center">

# CalcPro Studio

**Professional Scientific Calculator for Students & Engineers**

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)
[![Tests](https://img.shields.io/badge/tests-35%20passed-brightgreen?style=for-the-badge)](#testing)

Cross-platform calculator with **8 modes**: Standard, Scientific, Calculus, Matrix, Complex, Statistics, Programmer, and Unit Converter.

</div>

---

## Features

| Mode | Capabilities |
|---|---|
| **Standard** | Arithmetic, percent, square root, memory (M+/M-/MR/MC), undo/redo |
| **Scientific** | Trig (deg/rad), inverse & hyperbolic, logs, roots, nPr/nCr, factorial, constants |
| **Calculus** | Numerical derivatives, integrals (Simpson's rule), limits, summation, product, Taylor series |
| **Matrix** | Visual editor: transpose, determinant, inverse, trace, rank, eigenvalues, solve Ax=b |
| **Complex** | Full complex arithmetic: conjugate, modulus, argument, re/im, exp, ln, trig |
| **Statistics** | Descriptive stats, regression, normal/binomial/Poisson/t/χ² distributions |
| **Programmer** | BIN/OCT/DEC/HEX, AND/OR/XOR/NAND/NOR, shifts, NOT, 1's/2's complement, popcount, CLZ |
| **Unit Converter** | 12 categories, ~100 units, physical constants, temperature conversion |

### Core

- Full expression parser (Lexer → Recursive Descent → AST → Evaluator)
- Live result preview
- Persistent history (500 entries, search, favorites, share/export)
- 3 themes: Dark, Light, AMOLED
- High-contrast accessibility mode
- Haptic feedback
- Customizable precision
- Undo/Redo (50-deep)

## Architecture

```
lib/
├── core/          # Constants, enums, theme, utils
├── domain/        # Parser, AST, evaluator, math functions
├── l10n/          # Localization (9 languages scaffolded)
└── presentation/  # BLoC state, screens, widgets
```

- **State:** flutter_bloc (Cubit)
- **Parsing:** Custom recursive-descent parser with full operator precedence
- **Evaluation:** Visitor-pattern AST evaluator
- **Persistence:** SharedPreferences

## Getting Started

### Prerequisites

- Flutter SDK 3.19+
- Android Studio / Xcode (for mobile builds)

### Install

```bash
# Clone
git clone https://github.com/Atiqullah61111/CalcPro.git
cd CalcPro

# Install dependencies
flutter pub get

# Run on any platform
flutter run -d chrome      # Web
flutter run -d android     # Android
flutter run -d ios         # iOS
flutter run -d linux       # Linux

# Run tests
flutter test

# Build release APK
flutter build apk --release
```

### Install on Android (via ADB)

```bash
# Build debug APK
flutter build apk --debug

# Install on connected device
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Launch
adb shell am start -n com.calcpro.calcpro_studio/.MainActivity
```

## Platforms

| Platform | Status |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ |
| Linux | ✅ |
| macOS | ✅ |
| Windows | ⏳ Planned |

## Testing

```bash
flutter test
```

**35 tests passing** — covers lexer, parser, evaluator, calculus functions, and programmer operations.

## Packages Used

| Package | Purpose |
|---|---|
| flutter_bloc | State management |
| shared_preferences | Local storage |
| google_fonts | Custom typography |
| share_plus | Export/share results |
| vector_math | Math utilities |
| intl | Localization |

## License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

Built with **Flutter** · © 2026 [Atiqullah](https://github.com/Atiqullah61111)

</div>
