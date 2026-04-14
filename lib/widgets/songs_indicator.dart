import 'package:flutter/material.dart';

/// Animated equalizer bars — 3 bars that bounce independently.
/// Must be used inside a StatefulWidget tree so controllers stay alive.
class SongIndicator extends StatefulWidget {
  final Color color;
  final double size;

  const SongIndicator({
    super.key,
    required this.color,
    this.size = 20,
  });

  @override
  State<SongIndicator> createState() => _SongIndicatorState();
}

class _SongIndicatorState extends State<SongIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _c0;
  late final AnimationController _c1;
  late final AnimationController _c2;
  late final Animation<double> _a0;
  late final Animation<double> _a1;
  late final Animation<double> _a2;

  @override
  void initState() {
    super.initState();

    _c0 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _c1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _c2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _a0 = Tween(begin: 0.2, end: 1.0)
        .animate(CurvedAnimation(parent: _c0, curve: Curves.easeInOut));
    _a1 = Tween(begin: 0.55, end: 1.0)
        .animate(CurvedAnimation(parent: _c1, curve: Curves.easeInOut));
    _a2 = Tween(begin: 0.15, end: 0.85)
        .animate(CurvedAnimation(parent: _c2, curve: Curves.easeInOut));

    // Start at different points so bars are never in sync
    _c0.value = 0.0;
    _c1.value = 0.45;
    _c2.value = 0.75;

    _c0.repeat(reverse: true);
    _c1.repeat(reverse: true);
    _c2.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c0.dispose();
    _c1.dispose();
    _c2.dispose();
    super.dispose();
  }

  Widget _bar(Animation<double> anim, double barW, double maxH) {
    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Container(
        width: barW,
        height: maxH * anim.value,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(barW),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final barW = s * 0.20;
    final gap = s * 0.12;

    return SizedBox(
      width: s,
      height: s,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _bar(_a0, barW, s),
          SizedBox(width: gap),
          _bar(_a1, barW, s),
          SizedBox(width: gap),
          _bar(_a2, barW, s),
        ],
      ),
    );
  }
}