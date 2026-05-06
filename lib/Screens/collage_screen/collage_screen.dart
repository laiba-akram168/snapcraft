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
      backgroundColor: Colors.transparent,
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
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppTheme.surfaceGradient,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                const Gap(80), // Space for floating header
                _buildLayoutPicker(),
                const Gap(16),
                Expanded(child: _buildCollageCanvas(state, layout)),
                const Gap(16),
                _buildRatioSelector(),
                _buildBottomBar(state),
              ],
            ),
          ),

          // Floating Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildHeader(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SafeArea(
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
            filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppTheme.text1, size: 20),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Collage',
                          style: GoogleFonts.syne(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.text1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Create your story',
                          style: GoogleFonts.dmSans(
                            fontSize: 11,
                            color: AppTheme.text2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(collageProvider.notifier).clearAll(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                      ),
                      child: Text(
                        'Clear',
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.text2,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const Gap(10),
                  GestureDetector(
                    onTap: _exportCollage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.brandGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        'Export',
                        style: GoogleFonts.syne(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exportCollage() async {
    try {
      final boundary = _collageKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final dir = await getApplicationDocumentsDirectory();
      final file = File(
          '${dir.path}/snapcraft_collage_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Collage saved successfully!',
              style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppTheme.accentSecondary,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'CHOOSE LAYOUT',
            style: GoogleFonts.syne(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.text2,
                letterSpacing: 1.5),
          ),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _layouts.length,
            itemBuilder: (_, i) {
              final isSelected = i == _selectedLayout;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedLayout = i);
                  ref.read(collageProvider.notifier).setLayout(_layouts[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  width: 84,
                  margin: const EdgeInsets.only(right: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.brandGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.border,
                      width: 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      )
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _layouts[i].icon,
                        color: isSelected ? Colors.white : AppTheme.text2,
                        size: 26,
                      ),
                      const Gap(8),
                      Text(
                        _layouts[i].name,
                        style: GoogleFonts.syne(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppTheme.text2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCollageCanvas(CollageState state, CollageLayout layout) {
    final totalSlots = layout.rows * layout.cols;

    Widget innerContent = Container(
      color: state.background,
      child: _buildLayoutGrid(layout, totalSlots, state),
    );

    Widget boundaryContent = RepaintBoundary(
      key: _collageKey,
      child: innerContent,
    );

    Widget finalContent = boundaryContent;

    if (_selectedRatio != 'Free') {
      double ratioValue = 1.0;
      switch (_selectedRatio) {
        case '4:5':
          ratioValue = 4 / 5;
          break;
        case '9:16':
          ratioValue = 9 / 16;
          break;
        case '16:9':
          ratioValue = 16 / 9;
          break;
        case '1:1':
        default:
          ratioValue = 1.0;
          break;
      }
      finalContent = Center(
        child: AspectRatio(
          aspectRatio: ratioValue,
          child: boundaryContent,
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 35,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(color: AppTheme.border, width: 2),
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
        childAspectRatio: layout.id == 3 ? 0.7 : 1.0,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
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
    final ratios = ['1:1', '4:5', '9:16', '16:9'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            'ASPECT RATIO',
            style: GoogleFonts.syne(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppTheme.text2,
                letterSpacing: 1.5),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: ratios.map((r) {
              final isSelected = r == _selectedRatio;
              return GestureDetector(
                onTap: () => setState(() => _selectedRatio = r),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.only(right: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.brandGradient : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                    border: Border.all(
                      color: isSelected ? Colors.transparent : AppTheme.border,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    r,
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppTheme.text1,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
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
                      fontSize: 12, color: AppTheme.accentSecondary),
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
                AppTheme.accentSecondary.withOpacity(0.3)
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
          // Gradient overlay for the close button
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12, blurRadius: 4, spreadRadius: 1)
                  ],
                ),
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.error, size: 14),
              ),
            ),
          ),
        ],
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: const Color(0xFFFBF9F8),
        child: DottedBorder(
          borderType: BorderType.RRect,
          radius: const Radius.circular(0),
          color: AppTheme.border,
          strokeWidth: 2,
          dashPattern: const [8, 6],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: const Icon(Icons.add_rounded,
                      color: AppTheme.accent, size: 24),
                ),
                const Gap(10),
                Text(
                  'ADD PHOTO',
                  style: GoogleFonts.syne(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text2,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
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
