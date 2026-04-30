import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Nested models
// ═══════════════════════════════════════════════════════════════════════════

/// Department info embedded in the employee profile.
class ProfileDepartment extends Equatable {
  final int id;
  final String name;
  final String? nameEn;

  const ProfileDepartment({
    required this.id,
    required this.name,
    this.nameEn,
  });

  factory ProfileDepartment.fromJson(Map<String, dynamic> json) {
    return ProfileDepartment(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
      };

  @override
  List<Object?> get props => [id, name, nameEn];
}

/// Company info embedded in the employee profile.
class ProfileCompany extends Equatable {
  final int id;
  final String? name;
  final String companyCode;

  const ProfileCompany({
    required this.id,
    this.name,
    required this.companyCode,
  });

  factory ProfileCompany.fromJson(Map<String, dynamic> json) {
    return ProfileCompany(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name'] as String?,
      companyCode: (json['company_code'] as String?) ??
          (json['code'] as String?) ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'company_code': companyCode,
      };

  @override
  List<Object?> get props => [id, name, companyCode];
}

/// Manager info embedded in the employee profile.
class ProfileManager extends Equatable {
  final int id;
  final String code;
  final String name;
  final String jobTitle;

  const ProfileManager({
    required this.id,
    required this.code,
    required this.name,
    required this.jobTitle,
  });

