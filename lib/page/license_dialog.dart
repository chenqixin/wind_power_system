///
/// license_dialog.dart
/// wind_power_system
/// License 激活 / 过期提示弹窗
///
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/core/license/license_validator.dart';

class LicenseDialog extends StatefulWidget {
  final LicenseStatus status;
  final LicenseInfo? info;

  const LicenseDialog({
    super.key,
    required this.status,
    this.info,
  });

  @override
  State<LicenseDialog> createState() => _LicenseDialogState();
}

class _LicenseDialogState extends State<LicenseDialog> {
  final TextEditingController _keyController = TextEditingController();
  bool _activating = false;
  String _errorText = '';

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  String get _hintMessage {
    switch (widget.status) {
      case LicenseStatus.fileNotFound:
        return '未检测到授权文件，请输入授权密钥以激活软件';
      case LicenseStatus.expired:
        final expire = widget.info?.expire ?? '';
        return '授权已于 $expire 到期，请输入新的授权密钥';
      case LicenseStatus.invalid:
        return '授权文件无效，请输入正确的授权密钥';
      case LicenseStatus.valid:
        return '';
    }
  }

  Future<void> _activate() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() => _errorText = '请输入授权密钥');
      return;
    }

    setState(() {
      _activating = true;
      _errorText = '';
    });

    try {
      // 先校验密钥是否合法
      final (status, info) = await LicenseValidator.validateFromString(key);

      if (status == LicenseStatus.valid) {
        // 写入 license.dat 到 Documents 目录
        final licensePath = await LicenseValidator.getLicensePath();
        await File(licensePath).writeAsString(key);

        if (!mounted) return;
        Navigator.of(context).pop(true);
        AppNotice.show(
          title: '提示',
          content: '激活成功！客户：${info?.customer}，有效期至：${info?.expire}',
        );
      } else if (status == LicenseStatus.expired) {
        setState(() {
          _activating = false;
          _errorText = '此授权密钥已过期 (${info?.expire})';
        });
      } else {
        setState(() {
          _activating = false;
          _errorText = '授权密钥无效，请检查后重试';
        });
      }
    } catch (e) {
      setState(() {
        _activating = false;
        _errorText = '激活失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
      color: AppColors.blue06,
      fontWeight: FontWeight.w600,
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
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题
            Row(
              children: [
                Container(width: 4, height: 16, color: AppColors.blue06),
                const SizedBox(width: 12),
                Text('软件授权', style: titleStyle),
              ],
            ),
            const SizedBox(height: 16),

            // 提示信息
            Text(_hintMessage).simpleStyle(13, HexColor('#8A9199')),
            const SizedBox(height: 16),

            // 已有授权信息（过期时显示）
            if (widget.info != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: HexColor('#FFF3E0'),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: HexColor('#FFB74D')),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('当前授权信息:').simpleStyle(12, HexColor('#E65100')),
                    const SizedBox(height: 4),
                    Text('客户: ${widget.info!.customer}')
                        .simpleStyle(12, HexColor('#BF360C')),
                    Text('有效期至: ${widget.info!.expire}')
                        .simpleStyle(12, HexColor('#BF360C')),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 密钥输入框
            Text('授权密钥：').simpleStyle(14, AppColors.blue133),
            const SizedBox(height: 8),
            TextField(
              controller: _keyController,
              maxLines: 4,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.blue133,
                fontFamily: 'Consolas',
              ),
              decoration: InputDecoration(
                hintText: '请粘贴授权密钥',
                hintStyle: TextStyle(
                  fontSize: 12,
                  color: HexColor('#8A9199'),
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF0696BD)),
                ),
              ),
            ),

            // 错误提示
            if (_errorText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_errorText).simpleStyle(12, Colors.red),
            ],

            const SizedBox(height: 16),

            // 按钮
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _activating ? null : _activate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _activating
                            ? HexColor('#0696BD').withOpacity(0.5)
                            : HexColor('#0696BD'),
                      ),
                      child: Center(
                        child: Text(_activating ? '验证中...' : '激活')
                            .simpleStyle(12, HexColor('#F8FCFF')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: () => exit(0), // 未激活则退出
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: HexColor('#CADBEB'),
                      ),
                      child: Center(
                        child:
                            Text('退出程序').simpleStyle(12, HexColor('#424A4D')),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
