import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Main app loader - beautiful custom loader with theme colors
class AppLoader extends StatelessWidget {
  final double size;
  final Color? color;
  final bool useGradient;

  const AppLoader({
    super.key,
    this.size = 40.0,
    this.color,
    this.useGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      return CustomGradientLoader(size: size, color: color);
    } else {
      return CustomLoader(size: size, color: color);
    }
  }
}

/// Beautiful custom loader with gradient and pulse animation
class CustomLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CustomLoader({
    super.key,
    this.size = 50.0,
    this.color,
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

/// Gradient loader with theme colors
class CustomGradientLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const CustomGradientLoader({
    super.key,
    this.size = 40.0,
    this.color,
  });

  @override
  State<CustomGradientLoader> createState() => _CustomGradientLoaderState();
}

class _CustomGradientLoaderState extends State<CustomGradientLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use theme colors for beautiful gradient when no custom color is provided
    // If custom color is provided, use it with a lighter variant for gradient
    final primaryColor = widget.color ?? AppTheme.primaryOrange;
    final secondaryColor = widget.color != null 
        ? widget.color!.withValues(alpha: 0.6)
        : AppTheme.primaryTurquoise;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  primaryColor,
                  secondaryColor,
                  primaryColor,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: widget.size * 0.65,
                height: widget.size * 0.65,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 2 * 3.14159,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    widget.color ?? AppTheme.primaryOrange,
                    (widget.color ?? AppTheme.primaryOrange).withValues(alpha: 0.3),
                    widget.color ?? AppTheme.primaryOrange,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Center(
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Pulsing dots loader
class PulsingDotsLoader extends StatefulWidget {
  final Color? color;
  final double dotSize;

  const PulsingDotsLoader({
    super.key,
    this.color,
    this.dotSize = 12.0,
  });

  @override
  State<PulsingDotsLoader> createState() => _PulsingDotsLoaderState();
}

class _PulsingDotsLoaderState extends State<PulsingDotsLoader>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      )..repeat(reverse: true),
    );

    // Stagger the animations
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) _controllers[i].forward();
      });
    }

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0.4, end: 1.0).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.easeInOut,
              ),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: widget.dotSize * _animations[index].value,
              height: widget.dotSize * _animations[index].value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (widget.color ?? AppTheme.primaryOrange)
                    .withValues(alpha: _animations[index].value),
              ),
            );
          },
        );
      }),
    );
  }
}

