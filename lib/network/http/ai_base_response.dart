

import '../../core/network/base_response.dart';

class AIBaseResponse extends BaseResponse{
  int code = 0;
  String? message;
  dynamic data;

  AIBaseResponse(this.code, this.message, this.data);

  AIBaseResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    message = json['msg'];
    data = json['data'];
  }

  @override
  int getResponseCode() {
    return code;
  }

  @override
  dynamic getResponseData() {
    return data;
  }

  @override
  String? getResponseMsg() {
    return message;
  }

}