import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sprintf/sprintf.dart';
import '../../core/utils/print_utils.dart';
import '/main.dart';
import 'ai_http_request.dart';

Map<String, dynamic> sortMapByKey(Map<String, dynamic> unsortedMap) {
  List<String> sortedKeys = unsortedMap.keys.toList()..sort(); // 获取键的列表并进行排序
  Map<String, dynamic> sortedMap = {};
  for (var key in sortedKeys) {
    sortedMap[key] = unsortedMap[key];
  }
  return sortedMap;
}

String signKey() {
  return '9H67G￥8Ut';
}

String getDeviceType() {
  if (kIsWeb == true) {
    return 'web';
  }
  if (Platform.isAndroid) {
    return 'ANDROID';
  } else if (Platform.isIOS) {
    return 'iOS';
  } else if (Platform.isMacOS) {
    return 'MacOS';
  } else if (Platform.isWindows) {
    return 'Windows';
  } else if (Platform.isLinux) {
    return 'Linux';
  } else if (Platform.isFuchsia) {
    return 'Fuchsia';
  } else {
    return 'Unknown';
  }
}

String appVersionCode = () {
  String version =  "1.0.0";
  List<String> subs = version.split(".");
  String code = "";
  for (int i = 0; i < 3; i++) {
    code += sprintf("%02d", [int.parse(subs[i])]);
  }
  cjPrint(code);
  return code;
}();

String getBaseUrl() {
  return AIHttpRequest().getBaseUrl();
}

String env() {
  // switch (APPConfig.serverEnvironment) {
  //   case ServerEnvironment.test:
  //     return 'https://xgj.chanka666.com:';
  //   case ServerEnvironment.release:
  //     return "https://xgj.chanka666.com:";
  // }

  return "http://127.0.0.1";
}
