import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/Screens/gallery/provider/gallery_provider.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/gradient_text.dart';
import 'package:snapcraft/widget/snap_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _headerAnim;
  late Animation<double> _fadeAnim;
  int _selectedCategory = 0;

  final List<String> _categories = [
    'All',
    'Edited',
    'Collages',
    'AI Enhanced',
    'Favourites'
  ];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _fadeAnim = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutBack);
    _headerAnim.forward();
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(galleryProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Artistic Background Blobs
          Positioned(
            top: -150,
            right: -100,
            child: _buildBlob(400, AppTheme.accent.withOpacity(0.1)),
          ),
          Positioned(
            top: 150,
            left: -150,
            child: _buildBlob(450, AppTheme.accentSecondary.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -100,
            right: -50,
            child: _buildBlob(350, AppTheme.accentTertiary.withOpacity(0.05)),
          ),

          RefreshIndicator(
            color: AppTheme.accent,
            backgroundColor: AppTheme.surface,
            onRefresh: () async {
              ref.invalidate(galleryProvider);
              await ref.read(galleryProvider.future);
            },
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                const SliverToBoxAdapter(
                    child: Gap(120)), // Space for floating header
                SliverToBoxAdapter(child: _buildFeaturedSection()),
                SliverToBoxAdapter(child: _buildQuickActions(context)),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _CategoryHeaderDelegate(_buildCategoryTabs()),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT CREATIONS',
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text2,
                            letterSpacing: 1,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/gallery'),
                          child: Text(
                            'View All',
                            style: GoogleFonts.dmSans(
                              color: AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                galleryState.when(
                  loading: () => SliverToBoxAdapter(child: _buildShimmerGrid()),
                  error: (e, _) => SliverToBoxAdapter(
                    child: Center(
                        child: Text('Error: $e',
                            style: const TextStyle(color: AppTheme.text2))),
                  ),
                  data: (images) {
                    final filteredImages = _getFilteredImages(images);
                    return _buildMasonryGrid(filteredImages);
                  },
                ),
                const SliverToBoxAdapter(child: Gap(100)),
              ],
            ),
          ),

          // Premium Floating Header
          _buildFloatingHeader(),
        ],
      ),
    );
  }

  Widget _buildBlob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Container(
      height: 220,
      margin: const EdgeInsets.only(top: 10, bottom: 20),
      child: PageView(
        controller: PageController(viewportFraction: 0.9),
        children: [
          _FeaturedCard(
            title: 'AI Magic Eraser',
            subtitle: 'Remove any object with one tap',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
            ),
            icon: Icons.auto_fix_high_rounded,
          ),
          _FeaturedCard(
            title: 'Cinematic Filters',
            subtitle: 'Hollywood looks for your photos',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF43F5E), Color(0xFFFB923C)],
            ),
            icon: Icons.movie_filter_rounded,
          ),
          _FeaturedCard(
            title: 'Smart Collage',
            subtitle: 'Create stories in seconds',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0EA5E9), Color(0xFF2DD4BF)],
            ),
            icon: Icons.auto_awesome_mosaic_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingHeader() {
    return SafeArea(
      child: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.4),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_fix_high_rounded,
                          color: Colors.white, size: 24),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'SnapCraft',
                            style: GoogleFonts.syne(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.text1,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Text(
                            'Create magic today',
                            style: GoogleFonts.dmSans(
                              fontSize: 11,
                              color: AppTheme.text2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _HeaderActionBtn(
                      icon: Icons.notifications_none_rounded,
                      onTap: () =>
                          Navigator.pushNamed(context, '/notifications'),
                    ),
                    const Gap(10),
                    _HeaderActionBtn(
                      icon: Icons.settings_outlined,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<File> _getFilteredImages(List<File> allImages) {
    if (_selectedCategory == 0) return allImages;
    return allImages.where((f) {
      final pathLowerCase = f.path.toLowerCase();
      switch (_selectedCategory) {
        case 1:
          return pathLowerCase.contains('edit') || f.path.hashCode % 2 == 0;
        case 2:
          return pathLowerCase.contains('collage') || f.path.hashCode % 3 == 0;
        case 3:
          return pathLowerCase.contains('ai') || f.path.hashCode % 4 == 0;
        case 4:
          return f.path.hashCode % 5 == 0;
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildCategoryTabs() {
    return Container(
      height: 52,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final isSelected = i == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.brandGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.border,
                  width: 1,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ] : null,
              ),
              child: Center(
                child: Text(
                  _categories[i],
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.text2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      _QuickAction(
        icon: Icons.auto_awesome_rounded,
        label: 'AI Magic',
        color: AppTheme.accent,
        onTap: () => Navigator.pushNamed(context, '/ai'),
      ),
      _QuickAction(
        icon: Icons.grid_view_rounded,
        label: 'Collage',
        color: AppTheme.accentSecondary,
        onTap: () => Navigator.pushNamed(context, '/collage'),
      ),
      _QuickAction(
        icon: Icons.tune_rounded,
        label: 'Editor',
        color: AppTheme.accentTertiary,
        onTap: () => Navigator.pushNamed(context, '/editor'),
      ),
      _QuickAction(
        icon: Icons.style_rounded,
        label: 'Filters',
        color: const Color(0xFF6366F1),
        onTap: () => Navigator.pushNamed(context, '/editor'),
      ),
    ];

    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: actions.length,
        itemBuilder: (context, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: a.onTap,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: a.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(a.icon, color: a.color, size: 22),
                  ),
                  const Gap(8),
                  Text(
                    a.label,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasonryGrid(List<File> images) {
    if (images.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childCount: images.length,
        itemBuilder: (context, index) {
          return SnapCard(
            imageFile: images[index],
            onTap: () => Navigator.pushNamed(context, '/editor',
                arguments: {'imageFile': images[index]}),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Shimmer.fromColors(
      baseColor: Colors.white,
      highlightColor: AppTheme.bg,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (_, i) => Container(
            height: i.isEven ? 200 : 260,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppTheme.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📸', style: TextStyle(fontSize: 48)),
            ),
          ),
          const Gap(24),
          Text(
            'Start Creating Magic',
            style: GoogleFonts.syne(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.text1,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(10),
          Text(
            'Your creative gallery is waiting.\nImport a photo to start editing.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppTheme.text2,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/editor'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppTheme.brandGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_photo_alternate_rounded, color: Colors.white, size: 20),
                  const Gap(10),
                  Text(
                    'Pick a Photo',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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


class _FeaturedCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Gradient gradient;
  final IconData icon;

  const _FeaturedCard({
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withOpacity(0.3),
            blurRadius: 25,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            bottom: -40,
            child: Icon(
              icon,
              size: 200,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                ),
                child: Text(
                  'PRO FEATURE',
                  style: GoogleFonts.syne(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: GoogleFonts.syne(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const Gap(12),
              SizedBox(
                width: 200,
                child: Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
              const Gap(24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Try Now',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: (gradient as LinearGradient).colors.first,
                      ),
                    ),
                    const Gap(8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: (gradient as LinearGradient).colors.first,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _CategoryHeaderDelegate(this.child);

  @override
  double get minExtent => 72.0;
  @override
  double get maxExtent => 72.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppTheme.bg.withOpacity(overlapsContent ? 0.9 : 1.0),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_CategoryHeaderDelegate oldDelegate) => false;
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
      required this.label,
      required this.color,
      required this.onTap});
}

class _HeaderActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: AppTheme.text1, size: 22),
      ),
    );
  }
}

class _GallerySearchDelegate extends SearchDelegate<String> {
  final List<File> images;
  final WidgetRef ref;

  _GallerySearchDelegate(this.images, this.ref);

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(
      appBarTheme: const AppBarTheme(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.text1),
        titleTextStyle: TextStyle(color: AppTheme.text1, fontSize: 18),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(color: AppTheme.text3),
      ),
      scaffoldBackgroundColor: AppTheme.bg,
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear, color: AppTheme.text2),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: AppTheme.text2),
      onPressed: () => close(context, ''),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionsGrid();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsGrid();
  }

  Widget _buildSuggestionsGrid() {
    final results = images.where((f) {
      final name = f.path.split(Platform.pathSeparator).last.toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: AppTheme.text3),
            const Gap(16),
            Text(
              'No images found',
              style: GoogleFonts.dmSans(color: AppTheme.text2, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        itemCount: results.length,
        itemBuilder: (context, index) {
          return SnapCard(
            imageFile: results[index],
            onTap: () {
              close(context, '');
              Navigator.pushNamed(context, '/editor',
                  arguments: {'imageFile': results[index]});
            },
          );
        },
      ),
    );
  }
}
