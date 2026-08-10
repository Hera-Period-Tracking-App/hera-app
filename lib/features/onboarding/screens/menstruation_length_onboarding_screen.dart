import 'package:flutter/material.dart';
import 'package:hera_app/features/onboarding/widgets/cycle_length_cards.dart';

class MenstruationLengthOnboardingScreen extends StatefulWidget {
  const MenstruationLengthOnboardingScreen({
    super.key,
    required this.menstruationLength,
    required this.onChanged,
  });

  final double menstruationLength;
  final ValueChanged<double> onChanged;

  @override
  State<MenstruationLengthOnboardingScreen> createState() =>
      _MenstruationLengthOnboardingScreenState();
}

class _MenstruationLengthOnboardingScreenState
    extends State<MenstruationLengthOnboardingScreen> {
  final _manualCardKey = GlobalKey();
  final _notSureCardKey = GlobalKey();
  bool _isManualSelection = true;
  bool _isNotSureSelection = false;
  bool _showNotSureDetails = false;

  void _selectManual() {
    setState(() {
      _isManualSelection = true;
      _isNotSureSelection = false;
      _showNotSureDetails = false;
    });
  }

  void _updateLength(double value) {
    _selectManual();
    widget.onChanged(value);
  }

  void _selectManualAndScroll() {
    _selectManual();
    _scrollTo(_manualCardKey, alignment: 0.1);
  }

  void _scrollTo(GlobalKey key, {required double alignment}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cardContext = key.currentContext;
      if (cardContext != null) {
        Scrollable.ensureVisible(
          cardContext,
          duration: const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          alignment: alignment,
        );
      }
    });
  }

  void _toggleNotSure() {
    final willShowDetails = !_showNotSureDetails;
    setState(() {
      _isManualSelection = false;
      _isNotSureSelection = true;
      _showNotSureDetails = willShowDetails;
    });

    if (willShowDetails) {
      widget.onChanged(5);
      _scrollTo(_notSureCardKey, alignment: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const selectionAccent = Color(0xFFFFC857);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        AnimatedScale(
          key: _manualCardKey,
          scale: _isManualSelection ? 1 : 0.985,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: _isManualSelection
                    ? selectionAccent
                    : selectionAccent.withValues(alpha: 0.14),
                width: _isManualSelection ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _selectManualAndScroll,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.menstruationLength.round().toString(),
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
                        'How long on average do your menstruations last?',
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
                          min: 1,
                          max: 10,
                          divisions: 9,
                          value: widget.menstruationLength,
                          label: widget.menstruationLength.round().toString(),
                          onChanged: _updateLength,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Shorter', style: theme.textTheme.bodyMedium),
                          Text('Longer', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        CycleLengthNotSureCard(
          key: _notSureCardKey,
          isSelected: _isNotSureSelection,
          isExpanded: _showNotSureDetails,
          onTap: _toggleNotSure,
          detailsText:
              "I have no idea. It's different each time, it's inconsistent, and I can't confidently tell.",
          supportingText:
              "We'll set it at 5 days to start. You can always edit your menstruation length later.",
        ),
      ],
    );
  }
}
