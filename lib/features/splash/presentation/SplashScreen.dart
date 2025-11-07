import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_constants.dart';
import '../../../core/theme/color_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        context.go(RouteConstants.dashboard);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? ColorManager.backgroundDark : ColorManager.backgroundLight,
      body: Stack(
        children: [
          Positioned.fill(child: AnimatedStockChart()),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 96.w,
                    height: 96.h,
                    decoration: BoxDecoration(
                      color: ColorManager.primary.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.show_chart,
                      size: 50.sp,
                      color: ColorManager.primary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'MyStocks',
                    style: TextStyle(
                      fontSize: 45.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? ColorManager.textPrimaryDark
                          : ColorManager.textPrimaryLight,
                      letterSpacing: 0.5,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedStockChart extends StatefulWidget {
  const AnimatedStockChart({super.key});

  @override
  State<AnimatedStockChart> createState() => _AnimatedStockChartState();
}

class _AnimatedStockChartState extends State<AnimatedStockChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: false);
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
        return CustomPaint(
          painter: StockChartPainter(animationValue: _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class StockChartPainter extends CustomPainter {
  final double animationValue;

  StockChartPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = ColorManager.primary.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paint2 = Paint()
      ..color = ColorManager.primary.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dx = size.width * 0.02 * (animationValue - 0.5) * 2;
    final dy = -size.height * 0.02 * (animationValue - 0.5) * 2;
    final scale = 1.0 +
        0.05 * (animationValue > 0.5 ? 1 - animationValue : animationValue) * 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    final path1 = Path();
    path1.moveTo(-200, size.height * 0.8125);
    path1.quadraticBezierTo(
      120,
      size.height * 0.625,
      360,
      size.height * 0.6875,
    );
    path1.quadraticBezierTo(
      size.width * 0.5556,
      size.height * 0.5625,
      800,
      size.height * 0.5625,
    );
    path1.quadraticBezierTo(
      size.width * 0.8611,
      size.height * 0.625,
      1240,
      size.height * 0.625,
    );
    path1.quadraticBezierTo(
      size.width * 1.1667,
      size.height * 0.5,
      1680,
      size.height * 0.5,
    );

    canvas.drawPath(path1, paint1);

    final path2 = Path();
    path2.moveTo(-150, size.height * 0.875);
    path2.quadraticBezierTo(170, size.height * 0.6875, 410, size.height * 0.75);
    path2.quadraticBezierTo(
      size.width * 0.5903,
      size.height * 0.625,
      850,
      size.height * 0.625,
    );
    path2.quadraticBezierTo(
      size.width * 0.8958,
      size.height * 0.6875,
      1290,
      size.height * 0.6875,
    );
    path2.quadraticBezierTo(
      size.width * 1.2014,
      size.height * 0.5625,
      1730,
      size.height * 0.5625,
    );

    canvas.drawPath(path2, paint2);

    canvas.restore();
  }

  @override
  bool shouldRepaint(StockChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
