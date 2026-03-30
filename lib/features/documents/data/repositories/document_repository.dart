import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/document_models.dart';

/// Repository handling admin document operations.
///
/// Endpoints covered:
/// - D1: GET /admin/documents/categories
/// - D2: GET /admin/documents
/// - D3: GET /admin/documents/{id}
/// - D4: DELETE /admin/documents/{id}
class DocumentRepository {
  final ApiClient _client;

  DocumentRepository({required ApiClient client}) : _client = client;

  /// Fetch all document categories with counts.
  Future<DocumentCategoriesData> getCategories() async {
    final response = await _client.get<DocumentCategoriesData>(
      ApiConstants.adminDocumentCategories,
      fromJson: (json) =>
          DocumentCategoriesData.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Fetch paginated list of documents with optional filters.
  Future<AdminDocumentsData> getDocuments({
    String? category,
    int? employeeId,
    int? departmentId,
    String? search,
    int? perPage,
    int? page,
  }) async {
    final response = await _client.get<AdminDocumentsData>(
      ApiConstants.adminDocuments,
      fromJson: (json) =>
          AdminDocumentsData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        if (category != null) 'category': category,
        if (employeeId != null) 'employee_id': employeeId,
        if (departmentId != null) 'department_id': departmentId,
        if (search != null) 'search': search,
        if (perPage != null) 'per_page': perPage,
        if (page != null) 'page': page,
      },
    );
    return response.data!;
  }

  /// Fetch a single document by ID.
  Future<AdminDocument> getDocumentDetail(int id) async {
    final response = await _client.get<AdminDocument>(
      ApiConstants.adminDocumentDetail(id),
      fromJson: (json) =>
          AdminDocument.fromJson(json as Map<String, dynamic>),
    );
    return response.data!;
  }

  /// Delete a document by ID.
  Future<void> deleteDocument(int id) async {
    await _client.delete<void>(
      ApiConstants.adminDocumentDetail(id),
    );
  }
}
