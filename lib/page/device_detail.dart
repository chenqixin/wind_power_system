///
/// device_detail.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_decorations.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/string.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/content_navigator.dart';
import 'package:dash_painter/dash_painter.dart';
import 'package:wind_power_system/network/http/api_util.dart';
import 'package:wind_power_system/model/DeviceDetailData.dart' as model;
import 'package:wind_power_system/core/utils/power_utils.dart';
import 'package:wind_power_system/view/notice_dialog.dart';

class DeviceDetailPage extends StatefulWidget {
  final String sn;
  const DeviceDetailPage({super.key, required this.sn});

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _fzController = TextEditingController();
  double _heatingMinutes = 10;
  bool _heatingMinutesInitialized = false;
  bool _iSetInitialized = false;
  model.DeviceDetailData? detail;
  Timer? _pollTimer;
  late AnimationController _blinkController;
  late Animation<double> _opacityAnim;

  //故障
  bool _faultOn(int index) {
    final f = detail?.fault;
    if (f == null) return false;
    switch (index) {
      case 0:
        return (f.faultRing ?? 0) == 1;
      case 1:
        return (f.faultUps ?? 0) == 1;
      case 2:
        return (f.faultTestCom ?? 0) == 1;
      case 3:
        return (f.faultBlade1 ?? 0) == 1;
      case 4:
        return (f.faultIavg ?? 0) == 1;
      case 5:
        return (f.faultBlade2 ?? 0) == 1;
      case 6:
        return (f.faultStick ?? 0) == 1;
      case 7:
        return (f.faultBlade3 ?? 0) == 1;
      default:
        return false;
    }
  }

