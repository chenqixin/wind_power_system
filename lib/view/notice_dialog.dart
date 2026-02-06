library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';

class NoticeDialog extends StatelessWidget {
  final String title;
  final String content;

  const NoticeDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 20),
      color: AppColors.blue06,
      fontWeight: FontWeight.w600,
    );

    final contentStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.blue133,
      fontWeight: FontWeight.w400,
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8FCFF),
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color(0x330B2750),
              offset: Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0,
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        width: 200,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 12),
                Text(title, style: titleStyle),
              ],
            ),
            const SizedBox(height: 10),
            Text(content, style: contentStyle),
          ],
        ),
      ),
    );
  }
}

class AppNotice {
  static Future<void> show({
    required String title,
    required String content,
    Duration duration = const Duration(seconds: 1),
  }) async {
    final ctx = AppConstant.shared.context;
    final nav = Navigator.of(ctx, rootNavigator: true);
    showDialog(
      context: ctx,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (_) => NoticeDialog(title: title, content: content),
    );
    await Future.delayed(duration);
    nav.maybePop();
  }
}
