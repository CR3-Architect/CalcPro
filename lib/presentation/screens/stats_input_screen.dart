import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/color_tokens.dart';
import '../../domain/functions/stats_functions.dart';

/// Statistics data entry table with analysis results
class StatsInputScreen extends StatefulWidget {
  const StatsInputScreen({super.key});

  @override
  State<StatsInputScreen> createState() => _StatsInputScreenState();
}

class _StatsInputScreenState extends State<StatsInputScreen> {
  final TextEditingController _dataController = TextEditingController();
  List<double> _data = [];
  String _selectedTest = '1-Variable Stats';
  
  // 2-variable data
  final TextEditingController _xDataController = TextEditingController();
  final TextEditingController _yDataController = TextEditingController();
  List<double> _xData = [];
  List<double> _yData = [];
  
  String _results = '';
  
  void _parseData() {
    final text = _dataController.text.trim();
    if (text.isEmpty) {
      _data = [];
      return;
    }
    _data = text
        .split(RegExp(r'[\s,;]+'))
        .map((s) => double.tryParse(s))
        .where((d) => d != null)
        .cast<double>()
        .toList();
  }
  
  void _parseXYData() {
    final xText = _xDataController.text.trim();
    final yText = _yDataController.text.trim();
    
    _xData = xText
        .split(RegExp(r'[\s,;]+'))
        .map((s) => double.tryParse(s))
        .where((d) => d != null)
        .cast<double>()
        .toList();
    
    _yData = yText
        .split(RegExp(r'[\s,;]+'))
        .map((s) => double.tryParse(s))
        .where((d) => d != null)
        .cast<double>()
        .toList();
  }
  
