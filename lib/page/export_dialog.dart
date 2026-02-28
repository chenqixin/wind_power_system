///
/// export_dialog.dart
/// wind_power_system
/// Created by cqx on 2026/2/28.
/// Copyright ©2026 Changjia. All rights reserved.
///
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wind_power_system/core/style/app_colors.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';
import 'package:wind_power_system/genernal/extension/string.dart';
import 'package:wind_power_system/genernal/extension/text.dart';
import 'package:wind_power_system/core/utils/custom_toast.dart';
import 'package:intl/intl.dart';
import 'package:excel/excel.dart' as ex;
import 'package:path_provider/path_provider.dart';
import 'package:wind_power_system/db/app_database.dart';

class ExportDialog extends StatefulWidget {
  final String sn;
  const ExportDialog({super.key, required this.sn});

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  final TextEditingController _reportNameController = TextEditingController();
  late DateTime _startTime;
  late DateTime _endTime;
  String _intervalUnit = '天';
  final List<String> _intervalUnits = ['小时', '天', '分'];

  final List<String> _vars = [
    'A相电流',
    'B相电流',
    'C相电流',
    '环境温度',
    '叶片1冰层厚度+温度+功率',
    '叶片2冰层通度+温度+功率',
    '叶片3冰层厚度+温度+功率',
    '加热功率',
    '报警状态',
  ];
  final Set<String> _selectedVars = {};

