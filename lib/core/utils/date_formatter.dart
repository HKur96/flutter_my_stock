import 'package:intl/intl.dart';

enum TimeZoneName {
  wib,
  wita,
  wit;

  static TimeZoneName? fromOffset(Duration offset) {
    switch (offset) {
      case const Duration(hours: 7):
        return TimeZoneName.wib;
      case const Duration(hours: 8):
        return TimeZoneName.wita;
      case const Duration(hours: 9):
        return TimeZoneName.wit;
      default:
        return null;
    }
  }

  String get name {
    switch (this) {
      case TimeZoneName.wib:
        return 'WIB';
      case TimeZoneName.wita:
        return 'WITA';
      case TimeZoneName.wit:
        return 'WIT';
    }
  }

  Duration get offset {
    switch (this) {
      case TimeZoneName.wib:
        return const Duration(hours: 7);
      case TimeZoneName.wita:
        return const Duration(hours: 8);
      case TimeZoneName.wit:
        return const Duration(hours: 9);
    }
  }
}

class DateFormatter {
  DateFormatter._();

  static final DateFormat _fullDate = DateFormat('dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('dd MMM', 'id_ID');
  static final DateFormat _dayDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  static final DateFormat _dayHours = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  static String fullDate(DateTime date) => _fullDate.format(date);
  static String shortDate(DateTime date) => _shortDate.format(date);
  static String dayDate(DateTime date) => _dayDate.format(date);
  static String dayHours(DateTime date) =>
      '${_dayHours.format(date.add(DateTime.now().timeZoneOffset))}'
      ' ${TimeZoneName.fromOffset(DateTime.now().timeZoneOffset)?.name}';
}
