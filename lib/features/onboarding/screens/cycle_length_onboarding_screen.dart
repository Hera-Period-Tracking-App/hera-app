import 'package:flutter/material.dart';
import 'package:hera_app/features/onboarding/widgets/cycle_length_cards.dart';

class CycleLengthOnboardingScreen extends StatefulWidget {
  const CycleLengthOnboardingScreen({
    super.key,
    required this.cycleLength,
    required this.onChanged,
  });

  final double cycleLength;
  final ValueChanged<double> onChanged;

  @override
  State<CycleLengthOnboardingScreen> createState() =>
      _CycleLengthOnboardingScreenState();
}

class _CycleLengthOnboardingScreenState
    extends State<CycleLengthOnboardingScreen> {
  final _manualCardKey = GlobalKey();
  final _notSureCardKey = GlobalKey();
  bool _isManualSelection = true;
  bool _isNotSureSelection = false;
  bool _showNotSureDetails = false;

  bool get _isOutsideTypicalRange =>
      widget.cycleLength < 21 || widget.cycleLength > 35;

  void _selectManual() {
    setState(() {
      _isManualSelection = true;
      _isNotSureSelection = false;
      _showNotSureDetails = false;
    });
  }

  void _updateCycleLength(double value) {
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
      widget.onChanged(28);
      _scrollTo(_notSureCardKey, alignment: 0.2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        CycleLengthValueCard(
          key: _manualCardKey,
          cycleLength: widget.cycleLength,
          isSelected: _isManualSelection,
          isOutsideTypicalRange: _isOutsideTypicalRange,
          onTap: _selectManualAndScroll,
          onChanged: _updateCycleLength,
        ),
        const SizedBox(height: 14),
        CycleLengthNotSureCard(
          key: _notSureCardKey,
          isSelected: _isNotSureSelection,
          isExpanded: _showNotSureDetails,
          onTap: _toggleNotSure,
        ),
      ],
    );
  }
}
