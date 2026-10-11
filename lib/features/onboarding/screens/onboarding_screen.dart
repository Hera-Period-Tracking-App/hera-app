import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hera_app/core/routes/app_route_paths.dart';
import 'package:hera_app/core/theme/app_colors.dart';
import 'package:hera_app/core/theme/app_theme_style.dart';
import 'package:hera_app/core/theme/theme_style_provider.dart';
import 'package:hera_app/features/cycles/exceptions/cycle_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/duplicate_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/future_cycle_exception.dart';
import 'package:hera_app/features/cycles/exceptions/menstruation_length_exception.dart';
import 'package:hera_app/features/cycles/exceptions/overlapping_cycle_exception.dart';
import 'package:hera_app/features/cycles/providers/cycles_provider.dart';
import 'package:hera_app/features/cycles/repositories/cycle_repository.dart';
import 'package:hera_app/features/onboarding/models/onboarding_step.dart';
import 'package:hera_app/features/onboarding/providers/onboarding_provider.dart';
import 'package:hera_app/features/onboarding/screens/cycle_length_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/last_cycle_start_onboarding_screen.dart';
import 'package:hera_app/features/onboarding/screens/menstruation_length_onboarding_screen.dart';
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
  static const _steps = [
    OnboardingStep.welcome(),
    OnboardingStep.cycleLength(),
    OnboardingStep.menstruationLength(),
    OnboardingStep.lastCycleStart(),
  ];
  int _currentStep = 0;
  double _cycleLength = 28;
  double _menstruationLength = 5;
  DateTime _lastCycleStart = DateTime.now().subtract(const Duration(days: 4));
  bool _saving = false;
  bool _welcomeReady = false;

  @override
  Widget build(BuildContext context) {
    final onboarding = ref.watch(onboardingProvider);
    if (onboarding.isLoading || _saving) return const StartupLoadingScreen();
    final step = _steps[_currentStep];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(systemNavigationBarColor: AppColors.twilight, systemNavigationBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: AppColors.twilight,
        body: SafeArea(
          bottom: false,
          child: Column(children: [
            Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: OnboardingProgressHeader(currentStep: _currentStep, totalSteps: _steps.length, title: step.title, subtitle: step.subtitle, showStepInfo: step.type != OnboardingStepType.welcome)),
            const SizedBox(height: 16),
            Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: step.type == OnboardingStepType.welcome ? 0 : 20), child: _step(step.type))),
            if ((step.type != OnboardingStepType.welcome || _welcomeReady) && MediaQuery.viewInsetsOf(context).bottom == 0)
              Padding(padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.paddingOf(context).bottom), child: OnboardingFooter(canGoBack: _currentStep > 0, isSaving: _saving, isLastStep: _currentStep == _steps.length - 1, canContinue: true, animateContinueLabel: true, continueLabelAnimationKey: _currentStep, onBack: _back, onContinue: _currentStep == _steps.length - 1 ? _finish : _next)),
          ]),
        ),
      ),
    );
  }

  Widget _step(OnboardingStepType type) => switch (type) {
    OnboardingStepType.welcome => WelcomeOnboardingScreen(onTypingCompleted: () => setState(() => _welcomeReady = true)),
    OnboardingStepType.cycleLength => CycleLengthOnboardingScreen(cycleLength: _cycleLength, onChanged: (v) => setState(() => _cycleLength = v)),
    OnboardingStepType.menstruationLength => MenstruationLengthOnboardingScreen(menstruationLength: _menstruationLength, onChanged: (v) => setState(() => _menstruationLength = v)),
    OnboardingStepType.lastCycleStart => LastCycleStartOnboardingScreen(lastCycleStart: _lastCycleStart, onChanged: (v) => setState(() => _lastCycleStart = v)),
  };

  void _next() => setState(() => _currentStep++);
  void _back() => setState(() => _currentStep--);
  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await ref.read(cycleRepositoryProvider).addCycle(startDate: _lastCycleStart, cycleLength: _cycleLength.round(), menstruationLength: _menstruationLength.round());
      ref.invalidate(cyclesProvider);
      await ref.read(themeStyleProvider.notifier).setStyle(AppThemeStyle.dark);
      await ref.read(onboardingProvider.notifier).completeOnboarding(privacyMode: PrivacyMode.localOnly, averageCycleLength: _cycleLength.round(), averageMenstruationLength: _menstruationLength.round());
      if (mounted) context.go(AppRoutePaths.home);
    } on FutureCycleException catch (e) { _error(e.message); }
      on CycleLengthException catch (e) { _error(e.message); }
      on MenstruationLengthException catch (e) { _error(e.message); }
      on DuplicateCycleException catch (e) { _error(e.message); }
      on OverlappingCycleException catch (e) { _error(e.message); }
      catch (_) { _error('Could not save your cycle right now. Please try again.'); }
  }
  void _error(String message) { if (mounted) { setState(() => _saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); } }
}
