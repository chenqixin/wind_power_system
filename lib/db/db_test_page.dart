import 'package:flutter/material.dart';
import 'app_database.dart';

class DbTestPage extends StatefulWidget {
  const DbTestPage({super.key});
  @override
  State<DbTestPage> createState() => _DbTestPageState();
}

class _DbTestPageState extends State<DbTestPage> {
  final List<String> _logs = [];

  void _addLog(String s) {
    setState(() => _logs.insert(0, s));
  }

  Future<void> _createDevices() async {
    final sn = await AppDatabase.createNextDevice();
    final sns = await AppDatabase.allDeviceSN();
    _addLog('新增设备: $sn, 当前数量: ${sns.length}');
  }

  Future<void> _insertForMonth(int month) async {
    final nowYear = DateTime.now().year;
    final ts = await AppDatabase.nextBatchTs(nowYear, month);
    await AppDatabase.insertMonthRecords(year: nowYear, month: month, ts: ts);
    final table = AppDatabase.monthTableName(nowYear, month);
    _addLog('插入 $table 数据时间 ${ts.toIso8601String()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('数据库测试')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: _createDevices, child: const Text('创建SN设备')),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(12, (i) {
                      final m = i + 1;
                      return ElevatedButton(
                        onPressed: () => _insertForMonth(m),
                        child: Text('$m月'),
                      );
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _logs.length,
                  itemBuilder: (_, i) => Text(_logs[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
