///
/// device_history_page.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';

class DeviceHistoryPage extends StatefulWidget {
  final String sn;
  const DeviceHistoryPage({super.key, required this.sn});

  @override
  _DeviceHistoryPageState createState() => _DeviceHistoryPageState();
}

class _DeviceHistoryPageState extends State<DeviceHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Text('Device History Page'),
      ),
    );
  }
}
