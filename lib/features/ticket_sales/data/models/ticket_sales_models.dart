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

/// A single ticket sale record.
///
/// Matches the real `/admin/ticket-sales-reports` response shape captured
/// 2026-04-29 — backend returns:
/// `{ id, ticket_no, booking_date, issue_date, carrier_code, reservation_ref,
///    pnr, invoice_no, status, gross_amount, service_total, company, branch,
///    booked_by_name, issued_by_name }`
class TicketSaleRecord extends Equatable {
  final int id;
  final String? ticketNo;
  final String? bookingDate;
  final String? issueDate;
  final String? carrierCode;
  final String? reservationRef;
  final String? pnr;
  final String? invoiceNo;
  final String status; // confirmed / void / refunded ...
  final double grossAmount;
  final double serviceTotal;
  final int? companyId;
  final String? companyName;
  final int? branchId;
  final String? branchName;
  final String? bookedByName;
  final String? issuedByName;

  const TicketSaleRecord({
    required this.id,
    this.ticketNo,
    this.bookingDate,
    this.issueDate,
    this.carrierCode,
    this.reservationRef,
    this.pnr,
    this.invoiceNo,
    required this.status,
    this.grossAmount = 0,
    this.serviceTotal = 0,
    this.companyId,
    this.companyName,
    this.branchId,
    this.branchName,
    this.bookedByName,
    this.issuedByName,
  });

  // ── Backward-compatible aliases used by older UI code ──────────────────
  String? get ticketNumber => ticketNo;
  String? get passengerName => bookedByName ?? issuedByName;
  String? get carrierName => carrierCode;
  String? get routeFrom => null;
  String? get routeTo => null;
  String? get travelDate => bookingDate;
  String? get employeeName => issuedByName ?? bookedByName;
  int? get employeeId => null;
  double? get fareAmount => grossAmount - serviceTotal;
  double? get taxAmount => null;
  double? get totalAmount => grossAmount;
  double? get commissionAmount => serviceTotal;
  double? get netAmount => grossAmount;
  String? get currency => null;
  String? get notes => null;
  String? get createdAt => bookingDate;

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
      ticketNo:
          _asString(json['ticket_no']) ?? _asString(json['ticket_number']),
      bookingDate: _asString(json['booking_date']),
      issueDate: _asString(json['issue_date']) ?? _asString(json['issued_at']),
      carrierCode: _asString(json['carrier_code']) ??
          _asString(json['airline_code']) ??
          nested('carrier', 'code'),
      reservationRef: _asString(json['reservation_ref']),
      pnr: _asString(json['pnr']) ?? _asString(json['pnr_code']),
      invoiceNo: _asString(json['invoice_no']),
      status: _asString(json['status']) ?? 'confirmed',
      grossAmount: _asDouble(json['gross_amount']) ??
          _asDouble(json['total_amount']) ??
          _asDouble(json['amount']) ??
          0,
      serviceTotal: _asDouble(json['service_total']) ??
          _asDouble(json['commission_amount']) ??
          _asDouble(json['commission']) ??
          0,
      companyId: _asInt(json['company_id']) ?? nestedId('company'),
      companyName:
          _asString(json['company_name']) ?? nested('company', 'name'),
      branchId: _asInt(json['branch_id']) ?? nestedId('branch'),
      branchName: _asString(json['branch_name']) ?? nested('branch', 'name'),
      bookedByName: _asString(json['booked_by_name']),
      issuedByName: _asString(json['issued_by_name']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (ticketNo != null) 'ticket_no': ticketNo,
        if (bookingDate != null) 'booking_date': bookingDate,
        if (issueDate != null) 'issue_date': issueDate,
        if (carrierCode != null) 'carrier_code': carrierCode,
        if (reservationRef != null) 'reservation_ref': reservationRef,
        if (pnr != null) 'pnr': pnr,
        if (invoiceNo != null) 'invoice_no': invoiceNo,
        'status': status,
        'gross_amount': grossAmount,
        'service_total': serviceTotal,
        if (companyId != null) 'company_id': companyId,
        if (companyName != null) 'company_name': companyName,
        if (branchId != null) 'branch_id': branchId,
        if (branchName != null) 'branch_name': branchName,
        if (bookedByName != null) 'booked_by_name': bookedByName,
        if (issuedByName != null) 'issued_by_name': issuedByName,
      };

