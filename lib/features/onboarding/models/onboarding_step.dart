class OnboardingStep {
  const OnboardingStep._({
    required this.type,
    required this.title,
    required this.subtitle,
  });

  const OnboardingStep.welcome()
      : this._(
          type: OnboardingStepType.welcome,
          title: 'Welcome to Hera',
          subtitle: 'A private cycle companion shaped around your body and data.',
        );

  const OnboardingStep.privacy()
      : this._(
          type: OnboardingStepType.privacy,
          title: 'Choose your privacy mode',
          subtitle: 'Start offline or create an account for secure sync.',
        );

  const OnboardingStep.register()
      : this._(
          type: OnboardingStepType.register,
          title: 'Create your sync account',
          subtitle: 'Secure sync uses your Gmail and password to prepare backup.',
        );

  const OnboardingStep.theme()
      : this._(
          type: OnboardingStepType.theme,
          title: 'Pick a theme',
          subtitle: 'Choose the look Hera should use every day.',
        );

  const OnboardingStep.cycleLength()
      : this._(
          type: OnboardingStepType.cycleLength,
          title: 'Average cycle length',
          subtitle: 'This helps Hera start with a useful baseline.',
        );

  const OnboardingStep.menstruationLength()
      : this._(
          type: OnboardingStepType.menstruationLength,
          title: 'Average menstruation length',
          subtitle: 'Tell Hera how long your period usually lasts.',
        );

  const OnboardingStep.lastCycleStart()
      : this._(
          type: OnboardingStepType.lastCycleStart,
          title: 'Last cycle start',
          subtitle: 'Choose the date your most recent cycle began.',
        );

  final OnboardingStepType type;
  final String title;
  final String subtitle;
}

enum OnboardingStepType {
  welcome,
  privacy,
  register,
  theme,
  cycleLength,
  menstruationLength,
  lastCycleStart,
}
