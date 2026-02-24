library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';

class ErrorAlarmDialog extends StatelessWidget {
  final String title;
  final String content;

  const ErrorAlarmDialog({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
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
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: AppColors.blue06),
                const SizedBox(width: 12),
                Text(title, style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, size: 18),
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: contentStyle),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: AppColors.blue06,
                      ),
                      child: Center(
                        child: Text('确定').simpleStyle(12, AppColors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: const Color(0xFFCADBEB),
                      ),
                      child: Center(
                        child: Text('取消').simpleStyle(12, const Color(0xFF424A4D)),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

