import 'package:flutter/material.dart';
import 'package:hera_app/features/auth/widgets/auth_status_card.dart';
import 'package:hera_app/shared/widgets/placeholder_feature_screen.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PlaceholderFeatureScreen(
        title: 'Authentication',
        description:
            'Privacy-preserving sign-in, biometrics, and PIN flows will be attached here.',
        cards: [
          AuthStatusCard(),
          SectionPlaceholderCard(
            title: 'Secure Storage',
            body: 'Sensitive credentials remain in Flutter Secure Storage only.',
          ),
        ],
      ),
    );
  }
}
