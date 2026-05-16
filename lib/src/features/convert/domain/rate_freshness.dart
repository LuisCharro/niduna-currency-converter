import 'package:intl/intl.dart';

class RateFreshness {
  RateFreshness._();

  static const int _centralEuropeUpdateHour = 16;

  static String updatedLabel({
    required DateTime? rateDate,
    required DateTime savedAt,
  }) {
    if (rateDate != null) {
      return 'Updated ${DateFormat('MMM d').format(rateDate)}';
    }
    return 'Updated ${DateFormat('MMM d, h:mm a').format(savedAt.toLocal())}';
  }

  static String nextUpdateLabel({DateTime? now}) {
    final update = nextExpectedUpdate(now: now);
    return 'Next around ${DateFormat('h:mm a').format(update)} local';
  }

  static DateTime nextExpectedUpdate({DateTime? now}) {
    final current = now ?? DateTime.now();
    final utcNow = current.toUtc();
    var centralEuropeDate = _centralEuropeDateFor(utcNow);

    while (true) {
      if (_isWeekend(centralEuropeDate)) {
        centralEuropeDate = centralEuropeDate.add(const Duration(days: 1));
        continue;
      }

      final updateUtc = _centralEuropeUpdateUtc(centralEuropeDate);
      if (utcNow.isBefore(updateUtc)) {
        return updateUtc.toLocal();
      }
      centralEuropeDate = centralEuropeDate.add(const Duration(days: 1));
    }
  }

  static DateTime _centralEuropeDateFor(DateTime utcNow) {
    final offset = _centralEuropeOffsetHours(utcNow);
    final centralEuropeNow = utcNow.add(Duration(hours: offset));
    return DateTime.utc(
      centralEuropeNow.year,
      centralEuropeNow.month,
      centralEuropeNow.day,
    );
  }

  static DateTime _centralEuropeUpdateUtc(DateTime centralEuropeDate) {
    final offset = _centralEuropeOffsetHours(
      DateTime.utc(
        centralEuropeDate.year,
        centralEuropeDate.month,
        centralEuropeDate.day,
        12,
      ),
    );
    return DateTime.utc(
      centralEuropeDate.year,
      centralEuropeDate.month,
      centralEuropeDate.day,
      _centralEuropeUpdateHour - offset,
    );
  }

  static int _centralEuropeOffsetHours(DateTime utc) {
    final starts = _lastSundayOfMonth(utc.year, DateTime.march);
    final ends = _lastSundayOfMonth(utc.year, DateTime.october);
    final dstStart = DateTime.utc(utc.year, DateTime.march, starts.day, 1);
    final dstEnd = DateTime.utc(utc.year, DateTime.october, ends.day, 1);
    return !utc.isBefore(dstStart) && utc.isBefore(dstEnd) ? 2 : 1;
  }

  static DateTime _lastSundayOfMonth(int year, int month) {
    final nextMonth = month == DateTime.december
        ? DateTime.utc(year + 1, DateTime.january)
        : DateTime.utc(year, month + 1);
    var day = nextMonth.subtract(const Duration(days: 1));
    while (day.weekday != DateTime.sunday) {
      day = day.subtract(const Duration(days: 1));
    }
    return day;
  }

  static bool _isWeekend(DateTime day) {
    return day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;
  }
}
