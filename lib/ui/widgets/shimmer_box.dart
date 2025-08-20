import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../design_system.dart';

class ShimmerBox extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  const ShimmerBox({super.key, required this.height, this.width, this.borderRadius = const BorderRadius.all(Radius.circular(12))});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = AppTokens.outline.withOpacity(0.35);
    final highlight = Colors.white;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final dx = (widget.width ?? MediaQuery.of(context).size.width) * (t * 2 - 0.5);
        return ClipRRect(
          borderRadius: widget.borderRadius,
          child: Stack(
            children: [
              Container(
                height: widget.height,
                width: widget.width,
                color: base,
              ),
              Transform.translate(
                offset: Offset(dx, 0),
                child: Container(
                  height: widget.height,
                  width: math.max(80, (widget.width ?? MediaQuery.of(context).size.width) * 0.3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        base.withOpacity(0.0),
                        highlight.withOpacity(0.7),
                        base.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
