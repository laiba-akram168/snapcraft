import 'dart:io';
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
            if (_isSelecting) _buildSelectionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GradientText(
            'Gallery',
            gradient: AppTheme.brandGradient,
            style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          // View mode toggle
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border, width: 0.5),
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
          const Gap(8),
          GestureDetector(
            onTap: () => setState(() {
              _isSelecting = !_isSelecting;
              if (!_isSelecting) _selectedIndices.clear();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: _isSelecting
                    ? AppTheme.accent.withOpacity(0.15)
                    : AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isSelecting ? AppTheme.accent : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Text(
                _isSelecting ? 'Cancel' : 'Select',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: _isSelecting ? AppTheme.accent : AppTheme.text2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBar(AsyncValue<List<File>> state) {
    return state.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (images) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            _StatChip(label: '${images.length} Photos'),
            const Gap(8),
            _StatChip(label: '12 Edited', color: AppTheme.accentPurple),
            const Gap(8),
            _StatChip(label: '3 Collages', color: AppTheme.accentBlue),
          ],
        ),
      ),
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
      itemBuilder: (_, i) => Container(
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
              child: Image.file(images[i],
                  width: 72, height: 72, fit: BoxFit.cover),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Photo ${i + 1}',
                    style: GoogleFonts.syne(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.text1),
                  ),
                  Text(
                    'Edited · ${i % 2 == 0 ? 'Today' : 'Yesterday'}',
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
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIndices.length} selected',
            style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text2),
          ),
          const Spacer(),
          _SelectionBtn(
              icon: Icons.share_rounded, label: 'Share', onTap: () {}),
          const Gap(8),
          _SelectionBtn(
              icon: Icons.delete_outline_rounded,
              label: 'Delete',
              color: Colors.red,
              onTap: () {}),
          const Gap(8),
          _SelectionBtn(
              icon: Icons.auto_fix_high_rounded,
              label: 'Edit',
              color: AppTheme.accentPurple,
              onTap: () {}),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withOpacity(0.3), width: 0.5),
      ),
      child: Text(label, style: GoogleFonts.dmSans(fontSize: 11, color: c)),
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
    final c = color ?? AppTheme.text2;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.withOpacity(0.3), width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: c, size: 16),
            const Gap(5),
            Text(label, style: GoogleFonts.dmSans(fontSize: 12, color: c)),
          ],
        ),
      ),
    );
  }
}
