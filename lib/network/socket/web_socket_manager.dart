///
/// web_socket_manager.dart
/// window
/// Created by cqx on 2025/12/11.
/// Copyright ©2025 Changjia. All rights reserved.
///
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  WebSocketChannel? _channel;
  bool _connected = false;

  /// 用来标记是否是手动关闭（用于阻止自动重连）
  bool _manuallyClosed = false;

  Timer? _heartBeatTimer;
  Timer? _reconnectTimer;

  final _msgStream = StreamController<String>.broadcast();
  Stream<String> get stream => _msgStream.stream;

  /// 开始连接
  void connect(String url) {
    _manuallyClosed = false; // 每次连接前清空手动关闭标记
    print("WS connecting: $url");

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
            (data) {
          _connected = true;
          print("WS 收到: $data");
          _msgStream.add(data);
        },

        onError: (e) {
          print("WS error: $e");
          _connected = false;

          // 不是手动关闭才自动重连
          if (!_manuallyClosed) _reconnect(url);
        },

        onDone: () {
          print("WS closed");
          _connected = false;

          // 不是手动关闭才自动重连
          if (!_manuallyClosed) _reconnect(url);
        },
      );

      _startHeartBeat();
    } catch (e) {
      print("WS connect exception: $e");
      _connected = false;

      if (!_manuallyClosed) _reconnect(url);
    }
  }

  /// 心跳包，每5秒发送一次
  void _startHeartBeat() {
    _heartBeatTimer?.cancel();
    _heartBeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_connected) {
        send(jsonEncode({
          "cmd": 'ping',
        }));
        print("WS 心跳 ping");
      }
    });
  }

  /// 自动重连
  void _reconnect(String url) {
    if (_reconnectTimer != null) return;

    print("WS 3秒后重连...");
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _reconnectTimer = null;
      if (!_manuallyClosed) {
        connect(url);
      }
    });
  }

  /// 发送消息
  void send(String message) {
    if (_connected && _channel != null) {
      _channel!.sink.add(message);
    }
  }

  /// 关闭
  void close() {
    print("WS 手动关闭");
    _manuallyClosed = true; // ❗ 阻止自动重连

    _connected = false;
    _heartBeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
  }
}
