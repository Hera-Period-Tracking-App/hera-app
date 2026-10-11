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


  final OnboardingStepType type;
  final String title;
  final String subtitle;
}

enum OnboardingStepType {
  welcome,
  cycleLength,
  menstruationLength,
  lastCycleStart,
}
