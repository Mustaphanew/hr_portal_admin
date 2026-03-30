import 'package:sqlite3/common.dart';
import 'package:sqlite3/wasm.dart';

WasmSqlite3? _sqlite;

Future<WasmSqlite3> _loadSqlite() async {
  if (_sqlite != null) return _sqlite!;

  final sqlite = await WasmSqlite3.loadFromUrl(
    Uri.base.resolve('sqlite3.wasm'),
  );

  final fs = await IndexedDbFileSystem.open(dbName: 'hr_admin_app');
  sqlite.registerVirtualFileSystem(fs, makeDefault: true);

  _sqlite = sqlite;
  return sqlite;
}

Future<CommonDatabase> openAppDatabase(String fileName) async {
  final sqlite = await _loadSqlite();
  return sqlite.open(fileName);
}
