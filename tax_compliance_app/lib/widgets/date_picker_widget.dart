import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DatePickerWidget extends StatefulWidget {
  final DateTime? initialDate;
  final ValueChanged<DateTime?> onDateSelected;
  final String label;
  final String? hint;
  final String? errorText;
  final bool isRequired;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateFormat? dateFormat;
  final bool readOnly;
  final InputDecoration? decoration;

  const DatePickerWidget({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.label,
    this.hint,
    this.errorText,
    this.isRequired = false,
    this.firstDate,
    this.lastDate,
    this.dateFormat,
    this.readOnly = false,
    this.decoration,
  });

  @override
  State<DatePickerWidget> createState() => _DatePickerWidgetState();
}

class _DatePickerWidgetState extends State<DatePickerWidget> {
  late DateTime? _selectedDate;
  late final TextEditingController _controller;
  late final DateFormat _dateFormat;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _dateFormat = widget.dateFormat ?? DateFormat('dd MMM yyyy');
    _controller = TextEditingController(
      text: _selectedDate != null ? _dateFormat.format(_selectedDate!) : '',
    );
  }

  @override
  void didUpdateWidget(DatePickerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDate != widget.initialDate) {
      _selectedDate = widget.initialDate;
      _controller.text =
          _selectedDate != null ? _dateFormat.format(_selectedDate!) : '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    // Don't show picker if readOnly
    if (widget.readOnly) return;

    final DateTime now = DateTime.now();
    final DateTime firstDate = widget.firstDate ?? DateTime(1900);
    final DateTime lastDate = widget.lastDate ?? now;

    // Validate dates
    if (firstDate.isAfter(lastDate)) {
      throw ArgumentError('firstDate cannot be after lastDate');
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate != null &&
              _selectedDate!.isAfter(firstDate) &&
              _selectedDate!.isBefore(lastDate)
          ? _selectedDate!
          : (lastDate.isBefore(firstDate) ? firstDate : lastDate),
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Select ${widget.label}',
      cancelText: 'Cancel',
      confirmText: 'OK',
      errorFormatText: 'Invalid date format',
      errorInvalidText: 'Date is out of range',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Theme.of(context).primaryColor,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = _dateFormat.format(picked);
      });
      widget.onDateSelected(picked);
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
      _controller.clear();
    });
    widget.onDateSelected(null);
  }

  String? _getValidationError() {
    if (widget.isRequired && _selectedDate == null) {
      return '${widget.label} is required';
    }
    return widget.errorText;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        absorbing: widget.readOnly,
        child: TextFormField(
          controller: _controller,
          readOnly: true,
          decoration: widget.decoration ??
              InputDecoration(
                labelText: widget.label,
                hintText: widget.hint ?? 'Select ${widget.label}',
                errorText: _getValidationError(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: _selectedDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: _clearDate,
                        tooltip: 'Clear date',
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  gapPadding: 4,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 1,
                  ),
                ),
                filled: true,
                fillColor: widget.readOnly
                    ? Theme.of(context).disabledColor.withValues(alpha: 0.1)
                    : null,
              ),
          validator: (value) => _getValidationError(),
        ),
      ),
    );
  }
}

// Extension methods for easier date operations
extension DatePickerExtensions on DateTime {
  String formatDate({DateFormat? format}) {
    final formatter = format ?? DateFormat('dd MMM yyyy');
    return formatter.format(this);
  }

  bool isSameDay(DateTime? other) {
    if (other == null) return false;
    return year == other.year && month == other.month && day == other.day;
  }

  String toApiFormat() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  String toDisplayFormat() {
    return DateFormat('dd MMM yyyy').format(this);
  }

  String toFullDateTime() {
    return DateFormat('dd MMM yyyy, hh:mm a').format(this);
  }

  String toTimeOnly() {
    return DateFormat('hh:mm a').format(this);
  }

  String toMonthYear() {
    return DateFormat('MMM yyyy').format(this);
  }

  String toYearOnly() {
    return DateFormat('yyyy').format(this);
  }

  DateTime get startOfDay {
    return DateTime(year, month, day);
  }

  DateTime get endOfDay {
    return DateTime(year, month, day, 23, 59, 59, 999);
  }

  DateTime get startOfMonth {
    return DateTime(year, month, 1);
  }

  DateTime get endOfMonth {
    return DateTime(year, month + 1, 0);
  }

  DateTime get startOfYear {
    return DateTime(year, 1, 1);
  }

  DateTime get endOfYear {
    return DateTime(year, 12, 31);
  }

  int get daysInMonth {
    return DateTime(year, month + 1, 0).day;
  }

  bool isWeekend() {
    return weekday == DateTime.saturday || weekday == DateTime.sunday;
  }

  bool isWeekday() {
    return !isWeekend();
  }

  String get dayName {
    return DateFormat('EEEE').format(this);
  }

  String get shortDayName {
    return DateFormat('EEE').format(this);
  }

  String get monthName {
    return DateFormat('MMMM').format(this);
  }

  String get shortMonthName {
    return DateFormat('MMM').format(this);
  }
}

// Utility class for common date configurations
class DatePickerUtils {
  static Future<DateTime?> showCustomDatePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    String? helpText,
    String? cancelText,
    String? confirmText,
  }) async {
    return showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime.now(),
      helpText: helpText ?? 'Select Date',
      cancelText: cancelText ?? 'Cancel',
      confirmText: confirmText ?? 'OK',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );
  }

  static DateTime parseDate(String dateStr, {String format = 'dd/MM/yyyy'}) {
    return DateFormat(format).parse(dateStr);
  }

  static String formatDate(DateTime date, {String format = 'dd MMM yyyy'}) {
    return DateFormat(format).format(date);
  }

  static DateTime? tryParseDate(String dateStr,
      {String format = 'dd/MM/yyyy'}) {
    try {
      return DateFormat(format).parse(dateStr);
    } catch (e) {
      return null;
    }
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    final days = <DateTime>[];
    for (int i = 0; i < end.day; i++) {
      days.add(DateTime(start.year, start.month, start.day + i));
    }
    return days;
  }

  static List<DateTime> getDaysInRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 0; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  static int daysBetween(DateTime from, DateTime to) {
    return to.difference(from).inDays.abs();
  }

  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    return date.isAfter(start) && date.isBefore(end);
  }

  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static DateTime getFirstDayOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  static DateTime getLastDayOfYear(DateTime date) {
    return DateTime(date.year, 12, 31);
  }

  static List<String> getMonthNames() {
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
  }

  static List<String> getShortMonthNames() {
    return [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
  }

  static List<String> getDayNames() {
    return [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
  }

  static List<String> getShortDayNames() {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  }
}
