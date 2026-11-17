import 'package:flutter/material.dart';

import '../core/models/models.dart';
import '../core/theme/app_colors.dart';
import 'glass.dart';

/// Fades + slides children in with a staggered delay.
class Entrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Offset offset;
  final Duration baseDelay;
  const Entrance({super.key, required this.child, this.index = 0, this.offset = const Offset(0, 0.12), this.baseDelay = const Duration(milliseconds: 70)});

  @override
  State<Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<Entrance> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.baseDelay * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween(begin: widget.offset, end: Offset.zero).animate(curve),
        child: ScaleTransition(scale: Tween(begin: 0.96, end: 1.0).animate(curve), child: widget.child),
      ),
    );
  }
}

class GradientText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Gradient gradient;
  const GradientText(this.text, {super.key, this.style, this.gradient = AppColors.brand});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (b) => gradient.createShader(Rect.fromLTWH(0, 0, b.width, b.height)),
      child: Text(text, style: style),
    );
  }
}

/// Glossy 3D-ish icon tile with gradient, inner highlight and colored glow.
class IconOrb extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final double size;
  final double iconSize;
  const IconOrb({super.key, required this.icon, required this.gradient, this.size = 46, this.iconSize = 22});

  @override
  Widget build(BuildContext context) {
    final c = gradient.colors.first;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(size * 0.34),
        boxShadow: [BoxShadow(color: c.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 8), spreadRadius: -4)],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size * 0.5,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(size * 0.34)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.35), Colors.white.withValues(alpha: 0)],
                ),
              ),
            ),
          ),
          Center(child: Icon(icon, color: Colors.white, size: iconSize)),
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14, top: 6),
      child: Row(
        children: [
          Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19))),
          if (action != null)
            Pressable(
              onTap: onAction ?? () {},
              child: Row(
                children: [
                  Text(action!, style: const TextStyle(color: AppColors.cyan, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.cyan, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StatusPill extends StatelessWidget {
  final HealthStatus status;
  final bool compact;
  const StatusPill(this.status, {super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: status.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: status.color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: status.color, blurRadius: 6)])),
          const SizedBox(width: 6),
          Text(status.label, style: TextStyle(color: status.color, fontSize: compact ? 10.5 : 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class Avatar extends StatelessWidget {
  final String initials;
  final Color color;
  final double size;
  final bool online;
  final bool ring;
  const Avatar({super.key, required this.initials, required this.color, this.size = 48, this.online = false, this.ring = false});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(ring ? 2.5 : 0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ring ? SweepGradient(colors: [color, AppColors.violet, color]) : null,
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: ring ? Border.all(color: AppColors.bg, width: 2) : null,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.95), Color.lerp(color, Colors.black, 0.45)!],
              ),
            ),
            alignment: Alignment.center,
            child: Text(initials, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: size * 0.34)),
          ),
        ),
        if (online)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.emerald,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.bg, width: 2.5),
              ),
            ),
          ),
      ],
    );
  }
}

/// Number that counts up when first shown.
class CountUp extends StatelessWidget {
  final double value;
  final int decimals;
  final TextStyle? style;
  final String suffix;
  final Duration duration;
  const CountUp(this.value, {super.key, this.decimals = 0, this.style, this.suffix = '', this.duration = const Duration(milliseconds: 1400)});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, v, _) {
        var s = v.toStringAsFixed(decimals);
        if (decimals == 0 && v >= 1000) {
          s = s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},');
        }
        return Text('$s$suffix', style: style);
      },
    );
  }
}

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final int badge;
  const GlassIconButton({super.key, required this.icon, required this.onTap, this.badge = 0});

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.stroke),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
          if (badge > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(gradient: AppColors.heart, shape: BoxShape.circle, border: Border.all(color: AppColors.bg, width: 2)),
                child: Text('$badge', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

/// Transparent app bar for pushed pages.
class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> actions;
  const PageHeader({super.key, required this.title, this.subtitle, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          if (canPop) ...[
            GlassIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.of(context).pop()),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null) Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Fancy route: fade + scale + slight 3D rotate.
Route<T> premiumRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 650),
    reverseTransitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, _, _) => page,
    transitionsBuilder: (_, a, _, child) {
      final c = CurvedAnimation(parent: a, curve: Curves.easeOutQuart, reverseCurve: Curves.easeInCubic);
      return AnimatedBuilder(
        animation: c,
        builder: (context, ch) {
          final m = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY((1 - c.value) * 0.35)
            ..scaleByDouble(0.92 + 0.08 * c.value, 0.92 + 0.08 * c.value, 1, 1);
          return Opacity(
            opacity: c.value.clamp(0, 1),
            child: Transform(alignment: Alignment.centerLeft, transform: m, child: ch),
          );
        },
        child: child,
      );
    },
  );
}
