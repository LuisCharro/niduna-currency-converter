import 'review_prompt_policy.dart';
import 'review_prompt_store.dart';
import 'review_service.dart';

/// Records local usage and asks for a Play rating after a successful
/// conversion once [ReviewPromptPolicy] allows it. Never throws: a review
/// failure must not affect conversion.
class ReviewPromptController {
  ReviewPromptController({
    required ReviewPromptStore store,
    required ReviewService service,
    ReviewPromptPolicy policy = const ReviewPromptPolicy(),
    DateTime Function()? clock,
  }) : _store = store,
       _service = service,
       _policy = policy,
       _clock = clock ?? DateTime.now;

  final ReviewPromptStore _store;
  final ReviewService _service;
  final ReviewPromptPolicy _policy;
  final DateTime Function() _clock;
  bool _requesting = false;

  Future<void> recordLaunch() => _store.recordActiveDay(_clock());

  /// Call after the user commits a new amount and rates are on screen.
  Future<void> onConversionCompleted({required bool hasRates}) async {
    final now = _clock();
    await _store.recordActiveDay(now);
    if (!hasRates || _requesting) return;
    if (!_policy.shouldRequest(_store.read(), now)) return;
    _requesting = true;
    try {
      if (!await _service.isAvailable()) return;
      await _store.recordRequest(now);
      await _service.requestReview();
    } catch (_) {
      // Play unavailable or quota errors are not user-facing.
    } finally {
      _requesting = false;
    }
  }
}
