import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:wind_power_system/core/utils/print_utils.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/network/socket/web_socket_manager.dart';
import 'package:wind_power_system/db/app_database.dart';

class Api {
  static Future<void> requestDevicePolling({
    required String sn,
    required String ip,
    required int port,
  }) async {
    recordRequestLog(type: 'Polling', sn: sn, ip: ip, port: port);
    try {
      // 保持连接即可，无需立即发送命令
      await WebSocketManager().getConnection(ip, port);
    } catch (e) {
      print("Polling failed: $e");
      recordRequestLog(
          type: 'Polling Failed', sn: sn, ip: ip, port: port, extra: '$e');
    }
  }

  static Future<void> getDeviceDetailTcp({
    required String sn,
    required String ip,
    required int port,
    required Function(dynamic data) successCallback,
    Function(int code, String? msg)? failCallback,
  }) async {
    try {
      final res = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'sn_detail',
        line: 'detail sn=$sn',
      );

      final rawCode = res['code'];
      final code = rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
      final msg = res['message'] ?? res['messge'];

      if (code == 200) {
        successCallback.call(res['data']);
      } else {
        failCallback?.call(code, msg);
      }
    } catch (e) {
      failCallback?.call(-1, e.toString());
    }
  }

  static Future<void> emergencyStopTcp({
    required String sn,
    required String ip,
    required int port,
  }) async {
    recordRequestLog(type: 'Emergency Stop', sn: sn, ip: ip, port: port);
    try {
      final res = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'stop_detail',
        line: 'stop sn=$sn',
      );
      final code = res['code'] ?? 0;
      final msg = res['message'] ?? res['messge'];
      if (code == 200) {
        AppNotice.show(title: '提示', content: '操作成功');
      } else if (msg != null) {
        AppNotice.show(title: '提示', content: msg.toString());
      }
    } catch (e) {
      print("Emergency stop failed: $e");
    }
  }

  static Future<void> resetTcp({
    required String sn,
    required String ip,
    required int port,
  }) async {
    recordRequestLog(type: 'Reset', sn: sn, ip: ip, port: port);
    try {
      final res = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'reset_detail',
        line: 'reset sn=$sn',
      );
      final code = res['code'] ?? 0;
      final msg = res['message'] ?? res['messge'];
      if (code == 200) {
        AppNotice.show(title: '提示', content: '操作成功');
      } else if (msg != null) {
        AppNotice.show(title: '提示', content: msg.toString());
      }
    } catch (e) {
      print("Reset failed: $e");
    }
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
      extra: 'heatingOn=$op, hotTime=$ht, iSet=$iset',
    );

    try {
      final res = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'hot_detail',
        line: 'hot sn=$sn heatingOn=$op hotTime=$ht iSet=$iset',
      );
      final code = res['code'] ?? 0;
      final msg = res['message'] ?? res['messge'];
      if (code == 200) {
        AppNotice.show(title: '提示', content: '操作成功');
      } else if (msg != null) {
        AppNotice.show(title: '提示', content: msg.toString());
      }
    } catch (e) {
      print("Manual heating failed: $e");
    }
  }

  static Future<void> switchModeTcp({
    required String sn,
    required String ip,
    required int port,
    required int mode,
  }) async {
    recordRequestLog(
      type: 'Switch Mode',
      sn: sn,
      ip: ip,
      port: port,
      extra: 'mode=$mode',
    );

    try {
      final res = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'mode_detail',
        line: 'mode sn=$sn ctrl=$mode',
      );
      final code = res['code'] ?? 0;
      final msg = res['message'] ?? res['messge'];
      if (code == 200) {
        AppNotice.show(title: '提示', content: '操作成功');
      } else if (msg != null) {
        AppNotice.show(title: '提示', content: msg.toString());
      }
    } catch (e) {
      print("Switch mode failed: $e");
    }
  }

  /// OTA固件升级：握手 → 分包传输 → 完成确认
  static const int _otaChunkSize = 1024; // 每包1KB，base64后约1.3KB，不超2KB

  static Future<void> otaUpgrade({
    required String sn,
    required String ip,
    required int port,
    required File file,
    required String fileName,
    void Function(double progress, String status)? onProgress,
  }) async {
    final bytes = await file.readAsBytes();
    final totalSize = bytes.length;
    final totalChunks = (totalSize / _otaChunkSize).ceil();

    recordRequestLog(
      type: 'OTA Start',
      sn: sn,
      ip: ip,
      port: port,
      extra: 'file=$fileName, size=$totalSize, chunks=$totalChunks',
    );

    // 阶段1: 握手 — 通知设备准备接收
    onProgress?.call(0.0, '正在通知设备准备升级...');
    final startRes = await WebSocketManager().sendCommand(
      host: ip,
      port: port,
      cmd: 'ota_start',
      line: 'OTA sn=$sn version=$fileName size=$totalSize chunks=$totalChunks',
      timeout: const Duration(seconds: 10),
    );
    final startCode = startRes['code'];
    if ((startCode is int ? startCode : int.tryParse('$startCode') ?? 0) != 200) {
      final msg = startRes['message'] ?? startRes['messge'] ?? '设备拒绝升级';
      throw Exception('$msg');
    }

    // 阶段2: 分包传输
    for (int i = 0; i < totalChunks; i++) {
      final start = i * _otaChunkSize;
      final end = (start + _otaChunkSize > totalSize) ? totalSize : start + _otaChunkSize;
      final chunk = bytes.sublist(start, end);
      final b64 = base64Encode(chunk);

      onProgress?.call((i + 1) / totalChunks * 0.95, '正在传输 ${i + 1}/$totalChunks ...');

      final dataRes = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'ota_data',
        line: 'OTA_DATA index=$i data=$b64',
        timeout: const Duration(seconds: 10),
      );
      final dataCode = dataRes['code'];
      if ((dataCode is int ? dataCode : int.tryParse('$dataCode') ?? 0) != 200) {
        final msg = dataRes['message'] ?? dataRes['messge'] ?? '数据包 $i 传输失败';
        throw Exception('$msg');
      }
    }

    // 阶段3: 完成确认
    onProgress?.call(0.98, '正在等待设备校验...');
    final finishRes = await WebSocketManager().sendCommand(
      host: ip,
      port: port,
      cmd: 'ota_finish',
      line: 'OTA_FINISH sn=$sn',
      timeout: const Duration(seconds: 30),
    );
    final finishCode = finishRes['code'];
    if ((finishCode is int ? finishCode : int.tryParse('$finishCode') ?? 0) != 200) {
      final msg = finishRes['message'] ?? finishRes['messge'] ?? '设备校验失败';
      throw Exception('$msg');
    }

    onProgress?.call(1.0, '升级完成');
    recordRequestLog(
      type: 'OTA Complete',
      sn: sn,
      ip: ip,
      port: port,
      extra: 'file=$fileName',
    );
  }

  /// 通知设备修改IP和端口，等待 sn_change_tp 返回成功
  static Future<bool> changeDeviceIpTcp({
    required String sn,
    required String ip,
    required int port,
    required String newIp,
    required int newPort,
  }) async {
    recordRequestLog(
      type: 'Change IP',
      sn: sn,
      ip: ip,
      port: port,
      extra: 'newIp=$newIp, newPort=$newPort',
    );
    try {
      final res = await WebSocketManager().sendCommand(
        host: ip,
        port: port,
        cmd: 'ip_detail',
        line: 'IP_change=$newIp port=$newPort sn=$sn',
      );
      final rawCode = res['code'];
      final code = rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
      return code == 200;
    } catch (e) {
      print("Change device IP failed: $e");
      recordRequestLog(
        type: 'Change IP Failed',
        sn: sn,
        ip: ip,
        port: port,
        extra: 'Error: $e',
      );
      return false;
    }
  }

  static Future<void> syncClockTcp({DateTime? time}) async {
    final devs = await AppDatabase.allDevices();
    final now = time ?? DateTime.now();
    final y = now.year;
    final m = now.month;
    final d = now.day;
    final h = now.hour;
    final min = now.minute;
    final s = now.second;

    for (final dev in devs) {
      final sn = (dev['sn'] as String?) ?? '';
      final ip = (dev['ip'] as String?) ?? '';
      final port = (dev['port'] as int?) ?? 0;
      if (ip.isEmpty || port == 0) continue;

      recordRequestLog(
        type: 'Sync Clock',
        sn: sn,
        ip: ip,
        port: port,
        extra: 'Time: $y-$m-$d $h:$min:$s',
      );

      try {
        // 发送 clock 指令，不等待响应即可
        await WebSocketManager().sendCommandNoWait(
          host: ip,
          port: port,
          line: 'clock year=$y month=$m day=$d hour=$h minute=$min second=$s',
        );
        // await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print("Sync device $sn failed: $e");
        recordRequestLog(
          type: 'Sync Clock Failed',
          sn: sn,
          ip: ip,
          port: port,
          extra: 'Error: $e',
        );
      }
    }
  }
}
