import 'dart:math';

import 'package:flutter/material.dart';

extension AppColors on Colors {

  static const blue135 = Color(0xFF135B95);
  static const blue06 = Color(0xFF0696BD);
  static const blue133 = Color(0xFF133F72);
  static const blueE9 = Color(0xFFE9F4FF);
  static const blue0C = Color(0xFF0C83BB);

  static const white = Colors.white;
  static const black = Colors.black;
  static const lightBackground = Color(0xFFF5F5F5);
  static const darkBackground =  Color(0xFF0F1118);
  static const buttonBgGreyColor = Color(0xFF242833);
  static const lineGray = Color(0xFFE6E6E6);
  static const borderGray = Color(0xFFE6E6E6);

  static const textWhite = Colors.white;
  static const textBlack = Color(0xFF333333);
  static const textGray = Color(0xFF666666);
  static const textLightGray = Color(0xFF999999);
  static const textLighterGray = Color(0xFFCCCCCC);
  static const textRed = Color(0xFFFF0042);

  /// 如 0xffffff 
  static MaterialColor hexInt(int color) {
    return MaterialColor(0xFF000000 + color, const {});
  }

  static MaterialColor hexString(String color, [int num = 100]) {
    int alpha = (num * 255 / 100).round();
    int colorValue = int.parse(color.substring(1), radix: 16) + (alpha << 24);
    return MaterialColor(colorValue, const {});
  }

  static Color random() {
    final Random random = Random();
    return Color.fromARGB(
      255, // 透明度
      random.nextInt(256), // 红色值
      random.nextInt(256), // 绿色值
      random.nextInt(256), // 蓝色值
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

extension ColorExtension on Color {

  Color avg(Color other) {
    final red = (this.red + other.red) ~/ 2;
    final green = (this.green + other.green) ~/ 2;
    final blue = (this.blue + other.blue) ~/ 2;
    final alpha = (this.alpha + other.alpha) ~/ 2;
    return Color.fromARGB(alpha, red, green, blue);
  }
}
