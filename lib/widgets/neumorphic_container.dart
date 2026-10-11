import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final double borderRadius;
  final bool isInset;
  final Color color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.borderRadius = 25,
    this.isInset = false,
    this.color = AppColors.background,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: isInset
              ? []
              : [
            const BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-5, -5),
              blurRadius: 10,
            ),
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.6),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
