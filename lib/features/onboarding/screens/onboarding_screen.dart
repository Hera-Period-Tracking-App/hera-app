import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/dev/dev_flags.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/core/theme/theme_style_provider.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/onboarding/models/onboarding_step.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/onboarding/screens/cycle_length_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/last_cycle_start_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/login_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/menstruation_length_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/privacy_mode_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/register_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/welcome_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/widgets/onboarding_footer.dart';
import 'package:hera_app/features/onboarding/widgets/onboarding_progress_header.dart';
import 'package:hera_app/shared/models/privacy_mode.dart';
import 'package:hera_app/shared/screens/startup_loading_screen.dart';

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
  double _cycleLength = 28;
  double _menstruationLength = 5;
  DateTime _lastCycleStart = DateTime.now().subtract(const Duration(days: 4));
  bool _submitted = false;
  bool _isSaving = false;
  bool _welcomeAnimationCompleted = false;
  bool _welcomeAssetsReady = false;
  bool _welcomeAssetsPreloadStarted = false;
  bool _isLoginFlow = false;

  List<OnboardingStep> get _steps {
    return [
      const OnboardingStep.welcome(),
      const OnboardingStep.privacy(),
      if (_selectedPrivacyMode == PrivacyMode.secureSync)
        const OnboardingStep.register(),
      if (_isLoginFlow)
        const OnboardingStep.login()
      else ...[
        const OnboardingStep.cycleLength(),
        const OnboardingStep.menstruationLength(),
        const OnboardingStep.lastCycleStart(),
      ],
    ];
  }

  bool get _isLastStep => _currentStep == _steps.length - 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_welcomeAssetsPreloadStarted) {
      return;
    }

    _welcomeAssetsPreloadStarted = true;
    _preloadWelcomeAssets();
  }

  Future<void> _preloadWelcomeAssets() async {
    try {
      await Future.wait([
        precacheImage(
          const AssetImage('assets/images/homepage/hera.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/homepage/athena.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/homepage/persephone.png'),
          context,
        ),
        Future<void>.delayed(const Duration(seconds: 2)),
      ]);
    } catch (error) {
      debugPrint('Onboarding assets could not be preloaded: $error');
      return;
    }

    if (mounted) {
      setState(() => _welcomeAssetsReady = true);
    }
  }

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
      return const StartupLoadingScreen();
    }

    if (!_welcomeAssetsReady) {
      return const StartupLoadingScreen();
    }

    _selectedPrivacyMode ??= loadedStatus?.selectedPrivacyMode;

    final step = _steps[_currentStep];
    final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final isRegisterStep = step.type == OnboardingStepType.register;
    final isAccountStep = isRegisterStep || step.type == OnboardingStepType.login;
    final theme = Theme.of(context);

    final systemBarColor = isAccountStep ? theme.cardColor : AppColors.twilight;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: systemBarColor,
        systemNavigationBarDividerColor: systemBarColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: systemBarColor,
        body: ColoredBox(
          color: AppColors.twilight,
          child: SafeArea(
            bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: OnboardingProgressHeader(
                  currentStep: _currentStep,
                  totalSteps: _steps.length,
                  title: step.title,
                  subtitle: step.subtitle,
                  showStepInfo: step.type != OnboardingStepType.welcome,
                ),
              ),
              SizedBox(height: isAccountStep ? 36 : 20),
              Expanded(
                child: ColoredBox(
                  color: Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isAccountStep ||
                              step.type == OnboardingStepType.welcome
                          ? 0
                          : 20,
                    ),
                    child: _buildStep(step.type),
                  ),
                ),
              ),
              if ((step.type != OnboardingStepType.welcome ||
                      _welcomeAnimationCompleted) &&
                  !isKeyboardVisible)
                ColoredBox(
                  color: isAccountStep ? theme.cardColor : Colors.transparent,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      20,
                      20,
                      20 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: OnboardingFooter(
                    canGoBack: _currentStep > 0,
                    isSaving: _isSaving,
                    isLastStep: _isLastStep,
                    canContinue: _canUsePrimaryButton(step.type),
                    animateContinueLabel: true,
                    continueLabelAnimationKey: _currentStep,
                    infoText: switch (step.type) {
                      OnboardingStepType.privacy =>
                        'You can start offline today and switch to secure sync later.',
                      OnboardingStepType.cycleLength =>
                        'You can change your cycle length anytime. Hera will refine its predictions based on your previous cycles.',
                      OnboardingStepType.menstruationLength =>
                        'You can change your menstruation length anytime as you learn what is typical for you.',
                      OnboardingStepType.lastCycleStart =>
                        'You can always change your cycle start date later.',
                      _ => null,
                    },
                    secondaryAction: isRegisterStep
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: theme.textTheme.bodySmall,
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoginFlow = true;
                                    _currentStep = _steps.length - 1;
                                    _submitted = false;
                                  });
                                },
                                child: const Text('Log in'),
                              ),
                            ],
                          )
                        : null,
                    onBack: _goBack,
                      onContinue: _isLastStep ? _finishOnboarding : _goNext,
                    ),
                  ),
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
      OnboardingStepType.welcome => WelcomeOnboardingScreen(
          onTypingCompleted: () {
            if (mounted) {
              setState(() => _welcomeAnimationCompleted = true);
            }
          },
        ),
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
      OnboardingStepType.login => LoginOnboardingScreen(
          emailController: _emailController,
          passwordController: _passwordController,
          submitted: _submitted,
          onChanged: () => setState(() {}),
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
      if (_isLoginFlow) {
        _isLoginFlow = false;
        // Registration is always the third screen in the secure-sync flow.
        _currentStep = 2;
      } else {
        _currentStep -= 1;
      }
      if (_currentStep == 0) {
        _welcomeAnimationCompleted = false;
      }
    });
  }

  Future<void> _finishOnboarding() async {
    if (_selectedPrivacyMode == null) {
      return;
    }

    if (_steps[_currentStep].type == OnboardingStepType.login &&
        !_isValidSyncAccount()) {
      setState(() => _submitted = true);
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
    } on OverlappingCycleException catch (error) {
      _showSaveError(error.message);
    } catch (error) {
      debugPrint('Onboarding save failed: $error');
      _showSaveError('Could not save your cycle right now. Please try again.');
      return;
    }

    try {
      await ref.read(themeStyleProvider.notifier).setStyle(AppThemeStyle.dark);
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
    final email = _emailController.text.trim();
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email) &&
        _passwordController.text.trim().length >= 8;
  }
}
