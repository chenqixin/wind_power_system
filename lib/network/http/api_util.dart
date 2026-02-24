import 'ai_http_request.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wind_power_system/network/socket/web_socket_manager.dart';
import 'package:wind_power_system/core/config/tcp_config.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/db/app_database.dart';

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

  static Future<void> requestDevicePolling({
    required String sn,
    required String ip,
    required int port,
  }) async {
    await WebSocketManager()
        .connectTcp(ip, port, timeout: const Duration(seconds: 5));
  }

  static Future<void> requestDeviceDetail({
    required String sn,
    required String ip,
    required int port,
  }) async {
    await WebSocketManager()
        .connectTcp(ip, port, timeout: const Duration(seconds: 5));
    WebSocketManager().sendLine("detail sn=$sn");
  }

  static Future<void> getDeviceDetailTcp({
    required String sn,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
  }) async {
    final rows = await AppDatabase.allDevices();
    await TCPConfig.ensureLoaded();
    await WebSocketManager().connectTcp(TCPConfig.host, TCPConfig.port,
        timeout: const Duration(seconds: 5));
    final mgr = WebSocketManager();
    final completer = Completer<void>();
    late StreamSubscription<String> sub;
    sub = mgr.stream.listen((event) {
      try {
        final obj = json.decode(event);
        if (obj is Map<String, dynamic>) {
          final cmd = obj['cmd'];
          if (cmd == 'sn_detail') {
            final rawCode = obj['code'];
            final code =
                rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
            final msg = obj['message'] ?? obj['messge'];
            if (code == 200) {
              successCallback.call(obj['data']);
            } else {
              failCallback?.call(code, msg is String ? msg : null);
              if (msg is String && msg.isNotEmpty) {
                AppNotice.show(title: '提示', content: msg);
              }
            }
            sub.cancel();
            completer.complete();
          }
        }
      } catch (_) {}
    });
    mgr.sendLine("detail sn=$sn");
    print("请求 detail sn=$sn");
    await completer.future;
  }

  static Future<void> emergencyStopTcp({
    required String sn,
  }) async {
    await AppDatabase.allDevices();
    await TCPConfig.ensureLoaded();
    await WebSocketManager().connectTcp(TCPConfig.host, TCPConfig.port,
        timeout: const Duration(seconds: 5));
    final mgr = WebSocketManager();
    final completer = Completer<void>();
    late StreamSubscription<String> sub;
    sub = mgr.stream.listen((event) {
      try {
        final obj = json.decode(event);
        if (obj is Map<String, dynamic>) {
          final cmdVal = obj['cmd'];
          final cmdStr = cmdVal is String ? cmdVal : '$cmdVal';
          if (cmdStr == 'stop_detail') {
            final rawCode = obj['code'];
            final code =
                rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
            final msg = obj['message'] ?? obj['messge'];
            if (code == 200) {
              AppNotice.show(title: '提示', content: '操作成功');
            } else {
              final m = msg is String ? msg : null;
              if (m != null && m.isNotEmpty) {
                AppNotice.show(title: '提示', content: m);
              }
            }
            sub.cancel();
            completer.complete();
          }
        }
      } catch (_) {}
    });
    mgr.sendLine("stop sn=$sn");
    await completer.future;
  }

  static Future<void> resetTcp({
    required String sn,
  }) async {
    await AppDatabase.allDevices();
    await TCPConfig.ensureLoaded();
    await WebSocketManager().connectTcp(TCPConfig.host, TCPConfig.port,
        timeout: const Duration(seconds: 5));
    final mgr = WebSocketManager();
    final completer = Completer<void>();
    late StreamSubscription<String> sub;
    sub = mgr.stream.listen((event) {
      try {
        final obj = json.decode(event);
        if (obj is Map<String, dynamic>) {
          final cmdVal = obj['cmd'];
          final cmdStr = cmdVal is String ? cmdVal : '$cmdVal';
          if (cmdStr == 'reset_detail') {
            final rawCode = obj['code'];
            final code =
                rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
            final msg = obj['message'] ?? obj['messge'];
            if (code == 200) {
              AppNotice.show(title: '提示', content: '操作成功');
              try {
                // 复位成功后，断开并重建 TCP 连接
                mgr.restartTcp();
              } catch (_) {}
            } else {
              final m = msg is String ? msg : null;
              if (m != null && m.isNotEmpty) {
                AppNotice.show(title: '提示', content: m);
              }
            }
            sub.cancel();
            completer.complete();
          }
        }
      } catch (_) {}
    });
    mgr.sendLine("reset sn=$sn");
    await completer.future;
  }

  static Future<void> submitManualHeatingTcp({
    required String sn,
    required bool heatingOn,
    int? hotTime,
    num? iSet,
  }) async {
    await AppDatabase.allDevices();
    await TCPConfig.ensureLoaded();
    await WebSocketManager().connectTcp(TCPConfig.host, TCPConfig.port,
        timeout: const Duration(seconds: 5));
    final mgr = WebSocketManager();
    final completer = Completer<void>();
    late StreamSubscription<String> sub;
    sub = mgr.stream.listen((event) {
      try {
        final obj = json.decode(event);
        if (obj is Map<String, dynamic>) {
          final cmdVal = obj['cmd'];
          final cmdStr = cmdVal is String ? cmdVal : '$cmdVal';
          if (cmdStr == 'hot_detail') {
            final rawCode = obj['code'];
            final code =
                rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
            final msg = obj['message'] ?? obj['messge'];
            if (code == 200) {
              AppNotice.show(title: '提示', content: '操作成功');
            } else {
              final m = msg is String ? msg : null;
              if (m != null && m.isNotEmpty) {
                AppNotice.show(title: '提示', content: m);
              }
            }
            sub.cancel();
            completer.complete();
          }
        }
      } catch (_) {}
    });
    final op = heatingOn ? '1' : '0';
    final ht = hotTime ?? 0;
    final iset = iSet ?? 0;
    mgr.sendLine("hot sn=$sn heatingOn=$op hotTime=$ht iSet=$iset");
    print("请求 hot sn=$sn heatingOn=$op hotTime=$ht iSet=$iset");
    await completer.future;
  }

  static Future<void> syncClockTcp({
    DateTime? time,
  }) async {
    await AppDatabase.allDevices();
    await TCPConfig.ensureLoaded();
    await WebSocketManager().connectTcp(TCPConfig.host, TCPConfig.port,
        timeout: const Duration(seconds: 5));
    final now = time ?? DateTime.now();
    final y = now.year;
    final m = now.month;
    final d = now.day;
    final h = now.hour;
    final min = now.minute;
    final s = now.second;
    final mgr = WebSocketManager();
    mgr.sendLine(
        "clock  year=$y month=$m day=$d hour=$h minute=$min second=$s");
    print(
        "请求 clock  year=$y month=$m day=$d hour=$h minute=$min second=$s");
  }
}
