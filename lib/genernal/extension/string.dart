import 'package:flutter/material.dart';

extension AIString on String {
  /// 补齐images 路径
  String get imagePath {
    return "lib/images/$this";
  }

  String get capitalizeFirstLetter {
    if (isEmpty) return "";
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  /// 大于10000以w为单位
  static String balanceFormat(String string) {
    int balance = int.parse(string);
    if (balance >= 10000) {
      return "${((balance / 100.0).truncateToDouble() / 100.0).toStringAsFixed(2)}w";
    }
    return balance.toString();
  }

  /// 判断字符串是否是 HTML 标签
  bool isHtml() {
    const htmlPattern = r"<([A-Za-z][A-Za-z0-9]*)\b[^>]*>(.*?)</\1>";
    final regex = RegExp(htmlPattern, dotAll: true);
    return regex.hasMatch(this);
  }

  /// 判断是不是视频地址
  bool isVideoUrl() {
    final videoExtensions = [
      '.mp4',
      '.avi',
      '.mov',
      '.wmv',
      '.flv',
      '.mkv',
      '.webm',
      '.mpeg',
      '.3gp',
    ];
    return videoExtensions
        .any((extension) => toLowerCase().endsWith(extension));
  }

  static const placeholder = 'https://fakeimg.pl/100x100';

  /// 文本宽度
  double width(double fontSize, FontWeight fontWeight) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: this,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  /// 文本高度
  double height(double fontSize, FontWeight fontWeigh, double width) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: this,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeigh),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: width);
    return textPainter.height;
  }

}
