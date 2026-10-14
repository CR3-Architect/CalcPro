import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/color_tokens.dart';

/// Unit converter with 12 categories and 100+ units
class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen> {
  String _selectedCategory = 'Length';
  String _fromUnit = 'Meter';
  String _toUnit = 'Kilometer';
  final TextEditingController _inputController = TextEditingController(text: '1');
  double _result = 0;
  bool _showConstants = false;
  
  @override
  void initState() {
    super.initState();
    _convert();
  }
  
  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }
  
  static const Map<String, Map<String, double>> _units = {
    'Length': {
      'Meter': 1, 'Kilometer': 1000, 'Centimeter': 0.01, 'Millimeter': 0.001,
      'Micrometer': 1e-6, 'Nanometer': 1e-9, 'Mile': 1609.344, 'Yard': 0.9144,
      'Foot': 0.3048, 'Inch': 0.0254, 'Nautical Mile': 1852, 'Light Year': 9.4607e15,
      'Parsec': 3.0857e16, 'Astronomical Unit': 1.49598e11,
    },
    'Mass': {
      'Kilogram': 1, 'Gram': 0.001, 'Milligram': 1e-6, 'Microgram': 1e-9,
      'Metric Ton': 1000, 'Pound': 0.453592, 'Ounce': 0.0283495,
      'Stone': 6.35029, 'US Ton': 907.185, 'Imperial Ton': 1016.05,
      'Atomic Mass Unit': 1.66054e-27,
    },
    'Temperature': {
      'Celsius': 1, 'Fahrenheit': 1, 'Kelvin': 1, 'Rankine': 1,
    },
    'Time': {
      'Second': 1, 'Millisecond': 0.001, 'Microsecond': 1e-6, 'Nanosecond': 1e-9,
      'Minute': 60, 'Hour': 3600, 'Day': 86400, 'Week': 604800,
      'Month (30d)': 2592000, 'Year (365d)': 31536000, 'Decade': 315360000,
      'Century': 3153600000,
    },
    'Speed': {
      'm/s': 1, 'km/h': 0.277778, 'mph': 0.44704, 'knot': 0.514444,
      'ft/s': 0.3048, 'Mach': 343, 'c (speed of light)': 299792458,
    },
    'Area': {
      'sq meter': 1, 'sq kilometer': 1e6, 'sq centimeter': 1e-4, 'sq millimeter': 1e-6,
      'Hectare': 10000, 'Acre': 4046.86, 'sq foot': 0.092903, 'sq inch': 6.4516e-4,
      'sq mile': 2.59e6, 'sq yard': 0.836127,
    },
    'Volume': {
      'Liter': 1, 'Milliliter': 0.001, 'Cubic Meter': 1000, 'Cubic Centimeter': 0.001,
      'Gallon (US)': 3.78541, 'Gallon (UK)': 4.54609, 'Quart (US)': 0.946353,
      'Pint (US)': 0.473176, 'Cup (US)': 0.236588, 'Fluid Ounce (US)': 0.0295735,
      'Tablespoon': 0.0147868, 'Teaspoon': 0.00492892, 'Cubic Foot': 28.3168,
      'Cubic Inch': 0.0163871,
    },
    'Data Storage': {
      'Bit': 1, 'Byte': 8, 'Kilobyte': 8192, 'Megabyte': 8388608,
      'Gigabyte': 8589934592, 'Terabyte': 8796093022208, 'Petabyte': 8.8e15,
      'Kibibyte': 8192, 'Mebibyte': 8388608, 'Gibibyte': 8.59e9,
      'Nibble': 4, 'Word (16-bit)': 16, 'Dword (32-bit)': 32,
    },
    'Energy': {
      'Joule': 1, 'Kilojoule': 1000, 'Calorie': 4184, 'Kilocalorie': 4184000,
      'Watt-hour': 3600, 'Kilowatt-hour': 3.6e6, 'Electron Volt': 1.60218e-19,
      'BTU': 1055.06, 'Foot-pound': 1.35582,
    },
    'Pressure': {
      'Pascal': 1, 'Kilopascal': 1000, 'Bar': 100000, 'Atmosphere': 101325,
      'psi': 6894.76, 'mmHg': 133.322, 'Torr': 133.322,
      'Megapascal': 1e6, 'Gigapascal': 1e9,
    },
    'Frequency': {
      'Hertz': 1, 'Kilohertz': 1000, 'Megahertz': 1e6, 'Gigahertz': 1e9,
      'Terahertz': 1e12, 'RPM': 1/60,
    },
    'Angle': {
      'Degree': 1, 'Radian': 57.2958, 'Gradian': 0.9, 'Arc Minute': 1/60,
      'Arc Second': 1/3600, 'Turn': 360,
    },
  };
  
  /// Physical constants reference table
  static const Map<String, Map<String, String>> _constants = {
    'Speed of Light': {'value': '299,792,458', 'unit': 'm/s', 'symbol': 'c'},
    'Planck Constant': {'value': '6.626 × 10⁻³⁴', 'unit': 'J·s', 'symbol': 'h'},
    'Gravitational Constant': {'value': '6.674 × 10⁻¹¹', 'unit': 'm³/(kg·s²)', 'symbol': 'G'},
    'Boltzmann Constant': {'value': '1.381 × 10⁻²³', 'unit': 'J/K', 'symbol': 'kB'},
    'Elementary Charge': {'value': '1.602 × 10⁻¹⁹', 'unit': 'C', 'symbol': 'e'},
    'Electron Mass': {'value': '9.109 × 10⁻³¹', 'unit': 'kg', 'symbol': 'me'},
    'Proton Mass': {'value': '1.673 × 10⁻²⁷', 'unit': 'kg', 'symbol': 'mp'},
    'Avogadro Number': {'value': '6.022 × 10²³', 'unit': '/mol', 'symbol': 'NA'},
    'Gas Constant': {'value': '8.314', 'unit': 'J/(mol·K)', 'symbol': 'R'},
    'Stefan-Boltzmann': {'value': '5.670 × 10⁻⁸', 'unit': 'W/(m²·K⁴)', 'symbol': 'σ'},
    'Standard Gravity': {'value': '9.807', 'unit': 'm/s²', 'symbol': 'g'},
    'Earth Mass': {'value': '5.972 × 10²⁴', 'unit': 'kg', 'symbol': 'M⊕'},
    'Earth Radius': {'value': '6,371', 'unit': 'km', 'symbol': 'R⊕'},
  };
  
  void _convert() {
    final input = double.tryParse(_inputController.text);
    if (input == null) {
      setState(() => _result = 0);
      return;
    }
    
    if (_selectedCategory == 'Temperature') {
      _result = _convertTemperature(input, _fromUnit, _toUnit);
    } else {
      final units = _units[_selectedCategory]!;
      final fromFactor = units[_fromUnit]!;
      final toFactor = units[_toUnit]!;
      _result = input * fromFactor / toFactor;
    }
    setState(() {});
  }
  
  double _convertTemperature(double value, String from, String to) {
    // Convert to Celsius first
    double celsius;
    switch (from) {
      case 'Celsius': celsius = value; break;
      case 'Fahrenheit': celsius = (value - 32) * 5 / 9; break;
      case 'Kelvin': celsius = value - 273.15; break;
      case 'Rankine': celsius = (value - 491.67) * 5 / 9; break;
      default: celsius = value;
    }
    
    // Convert from Celsius
    switch (to) {
      case 'Celsius': return celsius;
      case 'Fahrenheit': return celsius * 9 / 5 + 32;
      case 'Kelvin': return celsius + 273.15;
      case 'Rankine': return (celsius + 273.15) * 9 / 5;
      default: return celsius;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final units = _units[_selectedCategory]!.keys.toList();
    
    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text(
          _showConstants ? 'Physical Constants' : 'Unit Converter',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showConstants = !_showConstants),
            icon: Icon(_showConstants ? Icons.swap_horiz : Icons.science),
          ),
        ],
      ),
      body: _showConstants
          ? _buildConstantsTable(isDark)
          : _buildConverter(isDark, units),
    );
  }
  
  Widget _buildConverter(bool isDark, List<String> units) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Category selector
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _units.keys.map((cat) {
              final isSelected = cat == _selectedCategory;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategory = cat;
                      _fromUnit = _units[cat]!.keys.first;
                      _toUnit = _units[cat]!.keys.last;
                    });
                    _convert();
                  },
                  selectedColor: ColorTokens.electricCyan.withOpacity(0.2),
                  checkmarkColor: ColorTokens.electricCyan,
                ),
              );
            }).toList(),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Input value
        TextField(
          controller: _inputController,
          keyboardType: TextInputType.number,
          onChanged: (_) => _convert(),
          style: TextStyle(fontFamily: 'monospace', fontSize: 24),
          decoration: InputDecoration(
            labelText: 'Value',
            filled: true,
            fillColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // From unit
        _buildUnitDropdown('From', _fromUnit, units, (value) {
          setState(() {
            _fromUnit = value!;
            _toUnit = units.firstWhere((u) => u != _fromUnit, orElse: () => units.first);
          });
          _convert();
        }, isDark),
        
        const SizedBox(height: 8),
        
        // Swap button
        Center(
          child: IconButton(
            onPressed: () {
              setState(() {
                final temp = _fromUnit;
                _fromUnit = _toUnit;
                _toUnit = temp;
              });
              _convert();
            },
            icon: const Icon(Icons.swap_vert_rounded),
            style: IconButton.styleFrom(
              backgroundColor: ColorTokens.electricCyan.withOpacity(0.1),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // To unit
        _buildUnitDropdown('To', _toUnit, units, (value) {
          setState(() => _toUnit = value!);
          _convert();
        }, isDark),
        
        const SizedBox(height: 24),
        
        // Result
        Card(
          color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '${_inputController.text} $_fromUnit',
                  style: TextStyle(
                    fontSize: 16,
                    color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                        .withOpacity(0.6),
                  ),
                ),
                const Icon(Icons.arrow_downward_rounded, color: ColorTokens.electricCyan),
                const SizedBox(height: 8),
                Text(
                  _formatResult(_result),
                  style: TextStyle(fontFamily: 'monospace', 
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: ColorTokens.electricCyan,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _toUnit,
                  style: TextStyle(
                    fontSize: 16,
                    color: (isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface)
                        .withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                // Copy button
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _formatResult(_result)));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Result copied'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildUnitDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
    bool isDark,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((unit) {
        return DropdownMenuItem(
          value: unit,
          child: Text(unit, style: TextStyle()),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
  
  Widget _buildConstantsTable(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _constants.length,
      itemBuilder: (context, index) {
        final entry = _constants.entries.elementAt(index);
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorTokens.electricCyan.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  entry.value['symbol']!,
                  style: TextStyle(fontFamily: 'monospace', 
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ColorTokens.electricCyan,
                  ),
                ),
              ),
            ),
            title: Text(entry.key, style: TextStyle(fontSize: 14)),
            subtitle: Text(
              '${entry.value['value']} ${entry.value['unit']}',
              style: TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
            onTap: () {
              Clipboard.setData(ClipboardData(text: '${entry.value['value']} ${entry.value['unit']}'));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Constant copied'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        );
      },
    );
  }
  
  String _formatResult(double value) {
    if (value.isNaN || value.isInfinite) return value.toString();
    if (value.abs() >= 1e15 || (value.abs() < 1e-6 && value != 0)) {
      return value.toStringAsExponential(6);
    }
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(8).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
}
