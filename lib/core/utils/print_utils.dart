
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'fileutils.dart';

void cjPrint(String msg) {
  if (kDebugMode) {
    print(msg);
  }
}

void recordLogs(String msg) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String date = dateFormat.format(DateTime.now());
  writeToFile("error_log.txt", "$date\n$msg\n");
}




