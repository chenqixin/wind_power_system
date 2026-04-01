import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'table/divices_tab.dart';
import 'table/sensor_history_data.dart';
import 'table/users_table.dart';
import 'package:wind_power_system/model/DeviceDetailData.dart';
import 'package:wind_power_system/core/constant/app_constant.dart';

/// 当前数据库 Schema 版本号，每次有表结构变动时递增
const int kSchemaVersion = 1;

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

    final Directory dir;
    if (AppConstant.isRelease) {
      // 正式环境：存放在系统应用数据目录，用户不易误删
      // macOS: ~/Library/Application Support/
      // Windows: C:\Users\{USERNAME}\AppData\Roaming\
      // Linux: ~/.local/share/
      dir = await getApplicationSupportDirectory();
    } else {
      // 测试环境：存放在"文档"目录，方便开发者查看调试
      dir = Platform.isWindows
          ? Directory(
              'C:/Users/${Platform.environment['USERNAME']}/Documents')
          : await getApplicationDocumentsDirectory();
    }

    final path = p.join(dir.path, 'window_app.db');
    _db = await databaseFactory.openDatabase(path);
    await _runMigrations();
    await _ensureDefaultAdmin();
    return _db!;
  }

  // ===========================================================================
  // 数据库版本迁移
  // ===========================================================================

  /// 读取当前版本号，逐版本执行迁移，仅在 App 启动时运行一次
  static Future<void> _runMigrations() async {
    final db = _db!;
    await db.execute(
      'CREATE TABLE IF NOT EXISTS _meta (key TEXT PRIMARY KEY, value TEXT)',
    );
    final rows = await db.rawQuery(
      "SELECT value FROM _meta WHERE key = 'schema_version'",
    );
    final oldVersion =
        rows.isEmpty ? 0 : int.parse(rows.first['value'] as String);
    if (oldVersion >= kSchemaVersion) return;
    for (int v = oldVersion + 1; v <= kSchemaVersion; v++) {
      await _applyMigration(db, v);
    }
    await db.execute(
      "INSERT OR REPLACE INTO _meta (key, value) "
      "VALUES ('schema_version', '$kSchemaVersion')",
    );
  }

  /// 按版本号执行对应的迁移操作。
  /// 未来新增字段时：递增 [kSchemaVersion]，添加新的 case，
  /// 把新列同时加到 [sensorHistoryCreateSql] / 建表 SQL 中即可。
  static Future<void> _applyMigration(Database db, int version) async {
    switch (version) {
      case 1:
        // v1: 基线 — 确保所有表和列与当前 schema 一致
        // devices 表
        final devRes = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='devices'",
        );
        if (devRes.isEmpty) {
          await db.execute(devicesCreateSql('devices'));
        } else {
          await _addColumnsIfMissing(db, 'devices', _deviceColumnsV1);
        }
        // users 表
        final usrRes = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='users'",
        );
        if (usrRes.isEmpty) {
          await db.execute(usersCreateSql('users'));
        }
        // 已有的月分表批量补齐列和索引
        await _migrateExistingMonthTables(db, _historyColumnsV1);
        break;
      // ---- 未来版本示例 ----
      // case 2:
      //   await _addColumnsIfMissing(db, 'users', [MapEntry('email', 'TEXT')]);
      //   await _addColumnsIfMissing(db, 'devices', [MapEntry('alias', 'TEXT')]);
      //   await _migrateExistingMonthTables(db, _historyColumnsV2);
      //   break;
    }
  }

  /// 批量给指定表安全添加缺失列（先读一次 PRAGMA，再逐列判断）
  static Future<void> _addColumnsIfMissing(
    Database db,
    String table,
    List<MapEntry<String, String>> columns,
  ) async {
    final info = await db.rawQuery('PRAGMA table_info($table)');
    final existing = info.map((e) => e['name'] as String).toSet();
    for (final col in columns) {
      if (!existing.contains(col.key)) {
        await db.execute(
            'ALTER TABLE $table ADD COLUMN ${col.key} ${col.value}');
      }
    }
  }

  /// 扫描所有已存在的 history_YYYY_MM 月分表，批量补齐缺失列与索引
  static Future<void> _migrateExistingMonthTables(
    Database db,
    List<MapEntry<String, String>> columns,
  ) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'history_%'",
    );
    for (final row in tables) {
      final table = row['name'] as String;
      await _addColumnsIfMissing(db, table, columns);
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_${table}_sn_time ON $table (sn, recordTime)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_${table}_sn ON $table (sn)');
    }
  }

  // ---- 各版本列定义（仅用于迁移老数据库） ----

  static const _deviceColumnsV1 = <MapEntry<String, String>>[
    MapEntry('ip', 'TEXT'),
    MapEntry('port', 'INTEGER'),
    MapEntry('deviceSn', 'TEXT'),
  ];

  static const _historyColumnsV1 = <MapEntry<String, String>>[
    MapEntry('payload', 'TEXT NULL'),
    MapEntry('deviceId', 'TEXT NULL'),
    MapEntry('verisonHot', 'TEXT NULL'),
    MapEntry('verisonIce', 'TEXT NULL'),
    MapEntry('aI', 'REAL NULL'),
    MapEntry('bI', 'REAL NULL'),
    MapEntry('cI', 'REAL NULL'),
    MapEntry('aV', 'REAL NULL'),
    MapEntry('bV', 'REAL NULL'),
    MapEntry('cV', 'REAL NULL'),
    MapEntry('cmd', 'INTEGER NULL'),
    MapEntry('tcpIp', 'TEXT NULL'),
    MapEntry('envTemp', 'REAL NULL'),
    MapEntry('envHumidity', 'REAL NULL'),
    MapEntry('errorStop', 'INTEGER NULL'),
    MapEntry('restFlag', 'INTEGER NULL'),
    MapEntry('envHot', 'INTEGER NULL'),
    MapEntry('hotAll', 'INTEGER NULL'),
    MapEntry('ctrlMode', 'INTEGER NULL'),
    MapEntry('windSpeed', 'REAL NULL'),
    MapEntry('rotorSpeed', 'REAL NULL'),
    MapEntry('iceState', 'INTEGER NULL'),
    MapEntry('hotState1', 'INTEGER NULL'),
    MapEntry('hotState2', 'INTEGER NULL'),
    MapEntry('hotState3', 'INTEGER NULL'),
    MapEntry('hotState4', 'INTEGER NULL'),
    MapEntry('hotTime', 'INTEGER NULL'),
    MapEntry('iSet', 'REAL NULL'),
    MapEntry('temperature', 'REAL NULL'),
    MapEntry('power', 'REAL NULL'),
    // Blade 1
    MapEntry('b1_temp_up', 'REAL NULL'),
    MapEntry('b1_temp_mid', 'REAL NULL'),
    MapEntry('b1_temp_down', 'REAL NULL'),
    MapEntry('b1_tick_up', 'REAL NULL'),
    MapEntry('b1_tick_mid', 'REAL NULL'),
    MapEntry('b1_tick_down', 'REAL NULL'),
    MapEntry('b1_run_up', 'INTEGER NULL'),
    MapEntry('b1_run_mid', 'INTEGER NULL'),
    MapEntry('b1_run_down', 'INTEGER NULL'),
    MapEntry('b1_i', 'REAL NULL'),
    MapEntry('b1_v', 'REAL NULL'),
    // Blade 2
    MapEntry('b2_temp_up', 'REAL NULL'),
    MapEntry('b2_temp_mid', 'REAL NULL'),
    MapEntry('b2_temp_down', 'REAL NULL'),
    MapEntry('b2_tick_up', 'REAL NULL'),
    MapEntry('b2_tick_mid', 'REAL NULL'),
    MapEntry('b2_tick_down', 'REAL NULL'),
    MapEntry('b2_run_up', 'INTEGER NULL'),
    MapEntry('b2_run_mid', 'INTEGER NULL'),
    MapEntry('b2_run_down', 'INTEGER NULL'),
    MapEntry('b2_i', 'REAL NULL'),
    MapEntry('b2_v', 'REAL NULL'),
    // Blade 3
    MapEntry('b3_temp_up', 'REAL NULL'),
    MapEntry('b3_temp_mid', 'REAL NULL'),
    MapEntry('b3_temp_down', 'REAL NULL'),
    MapEntry('b3_tick_up', 'REAL NULL'),
    MapEntry('b3_tick_mid', 'REAL NULL'),
    MapEntry('b3_tick_down', 'REAL NULL'),
    MapEntry('b3_run_up', 'INTEGER NULL'),
    MapEntry('b3_run_mid', 'INTEGER NULL'),
    MapEntry('b3_run_down', 'INTEGER NULL'),
    MapEntry('b3_i', 'REAL NULL'),
    MapEntry('b3_v', 'REAL NULL'),
    // Faults
    MapEntry('faultRing', 'INTEGER NULL'),
    MapEntry('faultUps', 'INTEGER NULL'),
    MapEntry('faultTestCom', 'INTEGER NULL'),
    MapEntry('faultIavg', 'INTEGER NULL'),
    MapEntry('faultContactor', 'INTEGER NULL'),
    MapEntry('faultStick', 'INTEGER NULL'),
    MapEntry('faultStickBlade1', 'INTEGER NULL'),
    MapEntry('faultStickBlade2', 'INTEGER NULL'),
    MapEntry('faultStickBlade3', 'INTEGER NULL'),
    MapEntry('faultBlade1', 'INTEGER NULL'),
    MapEntry('faultBlade2', 'INTEGER NULL'),
    MapEntry('faultBlade3', 'INTEGER NULL'),
  ];

  // ===========================================================================
  // 表辅助方法
  // ===========================================================================

  /// 确保设备表存在（仅建表，列迁移由 [_runMigrations] 统一处理）
  static Future<void> _ensureDeviceTable() async {
    final db = await instance();
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        ['devices']);
    if (res.isEmpty) {
      await db.execute(devicesCreateSql('devices'));
    }
  }

  /// 生成按月分表的历史表名，例如 `history_2026_02`
  static String monthTableName(int year, int month) {
    final mm = month.toString().padLeft(2, '0');
    return 'history_${year}_$mm';
  }

  /// 确保指定年月的历史分表存在（新表直接使用最新完整 schema 建表）
  static Future<void> ensureMonthTable(int year, int month) async {
    final db = await instance();
    final table = monthTableName(year, month);
    final res = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [table]);
    if (res.isEmpty) {
      await db.execute(sensorHistoryCreateSql(table));
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_${table}_sn_time ON $table (sn, recordTime)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_${table}_sn ON $table (sn)');
    }
  }

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

  /// 默认管理员账户写入（若不存在）
  static Future<void> _ensureDefaultAdmin() async {
    final exist = await userExists('admin');
    if (exist) return;
    await insertUser(
      username: 'admin',
      role: 2,
      realName: '主',
      password: 'abc123456',
      phone: '17366621184',
    );
  }

  // ===========================================================================
  // 业务方法
  // ===========================================================================

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

  static Future<Map<String, Object?>?> getDeviceBySn(String sn) async {
    final db = await instance();
    final res = await db.query('devices', where: 'sn = ?', whereArgs: [sn]);
    return res.isNotEmpty ? res.first : null;
  }

  /// 判断设备 `sn` 是否已存在
  static Future<bool> deviceExistsBySn(String sn) async {
    final db = await instance();
    final rows = await db.query('devices',
        columns: ['sn'], where: 'sn = ?', whereArgs: [sn], limit: 1);
    return rows.isNotEmpty;
  }

  /// 删除设备及其记录
  static Future<int> deleteDevice(String sn) async {
    final db = await instance();
    await _ensureDeviceTable();
    return await db.delete('devices', where: 'sn = ?', whereArgs: [sn]);
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

  static Future<void> updateDevice({
    required String originSn,
    required String sn,
    required String ip,
    required int port,
    required String deviceSn,
  }) async {
    final db = await instance();
    await _ensureDeviceTable();
    if (originSn != sn) {
      final exist = await deviceExistsBySn(sn);
      if (exist) {
        throw StateError('sn_exists');
      }
    }
    await db.update(
      'devices',
      {
        'sn': sn,
        'ip': ip,
        'port': port,
        'deviceSn': deviceSn,
      },
      where: 'sn = ?',
      whereArgs: [originSn],
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
