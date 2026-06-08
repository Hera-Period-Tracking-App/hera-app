import 'package:flutter/material.dart';

class PrivacyChoiceCard extends StatelessWidget {
  const PrivacyChoiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.animatedBadge = false,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final bool animatedBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: selected ? 1 : 0.985,
      duration: const Duration(milliseconds: 220),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? accent : accent.withValues(alpha: 0.14),
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.16),
                        blurRadius: 26,
                        offset: const Offset(0, 14),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: selected ? 0.18 : 0.10),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(icon, color: accent, size: 28),
                      if (animatedBadge)
                        const Positioned(
                          right: 12,
                          top: 12,
                          child: _PulseDot(),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(description, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: selected ? accent : theme.colorScheme.outline,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.82, end: 1.18).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
