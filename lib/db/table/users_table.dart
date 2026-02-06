library;

import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get username => text()();
  IntColumn get role => integer()();
  TextColumn get realName => text()();
  TextColumn get password => text()();
  TextColumn get phone => text()();

  @override
  Set<Column> get primaryKey => {username};
}

String usersCreateSql(String table) {
  return 'CREATE TABLE '
      '$table('
      'username TEXT PRIMARY KEY, '
      'role INTEGER, '
      'realName TEXT, '
      'password TEXT, '
      'phone TEXT'
      ')';
}
