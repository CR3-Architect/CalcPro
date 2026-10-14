import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../core/theme/color_tokens.dart';

/// Currency converter with live exchange rates — all world currencies A-Z
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
  String _searchFrom = '';
  String _searchTo = '';

  /// All ISO 4217 world currencies with names — sorted A-Z
  static const Map<String, String> _allCurrencies = {
    'AED': 'UAE Dirham',
    'AFN': 'Afghan Afghani',
    'ALL': 'Albanian Lek',
    'AMD': 'Armenian Dram',
    'ANG': 'Netherlands Antillean Guilder',
    'AOA': 'Angolan Kwanza',
    'ARS': 'Argentine Peso',
    'AUD': 'Australian Dollar',
    'AWG': 'Aruban Florin',
    'AZN': 'Azerbaijani Manat',
    'BAM': 'Bosnian Convertible Mark',
    'BBD': 'Barbadian Dollar',
    'BDT': 'Bangladeshi Taka',
    'BGN': 'Bulgarian Lev',
    'BHD': 'Bahraini Dinar',
    'BIF': 'Burundian Franc',
    'BMD': 'Bermudian Dollar',
    'BND': 'Brunei Dollar',
    'BOB': 'Bolivian Boliviano',
    'BRL': 'Brazilian Real',
    'BSD': 'Bahamian Dollar',
    'BTN': 'Bhutanese Ngultrum',
    'BWP': 'Botswana Pula',
    'BYN': 'Belarusian Ruble',
    'BZD': 'Belize Dollar',
    'CAD': 'Canadian Dollar',
    'CDF': 'Congolese Franc',
    'CHF': 'Swiss Franc',
    'CLP': 'Chilean Peso',
    'CNY': 'Chinese Yuan',
    'COP': 'Colombian Peso',
    'CRC': 'Costa Rican Colón',
    'CUP': 'Cuban Peso',
    'CVE': 'Cape Verdean Escudo',
    'CZK': 'Czech Koruna',
    'DJF': 'Djiboutian Franc',
    'DKK': 'Danish Krone',
    'DOP': 'Dominican Peso',
    'DZD': 'Algerian Dinar',
    'EGP': 'Egyptian Pound',
    'ERN': 'Eritrean Nakfa',
    'ETB': 'Ethiopian Birr',
    'EUR': 'Euro',
    'FJD': 'Fijian Dollar',
    'FKP': 'Falkland Islands Pound',
    'GBP': 'British Pound Sterling',
    'GEL': 'Georgian Lari',
    'GHS': 'Ghanaian Cedi',
    'GIP': 'Gibraltar Pound',
    'GMD': 'Gambian Dalasi',
    'GNF': 'Guinean Franc',
    'GTQ': 'Guatemalan Quetzal',
    'GYD': 'Guyanese Dollar',
    'HKD': 'Hong Kong Dollar',
    'HNL': 'Honduran Lempira',
    'HRK': 'Croatian Kuna',
    'HTG': 'Haitian Gourde',
    'HUF': 'Hungarian Forint',
    'IDR': 'Indonesian Rupiah',
    'ILS': 'Israeli New Shekel',
    'INR': 'Indian Rupee',
    'IQD': 'Iraqi Dinar',
    'IRR': 'Iranian Rial',
    'ISK': 'Icelandic Króna',
    'JMD': 'Jamaican Dollar',
    'JOD': 'Jordanian Dinar',
    'JPY': 'Japanese Yen',
    'KES': 'Kenyan Shilling',
    'KGS': 'Kyrgyzstani Som',
    'KHR': 'Cambodian Riel',
    'KMF': 'Comorian Franc',
    'KRW': 'South Korean Won',
    'KWD': 'Kuwaiti Dinar',
    'KYD': 'Cayman Islands Dollar',
    'KZT': 'Kazakhstani Tenge',
    'LAK': 'Lao Kip',
    'LBP': 'Lebanese Pound',
    'LKR': 'Sri Lankan Rupee',
    'LRD': 'Liberian Dollar',
    'LSL': 'Lesotho Loti',
    'LYD': 'Libyan Dinar',
    'MAD': 'Moroccan Dirham',
    'MDL': 'Moldovan Leu',
    'MGA': 'Malagasy Ariary',
    'MKD': 'Macedonian Denar',
    'MMK': 'Myanmar Kyat',
    'MNT': 'Mongolian Tögrög',
    'MOP': 'Macanese Pataca',
    'MRU': 'Mauritanian Ouguiya',
    'MUR': 'Mauritian Rupee',
    'MVR': 'Maldivian Rufiyaa',
    'MWK': 'Malawian Kwacha',
    'MXN': 'Mexican Peso',
    'MYR': 'Malaysian Ringgit',
    'MZN': 'Mozambican Metical',
    'NAD': 'Namibian Dollar',
    'NGN': 'Nigerian Naira',
    'NIO': 'Nicaraguan Córdoba',
    'NOK': 'Norwegian Krone',
    'NPR': 'Nepalese Rupee',
    'NZD': 'New Zealand Dollar',
    'OMR': 'Omani Rial',
    'PAB': 'Panamanian Balboa',
    'PEN': 'Peruvian Sol',
    'PGK': 'Papua New Guinean Kina',
    'PHP': 'Philippine Peso',
    'PKR': 'Pakistani Rupee',
    'PLN': 'Polish Złoty',
    'PYG': 'Paraguayan Guarani',
    'QAR': 'Qatari Riyal',
    'RON': 'Romanian Leu',
    'RSD': 'Serbian Dinar',
    'RUB': 'Russian Ruble',
    'RWF': 'Rwandan Franc',
    'SAR': 'Saudi Riyal',
    'SBD': 'Solomon Islands Dollar',
    'SCR': 'Seychellois Rupee',
    'SDG': 'Sudanese Pound',
    'SEK': 'Swedish Krona',
    'SGD': 'Singapore Dollar',
    'SHP': 'Saint Helena Pound',
    'SLE': 'Sierra Leonean Leone',
    'SOS': 'Somali Shilling',
    'SRD': 'Surinamese Dollar',
    'SSP': 'South Sudanese Pound',
    'STN': 'São Tomé and Príncipe Dobra',
    'SYP': 'Syrian Pound',
    'SZL': 'Swazi Lilangeni',
    'THB': 'Thai Baht',
    'TJS': 'Tajikistani Somoni',
    'TMT': 'Turkmenistani Manat',
    'TND': 'Tunisian Dinar',
    'TOP': 'Tongan Paʻanga',
    'TRY': 'Turkish Lira',
    'TTD': 'Trinidad and Tobago Dollar',
    'TWD': 'New Taiwan Dollar',
    'TZS': 'Tanzanian Shilling',
    'UAH': 'Ukrainian Hryvnia',
    'UGX': 'Ugandan Shilling',
    'USD': 'US Dollar',
    'UYU': 'Uruguayan Peso',
    'UZS': 'Uzbekistani Som',
    'VED': 'Venezuelan Bolívar',
    'VND': 'Vietnamese Đồng',
    'VUV': 'Vanuatu Vatu',
    'WST': 'Samoan Tala',
    'XAF': 'Central African CFA Franc',
    'XCD': 'East Caribbean Dollar',
    'XOF': 'West African CFA Franc',
    'XPF': 'CFP Franc',
    'YER': 'Yemeni Rial',
    'ZAR': 'South African Rand',
    'ZMW': 'Zambian Kwacha',
    'ZWG': 'Zimbabwean Gold',
  };

  late final List<String> _sortedCodes = _allCurrencies.keys.toList()..sort();

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
      final url = Uri.parse('https://open.er-api.com/v6/latest/USD');
      final resp = await http.get(url).timeout(const Duration(seconds: 12));

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
      setState(() => _error = 'Rate not available for this currency');
      return;
    }
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
    final text =
        '$_amount $_from = ${_result.toStringAsFixed(2)} $_to\nvia CalcPro Studio';
    Share.share(text);
  }

  List<String> _filterCodes(String query) {
    if (query.isEmpty) return _sortedCodes;
    final q = query.toUpperCase();
    return _sortedCodes.where((code) {
      final name = _allCurrencies[code] ?? '';
      return code.contains(q) || name.toUpperCase().contains(q);
    }).toList();
  }

  void _showCurrencyPicker({required bool isFrom}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final surface = isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface;
    final query = isFrom ? _searchFrom : _searchTo;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (ctx, scrollCtrl) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    autofocus: false,
                    style: TextStyle(color: fg, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Search currency or country...',
                      hintStyle: TextStyle(color: fg.withOpacity(0.4)),
                      prefixIcon: Icon(Icons.search, color: fg.withOpacity(0.5), size: 20),
                      filled: true,
                      fillColor: isDark ? ColorTokens.darkSurfaceVariant : ColorTokens.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) {
                      (ctx as Element).markNeedsBuild();
                      if (isFrom) {
                        _searchFrom = v;
                      } else {
                        _searchTo = v;
                      }
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollCtrl,
                    itemCount: _filterCodes(query).length,
                    itemBuilder: (_, i) {
                      final code = _filterCodes(query)[i];
                      final name = _allCurrencies[code] ?? code;
                      final selected = isFrom ? code == _from : code == _to;
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        leading: Container(
                          width: 40,
                          alignment: Alignment.center,
                          child: Text(
                            code,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: selected ? ColorTokens.electricCyan : fg,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(fontSize: 14, color: fg),
                        ),
                        trailing: selected
                            ? const Icon(Icons.check_circle, color: ColorTokens.electricCyan, size: 20)
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          setState(() {
                            if (isFrom) {
                              _from = code;
                            } else {
                              _to = code;
                            }
                          });
                          _convert();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
        title: Text('Currency Converter',
            style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 17)),
        iconTheme: IconThemeData(color: fg),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loading ? null : _fetchRates,
            icon: _loading
                ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
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
                  'Live rates · Updated ${_lastUpdated!.hour.toString().padLeft(2, '0')}:${_lastUpdated!.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 11, color: subFg.withOpacity(0.5)),
                ),
              ),

            // From card
            _CurrencyCard(
              label: 'From',
              amount: _amount,
              code: _from,
              name: _allCurrencies[_from] ?? _from,
              isDark: isDark,
              fg: fg,
              subFg: subFg,
              surface: surface,
              onAmountChanged: (v) {
                _amount = v;
                _convert();
              },
              onTapCurrency: () => _showCurrencyPicker(isFrom: true),
            ),

            // Swap
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
                  child: const Icon(Icons.swap_vert_rounded,
                      color: ColorTokens.electricCyan, size: 24),
                ),
              ),
            ),

            // To card
            _CurrencyCard(
              label: 'To',
              amount: _result,
              code: _to,
              name: _allCurrencies[_to] ?? _to,
              isDark: isDark,
              fg: fg,
              subFg: subFg,
              surface: surface,
              readOnlyAmount: true,
              onAmountChanged: (_) {},
              onTapCurrency: () => _showCurrencyPicker(isFrom: false),
            ),

            const Spacer(),
            Text(
              '${_allCurrencies.length} currencies · live via open.er-api.com',
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
  final String code;
  final String name;
  final bool isDark;
  final Color fg;
  final Color subFg;
  final Color surface;
  final bool readOnlyAmount;
  final ValueChanged<double> onAmountChanged;
  final VoidCallback onTapCurrency;

  const _CurrencyCard({
    required this.label,
    required this.amount,
    required this.code,
    required this.name,
    required this.isDark,
    required this.fg,
    required this.subFg,
    required this.surface,
    required this.onAmountChanged,
    required this.onTapCurrency,
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
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: subFg.withOpacity(0.6), fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: readOnlyAmount
                    ? Text(
                        amount.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: fg,
                          fontFamily: 'Roboto Mono',
                        ),
                      )
                    : TextFormField(
                        initialValue:
                            amount == amount.roundToDouble() ? amount.toStringAsFixed(0) : amount.toString(),
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 30,
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
              InkWell(
                onTap: onTapCurrency,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark ? ColorTokens.darkSurfaceVariant : ColorTokens.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorTokens.electricCyan,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, color: fg.withOpacity(0.5), size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: TextStyle(fontSize: 12, color: subFg.withOpacity(0.6)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
