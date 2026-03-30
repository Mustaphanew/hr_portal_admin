import 'package:sqlite3/common.dart';
import 'sqlite_platform.dart';
import 'tables.dart' as t;

class DbHelper {
  DbHelper._internal();

  static final DbHelper _instance = DbHelper._internal();
  factory DbHelper() => _instance;

  CommonDatabase? _db;

  Future<CommonDatabase>? _opening;

  Future<CommonDatabase> createDatabase() async {
    if (_db != null) return _db!;
    if (_opening != null) return _opening!;

    _opening = _open();
    try {
      _db = await _opening!;
      return _db!;
    } finally {
      _opening = null;
    }
  }

  Future<CommonDatabase> _open() async {
    final db = await openAppDatabase('db.db');

    try {
      db.execute('PRAGMA foreign_keys = ON;');

      db.execute('BEGIN;');
      db.execute(t.notifications);
      db.execute(t.notificationsIndexes);
      db.execute(t.tmp);
      db.execute('COMMIT;');

      return db;
    } catch (e) {
      try {
        db.execute('ROLLBACK;');
      } catch (_) {}
      try {
        db.close();
      } catch (_) {}
      rethrow;
    }
  }

  Future<void> closeDatabase() async {
    try {
      _db?.close();
    } catch (_) {}
    _db = null;
    _opening = null;
  }

  List<Map<String, Object?>> _rows(ResultSet rs) {
    return rs.map((r) => Map<String, Object?>.from(r)).toList();
  }

  // -------------------- RAW HELPERS --------------------

  Future<List<Map<String, Object?>>> rawSelect({
    required String sql,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();
    final fixed = sql.trim().endsWith(';') ? sql.trim() : '${sql.trim()};';
    final rs = db.select(fixed, params);
    return _rows(rs);
  }

  Future<int> execute({
    required String sql,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();
    final fixed = sql.trim().endsWith(';') ? sql.trim() : '${sql.trim()};';

    final stmt = db.prepare(fixed);
    try {
      stmt.execute(params);
      return db.updatedRows;
    } finally {
      stmt.close();
    }
  }

  Future<List<Map<String, Object?>>> cmd({
    required String cmd,
    List<Object?> params = const [],
  }) async {
    return rawSelect(sql: cmd, params: params);
  }

  // -------------------- UTILS --------------------

  Future<String> maxDate({required bool created_at, required String table}) async {
    final column = created_at ? "created_at" : "updated_at";
    return maxDateText(table: table, column: column);
  }

  Future<String> maxDateText({
    required String table,
    String column = "created_at",
    String defaultValue = "2010-01-01T01:01:01",
  }) async {
    final db = await createDatabase();
    final rs = db.select("SELECT MAX($column) AS m FROM $table;");
    final v = rs.isNotEmpty ? rs.first["m"] : null;

    final s = v?.toString().trim();
    if (s == null || s.isEmpty) return defaultValue;

    return s.replaceAll(" ", "T");
  }

  Future<int> maxEpoch({
    required String table,
    String column = "created_at",
    int defaultValue = 0,
  }) async {
    final db = await createDatabase();
    final rs = db.select("SELECT MAX($column) AS m FROM $table;");
    final v = rs.isNotEmpty ? rs.first["m"] : null;

    if (v is int) return v;
    if (v is BigInt) return v.toInt();
    if (v == null) return defaultValue;
    return int.tryParse(v.toString()) ?? defaultValue;
  }

  // -------------------- CRUD --------------------

  Future<List<Map<String, Object?>>> select({
    required String column,
    required String table,
    required String condition,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();

    var cond = condition.trim();

    if (cond.endsWith("and") || cond.endsWith("and ")) {
      cond = "$cond 1";
    }
    if (cond.startsWith("and") || cond.startsWith(" and")) {
      cond = "1 $cond";
    }

    final rs = db.select("SELECT $column FROM $table WHERE $cond;", params);
    return _rows(rs);
  }

  Future<int> insert({
    required String table,
    required Map<String, Object?> obj,
  }) async {
    final db = await createDatabase();
    if (obj.isEmpty) return 0;

    final cols = obj.keys.toList();
    final placeholders = List.filled(cols.length, '?').join(', ');
    final sql = "INSERT INTO $table (${cols.join(', ')}) VALUES ($placeholders);";

    final stmt = db.prepare(sql);
    try {
      stmt.execute(cols.map((c) => obj[c]).toList());
      return db.lastInsertRowId;
    } finally {
      stmt.close();
    }
  }

  Future<int> insertOrIgnore({
    required String table,
    required Map<String, Object?> obj,
  }) async {
    final db = await createDatabase();
    if (obj.isEmpty) return 0;

    final cols = obj.keys.toList();
    final placeholders = List.filled(cols.length, '?').join(', ');
    final sql = "INSERT OR IGNORE INTO $table (${cols.join(', ')}) VALUES ($placeholders);";

    final stmt = db.prepare(sql);
    try {
      stmt.execute(cols.map((c) => obj[c]).toList());
      return db.updatedRows; // 1 inserted, 0 ignored
    } finally {
      stmt.close();
    }
  }

  Future<int> update({
    required String table,
    required Map<String, Object?> obj,
    required String condition,
    List<Object?> conditionParams = const [],
  }) async {
    final db = await createDatabase();
    if (obj.isEmpty) return 0;

    final cols = obj.keys.toList();
    final setPart = cols.map((c) => "$c = ?").join(', ');
    final sql = "UPDATE $table SET $setPart WHERE $condition;";

    final stmt = db.prepare(sql);
    try {
      stmt.execute([
        ...cols.map((c) => obj[c]),
        ...conditionParams,
      ]);
      return db.updatedRows;
    } finally {
      stmt.close();
    }
  }

  Future<int> delete({
    required String table,
    required String condition,
    List<Object?> conditionParams = const [],
  }) async {
    final db = await createDatabase();

    final stmt = db.prepare("DELETE FROM $table WHERE $condition;");
    try {
      stmt.execute(conditionParams);
      return db.updatedRows;
    } finally {
      stmt.close();
    }
  }

  Future<int> countRows({
    required String table,
    required String condition,
    List<Object?> params = const [],
  }) async {
    final db = await createDatabase();

    final rs = db.select(
      'SELECT COUNT(*) as c FROM $table WHERE $condition;',
      params,
    );

    if (rs.isEmpty) return 0;
    final v = rs.first['c'];

    if (v is int) return v;
    if (v is BigInt) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
