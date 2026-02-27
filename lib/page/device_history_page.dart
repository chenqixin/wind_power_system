///
/// device_history_page.dart
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
import 'package:wind_power_system/utils/mock_data_util.dart';
import 'package:wind_power_system/core/utils/custom_toast.dart';

class DeviceHistoryPage extends StatefulWidget {
  final String sn;
  const DeviceHistoryPage({super.key, required this.sn});

  @override
  _DeviceHistoryPageState createState() => _DeviceHistoryPageState();
}

class _DeviceHistoryPageState extends State<DeviceHistoryPage> {
  final List<String> _vars = [
    '电流',
    '冰层厚度',
    '叶片温度',
    '叶片功率',
    '报警状态',
    '环境温度',
    '加热功率'
  ];
  int _selected = 0;

  late DateTime _startTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _endTime = DateTime.now();
    _startTime = DateTime(_endTime.year, _endTime.month - 1, _endTime.day,
        _endTime.hour, _endTime.minute);
  }

  final GlobalKey _pickerKey = GlobalKey();

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  void _showDatePicker(bool isStart) async {
    final RenderBox? renderBox =
        _pickerKey.currentContext?.findRenderObject() as RenderBox?;
    final Offset offset = renderBox?.localToGlobal(Offset.zero) ?? Offset.zero;
    final Size size = renderBox?.size ?? Size.zero;
    final double screenHeight = MediaQuery.of(context).size.height;

    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              left: offset.dx,
              bottom: screenHeight - offset.dy + 10, // 底部在选择器上方，留出10像素间距
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isStart ? '选择开始日期' : '选择结束日期')
                          .simpleStyle(16, AppColors.blue133),
                      const Divider(),
                      Localizations.override(
                        context: context,
                        locale: const Locale('zh', 'CN'),
                        child: CalendarDatePicker(
                          initialDate: isStart ? _startTime : _endTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                          onDateChanged: (date) {
                            DateTime newDateTime;
                            if (isStart) {
                              newDateTime = DateTime(date.year, date.month,
                                  date.day, _startTime.hour, _startTime.minute);
                              if (newDateTime.isBefore(_endTime)) {
                                setState(() {
                                  _startTime = newDateTime;
                                });
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('开始时间必须早于结束时间')),
                                );
                              }
                            } else {
                              newDateTime = DateTime(date.year, date.month,
                                  date.day, _endTime.hour, _endTime.minute);
                              if (newDateTime.isAfter(_startTime)) {
                                setState(() {
                                  _endTime = newDateTime;
                                });
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('结束时间必须晚于开始时间')),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
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
                'ic_history_image.png'.imagePath,
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
                child: Column(
                  children: [
                    Expanded(
                      flex: 603,
                      child: Container(
                        decoration: AppDecorations.panel(),
                        padding: EdgeInsets.zero,
                        child: SizedBox.expand(
                          child: Column(children: [
                            //历史记录
                            Expanded(
                                flex: 1,
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        if (_vars[_selected] == '电流') ...[
                                          _xItem('ic_yg.png', 'A相电流'),
                                          //红
                                          _xItem('ic_yz.png', 'B相电流'),
                                          //青
                                          _xItem('ic_yj.png', 'C相电流'),
                                        ] else if (_vars[_selected] ==
                                            '冰层厚度') ...[
                                          _xItem('ic_yg.png', '1叶片冰层厚度'),
                                          //红
                                          _xItem('ic_yz.png', '2叶片冰层厚度'),
                                          //青
                                          _xItem('ic_yj.png', '3叶片冰层厚度'),
                                        ] else if (_vars[_selected] ==
                                            '叶片温度') ...[
                                          _xItem('ic_yg.png', '1叶片温度'),
                                          //红
                                          _xItem('ic_yz.png', '2叶片温度'),
                                          //青
                                          _xItem('ic_yj.png', '3叶片温度'),
                                        ] else if (_vars[_selected] ==
                                            '叶片功率') ...[
                                          _xItem('ic_yg.png', '1叶片功率'),
                                          //红
                                          _xItem('ic_yz.png', '2叶片功率'),
                                          //青
                                          _xItem('ic_yj.png', '3叶片功率'),
                                        ] else if (_vars[_selected] ==
                                            '报警状态') ...[
                                          _xItem('ic_yg.png', '报警状态'),
                                        ] else if (_vars[_selected] ==
                                            '加热功率') ...[
                                          _xItem('ic_yg.png', '加热功率'),
                                        ] else if (_vars[_selected] ==
                                            '环境温度') ...[
                                          _xItem('ic_yg.png', '环境温度'),
                                        ]
                                      ],
                                    ),

                                    //根据时间 从数据库中获取曲线图



                                  ],
                                )),
                            // 时间选择
                            Container(
                              key: _pickerKey,
                              height: 48,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: HexColor('#F4F7F9'),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Text('开始时间：')
                                      .simpleStyle(14, AppColors.blue133),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _showDatePicker(true),
                                    child: Text(_formatDateTime(_startTime))
                                        .simpleStyle(14,
                                            AppColors.blue133.withOpacity(0.6)),
                                  ),
                                  const Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('-'),
                                  ),
                                  Text('结束时间：')
                                      .simpleStyle(14, AppColors.blue133),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => _showDatePicker(false),
                                    child: Text(_formatDateTime(_endTime))
                                        .simpleStyle(14,
                                            AppColors.blue133.withOpacity(0.6)),
                                  ),
                                  const Spacer(),
                                  ElevatedButton(
                                    onPressed: () async {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                      try {
                                        await MockDataUtil
                                            .generateMockHistoryData();
                                        if (context.mounted) {
                                          AIToast.msg('生成成功');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          AIToast.msg('生成失败');
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(88, 42),
                                    ),
                                    child: const Text('模拟数据',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      // TODO: 分析逻辑
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: HexColor('#009BB4'),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      minimumSize: const Size(88, 42),
                                    ),
                                    child: const Text('分析',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: List.generate(_vars.length, (i) {
                        final checked = _selected == i;
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selected = i;
                              });
                            },
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.blueE9,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              margin: EdgeInsets.only(
                                  right: i == _vars.length - 1 ? 0 : 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_vars[i])
                                      .simpleStyle(12, AppColors.blue133),
                                  const SizedBox(width: 12),
                                  Image.asset(
                                    (checked
                                            ? 'ic_tj_select.png'
                                            : 'ic_tj_unselect.png')
                                        .imagePath,
                                    width: 18,
                                    height: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
          ])
        ]),
      ),
    );
  }

  //  1:'ic_yg.png',2:ic_yz.png, 3 ic_yj.png
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
}
