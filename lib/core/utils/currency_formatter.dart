import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  static final _formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Convert USD price from FakeStoreAPI to IDR and format
  static String format(double usdPrice) {
    final idr = (usdPrice * AppConstants.priceMultiplier).roundToDouble();
    return _formatter.format(idr);
  }

  /// Format raw IDR value
  static String formatIDR(double idr) => _formatter.format(idr);

  /// Raw IDR value from USD
  static double toIDR(double usdPrice) =>
      (usdPrice * AppConstants.priceMultiplier).roundToDouble();
}
