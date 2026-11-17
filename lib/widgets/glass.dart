import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

/// Frosted glass card with a luminous gradient hairline border.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Gradient? tint;
  final double blur;
  final VoidCallback? onTap;
  final Color? glow;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 26,
    this.tint,
    this.blur = 18,
    this.onTap,
    this.glow,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: tint ??
            LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withValues(alpha: 0.09), Colors.white.withValues(alpha: 0.025)],
            ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = Pressable(onTap: onTap!, child: content);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        boxShadow: [
          if (glow != null) BoxShadow(color: glow!.withValues(alpha: 0.28), blurRadius: 40, spreadRadius: -8, offset: const Offset(0, 16)),
          BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 30, offset: const Offset(0, 14)),
        ],
      ),
      child: CustomPaint(
        foregroundPainter: _HairlinePainter(radius),
        child: ClipRRect(
          borderRadius: br,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: content,
          ),
        ),
      ),
    );
  }
}

class _HairlinePainter extends CustomPainter {
  final double radius;
  _HairlinePainter(this.radius);
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(0.5);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.04),
          Colors.white.withValues(alpha: 0.14),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, p);
  }

  @override
  bool shouldRepaint(covariant _HairlinePainter old) => old.radius != radius;
}

/// Spring-like press scale feedback with haptics.
class Pressable extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double scale;
  const Pressable({super.key, required this.child, required this.onTap, this.scale = 0.96});

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}

/// Interactive 3D tilt: follows the finger / mouse with perspective rotation
/// and a moving specular highlight. Gently floats when idle.
class Tilt3D extends StatefulWidget {
  final Widget child;
  final double maxAngle;
  final bool idleFloat;
  final double radius;
  const Tilt3D({super.key, required this.child, this.maxAngle = 0.22, this.idleFloat = true, this.radius = 28});

  @override
  State<Tilt3D> createState() => _Tilt3DState();
}

class _Tilt3DState extends State<Tilt3D> with TickerProviderStateMixin {
  Offset _tilt = Offset.zero;
  late final AnimationController _idle = AnimationController(vsync: this, duration: const Duration(seconds: 6))..repeat();
  late final AnimationController _reset = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  Offset _resetFrom = Offset.zero;
  bool _active = false;

  @override
  void initState() {
    super.initState();
    _reset.addListener(() {
      final t = Curves.elasticOut.transform(_reset.value);
      setState(() => _tilt = Offset.lerp(_resetFrom, Offset.zero, t)!);
    });
  }

  @override
  void dispose() {
    _idle.dispose();
    _reset.dispose();
    super.dispose();
  }

  void _update(Offset local, Size size) {
    _active = true;
    _reset.stop();
    final dx = (local.dx / size.width - 0.5) * 2;
    final dy = (local.dy / size.height - 0.5) * 2;
    setState(() => _tilt = Offset(dx.clamp(-1, 1), dy.clamp(-1, 1)));
  }

  void _release() {
    _active = false;
    _resetFrom = _tilt;
    _reset.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final size = Size(c.maxWidth, c.maxHeight.isFinite ? c.maxHeight : 200);
      return MouseRegion(
        onHover: (e) => _update(e.localPosition, size),
        onExit: (_) => _release(),
        child: GestureDetector(
          onPanStart: (d) => _update(d.localPosition, size),
          onPanUpdate: (d) => _update(d.localPosition, size),
          onPanEnd: (_) => _release(),
          onPanCancel: _release,
          child: AnimatedBuilder(
            animation: _idle,
            builder: (context, child) {
              final idle = widget.idleFloat && !_active
                  ? Offset(math.sin(_idle.value * 2 * math.pi) * 0.12, math.cos(_idle.value * 2 * math.pi) * 0.08)
                  : Offset.zero;
              final t = _tilt + idle;
              final m = Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateX(-t.dy * widget.maxAngle)
                ..rotateY(t.dx * widget.maxAngle);
              return Transform(
                alignment: Alignment.center,
                transform: m,
                child: Stack(
                  children: [
                    child!,
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(widget.radius),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                center: Alignment(t.dx * 0.9, t.dy * 0.9),
                                radius: 1.0,
                                colors: [Colors.white.withValues(alpha: 0.16), Colors.transparent],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: widget.child,
          ),
        ),
      );
    });
  }
}

/// Premium gradient CTA with shine sweep and glow.
class GradientButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final Gradient gradient;
  final double height;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.gradient = AppColors.brand,
    this.height = 58,
    this.loading = false,
  });

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with SingleTickerProviderStateMixin {
  late final AnimationController _shine = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600))..repeat();

  @override
  void dispose() {
    _shine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final first = widget.gradient.colors.first;
    return Pressable(
      onTap: widget.loading ? () {} : widget.onTap,
      child: Container(
        height: widget.height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(widget.height / 2),
          boxShadow: [
            BoxShadow(color: first.withValues(alpha: 0.45), blurRadius: 28, offset: const Offset(0, 12), spreadRadius: -6),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.height / 2),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _shine,
                  builder: (context, _) => FractionalTranslation(
                    translation: Offset(-1.2 + _shine.value * 3, 0),
                    child: Transform.rotate(
                      angle: 0.35,
                      child: Container(
                        width: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.white.withValues(alpha: 0),
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0),
                          ]),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: widget.loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.3)),
                          if (widget.icon != null) ...[const SizedBox(width: 10), Icon(widget.icon, color: Colors.white, size: 20)],
                        ],
                      ),
                      ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
