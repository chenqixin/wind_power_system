import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wind_power_system/genernal/extension/text.dart';

import '../core/constant/app_constant.dart';
import '../core/style/app_colors.dart';
import '../core/utils/secure_storage.dart';
import '../page/login_dialog.dart';
import '../view/notice_dialog.dart';

class GlobalHeader extends StatefulWidget {
  const GlobalHeader({super.key});

  @override
  State<GlobalHeader> createState() => _GlobalHeaderState();
}

class _GlobalHeaderState extends State<GlobalHeader> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        _now = DateTime.now();
      });
    });
    _initLoginState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppScreen.headerHeight,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
              color: HexColor('#0B2750').withOpacity(0.3),
              offset: const Offset(0, 2),
              blurRadius: 6,
              spreadRadius: 0),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Text(
              '',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w600,
                color: HexColor('#133F72'),
              ),
            ),
            const Spacer(),
            Text(_format(_now)).simpleStyle(20, HexColor('#133F72')),
            const SizedBox(width: 16),
            if (UserInfo.userName.isNotEmpty)
              Text(UserInfo.userName).simpleStyle(20, HexColor('#133F72')),
            const SizedBox(width: 12),
            InkWell(
              onTap: () async {
                if (UserInfo.userName.isNotEmpty) {
                  //await SecureStorage.clearLogin();
                  UserInfo.userName = '';
                  UserInfo.password = '';
                  UserInfo.role = 0;
                  if (mounted) setState(() {});
                  AppNotice.show(title: '提示', content: '已退出登录');
                } else {
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (_) => const LoginDialog(),
                  );
                  if (mounted) setState(() {});
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: UserInfo.userName.isNotEmpty
                      ? HexColor('#CADBEB')
                      : AppColors.blue06,
                ),
                child: Text(UserInfo.userName.isNotEmpty ? '退出' : '登录')
                    .simpleStyle(14, AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime t) {
    return '${t.year}-${_two(t.month)}-${_two(t.day)} '
        '${_two(t.hour)}:${_two(t.minute)}:${_two(t.second)}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  void _initLoginState() async {
    final u = await SecureStorage.username();
    final p = await SecureStorage.password();
    final r = await SecureStorage.role();
    if (u != null && p != null && r != null) {
      UserInfo.userName = u;
      UserInfo.password = p;
      UserInfo.role = r;
      if (mounted) setState(() {});
    }
  }
}
