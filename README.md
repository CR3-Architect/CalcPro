# CalcPro Studio

A calculator I built because every one I tried was either ugly, slow, or missing basic stuff like matrix operations and unit conversion. This one has everything in one app — no ads, no in-app purchases, free forever.

Built with Flutter. Works on Android, iOS, Web, Linux, macOS.

---

## What's inside

**9 modes** — switch between them from the top-left chip:

| Mode | What it does |
|---|---|
| Standard | Normal calculator. 789÷, memory keys, undo/redo, share result as image |
| Scientific | sin/cos/tan (deg/rad), log, ln, √, xʸ, nPr, nCr, factorial, π, e |
| Calculus | Derivatives, integrals (Simpson's rule), limits, sum, product, Taylor series, ODE |
| Matrix | Build matrices visually, then transpose, determinant, inverse, trace, rank, eigenvalues, solve Ax=b |
| Complex | Complex number arithmetic — conjugate, modulus, argument, re/im parts, exp, ln, trig |
| Statistics | Mean/median/std dev, regression, normal/binomial/Poisson/t/χ² distributions |
| Programmer | BIN/OCT/DEC/HEX conversion, AND/OR/XOR/NAND/NOR, shifts, NOT, 1's/2's complement, popcount, CLZ |
| Unit Converter | Length, mass, temperature, area, volume, speed, time, data, pressure, energy, power, angle — ~100 units + physical constants |
| Currency Converter | Live exchange rates for 160+ currencies (including AFN, PKR, INR, SAR, AED...) via open.er-api.com. Search, swap, share |

**Other stuff:**
- Expression parser (lexer → recursive descent → AST → evaluator), not just button mashing
- Live result preview as you type
- History saved locally (500 entries), searchable, exportable
- 3 themes: Dark, Light, AMOLED
- High contrast mode for accessibility
- Haptic feedback (toggle in Settings)
- Adjustable decimal precision
- Undo/Redo (50 steps deep)
- Share calculations as image or text

---

## Project structure

```
lib/
├── main.dart
├── core/
│   ├── constants/    # Math constants
│   ├── enums/        # CalcMode, AngleMode, NumberBase
│   ├── theme/        # Colors, app theme
│   └── utils/        # Share image service
├── domain/
│   ├── ast/          # AST node definitions
│   ├── evaluator/    # Walks the AST, computes results
│   ├── functions/    # Calculus, complex, matrix, programmer, stats
│   ├── models/       # CalculationEntry, VariableScope
│   └── parser/       # Lexer + Parser (recursive descent)
├── l10n/             # Localization scaffold (9 languages)
└── presentation/
    ├── bloc/         # CalculatorCubit, HistoryCubit (flutter_bloc)
    ├── screens/      # All screens (calculator, history, settings, converters, etc.)
    └── widgets/
        ├── display/  # Expression, result, history tape
        └── keypad/   # All 7 keypads + CalcButton
```

State management is flutter_bloc (Cubit). Parsing is custom — I wrote the lexer and parser from scratch because I wanted full control over operator precedence and function handling.

---

## Running it

**Prerequisites:** Flutter SDK 3.19+

```bash
git clone https://github.com/CR3-Architect/CalcPro.git
cd CalcPro
flutter pub get
```

**Run on device:**
```bash
flutter run -d android
flutter run -d chrome
flutter run -d linux
```

**Build APK:**
```bash
flutter build apk --debug    # for testing
flutter build apk --release  # for sharing
```

**Install on phone via ADB:**
```bash
adb install -r build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n com.calcpro.calcpro_studio/.MainActivity
```

**Run tests:**
```bash
flutter test
```

---

## Testing

35 tests passing — covers lexer, parser, evaluator, calculus functions, and programmer operations. Run with `flutter test`.

---

## Packages

- `flutter_bloc` — state management
- `shared_preferences` — local storage (history, settings)
- `google_fonts` — Inter + Roboto Mono
- `share_plus` — share results
- `http` — currency API
- `path_provider` — temp files for image sharing
- `vector_math` — math utilities
- `intl` — localization

---

## License

MIT. Do whatever you want with it.

---

Built by [Atiqullah](https://github.com/CR3-Architect) — if you find bugs or want something added, open an issue.
