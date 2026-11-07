import 'package:flutter_riverpod/flutter_riverpod.dart';

final shellNavigationVisibleProvider = NotifierProvider<ShellNavigationVisibilityNotifier, bool>(
  ShellNavigationVisibilityNotifier.new,
);

class ShellNavigationVisibilityNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setVisible(bool value) {
    state = value;
  }

  void restoreVisibilityAfterUnmount() {
    Future<void>.microtask(() {
      if (ref.mounted) setVisible(true);
    });
  }
}
