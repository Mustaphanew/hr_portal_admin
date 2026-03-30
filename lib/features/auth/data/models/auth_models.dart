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
      id: json['id'] as int,
      name: json['name'] as String,
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
      id: json['id'] as int,
      name: json['name'] as String?,
      companyCode: json['company_code'] as String,
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
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      jobTitle: json['job_title'] as String,
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

    return EmployeeProfile(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      address: json['address'] as String?,
      photoUrl: json['photo_url'] as String?,
      initials: json['initials'] as String?,
      employmentStatus: json['employment_status'] as String,
      jobTitle: json['job_title'] as String?,
      hireDate: json['hire_date'] as String?,
      gender: json['gender'] as String?,
      nationality: json['nationality'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      idNumber: json['id_number'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      department: json['department'] != null
          ? ProfileDepartment.fromJson(
              json['department'] as Map<String, dynamic>)
          : null,
      company: json['company'] != null
          ? ProfileCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
      manager: json['manager'] != null
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