  @override
  List<Object?> get props => [
        id,
        ticketNo,
        bookingDate,
        issueDate,
        carrierCode,
        reservationRef,
        pnr,
        invoiceNo,
        status,
        grossAmount,
        serviceTotal,
        companyId,
        companyName,
        branchId,
        branchName,
        bookedByName,
        issuedByName,
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

/// Single bucket inside `by_status` array.
class TicketStatusBucket extends Equatable {
  final String status;
  final int tickets;
  final double grossAmount;

  const TicketStatusBucket({
    required this.status,
    required this.tickets,
    required this.grossAmount,
  });

  factory TicketStatusBucket.fromJson(Map<String, dynamic> json) {
    return TicketStatusBucket(
      status: _asString(json['status']) ?? '',
      tickets: _asInt(json['tickets']) ?? 0,
      grossAmount: _asDouble(json['gross_amount']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [status, tickets, grossAmount];
}

/// Single bucket inside `trend` array.
class TicketTrendPoint extends Equatable {
  final String month;
  final int tickets;
  final double grossAmount;

  const TicketTrendPoint({
    required this.month,
    required this.tickets,
    required this.grossAmount,
  });

  factory TicketTrendPoint.fromJson(Map<String, dynamic> json) {
    return TicketTrendPoint(
      month: _asString(json['month']) ?? '',
      tickets: _asInt(json['tickets']) ?? 0,
      grossAmount: _asDouble(json['gross_amount']) ?? 0,
    );
  }

  @override
  List<Object?> get props => [month, tickets, grossAmount];
}

/// KPIs response — captured 2026-04-29 from
/// `/admin/ticket-sales-reports/kpis`. Real shape:
/// `{ kpis: { ticket_count, gross_amount, service_total, average_ticket_value },
///    by_status: [{status, tickets, gross_amount}],
///    trend: [{month, tickets, gross_amount}] }`
class TicketSalesKpis extends Equatable {
  final int ticketCount;
  final double grossAmount;
  final double serviceTotal;
  final double averageTicketValue;
  final List<TicketStatusBucket> byStatus;
  final List<TicketTrendPoint> trend;

  const TicketSalesKpis({
    this.ticketCount = 0,
    this.grossAmount = 0,
    this.serviceTotal = 0,
    this.averageTicketValue = 0,
    this.byStatus = const [],
    this.trend = const [],
  });

  // ── Backward-compatible aliases for older UI code ─────────────────────
  /// Total ticket count (alias for [ticketCount]).
  int get totalTickets => ticketCount;
  /// Confirmed/issued ticket count, derived from `by_status`.
  int get issued => byStatus
      .where((b) => b.status == 'confirmed' || b.status == 'issued')
      .fold<int>(0, (sum, b) => sum + b.tickets);
  /// Void / cancelled count derived from `by_status`.
  int get cancelled => byStatus
      .where((b) => b.status == 'void' || b.status == 'cancelled')
      .fold<int>(0, (sum, b) => sum + b.tickets);
  /// Refunded count derived from `by_status`.
  int get refunded => byStatus
      .where((b) => b.status == 'refunded')
      .fold<int>(0, (sum, b) => sum + b.tickets);
  /// Exchanged count derived from `by_status`.
  int get exchanged => byStatus
      .where((b) => b.status == 'exchanged')
      .fold<int>(0, (sum, b) => sum + b.tickets);
  /// Total sales (alias for [grossAmount]).
  double get totalSales => grossAmount;
  /// Total commission/service (alias for [serviceTotal]).
  double get totalCommission => serviceTotal;
  /// Net sales (gross − service).
  double get totalNet => grossAmount - serviceTotal;
  /// Empty list — no breakdown by carrier in current backend.
  List<Map<String, dynamic>> get byCarrier => const [];
  /// Empty list — no breakdown by branch in current backend.
  List<Map<String, dynamic>> get byBranch => const [];
  /// Currency — the new endpoint doesn't return one (numbers are raw).
  String? get currency => null;

  factory TicketSalesKpis.fromJson(Map<String, dynamic> json) {
    // Real envelope: { kpis: {...}, by_status: [...], trend: [...] }.
    // Also accept flat keys for backwards compatibility.
    final kpisJson = json['kpis'] is Map<String, dynamic>
        ? json['kpis'] as Map<String, dynamic>
        : json;

    return TicketSalesKpis(
      ticketCount: _asInt(kpisJson['ticket_count']) ??
          _asInt(kpisJson['total_tickets']) ??
          _asInt(kpisJson['total']) ??
          0,
      grossAmount: _asDouble(kpisJson['gross_amount']) ??
          _asDouble(kpisJson['total_sales']) ??
          _asDouble(kpisJson['total_amount']) ??
          0,
      serviceTotal: _asDouble(kpisJson['service_total']) ??
          _asDouble(kpisJson['total_commission']) ??
          0,
      averageTicketValue: _asDouble(kpisJson['average_ticket_value']) ?? 0,
      byStatus: (json['by_status'] is List)
          ? (json['by_status'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TicketStatusBucket.fromJson)
              .toList()
          : const [],
      trend: (json['trend'] is List)
          ? (json['trend'] as List)
              .whereType<Map<String, dynamic>>()
              .map(TicketTrendPoint.fromJson)
              .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'kpis': {
          'ticket_count': ticketCount,
          'gross_amount': grossAmount,
          'service_total': serviceTotal,
          'average_ticket_value': averageTicketValue,
        },
        'by_status': byStatus.map((b) => {
              'status': b.status,
              'tickets': b.tickets,
              'gross_amount': b.grossAmount,
            }).toList(),
        'trend': trend.map((p) => {
              'month': p.month,
              'tickets': p.tickets,
              'gross_amount': p.grossAmount,
            }).toList(),
      };

  @override
  List<Object?> get props => [
        ticketCount,
        grossAmount,
        serviceTotal,
        averageTicketValue,
        byStatus,
        trend,
      ];
}
