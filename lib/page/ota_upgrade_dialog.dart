///
/// ota_upgrade_dialog.dart
/// wind_power_system
/// Created by claude on 2026/3/23.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/view/notice_dialog.dart';
import 'package:wind_power_system/network/http/api_util.dart';

class OtaUpgradeDialog extends StatefulWidget {
  final String sn;
  final String ip;
  final int port;

  const OtaUpgradeDialog({
    super.key,
    required this.sn,
    required this.ip,
    required this.port,
  });

  @override
  State<OtaUpgradeDialog> createState() => _OtaUpgradeDialogState();
}

class _OtaUpgradeDialogState extends State<OtaUpgradeDialog> {
  File? _selectedFile;
  String? _fileName;
  int? _fileSize;
  bool _uploading = false;
  double _progress = 0.0;
  String _statusText = '';

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
      dialogTitle: '选择OTA升级文件',
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
        _fileName = result.files.single.name;
        _fileSize = file.lengthSync();
      });
    }
  }

  Future<void> _startUpload() async {
    if (_selectedFile == null) {
      AppNotice.show(title: '提示', content: '请先选择升级文件');
      return;
    }

    setState(() {
      _uploading = true;
      _progress = 0.0;
      _statusText = '正在通知设备准备升级...';
    });

    try {
      await Api.otaUpgrade(
        sn: widget.sn,
        ip: widget.ip,
        port: widget.port,
        file: _selectedFile!,
        fileName: _fileName!,
        onProgress: (progress, status) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
            _statusText = status;
          });
        },
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      AppNotice.show(title: '提示', content: 'OTA升级成功');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _statusText = '升级失败: $e';
      });
      AppNotice.show(title: '提示', content: '升级失败: $e');
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
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
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            Row(
              children: [
                Container(width: 4, height: 16, color: AppColors.blue06),
                const SizedBox(width: 12),
                Text('OTA固件升级', style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: _uploading ? null : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 设备信息
            Text('设备编号：${widget.sn}').simpleStyle(14, AppColors.blue133),
            const SizedBox(height: 4),
            Text('设备地址：${widget.ip}:${widget.port}')
                .simpleStyle(12, HexColor('#8A9199')),
            const SizedBox(height: 16),

            // 文件选择区域
            InkWell(
              onTap: _uploading ? null : _pickFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _selectedFile != null
                        ? HexColor('#0696BD')
                        : const Color(0xFFE6E6E6),
                    style: _selectedFile != null
                        ? BorderStyle.solid
                        : BorderStyle.solid,
                  ),
                  color: _selectedFile != null
                      ? HexColor('#0696BD').withOpacity(0.05)
                      : Colors.white,
                ),
                child: Column(
                  children: [
                    Icon(
                      _selectedFile != null
                          ? Icons.insert_drive_file
                          : Icons.cloud_upload_outlined,
                      size: 36,
                      color: _selectedFile != null
                          ? HexColor('#0696BD')
                          : HexColor('#8A9199'),
                    ),
                    const SizedBox(height: 8),
                    if (_selectedFile != null) ...[
                      Text(_fileName ?? '').simpleStyle(13, AppColors.blue133),
                      const SizedBox(height: 4),
                      Text(_formatFileSize(_fileSize ?? 0))
                          .simpleStyle(12, HexColor('#8A9199')),
                    ] else
                      Text('点击选择升级固件文件')
                          .simpleStyle(13, HexColor('#8A9199')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 上传进度
            if (_uploading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 8,
                  backgroundColor: HexColor('#E6E6E6'),
                  valueColor:
                      AlwaysStoppedAnimation<Color>(HexColor('#0696BD')),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(_statusText)
                        .simpleStyle(12, HexColor('#8A9199')),
                  ),
                  Text('${(_progress * 100).toStringAsFixed(1)}%')
                      .simpleStyle(12, HexColor('#0696BD')),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 非上传中但有状态文字（如失败信息）
            if (!_uploading && _statusText.isNotEmpty) ...[
              Text(_statusText).simpleStyle(12, Colors.red),
              const SizedBox(height: 12),
            ],

            // 按钮栏
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _uploading ? null : _startUpload,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _uploading
                            ? HexColor('#0696BD').withOpacity(0.5)
                            : HexColor('#0696BD'),
                      ),
                      child: Center(
                        child: Text(_uploading ? '升级中...' : '开始升级')
                            .simpleStyle(12, HexColor('#F8FCFF')),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _uploading ? null : () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _uploading
                            ? HexColor('#CADBEB').withOpacity(0.5)
                            : HexColor('#CADBEB'),
                      ),
                      child: Center(
                        child: Text('取消')
                            .simpleStyle(12, HexColor('#424A4D')),
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
