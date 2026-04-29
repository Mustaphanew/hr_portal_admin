import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/providers/admin_providers.dart';
import '../../../../core/widgets/admin_widgets.dart';

/// Open the bottom sheet that lets the admin filter the employees list by
/// department and employment status. Filters are persisted via Riverpod
/// state providers — applying them re-fetches the paginated list.
Future<void> showEmployeesAdvancedFilterSheet(
  BuildContext context,
  WidgetRef ref,
) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EmployeesAdvancedFilterSheet(),
  );
}

class _EmployeesAdvancedFilterSheet extends ConsumerStatefulWidget {
  const _EmployeesAdvancedFilterSheet();
  @override
  ConsumerState<_EmployeesAdvancedFilterSheet> createState() =>
      _EmployeesAdvancedFilterSheetState();
}

class _EmployeesAdvancedFilterSheetState
    extends ConsumerState<_EmployeesAdvancedFilterSheet> {
  int? _deptId;
  String? _empStatus;

  // Backend `employment_status` enum values discovered in real responses.
  // Add more as new ones appear.
  static const _statusOptions = <String>[
    'core_employee',
    'trainee',
    'contractor',
    'terminated',
    'resigned',
    'suspended',
  ];

  @override
  void initState() {
    super.initState();
    _deptId = ref.read(employeesDepartmentFilterProvider);
    _empStatus = ref.read(employeesEmploymentStatusFilterProvider);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final deptsAsync = ref.watch(departmentsProvider);

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.bgCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
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
                'Filter employees'.tr(context),
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Department dropdown
              _label('Department'.tr(context)),
              deptsAsync.when(
                loading: () => const _LoadingBox(),
                error: (e, _) => Text('—',
                    style: TextStyle(fontFamily: 'Cairo', color: c.textMuted)),
                data: (data) {
                  return _DropdownBox<int?>(
                    value: _deptId,
                    hint: 'All departments'.tr(context),
                    items: [
                      DropdownMenuItem<int?>(
                          value: null,
                          child: Text('All departments'.tr(context))),
                      ...data.departments.map(
                        (d) => DropdownMenuItem<int?>(
                          value: d.id,
                          child: Text(d.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _deptId = v),
                  );
                },
              ),
              const SizedBox(height: 12),

              // Employment status dropdown
              _label('Employment status'.tr(context)),
              _DropdownBox<String?>(
                value: _empStatus,
                hint: 'All statuses'.tr(context),
                items: [
                  DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All statuses'.tr(context))),
                  ..._statusOptions.map(
                    (s) => DropdownMenuItem<String?>(
                      value: s,
                      child: Text('employment_status.$s'.tr(context)),
                    ),
                  ),
                ],
                onChanged: (v) => setState(() => _empStatus = v),
              ),

              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlineBtn(
                    text: 'Reset'.tr(context),
                    onTap: () {
                      ref
                          .read(employeesDepartmentFilterProvider.notifier)
                          .state = null;
                      ref
                          .read(employeesEmploymentStatusFilterProvider.notifier)
                          .state = null;
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TealBtn(
                    text: 'Apply'.tr(context),
                    onTap: () {
                      ref
                          .read(employeesDepartmentFilterProvider.notifier)
                          .state = _deptId;
                      ref
                          .read(employeesEmploymentStatusFilterProvider.notifier)
                          .state = _empStatus;
                      Navigator.pop(context);
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
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.g500,
          ),
        ),
      );
}

class _DropdownBox<T> extends StatelessWidget {
  final T value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownBox({
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.g300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: AppColors.g500,
            ),
          ),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _LoadingBox extends StatelessWidget {
  const _LoadingBox();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.g300),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}
