import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/providers/core_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';
import '../../data/models/payroll_models.dart';
import '../providers/payroll_providers.dart';
import '../screens/allowances_screen.dart' show PayrollLineKind;

/// Open the bottom sheet that creates / edits an allowance or deduction.
///
/// - When [existing] is null → POST (create).
/// - When [existing] is provided → PUT (update).
Future<void> showPayrollLineFormSheet(
  BuildContext context,
  WidgetRef ref, {
  required PayrollLineKind kind,
  PayrollLineItem? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PayrollLineFormSheet(kind: kind, existing: existing),
  );
}

class _PayrollLineFormSheet extends ConsumerStatefulWidget {
  final PayrollLineKind kind;
  final PayrollLineItem? existing;
  const _PayrollLineFormSheet({required this.kind, this.existing});
  @override
  ConsumerState<_PayrollLineFormSheet> createState() =>
      _PayrollLineFormSheetState();
}

class _PayrollLineFormSheetState
    extends ConsumerState<_PayrollLineFormSheet> {
  int? _employeeId;
  String? _employeeName;
  int? _inputTypeId;
  String? _inputTypeName;
  late TextEditingController _qtyCtrl;
  late TextEditingController _rateCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  DateTime? _periodStart;
  DateTime? _periodEnd;

  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;
  bool get _isAllowance => widget.kind == PayrollLineKind.allowance;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _employeeId = e?.employee?.id;
    _employeeName = e?.employee?.name;
    _inputTypeId = e?.inputType?.id;
    _inputTypeName = e?.inputType?.name;
    _qtyCtrl = TextEditingController(
        text: e?.quantity.toStringAsFixed(0) ?? '1');
    _rateCtrl =
        TextEditingController(text: e?.rate.toStringAsFixed(2) ?? '');
    _amountCtrl =
        TextEditingController(text: e?.amount.toStringAsFixed(2) ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _periodStart =
        e?.periodStart != null ? DateTime.tryParse(e!.periodStart!) : null;
    _periodEnd =
        e?.periodEnd != null ? DateTime.tryParse(e!.periodEnd!) : null;
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Auto-compute amount when both quantity and rate are entered.
  void _autoAmount() {
    final q = double.tryParse(_qtyCtrl.text);
    final r = double.tryParse(_rateCtrl.text);
    if (q != null && r != null) {
      _amountCtrl.text = (q * r).toStringAsFixed(2);
    }
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _periodStart : _periodEnd) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _periodStart = picked;
        } else {
          _periodEnd = picked;
        }
      });
    }
  }

  Future<void> _pickEmployee() async {
    final picked = await showModalBottomSheet<MapEntry<int, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EmployeePickerSheet(),
    );
    if (picked != null) {
      setState(() {
        _employeeId = picked.key;
        _employeeName = picked.value;
      });
    }
  }

  Future<void> _pickInputType() async {
    final picked = await showModalBottomSheet<MapEntry<int, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InputTypePickerSheet(kind: widget.kind),
    );
    if (picked != null) {
      setState(() {
        _inputTypeId = picked.key;
        _inputTypeName = picked.value;
      });
    }
  }

  String? _validate() {
    if (!_isEdit && _employeeId == null) return 'Pick employee'.tr(context);
    if (!_isEdit && _inputTypeId == null) return 'Pick type'.tr(context);
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return 'Enter amount'.tr(context);
    if (_periodStart == null) return 'Pick start date'.tr(context);
    if (_periodEnd == null) return 'Pick end date'.tr(context);
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });

    final repo = ref.read(payrollRepositoryProvider);
    final qty = double.tryParse(_qtyCtrl.text) ?? 1;
    final rate = double.tryParse(_rateCtrl.text) ?? 0;
    final amount = double.parse(_amountCtrl.text);
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    try {
      if (_isEdit) {
        if (_isAllowance) {
          await repo.updateAllowance(
            widget.existing!.id,
            quantity: qty,
            rate: rate,
            amount: amount,
            notes: notes,
            periodStart: _fmtDate(_periodStart!),
            periodEnd: _fmtDate(_periodEnd!),
          );
        } else {
          await repo.updateDeduction(
            widget.existing!.id,
            quantity: qty,
            rate: rate,
            amount: amount,
            notes: notes,
            periodStart: _fmtDate(_periodStart!),
            periodEnd: _fmtDate(_periodEnd!),
          );
        }
      } else {
        if (_isAllowance) {
          await repo.createAllowance(
            employeeId: _employeeId!,
            inputTypeId: _inputTypeId!,
            periodStart: _fmtDate(_periodStart!),
            periodEnd: _fmtDate(_periodEnd!),
            quantity: qty,
            rate: rate,
            amount: amount,
            notes: notes,
          );
        } else {
          await repo.createDeduction(
            employeeId: _employeeId!,
            inputTypeId: _inputTypeId!,
            periodStart: _fmtDate(_periodStart!),
            periodEnd: _fmtDate(_periodEnd!),
            quantity: qty,
            rate: rate,
            amount: amount,
            notes: notes,
          );
        }
      }

      // Refresh provider.
      if (_isAllowance) {
        ref.invalidate(adminAllowancesProvider);
      } else {
        ref.invalidate(adminDeductionsProvider);
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit ? 'Updated'.tr(context) : 'Created'.tr(context),
            style: const TextStyle(fontFamily: 'Cairo'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.92),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.g300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text(
                _isEdit
                    ? (_isAllowance
                        ? 'Edit allowance'.tr(context)
                        : 'Edit deduction'.tr(context))
                    : (_isAllowance
                        ? 'Add allowance'.tr(context)
                        : 'Add deduction'.tr(context)),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Employee picker (only when creating)
              if (!_isEdit) ...[
                _label('Employee'.tr(context)),
                _pickerBox(
                  text: _employeeName ?? 'Pick employee'.tr(context),
                  hasValue: _employeeId != null,
                  onTap: _pickEmployee,
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 12),
                _label(_isAllowance ? 'Allowance type'.tr(context) : 'Deduction type'.tr(context)),
                _pickerBox(
                  text: _inputTypeName ?? 'Pick type'.tr(context),
                  hasValue: _inputTypeId != null,
                  onTap: _pickInputType,
                  icon: Icons.label_rounded,
                ),
                const SizedBox(height: 12),
              ] else ...[
                // Read-only employee + type for edits
                _readOnlyRow(context,
                    label: 'Employee'.tr(context),
                    value: widget.existing?.employee?.name ?? '-'),
                _readOnlyRow(context,
                    label: 'Type'.tr(context),
                    value: widget.existing?.inputType?.name ?? '-'),
                const SizedBox(height: 8),
              ],

              // Period
              Row(children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Period start'.tr(context)),
                      _pickerBox(
                        text: _periodStart == null
                            ? 'Pick'.tr(context)
                            : _fmtDate(_periodStart!),
                        hasValue: _periodStart != null,
                        onTap: () => _pickDate(isStart: true),
                        icon: Icons.event_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Period end'.tr(context)),
                      _pickerBox(
                        text: _periodEnd == null
                            ? 'Pick'.tr(context)
                            : _fmtDate(_periodEnd!),
                        hasValue: _periodEnd != null,
                        onTap: () => _pickDate(isStart: false),
                        icon: Icons.event_rounded,
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // Quantity / Rate / Amount
              Row(children: [
                Expanded(
                  child: _numberField(
                    label: 'Quantity'.tr(context),
                    controller: _qtyCtrl,
                    onChanged: (_) => _autoAmount(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _numberField(
                    label: 'Rate'.tr(context),
                    controller: _rateCtrl,
                    onChanged: (_) => _autoAmount(),
                  ),
                ),
              ]),
              const SizedBox(height: 12),
              _numberField(
                label: 'Amount'.tr(context),
                controller: _amountCtrl,
              ),
              const SizedBox(height: 12),
              _label('Notes'.tr(context)),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: _dec(context, 'optional'.tr(context)),
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(_error!,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12,
                        color: AppColors.error,
                      )),
                ),
              ],
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: OutlineBtn(
                    text: 'Cancel'.tr(context),
                    onTap: _saving ? null : () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TealBtn(
                    text: _saving
                        ? '${'Saving'.tr(context)}...'
                        : (_isEdit ? 'Save'.tr(context) : 'Create'.tr(context)),
                    onTap: _saving ? null : _submit,
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 4),
        child: Text(text,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.g500,
            )),
      );

  Widget _pickerBox({
    required String text,
    required bool hasValue,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    final c = context.appColors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.g300),
        ),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.navyMid),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                color: hasValue ? c.textPrimary : AppColors.g400,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Icon(Icons.unfold_more_rounded,
              size: 16, color: AppColors.g500),
        ]),
      ),
    );
  }

  Widget _numberField({
    required String label,
    required TextEditingController controller,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label(label),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          onChanged: onChanged,
          decoration: _dec(context, '0'),
        ),
      ],
    );
  }

  InputDecoration _dec(BuildContext context, String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.g400),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.g300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
      );

  Widget _readOnlyRow(BuildContext context,
      {required String label, required String value}) {
    final c = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, color: c.textMuted)),
          Flexible(
            child: Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ─── Employee Picker Sheet ────────────────────────────────────────────────

class _EmployeePickerSheet extends ConsumerStatefulWidget {
  const _EmployeePickerSheet();
  @override
  ConsumerState<_EmployeePickerSheet> createState() =>
      _EmployeePickerSheetState();
}

class _EmployeePickerSheetState extends ConsumerState<_EmployeePickerSheet> {
  String _q = '';
  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final asyncEmployees = ref.watch(employeesProvider);
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: Container(
            width: 42, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.g300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Text('Pick employee'.tr(context),
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            )),
        const SizedBox(height: 12),
        TextField(
          autofocus: false,
          onChanged: (v) => setState(() => _q = v.trim().toLowerCase()),
          decoration: InputDecoration(
            hintText: 'Search employee'.tr(context),
            hintStyle: const TextStyle(
                fontFamily: 'Cairo', fontSize: 13, color: AppColors.g400),
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.g300),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: asyncEmployees.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('$e', style: const TextStyle(fontFamily: 'Cairo'))),
            data: (data) {
              final filtered = _q.isEmpty
                  ? data.employees
                  : data.employees.where((e) =>
                      e.name.toLowerCase().contains(_q) ||
                      (e.code).toLowerCase().contains(_q));
              if (filtered.isEmpty) {
                return Center(
                  child: Text('No employees'.tr(context),
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13,
                          color: c.textMuted)),
                );
              }
              return ListView(
                children: filtered.map((e) {
                  return ListTile(
                    leading: AdminAvatar(
                        initials: e.name.characters.isEmpty
                            ? '·'
                            : e.name.characters.first,
                        size: 36),
                    title: Text(e.name,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    subtitle: Text('${e.code} · ${e.jobTitle ?? ''}',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: c.textMuted)),
                    onTap: () =>
                        Navigator.pop(context, MapEntry(e.id, e.name)),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ]),
    );
  }
}

// ─── Input Type Picker Sheet ──────────────────────────────────────────────
//
// Loads payroll input types from the DB through a custom raw call so we don't
// need a dedicated repository method. (When the backend exposes a proper
// `/admin/payroll-input-types` endpoint, swap this to a typed repo call.)
class _InputTypePickerSheet extends ConsumerStatefulWidget {
  final PayrollLineKind kind;
  const _InputTypePickerSheet({required this.kind});
  @override
  ConsumerState<_InputTypePickerSheet> createState() =>
      _InputTypePickerSheetState();
}

class _InputTypePickerSheetState
    extends ConsumerState<_InputTypePickerSheet> {
  late Future<List<PayrollInputType>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadTypes();
  }

  /// Until a dedicated endpoint exists, derive the available input types from
  /// the existing list response. Distinct by id.
  ///
  /// The backend caps `per_page` at 100 — when the underlying table has more
  /// rows we walk through pages until we've seen them all (or hit the cap).
  Future<List<PayrollInputType>> _loadTypes() async {
    final repo = ref.read(payrollRepositoryProvider);
    final isAllow = widget.kind == PayrollLineKind.allowance;
    final seen = <int, PayrollInputType>{};

    var page = 1;
    const maxPages = 5; // safety cap (≤ 500 rows scanned)
    while (page <= maxPages) {
      final response = isAllow
          ? await repo.getAllowances(perPage: 100, page: page)
          : await repo.getDeductions(perPage: 100, page: page);
      final data = response.data;
      final items = data?.items ?? const <PayrollLineItem>[];
      for (final it in items) {
        final t = it.inputType;
        if (t != null) seen[t.id] = t;
      }
      // Stop when we hit the last page or the page is empty.
      final pag = data?.pagination;
      if (pag == null || page >= pag.lastPage || items.isEmpty) break;
      page++;
    }

    return seen.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  /// Show a clean Arabic error from any thrown exception.
  String _formatError(Object error) {
    final raw = error.toString();
    // Strip noisy prefixes like "ApiException(VALIDATION_FAILED: ...)".
    final cleaned = raw
        .replaceAll(RegExp(r'^[A-Za-z]+Exception\([^:]+:\s*'), '')
        .replaceAll(RegExp(r'\)$'), '');
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isAllow = widget.kind == PayrollLineKind.allowance;
    return Container(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7),
      decoration: BoxDecoration(
        color: c.bgCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Center(
          child: Container(
            width: 42, height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.g300,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Text(
          isAllow ? 'Pick allowance type'.tr(context) : 'Pick deduction type'.tr(context),
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: FutureBuilder<List<PayrollInputType>>(
            future: _future,
            builder: (_, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 36, color: AppColors.error),
                        const SizedBox(height: 8),
                        Text(
                          _formatError(snap.error!),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _future = _loadTypes();
                          }),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: Text('Retry'.tr(context),
                              style: const TextStyle(
                                  fontFamily: 'Cairo', fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final types = snap.data ?? [];
              if (types.isEmpty) {
                return Center(
                  child: Text('No types'.tr(context),
                      style: TextStyle(
                          fontFamily: 'Cairo', color: c.textMuted)),
                );
              }
              return ListView(
                children: types.map((t) {
                  return ListTile(
                    leading: const Icon(Icons.label_rounded,
                        color: AppColors.teal),
                    title: Text(t.name,
                        style: const TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13,
                            fontWeight: FontWeight.w700)),
                    subtitle: Text('${t.code ?? ''} · ${t.calcMode ?? ''}',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11,
                            color: c.textMuted)),
                    onTap: () =>
                        Navigator.pop(context, MapEntry(t.id, t.name)),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ]),
    );
  }
}

/// Strip showing count + total amount for allowances/deductions.
class PayrollLinesSummaryStrip extends StatelessWidget {
  final PayrollLinesSummary summary;
  final PayrollLineKind kind;
  const PayrollLinesSummaryStrip({
    super.key,
    required this.summary,
    required this.kind,
  });

  String _fmt(num v) {
    if (v >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
    return v.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final isAllow = kind == PayrollLineKind.allowance;
    final accent = isAllow ? AppColors.success : AppColors.error;
    return Container(
      color: c.bgCard,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            decoration: BoxDecoration(
              color: AppColors.navyMid.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.navyMid.withOpacity(0.2)),
            ),
            child: Row(children: [
              const Icon(Icons.list_rounded,
                  size: 16, color: AppColors.navyMid),
              const SizedBox(width: 6),
              Text('Total'.tr(context),
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: c.textMuted)),
              const Spacer(),
              Text('${summary.count}',
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyMid)),
            ]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withOpacity(0.2)),
            ),
            child: Row(children: [
              Icon(
                  isAllow ? Icons.add_circle_rounded : Icons.remove_circle_rounded,
                  size: 16, color: accent),
              const SizedBox(width: 6),
              Text('Amount'.tr(context),
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11,
                      color: c.textMuted)),
              const Spacer(),
              Text(_fmt(summary.totalAmount),
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: accent)),
            ]),
          ),
        ),
      ]),
    );
  }
}
