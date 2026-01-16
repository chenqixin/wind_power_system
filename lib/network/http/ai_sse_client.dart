// ignore_for_file: avoid_single_cascade_in_expression_statements, unnecessary_null_comparison, avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/utils/custom_toast.dart';
import '../../core/utils/print_utils.dart';
import 'package:http/http.dart' as http;

enum SSERequestType { GET, POST }

class SSEModel {
  //Id of the event
  String? id = '';
  //Event name
  String? event = '';
  //Event data
  String? data = '';
  SSEModel({required this.data, required this.id, required this.event});
  SSEModel.fromData(String data) {
    id = data.split("\n")[0].split('id:')[1];
    event = data.split("\n")[1].split('event:')[1];
    this.data = data.split("\n")[2].split('data:')[1];
  }
}

class AISSEClient {
  static http.Client _client = http.Client();

  ///def: Subscribes to SSE
  ///param:
  ///[method]->Request method ie: GET/POST
  ///[url]->URl of the SSE api
  ///[header]->Map<String,String>, key value pair of the request header
  static Stream<SSEModel> subscribeToSSE(BuildContext context,
      {required SSERequestType method,
      required String url,
      required Map<String, String> header,
      Map<String, dynamic>? body,
      required Function() errorComoletion}) {
    var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    // ignore: close_sinks
    StreamController<SSEModel> streamController = StreamController();
    cjPrint("--SUBSCRIBING TO SSE---");
    while (true) {
      try {
        _client = http.Client();
        var request = http.Request(
          method == SSERequestType.GET ? "GET" : "POST",
          Uri.parse(url),
        );

        ///Adding headers to the request
        header.forEach((key, value) {
          request.headers[key] = value;
        });

        ///Adding body to the request if exists
        if (body != null) {
          request.body = jsonEncode(body);
        }

        Future<http.StreamedResponse> response = _client.send(request);

        String otherInfo = "";

        ///Listening to the response as a stream
        response.asStream().listen((data) {
          ///Applying transforms and listening to it
          data.stream
            ..transform(const Utf8Decoder())
                .transform(const LineSplitter())
                .listen(
              (dataLine) {
                if (dataLine.isEmpty) {
                  ///This means that the complete event set has been read.
                  ///We then add the event to the stream
                  streamController.add(currentSSEModel);
                  currentSSEModel = SSEModel(data: '', id: '', event: '');
                  return;
                }

                ///Get the match of each line through the regex
                Match match = lineRegex.firstMatch(dataLine)!;
                var field = match.group(1);
                if (field!.isEmpty) {
                  return;
                }
                var value = '';
                if (field == 'data') {
                  //If the field is data, we get the data through the substring
                  value = dataLine.substring(
                    5,
                  );
                } else {
                  value = match.group(2) ?? '';
                }
                switch (field) {
                  case 'event':
                    currentSSEModel.event = value;
                    cjPrint('事件：event');
                    break;
                  case 'data':
                    if (value.isEmpty) {
                      currentSSEModel.data =
                        '${currentSSEModel.data ?? ''}[DONE]\n';
                    } else {
                      currentSSEModel.data =
                        '${currentSSEModel.data ?? ''}$value\n';
                    }
                    break;
                  case 'id':
                    currentSSEModel.id = value;
                    cjPrint('事件：id');
                    break;
                  case 'retry':
                    cjPrint('事件：retry');
                    break;
                  default:
                    cjPrint('dataLine: = $dataLine');
                    Map<String, dynamic>? jsonData = json.decode(dataLine);
                    cjPrint("$jsonData");
                    bool ret = true;
                    // 40101 重新登录
                    if (jsonData != null) {
                      int code = jsonData['code'];
                      if (code == 24702) {
                        /// 敏感数据
                        // AIToast.error(jsonData['msg']);
                        streamController.addError(jsonData, null);
                        ret = false;
                      } else if (code == 24701) {
                        /// token不足
                        // RechargeDialog.show(context);
                      } else if (code == 40101) {
                        /// 登录失效
                      } else {
                        AIToast.error(jsonData['msg'] ?? "未知错误");
                        currentSSEModel.data = null;
                      }
                      return;
                    }

                    if (ret) {
                      errorComoletion();
                    }
                }

                if (otherInfo.isNotEmpty) {
                  cjPrint(otherInfo);
                }
              },
              onError: (e, s) {
                cjPrint('---ERROR---');
                cjPrint(e);
                streamController.addError(e, s);
              },
            );
        }, onError: (e, s) {
          cjPrint('---ERROR---');
          cjPrint(e);
          streamController.addError(e, s);
        });
      } catch (e, s) {
        cjPrint('---ERROR---');
        cjPrint(e.toString());
        streamController.addError(e, s);
      }

      Future.delayed(const Duration(seconds: 1), () {});
      return streamController.stream;
    }
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }
}
