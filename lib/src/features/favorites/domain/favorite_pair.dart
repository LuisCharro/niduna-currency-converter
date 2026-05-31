class FavoritePair {
  const FavoritePair({
    required this.base,
    required this.quote,
    this.useCount = 0,
    this.lastUsedAt,
  });

  final String base;
  final String quote;
  final int useCount;
  final DateTime? lastUsedAt;

  factory FavoritePair.fromKey(String key) {
    final parts = key.split('-');
    if (parts.length != 2) {
      throw FormatException('Invalid favorite key: $key');
    }
    return FavoritePair(base: parts[0], quote: parts[1]);
  }

  String toKey() => '$base-$quote';

  FavoritePair copyWith({
    String? base,
    String? quote,
    int? useCount,
    DateTime? lastUsedAt,
  }) =>
      FavoritePair(
        base: base ?? this.base,
        quote: quote ?? this.quote,
        useCount: useCount ?? this.useCount,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoritePair && base == other.base && quote == other.quote;

  @override
  int get hashCode => Object.hash(base, quote);

  @override
  String toString() => '$base → $quote';
}