  factory ProfileManager.fromJson(Map<String, dynamic> json) {
    return ProfileManager(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      code: (json['employee_number'] as String?) ??
          (json['code'] as String?) ??
          '',
      name: (json['name'] as String?) ?? '',
      jobTitle: (json['job_title'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'job_title': jobTitle,
      };

  @override
  List<Object?> get props => [id, code, name, jobTitle];
}

// ═══════════════════════════════════════════════════════════════════════════
// Core models
// ═══════════════════════════════════════════════════════════════════════════

/// Full employee profile returned by login and profile endpoints.
class EmployeeProfile extends Equatable {
  final int id;
  final String code;
  final String name;
  final String? nameEn;
  final String? email;
  final String? phone;
  final String? mobile;
  final String? address;
  final String? photoUrl;
  final String? initials;
  final String employmentStatus;
  final String? jobTitle;
  final String? hireDate;
  final String? gender;
  final String? nationality;
  final String? dateOfBirth;
  final String? idNumber;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final ProfileDepartment? department;
  final ProfileCompany? company;
  final ProfileManager? manager;
  final bool isManager;

  const EmployeeProfile({
    required this.id,
    required this.code,
    required this.name,
    this.nameEn,
    this.email,
    this.phone,
    this.mobile,
    this.address,
    this.photoUrl,
    this.initials,
    required this.employmentStatus,
    this.jobTitle,
    this.hireDate,
    this.gender,
    this.nationality,
    this.dateOfBirth,
    this.idNumber,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.department,
    this.company,
    this.manager,
    required this.isManager,
  });

  factory EmployeeProfile.fromJson(Map<String, dynamic> json) {
    // is_manager may arrive as int (0/1) or bool from the API.
    final rawIsManager = json['is_manager'];
    final bool isManager;
    if (rawIsManager is bool) {
      isManager = rawIsManager;
    } else if (rawIsManager is int) {
      isManager = rawIsManager != 0;
    } else {
      isManager = false;
    }

    String? asStr(dynamic v) {
      if (v == null) return null;
      if (v is String) return v;
      return v.toString();
    }

    // The admin login endpoint returns a slimmer "company" representation:
    // sometimes a nested object, sometimes only `company_id`.
    ProfileCompany? company;
    final rawCompany = json['company'];
    if (rawCompany is Map<String, dynamic>) {
      company = ProfileCompany.fromJson(rawCompany);
    } else if (json['company_id'] != null) {
      company = ProfileCompany(
        id: (json['company_id'] is int)
            ? json['company_id'] as int
            : int.tryParse(json['company_id'].toString()) ?? 0,
        name: asStr(json['company_name']),
        companyCode: asStr(json['company_code']) ?? '',
      );
    }

    return EmployeeProfile(
      id: json['id'] as int,
      // Accept `employee_number` (admin login) or `code` (employee API).
      code: asStr(json['employee_number']) ?? asStr(json['code']) ?? '',
      name: asStr(json['name']) ?? '',
      nameEn: asStr(json['name_en']),
      email: asStr(json['email']),
      phone: asStr(json['phone']),
      mobile: asStr(json['mobile']),
      address: asStr(json['address']),
      photoUrl: asStr(json['photo_url']),
      initials: asStr(json['initials']),
      employmentStatus: asStr(json['employment_status']) ?? 'unknown',
      jobTitle: asStr(json['job_title']),
      hireDate: asStr(json['hire_date']),
      gender: asStr(json['gender']),
      nationality: asStr(json['nationality']),
      dateOfBirth: asStr(json['date_of_birth']),
      idNumber: asStr(json['id_number']),
      emergencyContactName: asStr(json['emergency_contact_name']),
      emergencyContactPhone: asStr(json['emergency_contact_phone']),
      department: json['department'] is Map<String, dynamic>
          ? ProfileDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      company: company,
      manager: json['manager'] is Map<String, dynamic>
          ? ProfileManager.fromJson(json['manager'] as Map<String, dynamic>)
          : null,
      isManager: isManager,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'name_en': nameEn,
        'email': email,
        'phone': phone,
        'mobile': mobile,
        'address': address,
        'photo_url': photoUrl,
        'initials': initials,
        'employment_status': employmentStatus,
        'job_title': jobTitle,
        'hire_date': hireDate,
        'gender': gender,
        'nationality': nationality,
        'date_of_birth': dateOfBirth,
        'id_number': idNumber,
        'emergency_contact_name': emergencyContactName,
        'emergency_contact_phone': emergencyContactPhone,
        'department': department?.toJson(),
        'company': company?.toJson(),
        'manager': manager?.toJson(),
        'is_manager': isManager,
      };

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        nameEn,
        email,
        phone,
        mobile,
        address,
        photoUrl,
        initials,
        employmentStatus,
        jobTitle,
        hireDate,
        gender,
        nationality,
        dateOfBirth,
        idNumber,
        emergencyContactName,
        emergencyContactPhone,
        department,
        company,
        manager,
        isManager,
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
// Admin user (separate from employee — represents the login account itself)
// ═══════════════════════════════════════════════════════════════════════════

class AdminUser extends Equatable {
  final int id;
  final String name;
  final String username;
  final String? email;
  final String? phone;
  final String? avatar;
  final String locale;
  final bool isActive;
  final bool twoFactorEnabled;

  const AdminUser({
    required this.id,
    required this.name,
    required this.username,
    this.email,
    this.phone,
    this.avatar,
    this.locale = 'ar',
    this.isActive = true,
    this.twoFactorEnabled = false,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      username: (json['username'] as String?) ?? '',
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      locale: (json['locale'] as String?) ?? 'ar',
      isActive: json['is_active'] as bool? ?? true,
      twoFactorEnabled: json['two_factor_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'avatar': avatar,
        'locale': locale,
        'is_active': isActive,
        'two_factor_enabled': twoFactorEnabled,
      };

  @override
  List<Object?> get props =>
      [id, name, username, email, phone, avatar, locale, isActive, twoFactorEnabled];
}

// ═══════════════════════════════════════════════════════════════════════════
// Admin role (one of many a user may have)
// ═══════════════════════════════════════════════════════════════════════════

class AdminRole extends Equatable {
  final int id;
  final String name;
  final String slug;
  final int? companyId;

  const AdminRole({
    required this.id,
    required this.name,
    required this.slug,
    this.companyId,
  });

  factory AdminRole.fromJson(Map<String, dynamic> json) {
    return AdminRole(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      slug: (json['slug'] as String?) ?? '',
      companyId: json['company_id'] is num
          ? (json['company_id'] as num).toInt()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        if (companyId != null) 'company_id': companyId,
      };

  @override
  List<Object?> get props => [id, name, slug, companyId];
}

// ═══════════════════════════════════════════════════════════════════════════
// Admin access — what the logged-in admin is allowed to do
// ═══════════════════════════════════════════════════════════════════════════

class AdminAccess extends Equatable {
  final bool isAdminPortalUser;
  final List<AdminRole> roles;
  /// Flat list of permission slugs (e.g. "employees.read", "expenses.approve").
  /// We expose it as a Set<String> via [permissionSet] for O(1) lookups.
  final List<String> permissions;

  const AdminAccess({
    this.isAdminPortalUser = false,
    this.roles = const [],
    this.permissions = const [],
  });

  Set<String> get permissionSet => permissions.toSet();

  bool hasPermission(String slug) => permissionSet.contains(slug);

  /// Check if user has any of the given permissions.
  bool hasAny(Iterable<String> slugs) {
    final set = permissionSet;
    return slugs.any(set.contains);
  }

  /// Check if user has all of the given permissions.
  bool hasAll(Iterable<String> slugs) {
    final set = permissionSet;
    return slugs.every(set.contains);
  }

  factory AdminAccess.fromJson(Map<String, dynamic> json) {
    return AdminAccess(
      isAdminPortalUser: json['is_admin_portal_user'] as bool? ?? false,
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AdminRole.fromJson)
          .toList(),
      permissions: (json['permissions'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'is_admin_portal_user': isAdminPortalUser,
        'roles': roles.map((r) => r.toJson()).toList(),
        'permissions': permissions,
      };

  @override
  List<Object?> get props => [isAdminPortalUser, roles, permissions];
}

// ═══════════════════════════════════════════════════════════════════════════
// Admin scope — companies & branches the admin can operate on
// ═══════════════════════════════════════════════════════════════════════════

class AllowedCompany extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String? code;
  final bool isActive;

  const AllowedCompany({
    required this.id,
    required this.name,
    this.nameEn,
    this.code,
    this.isActive = true,
  });

  factory AllowedCompany.fromJson(Map<String, dynamic> json) {
    return AllowedCompany(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      nameEn: json['name_en'] as String?,
      code: json['code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'name_en': nameEn,
        'code': code,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, name, nameEn, code, isActive];
}

class AllowedBranch extends Equatable {
  final int id;
  final int companyId;
  final String name;
  final String? code;
  final bool isActive;

  const AllowedBranch({
    required this.id,
    required this.companyId,
    required this.name,
    this.code,
    this.isActive = true,
  });

  factory AllowedBranch.fromJson(Map<String, dynamic> json) {
    return AllowedBranch(
      id: (json['id'] as num).toInt(),
      companyId: (json['company_id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      code: json['code'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'company_id': companyId,
        'name': name,
        'code': code,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [id, companyId, name, code, isActive];
}

class AdminScope extends Equatable {
  final List<int> companyIds;
  final List<AllowedCompany> allowedCompanies;
  /// "restricted" or "all" — when "all", any branch is permitted.
  final String branchScopeMode;
  final List<int> branchIds;
  final List<AllowedBranch> allowedBranches;

  const AdminScope({
    this.companyIds = const [],
    this.allowedCompanies = const [],
    this.branchScopeMode = 'restricted',
    this.branchIds = const [],
    this.allowedBranches = const [],
  });

  factory AdminScope.fromJson(Map<String, dynamic> json) {
    return AdminScope(
      companyIds: (json['company_ids'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      allowedCompanies: (json['allowed_companies'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AllowedCompany.fromJson)
          .toList(),
      branchScopeMode:
          (json['branch_scope_mode'] as String?) ?? 'restricted',
      branchIds: (json['branch_ids'] as List<dynamic>? ?? const [])
          .map((e) => (e as num).toInt())
          .toList(),
      allowedBranches: (json['allowed_branches'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(AllowedBranch.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'company_ids': companyIds,
        'allowed_companies':
            allowedCompanies.map((c) => c.toJson()).toList(),
        'branch_scope_mode': branchScopeMode,
        'branch_ids': branchIds,
        'allowed_branches':
            allowedBranches.map((b) => b.toJson()).toList(),
      };

  @override
  List<Object?> get props => [
        companyIds,
        allowedCompanies,
        branchScopeMode,
        branchIds,
        allowedBranches,
      ];
}

// ═══════════════════════════════════════════════════════════════════════════
// Module access — per-module CRUD flags returned by /admin/auth/login
// ═══════════════════════════════════════════════════════════════════════════

class ModuleAccess extends Equatable {
  final bool canRead;
  final bool canCreate;
  final bool canUpdate;
  final bool canDelete;
  final bool canApprove;

  const ModuleAccess({
    this.canRead = false,
    this.canCreate = false,
    this.canUpdate = false,
    this.canDelete = false,
    this.canApprove = false,
  });

  factory ModuleAccess.fromJson(Map<String, dynamic> json) {
    return ModuleAccess(
      canRead: json['can_read'] as bool? ?? false,
      canCreate: json['can_create'] as bool? ?? false,
      canUpdate: json['can_update'] as bool? ?? false,
      canDelete: json['can_delete'] as bool? ?? false,
      canApprove: json['can_approve'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'can_read': canRead,
        'can_create': canCreate,
        'can_update': canUpdate,
        'can_delete': canDelete,
        'can_approve': canApprove,
      };

  @override
  List<Object?> get props =>
      [canRead, canCreate, canUpdate, canDelete, canApprove];
}

class AdminModules extends Equatable {
  /// Raw map keyed by module name (e.g. "employees", "leave_requests").
  final Map<String, ModuleAccess> modules;

  const AdminModules({this.modules = const {}});

  ModuleAccess access(String moduleName) =>
      modules[moduleName] ?? const ModuleAccess();

  factory AdminModules.fromJson(Map<String, dynamic> json) {
    final result = <String, ModuleAccess>{};
    json.forEach((k, v) {
      if (v is Map<String, dynamic>) {
        result[k] = ModuleAccess.fromJson(v);
      }
    });
    return AdminModules(modules: result);
  }

  Map<String, dynamic> toJson() =>
      modules.map((k, v) => MapEntry(k, v.toJson()));

  @override
  List<Object?> get props => [modules];
}

// ═══════════════════════════════════════════════════════════════════════════
// Defaults — where new entries default to (selected company/branch)
// ═══════════════════════════════════════════════════════════════════════════

class AdminDefaults extends Equatable {
  final int? companyId;
  final int? branchId;

  const AdminDefaults({this.companyId, this.branchId});

  factory AdminDefaults.fromJson(Map<String, dynamic> json) {
    return AdminDefaults(
      companyId: (json['company_id'] as num?)?.toInt(),
      branchId: (json['branch_id'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'company_id': companyId,
        'branch_id': branchId,
      };

  @override
  List<Object?> get props => [companyId, branchId];
}

// ═══════════════════════════════════════════════════════════════════════════
// LoginData — full payload returned by POST /admin/auth/login
// ═══════════════════════════════════════════════════════════════════════════

/// Data payload returned by the login endpoint (A1).
///
/// Matches the real backend response captured 2026-04-29:
/// `{ token, token_type, user, employee, access, scope, modules, defaults,
///    expires_at }`
class LoginData extends Equatable {
  final String token;
  final String tokenType;
  final AdminUser? user;
  final EmployeeProfile employee;
  final AdminAccess access;
  final AdminScope scope;
  final AdminModules modules;
  final AdminDefaults defaults;
  final String? expiresAt;

  const LoginData({
    required this.token,
    required this.tokenType,
    required this.employee,
    this.user,
    this.access = const AdminAccess(),
    this.scope = const AdminScope(),
    this.modules = const AdminModules(),
    this.defaults = const AdminDefaults(),
    this.expiresAt,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String,
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      user: json['user'] is Map<String, dynamic>
          ? AdminUser.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      employee:
          EmployeeProfile.fromJson(json['employee'] as Map<String, dynamic>),
      access: json['access'] is Map<String, dynamic>
          ? AdminAccess.fromJson(json['access'] as Map<String, dynamic>)
          : const AdminAccess(),
      scope: json['scope'] is Map<String, dynamic>
          ? AdminScope.fromJson(json['scope'] as Map<String, dynamic>)
          : const AdminScope(),
      modules: json['modules'] is Map<String, dynamic>
          ? AdminModules.fromJson(json['modules'] as Map<String, dynamic>)
          : const AdminModules(),
      defaults: json['defaults'] is Map<String, dynamic>
          ? AdminDefaults.fromJson(json['defaults'] as Map<String, dynamic>)
          : const AdminDefaults(),
      expiresAt: json['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'token_type': tokenType,
        'user': user?.toJson(),
        'employee': employee.toJson(),
        'access': access.toJson(),
        'scope': scope.toJson(),
        'modules': modules.toJson(),
        'defaults': defaults.toJson(),
        'expires_at': expiresAt,
      };

  @override
  List<Object?> get props => [
        token,
        tokenType,
        user,
        employee,
        access,
        scope,
        modules,
        defaults,
        expiresAt,
      ];
}

/// Data payload returned by the logout-all endpoint (A3).
class LogoutAllData extends Equatable {
  final int revokedTokens;

  const LogoutAllData({required this.revokedTokens});

  factory LogoutAllData.fromJson(Map<String, dynamic> json) {
    return LogoutAllData(
      revokedTokens: json['revoked_tokens'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'revoked_tokens': revokedTokens,
      };

  @override
  List<Object?> get props => [revokedTokens];
}
