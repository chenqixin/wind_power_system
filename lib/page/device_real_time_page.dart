///
/// device_real_time_data.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_decorations.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/string.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/content_navigator.dart';
import 'package:dash_painter/dash_painter.dart';
import 'package:wind_power_system/network/http/api_util.dart';
import 'package:wind_power_system/view/charts/realtime_thickness_chart.dart';
import 'package:wind_power_system/model/DeviceDetailData.dart' as model;

class DeviceRealTimePage extends StatefulWidget {
  final String sn;

  const DeviceRealTimePage({super.key, required this.sn});

  @override
  State<StatefulWidget> createState() {
    return _DeviceRealTimePageState();
  }
}

class _DeviceRealTimePageState extends State<DeviceRealTimePage> {
  final Random _rnd = Random();
  model.DeviceDetailData? detail;
  Timer? _pollTimer;

  Widget _title(String text) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.blue06),
        const SizedBox(width: 12),
        Text(text).simpleStyle(12, AppColors.blue06, isBold: true),
      ],
    );
  }

  Widget _xItem(String path, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Row(
        children: [
          Image.asset(path.imagePath, width: 15, height: 5),
          const SizedBox(width: 2),
          Text(title).simpleStyle(10, HexColor('#133F72')),
        ],
      ),
    );
  }

  Future<List<double>> _requestBladeThickness(int blade) async {
    final completer = Completer<List<double>>();
    await Api.get(
      'device/realtime/thickness',
      params: {
        'sn': widget.sn,
        'blade': blade,
      },
      successCallback: (data) {
        try {
          if (data is Map<String, dynamic>) {
            final root = (data['root'] as num?)?.toDouble() ?? 0;
            final mid = (data['mid'] as num?)?.toDouble() ?? 0;
            final tip = (data['tip'] as num?)?.toDouble() ?? 0;
            completer.complete([root, mid, tip]);
            return;
          }
          if (data is List && data.length >= 3) {
            final root = (data[0] as num).toDouble();
            final mid = (data[1] as num).toDouble();
            final tip = (data[2] as num).toDouble();
            completer.complete([root, mid, tip]);
            return;
          }
        } catch (_) {}
        completer.complete([
          5 + _rnd.nextDouble() * 10,
          6 + _rnd.nextDouble() * 9,
          4 + _rnd.nextDouble() * 8,
        ]);
      },
      failCallback: (_, __) {
        completer.complete([
          5 + _rnd.nextDouble() * 10,
          6 + _rnd.nextDouble() * 9,
          4 + _rnd.nextDouble() * 8,
        ]);
      },
    );
    return completer.future;
  }

  void getSNDetail(String sn, String ip, int port) {
    Api.get(
      "sn/detail",
      successCallback: (data) {
        final d = model.DeviceDetailData.fromJson(data);
        if (!mounted) return;
        setState(() {
          detail = d;
        });
      },
      failCallback: (code, msg) {},
    );
  }

  @override
  void initState() {
    super.initState();
    getSNDetail(widget.sn, "172.0.0.1", 77);
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      getSNDetail(widget.sn, "172.0.0.1", 77);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
        child: Stack(children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'ic_bg_image.png'.imagePath,
                width: 300,
                height: 33,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: AppColors.white,
                  elevation: 6,
                  shadowColor: const Color(0x330B2750),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: TextStyle(
                    fontSize: AppScreen.adaptiveFontSize(context, 14),
                    color: AppColors.blue133,
                  ),
                ),
              ),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 18),
                tooltip: '',
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'overview',
                    child: Text('总预览页面').simpleStyle(12, AppColors.blue133),
                  ),
                  PopupMenuItem<String>(
                    value: 'realtime',
                    child: Text('实时数据').simpleStyle(12, AppColors.blue133),
                  ),
                  PopupMenuItem<String>(
                    value: 'history',
                    child: Text('历史数据').simpleStyle(12, AppColors.blue133),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'overview':
                      ContentNavigator.navigatorKey.currentState!
                          .pushNamedAndRemoveUntil('/home', (route) => false);
                      break;
                    case 'realtime':
                      ContentNavigator.navigatorKey.currentState!
                          .pushNamed('/real_time', arguments: widget.sn);
                      break;
                    case 'history':
                      ContentNavigator.navigatorKey.currentState!
                          .pushNamed('/history', arguments: widget.sn);
                      break;
                  }
                },
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                  child: Image.asset('btn_jm.png'.imagePath,
                      width: 90, height: 42),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppDecorations.panel(),
                              padding: EdgeInsets.zero,
                              child: SizedBox.expand(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          _title('叶片1厚度'),
                                          Spacer(),
                                          _xItem('ic_yg.png', '叶根冰层厚度'),
                                          _xItem('ic_yz.png', '叶中冰层厚度'),
                                          _xItem('ic_yj.png', '叶尖冰层厚度'),
                                          //折线图
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 1),
                                        child: RealtimeThicknessChart(
                                          onRequest: () =>
                                              _requestBladeThickness(2),
                                          refreshSeconds: 3,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppDecorations.panel(),
                              padding: EdgeInsets.zero,
                              child: SizedBox.expand(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          _title('叶片2厚度'),
                                          Spacer(),
                                          _xItem('ic_yg.png', '叶根冰层厚度'),
                                          _xItem('ic_yz.png', '叶中冰层厚度'),
                                          _xItem('ic_yj.png', '叶尖冰层厚度'),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 1),
                                        child: RealtimeThicknessChart(
                                          onRequest: () =>
                                              _requestBladeThickness(2),
                                          refreshSeconds: 3,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppDecorations.panel(),
                              padding: EdgeInsets.zero,
                              child: SizedBox.expand(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          _title('叶片3厚度'),
                                          Spacer(),
                                          _xItem('ic_yg.png', '叶根冰层厚度'),
                                          _xItem('ic_yz.png', '叶中冰层厚度'),
                                          _xItem('ic_yj.png', '叶尖冰层厚度'),
                                          //折线图
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 1),
                                        child: RealtimeThicknessChart(
                                          onRequest: () =>
                                              _requestBladeThickness(2),
                                          refreshSeconds: 3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppDecorations.panel(),
                              padding: EdgeInsets.zero,
                              child: SizedBox.expand(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          _title('叶片1加热曲线'),
                                          Spacer(),
                                          _xItem('ic_yg.png', '叶根冰层厚度'),
                                          _xItem('ic_yz.png', '叶中冰层厚度'),
                                          _xItem('ic_yj.png', '叶尖冰层厚度'),
                                          //折线图
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppDecorations.panel(),
                              padding: EdgeInsets.zero,
                              child: SizedBox.expand(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          _title('叶片2加热曲线'),
                                          Spacer(),
                                          _xItem('ic_yg.png', '叶根冰层厚度'),
                                          _xItem('ic_yz.png', '叶中冰层厚度'),
                                          _xItem('ic_yj.png', '叶尖冰层厚度'),
                                          //折线图
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: AppDecorations.panel(),
                              padding: EdgeInsets.zero,
                              child: SizedBox.expand(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18, vertical: 4),
                                      child: Row(
                                        children: [
                                          _title('叶片3加热曲线'),
                                          Spacer(),
                                          _xItem('ic_yg.png', '叶根冰层厚度'),
                                          _xItem('ic_yz.png', '叶中冰层厚度'),
                                          _xItem('ic_yj.png', '叶尖冰层厚度'),
                                          //折线图
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ])
        ]),
      ),
    );
  }
}
