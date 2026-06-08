import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/dev/dev_flags.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/core/theme/theme_style_provider.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/onboarding/models/onboarding_step.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/onboarding/screens/cycle_length_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/last_cycle_start_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/menstruation_length_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/privacy_mode_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/register_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/theme_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/welcome_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/widgets/onboarding_footer.dart';
import 'package:hera_app/features/onboarding/widgets/onboarding_progress_header.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  int _currentStep = 0;
  PrivacyMode? _selectedPrivacyMode;
  AppThemeStyle _selectedTheme = AppThemeStyle.dark;
  double _cycleLength = 28;
  double _menstruationLength = 5;
  DateTime _lastCycleStart = DateTime.now().subtract(const Duration(days: 4));
  bool _submitted = false;
  bool _isSaving = false;

  List<OnboardingStep> get _steps {
    return [
      const OnboardingStep.welcome(),
      const OnboardingStep.privacy(),
      if (_selectedPrivacyMode == PrivacyMode.secureSync)
        const OnboardingStep.register(),
      const OnboardingStep.theme(),
      const OnboardingStep.cycleLength(),
      const OnboardingStep.menstruationLength(),
      const OnboardingStep.lastCycleStart(),
    ];
  }

  bool get _isLastStep => _currentStep == _steps.length - 1;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardingState = ref.watch(onboardingProvider);
    final loadedStatus = onboardingState.asData?.value;
    final forceShowOnboarding = ref.watch(devShowOnboardingProvider);
    if (!forceShowOnboarding && loadedStatus?.hasCompletedOnboarding == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(AppRoutePaths.calendar);
        }
      });
    }

    _selectedPrivacyMode ??= loadedStatus?.selectedPrivacyMode;

    final theme = Theme.of(context);
    final step = _steps[_currentStep];

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
              theme.colorScheme.primary.withValues(alpha: 0.12),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingProgressHeader(
                  currentStep: _currentStep,
                  totalSteps: _steps.length,
                  title: step.title,
                  subtitle: step.subtitle,
                ),
                const SizedBox(height: 20),
                Expanded(child: _buildStep(step.type)),
                const SizedBox(height: 20),
                OnboardingFooter(
                  canGoBack: _currentStep > 0,
                  isSaving: _isSaving,
                  isLastStep: _isLastStep,
                  canContinue: _canUsePrimaryButton(step.type),
                  onBack: _goBack,
                  onContinue: _isLastStep ? _finishOnboarding : _goNext,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep(OnboardingStepType stepType) {
    final screen = switch (stepType) {
      OnboardingStepType.welcome => const WelcomeOnboardingScreen(),
      OnboardingStepType.privacy => PrivacyModeOnboardingScreen(
          selectedPrivacyMode: _selectedPrivacyMode,
          onSelected: (mode) => setState(() => _selectedPrivacyMode = mode),
        ),
      OnboardingStepType.register => RegisterOnboardingScreen(
          emailController: _emailController,
          passwordController: _passwordController,
          submitted: _submitted,
          onChanged: () => setState(() {}),
        ),
      OnboardingStepType.theme => ThemeOnboardingScreen(
          selectedTheme: _selectedTheme,
          onSelected: (style) => setState(() => _selectedTheme = style),
        ),
      OnboardingStepType.cycleLength => CycleLengthOnboardingScreen(
          cycleLength: _cycleLength,
          onChanged: (value) => setState(() => _cycleLength = value),
        ),
      OnboardingStepType.menstruationLength => MenstruationLengthOnboardingScreen(
          menstruationLength: _menstruationLength,
          onChanged: (value) => setState(() => _menstruationLength = value),
        ),
      OnboardingStepType.lastCycleStart => LastCycleStartOnboardingScreen(
          lastCycleStart: _lastCycleStart,
          onChanged: (date) => setState(() => _lastCycleStart = date),
        ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.06, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<String>(stepType.name),
        child: screen,
      ),
    );
  }

  bool _canUsePrimaryButton(OnboardingStepType stepType) {
    return switch (stepType) {
      OnboardingStepType.privacy => _selectedPrivacyMode != null,
      _ => true,
    };
  }

  void _goNext() {
    final stepType = _steps[_currentStep].type;

    if (stepType == OnboardingStepType.register && !_isValidSyncAccount()) {
      setState(() => _submitted = true);
      return;
    }

    setState(() {
      _submitted = false;
      _currentStep += 1;
    });
  }

  void _goBack() {
    setState(() {
      _submitted = false;
      _currentStep -= 1;
    });
  }

  Future<void> _finishOnboarding() async {
    if (_selectedPrivacyMode == null) {
      return;
    }

    setState(() {
      _submitted = true;
      _isSaving = true;
    });

    try {
      await ref.read(cycleRepositoryProvider).addCycle(
            startDate: _lastCycleStart,
            cycleLength: _cycleLength.round(),
            menstruationLength: _menstruationLength.round(),
          );
    } on FutureCycleException catch (error) {
      _showSaveError(error.message);
    } on CycleLengthException catch (error) {
      _showSaveError(error.message);
    } on MenstruationLengthException catch (error) {
      _showSaveError(error.message);
    } on DuplicateCycleException catch (error) {
      _showSaveError(error.message);
    } catch (error) {
      debugPrint('Onboarding save failed: $error');
      _showSaveError('Could not save your cycle right now. Please try again.');
      return;
    }

    try {
      await ref.read(themeStyleProvider.notifier).setStyle(_selectedTheme);
      await ref.read(onboardingProvider.notifier).completeOnboarding(
            privacyMode: _selectedPrivacyMode!,
        averageCycleLength: _cycleLength.round(),
        averageMenstruationLength: _menstruationLength.round(),
          );
    } catch (error) {
      debugPrint('Onboarding completion failed: $error');
      _showSaveError(
        'Your cycle was saved, but onboarding could not finish. Please reopen the app.',
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    context.go(AppRoutePaths.home);
  }

  void _showSaveError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  bool _isValidSyncAccount() {
    final email = _emailController.text.trim().toLowerCase();
    return RegExp(r'^[^@\s]+@gmail\.com$').hasMatch(email) &&
        _passwordController.text.trim().length >= 8;
  }
}
