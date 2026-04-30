import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';

/// Bottom sheet to edit advanced employee-requests filters.
/// Returns the new filters or null if cancelled.
Future<EmployeeRequestsFilters?> showRequestsFiltersSheet(
  BuildContext context, {
  required EmployeeRequestsFilters initial,
}) {
  return showModalBottomSheet<EmployeeRequestsFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RequestsFiltersSheet(initial: initial),
  );
}

class _RequestsFiltersSheet extends StatefulWidget {
  final EmployeeRequestsFilters initial;
  const _RequestsFiltersSheet({required this.initial});

  @override
  State<_RequestsFiltersSheet> createState() => _RequestsFiltersSheetState();
}

class _RequestsFiltersSheetState extends State<_RequestsFiltersSheet> {
  late TextEditingController _searchCtrl;
  late TextEditingController _empIdCtrl;
  late TextEditingController _deptIdCtrl;
  late TextEditingController _amountMinCtrl;
  late TextEditingController _amountMaxCtrl;
  String? _requestType;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  // Real request type codes from `hr_employee_request_types` table.
  // The labels are translation keys (see ar.json / en.json).
  static const _types = <({String value, String label})>[
    (value: 'salary_certificate',  label: 'request_type.salary_certificate'),
    (value: 'experience_letter',   label: 'request_type.experience_letter'),
    (value: 'vacation_settlement', label: 'request_type.vacation_settlement'),
    (value: 'loan_request',        label: 'request_type.loan_request'),
    (value: 'expense_claim',       label: 'request_type.expense_claim'),
    (value: 'training_request',    label: 'request_type.training_request'),
    (value: 'leace_application',   label: 'request_type.leave_application'),
    (value: 'other',               label: 'request_type.other'),
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _searchCtrl = TextEditingController(text: f.search ?? '');
    _empIdCtrl = TextEditingController(
        text: f.employeeId == null ? '' : f.employeeId.toString());
    _deptIdCtrl = TextEditingController(
        text: f.departmentId == null ? '' : f.departmentId.toString());
    _amountMinCtrl = TextEditingController(
        text: f.amountMin == null ? '' : f.amountMin!.toStringAsFixed(0));
    _amountMaxCtrl = TextEditingController(
        text: f.amountMax == null ? '' : f.amountMax!.toStringAsFixed(0));
    _requestType = f.requestType;
    _dateFrom = f.dateFrom == null ? null : DateTime.tryParse(f.dateFrom!);
    _dateTo = f.dateTo == null ? null : DateTime.tryParse(f.dateTo!);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _empIdCtrl.dispose();
    _deptIdCtrl.dispose();
    _amountMinCtrl.dispose();
    _amountMaxCtrl.dispose();
    super.dispose();
  }

  String _fmtDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.g300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text('Filter requests'.tr(context),
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              _label('Search'.tr(context)),
              TextField(
                controller: _searchCtrl,
                decoration:
                    _dec(context, 'Search by subject / description'.tr(context)),
              ),
              const SizedBox(height: 12),
              _label('Request type'.tr(context)),
              _typeDropdown(context),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Date from'.tr(context)),
                        _DateField(
                          date: _dateFrom,
                          onPick: (d) => setState(() => _dateFrom = d),
                          onClear: () => setState(() => _dateFrom = null),
                        ),
                      ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _label('Date to'.tr(context)),
                        _DateField(
                          date: _dateTo,
                          onPick: (d) => setState(() => _dateTo = d),
                          onClear: () => setState(() => _dateTo = null),
                        ),
                      ]),
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Amount min'.tr(context)),
                          TextField(
                            controller: _amountMinCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: _dec(context, '0'),
                          ),
                        ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Amount max'.tr(context)),
                          TextField(
                            controller: _amountMaxCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: _dec(context, '...'),
                          ),
                        ])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Department ID'.tr(context)),
                          TextField(
                            controller: _deptIdCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _dec(context, 'optional'.tr(context)),
                          ),
                        ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Employee ID'.tr(context)),
                          TextField(
                            controller: _empIdCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _dec(context, 'optional'.tr(context)),
                          ),
                        ])),
              ]),
              const SizedBox(height: 18),
              Row(children: [
                Expanded(
                  child: OutlineBtn(
                    text: 'Reset'.tr(context),
                    onTap: () {
                      Navigator.pop(
                          context,
                          widget.initial.copyWith(
                            search: null,
                            requestType: null,
                            requestTypeId: null,
                            departmentId: null,
                            employeeId: null,
                            dateFrom: null,
                            dateTo: null,
                            amountMin: null,
                            amountMax: null,
                          ));
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TealBtn(
                    text: 'Apply'.tr(context),
                    onTap: () {
                      final search = _searchCtrl.text.trim();
                      final empId = int.tryParse(_empIdCtrl.text.trim());
                      final deptId = int.tryParse(_deptIdCtrl.text.trim());
                      final mn = double.tryParse(_amountMinCtrl.text.trim());
                      final mx = double.tryParse(_amountMaxCtrl.text.trim());
                      Navigator.pop(
                          context,
                          widget.initial.copyWith(
                            search: search.isEmpty ? null : search,
                            requestType: _requestType,
                            departmentId: deptId,
                            employeeId: empId,
                            dateFrom:
                                _dateFrom == null ? null : _fmtDate(_dateFrom!),
                            dateTo: _dateTo == null ? null : _fmtDate(_dateTo!),
                            amountMin: mn,
                            amountMax: mx,
                          ));
                    },
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeDropdown(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.g300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: _requestType,
          hint: Text('All types'.tr(context),
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13, color: AppColors.g500)),
          items: [
            DropdownMenuItem<String?>(
                value: null, child: Text('All types'.tr(context))),
            ..._types.map((t) => DropdownMenuItem<String?>(
                value: t.value, child: Text(t.label.tr(context)))),
          ],
          onChanged: (v) => setState(() => _requestType = v),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4, top: 2),
        child: Text(text,
            style: const TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.g500)),
      );

  InputDecoration _dec(BuildContext context, String hint) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontFamily: 'Cairo', fontSize: 12.5, color: AppColors.g400),
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.g300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
        ),
      );
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final ValueChanged<DateTime> onPick;
  final VoidCallback onClear;
  const _DateField(
      {required this.date, required this.onPick, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.g300),
        ),
        child: Row(children: [
          const Icon(Icons.event_rounded, size: 18, color: AppColors.navyMid),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              date == null
                  ? 'Pick'.tr(context)
                  : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.5,
                  color: date == null ? AppColors.g400 : AppColors.tx1,
                  fontWeight: FontWeight.w600),
            ),
          ),
          if (date != null)
            GestureDetector(
              onTap: onClear,
              child: const Icon(Icons.close_rounded,
                  size: 16, color: AppColors.g500),
            ),
        ]),
      ),
    );
  }
}
