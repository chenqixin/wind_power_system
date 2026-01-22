///
/// home_page.dart
/// wind_power_system
/// Created by cqx on 2026/1/15.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/core/style/app_decorations.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/genernal/extension/string.dart';
import 'package:wind_power_system/genernal/extension/text.dart';

import '../content_navigator.dart';
import 'add_user_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class WindItem {
  final String name;
  final String status;
  final double power;

  WindItem(this.name, this.status, this.power);
}

class _HomePageState extends State<HomePage> {
  final List<WindItem> items = List.generate(
      28,
      (i) => WindItem(
            (1300 + i).toString(),
            i % 5 == 0 ? '报警' : '正常',
            908.0,
          ));

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
                  '1322',
                ).simpleStyle(22, AppColors.blue135, isBold: true),
                _buildHovelItem(1, '设备型号：', 'GW115/2200'),
                _buildHovelItem(0, '加热功率：', '908.00kw'),
                _buildHovelItem(1, '状态分类：：', '-'),
                _buildHovelItem(0, '叶片1平均温度：', '25.00℃'),
                _buildHovelItem(1, '叶片2平均温度：', '26.00℃'),
                _buildHovelItem(0, '叶片3平均温度：', '27.00℃'),
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
                        child: Image.asset('btn_login.png'.imagePath,
                            width: 90, height: 42),),

                      InkWell(
                        child: Image.asset('btn_register.png'.imagePath,
                            width: 90, height: 42),
                        onTap: () async {
                          final res = await showDialog(
                            context: context,
                            barrierDismissible: true,
                            builder: (_) => const AddUserDialog(),
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
                                arguments: 'sn123454',
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
                                                it.name,
                                                style: textMain,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Spacer(),
                                              Text('冰层等级', style: textSub),
                                              const SizedBox(height: 2),
                                              Text(
                                                '45',
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
                                                      'ic_right.png'.imagePath,
                                                      width: 15,
                                                      height: 15,
                                                    ),
                                                    const SizedBox(
                                                      width: 2,
                                                    ),
                                                    Text(
                                                      '电网限功率运行',
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
                                                        '960',
                                                        style: textCon,
                                                      ),
                                                      const SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        'kw',
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
                        _buildZHItem(1, '加热总功率', '150', 'KW/h'),
                        _buildZHItem(0, '平均环境温度：', '35', '℃'),
                        _buildZHItem(1, '平均冰层厚度：', '50', 'mm'),
                        _buildZHItem(0, '平均风速：', '3', 'm'),
                        _buildZHItem(1, '装机台数：', '50', '台'),
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
                                  _statTile('22', 'ic_right.png', '正常状态'),
                                  _statTile('0', 'ic_ice.png', '结冰状态'),
                                  _statTile('0', 'ic_warm.png', '加热状态'),
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
