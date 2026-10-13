import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../core/theme/color_tokens.dart';

/// Currency converter with live exchange rates
class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  double _amount = 1;
  String _from = 'USD';
  String _to = 'EUR';
  double _result = 0;
  bool _loading = false;
  String? _error;
  Map<String, double> _rates = {};
  DateTime? _lastUpdated;

  static const List<String> _currencies = [
    'USD', 'EUR', 'GBP', 'JPY', 'AUD', 'CAD', 'CHF', 'CNY', 'INR', 'PKR',
    'SAR', 'AED', 'TRY', 'RUB', 'BRL', 'MXN', 'KRW', 'SGD', 'HKD', 'NZD',
    'SEK', 'NOK', 'DKK', 'PLN', 'THB', 'ZAR', 'EGP', 'NGN', 'KES', 'GHS',
    'BDT', 'LKR', 'MYR', 'IDR', 'PHP', 'VND', 'UAH', 'CZK', 'HUF', 'ILS',
  ];

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // free API, no key needed
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final resp = await http.get(url).timeout(const Duration(seconds: 10));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final ratesMap = data['rates'] as Map<String, dynamic>;
        setState(() {
          _rates = ratesMap.map((k, v) => MapEntry(k, (v as num).toDouble()));
          _lastUpdated = DateTime.now();
          _loading = false;
        });
        _convert();
      } else {
        setState(() {
          _error = 'API error ${resp.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Network error — check connection';
        _loading = false;
      });
    }
  }

  void _convert() {
    if (_rates.isEmpty) return;
    final fromRate = _rates[_from];
    final toRate = _rates[_to];
    if (fromRate == null || toRate == null) {
      setState(() => _error = 'Currency not available');
      return;
    }
    // rates are relative to USD
    setState(() {
      _result = _amount / fromRate * toRate;
      _error = null;
    });
  }

  void _swap() {
    setState(() {
      final t = _from;
      _from = _to;
      _to = t;
    });
    _convert();
  }

  void _share() {
    final text = '$_amount $_from = ${_result.toStringAsFixed(2)} $_to\nvia CalcPro Studio';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final subFg = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
    final surface = isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface;

    return Scaffold(
      backgroundColor: isDark ? ColorTokens.darkBackground : ColorTokens.lightBackground,
      appBar: AppBar(
        title: Text('Currency Converter', style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
        iconTheme: IconThemeData(color: fg),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetchRates,
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, size: 20),
            tooltip: 'Refresh rates',
          ),
          IconButton(
            onPressed: _share,
            icon: const Icon(Icons.share, size: 20),
            tooltip: 'Share',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: ColorTokens.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  style: const TextStyle(color: ColorTokens.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),

            if (_lastUpdated != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Rates updated ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 11, color: subFg.withOpacity(0.5)),
                ),
              ),

            // From
            _CurrencyCard(
              label: 'From',
              amount: _amount,
              currency: _from,
              currencies: _currencies,
              isDark: isDark,
              fg: fg,
              subFg: subFg,
              surface: surface,
              onAmountChanged: (v) {
                _amount = v;
                _convert();
              },
              onCurrencyChanged: (v) {
                _from = v;
                _convert();
              },
            ),

            // Swap button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: GestureDetector(
                onTap: _swap,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ColorTokens.electricCyan.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.swap_vert_rounded, color: ColorTokens.electricCyan, size: 24),
                ),
              ),
            ),

            // To
            _CurrencyCard(
              label: 'To',
              amount: _result,
              currency: _to,
              currencies: _currencies,
              isDark: isDark,
              fg: fg,
              subFg: subFg,
              surface: surface,
              readOnlyAmount: true,
              onAmountChanged: (_) {},
              onCurrencyChanged: (v) {
                _to = v;
                _convert();
              },
            ),

            const Spacer(),

            // Info
            Text(
              'Live rates via open.er-api.com',
              style: TextStyle(fontSize: 11, color: subFg.withOpacity(0.4)),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _CurrencyCard extends StatelessWidget {
  final String label;
  final double amount;
  final String currency;
  final List<String> currencies;
  final bool isDark;
  final Color fg;
  final Color subFg;
  final Color surface;
  final bool readOnlyAmount;
  final ValueChanged<double> onAmountChanged;
  final ValueChanged<String> onCurrencyChanged;

  const _CurrencyCard({
    required this.label,
    required this.amount,
    required this.currency,
    required this.currencies,
    required this.isDark,
    required this.fg,
    required this.subFg,
    required this.surface,
    required this.onAmountChanged,
    required this.onCurrencyChanged,
    this.readOnlyAmount = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: subFg.withOpacity(0.6), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: readOnlyAmount
                    ? Text(
                        amount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          fontFamily: 'Roboto Mono',
                        ),
                      )
                    : TextFormField(
                        initialValue: amount == amount.roundToDouble() ? amount.toStringAsFixed(0) : amount.toString(),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          fontFamily: 'Roboto Mono',
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) {
                          final parsed = double.tryParse(v.replaceAll(',', ''));
                          if (parsed != null) onAmountChanged(parsed);
                        },
                      ),
              ),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: currency,
                dropdownColor: surface,
                underline: const SizedBox(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorTokens.electricCyan,
                ),
                items: currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCurrencyChanged(v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
