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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:wind_power_system/db/app_database.dart';
import 'package:intl/intl.dart';

class ChartData {
  final DateTime time;
  final double? value1;
  final double? value2;
  final double? value3;

  ChartData(this.time, this.value1, [this.value2, this.value3]);
}

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

  List<ChartData> _chartData = [];
  bool _isLoading = false;

  late ZoomPanBehavior _zoomPanBehavior;
  late TrackballBehavior _trackballBehavior;

  // 当前可视范围的时长，用于动态调整 X 轴 Level
  Duration _visibleSpan = const Duration(days: 3);

  @override
  void initState() {
    super.initState();
    _endTime = DateTime.now();
    final now = DateTime.now();
    _startTime = DateTime(now.year, now.month, now.day - 2, 0, 0, 0);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enableMouseWheelZooming: true,
      zoomMode: ZoomMode.x,
      enablePanning: true,
    );
    _trackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(enable: true),
    );
    _loadData();
  }

  /// 加载历史数据并更新图表状态
  /// 包含跨月数据聚合、变量选择映射以及缩放行为限制的更新
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final rows = await AppDatabase.queryHistoryData(
        sn: '8888', // widget.sn 为固定 8888 测试
        startTime: _startTime,
        endTime: _endTime,
      );

      final List<ChartData> data = rows.map((row) {
        final time =
            DateTime.fromMillisecondsSinceEpoch(row['recordTime'] as int);
        double? v1, v2, v3;
        final selectedVar = _vars[_selected];
        if (selectedVar == '电流') {
          v1 = row['aI'] as double?;
          v2 = row['bI'] as double?;
          v3 = row['cI'] as double?;
        } else if (selectedVar == '冰层厚度') {
          v1 =
              _avg3(row['b1_tick_up'], row['b1_tick_mid'], row['b1_tick_down']);
          v2 =
              _avg3(row['b2_tick_up'], row['b2_tick_mid'], row['b2_tick_down']);
          v3 =
              _avg3(row['b3_tick_up'], row['b3_tick_mid'], row['b3_tick_down']);
        } else if (selectedVar == '叶片温度') {
          v1 =
              _avg3(row['b1_temp_up'], row['b1_temp_mid'], row['b1_temp_down']);
          v2 =
              _avg3(row['b2_temp_up'], row['b2_temp_mid'], row['b2_temp_down']);
          v3 =
              _avg3(row['b3_temp_up'], row['b3_temp_mid'], row['b3_temp_down']);
        } else if (selectedVar == '叶片功率') {
          v1 = row['b1_i'] != null && row['b1_v'] != null
              ? (row['b1_i'] as num).toDouble() *
                  (row['b1_v'] as num).toDouble()
              : null;
          v2 = row['b2_i'] != null && row['b2_v'] != null
              ? (row['b2_i'] as num).toDouble() *
                  (row['b2_v'] as num).toDouble()
              : null;
          v3 = row['b3_i'] != null && row['b3_v'] != null
              ? (row['b3_i'] as num).toDouble() *
                  (row['b3_v'] as num).toDouble()
              : null;
        } else if (selectedVar == '环境温度') {
          v1 = row['envTemp'] as double?;
        } else if (selectedVar == '加热功率') {
          final p1 = (row['b1_i'] != null && row['b1_v'] != null)
              ? (row['b1_i'] as num).toDouble() *
                  (row['b1_v'] as num).toDouble()
              : null;
          final p2 = (row['b2_i'] != null && row['b2_v'] != null)
              ? (row['b2_i'] as num).toDouble() *
                  (row['b2_v'] as num).toDouble()
              : null;
          final p3 = (row['b3_i'] != null && row['b3_v'] != null)
              ? (row['b3_i'] as num).toDouble() *
                  (row['b3_v'] as num).toDouble()
              : null;
          if (p1 == null && p2 == null && p3 == null) {
            v1 = null;
          } else {
            v1 = (p1 ?? 0) + (p2 ?? 0) + (p3 ?? 0);
          }
        } else if (selectedVar == '报警状态') {
          final faultFields = [
            'errorStop',
            'faultRing',
            'faultUps',
            'faultTestCom',
            'faultIavg',
            'faultContactor',
            'faultStick',
            'faultStickBlade1',
            'faultStickBlade2',
            'faultStickBlade3',
            'faultBlade1',
            'faultBlade2',
            'faultBlade3'
          ];
          bool hasFault = false;
          for (final field in faultFields) {
            if ((row[field] as num? ?? 0) != 0) {
              hasFault = true;
              break;
            }
          }
          v1 = hasFault ? 1.0 : 0.0;
        }

        return ChartData(time, v1, v2, v3);
      }).toList();

      // 更新缩放限制
      final totalSpan = _endTime.difference(_startTime);
      final minSpan = _getMinZoomSpan();
      final newZoomPan = ZoomPanBehavior(
        enablePinching: true,
        enableMouseWheelZooming: true,
        zoomMode: ZoomMode.x,
        enablePanning: true,
        maximumZoomLevel: minSpan.inMilliseconds / totalSpan.inMilliseconds,
      );

      setState(() {
        _chartData = data;
        _zoomPanBehavior = newZoomPan;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  double? _avg3(dynamic a, dynamic b, dynamic c) {
    final values = [a, b, c].whereType<num>().toList();
    if (values.isEmpty) return null;
    return values.fold<double>(0.0, (p, e) => p + e.toDouble()) / values.length;
  }

  // Y轴配置
  double get _yMin => 0;
  double get _yMax {
    final selectedVar = _vars[_selected];
    if (selectedVar == '电流') return 40;
    if (selectedVar == '冰层厚度') return 30;
    return 100;
  }

  double get _yInterval {
    final selectedVar = _vars[_selected];
    if (selectedVar == '电流') return 5;
    if (selectedVar == '冰层厚度') return 5;
    return 20;
  }

  final GlobalKey _pickerKey = GlobalKey();

  String _formatDateTime(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  /// 显示日期选择器
  /// [isStart] true 表示选择开始时间，false 表示选择结束时间
  void _showDatePicker(bool isStart) async {
    final initialDate = isStart ? _startTime : _endTime;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('zh', 'CN'),
    );

    if (pickedDate != null) {
      DateTime newDateTime;
      if (isStart) {
        // 开始时间默认设为该日的 00:00
        newDateTime = DateTime(
            pickedDate.year, pickedDate.month, pickedDate.day, 0, 0, 0);
        if (newDateTime.isBefore(_endTime)) {
          setState(() {
            _startTime = newDateTime;
          });
          _loadData();
        } else {
          AIToast.msg('开始时间必须早于结束时间');
        }
      } else {
        // 结束时间保留当前选择的小时和分钟，或者如果需要也可以设为 23:59:59
        newDateTime = DateTime(pickedDate.year, pickedDate.month,
            pickedDate.day, _endTime.hour, _endTime.minute);
        if (newDateTime.isAfter(_startTime)) {
          setState(() {
            _endTime = newDateTime;
          });
          _loadData();
        } else {
          AIToast.msg('结束时间必须晚于开始时间');
        }
      }
    }
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
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: _isLoading
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator())
                                            : _chartData.isEmpty
                                                ? const Center(
                                                    child: Text('暂无历史数据'))
                                                : _buildChart(),
                                      ),
                                    ),
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
                                          _loadData();
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
                              _loadData();
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

  /// 构建同步化的笛卡尔图表
  /// 包含 X 轴分级逻辑监听 (_visibleSpan) 以及轨道球、缩放行为绑定
  Widget _buildChart() {
    return SfCartesianChart(
      zoomPanBehavior: _zoomPanBehavior,
      trackballBehavior: _trackballBehavior,
      primaryXAxis: DateTimeAxis(
        name: 'primaryXAxis',
        dateFormat: _getDateFormat(),
        intervalType: _getIntervalType(),
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
        minorGridLines: _getMinorGridLines(),
        minorTicksPerInterval: _getMinorTicksPerInterval(),
        labelIntersectAction: AxisLabelIntersectAction.rotate45,
        interactiveTooltip: const InteractiveTooltip(
          enable: true,
          format: 'MM-dd HH:mm',
        ),
      ),
      primaryYAxis: NumericAxis(
        minimum: _yMin,
        maximum: _yMax,
        interval: _yInterval,
        majorGridLines: const MajorGridLines(width: 0.5, color: Colors.grey),
      ),
      series: _getSeries(),
      onTrackballPositionChanging: (TrackballArgs args) {
        final selectedVar = _vars[_selected];
        String unit = '';
        if (selectedVar == '冰层厚度') {
          unit = ' mm';
        } else if (selectedVar == '叶片温度') {
          unit = ' 度';
        } else if (selectedVar == '叶片功率') {
          unit = ' W';
        }

        // 使用 chartPointInfoList 获取所有点的信息 (Syncfusion v21+ 的标准写法)
        // 如果版本较低，可能需要尝试不同的属性
        try {
          final List<dynamic> infoList = (args as dynamic).chartPointInfoList;
          for (var info in infoList) {
            final seriesName = info.series?.name ?? '';
            final yValue = info.yValue;
            String yValueStr;
            if (selectedVar == '报警状态') {
              yValueStr = yValue?.toInt().toString() ?? '--';
            } else {
              yValueStr = yValue?.toStringAsFixed(2) ?? '--';
            }
            info.label = '$seriesName: $yValueStr$unit';
          }
        } catch (e) {
          // 备选方案：尝试单一 chartPointInfo
          try {
            final info = (args as dynamic).chartPointInfo;
            if (info != null) {
              final seriesName = info.series?.name ?? '';
              final yValue = info.yValue;
              String yValueStr;
              if (selectedVar == '报警状态') {
                yValueStr = yValue?.toInt().toString() ?? '--';
              } else {
                yValueStr = yValue?.toStringAsFixed(2) ?? '--';
              }
              info.label = '$seriesName: $yValueStr$unit';
            }
          } catch (_) {}
        }
      },
      onActualRangeChanged: (ActualRangeChangedArgs args) {
        if (args.orientation == AxisOrientation.horizontal) {
          final visibleMin = args.visibleMin as num;
          final visibleMax = args.visibleMax as num;
          final span = DateTime.fromMillisecondsSinceEpoch(visibleMax.toInt())
              .difference(
                  DateTime.fromMillisecondsSinceEpoch(visibleMin.toInt()));

          if (span != _visibleSpan) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _visibleSpan = span;
                });
              }
            });
          }
        }
      },
    );
  }

  /// 获取当前可见范围下的次级网格线样式
  MinorGridLines _getMinorGridLines() {
    if (_visibleSpan.inHours <= 1) return const MinorGridLines(width: 0.2);
    return const MinorGridLines(width: 0);
  }

  /// 获取当前可见范围下的次级刻度数量
  int _getMinorTicksPerInterval() {
    if (_visibleSpan.inHours <= 1) return 4;
    return 0;
  }

  /// 获取当前可见范围下的时间格式化字符串
  DateFormat _getDateFormat() {
    if (_visibleSpan.inDays > 7) return DateFormat('MM-dd');
    if (_visibleSpan.inDays >= 1) return DateFormat('MM-dd HH:mm');
    return DateFormat('HH:mm');
  }

  /// 获取当前可见范围下的 X 轴间隔类型
  DateTimeIntervalType _getIntervalType() {
    if (_visibleSpan.inDays > 7) return DateTimeIntervalType.days;
    if (_visibleSpan.inDays >= 1) return DateTimeIntervalType.hours;
    return DateTimeIntervalType.minutes;
  }

  /// 获取缩放时允许的最小跨度（防止无限缩放）
  Duration _getMinZoomSpan() {
    return const Duration(minutes: 5);
  }

  /// 构建图表系列（根据 selectedVar 动态切换）
  List<LineSeries<ChartData, DateTime>> _getSeries() {
    final selectedVar = _vars[_selected];
    if (selectedVar == '电流') {
      return [
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value1,
          name: 'A相电流',
          color: const Color(0xFF1AD2B9),
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value2,
          name: 'B相电流',
          color: Colors.blue,
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value3,
          name: 'C相电流',
          color: const Color(0xFFFF6A4C),
        ),
      ];
    } else if (selectedVar == '冰层厚度') {
      return [
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value1,
          name: '1叶片冰厚',
          color: const Color(0xFF1AD2B9),
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value2,
          name: '2叶片冰厚',
          color: Colors.blue,
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value3,
          name: '3叶片冰厚',
          color: const Color(0xFFFF6A4C),
        ),
      ];
    } else if (selectedVar == '叶片温度') {
      return [
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value1,
          name: '1叶片温度',
          color: const Color(0xFF1AD2B9),
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value2,
          name: '2叶片温度',
          color: Colors.blue,
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value3,
          name: '3叶片温度',
          color: const Color(0xFFFF6A4C),
        ),
      ];
    } else if (selectedVar == '叶片功率') {
      return [
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value1,
          name: '1叶片功率',
          color: const Color(0xFF1AD2B9),
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value2,
          name: '2叶片功率',
          color: Colors.blue,
        ),
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value3,
          name: '3叶片功率',
          color: const Color(0xFFFF6A4C),
        ),
      ];
    } else {
      return [
        LineSeries<ChartData, DateTime>(
          dataSource: _chartData,
          xValueMapper: (ChartData data, _) => data.time,
          yValueMapper: (ChartData data, _) => data.value1,
          name: selectedVar,
          color: const Color(0xFF1AD2B9),
        ),
      ];
    }
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
