/// Local usage counters that decide when to ask for a Play rating.
/// Stored on the device only; nothing is sent anywhere.
class ReviewPromptStats {
  const ReviewPromptStats({
    this.firstSeen,
    this.activeDays = 0,
    this.requestCount = 0,
    this.lastRequestAt,
  });

  final DateTime? firstSeen;
  final int activeDays;
  final int requestCount;
  final DateTime? lastRequestAt;
}

/// Pure rule for the in-app review request. Google applies its own quota on
/// top, and the API never reports whether the user rated, so we cap our own
/// requests instead of retrying until a rating arrives.
class ReviewPromptPolicy {
  const ReviewPromptPolicy();

  static const int minActiveDays = 3;
  static const Duration minAgeSinceFirstSeen = Duration(days: 5);
  static const Duration retryAfter = Duration(days: 120);
  static const int maxRequests = 3;

  bool shouldRequest(ReviewPromptStats stats, DateTime now) {
    final firstSeen = stats.firstSeen;
    if (firstSeen == null) return false;
    if (stats.activeDays < minActiveDays) return false;
    if (now.difference(firstSeen) < minAgeSinceFirstSeen) return false;
    if (stats.requestCount >= maxRequests) return false;
    final lastRequestAt = stats.lastRequestAt;
    return lastRequestAt == null || now.difference(lastRequestAt) >= retryAfter;
  }
}
