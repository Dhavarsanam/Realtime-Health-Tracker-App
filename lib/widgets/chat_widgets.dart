import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'glass.dart';

String hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

class ChatBubble extends StatelessWidget {
  final String text;
  final bool mine;
  final DateTime time;
  final Gradient gradient;
  const ChatBubble({super.key, required this.text, required this.mine, required this.time, this.gradient = AppColors.brand});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, v, child) => Transform.scale(
        scale: 0.85 + 0.15 * v,
        alignment: mine ? Alignment.bottomRight : Alignment.bottomLeft,
        child: Opacity(opacity: v.clamp(0, 1), child: child),
      ),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: BoxDecoration(
            gradient: mine ? gradient : null,
            color: mine ? null : Colors.white.withValues(alpha: 0.08),
            border: mine ? null : Border.all(color: AppColors.stroke),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(mine ? 22 : 6),
              bottomRight: Radius.circular(mine ? 6 : 22),
            ),
            boxShadow: mine ? [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))] : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Align(alignment: Alignment.centerLeft, child: Text(text, style: const TextStyle(fontSize: 14, height: 1.45))),
              const SizedBox(height: 4),
              Row(mainAxisSize: MainAxisSize.min, children: [
                Text(hhmm(time), style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
                if (mine) ...[const SizedBox(width: 4), Icon(Icons.done_all_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8))],
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.stroke),
        ),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final y = math.sin((_c.value * 2 * math.pi) - i * 0.8);
              return Transform.translate(
                offset: Offset(0, -y.clamp(0, 1) * 5),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Color.lerp(AppColors.cyan, AppColors.violet, i / 2)!.withValues(alpha: 0.5 + 0.5 * y.clamp(0, 1))),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final String hint;
  final Gradient gradient;
  final IconData leading;
  const ChatComposer({super.key, required this.controller, required this.onSend, this.hint = 'Type a message…', this.gradient = AppColors.brand, this.leading = Icons.add_rounded});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(14, 10, 14, 10 + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: AppColors.bgElevated.withValues(alpha: 0.7),
            border: const Border(top: BorderSide(color: AppColors.stroke)),
          ),
          child: Row(children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(16)),
              child: Icon(leading, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSend(),
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  hintText: hint,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.stroke)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.stroke)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: const BorderSide(color: AppColors.cyan)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Pressable(
              onTap: onSend,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.5), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 21),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
