# Code Patterns

Reference patterns for implementing features in this app. Each pattern is extracted from real working code.

---

## Pattern: MVVM Within a Feature

```
feature/
├── presentation/
│   ├── feature_controller.dart   ← ChangeNotifier, holds UI state
│   └── feature_controller_*.dart  ← Split by concern (editing, loading, etc.)
├── domain/
│   └── feature_state.dart        ← Immutable state class
├── data/
│   └── feature_repository.dart   ← Abstract interface
└── widgets/
    ├── feature_screen.dart       ← Screen (max 80 lines), listens to controller
    ├── feature_content.dart      ← Layout, wires callbacks
    └── feature_*.dart            ← Individual widgets
```

**Controller example:**
```dart
class FeatureController extends ChangeNotifier {
  FeatureState _state = FeatureState.initial();
  FeatureState get state => _state;

  final FeatureRepository _repository;

  Future<void> load() async {
    _state = _state.copyWith(status: Status.loading);
    notifyListeners();

    try {
      final data = await _repository.fetch();
      _state = _state.copyWith(status: Status.loaded, data: data);
    } catch (e) {
      _state = _state.copyWith(status: Status.error, message: e.toString());
    }
    notifyListeners();
  }
}
```

**Screen example:**
```dart
class FeatureScreen extends StatelessWidget {
  const FeatureScreen({required this.controller, super.key});

  final FeatureController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        final state = controller.state;
        return switch (state.status) {
          Status.initial => const SizedBox.shrink(),
          Status.loading => const Center(child: CircularProgressIndicator()),
          Status.loaded => FeatureContent(state: state, onAction: controller.doAction),
          Status.error => Center(child: Text(state.message ?? 'Error')),
        };
      },
    );
  }
}
```

---

## Pattern: Settings Screen with Controller

```
settings/
├── settings_screen.dart      ← Orchestrator (60-80 lines max)
├── settings_controller.dart  ← All interaction logic, holds state
└── widgets/
    ├── section_header.dart
    ├── switch_tile.dart
    └── {{feature}}_tile.dart
```

**Controller holds:**
- SharedPreferences reference
- All settings values as fields
- Methods for every user action (toggle, pick, clear)
- `notifyListeners()` after every mutation

**Screen is pure:**
- Reads state from controller
- Calls controller methods for actions
- No business logic, no state

---

## Pattern: Settings Sub-Widget Extraction

When a settings widget exceeds ~60 lines, extract it:

```dart
// settings/widgets/my_feature_tile.dart
class MyFeatureTile extends StatelessWidget {
  const MyFeatureTile({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: Icons.my_icon,
      title: 'My Feature',
      subtitle: 'Description of what this does',
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
```

**Use `SettingsTile` (from `shared/widgets/settings_tile.dart`) as the base
for all settings rows. It handles icon, title, subtitle, trailing layout.

---

## Pattern: State Class

Always use an immutable state class with `copyWith`:

```dart
class FeatureState {
  const FeatureState({
    required this.status,
    this.data,
    this.message,
  });

  final Status status;
  final Data? data;
  final String? message;

  static const initial = FeatureState(status: Status.initial);

  FeatureState copyWith({
    Status? status,
    Data? data,
    String? message,
  }) {
    return FeatureState(
      status: status ?? this.status,
      data: data ?? this.data,
      message: message ?? this.message,
    );
  }
}

enum Status { initial, loading, loaded, error }
```

---

## Pattern: File Split Checklist

Split a file when ANY trigger fires:

- [ ] File exceeds 200 lines
- [ ] Widget has >3 nested levels of Column/Row/Expanded
- [ ] build() method exceeds 30 lines
- [ ] Must scroll to understand what the file does
- [ ] File does more than one thing

**Typical split points:**
- Screen → Content widget (layout orchestration)
- Content → Individual row/widget components
- Controller → *_editing.dart, *_loading.dart (by concern)

---

## Pattern: Widget Callback Hierarchy

Always pass callbacks top-down, not data bottom-up:

```dart
// Parent screen
ChildWidget(
  onAction: controller.handleAction,
  onNavigate: () => Navigator.push(context, ...),
)

// Child receives callbacks only, never the controller itself
class ChildWidget extends StatelessWidget {
  const ChildWidget({required this.onAction, required this.onNavigate, ...});
  final VoidCallback onAction;
  final VoidCallback onNavigate;
}
```

---

## Pattern: Mock Repository for Tests

```dart
class _FakeFeatureRepository implements FeatureRepository {
  _FakeFeatureRepository({this.mockData});

  final Data? mockData;

  @override
  Future<Data?> fetch() async => mockData;
}
```

Use in `setUp()` of widget tests. Keep mock in test file, not in lib/.

---

## Pattern: Monetization Entitlement Check

```dart
// In widget that needs premium access
@override
Widget build(BuildContext context) {
  return ListenableBuilder(
    listenable: monetization,
    builder: (_, __) {
      if (!monetization.hasPremiumAccess) {
        return PaywallGate(product: ProductType.feature);
      }
      return PremiumContent();
    },
  );
}
```

MonetizationController (in `core/monetization/`) owns all entitlement state.
Never duplicate entitlement checks — always go through the controller.