import 'package:flutter/material.dart';
class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  static const _backgroundColor = Color(0xFF12131A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 42,
            height: 42,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
