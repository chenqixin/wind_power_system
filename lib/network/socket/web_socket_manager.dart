///
/// web_socket_manager.dart
/// window
/// Created by cqx on 2025/12/11.
/// Copyright ©2025 Changjia. All rights reserved.
///
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/core/config/tcp_config.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  WebSocketChannel? _channel;
  bool _connected = false;

  Socket? _tcpSocket;
  StreamSubscription<List<int>>? _tcpSub;
  String? _tcpHost;
  int? _tcpPort;
  bool _connectingTcp = false;
  String _tcpBuffer = '';

  bool _manuallyClosed = false;

  Timer? _heartBeatTimer;
  Timer? _reconnectTimer;

  final _msgStream = StreamController<String>.broadcast();
  Stream<String> get stream => _msgStream.stream;

  void connect(String url) {
    _manuallyClosed = false;
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
          if (!_manuallyClosed) _reconnect(url);
        },
        onDone: () {
          print("WS closed");
          _connected = false;
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

  Future<void> connectTcp(String host, int port, {Duration? timeout}) async {
    _manuallyClosed = false;
    await TCPConfig.ensureLoaded();
    final targetHost = TCPConfig.host;
    final targetPort = TCPConfig.port;
    if (_connectingTcp && _tcpHost == targetHost && _tcpPort == targetPort) {
      return;
    }
    if (_tcpSocket != null &&
        _tcpHost == targetHost &&
        _tcpPort == targetPort) {
      return;
    }
    if (_tcpSocket != null &&
        (_tcpHost != targetHost || _tcpPort != targetPort)) {
      _closeTcpOnly();
    }

    _reconnectTimer?.cancel();
    _tcpHost = targetHost;
    _tcpPort = targetPort;
    _connectingTcp = true;
    print("TCP connecting: $targetHost:$targetPort");
    final t = timeout ?? const Duration(seconds: 5);

    try {
      _tcpSocket = await Socket.connect(targetHost, targetPort, timeout: t);
      _connected = true;
      _connectingTcp = false;
      final local = "${_tcpSocket!.address.address}:${_tcpSocket!.port}";
      final remote =
          "${_tcpSocket!.remoteAddress.address}:${_tcpSocket!.remotePort}";
      print("TCP 已连接 $local -> $remote");

      _tcpSub = _tcpSocket!.listen(
        (data) {
          final chunk = _bytesToPrintable(data);
          print("TCP 收到: $chunk");
          _tcpBuffer += chunk;
          while (true) {
            final idx = _tcpBuffer.indexOf('\n');
            if (idx < 0) break;
            final line = _tcpBuffer.substring(0, idx);
            _tcpBuffer = _tcpBuffer.substring(idx + 1);
            _handleTcpLine(line);
          }
        },
        onError: (e) {
          print("TCP error: $e");
          _connected = false;
          _connectingTcp = false;
          if (!_manuallyClosed) _reconnectTcp(targetHost, targetPort, t);
        },
        onDone: () {
          print("TCP closed");
          _connected = false;
          _connectingTcp = false;
          if (!_manuallyClosed) _reconnectTcp(targetHost, targetPort, t);
        },
        cancelOnError: true,
      );
    } catch (e) {
      print("TCP connect exception: $e");
      _connected = false;
      _connectingTcp = false;
      if (!_manuallyClosed) _reconnectTcp(targetHost, targetPort, t);
    }
  }

  String _bytesToPrintable(List<int> data) {
    try {
      return utf8.decode(data);
    } catch (_) {
      return data.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
    }
  }

  void _handleTcpLine(String line) {
    final s = line.trim();
    if (s.isEmpty) return;
    try {
      final obj = json.decode(s);
      final rawCode = obj is Map<String, dynamic> ? obj['code'] : null;
      final code = rawCode is int ? rawCode : int.tryParse('$rawCode') ?? 0;
      final msg = obj is Map<String, dynamic>
          ? (obj['message'] ?? obj['messge'])
          : null;
      if (code == 200) {
        _msgStream.add(s);
      } else {
        if (msg is String && msg.isNotEmpty) {
          AppNotice.show(title: '提示', content: msg);
        }
        _msgStream.add(s);
      }
    } catch (_) {
      _msgStream.add(s);
    }
  }

  void _startHeartBeat() {
    _heartBeatTimer?.cancel();
    _heartBeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_connected && _channel != null) {
        send(jsonEncode({"cmd": "ping"}));
        print("WS 心跳 ping");
      }
    });
  }

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

  void _reconnectTcp(String host, int port, Duration timeout) {
    if (_reconnectTimer != null) return;
    print("TCP 3秒后重连...");
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _reconnectTimer = null;
      if (!_manuallyClosed) {
        connectTcp(host, port, timeout: timeout);
      }
    });
  }

  void disconnectTcp() {
    _reconnectTimer?.cancel();
    _closeTcpOnly();
    _connected = false;
  }

  Future<void> restartTcp({Duration? delay, Duration? timeout}) async {
    final d = delay ?? const Duration(milliseconds: 300);
    await TCPConfig.ensureLoaded();
    final host = TCPConfig.host;
    final port = TCPConfig.port;
    _manuallyClosed = false;
    _reconnectTimer?.cancel();
    _closeTcpOnly();
    await Future.delayed(d);
    await connectTcp(host, port,
        timeout: timeout ?? const Duration(seconds: 5));
  }

  void _closeTcpOnly() {
    _tcpSub?.cancel();
    _tcpSocket?.destroy();
    _tcpSub = null;
    _tcpSocket = null;
  }

  void send(String message) {
    if (_connected) {
      if (_channel != null) {
        _channel!.sink.add(message);
        return;
      }
      if (_tcpSocket != null) {
        _tcpSocket!.add(utf8.encode(message));
      }
    }
  }

  void sendLine(String line) {
    if (_connected && _tcpSocket != null) {
      _tcpSocket!.add(utf8.encode("$line\n"));
    }
  }

  void requestDetail(String sn) {
    sendLine("detail sn=$sn");
  }

  void close() {
    print("WS 手动关闭");
    _manuallyClosed = true;

    _connected = false;
    _heartBeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _tcpSub?.cancel();
    _tcpSocket?.destroy();
  }
}
