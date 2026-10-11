import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _slideAnimation;
  int _lastIndex = 0;

  // এখন শুধু ৩টি আইটেম
  final List<NavConfig> _navItems = const [
    NavConfig(
      activeIcon: Icons.access_time_filled_rounded,
      inactiveIcon: Icons.access_time_rounded,
      label: "Clock",
    ),
    NavConfig(
      activeIcon: Icons.alarm_on_rounded,
      inactiveIcon: Icons.alarm_rounded,
      label: "Alarm",
    ),
    NavConfig(
      activeIcon: Icons.timer_rounded,
      inactiveIcon: Icons.timer_outlined,
      label: "Stopwatch",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _lastIndex = widget.currentIndex;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(
        begin: widget.currentIndex.toDouble(),
        end: widget.currentIndex.toDouble())
        .animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void didUpdateWidget(covariant CustomBottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _lastIndex = oldWidget.currentIndex;
      _slideAnimation = Tween<double>(
          begin: _lastIndex.toDouble(),
          end: widget.currentIndex.toDouble())
          .animate(
        CurvedAnimation(
          parent: _animController,
          curve: Curves.easeOutBack,
        ),
      );
      _animController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 20),
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B1424).withValues(alpha: 0.18),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.65),
                  Colors.white.withValues(alpha: 0.25),
                  AppColors.background.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.75),
                width: 1.5,
              ),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // ৩টি সমান স্লট
                final slotWidth = constraints.maxWidth / 3;
                const pillWidth = 54.0;
                const pillHeight = 48.0;

                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    AnimatedBuilder(
                      animation: _slideAnimation,
                      builder: (context, child) {
                        final currentSlot = _slideAnimation.value;
                        final leftPos = (currentSlot * slotWidth) + (slotWidth - pillWidth) / 2;

                        return Positioned(
                          left: leftPos,
                          child: Container(
                            width: pillWidth,
                            height: pillHeight,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(alpha: 0.38),
                                  blurRadius: 14,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFFC444).withValues(alpha: 0.15),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        _buildNavItem(0, slotWidth), // Clock
                        _buildNavItem(1, slotWidth), // Alarm
                        _buildNavItem(2, slotWidth), // Stopwatch
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int itemIndex, double width) {
    final isSelected = widget.currentIndex == itemIndex;
    final item = _navItems[itemIndex];

    return SizedBox(
      width: width,
      height: 76,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap(itemIndex);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1.0, end: isSelected ? 1.18 : 1.0),
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: child,
                    ),
                    child: Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      key: ValueKey<bool>(isSelected),
                      size: 25,
                      color: isSelected
                          ? const Color(0xFFFFC444)
                          : const Color(0xFF352B3E),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class NavConfig {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;

  const NavConfig({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}
