import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.token, value: token);
  }

  Future<String?> getToken() async {
    return _storage.read(key: StorageKeys.token);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> saveAdminId(int id) async {
    await _storage.write(key: StorageKeys.adminId, value: id.toString());
  }

  Future<int?> getAdminId() async {
    final value = await _storage.read(key: StorageKeys.adminId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveCompanyId(int id) async {
    await _storage.write(key: StorageKeys.companyId, value: id.toString());
  }

  Future<int?> getCompanyId() async {
    final value = await _storage.read(key: StorageKeys.companyId);
    if (value == null) return null;
    return int.tryParse(value);
  }

  Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: StorageKeys.lastBaseUrl, value: url);
  }

  Future<String?> getLastBaseUrl() async {
    return _storage.read(key: StorageKeys.lastBaseUrl);
  }

  Future<void> saveEmployeeProfile(Map<String, dynamic> profileJson) async {
    await _storage.write(
      key: StorageKeys.employeeProfile,
      value: jsonEncode(profileJson),
    );
  }

  Future<Map<String, dynamic>?> getEmployeeProfile() async {
    final value = await _storage.read(key: StorageKeys.employeeProfile);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  // ── Login envelope extras (admin user/access/scope/modules/defaults) ──

  Future<void> saveJsonMap(String key, Map<String, dynamic> data) async {
    await _storage.write(key: key, value: jsonEncode(data));
  }

  Future<Map<String, dynamic>?> readJsonMap(String key) async {
    final value = await _storage.read(key: key);
    if (value == null || value.isEmpty) return null;
    try {
      return jsonDecode(value) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveTokenExpiresAt(String? iso) async {
    if (iso == null) {
      await _storage.delete(key: StorageKeys.tokenExpiresAt);
    } else {
      await _storage.write(key: StorageKeys.tokenExpiresAt, value: iso);
    }
  }

  Future<String?> getTokenExpiresAt() async {
    return _storage.read(key: StorageKeys.tokenExpiresAt);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: StorageKeys.token);
    await _storage.delete(key: StorageKeys.adminId);
    await _storage.delete(key: StorageKeys.companyId);
    await _storage.delete(key: StorageKeys.employeeProfile);
    await _storage.delete(key: StorageKeys.adminUser);
    await _storage.delete(key: StorageKeys.adminAccess);
    await _storage.delete(key: StorageKeys.adminScope);
    await _storage.delete(key: StorageKeys.adminModules);
    await _storage.delete(key: StorageKeys.adminDefaults);
    await _storage.delete(key: StorageKeys.tokenExpiresAt);
  }
}
