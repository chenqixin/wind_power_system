///
/// device_detail.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';



class DeviceDetailPage extends StatefulWidget {
  final String sn;
  const DeviceDetailPage({super.key, required this.sn});

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Device Detail'),
      ),
      body: const Center(
        child: Text('Device Detail Page'),
      ),
    );
  }
}
