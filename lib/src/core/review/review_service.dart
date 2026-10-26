import 'package:in_app_review/in_app_review.dart';

/// Platform rating dialog. Abstract so tests never touch the plugin.
abstract class ReviewService {
  Future<bool> isAvailable();
  Future<void> requestReview();
}

/// Google Play In-App Review. The dialog only appears for Play-installed
/// builds and Play may silently skip it when its own quota is reached.
class InAppReviewService implements ReviewService {
  InAppReviewService({InAppReview? inAppReview})
    : _inAppReview = inAppReview ?? InAppReview.instance;

  final InAppReview _inAppReview;

  @override
  Future<bool> isAvailable() => _inAppReview.isAvailable();

  @override
  Future<void> requestReview() => _inAppReview.requestReview();
}
