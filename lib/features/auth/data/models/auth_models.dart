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

/// Data payload returned by the login endpoint (A1).
class LoginData extends Equatable {
  final String token;
  final String tokenType;
  final EmployeeProfile employee;
  final String? expiresAt;

  const LoginData({
    required this.token,
    required this.tokenType,
    required this.employee,
    this.expiresAt,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token'] as String,
      tokenType: json['token_type'] as String,
      employee:
          EmployeeProfile.fromJson(json['employee'] as Map<String, dynamic>),
      expiresAt: json['expires_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'token_type': tokenType,
        'employee': employee.toJson(),
        'expires_at': expiresAt,
      };

  @override
  List<Object?> get props => [token, tokenType, employee, expiresAt];
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