  void _showMsg(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportExcel() async {
    debugPrint(
        '开始执行导出: sn=${widget.sn}, start=$_startTime, end=$_endTime, unit=$_intervalUnit');
    _showMsg('开始查询数据，请稍候...');

    try {
      final rows = await AppDatabase.queryHistoryData(
        sn: widget.sn,
        startTime: _startTime,
        endTime: _endTime,
      );
      debugPrint('查询到数据行数: ${rows.length}');

      if (rows.isEmpty) {
        _showMsg('所选时间范围内无数据');
        return;
      }
      // ... 后面逻辑保持不变

      // 聚合数据
      List<Map<String, dynamic>> aggregatedData = _aggregateData(rows);
      debugPrint('聚合后数据行数: ${aggregatedData.length}');

      // 创建 Excel
      var excel = ex.Excel.createExcel();
      var sheet = excel['Sheet1'];

      // 1. 大标题 (第一行)
      String title =
          '${_formatDateTime(_startTime)} 至 ${_formatDateTime(_endTime)}历史数据表';

      int headerCount = _calculateHeaderCount();
      debugPrint('计算表头列数: $headerCount');

      sheet.merge(
          ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0),
          ex.CellIndex.indexByColumnRow(
              columnIndex: headerCount > 0 ? headerCount - 1 : 0, rowIndex: 0));

      var titleCell = sheet
          .cell(ex.CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
      titleCell.value = ex.TextCellValue(title);
      titleCell.cellStyle = ex.CellStyle(
        fontSize: 20,
        bold: true,
        horizontalAlign: ex.HorizontalAlign.Center,
      );

      // 2. 表头 (第二行)
      _addHeaders(sheet);

      // 3. 数据行 (从第三行开始)
      _addDataRows(sheet, aggregatedData);

      // 保存文件
      String fileName = _reportNameController.text;
      if (fileName.isEmpty) fileName = '历史数据';
      if (!fileName.toLowerCase().endsWith('.xlsx')) {
        fileName += '.xlsx';
      }

      File? file;
      String? finalPath;

      // 尝试保存到用户指定的文档目录 (可能会因为沙盒权限失败)
      try {
        Directory? preferredDir;
        if (Platform.isWindows) {
          preferredDir = Directory(
              'C:/Users/${Platform.environment['USERNAME']}/Documents');
        } else if (Platform.isMacOS) {
          preferredDir =
              Directory('/Users/${Platform.environment['USER']}/Documents');
        }

        if (preferredDir != null && await preferredDir.exists()) {
          finalPath = '${preferredDir.path}/$fileName';
          file = File(finalPath);
          final bytes = excel.save();
          if (bytes != null) {
            await file.writeAsBytes(bytes);
            debugPrint('成功保存到首选目录: $finalPath');
          }
        }
      } catch (e) {
        debugPrint('保存到首选目录失败 (通常是权限问题): $e');
        file = null;
      }

      // 如果首选目录失败，保存到应用私有目录 (保证成功)
      if (file == null) {
        final appDir = await getApplicationDocumentsDirectory();
        finalPath = '${appDir.path}/$fileName';
        file = File(finalPath);
        final bytes = excel.save();
        if (bytes == null) throw Exception('Excel 数据生成失败');
        await file.writeAsBytes(bytes);
        debugPrint('成功保存到应用私有目录: $finalPath');
      }

      _showMsg('导出成功！\n路径：$finalPath');
      if (mounted) Navigator.pop(context);
    } catch (e, stackTrace) {
      debugPrint('导出失败: $e');
      debugPrint('堆栈信息: $stackTrace');
      _showMsg('导出失败: $e');
    }
  }

  int _calculateHeaderCount() {
    int count = 1; // 时间列
    for (var v in _selectedVars) {
      if (v.contains('叶片')) {
        count += 3; // 厚度 + 温度 + 功率
      } else if (v == '报警状态') {
        count += 8; // 8个特定报警
      } else {
        count += 1;
      }
    }
    return count > 0 ? count : 1;
  }

  void _addHeaders(ex.Sheet sheet) {
    int colIndex = 0;
    int rowIndex = 1;

    void addHeaderCell(String value) {
      var cell = sheet.cell(ex.CellIndex.indexByColumnRow(
          columnIndex: colIndex, rowIndex: rowIndex));
      cell.value = ex.TextCellValue(value);
      cell.cellStyle = ex.CellStyle(
        bold: true,
        horizontalAlign: ex.HorizontalAlign.Center,
        verticalAlign: ex.VerticalAlign.Center,
      );
      colIndex++;
    }

    addHeaderCell('时间');

    // 按照用户要求的顺序添加列
    for (var v in _vars) {
      if (!_selectedVars.contains(v)) continue;

      if (v == 'A相电流')
        addHeaderCell('A相电流(A)');
      else if (v == 'B相电流')
        addHeaderCell('B相电流(A)');
      else if (v == 'C相电流')
        addHeaderCell('C相电流(A)');
      else if (v == '叶片1冰层厚度+温度+功率') {
        addHeaderCell('叶片1冰层厚度(mm)');
        addHeaderCell('叶片1温度(℃)');
        addHeaderCell('叶片1功率(W)');
      } else if (v == '叶片2冰层通度+温度+功率') {
        addHeaderCell('叶片2冰层厚度(mm)');
        addHeaderCell('叶片2温度(℃)');
        addHeaderCell('叶片2功率(W)');
      } else if (v == '叶片3冰层厚度+温度+功率') {
        addHeaderCell('叶片3冰层厚度(mm)');
        addHeaderCell('叶片3温度(℃)');
        addHeaderCell('叶片3功率(W)');
      } else if (v == '报警状态') {
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
        for (var t in tiles) {
          addHeaderCell(t);
        }
      } else if (v == '环境温度') {
        addHeaderCell('环境温度(℃)');
      } else if (v == '加热功率') {
        addHeaderCell('加热功率(W)');
      }
    }
  }

  List<Map<String, dynamic>> _aggregateData(List<Map<String, dynamic>> rows) {
    if (_intervalUnit == '分') return rows;

    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var row in rows) {
      DateTime dt =
          DateTime.fromMillisecondsSinceEpoch(row['recordTime'] as int);
      String key;
      if (_intervalUnit == '天') {
        key = DateFormat('yyyy-MM-dd').format(dt);
      } else {
        // 小时
        key = DateFormat('yyyy-MM-dd HH').format(dt);
      }
      grouped.putIfAbsent(key, () => []).add(row);
    }

    List<Map<String, dynamic>> result = [];
    grouped.forEach((key, groupRows) {
      Map<String, dynamic> aggregated = {};
      // 时间取组的第一条数据的时间
      aggregated['recordTime'] = groupRows.first['recordTime'];

      // 数字字段取平均值
      List<String> numericFields = [
        'aI',
        'bI',
        'cI',
        'envTemp',
        'b1_tick_up',
        'b1_tick_mid',
        'b1_tick_down',
        'b2_tick_up',
        'b2_tick_mid',
        'b2_tick_down',
        'b3_tick_up',
        'b3_tick_mid',
        'b3_tick_down',
        'b1_temp_up',
        'b1_temp_mid',
        'b1_temp_down',
        'b2_temp_up',
        'b2_temp_mid',
        'b2_temp_down',
        'b3_temp_up',
        'b3_temp_mid',
        'b3_temp_down',
        'b1_i',
        'b1_v',
        'b2_i',
        'b2_v',
        'b3_i',
        'b3_v'
      ];

      for (var field in numericFields) {
        double sum = 0;
        int count = 0;
        for (var row in groupRows) {
          if (row[field] != null) {
            sum += (row[field] as num).toDouble();
            count++;
          }
        }
        aggregated[field] = count > 0 ? sum / count : null;
      }

      // 报警状态字段
      // 6: 如果选择天 当天有一个错误那么就输出故障 否则输出无
      List<String> faultFields = [
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

      for (var field in faultFields) {
        bool hasFault = false;
        for (var row in groupRows) {
          if ((row[field] as num? ?? 0) != 0) {
            hasFault = true;
            break;
          }
        }
        aggregated[field] = hasFault ? 1 : 0;
      }

      result.add(aggregated);
    });

    // 排序
    result.sort(
        (a, b) => (a['recordTime'] as int).compareTo(b['recordTime'] as int));
    return result;
  }

  void _addDataRows(ex.Sheet sheet, List<Map<String, dynamic>> data) {
    int rowIndex = 2;

    // 隔行填充的背景色 (使用十六进制字符串)
    final String alternateColor = "E8F5E9"; // 极浅的绿色 (Material Light Green 50)

    for (var rowData in data) {
      int colIndex = 0;
      bool isAlternate = (rowIndex % 2 == 1); // 隔行判断

      // 基础样式
      late ex.CellStyle baseStyle;
      late ex.CellStyle redStyle;

      if (isAlternate) {
        baseStyle = ex.CellStyle(
          horizontalAlign: ex.HorizontalAlign.Center,
          verticalAlign: ex.VerticalAlign.Center,
          backgroundColorHex: ex.ExcelColor.fromHexString(alternateColor),
        );
        redStyle = ex.CellStyle(
          fontColorHex: ex.ExcelColor.red,
          horizontalAlign: ex.HorizontalAlign.Center,
          verticalAlign: ex.VerticalAlign.Center,
          backgroundColorHex: ex.ExcelColor.fromHexString(alternateColor),
        );
      } else {
        baseStyle = ex.CellStyle(
          horizontalAlign: ex.HorizontalAlign.Center,
          verticalAlign: ex.VerticalAlign.Center,
        );
        redStyle = ex.CellStyle(
          fontColorHex: ex.ExcelColor.red,
          horizontalAlign: ex.HorizontalAlign.Center,
          verticalAlign: ex.VerticalAlign.Center,
        );
      }

      DateTime dt =
          DateTime.fromMillisecondsSinceEpoch(rowData['recordTime'] as int);
      String timeStr;
      if (_intervalUnit == '天') {
        timeStr = DateFormat('yyyy/MM/dd').format(dt);
      } else if (_intervalUnit == '小时') {
        timeStr = DateFormat('yyyy/MM/dd HH:00').format(dt);
      } else {
        timeStr = DateFormat('yyyy/MM/dd HH:mm:ss').format(dt);
      }

      void addCell(dynamic value, {ex.CellStyle? style}) {
        var cell = sheet.cell(ex.CellIndex.indexByColumnRow(
            columnIndex: colIndex, rowIndex: rowIndex));
        if (value is num) {
          cell.value = ex.DoubleCellValue(value.toDouble());
        } else {
          cell.value = ex.TextCellValue(value?.toString() ?? '-');
        }
        cell.cellStyle = style ?? baseStyle;
        colIndex++;
      }

      addCell(timeStr);

      for (var v in _vars) {
        if (!_selectedVars.contains(v)) continue;

        if (v == 'A相电流')
          addCell(rowData['aI'] != null
              ? double.parse(rowData['aI'].toStringAsFixed(2))
              : '-');
        else if (v == 'B相电流')
          addCell(rowData['bI'] != null
              ? double.parse(rowData['bI'].toStringAsFixed(2))
              : '-');
        else if (v == 'C相电流')
          addCell(rowData['cI'] != null
              ? double.parse(rowData['cI'].toStringAsFixed(2))
              : '-');
        else if (v == '环境温度')
          addCell(rowData['envTemp'] != null
              ? double.parse(rowData['envTemp'].toStringAsFixed(2))
              : '-');
        else if (v == '叶片1冰层厚度+温度+功率') {
          addCell(_avg3(rowData['b1_tick_up'], rowData['b1_tick_mid'],
              rowData['b1_tick_down']));
          addCell(_avg3(rowData['b1_temp_up'], rowData['b1_temp_mid'],
              rowData['b1_temp_down']));
          addCell(_power(rowData['b1_i'], rowData['b1_v']));
        } else if (v == '叶片2冰层厚度+温度+功率') {
          addCell(_avg3(rowData['b2_tick_up'], rowData['b2_tick_mid'],
              rowData['b2_tick_down']));
          addCell(_avg3(rowData['b2_temp_up'], rowData['b2_temp_mid'],
              rowData['b2_temp_down']));
          addCell(_power(rowData['b2_i'], rowData['b2_v']));
        } else if (v == '叶片3冰层厚度+温度+功率') {
          addCell(_avg3(rowData['b3_tick_up'], rowData['b3_tick_mid'],
              rowData['b3_tick_down']));
          addCell(_avg3(rowData['b3_temp_up'], rowData['b3_temp_mid'],
              rowData['b3_temp_down']));
          addCell(_power(rowData['b3_i'], rowData['b3_v']));
        } else if (v == '加热功率') {
          double p1 = _power(rowData['b1_i'], rowData['b1_v']) as double? ?? 0;
          double p2 = _power(rowData['b2_i'], rowData['b2_v']) as double? ?? 0;
          double p3 = _power(rowData['b3_i'], rowData['b3_v']) as double? ?? 0;
          addCell(double.parse((p1 + p2 + p3).toStringAsFixed(2)));
        } else if (v == '报警状态') {
          // 按照要求 8 列
          addCell((rowData['errorStop'] ?? 0) != 0 ? '故障' : '无',
              style: (rowData['errorStop'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell((rowData['faultRing'] ?? 0) != 0 ? '故障' : '无',
              style: (rowData['faultRing'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell((rowData['faultUps'] ?? 0) != 0 ? '故障' : '无',
              style: (rowData['faultUps'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell((rowData['faultTestCom'] ?? 0) != 0 ? '故障' : '无',
              style:
                  (rowData['faultTestCom'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell((rowData['faultIavg'] ?? 0) != 0 ? '故障' : '无',
              style: (rowData['faultIavg'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell((rowData['faultContactor'] ?? 0) != 0 ? '故障' : '无',
              style:
                  (rowData['faultContactor'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell((rowData['faultStick'] ?? 0) != 0 ? '故障' : '无',
              style: (rowData['faultStick'] ?? 0) != 0 ? redStyle : baseStyle);
          addCell(
              ((rowData['faultBlade1'] ?? 0) != 0 ||
                      (rowData['faultBlade2'] ?? 0) != 0 ||
                      (rowData['faultBlade3'] ?? 0) != 0)
                  ? '故障'
                  : '无',
              style: ((rowData['faultBlade1'] ?? 0) != 0 ||
                      (rowData['faultBlade2'] ?? 0) != 0 ||
                      (rowData['faultBlade3'] ?? 0) != 0)
                  ? redStyle
                  : baseStyle);
        }
      }
      rowIndex++;
    }
  }

  double? _avg3(dynamic a, dynamic b, dynamic c) {
    final values = [a, b, c].whereType<num>().toList();
    if (values.isEmpty) return null;
    return values.fold<double>(0.0, (p, e) => p + e.toDouble()) / values.length;
  }

  double? _power(dynamic i, dynamic v) {
    if (i == null || v == null) return null;
    return (i as num).toDouble() * (v as num).toDouble();
  }

  @override
  void initState() {
    super.initState();
    _endTime = DateTime.now();
    final now = DateTime.now();
    _startTime = DateTime(now.year, now.month, now.day - 7, 0, 0, 0);
    _selectedVars.add(_vars[0]); // 默认选中第一个
  }

  @override
  void dispose() {
    _reportNameController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return DateFormat('yyyy/MM/dd').format(dt);
  }

  void _showDatePicker(bool isStart) async {
    final initialDate = isStart ? _startTime : _endTime;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('zh', 'CN'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.blue06,
              onPrimary: Colors.white,
              onSurface: AppColors.blue133,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          if (pickedDate.isBefore(_endTime)) {
            _startTime = pickedDate;
          } else {
            AIToast.msg('开始时间必须早于结束时间');
          }
        } else {
          if (pickedDate.isAfter(_startTime)) {
            _endTime = pickedDate;
          } else {
            AIToast.msg('结束时间必须晚于开始时间');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: AppScreen.adaptiveFontSize(context, 16),
      color: AppColors.blue06,
      fontWeight: FontWeight.w600,
    );

    final contentStyle = const TextStyle(
      fontSize: 14,
      color: AppColors.blue133,
      fontWeight: FontWeight.w400,
    );

    final hintStyle = TextStyle(
        fontSize: 12, color: HexColor('#8A9199'), fontWeight: FontWeight.w400);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40),
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
        padding: const EdgeInsets.all(16),
        width: 650, // 稍微宽一点以容纳多选框
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 16, color: AppColors.blue06),
                const SizedBox(width: 12),
                Text('报表历史查询', style: titleStyle),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_fullscreen,
                      size: 16, color: AppColors.blue133),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: HexColor('#F4F7F9'),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 报表名称
                  _formLabel('报表名称：'),
                  const SizedBox(height: 8),
                  _inputField(
                    controller: _reportNameController,
                    hintText: '请输入报表名称',
                    hintStyle: hintStyle,
                    textStyle: contentStyle,
                  ),
                  const SizedBox(height: 16),

                  // 时间属性
                  _formLabel('时间属性：'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _timePickerBox('起始时间：', _startTime, true),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _timePickerBox('终止时间：', _endTime, false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 间隔单位
                  _formLabel('间隔单位：'),
                  const SizedBox(height: 8),
                  _dropdown(
                    value: _intervalUnit,
                    items: _intervalUnits,
                    onChanged: (val) => setState(() => _intervalUnit = val!),
                  ),
                  const SizedBox(height: 16),

                  // 变量选择
                  _formLabel('变量选择：'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: _vars.map((v) => _variableCheckbox(v)).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                _actionButton('确定', HexColor('#0696BD'), HexColor('#F8FCFF'),
                    () async {
                  if (_reportNameController.text.isEmpty) {
                    AIToast.msg('请输入报表名称');
                    return;
                  }
                  if (_selectedVars.isEmpty) {
                    AIToast.msg('请选择要导出的变量');
                    return;
                  }
                  await _exportExcel();
                }),
                const SizedBox(width: 12),
                _actionButton('取消', HexColor('#CADBEB'), HexColor('#424A4D'),
                    () {
                  Navigator.pop(context);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _formLabel(String label) {
    return Text(label).simpleStyle(14, AppColors.blue133, isBold: true);
  }

  Widget _timePickerBox(String label, DateTime time, bool isStart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Row(
        children: [
          Text(label).simpleStyle(14, AppColors.blue133),
          const Spacer(),
          InkWell(
            onTap: () => _showDatePicker(isStart),
            child: Row(
              children: [
                Text(_formatDateTime(time)).simpleStyle(14, AppColors.blue133),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_drop_down, color: AppColors.blue133),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _variableCheckbox(String label) {
    final isSelected = _selectedVars.contains(label);
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedVars.remove(label);
          } else {
            _selectedVars.add(label);
          }
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            (isSelected ? 'ic_tj_select.png' : 'ic_tj_unselect.png').imagePath,
            width: 18,
            height: 18,
          ),
          const SizedBox(width: 8),
          Text(label).simpleStyle(14, AppColors.blue133),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hintText,
    required TextStyle hintStyle,
    TextStyle? textStyle,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        style: textStyle,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: hintStyle,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Color(0xFF0696BD)),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          highlightColor: AppColors.blueE9,
          focusColor: AppColors.blueE9,
          hoverColor: AppColors.blueE9.withOpacity(0.8),
          splashColor: AppColors.blueE9,
        ),
        child: DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.white,
          style: const TextStyle(fontSize: 14, color: AppColors.blue133),
          items: items
              .map(
                (e) => DropdownMenuItem<String>(
                  value: e,
                  child: Text(
                    e,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.blue133,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE6E6E6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF0696BD)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _actionButton(
      String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: bgColor,
        ),
        child: Center(
          child: Text(text).simpleStyle(14, textColor, isBold: true),
        ),
      ),
    );
  }
}
