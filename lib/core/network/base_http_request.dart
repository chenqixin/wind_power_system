import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../utils/fileutils.dart';
import '../utils/print_utils.dart';
import 'base_response.dart';

abstract class BaseHttpRequest {
  Dio? dio;
  static int error404 = 404;
  static int errorUnknow = 601;
  static int noNetwork = 602;

  Dio getDio() {
    if (dio == null) {
      final options = BaseOptions(
          baseUrl: getBaseUrl(),
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60));
      dio = Dio(options);
      // if (APPConfig.serverEnvironment == ServerEnvironment.test) {
      //   // 抓包调试，使用代理，并禁用HTTPS证书校验
      //   (dio?.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
      //     client.findProxy = (url) {
      //       return 'PROXY 192.168.12.178:8888'; //这里将localhost设置为自己电脑的IP，其他不变，注意上线的时候一定记得把代理去掉
      //     };
      //     //禁用证书校验
      //     client.badCertificateCallback =
      //         (X509Certificate cert, String host, int port) => true;
      //     return client;
      //   };
      // }
    }
    return dio!;
  }

  Future request(
    String path,
    String m, {
    Map<String, dynamic>? params,
    Object? data,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
    bool toastErrorMsg = true,
  }) async {
    try {
      final response = m == "POST"
          ? await getDio().request(path,
              data: data ?? jsonEncode(params ?? <String, dynamic>{}),
              options: Options(method: m, headers: await configHeaders(params)))
          : await getDio().request(path,
              queryParameters: params ?? <String, dynamic>{},
              options: Options(method: m, headers: await configHeaders(params)));
      cjPrint("$m ${getBaseUrl()}$path params: $params");
      cjPrint("状态数据:statusCode=${response.statusCode},statusMessage=${response.statusMessage}");
      if (response.statusCode == 200) {
        cjPrint("data:${response.data}");
        if (response.data is Map<String, dynamic>) {
          BaseResponse baseResponse = getBaseResponse(response.data);
          cjPrint(
              "请求结果:code=${baseResponse.getResponseCode()},msg=${baseResponse.getResponseMsg()},data=${baseResponse.getResponseData()}");
          if (baseResponse.getResponseCode() == getSuccessCode()) {
            successCallback.call(baseResponse.getResponseData());
          } else {
            failCallback?.call(baseResponse.getResponseCode(), baseResponse.getResponseMsg());
            failWithResponseCode(
                baseResponse.getResponseCode(), baseResponse.getResponseMsg(), toastErrorMsg);
          }
        } else {
          successCallback.call(response.data);
        }
      } else {
        // HTTP status code
        var httpStatusCode = response.statusCode ?? error404;
        // var msg = "${S.of(AppRoute.currentContext!).ServerRequestFailed}($httpStatusCode)";
        failCallback?.call(httpStatusCode, "");
        failWithResponseCode(httpStatusCode, "", toastErrorMsg);
      }
      return response;
    } catch (error, s) {
      // DioException
      cjPrint("异常请求：$m ${getBaseUrl()}$path params: $params");
      cjPrint("捕获到异常：${error.toString()},报错堆栈：$s");
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      String date = dateFormat.format(DateTime.now());
      writeToFile("error_log.txt", "$date\n捕获到异常：${error.toString()}\n,报错堆栈：$s \n\n\n");
      var msg = error.toString();
      // if (error is DioException) {
      //   msg = S.of(AppRoute.currentContext!).NetworkAnomaly;
      // } else if (kDebugMode) {
      //   msg = S.of(AppRoute.currentContext!).TheProgramEncounteredAnException;
      // } else {
      //   msg = S.of(AppRoute.currentContext!).ServiceException;
      // }
      int errorCode = errorUnknow;
      if (error is DioException &&
          (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.connectionTimeout)) {
        errorCode = noNetwork;
      }
      failCallback?.call(errorCode, msg);
      if (failCallback == null) {
        failWithResponseCode(errorCode, msg, toastErrorMsg);
      }
    }
  }

  Future post(
    String path, {
    Map<String, dynamic>? params,
    Object? data,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
    bool toastErrorMsg = true,
  }) async {
    return request(
      path,
      "POST",
      data: data,
      params: params,
      successCallback: successCallback,
      failCallback: failCallback,
      toastErrorMsg: toastErrorMsg,
    );
  }

  Future get(
    String path, {
    Map<String, dynamic>? params,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
    bool toastErrorMsg = true,
  }) async {
    return request(
      path,
      "GET",
      params: params,
      successCallback: successCallback,
      failCallback: failCallback,
      toastErrorMsg: toastErrorMsg,
    );
  }

  String getBaseUrl();

  Future<Map<String, dynamic>> configHeaders(Map<String, dynamic>? data);

  int getSuccessCode();

  BaseResponse getBaseResponse(Map<String, dynamic>? json);

  void failWithResponseCode(int code, String? msg, bool toastErrorMsg);
}
