///
/// sensor_history_data.dart
/// window
/// Created by cqx on 2025/12/22.
/// Copyright ©2025 Changjia. All rights reserved.
///
library;

import 'package:drift/drift.dart';

class SensorHistoryData extends Table {
  TextColumn get sn => text()();
  IntColumn get recordTime => integer()();
  TextColumn get payload => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  TextColumn get verisonHot => text().nullable()();
  TextColumn get verisonIce => text().nullable()();
  RealColumn get aI => real().nullable()();
  RealColumn get bI => real().nullable()();
  RealColumn get cI => real().nullable()();
  RealColumn get aV => real().nullable()();
  RealColumn get bV => real().nullable()();
  RealColumn get cV => real().nullable()();
  IntColumn get cmd => integer().nullable()();
  TextColumn get tcpIp => text().nullable()();
  RealColumn get envTemp => real().nullable()();
  RealColumn get envHumidity => real().nullable()();
  IntColumn get errorStop => integer().nullable()();
  IntColumn get restFlag => integer().nullable()();
  IntColumn get envHot => integer().nullable()();
  IntColumn get hotAll => integer().nullable()();
  IntColumn get ctrlMode => integer().nullable()();
  RealColumn get windSpeed => real().nullable()();
  RealColumn get rotorSpeed => real().nullable()();
  IntColumn get iceState => integer().nullable()();
  IntColumn get hotState1 => integer().nullable()();
  IntColumn get hotState2 => integer().nullable()();
  IntColumn get hotState3 => integer().nullable()();
  IntColumn get hotState4 => integer().nullable()();
  IntColumn get hotTime => integer().nullable()();
  RealColumn get iSet => real().nullable()();
  RealColumn get temperature => real().nullable()();
  RealColumn get power => real().nullable()();

  // Blade1
  RealColumn get b1_temp_up => real().nullable()();
  RealColumn get b1_temp_mid => real().nullable()();
  RealColumn get b1_temp_down => real().nullable()();
  RealColumn get b1_tick_up => real().nullable()();
  RealColumn get b1_tick_mid => real().nullable()();
  RealColumn get b1_tick_down => real().nullable()();
  IntColumn get b1_run_up => integer().nullable()();
  IntColumn get b1_run_mid => integer().nullable()();
  IntColumn get b1_run_down => integer().nullable()();
  RealColumn get b1_i => real().nullable()();
  RealColumn get b1_v => real().nullable()();

  // Blade2
  RealColumn get b2_temp_up => real().nullable()();
  RealColumn get b2_temp_mid => real().nullable()();
  RealColumn get b2_temp_down => real().nullable()();
  RealColumn get b2_tick_up => real().nullable()();
  RealColumn get b2_tick_mid => real().nullable()();
  RealColumn get b2_tick_down => real().nullable()();
  IntColumn get b2_run_up => integer().nullable()();
  IntColumn get b2_run_mid => integer().nullable()();
  IntColumn get b2_run_down => integer().nullable()();
  RealColumn get b2_i => real().nullable()();
  RealColumn get b2_v => real().nullable()();

  // Blade3
  RealColumn get b3_temp_up => real().nullable()();
  RealColumn get b3_temp_mid => real().nullable()();
  RealColumn get b3_temp_down => real().nullable()();
  RealColumn get b3_tick_up => real().nullable()();
  RealColumn get b3_tick_mid => real().nullable()();
  RealColumn get b3_tick_down => real().nullable()();
  IntColumn get b3_run_up => integer().nullable()();
  IntColumn get b3_run_mid => integer().nullable()();
  IntColumn get b3_run_down => integer().nullable()();
  RealColumn get b3_i => real().nullable()();
  RealColumn get b3_v => real().nullable()();

  @override
  Set<Column> get primaryKey => {sn, recordTime};
}

String sensorHistoryCreateSql(String table) {
  return 'CREATE TABLE '
      '$table('
      'sn TEXT, '
      'recordTime INTEGER, '
      'payload TEXT NULL, '
      'deviceId TEXT NULL, '
      'verisonHot TEXT NULL, '
      'verisonIce TEXT NULL, '
      'aI REAL NULL, '
      'bI REAL NULL, '
      'cI REAL NULL, '
      'aV REAL NULL, '
      'bV REAL NULL, '
      'cV REAL NULL, '
      'cmd INTEGER NULL, '
      'tcpIp TEXT NULL, '
      'envTemp REAL NULL, '
      'envHumidity REAL NULL, '
      'errorStop INTEGER NULL, '
      'restFlag INTEGER NULL, '
      'envHot INTEGER NULL, '
      'hotAll INTEGER NULL, '
      'ctrlMode INTEGER NULL, '
      'windSpeed REAL NULL, '
      'rotorSpeed REAL NULL, '
      'iceState INTEGER NULL, '
      'hotState1 INTEGER NULL, '
      'hotState2 INTEGER NULL, '
      'hotState3 INTEGER NULL, '
      'hotState4 INTEGER NULL, '
      'hotTime INTEGER NULL, '
      'iSet REAL NULL, '
      'temperature REAL NULL, '
      'power REAL NULL, '
      'b1_temp_up REAL NULL, '
      'b1_temp_mid REAL NULL, '
      'b1_temp_down REAL NULL, '
      'b1_tick_up REAL NULL, '
      'b1_tick_mid REAL NULL, '
      'b1_tick_down REAL NULL, '
      'b1_run_up INTEGER NULL, '
      'b1_run_mid INTEGER NULL, '
      'b1_run_down INTEGER NULL, '
      'b1_i REAL NULL, '
      'b1_v REAL NULL, '
      'b2_temp_up REAL NULL, '
      'b2_temp_mid REAL NULL, '
      'b2_temp_down REAL NULL, '
      'b2_tick_up REAL NULL, '
      'b2_tick_mid REAL NULL, '
      'b2_tick_down REAL NULL, '
      'b2_run_up INTEGER NULL, '
      'b2_run_mid INTEGER NULL, '
      'b2_run_down INTEGER NULL, '
      'b2_i REAL NULL, '
      'b2_v REAL NULL, '
      'b3_temp_up REAL NULL, '
      'b3_temp_mid REAL NULL, '
      'b3_temp_down REAL NULL, '
      'b3_tick_up REAL NULL, '
      'b3_tick_mid REAL NULL, '
      'b3_tick_down REAL NULL, '
      'b3_run_up INTEGER NULL, '
      'b3_run_mid INTEGER NULL, '
      'b3_run_down INTEGER NULL, '
      'b3_i REAL NULL, '
      'b3_v REAL NULL, '
      'faultRing INTEGER NULL, '
      'faultUps INTEGER NULL, '
      'faultTestCom INTEGER NULL, '
      'faultIavg INTEGER NULL, '
      'faultContactor INTEGER NULL, '
      'faultStick INTEGER NULL, '
      'faultStickBlade1 INTEGER NULL, '
      'faultStickBlade2 INTEGER NULL, '
      'faultStickBlade3 INTEGER NULL, '
      'faultBlade1 INTEGER NULL, '
      'faultBlade2 INTEGER NULL, '
      'faultBlade3 INTEGER NULL, '
      'PRIMARY KEY (sn, recordTime)'
      ')';
}
