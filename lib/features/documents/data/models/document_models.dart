import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Document Models (API D1-D5)
// ═══════════════════════════════════════════════════════════════════════════

/// A single document category with its metadata.
class DocumentCategory extends Equatable {
  final String key;
  final String label;
  final String icon;
  final int count;

  const DocumentCategory({
    required this.key,
    required this.label,
    required this.icon,
    required this.count,
  });

  factory DocumentCategory.fromJson(Map<String, dynamic> json) {
    return DocumentCategory(
      key: json['key'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'label': label,
        'icon': icon,
        'count': count,
      };

  @override
  List<Object?> get props => [key, label, icon, count];
}

/// Data payload returned by GET /admin/documents/categories.
class DocumentCategoriesData extends Equatable {
  final List<DocumentCategory> categories;
  final int totalDocuments;

  const DocumentCategoriesData({
    required this.categories,
    required this.totalDocuments,
  });

  factory DocumentCategoriesData.fromJson(Map<String, dynamic> json) {
    return DocumentCategoriesData(
      categories: (json['categories'] as List<dynamic>)
          .map((e) => DocumentCategory.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDocuments: json['total_documents'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'categories': categories.map((e) => e.toJson()).toList(),
        'total_documents': totalDocuments,
      };

  @override
  List<Object?> get props => [categories, totalDocuments];
}

/// Employee info embedded in a document.
class DocumentEmployee extends Equatable {
  final int id;
  final String name;

  const DocumentEmployee({
    required this.id,
    required this.name,
  });

  factory DocumentEmployee.fromJson(Map<String, dynamic> json) {
    return DocumentEmployee(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };

  @override
  List<Object?> get props => [id, name];
}

/// An admin document record.
class AdminDocument extends Equatable {
  final int id;
  final String title;
  final String category;
  final String categoryLabel;
  final DocumentEmployee? employee;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String uploadedAt;

  const AdminDocument({
    required this.id,
    required this.title,
    required this.category,
    required this.categoryLabel,
    this.employee,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  factory AdminDocument.fromJson(Map<String, dynamic> json) {
    return AdminDocument(
      id: json['id'] as int,
      title: json['title'] as String,
      category: json['category'] as String,
      categoryLabel: json['category_label'] as String,
      employee: json['employee'] != null
          ? DocumentEmployee.fromJson(
              json['employee'] as Map<String, dynamic>)
          : null,
      fileUrl: json['file_url'] as String,
      fileName: json['file_name'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int,
      uploadedAt: json['uploaded_at'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'category_label': categoryLabel,
        'employee': employee?.toJson(),
        'file_url': fileUrl,
        'file_name': fileName,
        'file_type': fileType,
        'file_size': fileSize,
        'uploaded_at': uploadedAt,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        categoryLabel,
        employee,
        fileUrl,
        fileName,
        fileType,
        fileSize,
        uploadedAt,
      ];
}

/// Data payload returned by GET /admin/documents.
class AdminDocumentsData extends Equatable {
  final List<AdminDocument> documents;
  final Pagination pagination;

  const AdminDocumentsData({
    required this.documents,
    required this.pagination,
  });

  factory AdminDocumentsData.fromJson(Map<String, dynamic> json) {
    return AdminDocumentsData(
      documents: (json['documents'] as List<dynamic>)
          .map((e) => AdminDocument.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'documents': documents.map((e) => e.toJson()).toList(),
        'meta': pagination.toJson(),
      };

  @override
  List<Object?> get props => [documents, pagination];
}
