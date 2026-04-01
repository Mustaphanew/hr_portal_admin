import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/models/auth_models.dart';

// ── Auth Status ──

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final EmployeeProfile? employee;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.employee,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isManager => employee?.isManager ?? false;

  AuthState copyWith({
    AuthStatus? status,
    EmployeeProfile? employee,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      employee: employee ?? this.employee,
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
      // Restore saved employee profile
      final storage = sessionManager.storage;
      final profileJson = await storage.getEmployeeProfile();
      EmployeeProfile? employee;
      if (profileJson != null) {
        try {
          employee = EmployeeProfile.fromJson(profileJson);
        } catch (_) {}
      }
      state = AuthState(
        status: AuthStatus.authenticated,
        employee: employee,
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
      // Save employee profile for session restore
      await _ref.read(sessionManagerProvider).storage
          .saveEmployeeProfile(loginData.employee.toJson());
      state = AuthState(
        status: AuthStatus.authenticated,
        employee: loginData.employee,
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
