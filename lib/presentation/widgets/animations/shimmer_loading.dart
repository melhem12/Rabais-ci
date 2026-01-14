import 'package:flutter/material.dart';
import 'dart:ui' as ui;

/// Shimmer loading effect for better loading states
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
    this.period = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.period,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return ui.Gradient.linear(
              Offset(-bounds.width * 2 + bounds.width * 2 * _controller.value, 0),
              Offset(bounds.width * 2 * _controller.value, bounds.height),
              [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              [0.0, 0.5, 1.0],
            );
          },
          child: widget.child,
        );
      },
    );
  }
}



