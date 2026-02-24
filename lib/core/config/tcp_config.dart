import 'dart:convert';
import 'package:flutter/services.dart';

class TCPConfig {
  static String? _host;
  static int? _port;

  static Future<void> ensureLoaded() async {
    if (_host != null && _port != null) return;
    try {
      final s = await rootBundle.loadString('lib/resources/json/tcp_config.json');
      final obj = json.decode(s);
      if (obj is Map<String, dynamic>) {
        final h = obj['host'];
        final p = obj['port'];
        _host = h is String ? h : (_host ?? '127.0.0.1');
        _port = p is int ? p : int.tryParse('$p') ?? (_port ?? 5000);
      }
    } catch (_) {
      _host ??= '127.0.0.1';
      _port ??= 5000;
    }
  }

  static String get host => _host ?? '127.0.0.1';
  static int get port => _port ?? 5000;
}
