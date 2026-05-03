import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:snapcraft/Screens/gallery/provider/gallery_provider.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/gradient_text.dart';

class CollageScreen extends ConsumerStatefulWidget {
  const CollageScreen({super.key});

  @override
  ConsumerState<CollageScreen> createState() => _CollageScreenState();
}

class _CollageScreenState extends ConsumerState<CollageScreen>
    with SingleTickerProviderStateMixin {
  int _selectedLayout = 0;
  String _selectedRatio = '1:1';
  final _picker = ImagePicker();
  final GlobalKey _collageKey = GlobalKey();

  final List<CollageLayout> _layouts = [
    CollageLayout(
        id: 0, name: '2×1', icon: Icons.grid_view_rounded, rows: 1, cols: 2),
    CollageLayout(
        id: 1, name: '2×2', icon: Icons.grid_on_rounded, rows: 2, cols: 2),
    CollageLayout(
        id: 2, name: '3×1', icon: Icons.view_column_rounded, rows: 1, cols: 3),
    CollageLayout(
        id: 3, name: 'Story', icon: Icons.view_day_rounded, rows: 3, cols: 1),
    CollageLayout(
        id: 4, name: 'Mosaic', icon: Icons.dashboard_rounded, rows: 2, cols: 3),
    CollageLayout(
        id: 5,
        name: 'Magazine',
        icon: Icons.auto_stories_rounded,
        rows: 2,
        cols: 2),
  ];

  Future<void> _addImage(int slotIndex) async {
    final result = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _ImageSourceSheet(),
    );
    if (result == null) return;

    final picked = await _picker.pickImage(source: result);
    if (picked != null) {
      ref
          .read(collageProvider.notifier)
          .setSlotImage(slotIndex, File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(collageProvider);
    final layout = _layouts[_selectedLayout];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildLayoutPicker(),
            const Gap(8),
            Expanded(child: _buildCollageCanvas(state, layout)),
            _buildRatioSelector(),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: AppTheme.text2, size: 16),
            ),
          ),
          const Gap(12),
          GradientText(
            'Collage',
            gradient: AppTheme.brandGradient,
            style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => ref.read(collageProvider.notifier).clearAll(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: Text('Clear',
                  style:
                      GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2)),
            ),
          ),
          const Gap(8),
          GestureDetector(
            onTap: _exportCollage,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Export',
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCollage() async {
    try {
      final boundary = _collageKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/snapcraft_collage_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Collage saved to gallery!'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    }
  }

  Widget _buildLayoutPicker() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _layouts.length,
        itemBuilder: (_, i) {
          final isSelected = i == _selectedLayout;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedLayout = i);
              ref.read(collageProvider.notifier).setLayout(_layouts[i]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.accentGradient : null,
                color: isSelected ? null : AppTheme.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppTheme.border,
                  width: 0.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_layouts[i].icon,
                      color: isSelected ? Colors.white : AppTheme.text3,
                      size: 22),
                  const Gap(5),
                  Text(_layouts[i].name,
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: isSelected ? Colors.white : AppTheme.text2,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollageCanvas(CollageState state, CollageLayout layout) {
    final totalSlots = layout.rows * layout.cols;

    Widget innerContent = Container(
      color: state.background,
      child: _buildLayoutGrid(layout, totalSlots, state),
    );

    // Tightly wrap the collage in the boundary to prevent exporting empty UI space
    Widget boundaryContent = RepaintBoundary(
      key: _collageKey,
      child: innerContent,
    );

    Widget finalContent = boundaryContent;

    // Apply aspect ratio if not 'Free'
    if (_selectedRatio != 'Free') {
      double ratioValue = 1.0;
      switch (_selectedRatio) {
        case '4:5': ratioValue = 4 / 5; break;
        case '9:16': ratioValue = 9 / 16; break;
        case '16:9': ratioValue = 16 / 9; break;
        case '1:1': default: ratioValue = 1.0; break;
      }
      finalContent = Center(
        child: AspectRatio(
          aspectRatio: ratioValue,
          child: boundaryContent,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: finalContent,
    );
  }

  Widget _buildLayoutGrid(
      CollageLayout layout, int totalSlots, CollageState state) {
    // Special magazine layout
    if (layout.id == 5) return _buildMagazineLayout(state);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.cols,
        childAspectRatio: layout.id == 3 ? 2.0 : 1.0,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: totalSlots,
      itemBuilder: (_, i) => _CollageSlot(
        index: i,
        imageFile: i < state.slots.length ? state.slots[i] : null,
        onTap: () => _addImage(i),
        onRemove: () => ref.read(collageProvider.notifier).removeSlotImage(i),
      ),
    );
  }

  Widget _buildMagazineLayout(CollageState state) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Row(
            children: [
              Expanded(
                  child: _CollageSlot(
                index: 0,
                imageFile: state.slots.isNotEmpty ? state.slots[0] : null,
                onTap: () => _addImage(0),
                onRemove: () =>
                    ref.read(collageProvider.notifier).removeSlotImage(0),
              )),
              const SizedBox(width: 2),
              Expanded(
                  child: Column(
                children: [
                  Expanded(
                      child: _CollageSlot(
                    index: 1,
                    imageFile: state.slots.length > 1 ? state.slots[1] : null,
                    onTap: () => _addImage(1),
                    onRemove: () =>
                        ref.read(collageProvider.notifier).removeSlotImage(1),
                  )),
                  const SizedBox(height: 2),
                  Expanded(
                      child: _CollageSlot(
                    index: 2,
                    imageFile: state.slots.length > 2 ? state.slots[2] : null,
                    onTap: () => _addImage(2),
                    onRemove: () =>
                        ref.read(collageProvider.notifier).removeSlotImage(2),
                  )),
                ],
              )),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: _CollageSlot(
            index: 3,
            imageFile: state.slots.length > 3 ? state.slots[3] : null,
            onTap: () => _addImage(3),
            onRemove: () =>
                ref.read(collageProvider.notifier).removeSlotImage(3),
          ),
        ),
      ],
    );
  }

  Widget _buildRatioSelector() {
    final ratios = ['Free', '1:1', '4:5', '9:16', '16:9'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          Text('Canvas ratio',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
          const Spacer(),
          ...ratios.map((r) => GestureDetector(
                onTap: () => setState(() => _selectedRatio = r),
                child: Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: r == _selectedRatio
                        ? AppTheme.accent.withOpacity(0.15)
                        : AppTheme.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: r == _selectedRatio ? AppTheme.accent : AppTheme.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(r,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: r == _selectedRatio ? AppTheme.accent : AppTheme.text2,
                      )),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildBottomBar(CollageState state) {
    final filledSlots = state.slots.where((f) => f != null).length;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          // Progress indicator
          Row(
            children: [
              Text(
                '$filledSlots/${_layouts[_selectedLayout].rows * _layouts[_selectedLayout].cols} photos added',
                style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    ref.read(collageProvider.notifier).autoFill(_picker),
                child: Text(
                  'Auto-fill from gallery',
                  style: GoogleFonts.dmSans(
                      fontSize: 12, color: AppTheme.accentPurple),
                ),
              ),
            ],
          ),
          const Gap(8),
          // Background color row
          Row(
            children: [
              Text('Background',
                  style:
                      GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text2)),
              const Gap(12),
              ...[
                Colors.black,
                Colors.white,
                const Color(0xFF1C1C26),
                AppTheme.accentPurple.withOpacity(0.3)
              ].map(
                (c) => GestureDetector(
                  onTap: () =>
                      ref.read(collageProvider.notifier).setBackground(c),
                  child: Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.border, width: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Collage Slot ──────────────────────────────────────────────────
class _CollageSlot extends StatelessWidget {
  final int index;
  final File? imageFile;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _CollageSlot({
    required this.index,
    required this.imageFile,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(imageFile!, fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(0),
        color: AppTheme.text3,
        strokeWidth: 1,
        dashPattern: const [6, 4],
        child: Container(
          color: AppTheme.surface,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined,
                  color: AppTheme.text3, size: 26),
              const Gap(6),
              Text(
                'Add photo',
                style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(20),
          Text('Add Photo',
              style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.text1)),
          const Gap(20),
          _SheetOption(
            icon: Icons.photo_library_rounded,
            label: 'Choose from Gallery',
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          const Gap(12),
          _SheetOption(
            icon: Icons.camera_alt_rounded,
            label: 'Take a Photo',
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SheetOption(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 22),
            const Gap(14),
            Text(label,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1)),
          ],
        ),
      ),
    );
  }
}
