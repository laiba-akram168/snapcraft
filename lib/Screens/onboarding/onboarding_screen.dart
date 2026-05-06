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
  late Animation<double> _iconFloat;

  final List<_OnboardPage> _pages = [
    const _OnboardPage(
      title: 'Edit Like a Pro',
      subtitle:
          'Professional brightness, contrast & advanced filters. Sepia, Vintage, Chrome — and more.',
      emoji: '✨',
      accentColor: AppTheme.accent,
      features: ['8 Premium Filters', 'Real-time Sliders', 'Undo / Redo'],
    ),
    const _OnboardPage(
      title: 'AI-Powered Magic',
      subtitle:
          'Smart AI analyzes your photos and suggests the perfect enhancements — automatically.',
      emoji: '🤖',
      accentColor: AppTheme.accentSecondary,
      features: ['Smart Analysis', 'One-tap Enhance', 'Real-time AI'],
    ),
    const _OnboardPage(
      title: 'Beautiful Collages',
      subtitle:
          'Combine multiple photos into stunning layouts. Choose from 6 templates and customize.',
      emoji: '🎨',
      accentColor: AppTheme.accentTertiary,
      features: ['6 Layouts', 'Custom BG', 'Quick Export'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _iconCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat(reverse: true);

    _iconFloat = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _iconCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _iconCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
      );
    } else {
      _finish();
    }
  }

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
          // Subtle background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.surfaceGradient,
              ),
            ),
          ),

          // Animated blobs for a modern look
          _buildDecorativeBlobs(page, size),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageCtrl,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (_, i) => _buildPage(_pages[i], size),
                  ),
                ),
                _buildBottomSection(page),
                const Gap(24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_fix_high_rounded,
                    color: Colors.white, size: 18),
              ),
              const Gap(10),
              Text(
                'SnapCraft',
                style: GoogleFonts.syne(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.text1,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: _finish,
            child: Text(
              'Skip',
              style: GoogleFonts.dmSans(
                color: AppTheme.text2,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorativeBlobs(_OnboardPage page, Size size) {
    return Stack(
      children: [
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          top: -100,
          right: _currentPage == 1 ? -50 : -150,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accentColor.withOpacity(0.08),
            ),
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 800),
          bottom: 100,
          left: _currentPage == 2 ? -50 : -150,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: page.accentColor.withOpacity(0.05),
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
          // Floating Illustration
          AnimatedBuilder(
            animation: _iconFloat,
            builder: (_, __) => Transform.translate(
              offset: Offset(0, _iconFloat.value),
              child: _buildIllustration(page),
            ),
          ),
          const Gap(60),
          Text(
            page.title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 34,
                  height: 1.1,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(20),
          Text(
            page.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: AppTheme.text2,
                ),
            textAlign: TextAlign.center,
          ),
          const Gap(40),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: page.features
                .map((f) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: AppTheme.shadowSm,
                        border: Border.all(color: AppTheme.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              color: page.accentColor, size: 14),
                          const Gap(6),
                          Text(
                            f,
                            style: GoogleFonts.dmSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.text1,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration(_OnboardPage page) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.accentColor.withOpacity(0.05),
          ),
        ),
        Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: page.accentColor.withOpacity(0.1),
          ),
        ),
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [page.accentColor, page.accentColor.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: page.accentColor.withOpacity(0.3),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Center(
            child: Text(
              page.emoji,
              style: const TextStyle(fontSize: 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(_OnboardPage page) {
    final isLast = _currentPage == _pages.length - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (i) {
              final isActive = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: isActive ? page.accentColor : AppTheme.border,
                ),
              );
            }),
          ),
          const Gap(40),
          GestureDetector(
            onTap: _nextPage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isLast ? 'Get Started' : 'Continue',
                      style: GoogleFonts.syne(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(10),
                    Icon(
                      isLast
                          ? Icons.rocket_launch_rounded
                          : Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
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
}

class _OnboardPage {
  final String title;
  final String subtitle;
  final String emoji;
  final Color accentColor;
  final List<String> features;

  const _OnboardPage({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.accentColor,
    required this.features,
  });
}
