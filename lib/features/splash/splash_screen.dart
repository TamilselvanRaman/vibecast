import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _zoomCtrl;
  late final AnimationController _waveCtrl;

  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    // Zooming headphone animation
    _zoomCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    
    _scale = Tween<double>(begin: 0.9, end: 1.1).animate(
        CurvedAnimation(parent: _zoomCtrl, curve: Curves.easeInOut));

    // Fast moving sound wave animation inside the logo
    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600))
      ..repeat(); // Loop infinitely

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) context.go('/home');
    });
  }

  @override
  void dispose() {
    _zoomCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Match user's white background picture
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Zooming Custom Logo ──
            ScaleTransition(
              scale: _scale,
              child: AnimatedBuilder(
                animation: _waveCtrl,
                builder: (context, child) {
                  return CustomLogoWidget(waveProgress: _waveCtrl.value);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Custom Headphone + Soundwave Logo
// ──────────────────────────────────────────────
class CustomLogoWidget extends StatelessWidget {
  final double waveProgress;
  const CustomLogoWidget({super.key, required this.waveProgress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115), // Deep dark background from sketch
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The Headphone Outline
          CustomPaint(
            size: const Size(100, 100),
            painter: HeadphonePainter(),
          ),
          // The moving Sound Waves in the center
          Padding(
            padding: const EdgeInsets.only(top: 10), // Push slightly down to center in the cups
            child: _InnerSoundWaves(progress: waveProgress),
          ),
        ],
      ),
    );
  }
}

class HeadphonePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;

    // Center point
    final cx = width / 2;
    // Y offset to push the band up a bit
    final cy = height / 2.2; 
    
    final radius = width / 2.2;

    // Draw the top arc (the headband)
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    canvas.drawArc(rect, pi, pi, false, paint);

    // Draw ear cups
    final cupWidth = 12.0;
    final cupHeight = 30.0;
    
    // Left Cup
    final leftCupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx - radius, cy + cupHeight / 2),
        width: cupWidth,
        height: cupHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftCupRect, paint);

    // Right Cup
    final rightCupRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx + radius, cy + cupHeight / 2),
        width: cupWidth,
        height: cupHeight,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(rightCupRect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InnerSoundWaves extends StatelessWidget {
  final double progress;
  const _InnerSoundWaves({required this.progress});

  @override
  Widget build(BuildContext context) {
    const barCount = 5;
    const maxHeights = [12.0, 24.0, 36.0, 24.0, 12.0];
    const minHeight = 4.0;
    const barWidth = 4.0;
    const spacing = 4.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(barCount, (i) {
        final phaseOffset = (i * 0.5); 
        final color = const Color(0xFF1DB954); // Neon Green

        // Sinusoidal movement
        final sineValue = (sin((progress * 2 * pi) + phaseOffset) + 1) / 2;
        final currentMax = maxHeights[i];
        final currentHeight = minHeight + ((currentMax - minHeight) * sineValue);

        return Container(
          width: barWidth,
          height: currentHeight,
          margin: const EdgeInsets.symmetric(horizontal: spacing / 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(barWidth / 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.6),
                blurRadius: 8,
                spreadRadius: 1,
              )
            ],
          ),
        );
      }),
    );
  }
}
