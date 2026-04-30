import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/storage_keys.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/auth_models.dart';

// ── Auth Status ──

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final EmployeeProfile? employee;
  final AdminUser? user;
  final AdminAccess access;
  final AdminScope scope;
  final AdminModules modules;
  final AdminDefaults defaults;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.employee,
    this.user,
    this.access = const AdminAccess(),
    this.scope = const AdminScope(),
    this.modules = const AdminModules(),
    this.defaults = const AdminDefaults(),
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isManager => employee?.isManager ?? false;

  /// Quick permission check by slug. Returns false if no permissions loaded.
  bool can(String slug) => access.hasPermission(slug);

  /// Module access lookup by name (e.g. "employees", "leave_requests").
  ModuleAccess module(String name) => modules.access(name);

  AuthState copyWith({
    AuthStatus? status,
    EmployeeProfile? employee,
    AdminUser? user,
    AdminAccess? access,
    AdminScope? scope,
    AdminModules? modules,
    AdminDefaults? defaults,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
      user: user ?? this.user,
      access: access ?? this.access,
      scope: scope ?? this.scope,
      modules: modules ?? this.modules,
      defaults: defaults ?? this.defaults,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ── Auth Notifier ──

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref _ref;
  StreamSubscription<bool>? _authSub;

  AuthNotifier(this._ref) : super(const AuthState()) {
    _authSub = _ref.read(sessionManagerProvider).authStateStream.listen((isAuth) {
      if (!isAuth && state.isAuthenticated) {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  Future<void> checkSession() async {
    final sessionManager = _ref.read(sessionManagerProvider);
    final hasSession = await sessionManager.tryRestoreSession();
    if (hasSession) {
      // Restore the full login envelope from secure storage so the app boots
      // straight into an authenticated state with permissions / scope / etc.
      final storage = sessionManager.storage;
      final profileJson = await storage.getEmployeeProfile();
      final userJson = await storage.readJsonMap(StorageKeys.adminUser);
      final accessJson = await storage.readJsonMap(StorageKeys.adminAccess);
      final scopeJson = await storage.readJsonMap(StorageKeys.adminScope);
      final modulesJson = await storage.readJsonMap(StorageKeys.adminModules);
      final defaultsJson = await storage.readJsonMap(StorageKeys.adminDefaults);

      EmployeeProfile? employee;
      if (profileJson != null) {
        try {
          employee = EmployeeProfile.fromJson(profileJson);
        } catch (_) {}
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        employee: employee,
        user: userJson != null ? AdminUser.fromJson(userJson) : null,
        access: accessJson != null
            ? AdminAccess.fromJson(accessJson)
            : const AdminAccess(),
        scope: scopeJson != null
            ? AdminScope.fromJson(scopeJson)
            : const AdminScope(),
        modules: modulesJson != null
            ? AdminModules.fromJson(modulesJson)
            : const AdminModules(),
        defaults: defaultsJson != null
            ? AdminDefaults.fromJson(defaultsJson)
            : const AdminDefaults(),
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login({
    required String username,
    required String password,
    String? deviceName,
    String? fcmToken,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final loginData = await _ref.read(authRepositoryProvider).login(
        username: username,
        password: password,
        deviceName: deviceName,
        fcmToken: fcmToken,
      );

      // Persist the full envelope so checkSession() can restore everything
      // on the next launch without re-hitting the network.
      final storage = _ref.read(sessionManagerProvider).storage;
      await storage.saveEmployeeProfile(loginData.employee.toJson());
      if (loginData.user != null) {
        await storage.saveJsonMap(StorageKeys.adminUser, loginData.user!.toJson());
      }
      await storage.saveJsonMap(StorageKeys.adminAccess, loginData.access.toJson());
      await storage.saveJsonMap(StorageKeys.adminScope, loginData.scope.toJson());
      await storage.saveJsonMap(StorageKeys.adminModules, loginData.modules.toJson());
      await storage.saveJsonMap(StorageKeys.adminDefaults, loginData.defaults.toJson());
      await storage.saveTokenExpiresAt(loginData.expiresAt);

      state = AuthState(
        status: AuthStatus.authenticated,
        employee: loginData.employee,
        user: loginData.user,
        access: loginData.access,
        scope: loginData.scope,
        modules: loginData.modules,
        defaults: loginData.defaults,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        status: AuthStatus.unauthenticated,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _ref.read(authRepositoryProvider).logout();
    } finally {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

// ── Providers ──

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref),
);

// ── Convenience providers (gating UI by permission / module / scope) ──

/// Set of permission slugs the current admin holds. O(1) lookups.
final permissionsProvider = Provider<Set<String>>((ref) {
  return ref.watch(authProvider).access.permissionSet;
});

/// Family: returns true if the current admin has [slug] permission.
/// Usage: `final canEdit = ref.watch(canProvider('employees.update'));`
final canProvider = Provider.family<bool, String>((ref, slug) {
  return ref.watch(permissionsProvider).contains(slug);
});

/// Family: returns ModuleAccess for a given module name (e.g. "employees").
final moduleAccessProvider =
    Provider.family<ModuleAccess, String>((ref, name) {
  return ref.watch(authProvider).modules.access(name);
});

/// Companies the current admin can operate on (from the login envelope).
final allowedCompaniesProvider = Provider<List<AllowedCompany>>((ref) {
  return ref.watch(authProvider).scope.allowedCompanies;
});

/// Branches the current admin can operate on (from the login envelope).
final allowedBranchesProvider = Provider<List<AllowedBranch>>((ref) {
  return ref.watch(authProvider).scope.allowedBranches;
});
