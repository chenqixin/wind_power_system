///
/// device_real_time_data.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';

class DeviceRealTimePage extends StatefulWidget{

  final String sn;
  const DeviceRealTimePage({super.key, required this.sn});
  @override
  State<StatefulWidget> createState() {
    return _DeviceRealTimePageState();
  }
}

class _DeviceRealTimePageState extends State<DeviceRealTimePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('${widget.sn} 实时数据'),
      ),
    );
  }
}
