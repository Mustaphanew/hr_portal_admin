import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/base_response.dart';
import '../models/ticket_sales_models.dart';

/// Repository for the admin ticket sales reports (Postman 07).
class TicketSalesRepository {
  final ApiClient _client;

  TicketSalesRepository({required ApiClient client}) : _client = client;

  /// List ticket sale records with rich filters.
  Future<BaseResponse<TicketSalesListData>> getTicketSales({
    int? companyId,
    int? branchId,
    String? month,
    String? dateFrom,
    String? dateTo,
    String? status,
    String? carrierCode,
    String? search,
    int? perPage,
    int? page,
  }) async {
    return _client.get<TicketSalesListData>(
      ApiConstants.adminTicketSalesReports,
      fromJson: (json) =>
          TicketSalesListData.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'month': ?month,
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'status': ?status,
        'carrier_code': ?carrierCode,
        'search': ?search,
        'per_page': ?perPage,
        'page': ?page,
      },
    );
  }

  /// Aggregated KPIs for ticket sales (Postman 07).
  Future<BaseResponse<TicketSalesKpis>> getTicketSalesKpis({
    int? companyId,
    int? branchId,
    String? month,
    String? dateFrom,
    String? dateTo,
    String? status,
  }) async {
    return _client.get<TicketSalesKpis>(
      ApiConstants.adminTicketSalesReportsKpis,
      fromJson: (json) =>
          TicketSalesKpis.fromJson(json as Map<String, dynamic>),
      queryParameters: {
        'company_id': ?companyId,
        'branch_id': ?branchId,
        'month': ?month,
        'date_from': ?dateFrom,
        'date_to': ?dateTo,
        'status': ?status,
      },
    );
  }
}
