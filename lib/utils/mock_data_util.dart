import 'dart:math';
import 'package:wind_power_system/db/app_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MockDataUtil {
  static final Random _random = Random();

  /// 生成并插入假数据
  /// 范围：过去5个月
  /// 间隔：10分钟
  /// SN：8888
  static Future<void> generateMockHistoryData() async {
    const String targetSn = '8888';
    final DateTime now = DateTime.now();
    final DateTime fiveMonthsAgo = DateTime(now.year, now.month - 5, now.day);

    final db = await AppDatabase.instance();

    // 确保 8888 设备在 devices 表中存在，以便查询能找到它（如果业务逻辑需要的话）
    final bool exists = await AppDatabase.deviceExistsBySn(targetSn);
    if (!exists) {
      await db.insert(
        'devices',
        {
          'sn': targetSn,
          'ip': '127.0.0.1',
          'port': 8888,
          'deviceSn': 'MOCK_DEV_8888',
          'createTime': DateTime.now().millisecondsSinceEpoch,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }

    DateTime current = fiveMonthsAgo;

    // 按月处理，因为数据库是按月分表的
    while (current.isBefore(now)) {
      final int year = current.year;
      final int month = current.month;

      await AppDatabase.ensureMonthTable(year, month);
      final String tableName = AppDatabase.monthTableName(year, month);

      final Batch batch = db.batch();

      // 生成当月的数据
      DateTime monthEnd = DateTime(year, month + 1, 1);
      if (monthEnd.isAfter(now)) {
        monthEnd = now;
      }

      while (current.isBefore(monthEnd)) {
        batch.insert(
          tableName,
          {
            'sn': targetSn,
            'recordTime': current.millisecondsSinceEpoch,
            'deviceId': 'MOCK_DEV_8888',
            'verisonHot': '1.0.0',
            'verisonIce': '1.0.0',
            'aI': _random.nextInt(41).toDouble(),
            'bI': _random.nextInt(41).toDouble(),
            'cI': _random.nextInt(41).toDouble(),
            'aV': 220.0 + _random.nextDouble() * 10,
            'bV': 220.0 + _random.nextDouble() * 10,
            'cV': 220.0 + _random.nextDouble() * 10,
            'cmd': 1,
            'tcpIp': '127.0.0.1',
            'envTemp': 5.0 + _random.nextDouble() * 20,
            'envHumidity': 40.0 + _random.nextDouble() * 30,
            'errorStop': 0,
            'restFlag': 0,
            'envHot': 0,
            'hotAll': 0,
            'ctrlMode': 1,
            'windSpeed': 3.0 + _random.nextDouble() * 12,
            'rotorSpeed': 10.0 + _random.nextDouble() * 5,
            'iceState': _random.nextInt(2), // 0 or 1
            'hotState1': 0,
            'hotState2': 0,
            'hotState3': 0,
            'hotState4': 0,
            'hotTime': 0,
            'iSet': 20.0,
            'temperature': 15.0 + _random.nextDouble() * 10,
            'power': 400.0 + _random.nextDouble() * 200,
            // Blade 1
            'b1_temp_up': -30.0 + _random.nextDouble() * 110.0,
            'b1_temp_mid': -30.0 + _random.nextDouble() * 110.0,
            'b1_temp_down': -30.0 + _random.nextDouble() * 110.0,
            'b1_tick_up': _random.nextInt(31).toDouble(),
            'b1_tick_mid': _random.nextInt(31).toDouble(),
            'b1_tick_down': _random.nextInt(31).toDouble(),
            'b1_run_up': 1,
            'b1_run_mid': 1,
            'b1_run_down': 1,
            'b1_i': _random.nextInt(8).toDouble(),
            'b1_v': 50.0,
            // Blade 2
            'b2_temp_up': -30.0 + _random.nextDouble() * 110.0,
            'b2_temp_mid': -30.0 + _random.nextDouble() * 110.0,
            'b2_temp_down': -30.0 + _random.nextDouble() * 110.0,
            'b2_tick_up': _random.nextInt(31).toDouble(),
            'b2_tick_mid': _random.nextInt(31).toDouble(),
            'b2_tick_down': _random.nextInt(31).toDouble(),
            'b2_run_up': 1,
            'b2_run_mid': 1,
            'b2_run_down': 1,
            'b2_i': _random.nextInt(8).toDouble(),
            'b2_v': 50.0,
            // Blade 3
            'b3_temp_up': -30.0 + _random.nextDouble() * 110.0,
            'b3_temp_mid': -30.0 + _random.nextDouble() * 110.0,
            'b3_temp_down': -30.0 + _random.nextDouble() * 110.0,
            'b3_tick_up': _random.nextInt(31).toDouble(),
            'b3_tick_mid': _random.nextInt(31).toDouble(),
            'b3_tick_down': _random.nextInt(31).toDouble(),
            'b3_run_up': 1,
            'b3_run_mid': 1,
            'b3_run_down': 1,
            'b3_i': _random.nextInt(8).toDouble(),
            'b3_v': 50.0 ,
            // Fault data
            'faultRing': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultUps': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultTestCom': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultIavg': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultContactor': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultStick': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultStickBlade1': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultStickBlade2': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultStickBlade3': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultBlade1': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultBlade2': _random.nextDouble() > 0.95 ? 1 : 0,
            'faultBlade3': _random.nextDouble() > 0.95 ? 1 : 0,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        current = current.add(const Duration(minutes: 10));
      }

      await batch.commit(noResult: true);
    }
  }
}
