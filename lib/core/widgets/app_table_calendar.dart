import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/app_colors.dart';

/// رمز `locale` لـ [TableCalendar] حسب لغة الواجهة.
String appTableCalendarLocaleFor(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  if (code == 'ar') return 'ar';
  return 'en_US';
}

/// أول يوم في الأسبوع شائع في الخليج عندما تكون اللغة عربية.
StartingDayOfWeek appTableCalendarStartingDayFor(BuildContext context) {
  return Localizations.localeOf(context).languageCode == 'ar'
      ? StartingDayOfWeek.saturday
      : StartingDayOfWeek.sunday;
}

/// تقويم جاهز (شهر) + اختيار يوم. للعرض داخل شاشة أو داخل [showDialog].
class AppTableCalendar extends StatefulWidget {
  const AppTableCalendar({
    super.key,
    required this.onDateChanged,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.height,
  });

  final ValueChanged<DateTime> onDateChanged;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final double? height;

  @override
  State<AppTableCalendar> createState() => _AppTableCalendarState();
}

class _AppTableCalendarState extends State<AppTableCalendar> {
  late DateTime _focused;
  late DateTime _selected;

  DateTime get _first => widget.firstDate ?? DateTime(2020, 1, 1);
  DateTime get _last => widget.lastDate ?? DateTime(2100, 12, 31);

  @override
  void initState() {
    super.initState();
    var d = _dateOnly(widget.initialDate ?? DateTime.now());
    if (d.isBefore(_first)) d = _dateOnly(_first);
    if (d.isAfter(_last)) d = _dateOnly(_last);
    _selected = d;
    _focused = d;
  }

  static DateTime _dateOnly(DateTime d) {
    return DateTime(d.year, d.month, d.day);
  }

  @override
  Widget build(BuildContext context) {
    final loc = appTableCalendarLocaleFor(context);
    return SizedBox(
      height: widget.height ?? 360,
      child: TableCalendar<void>(
        locale: loc,
        firstDay: _first,
        lastDay: _last,
        focusedDay: _focused,
        currentDay: DateTime.now(),
        startingDayOfWeek: appTableCalendarStartingDayFor(context),
        availableGestures: AvailableGestures.horizontalSwipe,
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.gold.withValues(alpha: 0.25),
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold),
          ),
          selectedDecoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
          todayTextStyle: const TextStyle(
            color: AppColors.navy,
            fontFamily: 'Cairo',
            fontWeight: FontWeight.w600,
          ),
          defaultTextStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14,
          ),
          weekendTextStyle: TextStyle(
            fontFamily: 'Cairo',
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.navy,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          weekendStyle: TextStyle(
            fontFamily: 'Cairo',
            color: AppColors.navy.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
        selectedDayPredicate: (day) => isSameDay(_selected, day),
        onDaySelected: (sel, focus) {
          setState(() {
            _selected = _dateOnly(sel);
            _focused = focus;
          });
          widget.onDateChanged(_selected);
        },
        onPageChanged: (f) {
          if (mounted) setState(() => _focused = f);
        },
      ),
    );
  }
}

/// يفتح [Dialog] بـ [TableCalendar] ويعيد تاريخاً واحداً (بدون وقت) أو `null` عند الإلغاء.
Future<DateTime?> showAppTableCalendarDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  String? title,
}) {
  final first = firstDate ?? DateTime(2000, 1, 1);
  final last = lastDate ?? DateTime(2100, 12, 31);
  var initial = DateTime(
    initialDate.year,
    initialDate.month,
    initialDate.day,
  );
  if (initial.isBefore(first)) {
    initial = first;
  }
  if (initial.isAfter(last)) {
    initial = last;
  }

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => _TableCalendarDatePickerDialog(
      firstDay: first,
      lastDay: last,
      initialSelected: initial,
      title: title,
    ),
  );
}

class _TableCalendarDatePickerDialog extends StatefulWidget {
  const _TableCalendarDatePickerDialog({
    required this.firstDay,
    required this.lastDay,
    required this.initialSelected,
    this.title,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime initialSelected;
  final String? title;

  @override
  State<_TableCalendarDatePickerDialog> createState() =>
      _TableCalendarDatePickerDialogState();
}

class _TableCalendarDatePickerDialogState
    extends State<_TableCalendarDatePickerDialog> {
  late DateTime _selected;
  late DateTime _focused;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelected;
    _focused = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    final loc = appTableCalendarLocaleFor(context);
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        widget.title ?? (loc == 'ar' ? 'اختر التاريخ' : 'Select date'),
        style: const TextStyle(
          fontFamily: 'Cairo',
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      content: SizedBox(
        width: 360,
        child: TableCalendar<void>(
          locale: loc,
          firstDay: widget.firstDay,
          lastDay: widget.lastDay,
          focusedDay: _focused,
          currentDay: DateTime.now(),
          startingDayOfWeek: appTableCalendarStartingDayFor(context),
          availableGestures: AvailableGestures.horizontalSwipe,
          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
          calendarStyle: CalendarStyle(
            todayDecoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.25),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.gold),
            ),
            selectedDecoration: const BoxDecoration(
              color: AppColors.navy,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
            todayTextStyle: const TextStyle(
              color: AppColors.navy,
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600,
            ),
            defaultTextStyle: const TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              fontFamily: 'Cairo',
              color: AppColors.navy,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          selectedDayPredicate: (day) => isSameDay(_selected, day),
          onDaySelected: (sel, focus) {
            setState(() {
              _selected = DateTime(sel.year, sel.month, sel.day);
              _focused = focus;
            });
          },
          onPageChanged: (f) {
            setState(() {
              _focused = f;
            });
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(loc == 'ar' ? 'إلغاء' : 'Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: Text(loc == 'ar' ? 'تأكيد' : 'OK'),
        ),
      ],
    );
  }
}
