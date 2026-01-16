import 'package:flutter/material.dart';

extension AIText on Text {
  /// 默认字号为空
  Text whiteBold(double? fontSize) {
    return Text(
      data ?? '',
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white,
        letterSpacing: AIText.letterSpacing,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
      ),
    );
  }

  Text simpleStyle(double size, Color textColor, {bool isBold = false}) {
    return Text(
      data ?? '',
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: size,
        color: textColor,
        fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  static double letterSpacing = 0.72;
}
