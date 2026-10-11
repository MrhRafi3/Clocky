import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class VerticalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const VerticalSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 58,
        height: 105,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark.withValues(alpha: 0.5),
              offset: const Offset(3, 3),
              blurRadius: 5,
            ),
            const BoxShadow(
              color: AppColors.shadowLight,
              offset: Offset(-3, -3),
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              alignment: value ? Alignment.topCenter : Alignment.bottomCenter,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: value ? AppColors.accentYellow : AppColors.primaryDark,
                  boxShadow: [
                    BoxShadow(
                      color: (value ? AppColors.accentYellow : AppColors.primaryDark).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    value ? "ON" : "OFF",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: value ? AppColors.primaryDark : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
