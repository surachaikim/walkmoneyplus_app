import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class LocaleUtils {
  static bool _isInitialized = false;

  /// Initialize Thai locale data for the entire app
  static Future<void> initializeLocale() async {
    if (!_isInitialized) {
      try {
        await initializeDateFormatting('th', null);
        _isInitialized = true;
        print('Thai locale initialized successfully');
      } catch (e) {
        print('Failed to initialize Thai locale: $e');
        // Fallback - don't throw error, just log it
      }
    }
  }

  /// Get a safe date formatter that falls back to default locale if Thai fails
  static DateFormat getDateFormatter({String pattern = 'yMd'}) {
    try {
      return DateFormat(pattern, 'th');
    } catch (e) {
      print('Failed to create Thai date formatter, using default: $e');
      return DateFormat(pattern);
    }
  }

  /// Get a safe number formatter that falls back to default locale if Thai fails
  static NumberFormat getNumberFormatter({String pattern = '#,###'}) {
    try {
      return NumberFormat(pattern, 'th_TH');
    } catch (e) {
      print('Failed to create Thai number formatter, using default: $e');
      return NumberFormat(pattern);
    }
  }

  /// Get a safe currency formatter
  static NumberFormat getCurrencyFormatter() {
    return getNumberFormatter(pattern: '#,###.00');
  }
}
