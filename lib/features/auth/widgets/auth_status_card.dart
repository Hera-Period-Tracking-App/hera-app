import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/shared/widgets/section_placeholder_card.dart';

class AuthStatusCard extends ConsumerWidget {
  const AuthStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSession = ref.watch(authSessionProvider);
    final body = authSession.when(
      data: (session) {
        if (!session.isAuthenticated) {
          return 'Signed out. Use the form below to create an account or log in.';
        }

        final email = session.email?.trim();
        return email == null || email.isEmpty
            ? 'Signed in. Encrypted sync calls can now use the stored bearer token.'
            : 'Signed in as $email. Encrypted sync calls can now use the stored bearer token.';
      },
      loading: () => 'Checking secure session state.',
      error: (error, _) => 'Session check failed: $error',
    );

    return SectionPlaceholderCard(
      title: 'Authentication Status',
      body: body,
    );
  }
}
