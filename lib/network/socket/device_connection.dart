///
/// device_connection.dart
/// wind_power_system
/// Created by cqx on 2026/3/14.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';
import 'package:wind_power_system/network/socket/web_socket_manager.dart';


//（每台设备的长连接 + 请求队列 + 心跳）
class DeviceConnection {

  final String host;
  final int port;

  final WebSocketManager manager;

  Socket? _socket;

  bool connected = false;

  StreamSubscription? _sub;

  final Map<String, Completer> _pending = {};

  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  DateTime lastUsed = DateTime.now();

  /// 解决 TCP 粘包/半包
  String _buffer = '';

  DeviceConnection(this.host, this.port, this.manager);

  void touch() {
    lastUsed = DateTime.now();
  }

  Future<void> connect() async {

    if (connected) return;

    try {

      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 5),
      );

      connected = true;

      _socket!.setOption(SocketOption.tcpNoDelay, true);

      _sub = _socket!.listen(
        _onData,
        onDone: _onDone,
        onError: _onError,
        cancelOnError: true,
      );

      _startHeartbeat();

      print("TCP connected $host:$port");

    } catch (e) {

      print("connect fail $host:$port $e");

      _scheduleReconnect();

    }

  }

  /// TCP 数据接收
  void _onData(List<int> data) {

    /// 把数据拼接到 buffer
    _buffer += utf8.decode(data);

    int index;

    /// 按换行符拆包
    while ((index = _buffer.indexOf('\n')) != -1) {

      final line = _buffer.substring(0, index).trim();

      _buffer = _buffer.substring(index + 1);

      if (line.isEmpty) continue;

      try {

        final obj = json.decode(line);

        final cmd = obj["cmd"]?.toString() ?? "";

        /// 请求响应
        if (_pending.containsKey(cmd)) {

          _pending.remove(cmd)?.complete(obj);

        } else {

          /// 设备主动推送
          manager.emitPush(obj);

        }

      } catch (e) {

        print("json parse error: $e");

      }

    }

  }

  Future<dynamic> send(
      String cmd,
      String line, {
        Duration timeout = const Duration(seconds: 5),
      }) {

    if (!connected || _socket == null) {
      throw Exception("device not connected");
    }

    final completer = Completer();

    _pending[cmd] = completer;

    _socket!.write("$line\n");

    touch();

    return completer.future.timeout(timeout, onTimeout: () {

      _pending.remove(cmd);

      throw Exception("timeout $cmd");

    });

  }

  void _onDone() {

    connected = false;

    print("TCP closed $host:$port");

    _scheduleReconnect();

  }

  void _onError(e) {

    connected = false;

    print("TCP error $host:$port $e");

    _scheduleReconnect();

  }

  void _scheduleReconnect() {

    if (_reconnectTimer != null) return;

    _reconnectTimer = Timer(const Duration(seconds: 3), () async {

      _reconnectTimer = null;

      if (!connected) {

        await connect();

      }

    });

  }

  void _startHeartbeat() {

    _heartbeatTimer?.cancel();

    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {

      if (connected && _socket != null) {

        _socket!.write('{"cmd":"ping"}\n');

      }

    });

  }

  void close() {

    connected = false;

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();

    _sub?.cancel();

    _socket?.destroy();

    _pending.clear();

  }

}