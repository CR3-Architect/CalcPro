import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/enums/angle_mode.dart';
import '../../core/enums/calc_mode.dart';
import '../../core/enums/number_base.dart';
import '../../domain/evaluator/ast_evaluator.dart';
import '../../domain/parser/parser.dart';
import '../../domain/models/calculation_entry.dart';
import '../../domain/models/variable_scope.dart';
import '../../domain/functions/programmer_functions.dart';
import 'calculator_state.dart';

/// Main calculator logic cubit
class CalculatorCubit extends Cubit<CalculatorState> {
  final VariableScope _scope = VariableScope();
  int _memoryIndex = 0;
  
  CalculatorCubit() : super(const CalculatorState()) {
    _loadPreferences();
    _loadHistory();
  }
  
  // --- Input Operations ---
  
  void inputDigit(String digit) {
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + digit,
      displayExpression: state.displayExpression + digit,
      error: '',
    ));
    _evaluateLive();
  }
  
  void inputOperator(String op) {
    _pushUndo();
    final displayOp = _convertOperatorDisplay(op);
    emit(state.copyWith(
      expression: state.expression + op,
      displayExpression: state.displayExpression + displayOp,
      error: '',
    ));
    _evaluateLive();
  }
  
  void inputFunction(String func) {
    _pushUndo();
    String expr;
    String display;
    
    // Check if it's a 2-argument function
    if (func == 'log(' || func == 'nPr(' || func == 'nCr(') {
      expr = func;
      display = func;
    } else {
      expr = func;
      display = func;
    }
    
    emit(state.copyWith(
      expression: state.expression + expr,
      displayExpression: state.displayExpression + display,
      error: '',
    ));
  }
  
  void inputConstant(String name, double value) {
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + name,
      displayExpression: state.displayExpression + name,
      error: '',
    ));
    _evaluateLive();
  }
  
  void inputParenthesis(String paren) {
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + paren,
      displayExpression: state.displayExpression + paren,
      error: '',
    ));
    _evaluateLive();
  }
  
  void inputDecimal() {
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + '.',
      displayExpression: state.displayExpression + '.',
      error: '',
    ));
  }
  
  void inputPercent() {
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + '%',
      displayExpression: state.displayExpression + '%',
      error: '',
    ));
    _evaluateLive();
  }
  
  // --- Control Operations ---
  
  void clearAll() {
    _pushUndo();
    emit(state.copyWith(
      expression: '',
      displayExpression: '',
      result: '',
      error: '',
    ));
  }
  
  void clearEntry() {
    _pushUndo();
    // Remove the last number entered
    final newExpr = state.expression.replaceAll(RegExp(r'[\d.]+$'), '');
    final newDisplay = state.displayExpression.replaceAll(RegExp(r'[\d.]+$'), '');
    emit(state.copyWith(
      expression: newExpr,
      displayExpression: newDisplay,
      error: '',
    ));
    _evaluateLive();
  }
  
  void backspace() {
    if (state.expression.isEmpty) return;
    _pushUndo();
    
    String newExpr = state.expression;
    String newDisplay = state.displayExpression;
    
    if (newExpr.length >= 2) {
      // Check if we're removing a multi-char function
      final funcEndings = ['sin(', 'cos(', 'tan(', 'asin(', 'acos(', 'atan(', 
        'sinh(', 'cosh(', 'tanh(', 'log(', 'ln(', 'sqrt(', 'abs(', 'nPr(', 'nCr('];
      
      bool removed = false;
      for (final func in funcEndings) {
        if (newExpr.endsWith(func)) {
          newExpr = newExpr.substring(0, newExpr.length - func.length);
          newDisplay = newDisplay.substring(0, newDisplay.length - func.length);
          removed = true;
          break;
        }
      }
      
      if (!removed) {
        newExpr = newExpr.substring(0, newExpr.length - 1);
        newDisplay = newDisplay.substring(0, newDisplay.length - 1);
      }
    } else {
      newExpr = '';
      newDisplay = '';
    }
    
    emit(state.copyWith(
      expression: newExpr,
      displayExpression: newDisplay,
      error: '',
    ));
    _evaluateLive();
  }
  
  void evaluate() {
    if (state.expression.isEmpty) return;
    
    try {
      final result = _performEvaluation(state.expression);
      final entry = CalculationEntry(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        expression: state.displayExpression,
        result: result,
        timestamp: DateTime.now(),
        mode: state.mode.displayName,
      );
      
      final newHistory = [entry, ...state.history];
      _saveHistory(newHistory);
      
      _hapticFeedback();
      
      emit(state.copyWith(
        result: result,
        expression: result,
        displayExpression: result,
        history: newHistory,
        undoStack: [],
        redoStack: [],
        error: '',
      ));
    } catch (e) {
      _hapticFeedback();
      emit(state.copyWith(
        error: _getErrorMessage(e),
        result: '',
      ));
    }
  }
  
  // --- Undo/Redo ---
  
  void undo() {
    if (state.undoStack.isEmpty) return;
    
    final currentSnapshot = state.expression;
    final lastUndo = state.undoStack.last;
    
    emit(state.copyWith(
      expression: lastUndo,
      displayExpression: lastUndo,
      undoStack: state.undoStack.sublist(0, state.undoStack.length - 1),
      redoStack: [...state.redoStack, currentSnapshot],
      error: '',
    ));
    _evaluateLive();
  }
  
  void redo() {
    if (state.redoStack.isEmpty) return;
    
    final currentSnapshot = state.expression;
    final lastRedo = state.redoStack.last;
    
    emit(state.copyWith(
      expression: lastRedo,
      displayExpression: lastRedo,
      redoStack: state.redoStack.sublist(0, state.redoStack.length - 1),
      undoStack: [...state.undoStack, currentSnapshot],
      error: '',
    ));
    _evaluateLive();
  }
  
  // --- Mode Changes ---
  
  void setMode(CalcMode mode) {
    emit(state.copyWith(mode: mode));
  }
  
  void setAngleMode(AngleMode mode) {
    _savePreference('angleMode', mode.index);
    emit(state.copyWith(angleMode: mode));
  }
  
  void toggleAngleMode() {
    final modes = AngleMode.values;
    final nextIndex = (state.angleMode.index + 1) % modes.length;
    setAngleMode(modes[nextIndex]);
  }
  
  void setNumberBase(NumberBase base) {
    _savePreference('numberBase', base.index);
    emit(state.copyWith(numberBase: base));
  }
  
  void setPrecision(int precision) {
    _savePreference('precision', precision);
    emit(state.copyWith(precision: precision));
  }
  
  void toggleHapticFeedback() {
    final newValue = !state.hapticFeedback;
    _savePreference('hapticFeedback', newValue ? 1 : 0);
    emit(state.copyWith(hapticFeedback: newValue));
  }
  
  void toggleHighContrast() {
    emit(state.copyWith(highContrastMode: !state.highContrastMode));
  }
  
  // --- Memory Operations ---
  
  void memoryAdd() {
    final value = double.tryParse(state.result) ?? 0;
    _scope.addToMemory(_memoryIndex, value);
    _hapticFeedback();
  }
  
  void memorySubtract() {
    final value = double.tryParse(state.result) ?? 0;
    _scope.subtractFromMemory(_memoryIndex, value);
    _hapticFeedback();
  }
  
  void memoryRecall() {
    final value = _scope.getMemory(_memoryIndex);
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + value.toString(),
      displayExpression: state.displayExpression + value.toString(),
    ));
    _evaluateLive();
  }
  
  void memoryClear() {
    _scope.setMemory(_memoryIndex, 0);
    _hapticFeedback();
  }
  
  void memoryStore(int index) {
    final value = double.tryParse(state.result) ?? 0;
    _scope.setMemory(index, value);
    _memoryIndex = index;
    _hapticFeedback();
  }
  
  // --- History ---
  
  void recallHistory(CalculationEntry entry) {
    _pushUndo();
    emit(state.copyWith(
      expression: entry.result,
      displayExpression: entry.result,
      result: entry.result,
    ));
  }
  
  void deleteHistoryEntry(String id) {
    final newHistory = state.history.where((e) => e.id != id).toList();
    _saveHistory(newHistory);
    emit(state.copyWith(history: newHistory));
  }
  
  void clearHistory() {
    _saveHistory([]);
    emit(state.copyWith(history: []));
  }
  
  // --- Programmer Mode ---
  
  void inputHexDigit(String digit) {
    if (state.mode != CalcMode.programmer) return;
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + digit,
      displayExpression: state.displayExpression + digit,
      error: '',
    ));
    _evaluateLive();
  }
  
  void inputBitwiseOp(String op) {
    _pushUndo();
    emit(state.copyWith(
      expression: state.expression + ' $op ',
      displayExpression: state.displayExpression + ' $op ',
      error: '',
    ));
  }
  
  void convertBase(NumberBase toBase) {
    final value = _getCurrentIntValue();
    if (value == null) return;
    
    final converted = ProgrammerFunctions.formatValue(value, toBase);
    emit(state.copyWith(
      numberBase: toBase,
      result: converted,
    ));
  }
  
  // --- Matrix Operations ---
  
  void setMatrixExpression(String expr) {
    _pushUndo();
    emit(state.copyWith(
      expression: expr,
      displayExpression: expr,
      error: '',
    ));
  }
  
  // --- Settings ---
  
  void setTheme(int themeIndex) {
    _savePreference('themeMode', themeIndex);
  }
  
  // --- Private Helpers ---
  
  void _evaluateLive() {
    if (state.expression.isEmpty) {
      emit(state.copyWith(result: '', error: ''));
      return;
    }
    
    try {
      final result = _performEvaluation(state.expression);
      emit(state.copyWith(result: result, error: ''));
    } catch (_) {
      // Silently fail for live preview - only show error on =
    }
  }
  
  String _performEvaluation(String expression) {
    // Handle programmer mode
    if (state.mode == CalcMode.programmer) {
      return _evaluateProgrammerExpression(expression);
    }
    
    // Convert display-friendly operators back to math operators
    String normalized = expression;
    normalized = normalized.replaceAll('×', '*');
    normalized = normalized.replaceAll('÷', '/');
    normalized = normalized.replaceAll('−', '-');
    
    // Add implicit multiplication: 2π → 2*π
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d)([a-zA-Zπ])'),
      (m) => '${m.group(1)}*${m.group(2)}',
    );
    
    // Handle factorial notation: n! 
    // (parser handles this via postfix)
    
    try {
      final ast = parseExpression(normalized);
      final evaluator = ASTEvaluator(
        angleMode: state.angleMode,
        variables: _scope.allVariables,
      );
      final value = evaluator.evaluate(ast);
      return _formatResult(value);
    } catch (e) {
      // Try using math_expressions package as fallback
      return _evaluateWithMathExpressions(normalized);
    }
  }
  
  String _evaluateWithMathExpressions(String expression) {
    // Basic evaluation fallback
    try {
      // Simple parse-and-evaluate for basic expressions
      String expr = expression;
      expr = expr.replaceAll('π', '3.14159265358979');
      expr = expr.replaceAll('e', '2.71828182845905');
      
      // Use a simple recursive approach
      final result = _simpleEval(expr);
      return _formatResult(result);
    } catch (e) {
      throw EvaluationException('Cannot evaluate expression');
    }
  }
  
  double _simpleEval(String expr) {
    expr = expr.trim();
    
    // Handle parentheses
    if (expr.startsWith('(') && _findMatchingParen(expr, 0) == expr.length - 1) {
      return _simpleEval(expr.substring(1, expr.length - 1));
    }
    
    // Find operator at lowest precedence
    int opPos = -1;
    int minPrec = 999;
    int parenDepth = 0;
    
    for (int i = expr.length - 1; i >= 0; i--) {
      if (expr[i] == ')') parenDepth++;
      else if (expr[i] == '(') parenDepth--;
      
      if (parenDepth == 0) {
        final prec = _getPrecedence(expr[i]);
        if (prec > 0 && prec <= minPrec) {
          minPrec = prec;
          opPos = i;
        }
      }
    }
    
    if (opPos > 0) {
      final left = _simpleEval(expr.substring(0, opPos));
      final right = _simpleEval(expr.substring(opPos + 1));
      final op = expr[opPos];
      
      switch (op) {
        case '+': return left + right;
        case '-': return left - right;
        case '*': return left * right;
        case '/': 
          if (right == 0) throw EvaluationException('Division by zero');
          return left / right;
        case '%': return left % right;
        default: throw EvaluationException('Unknown operator: $op');
      }
    }
    
    // Try to parse as number
    final num = double.tryParse(expr);
    if (num != null) return num;
    
    throw EvaluationException('Cannot evaluate: $expr');
  }
  
  int _getPrecedence(String op) {
    switch (op) {
      case '+': case '-': return 1;
      case '*': case '/': case '%': return 2;
      case '^': return 3;
      default: return 0;
    }
  }
  
  int _findMatchingParen(String expr, int openPos) {
    int depth = 0;
    for (int i = openPos; i < expr.length; i++) {
      if (expr[i] == '(') depth++;
      if (expr[i] == ')') {
        depth--;
        if (depth == 0) return i;
      }
    }
    return -1;
  }
  
  String _evaluateProgrammerExpression(String expression) {
    final base = state.numberBase;
    int? result;
    
    // Handle bitwise operations
    final tokens = expression.split(RegExp(r'\s+'));
    
    if (tokens.length >= 3) {
      final left = ProgrammerFunctions.parseValue(tokens[0], base);
      final op = tokens[1];
      final right = ProgrammerFunctions.parseValue(tokens[2], base);
      
      switch (op) {
        case 'AND': result = ProgrammerFunctions.bitwiseAnd(left, right);
        case 'OR': result = ProgrammerFunctions.bitwiseOr(left, right);
        case 'XOR': result = ProgrammerFunctions.bitwiseXor(left, right);
        case 'NAND': result = ProgrammerFunctions.bitwiseNand(left, right);
        case 'NOR': result = ProgrammerFunctions.bitwiseNor(left, right);
        case '<<': result = ProgrammerFunctions.shiftLeft(left, right);
        case '>>': result = ProgrammerFunctions.shiftRight(left, right);
        case '+': result = left + right;
        case '-': result = left - right;
        case '×': result = left * right;
      }
    } else if (tokens.length == 1) {
      result = ProgrammerFunctions.parseValue(tokens[0], base);
    }
    
    if (result != null) {
      return ProgrammerFunctions.formatValue(result, base);
    }
    
    throw EvaluationException('Invalid programmer expression');
  }
  
  int? _getCurrentIntValue() {
    try {
      return int.parse(state.result);
    } catch (_) {
      try {
        return double.parse(state.result).toInt();
      } catch (_) {
        return null;
      }
    }
  }
  
  String _formatResult(double value) {
    if (value.isNaN) return 'NaN';
    if (value.isInfinite) return value > 0 ? '∞' : '-∞';
    if (value == 0) return '0';
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    if (value.abs() >= 1e15 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(6);
    }
    return value.toStringAsFixed(state.precision > 0 ? state.precision : 10)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
  
  String _convertOperatorDisplay(String op) {
    switch (op) {
      case '*': return '×';
      case '/': return '÷';
      case '-': return '−';
      default: return op;
    }
  }
  
  String _getErrorMessage(dynamic error) {
    if (error is EvaluationException) return error.message;
    if (error is ParseException) return error.message;
    if (error is FormatException) return 'Invalid expression format';
    if (error is ArgumentError) return error.message;
    return 'Error: ${error.toString()}';
  }
  
  void _pushUndo() {
    final newUndo = [...state.undoStack, state.expression];
    if (newUndo.length > 50) newUndo.removeAt(0);
    emit(state.copyWith(
      undoStack: newUndo,
      redoStack: [],
    ));
  }
  
  void _hapticFeedback() {
    if (state.hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }
  
  // --- Persistence ---
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final angleModeIndex = prefs.getInt('angleMode') ?? 0;
      final numberBaseIndex = prefs.getInt('numberBase') ?? 2;
      final precision = prefs.getInt('precision') ?? 0;
      final haptic = prefs.getBool('hapticFeedback') ?? true;
      
      emit(state.copyWith(
        angleMode: AngleMode.values[angleModeIndex],
        numberBase: NumberBase.values[numberBaseIndex],
        precision: precision,
        hapticFeedback: haptic,
      ));
    } catch (_) {}
  }
  
  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList('history') ?? [];
      final entries = historyJson
          .map((json) => CalculationEntry.fromJsonString(json))
          .toList();
      emit(state.copyWith(history: entries));
    } catch (_) {}
  }
  
  Future<void> _saveHistory(List<CalculationEntry> history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = history.map((e) => e.toJsonString()).toList();
      // Keep only last 500 entries
      if (jsonList.length > 500) {
        jsonList.removeRange(500, jsonList.length);
      }
      await prefs.setStringList('history', jsonList);
    } catch (_) {}
  }
  
  Future<void> _savePreference(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is int) await prefs.setInt(key, value);
      if (value is bool) await prefs.setBool(key, value);
      if (value is String) await prefs.setString(key, value);
    } catch (_) {}
  }
}
