/// Variable storage for calculator expressions
class VariableScope {
  final Map<String, double> _variables = {};
  final Map<String, List<double>> _lists = {};
  final List<double> _memory = List.filled(5, 0.0); // M1-M5
  
  /// Get variable value
  double? getVariable(String name) => _variables[name];
  
  /// Set variable value
  void setVariable(String name, double value) {
    _variables[name] = value;
  }
  
  /// Check if variable exists
  bool hasVariable(String name) => _variables.containsKey(name);
  
  /// Remove variable
  void removeVariable(String name) {
    _variables.remove(name);
  }
  
  /// Get all variables
  Map<String, double> get allVariables => Map.unmodifiable(_variables);
  
  /// Clear all variables
  void clearVariables() {
    _variables.clear();
  }
  
  // --- List operations ---
  
  /// Store a list of values
  void setList(String name, List<double> values) {
    _lists[name] = List.from(values);
  }
  
  /// Get a list
  List<double>? getList(String name) => _lists[name];
  
  /// Get all lists
  Map<String, List<double>> get allLists => Map.unmodifiable(_lists);
  
  /// Remove a list
  void removeList(String name) {
    _lists.remove(name);
  }
  
  // --- Memory registers (M1-M5) ---
  
  /// Get memory register value
  double getMemory(int index) {
    if (index < 0 || index >= _memory.length) {
      throw RangeError('Memory register index must be 0-4');
    }
    return _memory[index];
  }
  
  /// Set memory register value
  void setMemory(int index, double value) {
    if (index < 0 || index >= _memory.length) {
      throw RangeError('Memory register index must be 0-4');
    }
    _memory[index] = value;
  }
  
  /// Add to memory register
  void addToMemory(int index, double value) {
    setMemory(index, getMemory(index) + value);
  }
  
  /// Subtract from memory register
  void subtractFromMemory(int index, double value) {
    setMemory(index, getMemory(index) - value);
  }
  
  /// Clear all memory
  void clearMemory() {
    for (int i = 0; i < _memory.length; i++) {
      _memory[i] = 0;
    }
  }
  
  /// Get all memory values
  List<double> get allMemory => List.unmodifiable(_memory);
  
  // --- Scope operations ---
  
  /// Create a child scope (for nested function calls)
  VariableScope childScope() {
    final child = VariableScope();
    child._variables.addAll(_variables);
    return child;
  }
  
  /// Merge another scope into this one
  void merge(VariableScope other) {
    _variables.addAll(other._variables);
  }
  
  /// Clear everything
  void clear() {
    clearVariables();
    _lists.clear();
    clearMemory();
  }
}
