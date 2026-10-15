<div align="center">

# CalcPro Studio

**A full-featured calculator for students, engineers, and developers.**

[![Flutter](https://img.shields.io/badge/Flutter-3.19+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.3+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)
[![Release](https://img.shields.io/badge/version-2.1.0-orange?style=flat-square)](../../releases)
[![APK](https://img.shields.io/badge/APK-18%20MB-brightgreen?style=flat-square)](../../releases)

Nine calculation modes · Live currency rates · 160 currencies · 35 passing tests · No ads, no tracking

</div>

---

## Why another calculator?

Because the ones I tried forced me into five different apps: one for matrices, one for unit conversion, one for currency, one for programmer math, and something else for calculus. CalcPro puts all of it in a single, fast, offline-first app — with a parser I wrote from scratch instead of string-punting to `eval`.

---

## Modes

| Mode | What it handles |
|---|---|
| **Standard** | Arithmetic, percent, memory (MC/M+/M−/MR), undo/redo, share as image |
| **Scientific** | Trig (deg/rad), inverses, hyperbolics, logs, roots, nPr/nCr, factorial, constants |
| **Calculus** | Numerical derivatives, integrals (Simpson's rule), limits, sums, products, Taylor series, ODEs |
| **Matrix** | Visual editor — transpose, determinant, inverse, trace, rank, eigenvalues, solve Ax=b |
| **Complex** | Full complex arithmetic — conjugate, modulus, argument, re/im, exp, ln, trig |
| **Statistics** | Descriptive stats, regression, normal/binomial/Poisson/t/χ² distributions |
| **Programmer** | BIN/OCT/DEC/HEX, bitwise ops, shifts, complements, popcount, CLZ |
| **Unit Converter** | 12 categories, ~100 units, physical constants |
| **Currency** | Live rates, 160+ currencies with official names and countries, search, swap |

---

## Highlights

- **Custom expression engine** — lexer → recursive-descent parser → AST → visitor evaluator. Full operator precedence, functions, constants, variables.
- **Live preview** — results update as you type, before you press `=`.
- **History** — 500 entries persisted locally, searchable, shareable.
- **Themes** — Dark, Light, AMOLED, plus a high-contrast accessibility mode.
- **Haptics** — toggleable in Settings.
- **Precision control** — configurable decimal places.
- **Undo/Redo** — 50 steps deep.
- **Share** — export results as text or PNG image.

---

## Architecture

```
lib/
├── core/           enums, theme tokens, share-image utility
├── domain/
│   ├── parser/     lexer + recursive-descent parser
│   ├── ast/        AST node definitions
│   ├── evaluator/  visitor-pattern evaluator
│   └── functions/  calculus, complex, matrix, programmer, stats
├── l10n/           localization scaffold (9 languages)
└── presentation/
    ├── bloc/       CalculatorCubit, HistoryCubit (flutter_bloc)
    ├── screens/    calculator, history, settings, converters, editors
    └── widgets/    display + 7 specialized keypads
```

**Stack:** Flutter · flutter_bloc · shared_preferences · http · share_plus

---

## Build & run

```bash
git clone https://github.com/CR3-Architect/CalcPro.git
cd CalcPro
flutter pub get
```

**Development**
```bash
flutter run                 # hot-reload on connected device
flutter test                # 35 tests
```

**Release (small APK)**
```bash
flutter build apk --release --split-per-abi --tree-shake-icons
# → build/app/outputs/flutter-apk/app-arm64-v8a-release.apk  (~18 MB)
```

**Install via ADB**
```bash
adb install -r build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
adb shell am start -n com.calcpro.calcpro_studio/.MainActivity
```

---

## Size

| Build | Size |
|---|---|
| Debug (all ABIs) | 152 MB |
| Release arm64 | **18.2 MB** |
| Release armeabi-v7a | 15.9 MB |

Release builds use R8 shrinking, resource shrinking, icon tree-shaking, and per-ABI splits. The `google_fonts` runtime downloader was removed in v2.1.0 in favor of system fonts.

---

## Testing

```bash
flutter test
```

35 tests covering the lexer, parser, evaluator, calculus functions, and programmer operations.

---

## Roadmap

- [ ] 2D function graphing
- [ ] Equation solver (systems, polynomial roots)
- [ ] Home screen widget (Android)
- [ ] CSV import/export for statistics
- [ ] Offline currency cache
- [ ] Custom theme builder
- [ ] Wear OS + tablet layouts

---

## License

[MIT](LICENSE) — use it, modify it, ship it. Keep the copyright notice.

---

<div align="center">

Built with **Flutter** · © 2026 [Atiqullah](https://github.com/CR3-Architect)

[Report a bug](../../issues) · [Request a feature](../../issues)

</div>
