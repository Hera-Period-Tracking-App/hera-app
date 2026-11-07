#!/usr/bin/env bash
set -euo pipefail

device="${ANDROID_SERIAL:-emulator-5554}"
app_id="com.example.hera_app"
apk="build/app/outputs/flutter-apk/app-debug.apk"
mkdir -p reports

# Collect diagnostics while the emulator is still running, including on failure.
collect_diagnostics() {
  local result=$?
  trap - EXIT
  adb -s "$device" logcat -d > reports/android-logcat.txt 2>&1 || true
  if (( result != 0 )); then
    adb -s "$device" exec-out screencap -p > reports/failure-screen.png 2>/dev/null || true
  fi
  printf '%s\n' "$result" > reports/exit-code.txt
  exit "$result"
}
trap collect_diagnostics EXIT

adb -s "$device" wait-for-device
adb -s "$device" logcat -c
adb -s "$device" install -r -g "$apk"
adb -s "$device" shell pm grant "$app_id" android.permission.POST_NOTIFICATIONS

# pipefail preserves a failing test exit code even though tee writes the report.
flutter test --no-pub integration_test/functional_suite.dart \
  -d "$device" --no-uninstall --machine \
  2> reports/flutter-stderr.log | tee reports/functional-tests.json
