import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../core/network/base_http_request.dart';
import '../../core/network/base_response.dart';
import '../../core/utils/custom_toast.dart';
import 'ai_base_response.dart';
import 'net_methods.dart';

class AIHttpRequest extends BaseHttpRequest {
  @override
  Future<Map<String, dynamic>> configHeaders(Map<String, dynamic>? data) async {
    var headers = <String, dynamic>{};
    data ??= <String, dynamic>{};
    var timeStamp = DateTime.now().millisecondsSinceEpoch.toString();
    data["timestamp"] = timeStamp;
    Map<String, dynamic> sortedMap = sortMapByKey(data);
    StringBuffer sb = StringBuffer();
    sortedMap.forEach((key, value) {
      sb.write("$key=$value&");
    });
    sb.write(signKey());
    // cjPrint("加密前参数:${sb.toString()}");
    var bytes = utf8.encode(sb.toString());
    var digest = md5.convert(bytes);
    var sign = digest.toString();
    // cjPrint("加密后参数:$sign");
    headers["appVersionCode"] = appVersionCode;
    //headers["sign"] = sign;
    headers["timestamp"] = timeStamp;

    return headers;
  }

  @override
  void failWithResponseCode(int code, String? msg, bool toastErrorMsg) {
    switch (code) {
      // 登录过期
      case 10002:
        break;
    }
    if (toastErrorMsg && msg != null) {
      AIToast.error(msg);
    }
  }

  @override
  BaseResponse getBaseResponse(Map<String, dynamic>? json) {
    return AIBaseResponse.fromJson(json!);
  }

  @override
  String getBaseUrl() {
    return '${env()}:8000/';
  }

  @override
  int getSuccessCode() {
    return 200;
  }

}
