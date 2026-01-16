import 'ai_http_request.dart';

class Api {
  static AIHttpRequest httpRequest = AIHttpRequest();

  static Future get(
    String path, {
    Map<String, dynamic>? params,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
    bool toastErrorMsg = true,
  }) async {
    return httpRequest.get(
      path,
      params: params,
      successCallback: successCallback,
      failCallback: failCallback,
      toastErrorMsg: toastErrorMsg,
    );
  }

  static Future post(
    String path, {
    Map<String, dynamic>? params,
        Object? data,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
    bool toastErrorMsg = true,
  }) async {
    return httpRequest.post(
      path,
      params: params,
      data: data,
      successCallback: successCallback,
      failCallback: failCallback,
      toastErrorMsg: toastErrorMsg,
    );
  }
}
