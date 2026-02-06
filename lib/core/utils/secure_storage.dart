library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'print_utils.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _kUsername = 'username';
  static const String _kPassword = 'password';
  static const String _kRole = 'role';

  static Future<String> _filePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'login.json');
  }

  static String _hash(String s) =>
      crypto.sha256.convert(utf8.encode(s)).toString();

  static Future<bool> _saveFile(
      String username, String password, int role) async {
    try {
      final path = await _filePath();
      final data = {
        'username': username,
        'password': _hash(password),
        'role': role,
      };
      final f = File(path);
      await f.writeAsString(jsonEncode(data));
      final back = await f.readAsString();
      final m = jsonDecode(back) as Map<String, dynamic>;
      final ok = m['username'] == username &&
          m['password'] == _hash(password) &&
          '${m['role']}' == role.toString();
      if (!ok) {
        recordLogs('secure_storage file mismatch: $m');
      }
      return ok;
    } catch (e) {
      recordLogs('secure_storage file save error: $e');
      return false;
    }
  }

  static Future<bool> saveLogin({
    required String username,
    required String password,
    required int role,
  }) async {
    try {
      await _storage.write(key: _kUsername, value: username);
      await _storage.write(key: _kPassword, value: password);
      await _storage.write(key: _kRole, value: role.toString());
      final u = await _storage.read(key: _kUsername);
      final p0 = await _storage.read(key: _kPassword);
      final r = await _storage.read(key: _kRole);
      final ok = u == username && p0 == password && r == role.toString();
      if (!ok) {
        recordLogs('secure_storage mismatch: u=$u p=$p0 r=$r');
        return await _saveFile(username, password, role);
      }
      return ok;
    } on PlatformException catch (e) {
      recordLogs(
          'secure_storage platform error: code=${e.code} message=${e.message}');
      return await _saveFile(username, password, role);
    } catch (e) {
      recordLogs('secure_storage error: $e');
      return await _saveFile(username, password, role);
    }
  }

  static Future<bool> selfTest() async {
    try {
      await _storage.write(key: 'secure_storage_test_key', value: 'ok');
      final v = await _storage.read(key: 'secure_storage_test_key');
      await _storage.delete(key: 'secure_storage_test_key');
      return v == 'ok';
    } catch (e) {
      recordLogs('secure_storage selfTest error: $e');
      return false;
    }
  }

  static Future<String?> username() async {
    try {
      final v = await _storage.read(key: _kUsername);
      if (v != null) return v;
    } catch (_) {}
    try {
      final f = File(await _filePath());
      if (!await f.exists()) return null;
      final m = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return m['username'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> password() async {
    try {
      final v = await _storage.read(key: _kPassword);
      if (v != null) return v;
    } catch (_) {}
    try {
      final f = File(await _filePath());
      if (!await f.exists()) return null;
      final m = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      return m['password'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<int?> role() async {
    try {
      final v = await _storage.read(key: _kRole);
      if (v != null) return int.tryParse(v);
    } catch (_) {}
    try {
      final f = File(await _filePath());
      if (!await f.exists()) return null;
      final m = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final v = m['role'];
      return v is int ? v : int.tryParse('$v');
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearLogin() async {
    await _storage.delete(key: _kUsername);
    await _storage.delete(key: _kPassword);
    await _storage.delete(key: _kRole);
    try {
      final f = File(await _filePath());
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
  }

  static Future<Map<String, String>> readAll() => _storage.readAll();
}
