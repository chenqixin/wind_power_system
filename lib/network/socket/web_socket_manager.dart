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
import 'package:wind_power_system/core/utils/print_utils.dart';

class WebSocketManager {
  static final WebSocketManager _instance = WebSocketManager._internal();

  factory WebSocketManager() => _instance;

  WebSocketManager._internal();

  WebSocketChannel? _channel;
  bool _connected = false;

  // TCP 多连接管理
  final Map<String, _TcpConnection> _tcpConnections = {};

  // 为了向后兼容，保留对“最后一次”或“当前”连接的引用
  String? _lastTcpKey;

  bool _manuallyClosed = false;

  Timer? _heartBeatTimer;
  Timer? _reconnectTimer;

  final _msgStream = StreamController<String>.broadcast();
  Stream<String> get stream => _msgStream.stream;

  String _tcpKey(String host, int port) => "$host:$port";

  void connect(String url) {
    _manuallyClosed = false;
    recordLogs("WS connecting: $url", level: LogLevel.info);
    recordRequestLog(type: 'WS Connect', ip: url);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      _channel!.stream.listen(
        (data) {
          _connected = true;
          cjPrint("WS 收到: $data");
          recordRequestLog(type: 'WS Receive', ip: url, extra: data.toString());
          _msgStream.add(data);
        },
        onError: (e) {
          recordLogs("WS error: $e", level: LogLevel.error);
          recordRequestLog(type: 'WS Error', ip: url, extra: e.toString());
          _connected = false;
          if (!_manuallyClosed) _reconnect(url);
        },
        onDone: () {
          recordLogs("WS closed", level: LogLevel.warning);
          recordRequestLog(type: 'WS Closed', ip: url);
          _connected = false;
          if (!_manuallyClosed) _reconnect(url);
        },
      );

      _startHeartBeat();
    } catch (e) {
      recordLogs("WS connect exception: $e", level: LogLevel.error);
      recordRequestLog(
          type: 'WS Connect Exception', ip: url, extra: e.toString());
      _connected = false;
      if (!_manuallyClosed) _reconnect(url);
    }
  }

  Future<void> connectTcp(String host, int port, {Duration? timeout}) async {
    _manuallyClosed = false;
    final key = _tcpKey(host, port);
    _lastTcpKey = key;

    var conn = _tcpConnections[key];
    if (conn == null) {
      conn = _TcpConnection(host, port);
      _tcpConnections[key] = conn;
    }

    if (conn.connecting || (conn.socket != null && conn.connected)) {
      return;
    }

    conn.reconnectTimer?.cancel();
    conn.connecting = true;
    recordLogs("TCP connecting: $host:$port", level: LogLevel.info);
    recordRequestLog(type: 'TCP Connect', ip: host, port: port);
    final t = timeout ?? const Duration(seconds: 5);

    try {
      final socket = await Socket.connect(host, port, timeout: t);
      conn.socket = socket;
      conn.connected = true;
      conn.connecting = false;
      _connected = true; // 只要有一个连上，全局状态暂且设为 true

      final local = "${socket.address.address}:${socket.port}";
      final remote = "${socket.remoteAddress.address}:${socket.remotePort}";
      recordLogs("TCP Connected $local -> $remote", level: LogLevel.info);
      recordRequestLog(
          type: 'TCP Connected',
          ip: host,
          port: port,
          extra: 'Local: $local, Remote: $remote');

      conn.sub = socket.listen(
        (data) {
          final chunk = _bytesToPrintable(data);
          cjPrint("TCP [$key] 收到: $chunk");
          recordRequestLog(
              type: 'TCP Receive', ip: host, port: port, extra: chunk.trim());
          conn!.buffer += chunk;
          while (true) {
            final idx = conn.buffer.indexOf('\n');
            if (idx < 0) break;
            final line = conn.buffer.substring(0, idx);
            conn.buffer = conn.buffer.substring(idx + 1);
            _handleTcpLine(line);
          }
        },
        onError: (e) {
          recordLogs("TCP [$key] error: $e", level: LogLevel.error);
          recordRequestLog(
              type: 'TCP Error', ip: host, port: port, extra: e.toString());
          conn!.connected = false;
          conn.connecting = false;
          if (!_manuallyClosed) _reconnectTcp(host, port, t);
        },
        onDone: () {
          recordLogs("TCP [$key] closed", level: LogLevel.warning);
          recordRequestLog(type: 'TCP Closed', ip: host, port: port);
          conn!.connected = false;
          conn.connecting = false;
          if (!_manuallyClosed) _reconnectTcp(host, port, t);
        },
        cancelOnError: true,
      );
    } catch (e) {
      recordLogs("TCP [$key] connect exception: $e", level: LogLevel.error);
      recordRequestLog(
          type: 'TCP Connect Exception',
          ip: host,
          port: port,
          extra: e.toString());
      conn.connected = false;
      conn.connecting = false;
      if (!_manuallyClosed) _reconnectTcp(host, port, t);
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
    final key = _tcpKey(host, port);
    final conn = _tcpConnections[key];
    if (conn == null || conn.reconnectTimer != null) return;

    print("TCP [$key] 3秒后重连...");
    conn.reconnectTimer = Timer(const Duration(seconds: 3), () {
      conn.reconnectTimer = null;
      if (!_manuallyClosed) {
        connectTcp(host, port, timeout: timeout);
      }
    });
  }

  void disconnectTcp({String? host, int? port}) {
    if (host != null && port != null) {
      final key = _tcpKey(host, port);
      final conn = _tcpConnections[key];
      if (conn != null) {
        conn.reconnectTimer?.cancel();
        conn.sub?.cancel();
        conn.socket?.destroy();
        conn.connected = false;
        _tcpConnections.remove(key);
      }
    } else {
      // 断开所有
      for (final conn in _tcpConnections.values) {
        conn.reconnectTimer?.cancel();
        conn.sub?.cancel();
        conn.socket?.destroy();
        conn.connected = false;
      }
      _tcpConnections.clear();
      _connected = false;
    }
  }

  Future<void> restartTcp(
      {String? host, int? port, Duration? delay, Duration? timeout}) async {
    final d = delay ?? const Duration(milliseconds: 300);

    String? targetHost = host;
    int? targetPort = port;

    if (targetHost == null || targetPort == null) {
      if (_lastTcpKey != null) {
        final parts = _lastTcpKey!.split(':');
        targetHost = parts[0];
        targetPort = int.tryParse(parts[1]);
      }
    }

    if (targetHost == null || targetPort == null) {
      await TCPConfig.ensureLoaded();
      targetHost = TCPConfig.host;
      targetPort = TCPConfig.port;
    }

    _manuallyClosed = false;
    disconnectTcp(host: targetHost, port: targetPort);
    await Future.delayed(d);
    await connectTcp(targetHost!, targetPort!,
        timeout: timeout ?? const Duration(seconds: 5));
  }

  void send(String message) {
    if (_connected) {
      if (_channel != null) {
        _channel!.sink.add(message);
        return;
      }
      // 如果没有指定，尝试发送到最后一个连接
      if (_lastTcpKey != null) {
        final conn = _tcpConnections[_lastTcpKey];
        if (conn != null && conn.connected && conn.socket != null) {
          conn.socket!.add(utf8.encode(message));
        }
      }
    }
  }

  void sendLine(String line, {String? host, int? port}) {
    _manuallyClosed = false;
    _TcpConnection? conn;
    if (host != null && port != null) {
      conn = _tcpConnections[_tcpKey(host, port)];
    } else if (_lastTcpKey != null) {
      conn = _tcpConnections[_lastTcpKey!];
    }

    if (conn != null && conn.connected && conn.socket != null) {
      recordRequestLog(
          type: 'TCP Send', ip: conn.host, port: conn.port, extra: line);
      conn.socket!.add(utf8.encode("$line\n"));
    }
  }

  void requestDetail(String sn, {String? host, int? port}) {
    sendLine("detail sn=$sn", host: host, port: port);
  }

  void close() {
    print("WS 手动关闭");
    _manuallyClosed = true;

    _connected = false;
    _heartBeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close();

    for (final conn in _tcpConnections.values) {
      conn.reconnectTimer?.cancel();
      conn.sub?.cancel();
      conn.socket?.destroy();
    }
    _tcpConnections.clear();
  }
}

class _TcpConnection {
  final String host;
  final int port;
  Socket? socket;
  StreamSubscription<List<int>>? sub;
  String buffer = '';
  bool connecting = false;
  bool connected = false;
  Timer? reconnectTimer;

  _TcpConnection(this.host, this.port);
}
