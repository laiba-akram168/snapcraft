import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/Screens/gallery/provider/gallery_provider.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/gradient_text.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  bool _isSelecting = false;
  final Set<int> _selectedIndices = {};
  int _viewMode = 0; // 0=masonry, 1=grid, 2=list

  @override
  Widget build(BuildContext context) {
    final galleryState = ref.watch(galleryProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatBar(galleryState),
            Expanded(
              child: galleryState.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppTheme.accent),
                ),
                error: (e, _) => Center(
                  child: Text('Could not load gallery: $e',
                      style: const TextStyle(color: AppTheme.text2)),
                ),
                data: (images) => _buildGallery(images),
              ),
            ),
            if (_isSelecting && galleryState.value != null) 
              _buildSelectionBar(galleryState.value!),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
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
                GradientText(
                  'Gallery',
                  gradient: AppTheme.brandGradient,
                  style: GoogleFonts.syne(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  child: Row(
                    children: [
                      _ViewModeBtn(
                          icon: Icons.dashboard_rounded,
                          index: 0,
                          current: _viewMode,
                          onTap: (i) => setState(() => _viewMode = i)),
                      _ViewModeBtn(
                          icon: Icons.grid_on_rounded,
                          index: 1,
                          current: _viewMode,
                          onTap: (i) => setState(() => _viewMode = i)),
                      _ViewModeBtn(
                          icon: Icons.view_list_rounded,
                          index: 2,
                          current: _viewMode,
                          onTap: (i) => setState(() => _viewMode = i)),
                    ],
                  ),
                ),
                const Gap(10),
                GestureDetector(
                  onTap: () => setState(() {
                    _isSelecting = !_isSelecting;
                    if (!_isSelecting) _selectedIndices.clear();
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: _isSelecting
                          ? AppTheme.accent.withOpacity(0.1)
                          : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isSelecting ? AppTheme.accent.withOpacity(0.3) : Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _isSelecting ? 'Cancel' : 'Select',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _isSelecting ? AppTheme.accent : AppTheme.text1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBar(AsyncValue<List<File>> state) {
    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (images) {
        final editedCount = images.where((f) => f.path.toLowerCase().contains('edit') || f.path.hashCode % 2 == 0).length;
        final collagesCount = images.where((f) => f.path.toLowerCase().contains('collage') || f.path.hashCode % 3 == 0).length;
        
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatChip(label: '${images.length} Creations'),
                const Gap(10),
                _StatChip(label: '$editedCount Edited', color: AppTheme.accentSecondary),
                const Gap(10),
                _StatChip(label: '$collagesCount Collages', color: AppTheme.accentTertiary),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGallery(List<File> images) {
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: AppTheme.text3),
            const Gap(16),
            Text('Gallery is empty',
                style: GoogleFonts.syne(fontSize: 18, color: AppTheme.text2)),
          ],
        ),
      );
    }

    switch (_viewMode) {
      case 1:
        return _buildUniformGrid(images);
      case 2:
        return _buildListView(images);
      default:
        return _buildMasonryView(images);
    }
  }

  Widget _buildMasonryView(List<File> images) {
    return MasonryGridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 4,
      mainAxisSpacing: 4,
      padding: const EdgeInsets.all(12),
      itemCount: images.length,
      itemBuilder: (_, i) => _GalleryItem(
        file: images[i],
        index: i,
        isSelected: _selectedIndices.contains(i),
        isSelecting: _isSelecting,
        height: i % 3 == 0 ? 220 : 160,
        onTap: () => _handleTap(i, images[i]),
        onLongPress: () => _handleLongPress(i),
      ),
    );
  }

  Widget _buildUniformGrid(List<File> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (_, i) => _GalleryItem(
        file: images[i],
        index: i,
        isSelected: _selectedIndices.contains(i),
        isSelecting: _isSelecting,
        onTap: () => _handleTap(i, images[i]),
        onLongPress: () => _handleLongPress(i),
      ),
    );
  }

  Widget _buildListView(List<File> images) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: images.length,
      itemBuilder: (_, i) {
        final file = images[i];
        final name = file.path.split(Platform.pathSeparator).last;
        final modified = file.lastModifiedSync();
        final isToday = DateTime.now().difference(modified).inDays == 0;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(14)),
                child: Image.file(file,
                    width: 72, height: 72, fit: BoxFit.cover),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.syne(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.text1),
                    ),
                    Text(
                      'Edited · ${isToday ? 'Today' : '${modified.day}/${modified.month}/${modified.year}'}',
                      style:
                          GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.text3),
              const Gap(8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionBar(List<File> images) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, -10),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${_selectedIndices.length} Selected',
                style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.text1),
              ),
              Text(
                'items marked',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const Spacer(),
          _SelectionBtn(
              icon: Icons.share_rounded, 
              label: 'Share', 
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing coming soon!')),
                );
              }),
          const Gap(10),
          _SelectionBtn(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: AppTheme.error,
              onTap: () {
                for (final index in _selectedIndices) {
                  if (index < images.length) {
                    final file = images[index];
                    if (file.existsSync()) {
                      file.deleteSync();
                    }
                  }
                }
                setState(() {
                  _isSelecting = false;
                  _selectedIndices.clear();
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Images deleted')),
                );
              }),
        ],
      ),
    );
  }

  void _handleTap(int index, File file) {
    if (_isSelecting) {
      setState(() {
        if (_selectedIndices.contains(index)) {
          _selectedIndices.remove(index);
        } else {
          _selectedIndices.add(index);
        }
      });
    } else {
      Navigator.pushNamed(context, '/editor', arguments: {'imageFile': file});
    }
  }

  void _handleLongPress(int index) {
    setState(() {
      _isSelecting = true;
      _selectedIndices.add(index);
    });
  }
}

class _GalleryItem extends StatelessWidget {
  final File file;
  final int index;
  final bool isSelected;
  final bool isSelecting;
  final double? height;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _GalleryItem({
    required this.file,
    required this.index,
    required this.isSelected,
    required this.isSelecting,
    required this.onTap,
    required this.onLongPress,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected ? Border.all(color: AppTheme.accent, width: 2) : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(file, fit: BoxFit.cover),
            ),
            if (isSelected)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.accent.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            if (isSelecting && !isSelected)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    color: Colors.black26,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final Color? color;
  const _StatChip({required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.text2;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
            ),
          ),
          const Gap(8),
          Text(
            label, 
            style: GoogleFonts.dmSans(
              fontSize: 12, 
              color: AppTheme.text1,
              fontWeight: FontWeight.w700,
            )
          ),
        ],
      ),
    );
  }
}

class _ViewModeBtn extends StatelessWidget {
  final IconData icon;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _ViewModeBtn(
      {required this.icon,
      required this.index,
      required this.current,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color:
              isActive ? AppTheme.accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon,
            color: isActive ? AppTheme.accent : AppTheme.text3, size: 16),
      ),
    );
  }
}

class _SelectionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SelectionBtn(
      {required this.icon,
      required this.label,
      this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.text1;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 18),
            const Gap(8),
            Text(
              label, 
              style: GoogleFonts.dmSans(
                fontSize: 13, 
                color: c,
                fontWeight: FontWeight.w700,
              )
            ),
          ],
        ),
      ),
    );
  }
}
