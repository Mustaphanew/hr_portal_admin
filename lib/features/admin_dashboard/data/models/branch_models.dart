import 'package:equatable/equatable.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Helpers
// ═══════════════════════════════════════════════════════════════════════════

String? _asString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

bool? _asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase();
    if (s == 'true' || s == '1' || s == 'yes') return true;
    if (s == 'false' || s == '0' || s == 'no') return false;
  }
  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// BranchCompany — lightweight company reference embedded in a branch
// ═══════════════════════════════════════════════════════════════════════════

class BranchCompany extends Equatable {
  final int id;
  final String? nameAr;
  final String? nameEn;

  const BranchCompany({required this.id, this.nameAr, this.nameEn});

  factory BranchCompany.fromJson(Map<String, dynamic> json) => BranchCompany(
        id: _asInt(json['id']) ?? 0,
        // The new admin API returns `name` (Arabic) and `name_en`. Older
        // responses used `name_ar` / `name_en`. Accept both.
        nameAr: _asString(json['name_ar']) ?? _asString(json['name']),
        nameEn: _asString(json['name_en']),
      );

  String get displayName => nameAr ?? nameEn ?? '';

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}

// ═══════════════════════════════════════════════════════════════════════════
// Branch
// ═══════════════════════════════════════════════════════════════════════════

class Branch extends Equatable {
  final int id;
  final int companyId;
  final String branchName;
  final String? branchNameEn;
  final String? name;
  final String? nameEn;
  final String code;
  final String? country;
  final String? city;
  final String? branchType;
  final String? address;
  final String? phone;
  final String? email;
  final String status;
  final BranchCompany? company;

  const Branch({
    required this.id,
    required this.companyId,
    required this.branchName,
    this.branchNameEn,
    this.name,
    this.nameEn,
    required this.code,
    this.country,
    this.city,
    this.branchType,
    this.address,
    this.phone,
    this.email,
    required this.status,
    this.company,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    // Resolve display name from any of the known fields (new admin API uses
    // `name`, older list endpoint uses `branch_name`).
    final nameRaw = _asString(json['name']);
    final branchNameRaw = _asString(json['branch_name']);
    final resolvedBranchName = branchNameRaw ?? nameRaw ?? '';

    return Branch(
      id: _asInt(json['id']) ?? 0,
      companyId: _asInt(json['company_id']) ??
          (json['company'] is Map<String, dynamic>
              ? _asInt((json['company'] as Map<String, dynamic>)['id']) ?? 0
              : 0),
      branchName: resolvedBranchName,
      branchNameEn: _asString(json['branch_name_en']),
      name: nameRaw,
      nameEn: _asString(json['name_en']),
      code: _asString(json['branch_code']) ?? _asString(json['code']) ?? '',
      country: _asString(json['country']),
      city: _asString(json['city']),
      branchType: _asString(json['branch_type']),
      address: _asString(json['address']),
      phone: _asString(json['phone']),
      email: _asString(json['email']),
      status: _asString(json['status']) ?? 'active',
      company: json['company'] is Map<String, dynamic>
          ? BranchCompany.fromJson(json['company'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Display name: branch_name first, fallback to name
  String get displayName => branchName;

  /// Location: city + country
  String get location =>
      [city, country].where((s) => s != null && s.isNotEmpty).join(', ');

  @override
  List<Object?> get props => [id, companyId, branchName, code, status];
}

// ═══════════════════════════════════════════════════════════════════════════
// BranchSelection
// ═══════════════════════════════════════════════════════════════════════════

/// Represents what the user selected: all, a company, or a specific branch.
class BranchSelection extends Equatable {
  final BranchCompany? company;
  final Branch? branch;

  const BranchSelection({this.company, this.branch});

  bool get isAll => company == null;
  bool get isCompany => company != null && branch == null;
  bool get isBranch => company != null && branch != null;

  int? get companyId => company?.id;
  int? get branchId => branch?.id;

  String companyLabel(String allLabel) => company?.displayName ?? allLabel;
  String branchLabel(String allLabel) =>
      branch?.name ?? branch?.branchName ?? allLabel;

  @override
  List<Object?> get props => [company, branch];
}

// ═══════════════════════════════════════════════════════════════════════════
// BranchesData — wrapper for GET /admin/branches
// ═══════════════════════════════════════════════════════════════════════════

class BranchesData extends Equatable {
  final List<Branch> branches;
  final int total;

  const BranchesData({required this.branches, required this.total});

  factory BranchesData.fromJson(Map<String, dynamic> json) {
    final raw =
        json['branches'] ?? json['items'] ?? json['data'] ?? const <dynamic>[];
    final list = (raw as List<dynamic>)
        .map((e) => Branch.fromJson(e as Map<String, dynamic>))
        .toList();
    return BranchesData(
      branches: list,
      total: _asInt(json['total']) ?? list.length,
    );
  }

  @override
  List<Object?> get props => [branches, total];
}

// ═══════════════════════════════════════════════════════════════════════════
// Company — full record returned by GET /admin/companies (Postman 00)
// ═══════════════════════════════════════════════════════════════════════════

class Company extends Equatable {
  final int id;
  final String name;
  final String? nameEn;
  final String? code;
  final String? logoUrl;
  final String? phone;
  final String? email;
  final String? address;
  final bool? isActive;

  const Company({
    required this.id,
    required this.name,
    this.nameEn,
    this.code,
    this.logoUrl,
    this.phone,
    this.email,
    this.address,
    this.isActive,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: _asInt(json['id']) ?? 0,
        // The new admin API returns `name` (Arabic). Some responses still ship
        // `name_ar` for legacy reasons.
        name: _asString(json['name']) ??
            _asString(json['name_ar']) ??
            _asString(json['title']) ??
            '',
        nameEn: _asString(json['name_en']),
        code: _asString(json['code']) ?? _asString(json['company_code']),
        logoUrl: _asString(json['logo_url']) ?? _asString(json['logo']),
        phone: _asString(json['phone']),
        email: _asString(json['email']),
        address: _asString(json['address']),
        isActive: _asBool(json['is_active']),
      );

  /// Display name in the user's preferred locale (Arabic first).
  String get displayName => name.isNotEmpty ? name : (nameEn ?? '');

  /// Convert to the lightweight [BranchCompany] used in selectors.
  BranchCompany toBranchCompany() => BranchCompany(
        id: id,
        nameAr: name,
        nameEn: nameEn,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        if (nameEn != null) 'name_en': nameEn,
        if (code != null) 'code': code,
        if (logoUrl != null) 'logo_url': logoUrl,
        if (phone != null) 'phone': phone,
        if (email != null) 'email': email,
        if (address != null) 'address': address,
        if (isActive != null) 'is_active': isActive,
      };

  @override
  List<Object?> get props =>
      [id, name, nameEn, code, logoUrl, phone, email, address, isActive];
}

// ═══════════════════════════════════════════════════════════════════════════
// CompaniesData — wrapper for GET /admin/companies
// ═══════════════════════════════════════════════════════════════════════════

class CompaniesData extends Equatable {
  final List<Company> companies;
  final int total;

  const CompaniesData({required this.companies, required this.total});

  factory CompaniesData.fromJson(Map<String, dynamic> json) {
    final raw = json['companies'] ??
        json['items'] ??
        json['data'] ??
        const <dynamic>[];
    final list = (raw as List<dynamic>)
        .map((e) => Company.fromJson(e as Map<String, dynamic>))
        .toList();
    return CompaniesData(
      companies: list,
      total: _asInt(json['total']) ?? list.length,
    );
  }

  @override
  List<Object?> get props => [companies, total];
}
