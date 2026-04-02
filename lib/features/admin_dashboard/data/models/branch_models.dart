import 'package:equatable/equatable.dart';

class BranchCompany extends Equatable {
  final int id;
  final String? nameAr;
  final String? nameEn;

  const BranchCompany({required this.id, this.nameAr, this.nameEn});

  factory BranchCompany.fromJson(Map<String, dynamic> json) => BranchCompany(
    id: json['id'] as int,
    nameAr: json['name_ar'] as String?,
    nameEn: json['name_en'] as String?,
  );

  String get displayName => nameAr ?? nameEn ?? '';

  @override
  List<Object?> get props => [id, nameAr, nameEn];
}

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

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
    id: json['id'] as int,
    companyId: json['company_id'] as int,
    branchName: json['branch_name'] as String,
    branchNameEn: json['branch_name_en'] as String?,
    name: json['name'] as String?,
    nameEn: json['name_en'] as String?,
    code: json['branch_code'] as String? ?? json['code'] as String? ?? '',
    country: json['country'] as String?,
    city: json['city'] as String?,
    branchType: json['branch_type'] as String?,
    address: json['address'] as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    status: json['status'] as String? ?? 'active',
    company: json['company'] != null
      ? BranchCompany.fromJson(json['company'] as Map<String, dynamic>)
      : null,
  );

  /// Display name: branch_name first, fallback to name
  String get displayName => branchName;

  /// Location: city + country
  String get location => [city, country].where((s) => s != null && s.isNotEmpty).join(', ');

  @override
  List<Object?> get props => [id, companyId, branchName, code, status];
}

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
  String branchLabel(String allLabel) => branch?.name ?? branch?.branchName ?? allLabel;

  @override
  List<Object?> get props => [company, branch];
}

class BranchesData extends Equatable {
  final List<Branch> branches;
  final int total;

  const BranchesData({required this.branches, required this.total});

  factory BranchesData.fromJson(Map<String, dynamic> json) {
    final list = (json['branches'] as List?)
      ?.map((e) => Branch.fromJson(e as Map<String, dynamic>))
      .toList() ?? [];
    return BranchesData(
      branches: list,
      total: json['total'] as int? ?? list.length,
    );
  }

  @override
  List<Object?> get props => [branches, total];
}
