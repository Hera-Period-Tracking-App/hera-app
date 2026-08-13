import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/widgets/app_text_field.dart';
import 'package:hera_app/features/auth/providers/auth_provider.dart';
import 'package:hera_app/l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);
    if (_initialEmail == null) {
      _initialEmail = email;
      _emailController.text = email;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.editAccount)),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.only(
                left: 16,
                top: 16,
                right: 16,
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _AccountEditSection(
                      title: l10n.updateEmail,
                      description: l10n.updateEmailDescription,
                      children: [
                        AppTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: l10n.newEmail,
                            hintText: l10n.emailHint,
                          ),
                          onChanged: (_) => _clearEmailError(),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailCurrentPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.currentPassword,
                          ),
                          onChanged: (_) => _clearEmailError(),
                        ),
                        if (_emailErrorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorText(_emailErrorMessage!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.sun,
                            foregroundColor: AppColors.ink,
                          ),
                          onPressed: _isSavingEmail || _isSavingPassword
                              ? null
                              : _saveEmail,
                          child:
                              Text(_isSavingEmail ? l10n.saving : l10n.saveEmail),
                        ),
                      ],
                    ),
                    const SizedBox(height: 36),
                    _AccountEditSection(
                      title: l10n.updatePassword,
                      description: l10n.updatePasswordDescription,
                      children: [
                        AppTextField(
                          controller: _passwordCurrentPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.currentPassword,
                          ),
                          onChanged: (_) => _clearPasswordError(),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.newPassword,
                          ),
                          onChanged: (_) => _clearPasswordError(),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _confirmNewPasswordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: l10n.confirmNewPassword,
                          ),
                          onChanged: (_) => _clearPasswordError(),
                        ),
                        if (_passwordErrorMessage != null) ...[
                          const SizedBox(height: 16),
                          _ErrorText(_passwordErrorMessage!),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.sun,
                            foregroundColor: AppColors.ink,
                          ),
                          onPressed: _isSavingEmail || _isSavingPassword
                              ? null
                              : _savePassword,
                          child: Text(
                            _isSavingPassword
                                ? l10n.saving
                                : l10n.savePassword,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 44),
                    _DangerCard(
                      title: l10n.deleteAccount,
                      description: l10n.deleteAccountDescription,
                      buttonLabel: l10n.deleteAccount,
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
    final l10n = AppLocalizations.of(context);

    if (currentPassword.isEmpty) {
      setState(() => _emailErrorMessage = l10n.enterCurrentPassword);
      return;
    }
    if (email == (_initialEmail ?? '').trim()) {
      setState(() => _emailErrorMessage = l10n.enterNewEmail);
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailErrorMessage = l10n.enterValidEmail);
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
        SnackBar(content: Text(l10n.emailUpdated)),
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
    final l10n = AppLocalizations.of(context);

    if (currentPassword.isEmpty) {
      setState(() => _passwordErrorMessage = l10n.enterCurrentPassword);
      return;
    }
    if (newPassword.trim().length < 8) {
      setState(
        () => _passwordErrorMessage = l10n.newPasswordTooShort,
      );
      return;
    }
    if (newPassword != confirmNewPassword) {
      setState(() => _passwordErrorMessage = l10n.newPasswordsDoNotMatch);
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
        SnackBar(content: Text(l10n.passwordUpdated)),
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
    final authNotifier = ref.read(authSessionProvider.notifier);
    final deleted = await showDialog<bool>(
      context: context,
      builder: (_) => _DeleteAccountDialog(
        onDelete: (currentPassword) async {
          await authNotifier.deleteAccount(currentPassword: currentPassword);
        },
      ),
    );

    if (deleted == true && mounted) {
      context.go(AppRoutePaths.profile);
    }
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog({
    required this.onDelete,
  });

  final Future<void> Function(String currentPassword) onDelete;

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.deleteAccountQuestion),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.deleteAccountWarning),
          const SizedBox(height: 16),
          AppTextField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: l10n.currentPassword,
            ),
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            _ErrorText(_errorMessage!),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          onPressed: _isDeleting ? null : _deleteAccount,
          child: Text(
            _isDeleting ? l10n.deleting : l10n.deleteAccount,
          ),
        ),
      ],
    );
  }

  Future<void> _deleteAccount() async {
    final l10n = AppLocalizations.of(context);
    final currentPassword = _passwordController.text;

    if (currentPassword.isEmpty) {
      setState(() => _errorMessage = l10n.enterCurrentPassword);
      return;
    }

    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await widget.onDelete(currentPassword);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isDeleting = false;
        _errorMessage = error.toString();
      });
    }
  }
}

class _AccountEditSection extends StatelessWidget {
  const _AccountEditSection({
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
    return Column(
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
        const SizedBox(height: 6),
        ...children,
      ],
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
  const _DangerCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onDelete,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.error,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 20),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
          ),
          onPressed: onDelete,
          child: Text(buttonLabel),
        ),
      ],
    );
  }
}
