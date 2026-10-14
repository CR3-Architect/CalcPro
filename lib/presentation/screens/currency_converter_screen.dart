import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

import '../../core/theme/color_tokens.dart';

/// Currency data: code → (currency name, country)
class _CurrencyData {
  final String code;
  final String name;
  final String country;
  const _CurrencyData(this.code, this.name, this.country);
}

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

  /// All ISO 4217 currencies: code, official name, country — sorted A-Z
  static const List<_CurrencyData> _all = [
    _CurrencyData('AED', 'UAE Dirham', 'United Arab Emirates'),
    _CurrencyData('AFN', 'Afghan Afghani', 'Afghanistan'),
    _CurrencyData('ALL', 'Albanian Lek', 'Albania'),
    _CurrencyData('AMD', 'Armenian Dram', 'Armenia'),
    _CurrencyData('ANG', 'Netherlands Antillean Guilder', 'Curaçao'),
    _CurrencyData('AOA', 'Angolan Kwanza', 'Angola'),
    _CurrencyData('ARS', 'Argentine Peso', 'Argentina'),
    _CurrencyData('AUD', 'Australian Dollar', 'Australia'),
    _CurrencyData('AWG', 'Aruban Florin', 'Aruba'),
    _CurrencyData('AZN', 'Azerbaijani Manat', 'Azerbaijan'),
    _CurrencyData('BAM', 'Bosnian Convertible Mark', 'Bosnia & Herzegovina'),
    _CurrencyData('BBD', 'Barbadian Dollar', 'Barbados'),
    _CurrencyData('BDT', 'Bangladeshi Taka', 'Bangladesh'),
    _CurrencyData('BGN', 'Bulgarian Lev', 'Bulgaria'),
    _CurrencyData('BHD', 'Bahraini Dinar', 'Bahrain'),
    _CurrencyData('BIF', 'Burundian Franc', 'Burundi'),
    _CurrencyData('BMD', 'Bermudian Dollar', 'Bermuda'),
    _CurrencyData('BND', 'Brunei Dollar', 'Brunei'),
    _CurrencyData('BOB', 'Bolivian Boliviano', 'Bolivia'),
    _CurrencyData('BRL', 'Brazilian Real', 'Brazil'),
    _CurrencyData('BSD', 'Bahamian Dollar', 'Bahamas'),
    _CurrencyData('BTN', 'Bhutanese Ngultrum', 'Bhutan'),
    _CurrencyData('BWP', 'Botswana Pula', 'Botswana'),
    _CurrencyData('BYN', 'Belarusian Ruble', 'Belarus'),
    _CurrencyData('BZD', 'Belize Dollar', 'Belize'),
    _CurrencyData('CAD', 'Canadian Dollar', 'Canada'),
    _CurrencyData('CDF', 'Congolese Franc', 'DR Congo'),
    _CurrencyData('CHF', 'Swiss Franc', 'Switzerland'),
    _CurrencyData('CLP', 'Chilean Peso', 'Chile'),
    _CurrencyData('CNY', 'Chinese Yuan', 'China'),
    _CurrencyData('COP', 'Colombian Peso', 'Colombia'),
    _CurrencyData('CRC', 'Costa Rican Colón', 'Costa Rica'),
    _CurrencyData('CUP', 'Cuban Peso', 'Cuba'),
    _CurrencyData('CVE', 'Cape Verdean Escudo', 'Cape Verde'),
    _CurrencyData('CZK', 'Czech Koruna', 'Czech Republic'),
    _CurrencyData('DJF', 'Djiboutian Franc', 'Djibouti'),
    _CurrencyData('DKK', 'Danish Krone', 'Denmark'),
    _CurrencyData('DOP', 'Dominican Peso', 'Dominican Republic'),
    _CurrencyData('DZD', 'Algerian Dinar', 'Algeria'),
    _CurrencyData('EGP', 'Egyptian Pound', 'Egypt'),
    _CurrencyData('ERN', 'Eritrean Nakfa', 'Eritrea'),
    _CurrencyData('ETB', 'Ethiopian Birr', 'Ethiopia'),
    _CurrencyData('EUR', 'Euro', 'Eurozone'),
    _CurrencyData('FJD', 'Fijian Dollar', 'Fiji'),
    _CurrencyData('FKP', 'Falkland Islands Pound', 'Falkland Islands'),
    _CurrencyData('GBP', 'British Pound Sterling', 'United Kingdom'),
    _CurrencyData('GEL', 'Georgian Lari', 'Georgia'),
    _CurrencyData('GHS', 'Ghanaian Cedi', 'Ghana'),
    _CurrencyData('GIP', 'Gibraltar Pound', 'Gibraltar'),
    _CurrencyData('GMD', 'Gambian Dalasi', 'Gambia'),
    _CurrencyData('GNF', 'Guinean Franc', 'Guinea'),
    _CurrencyData('GTQ', 'Guatemalan Quetzal', 'Guatemala'),
    _CurrencyData('GYD', 'Guyanese Dollar', 'Guyana'),
    _CurrencyData('HKD', 'Hong Kong Dollar', 'Hong Kong'),
    _CurrencyData('HNL', 'Honduran Lempira', 'Honduras'),
    _CurrencyData('HRK', 'Croatian Kuna', 'Croatia'),
    _CurrencyData('HTG', 'Haitian Gourde', 'Haiti'),
    _CurrencyData('HUF', 'Hungarian Forint', 'Hungary'),
    _CurrencyData('IDR', 'Indonesian Rupiah', 'Indonesia'),
    _CurrencyData('ILS', 'Israeli New Shekel', 'Israel'),
    _CurrencyData('INR', 'Indian Rupee', 'India'),
    _CurrencyData('IQD', 'Iraqi Dinar', 'Iraq'),
    _CurrencyData('IRR', 'Iranian Rial', 'Iran'),
    _CurrencyData('ISK', 'Icelandic Króna', 'Iceland'),
    _CurrencyData('JMD', 'Jamaican Dollar', 'Jamaica'),
    _CurrencyData('JOD', 'Jordanian Dinar', 'Jordan'),
    _CurrencyData('JPY', 'Japanese Yen', 'Japan'),
    _CurrencyData('KES', 'Kenyan Shilling', 'Kenya'),
    _CurrencyData('KGS', 'Kyrgyzstani Som', 'Kyrgyzstan'),
    _CurrencyData('KHR', 'Cambodian Riel', 'Cambodia'),
    _CurrencyData('KMF', 'Comorian Franc', 'Comoros'),
    _CurrencyData('KRW', 'South Korean Won', 'South Korea'),
    _CurrencyData('KWD', 'Kuwaiti Dinar', 'Kuwait'),
    _CurrencyData('KYD', 'Cayman Islands Dollar', 'Cayman Islands'),
    _CurrencyData('KZT', 'Kazakhstani Tenge', 'Kazakhstan'),
    _CurrencyData('LAK', 'Lao Kip', 'Laos'),
    _CurrencyData('LBP', 'Lebanese Pound', 'Lebanon'),
    _CurrencyData('LKR', 'Sri Lankan Rupee', 'Sri Lanka'),
    _CurrencyData('LRD', 'Liberian Dollar', 'Liberia'),
    _CurrencyData('LSL', 'Lesotho Loti', 'Lesotho'),
    _CurrencyData('LYD', 'Libyan Dinar', 'Libya'),
    _CurrencyData('MAD', 'Moroccan Dirham', 'Morocco'),
    _CurrencyData('MDL', 'Moldovan Leu', 'Moldova'),
    _CurrencyData('MGA', 'Malagasy Ariary', 'Madagascar'),
    _CurrencyData('MKD', 'Macedonian Denar', 'North Macedonia'),
    _CurrencyData('MMK', 'Myanmar Kyat', 'Myanmar'),
    _CurrencyData('MNT', 'Mongolian Tögrög', 'Mongolia'),
    _CurrencyData('MOP', 'Macanese Pataca', 'Macau'),
    _CurrencyData('MRU', 'Mauritanian Ouguiya', 'Mauritania'),
    _CurrencyData('MUR', 'Mauritian Rupee', 'Mauritius'),
    _CurrencyData('MVR', 'Maldivian Rufiyaa', 'Maldives'),
    _CurrencyData('MWK', 'Malawian Kwacha', 'Malawi'),
    _CurrencyData('MXN', 'Mexican Peso', 'Mexico'),
    _CurrencyData('MYR', 'Malaysian Ringgit', 'Malaysia'),
    _CurrencyData('MZN', 'Mozambican Metical', 'Mozambique'),
    _CurrencyData('NAD', 'Namibian Dollar', 'Namibia'),
    _CurrencyData('NGN', 'Nigerian Naira', 'Nigeria'),
    _CurrencyData('NIO', 'Nicaraguan Córdoba', 'Nicaragua'),
    _CurrencyData('NOK', 'Norwegian Krone', 'Norway'),
    _CurrencyData('NPR', 'Nepalese Rupee', 'Nepal'),
    _CurrencyData('NZD', 'New Zealand Dollar', 'New Zealand'),
    _CurrencyData('OMR', 'Omani Rial', 'Oman'),
    _CurrencyData('PAB', 'Panamanian Balboa', 'Panama'),
    _CurrencyData('PEN', 'Peruvian Sol', 'Peru'),
    _CurrencyData('PGK', 'Papua New Guinean Kina', 'Papua New Guinea'),
    _CurrencyData('PHP', 'Philippine Peso', 'Philippines'),
    _CurrencyData('PKR', 'Pakistani Rupee', 'Pakistan'),
    _CurrencyData('PLN', 'Polish Złoty', 'Poland'),
    _CurrencyData('PYG', 'Paraguayan Guarani', 'Paraguay'),
    _CurrencyData('QAR', 'Qatari Riyal', 'Qatar'),
    _CurrencyData('RON', 'Romanian Leu', 'Romania'),
    _CurrencyData('RSD', 'Serbian Dinar', 'Serbia'),
    _CurrencyData('RUB', 'Russian Ruble', 'Russia'),
    _CurrencyData('RWF', 'Rwandan Franc', 'Rwanda'),
    _CurrencyData('SAR', 'Saudi Riyal', 'Saudi Arabia'),
    _CurrencyData('SBD', 'Solomon Islands Dollar', 'Solomon Islands'),
    _CurrencyData('SCR', 'Seychellois Rupee', 'Seychelles'),
    _CurrencyData('SDG', 'Sudanese Pound', 'Sudan'),
    _CurrencyData('SEK', 'Swedish Krona', 'Sweden'),
    _CurrencyData('SGD', 'Singapore Dollar', 'Singapore'),
    _CurrencyData('SHP', 'Saint Helena Pound', 'Saint Helena'),
    _CurrencyData('SLE', 'Sierra Leonean Leone', 'Sierra Leone'),
    _CurrencyData('SOS', 'Somali Shilling', 'Somalia'),
    _CurrencyData('SRD', 'Surinamese Dollar', 'Suriname'),
    _CurrencyData('SSP', 'South Sudanese Pound', 'South Sudan'),
    _CurrencyData('STN', 'São Tomé and Príncipe Dobra', 'São Tomé & Príncipe'),
    _CurrencyData('SYP', 'Syrian Pound', 'Syria'),
    _CurrencyData('SZL', 'Swazi Lilangeni', 'Eswatini'),
    _CurrencyData('THB', 'Thai Baht', 'Thailand'),
    _CurrencyData('TJS', 'Tajikistani Somoni', 'Tajikistan'),
    _CurrencyData('TMT', 'Turkmenistani Manat', 'Turkmenistan'),
    _CurrencyData('TND', 'Tunisian Dinar', 'Tunisia'),
    _CurrencyData('TOP', 'Tongan Paʻanga', 'Tonga'),
    _CurrencyData('TRY', 'Turkish Lira', 'Turkey'),
    _CurrencyData('TTD', 'Trinidad and Tobago Dollar', 'Trinidad & Tobago'),
    _CurrencyData('TWD', 'New Taiwan Dollar', 'Taiwan'),
    _CurrencyData('TZS', 'Tanzanian Shilling', 'Tanzania'),
    _CurrencyData('UAH', 'Ukrainian Hryvnia', 'Ukraine'),
    _CurrencyData('UGX', 'Ugandan Shilling', 'Uganda'),
    _CurrencyData('USD', 'US Dollar', 'United States'),
    _CurrencyData('UYU', 'Uruguayan Peso', 'Uruguay'),
    _CurrencyData('UZS', 'Uzbekistani Som', 'Uzbekistan'),
    _CurrencyData('VED', 'Venezuelan Bolívar', 'Venezuela'),
    _CurrencyData('VND', 'Vietnamese Đồng', 'Vietnam'),
    _CurrencyData('VUV', 'Vanuatu Vatu', 'Vanuatu'),
    _CurrencyData('WST', 'Samoan Tala', 'Samoa'),
    _CurrencyData('XAF', 'Central African CFA Franc', 'Central Africa'),
    _CurrencyData('XCD', 'East Caribbean Dollar', 'Eastern Caribbean'),
    _CurrencyData('XOF', 'West African CFA Franc', 'West Africa'),
    _CurrencyData('XPF', 'CFP Franc', 'French Polynesia'),
    _CurrencyData('YER', 'Yemeni Rial', 'Yemen'),
    _CurrencyData('ZAR', 'South African Rand', 'South Africa'),
    _CurrencyData('ZMW', 'Zambian Kwacha', 'Zambia'),
    _CurrencyData('ZWG', 'Zimbabwean Gold', 'Zimbabwe'),
  ];

  late final List<_CurrencyData> _sorted = List.unmodifiable(_all);

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

  List<_CurrencyData> _filter(String query) {
    if (query.isEmpty) return _sorted;
    final q = query.toLowerCase();
    return _sorted.where((c) {
      return c.code.toLowerCase().contains(q) ||
          c.name.toLowerCase().contains(q) ||
          c.country.toLowerCase().contains(q);
    }).toList();
  }

  void _showCurrencyPicker({required bool isFrom}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final surface = isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final query = isFrom ? _searchFrom : _searchTo;
            final results = _filter(query);
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.4,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, scrollCtrl) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: TextField(
                        autofocus: false,
                        style: TextStyle(color: fg, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search code, currency, or country...',
                          hintStyle: TextStyle(color: fg.withOpacity(0.4)),
                          prefixIcon: Icon(Icons.search, color: fg.withOpacity(0.5), size: 20),
                          suffixIcon: query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear, color: fg.withOpacity(0.5), size: 18),
                                  onPressed: () {
                                    setSheetState(() {
                                      if (isFrom) {
                                        _searchFrom = '';
                                      } else {
                                        _searchTo = '';
                                      }
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: isDark ? ColorTokens.darkSurfaceVariant : ColorTokens.lightSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (v) {
                          setSheetState(() {
                            if (isFrom) {
                              _searchFrom = v;
                            } else {
                              _searchTo = v;
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '${results.length} currencies',
                        style: TextStyle(fontSize: 11, color: fg.withOpacity(0.4)),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: results.isEmpty
                          ? Center(
                              child: Text(
                                'No matches for "$query"',
                                style: TextStyle(color: fg.withOpacity(0.5), fontSize: 14),
                              ),
                            )
                          : ListView.builder(
                              controller: scrollCtrl,
                              itemCount: results.length,
                              itemBuilder: (_, i) {
                                final c = results[i];
                                final selected = isFrom ? c.code == _from : c.code == _to;
                                return ListTile(
                                  dense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                  leading: Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      c.code,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: selected ? ColorTokens.electricCyan : fg,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    c.name,
                                    style: TextStyle(fontSize: 14, color: fg),
                                  ),
                                  subtitle: Text(
                                    c.country,
                                    style: TextStyle(fontSize: 11, color: fg.withOpacity(0.5)),
                                  ),
                                  trailing: selected
                                      ? const Icon(Icons.check_circle, color: ColorTokens.electricCyan, size: 20)
                                      : null,
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    setState(() {
                                      if (isFrom) {
                                        _from = c.code;
                                      } else {
                                        _to = c.code;
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fg = isDark ? ColorTokens.darkOnBackground : ColorTokens.lightOnBackground;
    final subFg = isDark ? ColorTokens.darkOnSurface : ColorTokens.lightOnSurface;
    final surface = isDark ? ColorTokens.darkSurface : ColorTokens.lightSurface;

    final fromData = _sorted.firstWhere((c) => c.code == _from);
    final toData = _sorted.firstWhere((c) => c.code == _to);

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

            _CurrencyCard(
              label: 'From',
              amount: _amount,
              code: _from,
              name: fromData.name,
              country: fromData.country,
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

            _CurrencyCard(
              label: 'To',
              amount: _result,
              code: _to,
              name: toData.name,
              country: toData.country,
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
              '${_all.length} currencies · live via open.er-api.com',
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
  final String country;
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
    required this.country,
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
            '$name · $country',
            style: TextStyle(fontSize: 12, color: subFg.withOpacity(0.6)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
