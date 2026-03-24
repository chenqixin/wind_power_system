///
/// license_validator.dart
/// wind_power_system
/// License 校验服务 — 使用内嵌 public.pem 验证 license.dat 签名
///
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';

class LicenseInfo {
  final String customer;
  final String expire;
  final String mac;

  LicenseInfo({
    required this.customer,
    required this.expire,
    this.mac = '',
  });

  bool get isExpired =>
      DateTime.tryParse(expire)?.isBefore(DateTime.now()) ?? true;
}

enum LicenseStatus {
  valid, // 合法且在有效期内
  expired, // 合法但已过期
  fileNotFound, // license.dat 不存在
  invalid, // 签名无效 / 格式错误
}

class LicenseValidator {
  /// 内嵌公钥 — 构建时替换为实际 public.pem 内容
  static const String _publicKeyPem = '''
-----BEGIN PUBLIC KEY-----
PASTE_YOUR_PUBLIC_KEY_HERE
-----END PUBLIC KEY-----
''';

  /// license.dat 的查找路径：优先安装目录（exe 同级），其次 Documents
  static Future<String?> _findLicenseFile() async {
    // 1. exe 同级目录（Inno Setup 写入位置）
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final p1 = '$exeDir${Platform.pathSeparator}license.dat';
    if (await File(p1).exists()) return p1;

    // 2. Documents 备用
    final home = Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'] ??
        '';
    if (home.isNotEmpty) {
      final p2 =
          '$home${Platform.pathSeparator}Documents${Platform.pathSeparator}license.dat';
      if (await File(p2).exists()) return p2;
    }

    return null;
  }

  /// 校验 license，返回状态和信息
  static Future<(LicenseStatus, LicenseInfo?)> validate() async {
    try {
      final path = await _findLicenseFile();
      if (path == null) {
        cjPrint('License: file not found');
        return (LicenseStatus.fileNotFound, null);
      }

      final raw = await File(path).readAsString();
      return validateFromString(raw.trim());
    } catch (e) {
      cjPrint('License: validate error: $e');
      return (LicenseStatus.invalid, null);
    }
  }

  /// 从 base64 字符串校验
  static Future<(LicenseStatus, LicenseInfo?)> validateFromString(
      String base64Str) async {
    try {
      final jsonStr = utf8.decode(base64Decode(base64Str));
      final obj = jsonDecode(jsonStr) as Map<String, dynamic>;

      final customer = obj['customer'] as String? ?? '';
      final expire = obj['expire'] as String? ?? '';
      final mac = obj['mac'] as String? ?? '';
      final signatureB64 = obj['signature'] as String? ?? '';

      if (customer.isEmpty || expire.isEmpty || signatureB64.isEmpty) {
        return (LicenseStatus.invalid, null);
      }

      // 验签
      final payload = '$customer|$expire|$mac';
      final signatureBytes = base64Decode(signatureB64);
      final valid = _verifySignature(payload, signatureBytes);

      if (!valid) {
        cjPrint('License: signature invalid');
        return (LicenseStatus.invalid, null);
      }

      final info = LicenseInfo(customer: customer, expire: expire, mac: mac);

      if (info.isExpired) {
        cjPrint('License: expired at $expire');
        return (LicenseStatus.expired, info);
      }

      cjPrint('License: valid, customer=$customer, expire=$expire');
      return (LicenseStatus.valid, info);
    } catch (e) {
      cjPrint('License: parse error: $e');
      return (LicenseStatus.invalid, null);
    }
  }

  /// RSA-SHA256 验签 (PKCS1v15)
  static bool _verifySignature(String payload, List<int> signature) {
    try {
      final publicKey = RSAKeyParser().parse(_publicKeyPem) as RSAPublicKey;

      final signer = RSASigner(
        RSASignDigest.SHA256,
        publicKey: publicKey,
      );

      return signer.verify(
        Uint8List.fromList(utf8.encode(payload)),
        Encrypted(Uint8List.fromList(signature)),
      );
    } catch (e) {
      cjPrint('License: verify error: $e');
      return false;
    }
  }
}
