///
/// time_provider.dart
/// window
/// Created by cqx on 2025/12/22.
/// Copyright ©2025 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';


class TimeProvider{
  int _lastTs = 0;

  int now() {
    final ts = DateTime.now().toUtc().millisecondsSinceEpoch;
    _lastTs = ts > _lastTs ? ts : _lastTs + 1;
    return _lastTs;
  }
}