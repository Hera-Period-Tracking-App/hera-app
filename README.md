<p align="center">
  <img src="assets/images/logo/hera_logo.png" alt="Hera" width="120" />
</p>

<h1 align="center">Hera</h1>

<p align="center">
  <strong>A private, offline-first menstrual cycle companion.</strong><br />
  Built with Flutter. Designed to keep sensitive health data on the device.
</p>

<p align="center">
  <a href="#quick-start">Quick start</a> ·
  <a href="#requirements">Requirements</a> ·
  <a href="#development">Development</a> ·
  <a href="#project-structure">Structure</a>
</p>

---

## What’s included

- Cycle tracking, calendar views, notes, and local predictions
- English and Slovenian localization
- Encrypted local SQLite storage via SQLCipher, with the key held in secure storage
- Optional biometric app lock
- Local cycle reminders and notifications
- A bundled, on-device language model for private cycle summaries—no API key or cloud service required

> **Privacy note:** Hera is a tracking and wellbeing tool, not medical advice or a diagnostic device.

## Quick start

```bash
# 1. Clone the repository and enter it
git clone <repository-url>
cd hera-app

# 2. Install Dart/Flutter packages
flutter pub get

# 3. Create generated Drift/Riverpod/JSON files
dart run build_runner build --delete-conflicting-outputs

# 4. Run on a connected device or emulator
flutter run
```

The app is ready to use locally after those steps—there are no environment variables, API keys, or backend services to configure.

## Requirements

| Tool | Required version | Why |
| --- | --- | --- |
| [Flutter](https://docs.flutter.dev/get-started/install) | `>= 3.24.0` | Application framework and tooling |
| Dart | `>= 3.5.0 < 4.0.0` | Installed with Flutter |
| Android Studio / Android SDK | Current stable | Android emulator, SDK, and native build tools |
| Xcode + CocoaPods | Current stable (macOS only) | iOS simulator and device builds |
| Java | 17 | Android Gradle builds |

Verify your environment before running the project:

```bash
flutter doctor
flutter devices
```

### Supported mobile targets

The bundled on-device AI integration uses the vendored `fllama` plugin. Its supported targets are Android (API 23+) and physical iOS devices (iOS 14+, arm64). For the full private-summary experience, use one of those targets. A physical device is strongly recommended: the model is memory-intensive and the iOS simulator does not support the plugin’s Metal path.

## Setup details

### Android

1. Install an Android SDK, emulator, and Android NDK through Android Studio.
2. Ensure Java 17 is selected (`java -version`).
3. Start an emulator or connect a USB-debugging-enabled device.
4. Run `flutter run`.

The application requests notification, biometric, boot-receive, and exact-alarm permissions as needed for reminders and app locking. Android 13+ will ask for notification permission at runtime.

### iOS

From macOS, after `flutter pub get`:

```bash
cd ios
pod install
cd ..
flutter run
```

Use a physical iPhone to exercise biometric unlock and the local AI summary. Face ID permission text is already configured in `ios/Runner/Info.plist`.

### Local AI model

`assets/models/LFM2-5-230M-q4-0.gguf` is committed as an app asset and is copied into app storage before use. It is approximately **142 MB**, so expect a larger first build/install and leave adequate free space on test devices. Do not remove it from `pubspec.yaml` unless the local summary feature is also disabled.

## Development

### Common commands

```bash
# Format Dart source
dart format lib test

# Static analysis
flutter analyze

# Run tests
flutter test

# Regenerate code once
dart run build_runner build --delete-conflicting-outputs

# Regenerate code while editing annotated models/tables
dart run build_runner watch --delete-conflicting-outputs

# Refresh Flutter localization output after editing lib/l10n/*.arb
flutter gen-l10n
```

Generated `*.g.dart` and `*.freezed.dart` files are intentionally excluded from version control. Always run code generation after a fresh clone or after modifying Drift tables, Riverpod generators, Freezed models, or JSON-serializable types.

### Native splash screen

The splash configuration lives in `pubspec.yaml`. After updating the splash image or colors, regenerate native resources with:

```bash
dart run flutter_native_splash:create
```

## Project structure

```text
lib/
├── core/              # Database, routing, theme, constants, and platform services
├── features/          # Feature modules: cycles, calendar, notes, settings, AI summaries…
├── l10n/              # English and Slovenian ARB translations plus generated output
├── shared/            # Reusable screens, widgets, providers, and domain models
├── app.dart           # Application shell, routing, locking, and lifecycle behavior
└── main.dart          # Flutter entry point

assets/
├── fonts/             # Brand typography
├── images/            # Logos and onboarding/home artwork
└── models/            # Bundled GGUF model used for local summaries

vendor/fllama/         # Local copy of the Flutter llama.cpp binding
```

## Architecture at a glance

Hera uses feature-oriented folders with Riverpod for state, GoRouter for navigation, and Drift + SQLCipher for its encrypted on-device database. Sensitive encryption material is generated locally and stored using `flutter_secure_storage`; it is never checked into the repository. Local notifications, biometric authentication, and the language model are accessed through platform plugins.

## Troubleshooting

| Symptom | What to try |
| --- | --- |
| Missing `*.g.dart` or generated class errors | Run `dart run build_runner build --delete-conflicting-outputs`. |
| Localization symbols are missing | Run `flutter gen-l10n`, then restart the IDE/analyzer. |
| Android native build fails | Run `flutter doctor`, confirm Java 17, and install the SDK/NDK components requested by your Flutter installation. |
| iOS pod issues | Run `cd ios && pod repo update && pod install`, then `flutter clean` and `flutter pub get` if necessary. |
| Local summary will not load | Test on a supported physical Android/iOS device and verify the GGUF asset is present. |

## License

This repository does not currently declare a project license. The vendored `fllama` dependency is licensed under MIT; see [`vendor/fllama/LICENSE`](vendor/fllama/LICENSE).
