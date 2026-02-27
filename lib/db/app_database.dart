import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'table/divices_tab.dart';
import 'table/sensor_history_data.dart';
import 'table/users_table.dart';
import 'package:wind_power_system/model/DeviceDetailData.dart';

/// 应用数据库工具类
/// 负责数据库初始化、表结构保证、数据插入与查询工具方法
class AppDatabase {
  static Database? _db;

  /// 获取数据库单例，若未初始化则完成初始化
  /// 返回已打开的 `Database` 实例
  static Future<Database> instance() async {
    if (_db != null) return _db!;
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    final Directory dir = Platform.isWindows
        ? Directory('C:/Users/${Platform.environment['USERNAME']}/Documents')
        : await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'window_app.db');
    _db = await databaseFactory.openDatabase(path);
    await _ensureDeviceTable();
    await ensureUserTable();
    return _db!;
  }

  /// 确保设备表 `devices` 存在，并按需迁移缺失列
  static Future<void> _ensureDeviceTable() async {
    final db = await instance();
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        ['devices']);
    if (res.isEmpty) {
      await db.execute(devicesCreateSql('devices'));
    }
    // migrate columns if missing
    final info = await db.rawQuery('PRAGMA table_info(devices)');
    final cols = info.map((e) => e['name'] as String).toSet();
    if (!cols.contains('ip')) {
      await db.execute('ALTER TABLE devices ADD COLUMN ip TEXT');
    }
    if (!cols.contains('port')) {
      await db.execute('ALTER TABLE devices ADD COLUMN port INTEGER');
    }
    if (!cols.contains('deviceSn')) {
      await db.execute('ALTER TABLE devices ADD COLUMN deviceSn TEXT');
    }
  }

  /// 生成按月分表的历史表名，例如 `history_2026_02`
  static String monthTableName(int year, int month) {
    final mm = month.toString().padLeft(2, '0');
    return 'history_${year}_$mm';
  }

  /// 确保指定年月的历史分表存在，并按需补齐缺失列与索引
  static Future<void> ensureMonthTable(int year, int month) async {
    final db = await instance();
    final table = monthTableName(year, month);
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [table]);
    if (res.isEmpty) {
      await db.execute(sensorHistoryCreateSql(table));
    }
    // migrate columns if missing
    final info = await db.rawQuery('PRAGMA table_info(' + table + ')');
    final cols = info.map((e) => e['name'] as String).toSet();
    if (!cols.contains('payload')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN payload TEXT NULL');
    }
    if (!cols.contains('deviceId')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN deviceId TEXT NULL');
    }
    if (!cols.contains('verisonHot')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN verisonHot TEXT NULL');
    }
    if (!cols.contains('verisonIce')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN verisonIce TEXT NULL');
    }
    if (!cols.contains('aI')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN aI REAL NULL');
    }
    if (!cols.contains('bI')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN bI REAL NULL');
    }
    if (!cols.contains('cI')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN cI REAL NULL');
    }
    if (!cols.contains('aV')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN aV REAL NULL');
    }
    if (!cols.contains('bV')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN bV REAL NULL');
    }
    if (!cols.contains('cV')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN cV REAL NULL');
    }
    if (!cols.contains('cmd')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN cmd INTEGER NULL');
    }
    if (!cols.contains('tcpIp')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN tcpIp TEXT NULL');
    }
    if (!cols.contains('envTemp')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN envTemp REAL NULL');
    }
    if (!cols.contains('envHumidity')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN envHumidity REAL NULL');
    }
    if (!cols.contains('errorStop')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN errorStop INTEGER NULL');
    }
    if (!cols.contains('restFlag')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN restFlag INTEGER NULL');
    }
    if (!cols.contains('envHot')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN envHot INTEGER NULL');
    }
    if (!cols.contains('hotAll')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN hotAll INTEGER NULL');
    }
    if (!cols.contains('ctrlMode')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN ctrlMode INTEGER NULL');
    }
    if (!cols.contains('windSpeed')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN windSpeed REAL NULL');
    }
    if (!cols.contains('rotorSpeed')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN rotorSpeed REAL NULL');
    }
    if (!cols.contains('iceState')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN iceState INTEGER NULL');
    }
    if (!cols.contains('hotState1')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN hotState1 INTEGER NULL');
    }
    if (!cols.contains('hotState2')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN hotState2 INTEGER NULL');
    }
    if (!cols.contains('hotState3')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN hotState3 INTEGER NULL');
    }
    if (!cols.contains('hotState4')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN hotState4 INTEGER NULL');
    }
    if (!cols.contains('hotTime')) {
      await db
          .execute('ALTER TABLE ' + table + ' ADD COLUMN hotTime INTEGER NULL');
    }
    if (!cols.contains('iSet')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN iSet REAL NULL');
    }
    if (!cols.contains('temperature')) {
      await db.execute(
          'ALTER TABLE ' + table + ' ADD COLUMN temperature REAL NULL');
    }
    if (!cols.contains('power')) {
      await db.execute('ALTER TABLE ' + table + ' ADD COLUMN power REAL NULL');
    }
    // Winddata flattened columns
    const blades = ['b1', 'b2', 'b3'];
    const tempKeys = ['temp_up', 'temp_mid', 'temp_down'];
    const tickKeys = ['tick_up', 'tick_mid', 'tick_down'];
    const runKeys = ['run_up', 'run_mid', 'run_down'];
    for (final b in blades) {
      for (final k in tempKeys) {
        final c = b + '_' + k.replaceAll('_', '_');
        if (!cols.contains('$b\_${k}')) {
          await db.execute('ALTER TABLE ' +
              table +
              ' ADD COLUMN ' +
              b +
              '_' +
              k +
              ' REAL NULL');
        }
      }
      for (final k in tickKeys) {
        if (!cols.contains('$b\_${k}')) {
          await db.execute('ALTER TABLE ' +
              table +
              ' ADD COLUMN ' +
              b +
              '_' +
              k +
              ' REAL NULL');
        }
      }
      for (final k in runKeys) {
        if (!cols.contains('$b\_${k}')) {
          await db.execute('ALTER TABLE ' +
              table +
              ' ADD COLUMN ' +
              b +
              '_' +
              k +
              ' INTEGER NULL');
        }
      }
      if (!cols.contains('$b\_i')) {
        await db.execute(
            'ALTER TABLE ' + table + ' ADD COLUMN ' + b + '_i REAL NULL');
      }
      if (!cols.contains('$b\_v')) {
        await db.execute(
            'ALTER TABLE ' + table + ' ADD COLUMN ' + b + '_v REAL NULL');
      }
    }
    // indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_' +
        table +
        '_sn_time ON ' +
        table +
        ' (sn, recordTime)');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_' +
        table +
        '_sn ON ' +
        table +
        ' (sn)');
  }

  // 用户表
  /// 确保用户表 `users` 存在
  static Future<void> ensureUserTable() async {
    final db = await instance();
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        ['users']);
    if (res.isEmpty) {
      await db.execute(usersCreateSql('users'));
    }
  }
  //
  // static Future<void> createDevices(int count) async {
  //   final db = await instance();
  //   final batch = db.batch();
  //   final now = DateTime.now().millisecondsSinceEpoch;
  //   for (int i = 1; i <= count; i++) {
  //     final sn = 'SN${i.toString().padLeft(4, '0')}';
  //     batch.insert(
  //         'devices',
  //         {
  //           'sn': sn,
  //           'ip': '127.0.0.1',
  //           'port': 8000 + i,
  //           'deviceSn': 'DEV${i.toString().padLeft(4, '0')}',
  //           'createTime': now,
  //         },
  //         conflictAlgorithm: ConflictAlgorithm.ignore);
  //   }
  //   await batch.commit(noResult: true);
  // }

  /// 获取全部设备的 `sn` 列表
  static Future<List<String>> allDeviceSN() async {
    final db = await instance();
    final rows = await db.query('devices', columns: ['sn']);
    return rows.map((e) => e['sn'] as String).toList();
  }

  /// 计算设备 `sn` 中的最大序号（形如 `SN0001`）
  static Future<int> _maxSnIndex() async {
    final sns = await allDeviceSN();
    int maxIdx = 0;
    for (final sn in sns) {
      final m = RegExp(r'^SN(\d+)').firstMatch(sn);
      if (m != null) {
        final idx = int.tryParse(m.group(1)!) ?? 0;
        if (idx > maxIdx) maxIdx = idx;
      }
    }
    return maxIdx;
  }

  /// 自动创建下一个设备（按最大 `sn` 序号 +1）并返回新 `sn`
  static Future<String> createNextDevice() async {
    final db = await instance();
    final next = (await _maxSnIndex()) + 1;
    final sn = 'SN' + next.toString().padLeft(4, '0');
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
        'devices',
        {
          'sn': sn,
          'ip': '127.0.0.1',
          'port': 8000 + next,
          'deviceSn': 'DEV' + next.toString().padLeft(4, '0'),
          'createTime': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore);
    return sn;
  }

  static Future<List<Map<String, Object?>>> allDevices() async {
    final db = await instance();
    await _ensureDeviceTable();
    return await db.query('devices');
  }

  /// 判断设备 `sn` 是否已存在
  static Future<bool> deviceExistsBySn(String sn) async {
    final db = await instance();
    final rows = await db.query('devices',
        columns: ['sn'], where: 'sn = ?', whereArgs: [sn], limit: 1);
    return rows.isNotEmpty;
  }

  /// 插入设备记录（若 `sn` 已存在则抛出 `sn_exists`）
  static Future<void> insertDevice({
    required String sn,
    required String ip,
    required int port,
    required String deviceSn,
  }) async {
    final db = await instance();
    await _ensureDeviceTable();
    final exist = await deviceExistsBySn(sn);
    if (exist) {
      throw StateError('sn_exists');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.insert(
      'devices',
      {
        'sn': sn,
        'ip': ip,
        'port': port,
        'deviceSn': deviceSn,
        'createTime': now,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// 判断用户是否存在
  static Future<bool> userExists(String username) async {
    final db = await instance();
    await ensureUserTable();
    final rows = await db.query('users',
        columns: ['username'],
        where: 'username = ?',
        whereArgs: [username],
        limit: 1);
    return rows.isNotEmpty;
  }

  /// 通过用户名与密码查询用户，成功返回首条记录
  static Future<Map<String, Object?>?> userByCredentials(
      String username, String password) async {
    final db = await instance();
    await ensureUserTable();
    final rows = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// 插入用户记录
  static Future<void> insertUser({
    required String username,
    required int role,
    required String realName,
    required String password,
    required String phone,
  }) async {
    final db = await instance();
    await ensureUserTable();
    await db.insert(
      'users',
      {
        'username': username,
        'role': role,
        'realName': realName,
        'password': password,
        'phone': phone,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// 演示/批量：向指定月表插入一批模拟数据（所有设备）
  static Future<void> insertMonthRecords({
    required int year,
    required int month,
    required DateTime ts,
  }) async {
    final db = await instance();
    await ensureMonthTable(year, month);
    final table = monthTableName(year, month);
    final sns = await allDeviceSN();
    final batch = db.batch();
    for (final sn in sns) {
      batch.insert(
        table,
        {
          'sn': sn,
          'recordTime': ts.millisecondsSinceEpoch,
          'temperature': 15 + (sn.hashCode % 10) * 1.2,
          'power': 500 + (sn.hashCode % 7) * 40,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
    await batch.commit(noResult: true);
  }

  /// 计算下一个批量插入时间：若存在记录则在最大时间基础上 +1 小时，否则该月第一天 00:00
  static Future<DateTime> nextBatchTs(int year, int month) async {
    final db = await instance();
    await ensureMonthTable(year, month);
    final table = monthTableName(year, month);
    final res =
        await db.rawQuery('SELECT MAX(recordTime) AS maxTs FROM ' + table);
    final maxTs = res.isNotEmpty ? res.first['maxTs'] as int? : null;
    if (maxTs != null) {
      return DateTime.fromMillisecondsSinceEpoch(maxTs)
          .add(const Duration(hours: 1));
    }
    return DateTime(year, month, 1, 0, 0, 0);
  }

  /// 自动计算时间并插入一批模拟数据
  static Future<void> insertMonthRecordsAuto(int year, int month) async {
    final ts = await nextBatchTs(year, month);
    await insertMonthRecords(year: year, month: month, ts: ts);
  }

  static Future<Map<String, Object?>?> latestHistoryForSn(String sn) async {
    final db = await instance();
    final now = DateTime.now();
    await ensureMonthTable(now.year, now.month);
    final cur = monthTableName(now.year, now.month);
    final curRows = await db.query(
      cur,
      where: 'sn = ?',
      whereArgs: [sn],
      orderBy: 'recordTime DESC',
      limit: 1,
    );
    if (curRows.isNotEmpty) return curRows.first;
    final prevMonth =
        DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
    await ensureMonthTable(prevMonth.year, prevMonth.month);
    final prev = monthTableName(prevMonth.year, prevMonth.month);
    final prevRows = await db.query(
      prev,
      where: 'sn = ?',
      whereArgs: [sn],
      orderBy: 'recordTime DESC',
      limit: 1,
    );
    return prevRows.isNotEmpty ? prevRows.first : null;
  }

  /// 写入实时数据：按 `ts` 定位月分表，展开 `State/Fault/Winddata` 到列
  /// `storePayload` 为真时同时保存完整 JSON 到 `payload`
  static Future<void> insertRealtimeData({
    required String sn,
    required DateTime ts,
    required DeviceDetailData data,
    bool storePayload = true,
  }) async {
    final db = await instance();
    await ensureMonthTable(ts.year, ts.month);
    final table = monthTableName(ts.year, ts.month);
    final st = data.state;
    final payload = jsonEncode(data.toJson());
    await db.insert(
      table,
      {
        'sn': sn,
        'recordTime': ts.millisecondsSinceEpoch,
        'payload': storePayload ? payload : null,
        'deviceId': st?.deviceId,
        'verisonHot': st?.verisonHot,
        'verisonIce': st?.verisonIce,
        'aI': st?.aI,
        'bI': st?.bI,
        'cI': st?.cI,
        'aV': st?.aV,
        'bV': st?.bV,
        'cV': st?.cV,
        'cmd': st?.cmd?.toInt(),
        'tcpIp': st?.tcpIp,
        'envTemp': st?.envTemp,
        'envHumidity': st?.envHumidity,
        'errorStop': st?.errorStop?.toInt(),
        'restFlag': st?.restFlag?.toInt(),
        'envHot': st?.envHot?.toInt(),
        'hotAll': st?.hotAll?.toInt(),
        'ctrlMode': st?.ctrlMode?.toInt(),
        'windSpeed': st?.windSpeed,
        'rotorSpeed': st?.rotorSpeed,
        'iceState': st?.iceState,
        'hotState1': st?.hotState1,
        'hotState2': st?.hotState2,
        'hotState3': st?.hotState3,
        'hotState4': st?.hotState4,
        'hotTime': st?.hotTime?.toInt(),
        'iSet': st?.iSet,
        // Blade1
        'b1_temp_up': data.winddata?.blade1?.tempUp,
        'b1_temp_mid': data.winddata?.blade1?.tempMid,
        'b1_temp_down': data.winddata?.blade1?.tempDown,
        'b1_tick_up': data.winddata?.blade1?.tickUp,
        'b1_tick_mid': data.winddata?.blade1?.tickMid,
        'b1_tick_down': data.winddata?.blade1?.tickDown,
        'b1_run_up': data.winddata?.blade1?.runUp?.toInt(),
        'b1_run_mid': data.winddata?.blade1?.runMid?.toInt(),
        'b1_run_down': data.winddata?.blade1?.runDown?.toInt(),
        'b1_i': data.winddata?.blade1?.windI,
        'b1_v': data.winddata?.blade1?.windV,
        // Blade2
        'b2_temp_up': data.winddata?.blade2?.tempUp,
        'b2_temp_mid': data.winddata?.blade2?.tempMid,
        'b2_temp_down': data.winddata?.blade2?.tempDown,
        'b2_tick_up': data.winddata?.blade2?.tickUp,
        'b2_tick_mid': data.winddata?.blade2?.tickMid,
        'b2_tick_down': data.winddata?.blade2?.tickDown,
        'b2_run_up': data.winddata?.blade2?.runUp?.toInt(),
        'b2_run_mid': data.winddata?.blade2?.runMid?.toInt(),
        'b2_run_down': data.winddata?.blade2?.runDown?.toInt(),
        'b2_i': data.winddata?.blade2?.windI,
        'b2_v': data.winddata?.blade2?.windV,
        // Blade3
        'b3_temp_up': data.winddata?.blade3?.tempUp,
        'b3_temp_mid': data.winddata?.blade3?.tempMid,
        'b3_temp_down': data.winddata?.blade3?.tempDown,
        'b3_tick_up': data.winddata?.blade3?.tickUp,
        'b3_tick_mid': data.winddata?.blade3?.tickMid,
        'b3_tick_down': data.winddata?.blade3?.tickDown,
        'b3_run_up': data.winddata?.blade3?.runUp?.toInt(),
        'b3_run_mid': data.winddata?.blade3?.runMid?.toInt(),
        'b3_run_down': data.winddata?.blade3?.runDown?.toInt(),
        'b3_i': data.winddata?.blade3?.windI,
        'b3_v': data.winddata?.blade3?.windV,
        // Fault
        'faultRing': data.fault?.faultRing?.toInt(),
        'faultUps': data.fault?.faultUps?.toInt(),
        'faultTestCom': data.fault?.faultTestCom?.toInt(),
        'faultIavg': data.fault?.faultIavg?.toInt(),
        'faultContactor': data.fault?.faultContactor?.toInt(),
        'faultStick': data.fault?.faultStick?.toInt(),
        'faultStickBlade1': data.fault?.faultStickBlade1?.toInt(),
        'faultStickBlade2': data.fault?.faultStickBlade2?.toInt(),
        'faultStickBlade3': data.fault?.faultStickBlade3?.toInt(),
        'faultBlade1': data.fault?.faultBlade1?.toInt(),
        'faultBlade2': data.fault?.faultBlade2?.toInt(),
        'faultBlade3': data.fault?.faultBlade3?.toInt(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 获取历史记录（跨月查询）
  /// [sn] 设备序列号
  /// [startTime] 开始时间
  /// [endTime] 结束时间
  /// 返回所有跨月表的聚合结果，并按 recordTime 升序排列
  static Future<List<Map<String, Object?>>> queryHistoryData({
    required String sn,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final db = await instance();
    final List<Map<String, Object?>> allResults = [];

    DateTime current = DateTime(startTime.year, startTime.month);
    final endMonth = DateTime(endTime.year, endTime.month);

    while (current.isBefore(endMonth) || current.isAtSameMomentAs(endMonth)) {
      final table = monthTableName(current.year, current.month);
      // 检查表是否存在
      final tableCheck = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
          [table]);
      if (tableCheck.isNotEmpty) {
        final rows = await db.query(
          table,
          where: 'sn = ? AND recordTime >= ? AND recordTime <= ?',
          whereArgs: [
            sn,
            startTime.millisecondsSinceEpoch,
            endTime.millisecondsSinceEpoch
          ],
          orderBy: 'recordTime ASC',
        );
        allResults.addAll(rows);
      }
      current = DateTime(current.year, current.month + 1);
    }
    // 跨月合并后重新按时间排序
    allResults.sort(
        (a, b) => (a['recordTime'] as int).compareTo(b['recordTime'] as int));
    return allResults;
  }
}
