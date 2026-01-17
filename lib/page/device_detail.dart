///
/// device_detail.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_decorations.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/string.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/content_navigator.dart';

class DeviceDetailPage extends StatefulWidget {
  final String sn;
  const DeviceDetailPage({super.key, required this.sn});

  @override
  _DeviceDetailPageState createState() => _DeviceDetailPageState();
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  final TextEditingController _fzController = TextEditingController();
  double _heatingMinutes = 10;

  Widget _title(String text) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: AppColors.blue06),
        const SizedBox(width: 12),
        Text(text).simpleStyle(16, AppColors.blue06, isBold: true),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(title).simpleStyle(14, AppColors.blue133)),
          Row(
            children: [
              Text(value).simpleStyle(16, AppColors.blue06, isBold: true),
              const SizedBox(width: 6),
              Text(unit).simpleStyle(12, HexColor('#133F72')),
            ],
          )
        ],
      ),
    );
  }

  // 叶子状态
  Widget _leafStatus(String name) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blueE9,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row (
        children: [
          SizedBox(width: 12),
          Text(name).simpleStyle(14, AppColors.blue06, isBold: true),
          SizedBox(width: 12),
          Expanded(child: Column(

            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                  child: Row(
                    children: [
                      Image.asset('ic_unselect.png'.imagePath, width: 12, height: 12),
                      const SizedBox(width: 8),
                      Text('加热状态').simpleStyle(14, HexColor('#051F34')),
                    ]
                  ),
                )
              ),
              SizedBox(height: 8),
              Container(
                  decoration: BoxDecoration(
                    color: HexColor('#C1D8F0'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    child: Row(
                        children: [
                          Text('功率：').simpleStyle(14, HexColor('#051F34')),
                          Spacer(),
                          Text('10').simpleStyle(12, AppColors.blue06, isBold: true),
                          Text('kw').simpleStyle(12, AppColors.blue133),
                        ]
                    ),
                  )
              )
            ],
          ))
        ],
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
    _fzController.text = '';
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _fzController.dispose();
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
                                                          'ic_select.png'
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
                                                          'ic_unselect.png'
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
                                      Image.asset('ic_jr.png'.imagePath,
                                          width: 20, height: 20),
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
                                                  'ic_unselect.png'.imagePath,
                                                  width: 20,
                                                  height: 20),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: () {},
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
                                                  'ic_unselect.png'.imagePath,
                                                  width: 20,
                                                  height: 20),
                                              const SizedBox(height: 8),
                                              InkWell(
                                                onTap: () {},
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
                                        Image.asset('ic_jr_kai.png'.imagePath,
                                            width: 12, height: 12),
                                        SizedBox(width: 2),
                                        Text('开').simpleStyle(
                                            12, HexColor('#051F34')),
                                      ],
                                    ),
                                    SizedBox(width: 12),
                                    Row(
                                      children: [
                                        Image.asset('ic_jr_guan.png'.imagePath,
                                            width: 12, height: 12),
                                        SizedBox(width: 2),
                                        Text('关').simpleStyle(
                                            12, HexColor('#051F34')),
                                      ],
                                    ),
                                  ]),
                              Spacer(),

                              Row(
                                children: [
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
                                        overlayShape: const RoundSliderOverlayShape(
                                            overlayRadius: 0),
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 8,
                                          disabledThumbRadius: 8,
                                          elevation: 0,
                                          pressedElevation: 0,
                                        ),
                                        valueIndicatorColor: AppColors.blue06,
                                        showValueIndicator: ShowValueIndicator.always,
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
                                ]
                              ),


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
                                Container(
                                  width: 85,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: AppColors.blue06,
                                      borderRadius: BorderRadius.circular(6)),
                                  alignment: Alignment.center,
                                  child: Text('确认').simpleStyle(
                                      14, AppColors.white,
                                      isBold: true),
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
                              '环境温度报警',
                              '测温仪温度报警',
                              '电气柜温度报警',
                              'UPS告警',
                              '23OV告警',
                              '2V/H告警',
                              '3相负载报警',
                              '未知事件',
                            ];
                            return GridView.count(
                              shrinkWrap: false,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: cross,
                              crossAxisSpacing: gap,
                              mainAxisSpacing: gap,
                              childAspectRatio: ratio,
                              children: tiles
                                  .map((t) => Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.blueE9,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Row(
                                          children: [
                                            const SizedBox(width: 12),
                                            Image.asset(
                                                'ic_jr.png'.imagePath,
                                                width: 12,
                                                height: 12),
                                            const SizedBox(width: 6),
                                            Expanded(
                                                child: Text(t).simpleStyle(
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
                  flex: 610,
                  child: Container(
                    decoration: AppDecorations.panel(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _title('加热系统数据'),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 240,
                          child: _grid3x3([
                            {'title': '环境温度', 'value': '26', 'unit': '℃'},
                            {'title': '风速', 'value': '6.75', 'unit': 'm/s'},
                            {'title': '用户量', 'value': '5436', 'unit': 'kWh'},
                            {'title': '1号叶片电流', 'value': '36', 'unit': 'A'},
                            {'title': '2号叶片电流', 'value': '12', 'unit': 'A'},
                            {'title': '3号叶片电流', 'value': '24', 'unit': 'A'},
                            {'title': '瞬时功率', 'value': '1870', 'unit': 'kW'},
                            {'title': '转速', 'value': '24', 'unit': 'A'},
                            {'title': '累计功率', 'value': '908', 'unit': 'kW'},
                          ]),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 120,
                          child: _leafStatus('1号叶片状态'),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 120,
                          child: _leafStatus('2号叶片状态'),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          flex: 120,
                          child: _leafStatus('3号叶片状态'),
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
                                    color: HexColor('#C1D8F0'),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('控制柜事件').simpleStyle(
                                          14, AppColors.blue135,
                                          isBold: true),
                                      const SizedBox(height: 8),
                                      Expanded(
                                        child: ListView(
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            Row(children: [
                                              Image.asset(
                                                  'ic_right.png'.imagePath,
                                                  width: 18,
                                                  height: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                  child: Text('主控柜异常告警')
                                                      .simpleStyle(14,
                                                          AppColors.blue133))
                                            ]),
                                            const SizedBox(height: 8),
                                            Row(children: [
                                              Image.asset(
                                                  'ic_right.png'.imagePath,
                                                  width: 18,
                                                  height: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                  child: Text('柜内230V异常')
                                                      .simpleStyle(14,
                                                          AppColors.blue133))
                                            ]),
                                            const SizedBox(height: 8),
                                            Row(children: [
                                              Image.asset(
                                                  'ic_right.png'.imagePath,
                                                  width: 18,
                                                  height: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                  child: Text('UPS告警')
                                                      .simpleStyle(14,
                                                          AppColors.blue133))
                                            ]),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 274,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _title('除冰控制柜'),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: _cabinetGrid([
                                        '加热230V作业箱',
                                        '柜内温度计',
                                        '除冰控制柜',
                                        '电源模块',
                                        '主控箱通信状态',
                                        '备用模块',
                                      ]),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 321,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _title('软件版本'),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: HexColor('#C1D8F0'),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('主控网关版本号：').simpleStyle(
                                                      14, AppColors.blue133),
                                                  Text('ZK_9527.01')
                                                      .simpleStyle(
                                                          14, AppColors.blue06,
                                                          isBold: true),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: HexColor('#C1D8F0'),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('环境上位机版本号：').simpleStyle(
                                                      14, AppColors.blue133),
                                                  Text('HW_2698.01')
                                                      .simpleStyle(
                                                          14, AppColors.blue06,
                                                          isBold: true),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: HexColor('#C1D8F0'),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text('测温系统版本号：').simpleStyle(
                                                      14, AppColors.blue133),
                                                  Text('CB_5698.01')
                                                      .simpleStyle(
                                                          14, AppColors.blue06,
                                                          isBold: true),
                                                ],
                                              ),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
