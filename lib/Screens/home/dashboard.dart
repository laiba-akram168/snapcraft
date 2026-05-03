import 'dart:io';
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
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
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
      body: RefreshIndicator(
        color: AppTheme.accent,
        backgroundColor: AppTheme.card,
        onRefresh: () async {
          ref.invalidate(galleryProvider);
          await ref.read(galleryProvider.future);
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(child: _buildCategoryTabs()),
            SliverToBoxAdapter(child: _buildQuickActions(context)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Recent Creations',
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.text1,
                  ),
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
    );
  }

  List<File> _getFilteredImages(List<File> allImages) {
    if (_selectedCategory == 0) return allImages;
    // Mock filtering logic based on file names or paths for professional feel
    return allImages.where((f) {
      final pathLowerCase = f.path.toLowerCase();
      switch (_selectedCategory) {
        case 1: // Edited
          return pathLowerCase.contains('edit') || f.path.hashCode % 2 == 0;
        case 2: // Collages
          return pathLowerCase.contains('collage') || f.path.hashCode % 3 == 0;
        case 3: // AI Enhanced
          return pathLowerCase.contains('ai') || f.path.hashCode % 4 == 0;
        case 4: // Favourites
          return f.path.hashCode % 5 == 0;
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: AppTheme.bg,
      expandedHeight: 100,
      floating: true,
      snap: true,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: FadeTransition(
          opacity: _fadeAnim,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 52, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GradientText(
                      'SnapCraft',
                      gradient: AppTheme.brandGradient,
                      style: GoogleFonts.syne(
                          fontSize: 28, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'Make every shot extraordinary',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppTheme.text2),
                    ),
                  ],
                ),
                const Spacer(),
                _IconBtn(
                  icon: Icons.notifications_outlined, 
                  onTap: () => Navigator.pushNamed(context, '/notifications'),
                ),
                const Gap(8),
                _IconBtn(
                  icon: Icons.search_rounded, 
                  onTap: () {
                    final galleryState = ref.read(galleryProvider);
                    galleryState.whenData((images) {
                      showSearch(
                        context: context,
                        delegate: _GallerySearchDelegate(images, ref),
                      );
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, i) {
          final isSelected = i == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.accentGradient : null,
                color: isSelected ? null : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                _categories[i],
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? Colors.white : AppTheme.text2,
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
          icon: Icons.auto_fix_high_rounded,
          label: 'AI Enhance',
          color: AppTheme.accentPurple,
          onTap: () => Navigator.pushNamed(context, '/ai')),
      _QuickAction(
          icon: Icons.grid_view_rounded,
          label: 'Collage',
          color: AppTheme.accentBlue,
          onTap: () => Navigator.pushNamed(context, '/collage')),
      _QuickAction(
          icon: Icons.tune_rounded,
          label: 'Edit',
          color: AppTheme.accent,
          onTap: () => Navigator.pushNamed(context, '/editor')),
      _QuickAction(
          icon: Icons.style_rounded,
          label: 'Filters',
          color: const Color(0xFF3DDC84),
          onTap: () => Navigator.pushNamed(context, '/editor')),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: actions
            .map((a) => Expanded(
                  child: GestureDetector(
                    onTap: a.onTap,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border, width: 0.5),
                      ),
                      child: Column(
                        children: [
                          Icon(a.icon, color: a.color, size: 22),
                          const Gap(6),
                          Text(
                            a.label,
                            style: GoogleFonts.dmSans(
                                fontSize: 10, color: AppTheme.text2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMasonryGrid(List<File> images) {
    if (images.isEmpty) {
      return SliverToBoxAdapter(child: _buildEmptyState());
    }
    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
      baseColor: AppTheme.card,
      highlightColor: AppTheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: MasonryGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          itemBuilder: (_, i) => Container(
            height: i.isEven ? 160 : 220,
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Gap(40),
          Icon(Icons.photo_library_outlined, size: 64, color: AppTheme.text3),
          const Gap(16),
          Text('No photos yet',
              style: GoogleFonts.syne(fontSize: 18, color: AppTheme.text2)),
          const Gap(8),
          Text(
            'Tap + to import & edit your first photo',
            style: GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text3),
          ),
        ],
      ),
    );
  }
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

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Icon(icon, color: AppTheme.text2, size: 18),
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
        backgroundColor: AppTheme.bg,
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.text1),
        titleTextStyle: TextStyle(color: AppTheme.text1, fontSize: 18),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: GoogleFonts.dmSans(color: AppTheme.text3),
      ),
      scaffoldBackgroundColor: AppTheme.bg,
      textTheme: TextTheme(
        titleLarge: GoogleFonts.dmSans(color: AppTheme.text1, fontSize: 16),
      ),
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
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
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
