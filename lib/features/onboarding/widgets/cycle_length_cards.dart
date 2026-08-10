import 'package:flutter/material.dart';

const _selectionAccent = Color(0xFFFFC857);

class CycleLengthValueCard extends StatelessWidget {
  const CycleLengthValueCard({
    super.key,
    required this.cycleLength,
    required this.isSelected,
    required this.isOutsideTypicalRange,
    required this.onTap,
    required this.onChanged,
  });

  final double cycleLength;
  final bool isSelected;
  final bool isOutsideTypicalRange;
  final VoidCallback onTap;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: isSelected ? 1 : 0.985,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: isSelected
                ? _selectionAccent
                : _selectionAccent.withValues(alpha: 0.14),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        cycleLength.round().toString(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 42,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text('days', style: theme.textTheme.titleLarge),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose your average cycle length. You can fine-tune this later.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 14,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 24,
                      ),
                    ),
                    child: Slider(
                      min: 15,
                      max: 45,
                      divisions: 30,
                      value: cycleLength,
                      label: cycleLength.round().toString(),
                      onChanged: onChanged,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Shorter', style: theme.textTheme.bodyMedium),
                      Text('Longer', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                  const SizedBox(height: 20),
                  TypingStatusText(
                    text: isOutsideTypicalRange
                        ? 'This is not considered within the typical 21–35 day range.'
                        : 'This is within the typical 21–35 day range.',
                    style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CycleLengthNotSureCard extends StatelessWidget {
  const CycleLengthNotSureCard({
    super.key,
    required this.isSelected,
    required this.isExpanded,
    required this.onTap,
    this.detailsText =
        "I have no idea. It's different each time, it's inconsistent, and I can't confidently tell.",
    this.supportingText =
        "We'll set it at 28 days to start, and the app will dynamically predict your cycle. You can always edit the cycle length later.",
  });

  final bool isSelected;
  final bool isExpanded;
  final VoidCallback onTap;
  final String detailsText;
  final String supportingText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedScale(
      scale: isSelected ? 1 : 0.985,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(
            color: isSelected
                ? _selectionAccent
                : _selectionAccent.withValues(alpha: 0.14),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(36),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 18, 24, isExpanded ? 0 : 18),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Not sure?',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 21,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          AnimatedRotation(
                            turns: isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                      if (isExpanded) ...[
                        const SizedBox(height: 14),
                        Padding(
                          padding: const EdgeInsets.only(right: 135),
                          child: Text(
                            detailsText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.only(right: 135),
                          child: Text(
                            supportingText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.68,
                              ),
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ],
                  ),
                  if (isExpanded)
                    Positioned(
                      right: -150,
                      bottom: -230,
                      child: IgnorePointer(
                        child: Image.asset(
                          'assets/images/homepage/thinking-persephone.png',
                          height: 400,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TypingStatusText extends StatefulWidget {
  const TypingStatusText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle? style;

  @override
  State<TypingStatusText> createState() => _TypingStatusTextState();
}

class _TypingStatusTextState extends State<TypingStatusText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  Duration _typingDuration(String text) =>
      Duration(milliseconds: text.length * 22);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _typingDuration(widget.text),
    )
      ..addListener(() => setState(() {}))
      ..forward();
  }

  @override
  void didUpdateWidget(covariant TypingStatusText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text) {
      _controller.duration = _typingDuration(widget.text);
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleCharacters = (widget.text.length * _controller.value).round();
    final isTyping = visibleCharacters < widget.text.length;

    return Text(
      '${widget.text.substring(0, visibleCharacters)}${isTyping ? '|' : ''}',
      style: widget.style,
    );
  }
}
