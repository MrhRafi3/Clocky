import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sheenAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );

    // 1. Logo Elastic Pop
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );

    // 2. High-speed Clock Hands Spin to 12 o'clock lock
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.70, curve: Curves.easeInOutCubic),
      ),
    );

    // 3. Ambient Breathing Pulse
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.85, curve: Curves.easeInOutSine),
      ),
    );

    // 4. Metallic Sheen Swipe
    _sheenAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.95, curve: Curves.easeInOut),
      ),
    );

    // 5. Signature Text Reveal
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.85, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Subtle tactile clicks
    Future.delayed(const Duration(milliseconds: 400), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 1800), () {
      HapticFeedback.lightImpact();
    });

    // Seamless fade route into HomeScreen
    Future.delayed(const Duration(milliseconds: 3100), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 700),
            pageBuilder: (_, _, _) => const HomeScreen(),
            transitionsBuilder: (_, animation, _, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(flex: 2),

                // ==========================================
                // ANIMATED CHRONO-LOGO WIDGET
                // ==========================================
                Center(
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Outer Ambient Pulse Aura
                        Container(
                          width: 170 * _pulseAnimation.value,
                          height: 170 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFFC444).withValues(
                              alpha: (0.18 - (_pulseAnimation.value - 1.0) * 0.9)
                                  .clamp(0.0, 0.18),
                            ),
                          ),
                        ),

                        // Neumorphic Dial Shell
                        Container(
                          width: 155,
                          height: 155,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.background,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowDark.withValues(alpha: 0.85),
                                offset: const Offset(10, 10),
                                blurRadius: 22,
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                offset: Offset(-10, -10),
                                blurRadius: 22,
                              ),
                            ],
                          ),
                          child: CustomPaint(
                            size: const Size(155, 155),
                            painter: _AnimatedLogoPainter(
                              spinAngle: _rotationAnimation.value,
                              sheenOffset: _sheenAnimation.value,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // ==========================================
                // BOTTOM SIGNATURE BRANDING
                // ==========================================
                Opacity(
                  opacity: _textFadeAnimation.value,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 35.0),
                    child: Column(
                      children: [
                        Text(
                          "DESIGNED BY",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3.5,
                            color: AppColors.textGrey.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Animated Metallic Gradient Text
                        ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: const [
                                AppColors.primaryDark,
                                Color(0xFFFFC444),
                                AppColors.primaryDark,
                              ],
                              stops: [
                                (_sheenAnimation.value - 0.4).clamp(0.0, 1.0),
                                _sheenAnimation.value.clamp(0.0, 1.0),
                                (_sheenAnimation.value + 0.4).clamp(0.0, 1.0),
                              ],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            "MRH RAFI",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Mini Modern Dot Tracker
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            final delay = index * 0.2;
                            final active =
                                ((_controller.value - delay) % 0.6) > 0.3;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: active ? 18 : 6,
                              height: 5,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),
                                color: active
                                    ? const Color(0xFFFFC444)
                                    : AppColors.shadowDark,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM VECTOR PAINTER FOR LIVE ANIMATED LOGO
// ==========================================
class _AnimatedLogoPainter extends CustomPainter {
  final double spinAngle;
  final double sheenOffset;

  _AnimatedLogoPainter({
    required this.spinAngle,
    required this.sheenOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 1. Double Bezel Rims
    final rimPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFD4D8E4), Color(0xFFADB3C4)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(center, radius - 4, rimPaint);

    // 2. Pearlescent Dial Face
    final dialBg = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.35),
        colors: const [
          Colors.white,
          Color(0xFFF6F8FC),
          Color(0xFFE5E9F2),
        ],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 6, dialBg);

    // 3. Geometric 12-Hour Dot Markers
    final dotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * pi / 180 - pi / 2;
      final isCardinal = (i % 3 == 0); // 12, 3, 6, 9
      dotPaint.color = isCardinal
          ? AppColors.primaryDark
          : AppColors.primaryDark.withValues(alpha: 0.3);

      final dotPos = Offset(
        center.dx + (radius - 18) * cos(angle),
        center.dy + (radius - 18) * sin(angle),
      );
      canvas.drawCircle(dotPos, isCardinal ? 3.0 : 1.5, dotPaint);
    }

    // 4. Fast Animated Hour Hand (Sleek Dark Violet)
    // Runs 1 full spin and locks straight up (-pi / 2)
    final currentHourAngle = (spinAngle * 0.5) - (pi / 2);
    final hourHandLength = radius * 0.44;
    final hourPaint = Paint()
      ..color = AppColors.primaryDark
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center - Offset(8 * cos(currentHourAngle), 8 * sin(currentHourAngle)),
      Offset(
        center.dx + hourHandLength * cos(currentHourAngle),
        center.dy + hourHandLength * sin(currentHourAngle),
      ),
      hourPaint,
    );

    // 5. Fast Animated Minute Hand (Metallic Amber Gold)
    // Runs 2 full spins and locks towards 10 o'clock (-pi * 0.65)
    final currentMinAngle = (spinAngle * 1.5) - (pi * 0.65);
    final minHandLength = radius * 0.62;
    final minPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFD56B), Color(0xFFF39C12)],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeWidth = 3.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center - Offset(10 * cos(currentMinAngle), 10 * sin(currentMinAngle)),
      Offset(
        center.dx + minHandLength * cos(currentMinAngle),
        center.dy + minHandLength * sin(currentMinAngle),
      ),
      minPaint,
    );

    // 6. Center Luxury Gem Pivot
    canvas.drawCircle(center, 7.0, Paint()..color = AppColors.primaryDark);
    canvas.drawCircle(center, 4.5, Paint()..color = const Color(0xFFFFC444));
    canvas.drawCircle(center, 2.2, Paint()..color = const Color(0xFFFF5252));

    // 7. Dynamic Curved Sapphire Glass Glare
    final glarePath = Path();
    glarePath.addArc(
      Rect.fromCircle(center: center, radius: radius - 6),
      -pi * 0.95,
      pi * 0.75,
    );
    glarePath.quadraticBezierTo(
      center.dx,
      center.dy - (radius * 0.2),
      center.dx - (radius - 6) * cos(pi * 0.25),
      center.dy - (radius - 6) * sin(pi * 0.25),
    );
    glarePath.close();

    final glarePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.58),
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawPath(glarePath, glarePaint);
  }

  @override
  bool shouldRepaint(covariant _AnimatedLogoPainter oldDelegate) => true;
}
