class RateRefreshPolicy {
  const RateRefreshPolicy._();

  static bool isFreshForToday(DateTime savedAt, {DateTime? now}) {
    final reference = now ?? DateTime.now();
    return savedAt.year == reference.year &&
        savedAt.month == reference.month &&
        savedAt.day == reference.day;
  }

  static bool shouldRefresh(DateTime savedAt, {DateTime? now}) {
    return !isFreshForToday(savedAt, now: now);
  }
}
