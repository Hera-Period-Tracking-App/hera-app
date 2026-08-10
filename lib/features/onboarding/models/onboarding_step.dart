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
          subtitle: '',
        );

  const OnboardingStep.register()
      : this._(
          type: OnboardingStepType.register,
          title: 'Create your sync account',
          subtitle: 'Secure sync uses your Gmail and password to prepare backup.',
        );

  const OnboardingStep.cycleLength()
      : this._(
          type: OnboardingStepType.cycleLength,
          title: "What's your average cycle length?",
          subtitle: 'This helps Hera start with a useful baseline.',
        );

  const OnboardingStep.menstruationLength()
      : this._(
          type: OnboardingStepType.menstruationLength,
          title: "What's your average menstruation length?",
          subtitle: 'Tell Hera how long your period usually lasts.',
        );

  const OnboardingStep.lastCycleStart()
      : this._(
          type: OnboardingStepType.lastCycleStart,
          title: 'When did your last cycle start?',
          subtitle: 'Choose the date your most recent cycle began.',
        );

  const OnboardingStep.login()
      : this._(
          type: OnboardingStepType.login,
          title: 'Log in to your sync account',
          subtitle: 'Use your existing email address and password to continue.',
        );

  final OnboardingStepType type;
  final String title;
  final String subtitle;
}

enum OnboardingStepType {
  welcome,
  privacy,
  register,
  cycleLength,
  menstruationLength,
  lastCycleStart,
  login,
}
