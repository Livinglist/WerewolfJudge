import 'package:flutter/material.dart';

class TapDownWrapper extends StatefulWidget {
  final VoidCallback onTap;
  final Widget child;

  TapDownWrapper({@required this.onTap, @required this.child});

  @override
  _TapDownWrapperState createState() => _TapDownWrapperState();
}

class _TapDownWrapperState extends State<TapDownWrapper> with SingleTickerProviderStateMixin{
  AnimationController controller;
  Tween<double> tween = Tween(begin: 1, end: 0.95);
  double scale = 1;

  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTapCancel: onTapCancel,
      child: AnimatedBuilder(
        animation: CurvedAnimation(parent: controller, curve: Curves.decelerate),
        child: widget.child,
        builder: (context, child) {
          return Transform.scale(scale: tween.evaluate(controller), child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onTapDown(TapDownDetails details) {
    controller.forward();
  }

  void onTapUp(TapUpDetails details) {
    controller.reverse();
  }

  void onTapCancel() {
    controller.reverse();
  }

  void onTap() {
    widget.onTap();
  }
}

