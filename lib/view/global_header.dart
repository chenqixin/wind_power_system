import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wind_power_system/genernal/extension/text.dart';

import '../core/constant/app_constant.dart';
import '../core/style/app_colors.dart';

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
}
