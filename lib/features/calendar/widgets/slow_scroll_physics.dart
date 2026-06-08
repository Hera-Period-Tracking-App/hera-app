import 'package:flutter/material.dart';

class SlowScrollPhysics extends ClampingScrollPhysics {
  const SlowScrollPhysics({super.parent});

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Reduce movement per gesture so month scrolling feels less jumpy.
    return super.applyPhysicsToUserOffset(position, offset * 0.45);
  }
}
