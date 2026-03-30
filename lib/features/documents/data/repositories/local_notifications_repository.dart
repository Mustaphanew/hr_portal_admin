import '../../../../core/services/db/db_helper.dart';
import '../models/local_notification_model.dart';

class LocalNotificationsRepository {
  static const _table = 'notifications';

  final DbHelper _db;

  LocalNotificationsRepository({DbHelper? db}) : _db = db ?? DbHelper();

  /// Fetch a page of notifications ordered by newest first.
  Future<List<LocalNotification>> fetchPage({
    int limit = 30,
    int offset = 0,
  }) async {
    final rows = await _db.rawSelect(
      sql: 'SELECT * FROM $_table ORDER BY created_at DESC LIMIT ? OFFSET ?',
      params: [limit, offset],
    );
    return rows.map(LocalNotification.fromDbMap).toList();
  }

  /// Count unread notifications.
  Future<int> countUnread() async {
    return _db.countRows(table: _table, condition: 'is_read = 0');
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String id) async {
    await _db.update(
      table: _table,
      obj: {'is_read': 1},
      condition: 'id = ?',
      conditionParams: [id],
    );
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    await _db.execute(
      sql: 'UPDATE $_table SET is_read = 1 WHERE is_read = 0',
    );
  }

  /// Delete a single notification.
  Future<void> deleteById(String id) async {
    await _db.delete(
      table: _table,
      condition: 'id = ?',
      conditionParams: [id],
    );
  }

  /// Delete all notifications.
  Future<void> clearAll() async {
    await _db.execute(sql: 'DELETE FROM $_table');
  }
}
