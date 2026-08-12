import 'package:flutter/material.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';
class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({super.key});

  static const _backgroundColor = Color(0xFF12131A);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'HERA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 64,
                  height: 0.9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.preparingPrivateSpace,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.58),
                  fontFamily: 'monospace',
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
