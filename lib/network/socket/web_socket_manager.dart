import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';
import 'package:wind_power_system/network/socket/device_connection.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();
  factory WebSocketManager() => _instance;
  WebSocketManager._internal();

  final Map<String, DeviceConnection> _connections = {};

  /// 最大连接数（防止设备太多）
  final int maxConnections = 100;

  final _devicePushStream = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get devicePushStream => _devicePushStream.stream;

  String _key(String host, int port) => "$host:$port";

  void emitPush(Map<String, dynamic> data) {
    _devicePushStream.add(data);
  }

  Future<DeviceConnection> getConnection(String host, int port) async {
    final key = _key(host, port);

    var conn = _connections[key];

    if (conn == null) {
      /// LRU 回收
      if (_connections.length >= maxConnections) {
        final oldest = _connections.values
            .reduce((a, b) => a.lastUsed.isBefore(b.lastUsed) ? a : b);
        oldest.close();
        _connections.remove(_key(oldest.host, oldest.port));
      }

      conn = DeviceConnection(host, port, this);
      _connections[key] = conn;
    }

    conn.touch();

    try {
      await conn.connect();
    } catch (e) {
      // 连接失败，上层处理
      rethrow;
    }

    return conn;
  }

  Future<dynamic> sendCommand({
    required String host,
    required int port,
    required String cmd,
    required String line,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final conn = await getConnection(host, port);
    return conn.send(cmd, line, timeout: timeout);
  }

  /// 发送文本头 + 原始二进制数据
  Future<dynamic> sendBinaryCommand({
    required String host,
    required int port,
    required String cmd,
    required String header,
    required Uint8List binary,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final conn = await getConnection(host, port);
    return conn.sendBinary(cmd, header, binary, timeout: timeout);
  }

  Future<void> sendCommandNoWait({
    required String host,
    required int port,
    required String line,
  }) async {
    try {
      final conn = await getConnection(host, port);
      conn.sendNoWait(line);
    } catch (e) {
      print("sendNoWait error: $e");
    }
  }

  void disconnectDevice(String host, int port) {
    final key = _key(host, port);
    _connections[key]?.close();
    _connections.remove(key);
  }

  void disconnectAll() {
    for (final c in _connections.values) {
      c.close();
    }
    _connections.clear();
  }
}
