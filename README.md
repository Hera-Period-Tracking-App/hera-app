# hera-app

Privacy-first Flutter architecture for an offline-first menstrual cycle tracking app.

## Setup

1. Install Flutter and Dart locally.
2. Run `flutter pub get`.
3. Run `dart run build_runner build`.
4. Run `flutter run`.

## Included Architecture

- `Riverpod` for state management
- `GoRouter` for centralized navigation
- `Drift` for local SQLite persistence
- `Freezed` and `json_serializable` for immutable models
- `Flutter Secure Storage` for secrets and privacy mode
