import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snapcraft/Screens/ImageDetail/image_detail_screen.dart';
import 'package:snapcraft/Screens/Notification/notification_screen.dart';
import 'package:snapcraft/Screens/ai_assistant/ai_assistant_screen.dart';
import 'package:snapcraft/Screens/collage_screen/collage_screen.dart';
import 'package:snapcraft/Screens/editor/editor_screen.dart';
import 'package:snapcraft/Screens/gallery/gallery_screen.dart';
import 'package:snapcraft/Screens/home/dashboard.dart';
import 'package:snapcraft/Screens/onboarding/onboarding_screen.dart';
import 'package:snapcraft/Screens/profile/profile_screen.dart';
import 'package:snapcraft/Screens/setting/setting_screen.dart';
import 'package:snapcraft/Screens/splash/splash_screen.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: WidgetsBinding.instance);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: AppTheme.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const ProviderScope(child: SnapCraftApp()));
}

class SnapCraftApp extends StatelessWidget {
  const SnapCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnapCraft',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return _fadeRoute(const SplashScreen());
          case '/onboarding':
            return _fadeRoute(const OnboardingScreen());
          case '/home':
            return _fadeRoute(const MainShell());
          case '/editor':
            final args = settings.arguments as Map<String, dynamic>?;
            return _slideRoute(EditorScreen(imageFile: args?['imageFile']));
          case '/collage':
            return _slideRoute(const CollageScreen());
          case '/ai':
            return _slideRoute(const AiAssistantScreen());
          case '/gallery':
            return _slideRoute(const GalleryScreen());
          case '/image-detail':
            final args = settings.arguments as Map<String, dynamic>?;
            return _fadeRoute(ImageDetailScreen(
              imageFile: args?['imageFile'],
              heroTag: args?['heroTag'],
            ));
          case '/profile':
            return _slideRoute(const ProfileScreen());
          case '/settings':
            return _slideRoute(const SettingsScreen());
          case '/notifications':
            return _slideRoute(const NotificationsScreen());
          default:
            return _fadeRoute(const MainShell());
        }
      },
    );
  }

  PageRoute _fadeRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      );

  PageRoute _slideRoute(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 350),
        transitionsBuilder: (_, anim, __, child) {
          final tween = Tween<Offset>(
            begin: const Offset(0, 0.06),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic));
          return SlideTransition(
            position: anim.drive(tween),
            child: FadeTransition(opacity: anim, child: child),
          );
        },
      );
}

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    GalleryScreen(),
    CollageScreen(),
    AiAssistantScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: _buildFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildFAB() {
    return Container(
      margin: const EdgeInsets.only(top: 36),
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/editor'),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: AppTheme.accent.withOpacity(0.4),
                  blurRadius: 25,
                  offset: const Offset(0, 8))
            ],
            border: Border.all(color: Colors.white, width: 2.5),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 84,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter:
              SystemUiOverlayStyle.light.statusBarBrightness == Brightness.light
                  ? ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                  : ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  index: 0,
                  current: _currentIndex,
                  onTap: _onTap),
              _NavItem(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  index: 1,
                  current: _currentIndex,
                  onTap: _onTap),
              const Gap(60),
              _NavItem(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Magic AI',
                  index: 3,
                  current: _currentIndex,
                  onTap: _onTap),
              _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 4,
                  current: _currentIndex,
                  onTap: _onTap),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _currentIndex = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isActive ? AppTheme.accent : AppTheme.text3.withOpacity(0.5),
              size: 22,
            ),
            const Gap(4),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: isActive
                    ? AppTheme.accent
                    : AppTheme.text3.withOpacity(0.5),
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            if (isActive) ...[
              const Gap(2),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
