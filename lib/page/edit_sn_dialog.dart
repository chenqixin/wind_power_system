library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/db/app_database.dart';
import 'package:wind_power_system/network/http/api_util.dart';

class EditSnDialog extends StatefulWidget {
  final String originSn;
  final String ip;
  final int port;
  final String deviceSn;

  const EditSnDialog({
    super.key,
    required this.originSn,
    required this.ip,
    required this.port,
    required this.deviceSn,
  });

  @override
  State<EditSnDialog> createState() => _EditSnDialogState();
}

class _EditSnDialogState extends State<EditSnDialog> {
  late final TextEditingController _ipController =
      TextEditingController(text: widget.ip);
  late final TextEditingController _turbineNoController =
      TextEditingController(text: widget.originSn);
  late final TextEditingController _portController =
      TextEditingController(text: widget.port.toString());
  late final TextEditingController _deviceSnController =
      TextEditingController(text: widget.deviceSn);

  @override
  void dispose() {
    _ipController.dispose();
    _turbineNoController.dispose();
    _portController.dispose();
    _deviceSnController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
      color: AppColors.blue06,
      fontWeight: FontWeight.w600,
    );

    final labelStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.blue133,
    );

    final contentStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.blue133,
      fontWeight: FontWeight.w400,
    );

    final hintStyle = TextStyle(
      fontSize: 12,
      color: HexColor('#8A9199'),
      fontWeight: FontWeight.w400,
    );

    return Dialog(
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
                Text('编辑设备信息', style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                )
              ],
            ),
            _formGroup(
              label: '风机IP地址：',
              labelStyle: labelStyle,
              child: _inputField(
                controller: _ipController,
                hintText: '请输入风机IP地址',
                hintStyle: hintStyle,
                textStyle: contentStyle,
                keyboardType: TextInputType.text,
              ),
            ),
            _formGroup(
              label: '风机编号：',
              labelStyle: labelStyle,
              child: _inputField(
                controller: _turbineNoController,
                hintText: '请输入风机编号',
                hintStyle: hintStyle,
                textStyle: hintStyle,
                keyboardType: TextInputType.text,
                enabled: false,
              ),
            ),
            _formGroup(
              label: '风机端口：',
              labelStyle: labelStyle,
              child: _inputField(
                controller: _portController,
                hintText: '请输入风机端口',
                hintStyle: hintStyle,
                textStyle: contentStyle,
                keyboardType: TextInputType.number,
              ),
            ),
            _formGroup(
              label: '设备编号：',
              labelStyle: labelStyle,
              child: _inputField(
                controller: _deviceSnController,
                hintText: '请输入设备编号',
                hintStyle: hintStyle,
                textStyle: hintStyle,
                keyboardType: TextInputType.text,
                enabled: false,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _onConfirm,
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
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onConfirm() async {
    final ip = _ipController.text.trim();
    final turbineNo = widget.originSn;
    final portText = _portController.text.trim();
    final deviceSn = widget.deviceSn;

    if (ip.isEmpty) {
      AppNotice.show(title: '提示', content: '请输入风机IP地址');
      return;
    }
    final ipReg = RegExp(r'^(?:\d{1,3}\.){3}\d{1,3}$');
    if (!ipReg.hasMatch(ip)) {
      AppNotice.show(title: '提示', content: '风机IP地址格式不正确');
      return;
    }
    if (turbineNo.isEmpty) {
      AppNotice.show(title: '提示', content: '请输入风机编号');
      return;
    }
    final port = int.tryParse(portText);
    if (port == null || port <= 0 || port > 65535) {
      AppNotice.show(title: '提示', content: '请输入合法的端口号');
      return;
    }
    if (deviceSn.isEmpty) {
      AppNotice.show(title: '提示', content: '请输入设备编号');
      return;
    }

    // 先通过TCP通知设备修改IP和端口，等待 sn_change_tp 返回成功
    final success = await Api.changeDeviceIpTcp(
      sn: turbineNo,
      ip: widget.ip,
      port: widget.port,
      newIp: ip,
      newPort: port,
    );

    if (!success) {
      AppNotice.show(title: '提示', content: '设备通信失败，请检查网络连接');
      return;
    }

    // TCP返回成功后，再更新数据库
    try {
      await AppDatabase.updateDevice(
        originSn: widget.originSn,
        sn: turbineNo,
        ip: ip,
        port: port,
        deviceSn: deviceSn,
      );
    } catch (e) {
      AppNotice.show(title: '提示', content: '该风机编号已存在');
      return;
    }

    Navigator.of(context).pop(<String, dynamic>{
      'ip': ip,
      'turbineNo': turbineNo,
      'port': port,
      'deviceSn': deviceSn,
    });
    AppNotice.show(title: '提示', content: '修改成功');
  }

  Widget _formGroup({
    required String label,
    required Widget child,
    required TextStyle labelStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label).simpleStyle(14, AppColors.blue133),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required TextStyle hintStyle,
    TextStyle? textStyle,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: textStyle,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF0696BD)),
        ),
      ),
    );
  }
}
