import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/color_tokens.dart';
import '../../domain/functions/matrix_functions.dart';

/// Matrix editor with up to 10x10 grid input
class MatrixEditorScreen extends StatefulWidget {
  const MatrixEditorScreen({super.key});

  @override
  State<MatrixEditorScreen> createState() => _MatrixEditorScreenState();
}

class _MatrixEditorScreenState extends State<MatrixEditorScreen> {
  int _rows = 3;
  int _cols = 3;
  late List<List<TextEditingController>> _controllers;
  String _result = '';
  
  @override
  void initState() {
    super.initState();
    _initControllers();
  }
  
  @override
  void dispose() {
    for (final row in _controllers) {
      for (final c in row) {
        c.dispose();
      }
    }
    super.dispose();
  }
  
  void _initControllers() {
    _controllers = List.generate(
      _rows,
      (i) => List.generate(_cols, (j) => TextEditingController(text: '0')),
    );
  }
  
  List<List<double>> _getMatrix() {
    return List.generate(
      _rows,
      (i) => List.generate(
        _cols,
        (j) => double.tryParse(_controllers[i][j].text) ?? 0,
      ),
    );
  }
  
  void _setMatrix(List<List<double>> matrix) {
    setState(() {
      _rows = matrix.length;
      _cols = matrix[0].length;
    });
    // Reinitialize controllers if dimensions changed
    if (_controllers.length != _rows || _controllers[0].length != _cols) {
      for (final row in _controllers) {
        for (final c in row) {
          c.dispose();
        }
      }
      _initControllers();
    }
    for (int i = 0; i < _rows; i++) {
      for (int j = 0; j < _cols; j++) {
        _controllers[i][j].text = matrix[i][j].toStringAsFixed(4);
      }
    }
  }
  
  void _applyOperation(String operation) {
    try {
      final matrix = _getMatrix();
      
      switch (operation) {
        case 'transpose':
          final result = MatrixFunctions.transpose(matrix);
          _setMatrix(result);
          _showResult('Transpose applied');
          break;
        case 'determinant':
          final det = MatrixFunctions.determinant(matrix);
          _showResult('det(A) = ${det.toStringAsFixed(6)}');
          break;
        case 'inverse':
          final inv = MatrixFunctions.inverse(matrix);
          _setMatrix(inv);
          _showResult('Inverse applied');
          break;
        case 'trace':
          final tr = MatrixFunctions.trace(matrix);
          _showResult('tr(A) = ${tr.toStringAsFixed(6)}');
          break;
        case 'rank':
          final r = MatrixFunctions.rank(matrix);
          _showResult('rank(A) = $r');
          break;
        case 'identity':
          final id = MatrixFunctions.createIdentity(_rows > _cols ? _rows : _cols);
          _setMatrix(id);
          _showResult('Identity matrix set');
          break;
        case 'zero':
          for (int i = 0; i < _rows; i++) {
            for (int j = 0; j < _cols; j++) {
              _controllers[i][j].text = '0';
            }
          }
          _showResult('Zero matrix set');
          break;
        case 'eigenvalues':
          if (_rows == 2 && _cols == 2) {
            final eigen = MatrixFunctions.eigenvalues2x2(matrix);
            final eigenStr = eigen.eigenvalues.map((v) => v.toStringAsFixed(4)).join(', ');
            final vecStr = eigen.eigenvectors.map((v) => '[${v.map((x) => x.toStringAsFixed(4)).join(', ')}]').join(', ');
            _showResult('λ = [$eigenStr]\nv = [$vecStr]');
          } else {
            _showResult('Eigenvalues only supported for 2×2 matrices');
          }
          break;
      }
    } catch (e) {
      _showResult('Error: $e');
    }
  }
  
  void _showResult(String result) {
    setState(() => _result = result);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result),
        duration: const Duration(seconds: 2),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text(
          'Matrix Editor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: _applyOperation,
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'transpose', child: Text('Transpose (Aᵀ)')),
              const PopupMenuItem(value: 'determinant', child: Text('Determinant (det A)')),
              const PopupMenuItem(value: 'inverse', child: Text('Inverse (A⁻¹)')),
              const PopupMenuItem(value: 'trace', child: Text('Trace (tr A)')),
              const PopupMenuItem(value: 'rank', child: Text('Rank (rank A)')),
              const PopupMenuItem(value: 'eigenvalues', child: Text('Eigenvalues (2×2 only)')),
              const PopupMenuItem(value: 'identity', child: Text('Set Identity Matrix')),
              const PopupMenuItem(value: 'zero', child: Text('Set Zero Matrix')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Dimension controls
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Text('Rows', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(width: 4),
                _buildDimensionButton(_rows, 10, (v) {
                  setState(() => _rows = v);
                  _initControllers();
                }),
                const SizedBox(width: 8),
                Text('Cols', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                const SizedBox(width: 4),
                _buildDimensionButton(_cols, 10, (v) {
                  setState(() => _cols = v);
                  _initControllers();
                }),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    _setMatrix(MatrixFunctions.createIdentity(_rows > _cols ? _rows : _cols));
                  },
                  icon: const Icon(Icons.grid_on, size: 20),
                  tooltip: 'Identity',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
                IconButton(
                  onPressed: () {
                    for (int i = 0; i < _rows; i++) {
                      for (int j = 0; j < _cols; j++) {
                        _controllers[i][j].text = (i == j ? '1' : '0');
                      }
                    }
                    setState(() {});
                  },
                  icon: const Icon(Icons.close_fullscreen, size: 20),
                  tooltip: 'Diagonal',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                ),
              ],
            ),
          ),
          
          // Matrix grid
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: MediaQuery.of(context).size.width - 24,
                  ),
                  child: _buildMatrixGrid(isDark),
                ),
              ),
            ),
          ),
          
          // Result display
          if (_result.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
              child: Text(
                _result,
                style: TextStyle(fontFamily: 'monospace', 
                  fontSize: 16,
                  color: ColorTokens.electricCyan,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          
          // Quick operations bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: [
                _buildOpButton('Aᵀ', 'transpose'),
                _buildOpButton('det', 'determinant'),
                _buildOpButton('A⁻¹', 'inverse'),
                _buildOpButton('tr', 'trace'),
                _buildOpButton('rank', 'rank'),
                _buildOpButton('λ', 'eigenvalues'),
                _buildOpButton('I', 'identity'),
                _buildOpButton('0', 'zero'),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildDimensionButton(int value, int max, ValueChanged<int> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        SizedBox(
          width: 24,
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'monospace', 
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          width: 28,
          height: 28,
          child: IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add, size: 16),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMatrixGrid(bool isDark) {
    final cellWidth = _cols > 5 ? 52.0 : 64.0;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(
          color: ColorTokens.electricCyan.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < _rows; i++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int j = 0; j < _cols; j++)
                  SizedBox(
                    width: cellWidth,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: TextField(
                        controller: _controllers[i][j],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                          filled: true,
                          fillColor: isDark
                              ? ColorTokens.darkSurfaceVariant
                              : ColorTokens.lightSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
  
  Widget _buildOpButton(String label, String operation) {
    return ActionChip(
      label: Text(label, style: TextStyle(fontFamily: 'monospace', fontSize: 11)),
      onPressed: () => _applyOperation(operation),
      backgroundColor: ColorTokens.electricCyan.withOpacity(0.1),
      labelStyle: const TextStyle(color: ColorTokens.electricCyan),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
