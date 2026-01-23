library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/style/app_decorations.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';

class AddUserDialog extends StatefulWidget {
  const AddUserDialog({super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _realNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String _role = '普通用户';
  String _status = '正常';

  @override
  void dispose() {
    _usernameController.dispose();
    _realNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
      color: AppColors.blue06,
      fontWeight: FontWeight.w600,
    );

    final labelStyle = TextStyle(
      fontSize: 14,
      color: AppColors.blue133,
    );

    final contentStyle = TextStyle(
      fontSize: 14,
      color: AppColors.blue133,
      fontWeight: FontWeight.w400,
    );

    final hintStyle = TextStyle(
        fontSize: 12, color: HexColor('#8A9199'), fontWeight: FontWeight.w400);

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
                Text('新增用户', style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                )
              ],
            ),
            _formGroup(
              context,
              label: '用户名：',
              labelStyle: labelStyle,
              child: _inputField(
                controller: _usernameController,
                hintText: '请输入用户名',
                hintStyle: hintStyle,
                keyboardType: TextInputType.text,
                textStyle: contentStyle,
              ),
            ),
            _formGroup(
              context,
              label: '用户权限：',
              labelStyle: labelStyle,
              child: _dropdown(
                value: _role,
                items: const ['普通用户', '管理员'],
                onChanged: (v) => setState(() => _role = v ?? _role),
              ),
            ),
            _formGroup(
              context,
              label: '状态：',
              labelStyle: labelStyle,
              child: _dropdown(
                value: _status,
                items: const ['正常', '禁用'],
                onChanged: (v) => setState(() => _status = v ?? _status),
              ),
            ),
            _formGroup(
              context,
              label: '密码：',
              labelStyle: labelStyle,
              child: _inputField(
                  controller: _realNameController,
                  hintText: '请输入密码',
                  hintStyle: hintStyle,
                  textStyle: contentStyle),
            ),
            _formGroup(
              context,
              label: '手机号：',
              labelStyle: labelStyle,
              child: _inputField(
                  controller: _phoneController,
                  hintText: '请输入手机号',
                  hintStyle: hintStyle,
                  keyboardType: TextInputType.phone,
                  textStyle: contentStyle),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
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

  Widget _formGroup(BuildContext context,
      {required String label,
      required Widget child,
      required TextStyle labelStyle}) {
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
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: textStyle,
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
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF0696BD)),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        highlightColor: AppColors.blueE9,
        focusColor: AppColors.blueE9,
        hoverColor: AppColors.blueE9.withOpacity(0.8),
        splashColor: AppColors.blueE9,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        dropdownColor: AppColors.white,
        style: const TextStyle(
            fontSize: 14, color: AppColors.blue133),
        items: items
            .map(
              (e) => DropdownMenuItem<String>(
                value: e,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 0),
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.blue133,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          isDense: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
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
    );
  }
}
