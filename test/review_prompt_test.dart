import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:currency_converter/src/core/review/review_prompt_controller.dart';
import 'package:currency_converter/src/core/review/review_prompt_policy.dart';
import 'package:currency_converter/src/core/review/review_prompt_store.dart';
import 'package:currency_converter/src/core/review/review_service.dart';

class _FakeReviewService implements ReviewService {
  _FakeReviewService({this.available = true, this.throwOnRequest = false});

  final bool available;
  final bool throwOnRequest;
  int requests = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {
    requests++;
    if (throwOnRequest) throw Exception('quota');
  }
}

void main() {
  final day0 = DateTime(2026, 11, 1, 10);
  DateTime dayN(int n) => day0.add(Duration(days: n));

  group('ReviewPromptPolicy', () {
    const policy = ReviewPromptPolicy();

    test('requires a first-seen date', () {
      expect(
        policy.shouldRequest(const ReviewPromptStats(activeDays: 9), dayN(30)),
        isFalse,
      );
    });

    test('requires 3 active days and 5 days since first seen', () {
      ReviewPromptStats stats(int activeDays) =>
          ReviewPromptStats(firstSeen: day0, activeDays: activeDays);
      expect(policy.shouldRequest(stats(2), dayN(10)), isFalse);
      expect(policy.shouldRequest(stats(3), dayN(4)), isFalse);
      expect(policy.shouldRequest(stats(3), dayN(5)), isTrue);
    });

    test('waits 120 days between requests and stops after 3', () {
      ReviewPromptStats stats(int count, DateTime? last) => ReviewPromptStats(
        firstSeen: day0,
        activeDays: 10,
        requestCount: count,
        lastRequestAt: last,
      );
      expect(policy.shouldRequest(stats(1, dayN(10)), dayN(129)), isFalse);
      expect(policy.shouldRequest(stats(1, dayN(10)), dayN(130)), isTrue);
      expect(policy.shouldRequest(stats(3, dayN(10)), dayN(400)), isFalse);
    });
  });

  group('ReviewPromptStore', () {
    setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

    test('counts each local calendar day once', () async {
      final store = ReviewPromptStore(await SharedPreferences.getInstance());
      await store.recordActiveDay(day0);
      await store.recordActiveDay(day0.add(const Duration(hours: 5)));
      await store.recordActiveDay(dayN(1));
      final stats = store.read();
      expect(stats.activeDays, 2);
      expect(stats.firstSeen, day0);
    });

    test('records request count and time', () async {
      final store = ReviewPromptStore(await SharedPreferences.getInstance());
      await store.recordRequest(dayN(6));
      await store.recordRequest(dayN(130));
      final stats = store.read();
      expect(stats.requestCount, 2);
      expect(stats.lastRequestAt, dayN(130));
    });
  });

  group('ReviewPromptController', () {
    late SharedPreferences prefs;
    late DateTime now;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      prefs = await SharedPreferences.getInstance();
      now = day0;
    });

    ReviewPromptController build(ReviewService service) =>
        ReviewPromptController(
          store: ReviewPromptStore(prefs),
          service: service,
          clock: () => now,
        );

    Future<void> useOnDays(ReviewPromptController c, List<int> days) async {
      for (final d in days) {
        now = dayN(d);
        await c.recordLaunch();
      }
    }

    test('asks once after enough usage, then not again soon', () async {
      final service = _FakeReviewService();
      final controller = build(service);
      await useOnDays(controller, [0, 2]);

      now = dayN(3);
      await controller.onConversionCompleted(hasRates: true);
      expect(service.requests, 0, reason: 'only 3 days since first seen');

      now = dayN(5);
      await controller.onConversionCompleted(hasRates: true);
      expect(service.requests, 1);

      now = dayN(6);
      await controller.onConversionCompleted(hasRates: true);
      expect(service.requests, 1);
    });

    test('never asks without rates on screen', () async {
      final service = _FakeReviewService();
      final controller = build(service);
      await useOnDays(controller, [0, 1, 2]);
      now = dayN(8);
      await controller.onConversionCompleted(hasRates: false);
      expect(service.requests, 0);
    });

    test('does not count a request when Play is unavailable', () async {
      final service = _FakeReviewService(available: false);
      final controller = build(service);
      await useOnDays(controller, [0, 1, 2]);
      now = dayN(8);
      await controller.onConversionCompleted(hasRates: true);
      expect(ReviewPromptStore(prefs).read().requestCount, 0);
    });

    test('swallows platform errors', () async {
      final service = _FakeReviewService(throwOnRequest: true);
      final controller = build(service);
      await useOnDays(controller, [0, 1, 2]);
      now = dayN(8);
      await expectLater(
        controller.onConversionCompleted(hasRates: true),
        completes,
      );
      expect(service.requests, 1);
    });
  });
}
