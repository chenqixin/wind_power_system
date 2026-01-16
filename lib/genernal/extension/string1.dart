///
/// string1.dart
/// banbei
/// Created by chenyu on 2025/3/21.
/// Copyright ©2025 Changjia. All rights reserved.
///
library;

import 'package:intl/intl.dart';

extension CJString on String {
  String get currency {
    final number = double.tryParse(this);
    if (number == null) return this;

    final formatter = NumberFormat("#,##0.##");
    return formatter.format(number);
  }
}
