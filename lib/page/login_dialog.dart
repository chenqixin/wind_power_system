library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/network/http/api_util.dart';
import 'package:wind_power_system/core/utils/custom_toast.dart';

class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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
                Text('登录', style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 18),
                )
              ],
            ),
            _formGroup(
              label: '用户名：',
              child: _inputField(
                controller: _usernameController,
                hintText: '请输入用户名',
                hintStyle: hintStyle,
                textStyle: contentStyle,
                keyboardType: TextInputType.text,
              ),
            ),
            _formGroup(
              label: '密码：',
              child: _passwordField(
                controller: _passwordController,
                hintText: '请输入密码',
                hintStyle: hintStyle,
                textStyle: contentStyle,
                obscure: _obscure,
                onToggleObscure: () => setState(() => _obscure = !_obscure),
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
                  child: InkWell(
                    onTap: () => Navigator.of(context).pop(),
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

  void _onConfirm() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    if (username.isEmpty) {
      AIToast.error('请输入用户名');
      return;
    }
    if (password.isEmpty) {
      AIToast.error('请输入密码');
      return;
    }

    await Api.post(
      'login',
      data: {
        'username': username,
        'password': password,
      },
      successCallback: (data) {
        AIToast.msg('登录成功');
        Navigator.of(context).pop(<String, dynamic>{
          'username': username,
        });
      },
      failCallback: (code, msg) {
        AIToast.error(msg);
      },
    );
  }

  Widget _formGroup({
    required String label,
    required Widget child,
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

  Widget _passwordField({
    required TextEditingController controller,
    required String hintText,
    required TextStyle hintStyle,
    TextStyle? textStyle,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
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
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
              size: 18, color: AppColors.blue133),
          onPressed: onToggleObscure,
        ),
      ),
    );
  }
}

