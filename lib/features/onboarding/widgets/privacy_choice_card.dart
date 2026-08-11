import 'package:flutter/material.dart';

class PrivacyChoiceCard extends StatelessWidget {
  const PrivacyChoiceCard({
    super.key,
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.supportingText,
    required this.selected,
    required this.accent,
    required this.onTap,
    this.titleFontSize,
    this.illustrationAsset,
    this.illustrationAlignment = Alignment.bottomRight,
    this.illustrationHeight = 160,
    this.illustrationOffset = Offset.zero,
    this.contentStartPadding = 0,
    this.contentEndPadding = 0,
  });

  final String title;
  final String eyebrow;
  final String description;
  final String supportingText;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;
  final double? titleFontSize;
  final String? illustrationAsset;
  final Alignment illustrationAlignment;
  final double illustrationHeight;
  final Offset illustrationOffset;
  final double contentStartPadding;
  final double contentEndPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: selected ? 1 : 0.985,
      duration: const Duration(milliseconds: 220),
      child: Material(
        color: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Ink(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: selected
                  ? accent.withValues(alpha: 0.08)
                  : theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: selected ? accent : accent.withValues(alpha: 0.14),
                width: selected ? 2 : 1,
              ),
            ),
            child: Stack(
              children: [
                if (illustrationAsset != null)
                  IgnorePointer(
                    child: Align(
                      alignment: illustrationAlignment,
                      child: Transform.translate(
                        offset: illustrationOffset,
                        child: Image.asset(
                          illustrationAsset!,
                          height: illustrationHeight,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsetsDirectional.only(
                    end: contentEndPadding,
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Text(
                        '> $eyebrow',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleFontSize,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: contentStartPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              supportingText,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withValues(alpha: 0.66),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? accent : theme.colorScheme.outline,
                    size: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
