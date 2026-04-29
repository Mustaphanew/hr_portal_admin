import 'package:equatable/equatable.dart';

import '../../../../core/network/pagination.dart';

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

double? _asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// TicketSaleRecord
// ═══════════════════════════════════════════════════════════════════════════

class TicketSaleRecord extends Equatable {
  final int id;
  final String? ticketNumber;
  final String? pnr;
  final String? carrierCode;
  final String? carrierName;
  final String? passengerName;
  final String? routeFrom;
  final String? routeTo;
  final String? issueDate;
  final String? travelDate;
  final String status;

  /// Branch / company / employee references — kept loose because Postman does
  /// not pin a precise schema.
  final int? branchId;
  final String? branchName;
  final int? companyId;
  final String? companyName;
  final int? employeeId;
  final String? employeeName;

  final double? fareAmount;
  final double? taxAmount;
  final double? totalAmount;
  final double? commissionAmount;
  final double? netAmount;
  final String? currency;

  final String? notes;
  final String? createdAt;

  const TicketSaleRecord({
    required this.id,
    this.ticketNumber,
    this.pnr,
    this.carrierCode,
    this.carrierName,
    this.passengerName,
    this.routeFrom,
    this.routeTo,
    this.issueDate,
    this.travelDate,
    required this.status,
    this.branchId,
    this.branchName,
    this.companyId,
    this.companyName,
    this.employeeId,
    this.employeeName,
    this.fareAmount,
    this.taxAmount,
    this.totalAmount,
    this.commissionAmount,
    this.netAmount,
    this.currency,
    this.notes,
    this.createdAt,
  });

  factory TicketSaleRecord.fromJson(Map<String, dynamic> json) {
    String? nested(String parentKey, String childKey) {
      final v = json[parentKey];
      return v is Map<String, dynamic> ? _asString(v[childKey]) : null;
    }

    int? nestedId(String parentKey) {
      final v = json[parentKey];
      return v is Map<String, dynamic> ? _asInt(v['id']) : null;
    }

    return TicketSaleRecord(
      id: _asInt(json['id']) ?? 0,
      ticketNumber:
          _asString(json['ticket_number']) ?? _asString(json['ticket_no']),
      pnr: _asString(json['pnr']) ?? _asString(json['pnr_code']),
      carrierCode: _asString(json['carrier_code']) ??
          _asString(json['airline_code']) ??
          nested('carrier', 'code'),
      carrierName: _asString(json['carrier_name']) ??
          _asString(json['airline_name']) ??
          nested('carrier', 'name'),
      passengerName:
          _asString(json['passenger_name']) ?? _asString(json['pax_name']),
      routeFrom: _asString(json['route_from']) ??
          _asString(json['origin']) ??
          _asString(json['from']),
      routeTo: _asString(json['route_to']) ??
          _asString(json['destination']) ??
          _asString(json['to']),
      issueDate: _asString(json['issue_date']) ?? _asString(json['issued_at']),
      travelDate: _asString(json['travel_date']) ?? _asString(json['departure_date']),
      status: _asString(json['status']) ?? 'issued',
      branchId: _asInt(json['branch_id']) ?? nestedId('branch'),
      branchName: _asString(json['branch_name']) ?? nested('branch', 'name'),
      companyId: _asInt(json['company_id']) ?? nestedId('company'),
      companyName: _asString(json['company_name']) ?? nested('company', 'name'),
      employeeId: _asInt(json['employee_id']) ?? nestedId('employee'),
      employeeName:
          _asString(json['employee_name']) ?? nested('employee', 'name'),
      fareAmount: _asDouble(json['fare_amount']) ?? _asDouble(json['fare']),
      taxAmount: _asDouble(json['tax_amount']) ?? _asDouble(json['tax']),
      totalAmount:
          _asDouble(json['total_amount']) ?? _asDouble(json['amount']),
      commissionAmount: _asDouble(json['commission_amount']) ??
          _asDouble(json['commission']),
      netAmount: _asDouble(json['net_amount']),
      currency: _asString(json['currency']) ?? _asString(json['currency_code']),
      notes: _asString(json['notes']),
      createdAt: _asString(json['created_at']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        pnr,
        carrierCode,
        carrierName,
        passengerName,
        routeFrom,
        routeTo,
        issueDate,
        travelDate,
        status,
        branchId,
        branchName,
        companyId,
        companyName,
        employeeId,
        employeeName,
        fareAmount,
        taxAmount,
        totalAmount,
        commissionAmount,
        netAmount,
        currency,
        notes,
        createdAt,
      ];
}

class TicketSalesListData extends Equatable {
  final List<TicketSaleRecord> tickets;
  final Pagination? pagination;

  const TicketSalesListData({required this.tickets, this.pagination});

  factory TicketSalesListData.fromJson(Map<String, dynamic> json) {
    final raw = json['tickets'] ??
        json['ticket_sales'] ??
        json['items'] ??
        json['data'] ??
        const <dynamic>[];
    return TicketSalesListData(
      tickets: (raw as List<dynamic>)
          .map((e) => TicketSaleRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: (json['meta'] ?? json['pagination']) != null
          ? Pagination.fromParent(json)
          : null,
    );
  }

  @override
  List<Object?> get props => [tickets, pagination];
}

// ═══════════════════════════════════════════════════════════════════════════
// TicketSalesKpis (Postman 07 — /admin/ticket-sales-reports/kpis)
// ═══════════════════════════════════════════════════════════════════════════

class TicketSalesKpis extends Equatable {
  final int totalTickets;
  final int issued;
  final int? cancelled;
  final int? refunded;
  final int? exchanged;
  final double totalSales;
  final double? totalFare;
  final double? totalTax;
  final double? totalCommission;
  final double? totalNet;
  final String? currency;

  /// Optional breakdowns: top carriers / top branches.
  final List<Map<String, dynamic>> byCarrier;
  final List<Map<String, dynamic>> byBranch;

  const TicketSalesKpis({
    required this.totalTickets,
    required this.issued,
    this.cancelled,
    this.refunded,
    this.exchanged,
    required this.totalSales,
    this.totalFare,
    this.totalTax,
    this.totalCommission,
    this.totalNet,
    this.currency,
    this.byCarrier = const [],
    this.byBranch = const [],
  });

  factory TicketSalesKpis.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> listOfMaps(dynamic v) {
      if (v is List) {
        return v.whereType<Map<String, dynamic>>().toList();
      }
      return const [];
    }

    return TicketSalesKpis(
      totalTickets: _asInt(json['total_tickets']) ?? _asInt(json['total']) ?? 0,
      issued: _asInt(json['issued']) ?? 0,
      cancelled: _asInt(json['cancelled']),
      refunded: _asInt(json['refunded']),
      exchanged: _asInt(json['exchanged']),
      totalSales: _asDouble(json['total_sales']) ??
          _asDouble(json['total_amount']) ??
          0,
      totalFare: _asDouble(json['total_fare']),
      totalTax: _asDouble(json['total_tax']),
      totalCommission: _asDouble(json['total_commission']),
      totalNet: _asDouble(json['total_net']),
      currency: _asString(json['currency']),
      byCarrier: listOfMaps(json['by_carrier']),
      byBranch: listOfMaps(json['by_branch']),
    );
  }

  @override
  List<Object?> get props => [
        totalTickets,
        issued,
        cancelled,
        refunded,
        exchanged,
        totalSales,
        totalFare,
        totalTax,
        totalCommission,
        totalNet,
        currency,
        byCarrier,
        byBranch,
      ];
}
