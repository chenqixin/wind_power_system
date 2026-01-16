import 'package:intl/intl.dart';

extension CJDouble on double {
  /// 不超过两位小数
  String get formatToTwoDecimalPlaces {
    return NumberFormat("#0.##").format(this);
  }

  String get currency {
    final formatter = NumberFormat("#,##0.##"); // 设置千位分隔符
    return formatter.format(this);
  }
}
