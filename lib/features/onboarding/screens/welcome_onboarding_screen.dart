import 'package:flutter/material.dart';

class WelcomeOnboardingScreen extends StatefulWidget {
  const WelcomeOnboardingScreen({super.key, this.onTypingCompleted});

  final VoidCallback? onTypingCompleted;

  @override
  State<WelcomeOnboardingScreen> createState() =>
      _WelcomeOnboardingScreenState();
}

class _WelcomeOnboardingScreenState extends State<WelcomeOnboardingScreen>
    with SingleTickerProviderStateMixin {
  static const _welcomeText = '> welcome to';
  static const _heraText = 'HERA';
  static const _subtitleText =
      '> your secure period tracking app\n> no subscriptions\n> no ads and tracking\n> yours and yours only';
  static const _underlinedOwnershipText = 'yours only';
  late final AnimationController _typingController;

  @override
  void initState() {
    super.initState();
    _typingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onTypingCompleted?.call();
        }
      })
      ..forward();
  }

  @override
  void dispose() {
    _typingController.dispose();
    super.dispose();
  }

  Widget _animateIllustration({
    required Widget child,
    required double start,
    required double end,
    required Offset beginOffset,
  }) {
    return AnimatedBuilder(
      animation: _typingController,
      child: child,
      builder: (context, child) {
        final progress = Curves.easeOutCubic.transform(
          Interval(start, end).transform(_typingController.value),
        );
        return Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: beginOffset * (1 - progress),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildAnimatedSubtitle() {
    return AnimatedBuilder(
      animation: _typingController,
      builder: (context, child) {
        final subtitleProgress =
            ((_typingController.value - 0.65) / 0.35).clamp(0.0, 1.0);
        final subtitleCharacters =
            (subtitleProgress * _subtitleText.length).floor();
        final typedSubtitle = _subtitleText.substring(0, subtitleCharacters);
        final ownershipStart = _subtitleText.lastIndexOf(_underlinedOwnershipText);
        final regularText = typedSubtitle.substring(
          0,
          typedSubtitle.length.clamp(0, ownershipStart).toInt(),
        );
        final ownershipText = typedSubtitle.length > ownershipStart
            ? typedSubtitle.substring(ownershipStart)
            : '';
        const secureText = 'secure';
        final secureStart = regularText.indexOf(secureText);
        final secureEnd = secureStart == -1
            ? regularText.length
            : (secureStart + secureText.length)
                .clamp(0, regularText.length)
                .toInt();

        return Text.rich(
          TextSpan(
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontFamily: 'monospace',
              fontSize: 16,
              height: 1.75,
            ),
            children: [
              TextSpan(
                text: regularText.substring(
                  0,
                  secureStart == -1 ? regularText.length : secureStart,
                ),
              ),
              if (secureStart != -1)
                TextSpan(
                  text: regularText.substring(secureStart, secureEnd),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    decoration: TextDecoration.underline,
                  ),
                ),
              if (secureStart != -1)
                TextSpan(text: regularText.substring(secureEnd)),
              TextSpan(
                text: ownershipText,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 24),
        SizedBox(
          height: 650,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: AnimatedBuilder(
                  animation: _typingController,
                  builder: (context, child) {
            const headingCharacters = _welcomeText.length + _heraText.length;
            final headingProgress =
                ((_typingController.value - 0.42) / 0.23).clamp(0.0, 1.0);
            final visibleCharacters =
                (headingProgress * headingCharacters).floor();
            final welcomeCharacters = visibleCharacters.clamp(
              0,
              _welcomeText.length,
            ).toInt();
            final heraCharacters = (visibleCharacters - _welcomeText.length)
                .clamp(0, _heraText.length)
                .toInt();
            final typedWelcome = _welcomeText.substring(0, welcomeCharacters);
            final typedHera = _heraText.substring(0, heraCharacters);

                    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  typedWelcome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        typedHera,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 88,
                          height: 0.9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
                    );
                  },
                ),
              ),
              Positioned(
                top: 52,
                left: 0,
                right: 0,
                child: Center(
                  child: _animateIllustration(
                    start: 0.05,
                    end: 0.28,
                    beginOffset: const Offset(0, 26),
                    child: Transform.translate(
                      offset: const Offset(38, 0),
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..scale(-1.0, 1.0),
                        child: Image.asset(
                          'assets/images/homepage/hera.png',
                          height: 355,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 140,
                left: -96,
                child: _animateIllustration(
                  start: 0.10,
                  end: 0.34,
                  beginOffset: const Offset(-28, 18),
                  child: Image.asset(
                    'assets/images/homepage/athena.png',
                    height: 350,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 250,
                right: -170,
                child: _animateIllustration(
                  start: 0.16,
                  end: 0.40,
                  beginOffset: const Offset(30, 22),
                  child: Image.asset(
                    'assets/images/homepage/persephone.png',
                    height: 440,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 128,
                top: 520,
                child: _buildAnimatedSubtitle(),
              ),
            ],
          ),
        ),
        const SizedBox.shrink(),
        Offstage(
          offstage: true,
          child: AnimatedBuilder(
          animation: _typingController,
          builder: (context, child) {
            final subtitleProgress =
                ((_typingController.value - 0.65) / 0.35).clamp(0.0, 1.0);
            final subtitleCharacters =
                (subtitleProgress * _subtitleText.length).floor();

            final typedSubtitle =
                _subtitleText.substring(0, subtitleCharacters);
            final ownershipStart =
                _subtitleText.lastIndexOf(_underlinedOwnershipText);
            final regularText = typedSubtitle.substring(
              0,
              typedSubtitle.length.clamp(0, ownershipStart).toInt(),
            );
            final ownershipText = typedSubtitle.length > ownershipStart
                ? typedSubtitle.substring(ownershipStart)
                : '';
            const secureText = 'secure';
            final secureStart = regularText.indexOf(secureText);
            final secureEnd = secureStart == -1
                ? regularText.length
                : (secureStart + secureText.length)
                    .clamp(0, regularText.length)
                    .toInt();

                  return Text.rich(
              TextSpan(
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontFamily: 'monospace',
                  fontSize: 16,
                  height: 1.75,
                ),
                children: [
                  TextSpan(
                    text: regularText.substring(
                      0,
                      secureStart == -1 ? regularText.length : secureStart,
                    ),
                  ),
                  if (secureStart != -1)
                    TextSpan(
                      text: regularText.substring(secureStart, secureEnd),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  if (secureStart != -1)
                    TextSpan(text: regularText.substring(secureEnd)),
                  TextSpan(
                    text: ownershipText,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
                  );
          },
          ),
        ),
      ],
    );
  }
}
