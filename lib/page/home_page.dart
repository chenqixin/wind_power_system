///
/// home_page.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/core/style/app_decorations.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/genernal/extension/string.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/db/app_database.dart';
import 'package:wind_power_system/network/http/api_util.dart';
import 'package:wind_power_system/model/DeviceDetailData.dart' as model;

import '../content_navigator.dart';
import 'add_user_dialog.dart';
import 'add_sn_dialog.dart';
import 'package:wind_power_system/core/utils/fileutils.dart';
import 'package:wind_power_system/core/utils/print_utils.dart';
import 'package:wind_power_system/core/utils/power_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class WindItem {
  final String sn;
  final String deviceSn;
  final String ip;
  final int port;
  final model.DeviceDetailData? details;

  WindItem(this.sn, this.deviceSn, this.ip, this.port, this.details);
}

class _HomePageState extends State<HomePage> {
  List<WindItem> items = [];
  Timer? _pollTimer;

  int? hoverIndex;
  OverlayEntry? _overlayEntry;
  Offset _overlayOffset = Offset.zero;

  double _tooltipW(BuildContext context) =>
      AppScreen.adaptiveFontSize(context, 290);

  double _tooltipH(BuildContext context) =>
      AppScreen.adaptiveFontSize(context, 135);

  Widget _buildHovelItem(int index, String title, String content) {
    return Container(
      decoration: BoxDecoration(
        color: index == 0 ? AppColors.white : AppColors.blueE9,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          children: [
            Text(title).simpleStyle(12, AppColors.blue133),
            const Spacer(),
            Text(content).simpleStyle(12, AppColors.blue133),
          ],
        ),
      ),
    );
  }

  String _statusText(WindItem it) {
    final s = it.details?.state;
    final ice = (s?.iceState ?? 0) == 1;
    final hot = (s?.hotState1 ?? 0) == 1;
    return (ice || hot) ? '警告' : '电网限功率运行';
  }

  String _statusImg(WindItem it) {
    final s = it.details?.state;
    final ice = (s?.iceState ?? 0) == 1;
    final hot = (s?.hotState1 ?? 0) == 1;
    return (ice || hot) ? 'ic_error.png' : 'ic_right.png';
  }

  //总功率
  ({String value, String unit}) _totalPowerValueUnit() {
    double sumW = 0.0;
    for (final it in items) {
      final res = powerValueUnit(it.details?.state);
      final v = double.tryParse(res.value);
      if (v == null) continue;
      if (res.unit.toLowerCase() == 'kw') {
        sumW += v * 1000.0;
      } else if (res.unit == 'W') {
        sumW += v;
      }
    }
    if (sumW >= 1000.0) {
      return (value: (sumW / 1000.0).toStringAsFixed(2), unit: 'kw');
    } else {
      return (value: sumW.toStringAsFixed(2), unit: 'W');
    }
  }

  num? _avg3(num? a, num? b, num? c) {
    final values = [a, b, c].where((e) => e != null).cast<num>().toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
    return sum / values.length;
  }

  num? _avgIceThickness(model.Winddata? wind) {
    if (wind == null) return null;
    final b1 = wind.blade1 == null
        ? null
        : _avg3(
            wind.blade1!.tickUp, wind.blade1!.tickMid, wind.blade1!.tickDown);
    final b2 = wind.blade2 == null
        ? null
        : _avg3(
            wind.blade2!.tickUp, wind.blade2!.tickMid, wind.blade2!.tickDown);
    final b3 = wind.blade3 == null
        ? null
        : _avg3(
            wind.blade3!.tickUp, wind.blade3!.tickMid, wind.blade3!.tickDown);
    final values = [b1, b2, b3].where((e) => e != null).cast<num>().toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
    return sum / values.length;
  }

  num? _avgBladeTemp(num? up, num? mid, num? down) {
    return _avg3(up, mid, down);
  }

  num? _avgDeviceTemp(model.Winddata? wind) {
    if (wind == null) return null;
    final b1 = wind.blade1 == null
        ? null
        : _avgBladeTemp(
            wind.blade1!.tempUp, wind.blade1!.tempMid, wind.blade1!.tempDown);
    final b2 = wind.blade2 == null
        ? null
        : _avgBladeTemp(
            wind.blade2!.tempUp, wind.blade2!.tempMid, wind.blade2!.tempDown);
    final b3 = wind.blade3 == null
        ? null
        : _avgBladeTemp(
            wind.blade3!.tempUp, wind.blade3!.tempMid, wind.blade3!.tempDown);
    final values = [b1, b2, b3].where((e) => e != null).cast<num>().toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
    return sum / values.length;
  }

  num? _avgAllDeviceTemp() {
    final values = items
        .map((it) => _avgDeviceTemp(it.details?.winddata))
        .where((e) => e != null)
        .cast<num>()
        .toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
    return sum / values.length;
  }

  num? _avgWindSpeed() {
    final values = items
        .map((it) => it.details?.state?.windSpeed)
        .where((e) => e != null && e >= 0)
        .cast<num>()
        .toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
    return sum / values.length;
  }

  num? _avgIceThicknessAll() {
    final values = items
        .map((it) => _avgIceThickness(it.details?.winddata))
        .where((e) => e != null && e >= 0)
        .cast<num>()
        .toList();
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
    return sum / values.length;
  }

  //综合管理
  Widget _buildZHItem(int index, String title, String content, String dw) {
    return Container(
      decoration: BoxDecoration(
        color: index == 0 ? AppColors.white : AppColors.blueE9,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 12),
        child: Row(
          children: [
            Text(title).simpleStyle(14, AppColors.blue133),
            const Spacer(),
            Text(content).simpleStyle(14, AppColors.blue06),
            const SizedBox(width: 4),
            Text(dw).simpleStyle(14, HexColor('#133F72')),
          ],
        ),
      ),
    );
  }

  void _showTooltip(WindItem it, Offset globalPos) {
    _overlayOffset = globalPos;
    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(builder: (context) {
      final screenW = MediaQuery.of(context).size.width;
      final screenH = MediaQuery.of(context).size.height;
      final margin = AppScreen.adaptiveFontSize(context, 8);
      double left = _overlayOffset.dx + margin;
      double top = _overlayOffset.dy - _tooltipH(context) - margin;
      if (left + _tooltipW(context) > screenW - margin) {
        left = _overlayOffset.dx - _tooltipW(context) - margin;
      }
      if (top < margin) {
        top = _overlayOffset.dy + margin; // 如果靠顶部，改为右下方
      }

      final textSub = TextStyle(
        fontSize: AppScreen.adaptiveFontSize(context, 14),
        color: const Color(0xFF6B7280),
      );

      //取平均值
      String _avgTempStr(num? a, num? b, num? c) {
        final values = [a, b, c].where((e) => e != null).cast<num>().toList();
        if (values.isEmpty) return 'error';
        final sum = values.fold<double>(0.0, (p, e) => p + e.toDouble());
        final avg = sum / values.length;
        return '${avg.toStringAsFixed(2)}℃';
      }

      final wind = it.details?.winddata;
      final blade1T = wind?.blade1 == null
          ? 'error'
          : _avgTempStr(
              wind!.blade1!.tempUp,
              wind.blade1!.tempMid,
              wind.blade1!.tempDown,
            );
      final blade2T = wind?.blade2 == null
          ? 'error'
          : _avgTempStr(
              wind!.blade2!.tempUp,
              wind.blade2!.tempMid,
              wind.blade2!.tempDown,
            );
      final blade3T = wind?.blade3 == null
          ? 'error'
          : _avgTempStr(
              wind!.blade3!.tempUp,
              wind.blade3!.tempMid,
              wind.blade3!.tempDown,
            );

      return Positioned(
        left: left,
        top: top,
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            width: _tooltipW(context),
            decoration: AppDecorations.panel(),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  it.sn,
                ).simpleStyle(22, AppColors.blue135, isBold: true),
                _buildHovelItem(1, '设备型号：', it.deviceSn),
                _buildHovelItem(0, '加热功率：',
                    '${powerValueUnit(it.details?.state).value} ${powerValueUnit(it.details?.state).unit}'),
                _buildHovelItem(1, '状态分类：：', '-'),
                _buildHovelItem(0, '叶片1平均温度：', blade1T),
                _buildHovelItem(1, '叶片2平均温度：', blade2T),
                _buildHovelItem(0, '叶片3平均温度：', blade3T),
              ],
            ),
          ),
        ),
      );
    });
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateTooltip(Offset globalPos) {
    _overlayOffset = globalPos;
    _overlayEntry?.markNeedsBuild();
  }

  void _hideTooltip() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
    // _pollTimer =
    //     Timer.periodic(const Duration(minutes: 5), (_) => _pollDevices());
  }

  Future<void> _loadItems() async {
    final devs = await AppDatabase.allDevices();
    final list = <WindItem>[];
    for (final d in devs) {
      final sn = (d['sn'] as String?) ?? '';
      final ip = (d['ip'] as String?) ?? '';
      final port = (d['port'] as int?) ?? 0;
      final deviceSn = (d['deviceSn'] as String?) ?? sn;
      final detail = await getSNDetail(sn, ip, port);
      list.add(WindItem(
        sn,
        deviceSn,
        ip,
        port,
        detail,
      ));
    }
    setState(() {
      items = list;
    });
  }

  void _pollDevices() {
    for (final it in items) {
      //getSNDetail(sn: it.sn, ip: it.ip, port: it.port);
    }
  }

  Future<model.DeviceDetailData?> getSNDetail(
      String sn, String ip, int port) async {
    final completer = Completer<model.DeviceDetailData?>();
    try {
      await Api.get(
        "sn/detail",
        successCallback: (data) {
          try {
            final detail = model.DeviceDetailData.fromJson(data);
            completer.complete(detail);
          } catch (_) {
            completer.complete(null);
          }
        },
        failCallback: (code, msg) {
          completer.complete(null);
        },
      );
    } catch (_) {
      completer.complete(null);
    }
    return await completer.future;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _hideTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textMain = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 18),
      color: const Color(0xFF135B95),
      fontWeight: FontWeight.w600,
    );

    final textSub = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 14),
      color: const Color(0xFF133F72),
    );

    final textCon = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
      color: const Color(0xFF0696BD),
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 100,
            child: Container(
              decoration: AppDecorations.panel(),
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () async {
                          final res = await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const AddUserDialog(),
                          );
                          if (res is Map<String, dynamic>) {
                            // 登录成功后的处理，例如刷新界面或保存用户信息
                          }
                        },
                        child: Image.asset('btn_login.png'.imagePath,
                            width: 90, height: 42),
                      ),
                      InkWell(
                        child: Image.asset('btn_register.png'.imagePath,
                            width: 90, height: 42),
                        onTap: () async {
                          //final detail =await getSNDetail("", "",1);
                          final res = await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => AddSnDialog(),
                          );
                          if (res is Map<String, dynamic>) {}
                        },
                      ),
                    ],
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 180),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 2.818,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final it = items[index];
                        return MouseRegion(
                          onEnter: (e) {
                            setState(() => hoverIndex = index);
                            _showTooltip(it, e.position);
                          },
                          onHover: (e) {
                            _updateTooltip(e.position);
                          },
                          onExit: (_) {
                            setState(() => hoverIndex = null);
                            _hideTooltip();
                          },
                          child: InkWell(
                            onTap: () {
                              //跳转到详情
                              ContentNavigator.navigatorKey.currentState!
                                  .pushNamed(
                                '/detail',
                                arguments: it.sn,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: HexColor('#C1D8F0'),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              padding: const EdgeInsets.all(10),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    AspectRatio(
                                      aspectRatio: 1, // 正方形
                                      child: Image.asset(
                                        'ic_fc.png'.imagePath,
                                        fit: BoxFit.cover, // 铺满
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                it.sn,
                                                style: textMain,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Spacer(),
                                              Text('冰层等级', style: textSub),
                                              const SizedBox(height: 2),
                                              Text(
                                                _avgIceThickness(it
                                                            .details?.winddata)
                                                        ?.toStringAsFixed(2) ??
                                                    '-',
                                                style: textCon,
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Image.asset(
                                                      _statusImg(it).imagePath,
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    const SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      _statusText(it),
                                                      style: textSub,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 17),
                                                  child: Text('加热功率',
                                                      style: textSub),
                                                ),
                                                const SizedBox(height: 2),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 17),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        powerValueUnit(it
                                                                .details?.state)
                                                            .value,
                                                        style: textCon,
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        powerValueUnit(it
                                                                .details?.state)
                                                            .unit,
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: HexColor(
                                                              '#133F72'),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 29,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 4, height: 16, color: AppColors.blue06),
                            const SizedBox(width: 12),
                            Text(
                              '统计数据',
                            ).simpleStyle(16, AppColors.blue06, isBold: true)
                          ],
                        ),
                        const SizedBox(height: 14),
                        _buildZHItem(1, '加热总功率', _totalPowerValueUnit().value,
                            _totalPowerValueUnit().unit),
                        _buildZHItem(
                            0,
                            '平均环境温度：',
                            _avgAllDeviceTemp()?.toStringAsFixed(2) ?? '-',
                            '℃'),
                        _buildZHItem(
                            1,
                            '平均冰层厚度：',
                            _avgIceThicknessAll()?.toStringAsFixed(2) ?? '-',
                            'mm'),
                        _buildZHItem(0, '平均风速：',
                            _avgWindSpeed()?.toStringAsFixed(2) ?? '-', 'm'),
                        _buildZHItem(1, '装机台数：', items.length.toString(), '台'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 4, height: 16, color: AppColors.blue06),
                            const SizedBox(width: 12),
                            Text(
                              '分类统计',
                            ).simpleStyle(16, AppColors.blue06, isBold: true),
                          ],
                        ),
                        SizedBox(height: 10),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, cons) {
                              const cross = 2;
                              const rows = 2;
                              const gap = 10.0;
                              final itemW =
                                  (cons.maxWidth - gap * (cross - 1)) / cross;
                              final itemH =
                                  (cons.maxHeight - gap * (rows - 1)) / rows;
                              final ratio = itemW / itemH;
                              return GridView.count(
                                shrinkWrap: false,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: cross,
                                crossAxisSpacing: gap,
                                mainAxisSpacing: gap,
                                childAspectRatio: ratio,
                                children: [
                                  _statTile(_normalCount().toString(),
                                      'ic_right.png', '正常状态'),
                                  _statTile(_iceCount().toString(),
                                      'ic_ice.png', '结冰状态'),
                                  _statTile(_heatCount().toString(),
                                      'ic_warm.png', '加热状态'),
                                  _statTile('0', 'ic_unkown.png', '未知事件'),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //正常状态
  int _normalCount() {
    return items.where((it) {
      final s = it.details?.state;
      final hot = (s?.hotState1 ?? 0) == 1;
      final ice = (s?.iceState ?? 0) == 1;
      return !hot && !ice;
    }).length;
  }

  //结冰状态
  int _iceCount() {
    return items.where((it) => (it.details?.state?.iceState ?? 0) == 1).length;
  }

  //加热状态
  int _heatCount() {
    return items.where((it) => (it.details?.state?.hotState1 ?? 0) == 1).length;
  }

  Widget _metricRow(String name, String value, TextStyle t1, TextStyle t2) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppScreen.adaptiveFontSize(context, 8)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: t2),
          Text(value, style: t1),
        ],
      ),
    );
  }

  Widget _statTile(String num, String path, String state) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor('#C1D8F0'),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.all(AppScreen.adaptiveFontSize(context, 12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(num,
              style: TextStyle(
                  fontSize: AppScreen.adaptiveFontSize(context, 30),
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue0C)),
          SizedBox(height: AppScreen.adaptiveFontSize(context, 8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(path.imagePath, width: 18, height: 18),
              const SizedBox(width: 4),
              Text(state,
                  style: TextStyle(
                      fontSize: AppScreen.adaptiveFontSize(context, 14))),
            ],
          ),
        ],
      ),
    );
  }
}
