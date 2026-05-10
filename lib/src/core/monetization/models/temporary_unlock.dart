class TemporaryUnlock {
  const TemporaryUnlock({
    required this.base,
    required this.quote,
    required this.grantedAt,
    this.duration = const Duration(hours: 24),
  });

  final String base;
  final String quote;
  final DateTime grantedAt;
  final Duration duration;

  bool get isExpired => DateTime.now().isAfter(grantedAt.add(duration));

  static String canonicalKey(String a, String b) {
    final sorted = [a, b]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  String get storageKey => 'temp_unlock_${canonicalKey(base, quote)}';

  Map<String, dynamic> toJson() => {
        'base': base,
        'quote': quote,
        'grantedAt': grantedAt.toIso8601String(),
        'durationMs': duration.inMilliseconds,
      };

  factory TemporaryUnlock.fromJson(Map<String, dynamic> json) {
    return TemporaryUnlock(
      base: json['base'] as String,
      quote: json['quote'] as String,
      grantedAt: DateTime.parse(json['grantedAt'] as String),
      duration: Duration(milliseconds: json['durationMs'] as int),
    );
  }
}
