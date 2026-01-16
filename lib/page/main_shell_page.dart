///
/// main_shell_page.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/content_navigator.dart';

import '../core/constant/app_constant.dart';
import '../view/global_header.dart';

class MainShellPage extends StatelessWidget {
  const MainShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppConstant.init(context);
    return const Scaffold(
      backgroundColor: Color(0xFFF2F6FA),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: AppScreen.headerHeight),
              Expanded(
                child: ContentNavigator(), // 👇 页面内容
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: GlobalHeader(),
          ),
        ],
      ),
    );
  }
}
