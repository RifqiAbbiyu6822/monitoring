// lib/utils/animations.dart - Modern Animation System
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AppAnimations {
  // Durations - Modern, fast and responsive
  static const Duration ultraFast = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration normal = Duration(milliseconds: 350);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 750);

  // Curves - Modern, natural feeling
  static const Curve easeOutQuart = Cubic(0.25, 1, 0.5, 1);
  static const Curve easeInOutQuart = Cubic(0.76, 0, 0.24, 1);
  static const Curve easeOutBack = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve easeInOutCirc = Cubic(0.85, 0, 0.15, 1);
  static const Curve smoothStep = Cubic(0.4, 0, 0.2, 1);

  // Page transitions
  static Widget slideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.right,
  }) {
    Offset beginOffset;
    switch (direction) {
      case SlideDirection.up:
        beginOffset = const Offset(0, 1);
        break;
      case SlideDirection.down:
        beginOffset = const Offset(0, -1);
        break;
      case SlideDirection.left:
        beginOffset = const Offset(1, 0);
        break;
      case SlideDirection.right:
        beginOffset = const Offset(-1, 0);
        break;
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: easeOutQuart,
      )),
      child: child,
    );
  }

  static Widget scaleTransition({
    required Widget child,
    required Animation<double> animation,
    double beginScale = 0.8,
  }) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: beginScale,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: easeOutBack,
      )),
      child: child,
    );
  }

  static Widget fadeSlideTransition({
    required Widget child,
    required Animation<double> animation,
    SlideDirection direction = SlideDirection.up,
  }) {
    return FadeTransition(
      opacity: animation,
      child: slideTransition(
        child: child,
        animation: animation,
        direction: direction,
      ),
    );
  }

  // Modern page route
  static PageRouteBuilder<T> modernPageRoute<T>({
    required Widget child,
    TransitionType type = TransitionType.fadeSlide,
    Duration duration = fast,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, _) => child,
      transitionDuration: duration,
      reverseTransitionDuration: Duration(milliseconds: (duration.inMilliseconds * 0.75).round()),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (type) {
          case TransitionType.fade:
            return FadeTransition(opacity: animation, child: child);
          case TransitionType.scale:
            return scaleTransition(child: child, animation: animation);
          case TransitionType.slide:
            return slideTransition(child: child, animation: animation);
          case TransitionType.fadeSlide:
            return fadeSlideTransition(child: child, animation: animation);
        }
      },
    );
  }
}

enum SlideDirection { up, down, left, right }
enum TransitionType { fade, scale, slide, fadeSlide }

// Staggered animation helper
class StaggeredAnimations extends StatefulWidget {
  final List<Widget> children;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Axis direction;

  const StaggeredAnimations({
    super.key,
    required this.children,
    this.delay = const Duration(milliseconds: 100),
    this.duration = AppAnimations.fast,
    this.curve = AppAnimations.easeOutQuart,
    this.direction = Axis.vertical,
  });

  @override
  State<StaggeredAnimations> createState() => _StaggeredAnimationsState();
}

class _StaggeredAnimationsState extends State<StaggeredAnimations>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(
        duration: widget.duration,
        vsync: this,
      ),
    );

    _animations = _controllers.map((controller) {
      return CurvedAnimation(parent: controller, curve: widget.curve);
    }).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      if (mounted) {
        _controllers[i].forward();
        await Future.delayed(widget.delay);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.direction == Axis.vertical
        ? Column(
            children: widget.children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, 30 * (1 - _animations[index].value)),
                    child: Opacity(
                      opacity: _animations[index].value,
                      child: child,
                    ),
                  );
                },
              );
            }).toList(),
          )
        : Row(
            children: widget.children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;
              return AnimatedBuilder(
                animation: _animations[index],
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(30 * (1 - _animations[index].value), 0),
                    child: Opacity(
                      opacity: _animations[index].value,
                      child: child,
                    ),
                  );
                },
              );
            }).toList(),
          );
  }
}

// Animated counter
class AnimatedCounter extends StatefulWidget {
  final int value;
  final Duration duration;
  final TextStyle? style;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = AppAnimations.slow,
    this.style,
  });

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousValue = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOutQuart,
    );
    _animateToValue();
  }

  @override
  void didUpdateWidget(AnimatedCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
      _animateToValue();
    }
  }

  void _animateToValue() {
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = (_previousValue + 
            (_animation.value * (widget.value - _previousValue))).round();
        return Text(
          currentValue.toString(),
          style: widget.style,
        );
      },
    );
  }
}

// Modern loading spinner
class ModernSpinner extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;

  const ModernSpinner({
    super.key,
    this.size = 24,
    this.color = const Color(0xFF0066FF),
    this.strokeWidth = 2.5,
  });

  @override
  State<ModernSpinner> createState() => _ModernSpinnerState();
}

class _ModernSpinnerState extends State<ModernSpinner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _SpinnerPainter(
              color: widget.color,
              strokeWidth: widget.strokeWidth,
              progress: _animation.value,
            ),
          ),
        );
      },
    );
  }
}

class _SpinnerPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double progress;

  _SpinnerPainter({
    required this.color,
    required this.strokeWidth,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw full circle background
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Draw spinning arc
    const sweepAngle = math.pi * 1.5;
    final startAngle = progress * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bounce animation widget
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;

  const BounceAnimation({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.duration = AppAnimations.ultraFast,
  });

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value,
            child: widget.child,
          );
        },
      ),
    );
  }
}

// Shimmer loading effect
class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = _controller;
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: const Alignment(-1.0, 0.0),
              end: const Alignment(1.0, 0.0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                math.max(0.0, _animation.value - 0.3),
                _animation.value,
                math.min(1.0, _animation.value + 0.3),
              ],
            ).createShader(rect);
          },
          child: widget.child,
        );
      },
    );
  }
}

// Reveal animation
class RevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final RevealDirection direction;

  const RevealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppAnimations.normal,
    this.direction = RevealDirection.bottomToTop,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: AppAnimations.easeOutQuart,
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double offsetX = 0;
        double offsetY = 0;

        switch (widget.direction) {
          case RevealDirection.topToBottom:
            offsetY = -50 * (1 - _animation.value);
            break;
          case RevealDirection.bottomToTop:
            offsetY = 50 * (1 - _animation.value);
            break;
          case RevealDirection.leftToRight:
            offsetX = -50 * (1 - _animation.value);
            break;
          case RevealDirection.rightToLeft:
            offsetX = 50 * (1 - _animation.value);
            break;
        }

        return Transform.translate(
          offset: Offset(offsetX, offsetY),
          child: Opacity(
            opacity: _animation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

enum RevealDirection { topToBottom, bottomToTop, leftToRight, rightToLeft }