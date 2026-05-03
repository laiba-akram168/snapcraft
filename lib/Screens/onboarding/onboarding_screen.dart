import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/core/constant.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _currentPage = 0;

  late AnimationController _iconCtrl;
  late AnimationController _bgCtrl;
  late Animation<double> _iconFloat;
  late Animation<Color?> _bgColor;

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      title: 'Edit Like a Pro',
      subtitle:
          'Real-time brightness, contrast & advanced filters at your fingertips. Sepia, Vintage, Chrome — and more.',
      icon: Icons.tune_rounded,
      emoji: '✨',
      gradient: [const Color(0xFF1A0A2E), const Color(0xFF2D1B4E)],
      accentColor: AppTheme.accentPurple,
      features: [
        '8 Premium Filters',
        'Real-time Sliders',
        'Undo / Redo History'
      ],
    ),
    _OnboardPage(
      title: 'AI-Powered Magic',
      subtitle:
          'Our smart AI assistant analyzes your photos and suggests the perfect enhancements — automatically.',
      icon: Icons.auto_awesome_rounded,
      emoji: '🤖',
      gradient: [const Color(0xFF0A1A2E), const Color(0xFF1B2D4E)],
      accentColor: AppTheme.accentBlue,
      features: [
        'Socket.io Real-time',
        'Smart Suggestions',
        'Auto Enhancement'
      ],
    ),
    _OnboardPage(
      title: 'Beautiful Collages',
      subtitle:
          'Combine multiple photos into stunning layouts. Choose from 6 templates and customize every detail.',
      icon: Icons.grid_view_rounded,
      emoji: '🎨',
      gradient: [const Color(0xFF1A0A0A), const Color(0xFF3E1A1A)],
      accentColor: AppTheme.accent,
      features: ['6 Layout Templates', 'Custom Backgrounds', 'One-tap Export'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);
    _bgCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _iconFloat = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _iconCtrl.dispose();
    _bgCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _skip() => _finish();

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Animated gradient background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: page.gradient,
              ),
            ),
          ),

          // Decorative circles
          _buildDecorativeCircles(page, size),

          SafeArea(
            child: Column(
              children: [
                // Skip button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 12, 20, 0),
                    child: GestureDetector(
                      onTap: _skip,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                              width: 0.5),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppTheme.text2),
                        ),
                      ),
                    ),
                  ),
                ),

                // PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _buildPage(_pages[i], size),
                  ),
                ),

                // Bottom: indicator + button
                _buildBottomSection(page),
                const Gap(32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeCircles(_OnboardPage page, Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.3,
          right: -size.width * 0.2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  page.accentColor.withOpacity(0.15),
                  Colors.transparent
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.3,
          left: -size.width * 0.2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: size.width * 0.7,
            height: size.width * 0.7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [page.accentColor.withOpacity(0.1), Colors.transparent],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPage(_OnboardPage page, Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Floating illustration
          AnimatedBuilder(
            animation: _iconFloat,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _iconFloat.value),
              child: _buildIllustration(page, size),
            ),
          ),

          const Gap(48),

          // Title
          Text(
            page.title,
            style: GoogleFonts.syne(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: AppTheme.text1,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(16),

          // Subtitle
          Text(
            page.subtitle,
            style: GoogleFonts.dmSans(
              fontSize: 15,
              color: AppTheme.text2,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),

          const Gap(32),

          // Feature pills
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: page.features
                .map((f) => _FeaturePill(
                      label: f,
                      color: page.accentColor,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(_OnboardPage page, Size size) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer ring
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: page.accentColor.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        // Middle ring
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: page.accentColor.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        // Icon card
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                page.accentColor.withOpacity(0.9),
                page.accentColor.withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: page.accentColor.withOpacity(0.4),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(page.emoji, style: const TextStyle(fontSize: 36)),
                Icon(page.icon, color: Colors.white, size: 28),
              ],
            ),
          ),
        ),
        // Small orbiting dots
        ..._buildOrbitDots(page.accentColor),
      ],
    );
  }

  List<Widget> _buildOrbitDots(Color color) {
    return [
      Positioned(
        top: 10,
        right: 30,
        child: AnimatedBuilder(
          animation: _iconCtrl,
          builder: (_, __) => Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.6),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: 20,
        left: 25,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color.withOpacity(0.4)),
        ),
      ),
      Positioned(
        top: 40,
        left: 20,
        child: Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: color.withOpacity(0.3)),
        ),
      ),
    ];
  }

  Widget _buildBottomSection(_OnboardPage page) {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Page indicator dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: isActive
                      ? LinearGradient(
                          colors: [page.accentColor, AppTheme.accentPurple])
                      : null,
                  color: isActive ? null : AppTheme.text3,
                ),
              );
            }),
          ),

          const Gap(32),

          // Main CTA button
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [page.accentColor, AppTheme.accentPurple],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: page.accentColor.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isLast ? 'Get Started' : 'Continue',
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Gap(8),
                  Icon(
                    isLast
                        ? Icons.rocket_launch_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          if (!isLast) ...[
            const Gap(16),
            GestureDetector(
              onTap: _skip,
              child: Text(
                'Already have an account? Sign in',
                style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OnboardPage {
  final String title;
  final String subtitle;
  final IconData icon;
  final String emoji;
  final List<Color> gradient;
  final Color accentColor;
  final List<String> features;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.emoji,
    required this.gradient,
    required this.accentColor,
    required this.features,
  });
}

class _FeaturePill extends StatelessWidget {
  final String label;
  final Color color;
  const _FeaturePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: color, size: 13),
          const Gap(5),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
