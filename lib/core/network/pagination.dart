import 'package:equatable/equatable.dart';

/// Pagination model as returned by the API contract v1.0.0 (§10.6).
///
/// Example:
/// ```json
/// {
///   "current_page": 1,
///   "last_page": 3,
///   "per_page": 15,
///   "total": 45
/// }
/// ```
class Pagination extends Equatable {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const Pagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: (json['current_page'] ?? 1) as int,
      lastPage: (json['last_page'] ?? 1) as int,
      perPage: (json['per_page'] ?? 15) as int,
      total: (json['total'] ?? 0) as int,
    );
  }

  /// Parse pagination from a parent JSON that may contain 'meta' or 'pagination'.
  static Pagination fromParent(Map<String, dynamic> json) {
    final meta = json['meta'] ?? json['pagination'];
    if (meta is Map<String, dynamic>) {
      return Pagination.fromJson(meta);
    }
    return const Pagination(currentPage: 1, lastPage: 1, perPage: 50, total: 0);
  }

  Map<String, dynamic> toJson() => {
        'current_page': currentPage,
        'last_page': lastPage,
        'per_page': perPage,
        'total': total,
      };

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
  bool get isFirstPage => currentPage <= 1;
  bool get isLastPage => currentPage >= lastPage;

  @override
  List<Object?> get props => [currentPage, lastPage, perPage, total];
}
