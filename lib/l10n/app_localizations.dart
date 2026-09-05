import 'package:flutter/material.dart';

/// Localization delegate for CalcPro Studio
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
    Locale('ur'),
    Locale('tr'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
  ];
  
  // English strings (fallback)
  static const Map<String, String> _en = {
    'appTitle': 'CalcPro Studio',
    'standard': 'Standard',
    'scientific': 'Scientific',
    'calculus': 'Calculus',
    'linearAlgebra': 'Linear Algebra',
    'complexNumbers': 'Complex Numbers',
    'statistics': 'Statistics',
    'programmer': 'Programmer',
    'converter': 'Converter',
    'settings': 'Settings',
    'history': 'History',
    'clearAll': 'Clear All',
    'copyResult': 'Copy Result',
    'copiedToClipboard': 'Copied to clipboard',
    'noHistory': 'No history yet',
    'noResults': 'No matching calculations',
    'search': 'Search calculations...',
    'theme': 'Theme',
    'angleMode': 'Angle Mode',
    'numberBase': 'Number Base',
    'decimalPrecision': 'Decimal Precision',
    'hapticFeedback': 'Haptic Feedback',
    'highContrast': 'High Contrast Mode',
    'about': 'About',
    'version': 'Version',
    'error': 'Error',
    'divisionByZero': 'Division by zero',
    'invalidExpression': 'Invalid expression',
    'matrixEditor': 'Matrix Editor',
    'dataEntry': 'Data Entry',
    'unitConverter': 'Unit Converter',
    'physicalConstants': 'Physical Constants',
  };
  
  static const Map<String, String> _ar = {
    'appTitle': 'كالك برو ستوديو',
    'standard': 'قياسي',
    'scientific': 'علمي',
    'settings': 'الإعدادات',
    'history': 'السجل',
  };
  
  static const Map<String, String> _tr = {
    'appTitle': 'CalcPro Stüdyo',
    'standard': 'Standart',
    'scientific': 'Bilimsel',
    'settings': 'Ayarlar',
    'history': 'Geçmiş',
  };
  
  static const Map<String, String> _es = {
    'appTitle': 'CalcPro Studio',
    'standard': 'Estándar',
    'scientific': 'Científica',
    'settings': 'Configuración',
    'history': 'Historial',
  };
  
  static const Map<String, String> _fr = {
    'appTitle': 'CalcPro Studio',
    'standard': 'Standard',
    'scientific': 'Scientifique',
    'settings': 'Paramètres',
    'history': 'Historique',
  };
  
  static const Map<String, String> _hi = {
    'appTitle': 'कैल्कप्रो स्टूडियो',
    'standard': 'मानक',
    'scientific': 'वैज्ञानिक',
    'settings': 'सेटिंग्स',
    'history': 'इतिहास',
  };
  
  static const Map<String, String> _zh = {
    'appTitle': 'CalcPro 工作室',
    'standard': '标准',
    'scientific': '科学',
    'settings': '设置',
    'history': '历史',
  };
  
  static const Map<String, String> _ja = {
    'appTitle': 'CalcPro スタジオ',
    'standard': '標準',
    'scientific': '科学',
    'settings': '設定',
    'history': '履歴',
  };
  
  static const Map<String, String> _ko = {
    'appTitle': 'CalcPro 스튜디오',
    'standard': '표준',
    'scientific': '과학',
    'settings': '설정',
    'history': '기록',
  };
  
  String translate(String key) {
    final map = _getMap();
    return map[key] ?? _en[key] ?? key;
  }
  
  Map<String, String> _getMap() {
    switch (locale.languageCode) {
      case 'ar': return _ar;
      case 'tr': return _tr;
      case 'es': return _es;
      case 'fr': return _fr;
      case 'hi': return _hi;
      case 'zh': return _zh;
      case 'ja': return _ja;
      case 'ko': return _ko;
      default: return _en;
    }
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar', 'ur', 'tr', 'es', 'fr', 'hi', 'zh', 'ja', 'ko']
        .contains(locale.languageCode);
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
