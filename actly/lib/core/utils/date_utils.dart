DateTime startOfDay(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime startOfIsoWeek(DateTime value) {
  final date = startOfDay(value);
  return date.subtract(Duration(days: date.weekday - DateTime.monday));
}

String isoWeekKey(DateTime date) {
  final thursday = startOfDay(date).add(Duration(days: 4 - date.weekday));
  final firstThursday = DateTime(thursday.year, 1, 4);
  final firstWeekStart =
      firstThursday.subtract(Duration(days: firstThursday.weekday - 1));
  final week = 1 + thursday.difference(firstWeekStart).inDays ~/ 7;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

DateTime timeOnDate(DateTime date, String hhmm) {
  final parts = hhmm.split(':');
  final hour = int.tryParse(parts.first) ?? 0;
  final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
  return DateTime(date.year, date.month, date.day, hour, minute);
}

String formatClock(DateTime value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

String formatShortDate(DateTime value) {
  const months = <String>[
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
    'Dec',
  ];
  return '${value.day} ${months[value.month - 1]}';
}
