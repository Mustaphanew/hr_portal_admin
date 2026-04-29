import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';

/// Bottom sheet for advanced task filters (Postman 06).
Future<TasksFilters?> showTasksFiltersSheet(
  BuildContext context, {
  required TasksFilters initial,
}) {
  return showModalBottomSheet<TasksFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TasksFiltersSheet(initial: initial),
  );
}

class _TasksFiltersSheet extends StatefulWidget {
  final TasksFilters initial;
  const _TasksFiltersSheet({required this.initial});

  @override
  State<_TasksFiltersSheet> createState() => _TasksFiltersSheetState();
}

class _TasksFiltersSheetState extends State<_TasksFiltersSheet> {
  late TextEditingController _searchCtrl;
  late TextEditingController _projectIdCtrl;
  late TextEditingController _assigneeIdCtrl;
  String? _priority;
  String? _type;
  DateTime? _dueFrom;
  DateTime? _dueTo;

  static const _priorities = <({String value, String label})>[
    (value: 'LOW', label: 'Low'),
    (value: 'MEDIUM', label: 'Medium'),
    (value: 'HIGH', label: 'High'),
    (value: 'URGENT', label: 'Urgent'),
  ];

  static const _types = <({String value, String label})>[
    (value: 'task', label: 'Task'),
    (value: 'bug', label: 'Bug'),
    (value: 'feature', label: 'Feature'),
    (value: 'improvement', label: 'Improvement'),
    (value: 'support', label: 'Support'),
  ];

  @override
  void initState() {
    super.initState();
    final f = widget.initial;
    _searchCtrl = TextEditingController(text: f.search ?? '');
    _projectIdCtrl = TextEditingController(
        text: f.projectId == null ? '' : f.projectId.toString());
    _assigneeIdCtrl = TextEditingController(
        text: f.assigneeEmployeeId == null
            ? ''
            : f.assigneeEmployeeId.toString());
    _priority = f.priority;
    _type = f.type;
    _dueFrom = f.dueFrom == null ? null : DateTime.tryParse(f.dueFrom!);
    _dueTo = f.dueTo == null ? null : DateTime.tryParse(f.dueTo!);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _projectIdCtrl.dispose();
    _assigneeIdCtrl.dispose();
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
              Text('Filter tasks'.tr(context),
                  style: const TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 17,
                      fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              _label('Search'.tr(context)),
              TextField(
                controller: _searchCtrl,
                decoration: _dec(context, 'Search by title / description'.tr(context)),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Priority'.tr(context)),
                          _Dropdown(
                            value: _priority,
                            options: _priorities,
                            allLabel: 'All priorities'.tr(context),
                            onChanged: (v) => setState(() => _priority = v),
                          ),
                        ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Type'.tr(context)),
                          _Dropdown(
                            value: _type,
                            options: _types,
                            allLabel: 'All types'.tr(context),
                            onChanged: (v) => setState(() => _type = v),
                          ),
                        ])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Due from'.tr(context)),
                          _DateField(
                            date: _dueFrom,
                            onPick: (d) => setState(() => _dueFrom = d),
                            onClear: () => setState(() => _dueFrom = null),
                          ),
                        ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Due to'.tr(context)),
                          _DateField(
                            date: _dueTo,
                            onPick: (d) => setState(() => _dueTo = d),
                            onClear: () => setState(() => _dueTo = null),
                          ),
                        ])),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Project ID'.tr(context)),
                          TextField(
                            controller: _projectIdCtrl,
                            keyboardType: TextInputType.number,
                            decoration: _dec(context, 'optional'.tr(context)),
                          ),
                        ])),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('Assignee ID'.tr(context)),
                          TextField(
                            controller: _assigneeIdCtrl,
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
                    onTap: () => Navigator.pop(
                        context,
                        widget.initial.copyWith(
                          search: null,
                          priority: null,
                          type: null,
                          projectId: null,
                          assigneeEmployeeId: null,
                          dueFrom: null,
                          dueTo: null,
                        )),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TealBtn(
                    text: 'Apply'.tr(context),
                    onTap: () {
                      final search = _searchCtrl.text.trim();
                      final pid = int.tryParse(_projectIdCtrl.text.trim());
                      final aid = int.tryParse(_assigneeIdCtrl.text.trim());
                      Navigator.pop(
                          context,
                          widget.initial.copyWith(
                            search: search.isEmpty ? null : search,
                            priority: _priority,
                            type: _type,
                            projectId: pid,
                            assigneeEmployeeId: aid,
                            dueFrom:
                                _dueFrom == null ? null : _fmtDate(_dueFrom!),
                            dueTo: _dueTo == null ? null : _fmtDate(_dueTo!),
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

class _Dropdown extends StatelessWidget {
  final String? value;
  final List<({String value, String label})> options;
  final String allLabel;
  final ValueChanged<String?> onChanged;
  const _Dropdown(
      {required this.value,
      required this.options,
      required this.allLabel,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.g300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          isExpanded: true,
          value: value,
          isDense: true,
          hint: Text(allLabel,
              style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 13, color: AppColors.g500)),
          items: [
            DropdownMenuItem<String?>(value: null, child: Text(allLabel)),
            ...options.map((o) => DropdownMenuItem<String?>(
                value: o.value, child: Text(o.label.tr(context)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
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
