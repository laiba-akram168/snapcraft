import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _glowCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _taglineOpacity;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _particleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.4)),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _textSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textCtrl, curve: const Interval(0.4, 1.0)),
    );
    _glowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Give native splash time to display (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    // Remove native splash before showing Flutter animations
    FlutterNativeSplash.remove();

    await Future.delayed(const Duration(milliseconds: 300));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!mounted) return;

    // Fade out then navigate
    await _logoCtrl.reverse();

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      onboardingDone ? '/home' : '/onboarding',
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _particleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Animated background blobs
          _buildBackgroundBlobs(size),

          // Particle dots
          CustomPaint(
            size: size,
            painter: _ParticlePainter(animation: _particleCtrl),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo container with glow
                AnimatedBuilder(
                  animation: Listenable.merge([_logoCtrl, _glowCtrl]),
                  builder: (_, __) => Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value.clamp(0.0, 1.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent
                                      .withOpacity(0.15 * _glowAnim.value),
                                  blurRadius: 60,
                                  spreadRadius: 20,
                                ),
                                BoxShadow(
                                  color: AppTheme.accentPurple
                                      .withOpacity(0.1 * _glowAnim.value),
                                  blurRadius: 80,
                                  spreadRadius: 30,
                                ),
                              ],
                            ),
                          ),
                          // Logo card
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppTheme.accent,
                                  AppTheme.accentPurple
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accent.withOpacity(0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.photo_camera_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App name + tagline
                AnimatedBuilder(
                  animation: _textCtrl,
                  builder: (_, __) => FadeTransition(
                    opacity: _textOpacity,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [AppTheme.accent, AppTheme.accentPurple],
                            ).createShader(Rect.fromLTWH(
                                0, 0, bounds.width, bounds.height)),
                            child: Text(
                              'SnapCraft',
                              style: GoogleFonts.syne(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          FadeTransition(
                            opacity: _taglineOpacity,
                            child: Text(
                              'Make every shot extraordinary',
                              style: GoogleFonts.dmSans(
                                fontSize: 15,
                                color: AppTheme.text2,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom loader
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _textCtrl,
              builder: (_, __) => FadeTransition(
                opacity: _textOpacity,
                child: Column(
                  children: [
                    _AnimatedLoader(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading your creative space...',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppTheme.text3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundBlobs(Size size) {
    return Stack(
      children: [
        // Top-left blob
        Positioned(
          top: -80,
          left: -80,
          child: AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentPurple.withOpacity(0.08 * _glowAnim.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        // Bottom-right blob
        Positioned(
          bottom: -100,
          right: -60,
          child: AnimatedBuilder(
            animation: _glowCtrl,
            builder: (_, __) => Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withOpacity(0.07 * _glowAnim.value),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Animated Loader ───────────────────────────────────────────────
class _AnimatedLoader extends StatefulWidget {
  @override
  State<_AnimatedLoader> createState() => _AnimatedLoaderState();
}

class _AnimatedLoaderState extends State<_AnimatedLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 3,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return CustomPaint(painter: _LoaderPainter(_ctrl.value));
        },
      ),
    );
  }
}

class _LoaderPainter extends CustomPainter {
  final double progress;
  _LoaderPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = AppTheme.card
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2),
        Offset(size.width, size.height / 2), bgPaint);

    final trackStart = (progress - 0.4).clamp(0.0, 1.0) * size.width;
    final trackEnd = progress * size.width;

    if (trackEnd > trackStart) {
      final fgPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppTheme.accent, AppTheme.accentPurple],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(trackStart, size.height / 2),
        Offset(trackEnd, size.height / 2),
        fgPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _LoaderPainter old) => old.progress != progress;
}

// ── Particle Painter ──────────────────────────────────────────────
class _ParticlePainter extends CustomPainter {
  final Animation<double> animation;

  _ParticlePainter({required this.animation}) : super(repaint: animation);

  final List<_Particle> _particles = List.generate(
    18,
    (i) => _Particle(
      x: (i * 37 % 100) / 100,
      y: (i * 53 % 100) / 100,
      size: 1.5 + (i % 3),
      speed: 0.002 + (i % 5) * 0.001,
      opacity: 0.1 + (i % 4) * 0.05,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in _particles) {
      final dy = (animation.value * p.speed * 200) % 1.0;
      final y = (p.y - dy) % 1.0;

      final paint = Paint()
        ..color = (p.x > 0.5 ? AppTheme.accentPurple : AppTheme.accent)
            .withOpacity(p.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(p.x * size.width, y * size.height),
        p.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  final double x, y, size, speed, opacity;
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}
