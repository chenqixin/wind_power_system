import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';

class DeleteDeviceDialog extends StatelessWidget {
  final String sn;

  const DeleteDeviceDialog({super.key, required this.sn});

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
      color: AppColors.blue06,
      fontWeight: FontWeight.w600,
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 120, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: HexColor('#F8FCFF'),
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
        padding: const EdgeInsets.all(16),
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: AppColors.blue06),
                const SizedBox(width: 12),
                Text('提示', style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  icon: const Icon(Icons.close, size: 18),
                )
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                '确认删除设备 $sn 吗？',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.blue133,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: HexColor('#0696BD'),
                      ),
                      child: Center(
                        child: Text('确定').simpleStyle(12, HexColor('#F8FCFF')),
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
                        color: HexColor('#CADBEB'),
                      ),
                      child: Center(
                        child: Text('取消').simpleStyle(12, HexColor('#424A4D')),
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
