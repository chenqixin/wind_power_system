///
/// divices_tab.dart
/// window
/// Created by cqx on 2025/12/22.
/// Copyright ©2025 Changjia. All rights reserved.
///
library;

import 'package:drift/drift.dart';

class Devices extends Table {

  //设备 SN (唯一)
  TextColumn get sn => text()();

  // 风机 IP 地址
  TextColumn get ip => text()();

  // 风机端口号
  IntColumn get port => integer()();

  // 设备编号（设备 SN）
  TextColumn get deviceSn => text()();

  //创建时间(UTC 毫秒时间戳)
  IntColumn get createTime => integer()();

  @override
  Set<Column> get primaryKey => {sn};



}

String devicesCreateSql(String table) {
  return 'CREATE TABLE '
      '$table('
      'sn TEXT PRIMARY KEY, '
      'ip TEXT, '
      'port INTEGER, '
      'deviceSn TEXT, '
      'createTime INTEGER'
      ')';
}