  void _computeStats() {
    try {
      if (_selectedTest == '1-Variable Stats') {
        _parseData();
        if (_data.isEmpty) {
          _results = 'Please enter data (space or comma separated)';
          setState(() {});
          return;
        }
        
        final n = _data.length;
        final meanVal = StatsFunctions.mean(_data);
        final medianVal = StatsFunctions.median(_data);
        final minVal = StatsFunctions.min(_data);
        final maxVal = StatsFunctions.max(_data);
        final rangeVal = StatsFunctions.range(_data);
        final stdDevVal = StatsFunctions.stdDev(_data);
        final varianceVal = StatsFunctions.variance(_data);
        final sum = _data.reduce((a, b) => a + b);
        final sumSq = _data.map((x) => x * x).reduce((a, b) => a + b);
        final modes = StatsFunctions.mode(_data);
        final q1Val = StatsFunctions.q1(_data);
        final q3Val = StatsFunctions.q3(_data);
        final iqrVal = StatsFunctions.iqr(_data);
        
        _results = '''
$n = $n
Sum (Σx) = ${sum.toStringAsFixed(6)}
Sum of squares (Σx²) = ${sumSq.toStringAsFixed(6)}
Mean (x̄) = ${meanVal.toStringAsFixed(6)}
Median = ${medianVal.toStringAsFixed(6)}
Mode = ${modes.map((m) => m.toStringAsFixed(2)).join(', ')}
Std Dev (σ) = ${stdDevVal.toStringAsFixed(6)}
Sample Std Dev (s) = ${StatsFunctions.stdDev(_data, population: false).toStringAsFixed(6)}
Variance (σ²) = ${varianceVal.toStringAsFixed(6)}
Sample Variance (s²) = ${StatsFunctions.variance(_data, population: false).toStringAsFixed(6)}
Min = ${minVal.toStringAsFixed(6)}
Max = ${maxVal.toStringAsFixed(6)}
Range = ${rangeVal.toStringAsFixed(6)}
Q1 = ${q1Val.toStringAsFixed(6)}
Q3 = ${q3Val.toStringAsFixed(6)}
IQR = ${iqrVal.toStringAsFixed(6)}
Geometric Mean = ${StatsFunctions.geometricMean(_data).toStringAsFixed(6)}
Harmonic Mean = ${StatsFunctions.harmonicMean(_data).toStringAsFixed(6)}
''';
      } else if (_selectedTest == '2-Variable Stats') {
        _parseXYData();
        if (_xData.length != _yData.length || _xData.isEmpty) {
          _results = 'X and Y data must have same non-zero length';
          setState(() {});
          return;
        }
        
        final reg = StatsFunctions.linearRegression(_xData, _yData);
        final corr = StatsFunctions.correlation(_xData, _yData);
        final rSquared = corr * corr;
        
        _results = '''
n = ${_xData.length}
x̄ = ${StatsFunctions.mean(_xData).toStringAsFixed(6)}
ȳ = ${StatsFunctions.mean(_yData).toStringAsFixed(6)}
r (correlation) = ${corr.toStringAsFixed(6)}
r² = ${rSquared.toStringAsFixed(6)}
$reg
Predictions:
  x=0 → y=${reg.predict(0).toStringAsFixed(6)}
  x=1 → y=${reg.predict(1).toStringAsFixed(6)}
''';
        
        // Try quadratic regression if enough data
        if (_xData.length >= 3) {
          try {
            final qreg = StatsFunctions.quadraticRegression(_xData, _yData);
            _results += '\nQuadratic: $qreg';
          } catch (_) {}
        }
      } else if (_selectedTest == 'Normal Distribution') {
        final controller = TextEditingController();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Normal Distribution'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'x value'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final x = double.tryParse(controller.text) ?? 0;
                  final pdf = StatsFunctions.normalPDF(x);
                  final cdf = StatsFunctions.normalCDF(x);
                  Navigator.pop(context);
                  setState(() {
                    _results = '''
Normal Distribution (μ=0, σ=1):
PDF($x) = ${pdf.toStringAsFixed(6)}
CDF($x) = ${cdf.toStringAsFixed(6)}
P(Z < $x) = ${(cdf * 100).toStringAsFixed(4)}%
P(Z > $x) = ${((1 - cdf) * 100).toStringAsFixed(4)}%
''';
                  });
                },
                child: const Text('Calculate'),
              ),
            ],
          ),
        );
      } else if (_selectedTest == 'Binomial Distribution') {
        final nCtrl = TextEditingController(text: '10');
        final pCtrl = TextEditingController(text: '0.5');
        final kCtrl = TextEditingController(text: '5');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Binomial Distribution'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nCtrl, decoration: const InputDecoration(labelText: 'n (trials)'), keyboardType: TextInputType.number),
                TextField(controller: pCtrl, decoration: const InputDecoration(labelText: 'p (probability)'), keyboardType: TextInputType.number),
                TextField(controller: kCtrl, decoration: const InputDecoration(labelText: 'k (successes)'), keyboardType: TextInputType.number),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final n = int.tryParse(nCtrl.text) ?? 10;
                  final p = double.tryParse(pCtrl.text) ?? 0.5;
                  final k = int.tryParse(kCtrl.text) ?? 5;
                  final pmf = StatsFunctions.binomialPMF(k, n, p);
                  final cdf = StatsFunctions.binomialCDF(k, n, p);
                  Navigator.pop(context);
                  setState(() {
                    _results = '''
Binomial(n=$n, p=$p):
P(X=$k) = ${(math.exp(pmf) * 100).toStringAsFixed(4)}%
P(X≤$k) = ${(cdf * 100).toStringAsFixed(4)}%
Mean = ${(n * p).toStringAsFixed(4)}
Var = ${(n * p * (1 - p)).toStringAsFixed(4)}
''';
                  });
                },
                child: const Text('Calculate'),
              ),
            ],
          ),
        );
      } else if (_selectedTest == 'Random Numbers') {
        final minCtrl = TextEditingController(text: '0');
        final maxCtrl = TextEditingController(text: '100');
        final countCtrl = TextEditingController(text: '10');
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Random Number Generator'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Min'), keyboardType: TextInputType.number),
                TextField(controller: maxCtrl, decoration: const InputDecoration(labelText: 'Max'), keyboardType: TextInputType.number),
                TextField(controller: countCtrl, decoration: const InputDecoration(labelText: 'Count'), keyboardType: TextInputType.number),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  final min = double.tryParse(minCtrl.text) ?? 0;
                  final max = double.tryParse(maxCtrl.text) ?? 100;
                  final count = int.tryParse(countCtrl.text) ?? 10;
                  final rng = math.Random();
                  final numbers = List.generate(count, (_) => 
                    (min + rng.nextDouble() * (max - min)).toStringAsFixed(4));
                  Navigator.pop(context);
                  setState(() {
                    _results = 'Random numbers ($count):\n${numbers.join(', ')}\n\nSum: ${numbers.map((n) => double.parse(n)).reduce((a, b) => a + b).toStringAsFixed(4)}\nMean: ${StatsFunctions.mean(numbers.map((n) => double.parse(n)).toList()).toStringAsFixed(4)}';
                  });
                },
                child: const Text('Generate'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _results = 'Error: $e';
    }
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text(
          'Statistics & Probability',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Mode selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                '1-Variable Stats', '2-Variable Stats', 'Normal Distribution',
                'Binomial Distribution', 'Random Numbers',
              ].map((test) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(test, style: const TextStyle(fontSize: 12)),
                    selected: _selectedTest == test,
                    onSelected: (_) => setState(() => _selectedTest = test),
                    selectedColor: ColorTokens.electricCyan.withOpacity(0.2),
                    checkmarkColor: ColorTokens.electricCyan,
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Data input
          if (_selectedTest == '1-Variable Stats') ...[
            TextField(
              controller: _dataController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Enter data (space or comma separated)',
                hintText: 'e.g., 12, 15, 18, 22, 25',
                filled: true,
                fillColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
          ] else if (_selectedTest == '2-Variable Stats') ...[
            TextField(
              controller: _xDataController,
              decoration: InputDecoration(
                labelText: 'X values (space or comma separated)',
                filled: true,
                fillColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _yDataController,
              decoration: InputDecoration(
                labelText: 'Y values (space or comma separated)',
                filled: true,
                fillColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
          
          const SizedBox(height: 16),
          
          // Calculate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _computeStats,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorTokens.electricCyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _selectedTest.contains('Distribution') || _selectedTest.contains('Random')
                    ? 'Open Tool'
                    : 'Calculate Statistics',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Results
          if (_results.isNotEmpty)
            Card(
              color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.analytics, color: ColorTokens.electricCyan, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Results',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _results));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Results copied')),
                            );
                          },
                          icon: const Icon(Icons.copy, size: 18),
                        ),
                      ],
                    ),
                    const Divider(),
                    Text(
                      _results,
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Data count
          if (_data.isNotEmpty)
            Text(
              '${_data.length} data points loaded',
              style: TextStyle(
                fontSize: 12,
                color: ColorTokens.electricCyan,
              ),
            ),
        ],
      ),
    );
  }
}
