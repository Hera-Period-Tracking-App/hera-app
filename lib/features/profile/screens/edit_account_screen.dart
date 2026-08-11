import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';

class EditAccountScreen extends ConsumerStatefulWidget {
  const EditAccountScreen({super.key});

  @override
  ConsumerState<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends ConsumerState<EditAccountScreen> {
  final _emailController = TextEditingController();
  final _emailCurrentPasswordController = TextEditingController();
  final _passwordCurrentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  String? _initialEmail;
  String? _emailErrorMessage;
  String? _passwordErrorMessage;
  bool _isSavingEmail = false;
  bool _isSavingPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _emailCurrentPasswordController.dispose();
    _passwordCurrentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authSessionProvider);
    final session = authState.asData?.value;
    final email = session?.email?.trim() ?? '';
    if (_initialEmail == null) {
      _initialEmail = email;
      _emailController.text = email;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit account')),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AccountEditCard(
                      title: 'Update email',
                      description:
                          'Change the email address connected to your account.',
                      children: [
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'New email',
                            hintText: 'you@example.com',
                          ),
                          onChanged: (_) => _clearEmailError(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailCurrentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Current password',
                          ),
                          onChanged: (_) => _clearEmailError(),
                        ),
                        if (_emailErrorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorText(_emailErrorMessage!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isSavingEmail || _isSavingPassword
                              ? null
                              : _saveEmail,
                          child:
                              Text(_isSavingEmail ? 'Saving...' : 'Save email'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _AccountEditCard(
                      title: 'Update password',
                      description: 'Choose a new password for this account.',
                      children: [
                        TextField(
                          controller: _passwordCurrentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Current password',
                          ),
                          onChanged: (_) => _clearPasswordError(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New password',
                          ),
                          onChanged: (_) => _clearPasswordError(),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _confirmNewPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirm new password',
                          ),
                          onChanged: (_) => _clearPasswordError(),
                        ),
                        if (_passwordErrorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorText(_passwordErrorMessage!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: _isSavingEmail || _isSavingPassword
                              ? null
                              : _savePassword,
                          child: Text(
                            _isSavingPassword ? 'Saving...' : 'Save password',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    _DangerCard(
                      onDelete: _showDeleteAccountDialog,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _saveEmail() async {
    final email = _emailController.text.trim();
    final currentPassword = _emailCurrentPasswordController.text;

    if (currentPassword.isEmpty) {
      setState(() => _emailErrorMessage = 'Enter your current password.');
      return;
    }
    if (email == (_initialEmail ?? '').trim()) {
      setState(() => _emailErrorMessage = 'Enter a new email address.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailErrorMessage = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _isSavingEmail = true;
      _emailErrorMessage = null;
    });

    try {
      await ref.read(authSessionProvider.notifier).updateAccount(
            currentPassword: currentPassword,
            email: email,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _initialEmail = email;
        _isSavingEmail = false;
        _emailCurrentPasswordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSavingEmail = false;
        _emailErrorMessage = error.toString();
      });
    }
  }

  Future<void> _savePassword() async {
    final currentPassword = _passwordCurrentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final confirmNewPassword = _confirmNewPasswordController.text;

    if (currentPassword.isEmpty) {
      setState(() => _passwordErrorMessage = 'Enter your current password.');
      return;
    }
    if (newPassword.trim().length < 8) {
      setState(
        () => _passwordErrorMessage =
            'New password must be at least 8 characters.',
      );
      return;
    }
    if (newPassword != confirmNewPassword) {
      setState(() => _passwordErrorMessage = 'New passwords do not match.');
      return;
    }

    setState(() {
      _isSavingPassword = true;
      _passwordErrorMessage = null;
    });

    try {
      await ref.read(authSessionProvider.notifier).updateAccount(
            currentPassword: currentPassword,
            newPassword: newPassword,
          );
      if (!mounted) {
        return;
      }
      setState(() {
        _isSavingPassword = false;
        _passwordCurrentPasswordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated.')),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSavingPassword = false;
        _passwordErrorMessage = error.toString();
      });
    }
  }

  void _clearEmailError() {
    if (_emailErrorMessage != null) {
      setState(() => _emailErrorMessage = null);
    }
  }

  void _clearPasswordError() {
    if (_passwordErrorMessage != null) {
      setState(() => _passwordErrorMessage = null);
    }
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
  }

  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    String? errorMessage;
    var isDeleting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> deleteAccount() async {
              final currentPassword = passwordController.text;
              if (currentPassword.isEmpty) {
                setDialogState(() {
                  errorMessage = 'Enter your current password.';
                });
                return;
              }

              setDialogState(() {
                isDeleting = true;
                errorMessage = null;
              });

              try {
                await ref
                    .read(authSessionProvider.notifier)
                    .deleteAccount(currentPassword: currentPassword);
                if (!dialogContext.mounted) {
                  return;
                }
                Navigator.of(dialogContext).pop();
                if (mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted.')),
                  );
                }
              } catch (error) {
                if (!dialogContext.mounted) {
                  return;
                }
                setDialogState(() {
                  isDeleting = false;
                  errorMessage = error.toString();
                });
              }
            }

            return AlertDialog(
              title: const Text('Delete account?'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'This deletes your account and encrypted sync records. This cannot be undone.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Current password',
                    ),
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setDialogState(() => errorMessage = null);
                      }
                    },
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 12),
                    _ErrorText(errorMessage!),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                  onPressed: isDeleting ? null : deleteAccount,
                  child: Text(isDeleting ? 'Deleting...' : 'Delete account'),
                ),
              ],
            );
          },
        );
      },
    );

    passwordController.dispose();
  }
}

class _AccountEditCard extends StatelessWidget {
  const _AccountEditCard({
    required this.title,
    required this.description,
    required this.children,
  });

  final String title;
  final String description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(description, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        color: Theme.of(context).colorScheme.error,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  const _DangerCard({required this.onDelete});

  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Delete account',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.error,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Permanently delete your account and encrypted sync records.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
            ),
            onPressed: onDelete,
            child: const Text('Delete account'),
          ),
        ],
      ),
    );
  }
}
