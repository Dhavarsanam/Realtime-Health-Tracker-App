import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItem(this.icon, this.activeIcon, this.label);
}

/// Floating frosted-glass bottom bar with a sliding gradient indicator.
class FloatingNav extends StatelessWidget {
  final List<NavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  final Gradient gradient;
  const FloatingNav({super.key, required this.items, required this.index, required this.onChanged, this.gradient = AppColors.brand});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom + 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 12))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              height: 74,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: AppColors.bgElevated.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: LayoutBuilder(builder: (context, c) {
                final w = c.maxWidth / items.length;
                return Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutBack,
                      left: w * index + (w - 56) / 2,
                      top: 9,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: gradient.colors.first.withValues(alpha: 0.55), blurRadius: 20, offset: const Offset(0, 6))],
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(items.length, (i) {
                        final active = i == index;
                        return Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onChanged(i);
                            },
                            child: AnimatedScale(
                              scale: active ? 1.08 : 1,
                              duration: const Duration(milliseconds: 300),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(active ? items[i].activeIcon : items[i].icon, color: active ? Colors.white : AppColors.textMuted, size: 24),
                                  AnimatedSize(
                                    duration: const Duration(milliseconds: 250),
                                    child: active
                                        ? const SizedBox.shrink()
                                        : Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(items[i].label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
