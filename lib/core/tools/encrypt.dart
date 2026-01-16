import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '/core/utils/print_utils.dart';

class Encrypt {

  /// AES加密
  /// content： 要加密的内容
  /// key：秘钥
  /// iv: 偏移向量（16位）
  static String aesEncrypt(String content, String key, String iv) {
    if (content.isEmpty || key.isEmpty) {
      return "";
    }
    cjPrint("AES加密前的文本:$content");
    final keyData = Key.fromUtf8(key);
    final ivData = IV.fromUtf8(iv);
    final encrypter = Encrypter(AES(keyData, mode: AESMode.cbc, padding: 'PKCS7'));
    final encrypted = encrypter.encrypt(content, iv: ivData);
    String result = encrypted.base64;
    cjPrint("AES加密后的文本(base64编码):${encrypted.base64}");
    return result;
  }

  /// AES解密
  /// content： 要解密的内容（base64编码）
  /// key：秘钥
  /// iv: 偏移向量（16位）
  static String aesDecrypt(String content, String key, String iv) {
    if (content.isEmpty || key.isEmpty) {
      return "";
    }
    cjPrint("AES解密前的文本:$content");
    final keyData = Key.fromUtf8(key);
    final ivData = IV.fromUtf8(iv);
    final encrypter = Encrypter(AES(keyData, mode: AESMode.cbc, padding: 'PKCS7'));
    final decrypted = encrypter.decrypt64(content, iv: ivData);
    cjPrint("AES解密后的文本:$decrypted");
    return decrypted;
  }

  /// RSA加密
  /// content： 要加密的内容
  /// publicKeyStr：公钥
  static Future<String> rsaEncrypt(String content) async {
    if (content.isEmpty) {
      return "";
    }
    cjPrint("RSA加密前的文本:$content");
    var publicKeyStr = 'test/public.pem';
    final publicKey = await parseKeyFromFile<RSAPublicKey>(publicKeyStr);
    Encrypter encrypter = Encrypter(RSA(publicKey: publicKey, encoding: RSAEncoding.PKCS1, digest: RSADigest.SHA1));
    Encrypted encrypted = encrypter.encrypt(content);
    String result = encrypted.base64;
    cjPrint("RSA加密后的文本:$result");
    return result;
  }

  /// RSA解密
  /// content： 要解密的内容（base64编码）
  /// privateKeyStr：私钥
  static Future<String> rsaDecrypt(String content) async {
    if (content.isEmpty) {
      return "";
    }
    cjPrint("RSA解密前的文本:$content");
    var privateKeyStr = 'test/private.pem';
    final privateKey = await parseKeyFromFile<RSAPrivateKey>(privateKeyStr);
    Encrypter encrypter = Encrypter(RSA(privateKey: privateKey, encoding: RSAEncoding.PKCS1, digest: RSADigest.SHA1));
    final decrypted = encrypter.decrypt64(content);
    cjPrint("RSA解密后的文本:$decrypted");
    return decrypted;
  }

  /// md5
  static String md5Encrypt(String content) {
    cjPrint("md5加密前文本：$content");
    final utf = utf8.encode(content);
    final digest = md5.convert(utf);
    final encryptStr = digest.toString();
    cjPrint("md5加密后文本：$encryptStr");
    return encryptStr;
  }


}