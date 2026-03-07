
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
  appendToFile("error_log.txt", "$date: $msg\n");
}

void recordRequestLog({
  required String type,
  String? sn,
  String? ip,
  int? port,
  String? extra,
}) {
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  String date = dateFormat.format(DateTime.now());
  String logMsg = "[$date] $type | SN: ${sn ?? 'N/A'} | IP: ${ip ?? 'N/A'} | Port: ${port ?? 'N/A'}";
  if (extra != null && extra.isNotEmpty) {
    logMsg += " | Info: $extra";
  }
  appendToFile("request_log.txt", "$logMsg\n");
}




