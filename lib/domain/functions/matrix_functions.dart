import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vm;

/// Matrix operations using vector_math
class MatrixFunctions {
  MatrixFunctions._();
  
  /// Create identity matrix of given size
  static vm.Matrix3 identity3() => vm.Matrix3.identity();
  
  static vm.Matrix4 identity4() => vm.Matrix4.identity();
  
  static List<List<double>> createIdentity(int size) {
    final result = List.generate(size, (_) => List.filled(size, 0.0));
    for (int i = 0; i < size; i++) {
      result[i][i] = 1.0;
    }
    return result;
  }
  
  /// Create zero matrix
  static List<List<double>> createZero(int rows, int cols) {
    return List.generate(rows, (_) => List.filled(cols, 0.0));
  }
  
  /// Create diagonal matrix
  static List<List<double>> createDiagonal(List<double> values) {
    final n = values.length;
    final result = createZero(n, n);
    for (int i = 0; i < n; i++) {
      result[i][i] = values[i];
    }
    return result;
  }
  
  /// Matrix addition
  static List<List<double>> add(List<List<double>> a, List<List<double>> b) {
    _checkSameDimensions(a, b);
    return List.generate(
      a.length,
      (i) => List.generate(
        a[0].length,
        (j) => a[i][j] + b[i][j],
      ),
    );
  }
  
  /// Matrix subtraction
  static List<List<double>> subtract(List<List<double>> a, List<List<double>> b) {
    _checkSameDimensions(a, b);
    return List.generate(
      a.length,
      (i) => List.generate(
        a[0].length,
        (j) => a[i][j] - b[i][j],
      ),
    );
  }
  
  /// Matrix multiplication
  static List<List<double>> multiply(List<List<double>> a, List<List<double>> b) {
    if (a[0].length != b.length) {
      throw ArgumentError(
        'Incompatible dimensions: ${a.length}×${a[0].length} and ${b.length}×${b[0].length}',
      );
    }
    
    final result = createZero(a.length, b[0].length);
    for (int i = 0; i < a.length; i++) {
      for (int j = 0; j < b[0].length; j++) {
        double sum = 0;
        for (int k = 0; k < a[0].length; k++) {
          sum += a[i][k] * b[k][j];
        }
        result[i][j] = sum;
      }
    }
    return result;
  }
  
  /// Scalar multiplication
  static List<List<double>> scalarMultiply(double scalar, List<List<double>> matrix) {
    return List.generate(
      matrix.length,
      (i) => List.generate(
        matrix[0].length,
        (j) => scalar * matrix[i][j],
      ),
    );
  }
  
  /// Transpose
  static List<List<double>> transpose(List<List<double>> matrix) {
    final rows = matrix.length;
    final cols = matrix[0].length;
    return List.generate(
      cols,
      (j) => List.generate(
        rows,
        (i) => matrix[i][j],
      ),
    );
  }
  
  /// Determinant (for square matrices)
  static double determinant(List<List<double>> matrix) {
    final n = matrix.length;
    if (n != matrix[0].length) throw ArgumentError('Matrix must be square');
    
    if (n == 1) return matrix[0][0];
    if (n == 2) {
      return matrix[0][0] * matrix[1][1] - matrix[0][1] * matrix[1][0];
    }
    if (n == 3) {
      return matrix[0][0] * (matrix[1][1] * matrix[2][2] - matrix[1][2] * matrix[2][1]) -
          matrix[0][1] * (matrix[1][0] * matrix[2][2] - matrix[1][2] * matrix[2][0]) +
          matrix[0][2] * (matrix[1][0] * matrix[2][1] - matrix[1][1] * matrix[2][0]);
    }
    
    // LU decomposition for larger matrices
    return _luDeterminant(matrix);
  }
  
