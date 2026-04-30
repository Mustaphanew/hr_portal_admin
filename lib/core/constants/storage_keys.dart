class StorageKeys {
  StorageKeys._();

  static const String token = 'admin_access_token';
  static const String adminId = 'admin_id';
  static const String companyId = 'company_id';
  static const String lastBaseUrl = 'last_base_url';
  static const String locale = 'app_locale';
  static const String themeMode = 'app_theme_mode';
  static const String employeeProfile = 'employee_profile';

  // ── Login envelope extras (captured 2026-04-29 from real /admin/auth/login)
  static const String adminUser = 'admin_user';
  static const String adminAccess = 'admin_access';     // roles + permissions
  static const String adminScope = 'admin_scope';       // companies + branches
  static const String adminModules = 'admin_modules';   // per-module CRUD flags
  static const String adminDefaults = 'admin_defaults'; // default company/branch
  static const String tokenExpiresAt = 'admin_token_expires_at';
}