  Widget _title(String text) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.blue06),
        const SizedBox(width: 12),
        Text(text).simpleStyle(16, AppColors.blue06, isBold: true),
      ],
    );
  }

  //请求数据
  void getSNDetail(String sn) {
    Api.getDeviceDetailTcp(
      sn: sn,
      successCallback: (data) {
        final d = model.DeviceDetailData.fromJson(data);
        if (!mounted) return;
        setState(() {
          detail = d;
          if (!_heatingMinutesInitialized) {
            final ctrl = (d.state?.ctrlMode ?? 0) == 1;
            final time = (d.state?.hotTime ?? 0).toDouble();
            _heatingMinutes = ctrl ? time : 0.0;
            _heatingMinutesInitialized = true;
          }
          if (!_iSetInitialized) {
            _fzController.text = (d.state?.iSet)?.toString() ?? '';
            _iSetInitialized = true;
          }
        });
      },
      failCallback: (code, msg) {},
    );
  }

  Widget _metricItem(String title, String value, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: HexColor('#C1D8F0'),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: EdgeInsets.all(AppScreen.adaptiveFontSize(context, 12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: AppScreen.adaptiveFontSize(context, 30),
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue0C)),
          SizedBox(height: AppScreen.adaptiveFontSize(context, 6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title).simpleStyle(14, AppColors.blue133),
              const SizedBox(width: 4),
              Text(unit).simpleStyle(12, HexColor('#133F72')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _grid3x3(List<Map<String, String>> items) {
    return LayoutBuilder(builder: (context, cons) {
      const cross = 3;
      const rows = 3;
      const gap = 4.0;
      final itemW = (cons.maxWidth - gap * (cross - 1)) / cross;
      final itemH = (cons.maxHeight - gap * (rows - 1)) / rows;
      final ratio = itemW / itemH;
      return GridView.count(
        shrinkWrap: false,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cross,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: ratio,
        children: items
            .map((e) => _metricBar(e['title']!, e['value']!, e['unit']!))
            .toList(),
      );
    });
  }

  Widget _metricBar(String title, String value, String unit) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blueE9,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(title).simpleStyle(12, AppColors.blue133)),
          Row(
            children: [
              Text(value).simpleStyle(13, AppColors.blue06, isBold: true),
              const SizedBox(width: 6),
              Text(unit).simpleStyle(12, HexColor('#133F72')),
            ],
          )
        ],
      ),
    );
  }

  //得出电流
  String _bladeCurrent(int blade) {
    final w = detail?.winddata;
    num? i;
    switch (blade) {
      case 1:
        i = w?.blade1?.windI;
        break;
      case 2:
        i = w?.blade2?.windI;
        break;
      case 3:
        i = w?.blade3?.windI;
        break;
      default:
        i = null;
    }
    return i == null ? '-' : i.toString();
  }

  // 叶子状态
  Widget _leafStatus(String name, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blueE9,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(width: 12),
            Text(name).simpleStyle(14, AppColors.blue06, isBold: true),
            SizedBox(width: 12),
            Expanded(
              flex: 180,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10.0),
                          child: Row(children: [
                            Image.asset((() {
                              final s = detail?.state;
                              final on = (s?.hotState4 ?? 0) == 1;
                              return on
                                  ? 'ic_jr.png'.imagePath
                                  : 'ic_jr_kai.png'.imagePath;
                            })(), width: 12, height: 12),
                            const SizedBox(width: 8),
                            Text('加热状态').simpleStyle(14, HexColor('#051F34')),
                          ]),
                        )),
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          color: HexColor('#C1D8F0'),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 10.0),
                          child: Row(children: [
                            Text('功率：').simpleStyle(14, HexColor('#051F34')),
                            Spacer(),
                            Text(bladePowerValueUnit(
                                        detail?.winddata, index + 1)
                                    .value)
                                .simpleStyle(12, AppColors.blue06,
                                    isBold: true),
                            Text(bladePowerValueUnit(
                                        detail?.winddata, index + 1)
                                    .unit)
                                .simpleStyle(12, AppColors.blue133),
                          ]),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            _buildLeafItem(index, 1),
            SizedBox(width: 12),
            _buildLeafItem(index, 2),
            SizedBox(width: 12),
            _buildLeafItem(index, 3),
            SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Expanded _buildLeafItem(int bladeIndex, int partIndex) {
    return Expanded(
        flex: 270,
        child: Container(
          height: double.maxFinite,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(children: [
            Container(
              height: double.maxFinite,
              decoration: BoxDecoration(
                color: HexColor('#DDEAF7'),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4),
                    bottomLeft: Radius.circular(4)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                child: Text(partIndex == 1
                        ? '叶\n根'
                        : partIndex == 2
                            ? '叶\n中'
                            : '叶\n尖')
                    .simpleStyle(12, HexColor('#051F34')),
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('温  度：').simpleStyle(11, HexColor('#051F34')),
                        Spacer(),
                        Text(_partTempValue(bladeIndex, partIndex))
                            .simpleStyle(11, AppColors.blue06, isBold: true),
                        Text('℃').simpleStyle(12, HexColor('#133F72')),
                      ],
                    ),
                  ),
                  //虚线

                  _buildLine(),

                  Expanded(
                    child: Row(
                      children: [
                        Text('厚度等级：').simpleStyle(11, HexColor('#051F34')),
                        Spacer(),
                        Text(_partTickValue(bladeIndex, partIndex))
                            .simpleStyle(11, AppColors.blue06, isBold: true),
                      ],
                    ),
                  ),
                  _buildLine(),
                  Expanded(
                    child: Row(
                      children: [
                        Text('运动状态：').simpleStyle(11, HexColor('#051F34')),
                        Spacer(),
                        Image.asset(
                            (_partRunOn(bladeIndex, partIndex)
                                    ? 'ic_jr.png'
                                    : 'ic_jr_guan.png')
                                .imagePath,
                            width: 12,
                            height: 12),
                      ],
                    ),
                  )
                ],
              ),
            ))
          ]),
        ));
  }

  String _partTempValue(int bladeIndex, int partIndex) {
    final b = _bladeByIndex(bladeIndex);
    if (b == null) return '-';
    switch (partIndex) {
      case 1:
        return (b.tempDown)?.toString() ?? '-';
      case 2:
        return (b.tempMid)?.toString() ?? '-';
      case 3:
        return (b.tempUp)?.toString() ?? '-';
      default:
        return '-';
    }
  }

  String _partTickValue(int bladeIndex, int partIndex) {
    final b = _bladeByIndex(bladeIndex);
    if (b == null) return '-';
    switch (partIndex) {
      case 1:
        return (b.tickDown)?.toString() ?? '-';
      case 2:
        return (b.tickMid)?.toString() ?? '-';
      case 3:
        return (b.tickUp)?.toString() ?? '-';
      default:
        return '-';
    }
  }

  bool _partRunOn(int bladeIndex, int partIndex) {
    final b = _bladeByIndex(bladeIndex);
    if (b == null) return false;
    switch (partIndex) {
      case 1:
        return (b.runDown ?? 0) == 1;
      case 2:
        return (b.runMid ?? 0) == 1;
      case 3:
        return (b.runUp ?? 0) == 1;
      default:
        return false;
    }
  }

  dynamic _bladeByIndex(int bladeIndex) {
    final w = detail?.winddata;
    switch (bladeIndex) {
      case 0:
        return w?.blade1;
      case 1:
        return w?.blade2;
      case 2:
        return w?.blade3;
      default:
        return null;
    }
  }

  SizedBox _buildLine() {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(
        painter: _DashLinePainter(
          color: HexColor('#C1D8F0'),
          strokeWidth: 1,
          step: 3,
          span: 1,
        ),
      ),
    );
  }

  Widget _heatingStateCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blueE9,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.radio_button_checked,
                  size: 18, color: Colors.grey[400]),
              const SizedBox(width: 6),
              Text('加热状态').simpleStyle(14, AppColors.blue133),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text('功率：').simpleStyle(14, AppColors.blue133),
              Text('10').simpleStyle(16, AppColors.blue06, isBold: true),
              const SizedBox(width: 4),
              Text('KW').simpleStyle(12, HexColor('#133F72')),
            ],
          )
        ],
      ),
    );
  }

  Widget _leafGroup(String tag) {
    return Row(
      children: [
        _leafTag(tag),
        const SizedBox(width: 8),
        Expanded(child: _leafInfoCard()),
      ],
    );
  }

  Widget _leafTag(String text) {
    return Container(
      width: 52,
      decoration: BoxDecoration(
        color: HexColor('#CFE2F6'),
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      alignment: Alignment.center,
      child: Text(text).simpleStyle(14, AppColors.blue133),
    );
  }

  Widget _leafInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
              color: Color(0x330B2750), offset: Offset(0, 1), blurRadius: 4),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('温    度：').simpleStyle(14, AppColors.blue133),
              Text('26').simpleStyle(16, AppColors.blue06, isBold: true),
              const SizedBox(width: 4),
              Text('℃').simpleStyle(12, HexColor('#133F72')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text('厚度等级：').simpleStyle(14, AppColors.blue133)),
              Text('5').simpleStyle(14, AppColors.blue06, isBold: true),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(child: Text('运动状态：').simpleStyle(14, AppColors.blue133)),
              Icon(Icons.circle, size: 10, color: Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cabinetGrid(List<String> titles) {
    return LayoutBuilder(builder: (context, cons) {
      const cross = 3;
      const rows = 2;
      const gap = 12.0;
      final itemW = (cons.maxWidth - gap * (cross - 1)) / cross;
      final itemH = (cons.maxHeight - gap * (rows - 1)) / rows;
      final ratio = itemW / itemH;
      return GridView.count(
        shrinkWrap: false,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: cross,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
        childAspectRatio: ratio,
        children: titles
            .map((t) => Container(
                  decoration: BoxDecoration(
                    color: HexColor('#C1D8F0'),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.centerLeft,
                  padding:
                      EdgeInsets.all(AppScreen.adaptiveFontSize(context, 12)),
                  child: Row(
                    children: [
                      Image.asset('ic_right.png'.imagePath,
                          width: 18, height: 18),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(t).simpleStyle(14, AppColors.blue133)),
                    ],
                  ),
                ))
            .toList(),
      );
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getSNDetail(widget.sn);
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      getSNDetail(widget.sn);
    });
    _fzController.text = '';
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _opacityAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fzController.dispose();
    _pollTimer?.cancel();
    _blinkController.dispose();
  }

  bool _controlOn(String title) {
    final s = detail?.state;
    switch (title) {
      case '柜内加热电源':
        return (s?.envHot ?? 0) == 1;
      case '急停按钮':
        return (s?.errorStop ?? 0) == 1;
      case '远程模式':
        return (s?.ctrlMode ?? 0) == 1;
      case '主接触器控制电源':
        return (s?.hotAll ?? 0) == 1;
      case '机舱230V断路器':
        return false;
      default:
        return false;
    }
  }

  // 提交加热设置
  Future<void> _submitHeatingSettings({
    required bool heatingOn,
    int? hotTime,
    num? iSet,
  }) async {
    if (heatingOn) {
      if (hotTime == null || hotTime <= 0 || iSet == null || iSet <= 0) {
        await AppNotice.show(title: '提示', content: '加热时长与阈值必须大于0');
        return;
      }
    }

    await Api.submitManualHeatingTcp(
      sn: widget.sn,
      heatingOn: heatingOn,
      hotTime: hotTime,
      iSet: iSet,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textMain = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 18),
      color: AppColors.blue135,
      fontWeight: FontWeight.w600,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Expanded(
            flex: 625,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    offset: const Offset(0, 12),
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
                              .pushNamedAndRemoveUntil(
                                  '/home', (route) => false);
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
                    child: Image.asset('btn_jm.png'.imagePath,
                        width: 90, height: 42),
                  ),
                ),
                Expanded(
                  flex: 250,
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('控制台'),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('设备编号：00009527')
                                        .simpleStyle(13, AppColors.blue133),
                                    SizedBox(height: 8),
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: AppColors.blueE9,
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text('除冰状态').simpleStyle(
                                                14, AppColors.blue133,
                                                isBold: true),
                                            const SizedBox(height: 20),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                          ((detail?.state?.ctrlMode ??
                                                                          0) ==
                                                                      1
                                                                  ? 'ic_select.png'
                                                                  : 'ic_unselect.png')
                                                              .imagePath,
                                                          width: 20,
                                                          height: 20),
                                                      SizedBox(width: 10),
                                                      Text('手动').simpleStyle(14,
                                                          HexColor('#051F34')),
                                                    ],
                                                  ),
                                                  Row(
                                                    children: [
                                                      Image.asset(
                                                          ((detail?.state?.ctrlMode ??
                                                                          0) ==
                                                                      0
                                                                  ? 'ic_select.png'
                                                                  : 'ic_unselect.png')
                                                              .imagePath,
                                                          width: 20,
                                                          height: 20),
                                                      SizedBox(width: 10),
                                                      Text('自动').simpleStyle(14,
                                                          HexColor('#051F34')),
                                                    ],
                                                  )
                                                ]),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      (((detail?.state?.iceState) ?? 0) == 1)
                                          ? FadeTransition(
                                              opacity: _opacityAnim,
                                              child: Image.asset(
                                                  'ic_jr.png'.imagePath,
                                                  width: 20,
                                                  height: 20),
                                            )
                                          : Image.asset(
                                              'ic_jr_guan.png'.imagePath,
                                              width: 20,
                                              height: 20),
                                      SizedBox(height: 8),
                                      Text('加热状态').simpleStyle(
                                          13, AppColors.blue133,
                                          isBold: true),
                                      SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Column(
                                            children: [
                                              Image.asset(
                                                  ((detail?.state?.errorStop ??
                                                                  0) ==
                                                              1
                                                          ? 'ic_select.png'
                                                          : 'ic_unselect.png')
                                                      .imagePath,
                                                  width: 20,
                                                  height: 20),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: () async {
                                                  await Api.emergencyStopTcp(
                                                      sn: widget.sn);
                                                  //getSNDetail(widget.sn);
                                                },
                                                child: Container(
                                                  width: 85,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      color: AppColors.blue06,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  alignment: Alignment.center,
                                                  child: Text('急停').simpleStyle(
                                                      14, AppColors.white,
                                                      isBold: true),
                                                ),
                                              )
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                  ((detail?.state?.restFlag ??
                                                                  0) ==
                                                              1
                                                          ? 'ic_select.png'
                                                          : 'ic_unselect.png')
                                                      .imagePath,
                                                  width: 20,
                                                  height: 20),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: () async {
                                                  await Api.resetTcp(
                                                      sn: widget.sn);
                                                },
                                                child: Container(
                                                  width: 85,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                      color: AppColors.blue06,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              6)),
                                                  alignment: Alignment.center,
                                                  child: Text('复位').simpleStyle(
                                                      14, AppColors.white,
                                                      isBold: true),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  flex: 308,
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('手动除冰参数设置'),
                        const SizedBox(height: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('加热开关').simpleStyle(
                                        14, AppColors.blue133,
                                        isBold: true),
                                    const SizedBox(width: 18),
                                    Row(
                                      children: [
                                        Image.asset(
                                            (((detail?.state?.ctrlMode ?? 0) ==
                                                            1) &&
                                                        ((detail?.state
                                                                    ?.hotState4 ??
                                                                0) ==
                                                            1)
                                                    ? 'ic_jr_kai.png'
                                                    : 'ic_jr_guan.png')
                                                .imagePath,
                                            width: 12,
                                            height: 12),
                                        SizedBox(width: 2),
                                        Text('开').simpleStyle(
                                            12, HexColor('#051F34')),
                                      ],
                                    ),
                                    SizedBox(width: 12),
                                    Row(
                                      children: [
                                        Image.asset(
                                            (((detail?.state?.ctrlMode ?? 0) ==
                                                            1) &&
                                                        ((detail?.state
                                                                    ?.hotState4 ??
                                                                0) ==
                                                            1)
                                                    ? 'ic_jr_guan.png'
                                                    : 'ic_jr_kai.png')
                                                .imagePath,
                                            width: 12,
                                            height: 12),
                                        SizedBox(width: 2),
                                        Text('关').simpleStyle(
                                            12, HexColor('#051F34')),
                                      ],
                                    ),
                                  ]),
                              Spacer(),
                              Row(children: [
                                Text('加热时常').simpleStyle(14, AppColors.blue133,
                                    isBold: true),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      activeTrackColor: AppColors.blue06,
                                      inactiveTrackColor: HexColor('#D9E5F2'),
                                      thumbColor: AppColors.blue06,
                                      overlayColor: Colors.transparent,
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 0),
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8,
                                        disabledThumbRadius: 8,
                                        elevation: 0,
                                        pressedElevation: 0,
                                      ),
                                      valueIndicatorColor: AppColors.blue06,
                                      showValueIndicator:
                                          ShowValueIndicator.always,
                                    ),
                                    child: Slider(
                                      value: _heatingMinutes,
                                      min: 0,
                                      max: 180,
                                      divisions: 180,
                                      label: '${_heatingMinutes.round()}分',
                                      onChanged: (v) {
                                        setState(() {
                                          _heatingMinutes = v;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ]),
                              Spacer(),
                              Text('不平衡电流阈值').simpleStyle(14, AppColors.blue133,
                                  isBold: true),
                              const SizedBox(height: 10),
                              Row(children: [
                                Expanded(
                                  child: TextField(
                                    controller: _fzController,
                                    keyboardType: TextInputType.number,
                                    maxLines: 1,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      counterText: '',
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 13),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        borderSide: BorderSide(
                                            color: HexColor('#E2E8F2'),
                                            width: 1),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        borderSide: BorderSide(
                                            color: HexColor('#E2E8F2'),
                                            width: 1),
                                      ),

                                      //,
                                      hintText: '请输入阈值参数',
                                      hintStyle: TextStyle(
                                        color: HexColor('#888888'),
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.normal,
                                      color: AppColors.blue133,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 22),
                                InkWell(
                                  onTap: () async {
                                    final heatingOn =
                                        ((detail?.state?.ctrlMode ?? 0) == 1) &&
                                            ((detail?.state?.hotState4 ?? 0) ==
                                                1);
                                    final hotTime = _heatingMinutes.round();
                                    final text = _fzController.text.trim();
                                    final iSet = text.isEmpty
                                        ? null
                                        : num.tryParse(text);
                                    await _submitHeatingSettings(
                                      heatingOn: heatingOn,
                                      hotTime: hotTime,
                                      iSet: iSet,
                                    );
                                  },
                                  child: Container(
                                    width: 85,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        color: AppColors.blue06,
                                        borderRadius: BorderRadius.circular(6)),
                                    alignment: Alignment.center,
                                    child: Text('确认').simpleStyle(
                                        14, AppColors.white,
                                        isBold: true),
                                  ),
                                )
                              ])
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  flex: 300,
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('故障状态'),
                        const SizedBox(height: 12),
                        Expanded(
                          child: LayoutBuilder(builder: (context, cons) {
                            const cross = 2;
                            const rows = 4;
                            const gap = 8.0;
                            final itemW =
                                (cons.maxWidth - gap * (cross - 1)) / cross;
                            final itemH =
                                (cons.maxHeight - gap * (rows - 1)) / rows;
                            final ratio = itemW / itemH;
                            final tiles = [
                              '环网通讯故障',
                              'UPS电源',
                              '测冰设备通讯故障',
                              '1#叶片电源故障',
                              '电流均值故障',
                              '2#叶片电源故障',
                              '接触器粘连故障',
                              '3#叶片电源故障',
                            ];
                            return GridView.count(
                              shrinkWrap: false,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: cross,
                              crossAxisSpacing: gap,
                              mainAxisSpacing: gap,
                              childAspectRatio: ratio,
                              children: tiles
                                  .asMap()
                                  .entries
                                  .map((e) => Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.blueE9,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 12),
                                            Image.asset(
                                                (_faultOn(e.key)
                                                        ? 'ic_jr.png'
                                                        : 'ic_jr_guan.png')
                                                    .imagePath,
                                                width: 12,
                                                height: 12),
                                            const SizedBox(width: 6),
                                            Expanded(
                                                child: Text(e.value)
                                                    .simpleStyle(
                                                        10, AppColors.blue133)),
                                          ],
                                        ),
                                      ))
                                  .toList(),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 1235,
            child: Column(
              children: [
                Expanded(
                  flex: 660,
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('加热系统数据'),
                        const SizedBox(height: 8),
                        Expanded(
                          flex: 150,
                          child: _grid3x3([
                            {
                              'title': '环境温度',
                              'value':
                                  (detail?.state?.envTemp)?.toString() ?? '-',
                              'unit': '℃'
                            },
                            {
                              'title': '风速',
                              'value':
                                  (detail?.state?.windSpeed)?.toString() ?? '-',
                              'unit': 'm/s'
                            },
                            {'title': '用电量', 'value': '-', 'unit': 'kWh'},
                            {
                              'title': '1号叶片电流',
                              'value': _bladeCurrent(1),
                              'unit': 'A'
                            },
                            {
                              'title': '2号叶片电流',
                              'value': _bladeCurrent(2),
                              'unit': 'A'
                            },
                            {
                              'title': '3号叶片电流',
                              'value': _bladeCurrent(3),
                              'unit': 'A'
                            },
                            {
                              'title': '瞬时功率',
                              'value': powerValueUnit(detail).value,
                              'unit': powerValueUnit(detail).unit
                            },
                            {
                              'title': '转速',
                              'value':
                                  (detail?.state?.rotorSpeed)?.toString() ??
                                      '-',
                              'unit': 'A'
                            },
                            {'title': '累计功率', 'value': '-', 'unit': 'kW'},
                          ]),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          flex: 140,
                          child: _leafStatus('1号叶片状态', 0),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 140,
                          child: _leafStatus('2号叶片状态', 1),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 140,
                          child: _leafStatus('3号叶片状态', 2),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  flex: 330,
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('控制系统数据'),
                        const SizedBox(height: 12),
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 560,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9F4FF'),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('————  除冰控制柜  ———').simpleStyle(
                                            13,
                                            AppColors.blue06,
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: LayoutBuilder(
                                                builder: (context, cons) {
                                              const cross = 2;
                                              const rows = 3;
                                              const gap = 8.0;
                                              final itemW = (cons.maxWidth -
                                                      gap * (cross - 1)) /
                                                  cross;
                                              final itemH = (cons.maxHeight -
                                                      gap * (rows - 1)) /
                                                  rows;
                                              final ratio = itemW / itemH;
                                              final tiles = [
                                                '柜内加热电源',
                                                '急停按钮',
                                                '远程模式',
                                                '主接触器控制电源',
                                                '机舱230V断路器'
                                              ];
                                              return GridView.count(
                                                shrinkWrap: false,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                crossAxisCount: cross,
                                                crossAxisSpacing: gap,
                                                mainAxisSpacing: gap,
                                                childAspectRatio: ratio,
                                                children: tiles
                                                    .map((t) => Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: HexColor(
                                                                '#C1D8F0'),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              const SizedBox(
                                                                  width: 12),
                                                              Image.asset(
                                                                  (_controlOn(t)
                                                                          ? 'ic_green_cicle.png'
                                                                          : 'ic_jr_guan.png')
                                                                      .imagePath,
                                                                  width: 12,
                                                                  height: 12),
                                                              const SizedBox(
                                                                  width: 6),
                                                              Expanded(
                                                                  child: Text(t)
                                                                      .simpleStyle(
                                                                          10,
                                                                          AppColors
                                                                              .blue133)),
                                                            ],
                                                          ),
                                                        ))
                                                    .toList(),
                                              );
                                            }),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 274,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9F4FF'),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('— 除冰控制柜 —').simpleStyle(
                                            13,
                                            AppColors.blue06,
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: HexColor('#C1D8F0'),
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text((detail?.state?.envTemp)
                                                              ?.toString() ??
                                                          '-')
                                                      .simpleStyle(
                                                    35,
                                                    AppColors.blue06,
                                                    isBold: true,
                                                  ),
                                                  Text('℃').simpleStyle(
                                                    15,
                                                    HexColor('#051F34'),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 321,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: HexColor('#E9F4FF'),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text('— 软件版本 —').simpleStyle(
                                            13,
                                            AppColors.blue06,
                                          ),
                                          const SizedBox(height: 8),
                                          Expanded(
                                            child: LayoutBuilder(
                                                builder: (context, cons) {
                                              const cross = 1;
                                              const rows = 3;
                                              const gap = 8.0;
                                              final itemW = (cons.maxWidth -
                                                      gap * (cross - 1)) /
                                                  cross;
                                              final itemH = (cons.maxHeight -
                                                      gap * (rows - 1)) /
                                                  rows;
                                              final ratio = itemW / itemH;
                                              final tiles = [
                                                '主控程序版本号：',
                                                '环网上位机版本号：',
                                                '测冰系统版本号：',
                                              ];
                                              return GridView.count(
                                                shrinkWrap: false,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                crossAxisCount: cross,
                                                crossAxisSpacing: gap,
                                                mainAxisSpacing: gap,
                                                childAspectRatio: ratio,
                                                children: tiles
                                                    .map((t) => Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: HexColor(
                                                                '#C1D8F0'),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        3),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        8),
                                                            child: Row(
                                                              children: [
                                                                Text(t).simpleStyle(
                                                                    10,
                                                                    AppColors
                                                                        .blue133),
                                                                Spacer(),
                                                                Text(tiles.indexOf(t) ==
                                                                            1
                                                                        ? 'ZK_95'
                                                                        : 'ZK_9527_01')
                                                                    .simpleStyle(
                                                                        10,
                                                                        AppColors
                                                                            .blue133),
                                                              ],
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                              );
                                            }),
                                          )
                                        ],
                                      )),
                                ),
                              ),
                            ],
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
}

class _DashLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double step;
  final double span;

  const _DashLinePainter({
    required this.color,
    required this.strokeWidth,
    required this.step,
    required this.span,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0);
    DashPainter(span: span, step: step).paint(canvas, path, paint);
  }

  @override
  bool shouldRepaint(covariant _DashLinePainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.step != step ||
        oldDelegate.span != span;
  }
}
