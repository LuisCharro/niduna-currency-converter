/// Signals that the UI no longer owns a rewarded-ad request.
///
/// Services cancel loading requests; an ad already handed to the SDK retains
/// its earned reward and completes when the SDK dismisses it.
class RewardedAdCancellation {
  bool _cancelled = false;
  final Set<void Function()> _listeners = {};

  bool get isCancelled => _cancelled;

  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    for (final listener in List.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  void addListener(void Function() listener) {
    if (_cancelled) {
      listener();
    } else {
      _listeners.add(listener);
    }
  }

  void removeListener(void Function() listener) => _listeners.remove(listener);
}
