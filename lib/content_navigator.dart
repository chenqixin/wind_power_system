///
/// content_navigator.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/page/device_detail.dart';
import 'package:wind_power_system/page/device_history_page.dart';
import 'package:wind_power_system/page/device_real_time_page.dart';
import 'package:wind_power_system/page/home_page.dart';


class ContentNavigator extends StatefulWidget {
  const ContentNavigator({super.key});

  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  @override
  State<ContentNavigator> createState() => _ContentNavigatorState();
}

class _ContentNavigatorState extends State<ContentNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: ContentNavigator.navigatorKey,
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(
              builder: (_) => const HomePage(),
            );
          case '/detail':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => DeviceDetailPage(sn: args),
            );

          case '/history':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => DeviceHistoryPage(sn: args),
            );
          case '/real_time':
            final args = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => DeviceRealTimePage(sn: args),
            );
        }
      },
    );
  }
}
