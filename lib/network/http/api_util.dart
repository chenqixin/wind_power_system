import 'ai_http_request.dart';
import 'dart:async';
import 'dart:convert';
import 'package:wind_power_system/network/socket/web_socket_manager.dart';
import 'package:wind_power_system/core/config/tcp_config.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/db/app_database.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';

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
    recordRequestLog(type: 'Polling', sn: sn, ip: ip, port: port);
    await WebSocketManager()
        .connectTcp(ip, port, timeout: const Duration(seconds: 5));
  }

  static Future<void> requestDeviceDetail({
    required String sn,
    required String ip,
    required int port,
  }) async {
    recordRequestLog(type: 'Detail Request', sn: sn, ip: ip, port: port);
    await WebSocketManager()
        .connectTcp(ip, port, timeout: const Duration(seconds: 5));
    WebSocketManager().sendLine("detail sn=$sn");
  }

  static Future<void> getDeviceDetailTcp({
    required String sn,
    required String ip,
    required int port,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
  }) async {
    recordRequestLog(type: 'Get Detail', sn: sn, ip: ip, port: port);
    final mgr = WebSocketManager();
    await mgr.connectTcp(ip, port, timeout: const Duration(seconds: 5));
    final completer = Completer<void>();
    late StreamSubscription<String> sub;
    sub = mgr.stream.listen((event) {
      try {
        final obj = json.decode(event);
        if (obj is Map<String, dynamic>) {
          final cmd = obj['cmd'];
          final resSn = obj['sn']?.toString();
          if (cmd == 'sn_detail' && (resSn == null || resSn == sn)) {
            final rawCode = obj['code'];
            final code =
                rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
            final msg = obj['message'] ?? obj['messge'];
            recordRequestLog(
                type: 'Detail Response',
                sn: sn,
                ip: ip,
                port: port,
                extra: 'Code: $code, Msg: $msg');
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
    required String ip,
    required int port,
  }) async {
    recordRequestLog(type: 'Emergency Stop', sn: sn, ip: ip, port: port);
    final mgr = WebSocketManager();
    await mgr.connectTcp(ip, port, timeout: const Duration(seconds: 5));
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
            recordRequestLog(
                type: 'Stop Response',
                sn: sn,
                ip: ip,
                port: port,
                extra: 'Code: $code, Msg: $msg');
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
    required String ip,
    required int port,
  }) async {
    recordRequestLog(type: 'Reset', sn: sn, ip: ip, port: port);
    final mgr = WebSocketManager();
    await mgr.connectTcp(ip, port, timeout: const Duration(seconds: 5));
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
            recordRequestLog(
                type: 'Reset Response',
                sn: sn,
                ip: ip,
                port: port,
                extra: 'Code: $code, Msg: $msg');
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
    required String ip,
    required int port,
    required bool heatingOn,
    int? hotTime,
    num? iSet,
  }) async {
    final op = heatingOn ? '1' : '0';
    final ht = hotTime ?? 0;
    final iset = iSet ?? 0;
    recordRequestLog(
        type: 'Manual Heating',
        sn: sn,
        ip: ip,
        port: port,
        extra: 'heatingOn=$op, hotTime=$ht, iSet=$iset');
    final mgr = WebSocketManager();
    await mgr.connectTcp(ip, port, timeout: const Duration(seconds: 5));
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
            recordRequestLog(
                type: 'Heating Response',
                sn: sn,
                ip: ip,
                port: port,
                extra: 'Code: $code, Msg: $msg');
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
    mgr.sendLine("hot sn=$sn heatingOn=$op hotTime=$ht iSet=$iset");
    print("请求 hot sn=$sn heatingOn=$op hotTime=$ht iSet=$iset");
    await completer.future;
  }

  static Future<void> syncClockTcp({
    DateTime? time,
  }) async {
    final devs = await AppDatabase.allDevices();
    final now = time ?? DateTime.now();
    final y = now.year;
    final m = now.month;
    final d = now.day;
    final h = now.hour;
    final min = now.minute;
    final s = now.second;
    final mgr = WebSocketManager();

    for (final dev in devs) {
      final sn = (dev['sn'] as String?) ?? '';
      final ip = (dev['ip'] as String?) ?? '';
      final port = (dev['port'] as int?) ?? 0;
      if (ip.isEmpty || port == 0) continue;

      try {
        recordRequestLog(
            type: 'Sync Clock',
            sn: sn,
            ip: ip,
            port: port,
            extra: 'Time: $y-$m-$d $h:$min:$s');
        await mgr.connectTcp(ip, port, timeout: const Duration(seconds: 3));
        mgr.sendLine(
            "clock  year=$y month=$m day=$d hour=$h minute=$min second=$s");
        print("请求设备 $sn ($ip:$port) clock");
        // 这里不等待响应，直接处理下一个设备
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print("同步设备 $sn 时间失败: $e");
        recordRequestLog(
            type: 'Sync Clock Failed',
            sn: sn,
            ip: ip,
            port: port,
            extra: 'Error: $e');
      }
    }
  }
}