  /// Matrix inverse using Gauss-Jordan elimination
  static List<List<double>> inverse(List<List<double>> matrix) {
    final n = matrix.length;
    if (n != matrix[0].length) throw ArgumentError('Matrix must be square');
    
    final det = determinant(matrix);
    if (det.abs() < 1e-10) throw ArgumentError('Matrix is singular (no inverse)');
    
    // Augmented matrix [A | I]
    final augmented = List.generate(n, (i) {
      return List.generate(2 * n, (j) {
        if (j < n) return matrix[i][j];
        return (i == j - n) ? 1.0 : 0.0;
      });
    });
    
    // Gauss-Jordan elimination
    for (int col = 0; col < n; col++) {
      // Find pivot
      int maxRow = col;
      for (int row = col + 1; row < n; row++) {
        if (augmented[row][col].abs() > augmented[maxRow][col].abs()) {
          maxRow = row;
        }
      }
      _swapRows(augmented, col, maxRow);
      
      final pivot = augmented[col][col];
      if (pivot.abs() < 1e-10) throw ArgumentError('Matrix is singular');
      
      // Scale pivot row
      for (int j = 0; j < 2 * n; j++) {
        augmented[col][j] /= pivot;
      }
      
      // Eliminate column
      for (int row = 0; row < n; row++) {
        if (row == col) continue;
        final factor = augmented[row][col];
        for (int j = 0; j < 2 * n; j++) {
          augmented[row][j] -= factor * augmented[col][j];
        }
      }
    }
    
    // Extract inverse from augmented matrix
    return List.generate(n, (i) {
      return List.generate(n, (j) => augmented[i][n + j]);
    });
  }
  
  /// Trace of a square matrix
  static double trace(List<List<double>> matrix) {
    final n = matrix.length;
    double sum = 0;
    for (int i = 0; i < n; i++) {
      sum += matrix[i][i];
    }
    return sum;
  }
  
  /// Rank of a matrix
  static int rank(List<List<double>> matrix) {
    // Row echelon form
    final m = List.generate(
      matrix.length,
      (i) => List<double>.from(matrix[i]),
    );
    
    int rank = 0;
    final rows = m.length;
    final cols = m[0].length;
    
    for (int col = 0; col < cols && rank < rows; col++) {
      // Find pivot
      int pivotRow = rank;
      for (int row = rank + 1; row < rows; row++) {
        if (m[row][col].abs() > m[pivotRow][col].abs()) {
          pivotRow = row;
        }
      }
      
      if (m[pivotRow][col].abs() < 1e-10) continue;
      
      _swapRows(m, rank, pivotRow);
      
      // Eliminate
      for (int row = 0; row < rows; row++) {
        if (row == rank) continue;
        final factor = m[row][col] / m[rank][col];
        for (int j = col; j < cols; j++) {
          m[row][j] -= factor * m[rank][j];
        }
      }
      
      rank++;
    }
    
    return rank;
  }
  
  /// Power of a square matrix
  static List<List<double>> power(List<List<double>> matrix, int n) {
    if (n == 0) return createIdentity(matrix.length);
    if (n < 0) return multiply(power(inverse(matrix), -n), createIdentity(matrix.length));
    if (n == 1) return matrix;
    
    if (n.isEven) {
      final half = power(matrix, n ~/ 2);
      return multiply(half, half);
    }
    
    return multiply(matrix, power(matrix, n - 1));
  }
  
  /// Eigenvalues and eigenvectors for 2x2 matrices
  static EigenResult eigenvalues2x2(List<List<double>> matrix) {
    if (matrix.length != 2 || matrix[0].length != 2) {
      throw ArgumentError('Only 2x2 matrices supported for eigenvalue computation');
    }
    
    final a = matrix[0][0];
    final b = matrix[0][1];
    final c = matrix[1][0];
    final d = matrix[1][1];
    
    final trace = a + d;
    final det = a * d - b * c;
    final discriminant = trace * trace - 4 * det;
    
    final eigenvalues = <double>[];
    final eigenvectors = <List<double>>[];
    
    if (discriminant >= 0) {
      final sqrtDisc = math.sqrt(discriminant);
      final l1 = (trace + sqrtDisc) / 2;
      final l2 = (trace - sqrtDisc) / 2;
      eigenvalues.addAll([l1, l2]);
      
      // Eigenvectors
      for (final lambda in eigenvalues) {
        if (b.abs() > 1e-10) {
          eigenvectors.add([b, lambda - a]);
        } else if (c.abs() > 1e-10) {
          eigenvectors.add([lambda - d, c]);
        } else {
          eigenvectors.add([1, 0]);
        }
      }
    } else {
      // Complex eigenvalues
      final real = trace / 2;
      final imag = math.sqrt(-discriminant) / 2;
      eigenvalues.addAll([real, -real]);
      eigenvectors.add([real, imag]);
      eigenvectors.add([real, -imag]);
    }
    
    return EigenResult(eigenvalues, eigenvectors);
  }
  
  /// Solve Ax = b using Gaussian elimination
  static List<double> solveSystem(List<List<double>> A, List<double> b) {
    final n = A.length;
    if (A[0].length != n) throw ArgumentError('Matrix must be square');
    if (b.length != n) throw ArgumentError('Vector size must match matrix');
    
    // Augmented matrix
    final augmented = List.generate(n, (i) {
      return [...A[i], b[i]];
    });
    
    // Forward elimination with partial pivoting
    for (int col = 0; col < n; col++) {
      int maxRow = col;
      for (int row = col + 1; row < n; row++) {
        if (augmented[row][col].abs() > augmented[maxRow][col].abs()) {
          maxRow = row;
        }
      }
      _swapRows(augmented, col, maxRow);
      
      if (augmented[col][col].abs() < 1e-10) {
        throw ArgumentError('System has no unique solution');
      }
      
      for (int row = col + 1; row < n; row++) {
        final factor = augmented[row][col] / augmented[col][col];
        for (int j = col; j <= n; j++) {
          augmented[row][j] -= factor * augmented[col][j];
        }
      }
    }
    
    // Back substitution
    final x = List<double>.filled(n, 0);
    for (int i = n - 1; i >= 0; i--) {
      x[i] = augmented[i][n];
      for (int j = i + 1; j < n; j++) {
        x[i] -= augmented[i][j] * x[j];
      }
      x[i] /= augmented[i][i];
    }
    
    return x;
  }
  
  /// Convert matrix to string representation
  static String matrixToString(List<List<double>> matrix, {int precision = 4}) {
    final buffer = StringBuffer('┌ ');
    final rows = matrix.length;
    final cols = matrix[0].length;
    
    // Find max width
    int maxWidth = 0;
    for (final row in matrix) {
      for (final val in row) {
        final s = val.toStringAsFixed(precision);
        if (s.length > maxWidth) maxWidth = s.length;
      }
    }
    
    for (int i = 0; i < rows; i++) {
      if (i == 0) {
        buffer.write('┌ ');
      } else if (i == rows - 1) {
        buffer.write('└ ');
      } else {
        buffer.write('│ ');
      }
      
      for (int j = 0; j < cols; j++) {
        final s = matrix[i][j].toStringAsFixed(precision);
        buffer.write(s.padLeft(maxWidth));
        if (j < cols - 1) buffer.write('  ');
      }
      
      if (i == 0) {
        buffer.writeln(' ┐');
      } else if (i == rows - 1) {
        buffer.writeln(' ┘');
      } else {
        buffer.writeln(' │');
      }
    }
    
    return buffer.toString();
  }
  
  // --- Internal helpers ---
  
  static double _luDeterminant(List<List<double>> matrix) {
    final n = matrix.length;
    final lu = List.generate(n, (i) => List<double>.from(matrix[i]));
    int sign = 1;
    
    for (int col = 0; col < n; col++) {
      int pivotRow = col;
      for (int row = col + 1; row < n; row++) {
        if (lu[row][col].abs() > lu[pivotRow][col].abs()) {
          pivotRow = row;
        }
      }
      
      if (lu[pivotRow][col].abs() < 1e-10) return 0;
      
      if (pivotRow != col) {
        _swapRows(lu, col, pivotRow);
        sign *= -1;
      }
      
      for (int row = col + 1; row < n; row++) {
        lu[row][col] /= lu[col][col];
        for (int j = col + 1; j < n; j++) {
          lu[row][j] -= lu[row][col] * lu[col][j];
        }
      }
    }
    
    double det = sign.toDouble();
    for (int i = 0; i < n; i++) {
      det *= lu[i][i];
    }
    return det;
  }
  
  static void _swapRows(List<List<double>> matrix, int i, int j) {
    final temp = matrix[i];
    matrix[i] = matrix[j];
    matrix[j] = temp;
  }
  
  static void _checkSameDimensions(List<List<double>> a, List<List<double>> b) {
    if (a.length != b.length || a[0].length != b[0].length) {
      throw ArgumentError(
        'Matrix dimensions must match: ${a.length}×${a[0].length} vs ${b.length}×${b[0].length}',
      );
    }
  }
}

/// Eigenvalue computation result
class EigenResult {
  final List<double> eigenvalues;
  final List<List<double>> eigenvectors;
  
  const EigenResult(this.eigenvalues, this.eigenvectors);
}
