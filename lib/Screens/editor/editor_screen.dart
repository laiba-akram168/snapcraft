import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapcraft/Screens/editor/editor_provider.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/filter_chip_widget.dart';
import 'package:snapcraft/widget/gradient_text.dart';

class EditorScreen extends ConsumerStatefulWidget {
  final File? imageFile;
  const EditorScreen({super.key, this.imageFile});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with TickerProviderStateMixin {
  late TabController _toolTabController;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _toolTabController = TabController(length: 4, vsync: this);

    // Load image if passed
    if (widget.imageFile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(editorProvider.notifier).loadImage(widget.imageFile!);
      });
    }
  }

  @override
  void dispose() {
    _toolTabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      ref.read(editorProvider.notifier).loadImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context, editorState),
            Expanded(child: _buildCanvas(editorState)),
            _buildToolTabs(),
            _buildToolPanel(editorState),
            _buildBottomActions(editorState),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, EditorState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          _TopBtn(
            icon: Icons.close_rounded,
            onTap: () => Navigator.pop(context),
            color: AppTheme.text1.withOpacity(0.05),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PHOTO EDITOR',
                  style: GoogleFonts.syne(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  state.processedImage != null ? 'Edit Image' : 'Import Photo',
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text1,
                  ),
                ),
              ],
            ),
          ),
          if (state.canUndo)
            _TopBtn(
              icon: Icons.undo_rounded,
              onTap: () => ref.read(editorProvider.notifier).undo(),
            ),
          const Gap(8),
          if (state.canRedo)
            _TopBtn(
              icon: Icons.redo_rounded,
              onTap: () => ref.read(editorProvider.notifier).redo(),
            ),
          const Gap(12),
          GestureDetector(
            onTap: () => ref.read(editorProvider.notifier).exportImage(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas(EditorState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: state.processedImage != null
          ? _buildImagePreview(state)
          : _buildEmptyCanvas(),
    );
  }

  Widget _buildImagePreview(EditorState state) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: state.activeFilter.colorFilter,
          child: Image.memory(
            state.processedImage!,
            fit: BoxFit.contain,
          ),
        ),
        // Histogram overlay (optional)
        if (state.showHistogram)
          Positioned(
            bottom: 8,
            right: 8,
            child: _HistogramWidget(imageData: state.processedImage!),
          ),
        // Compare button
        Positioned(
          bottom: 8,
          left: 8,
          child: GestureDetector(
            onLongPressStart: (_) =>
                ref.read(editorProvider.notifier).showOriginal(true),
            onLongPressEnd: (_) =>
                ref.read(editorProvider.notifier).showOriginal(false),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.compare_rounded,
                      color: Colors.white, size: 14),
                  const Gap(4),
                  Text(
                    'Hold to compare',
                    style:
                        GoogleFonts.dmSans(fontSize: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCanvas() {
    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: const Icon(Icons.add_photo_alternate_rounded,
                color: AppTheme.text3, size: 32),
          ),
          const Gap(16),
          Text(
            'Tap to import a photo',
            style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.text2),
          ),
          const Gap(6),
          Text(
            'JPEG, PNG, HEIC supported',
            style: GoogleFonts.dmSans(fontSize: 12, color: AppTheme.text3),
          ),
        ],
      ),
    );
  }

  Widget _buildToolTabs() {
    final tabs = ['Filters', 'Adjust', 'Crop', 'Tools'];
    final icons = [
      Icons.auto_awesome_rounded,
      Icons.tune_rounded,
      Icons.crop_rounded,
      Icons.auto_fix_normal_rounded,
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: TabBar(
        controller: _toolTabController,
        indicator: BoxDecoration(
          gradient: AppTheme.brandGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accent.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        padding: const EdgeInsets.all(4),
        labelStyle:
            GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.text2,
        tabs: List.generate(
            4,
            (i) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icons[i], size: 16),
                      const Gap(6),
                      Text(tabs[i]),
                    ],
                  ),
                )),
      ),
    );
  }

  Widget _buildToolPanel(EditorState state) {
    return SizedBox(
      height: 160,
      child: TabBarView(
        controller: _toolTabController,
        children: [
          _FilterPanel(state: state),
          _AdjustPanel(state: state),
          _CropPanel(),
          _MorePanel(),
        ],
      ),
    );
  }

  Widget _buildBottomActions(EditorState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          Expanded(
            child: _ActionBtn(
              icon: Icons.auto_fix_high_rounded,
              label: 'AI Enhance',
              gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF4F46E5)]),
              onTap: () => ref.read(editorProvider.notifier).aiEnhance(),
            ),
          ),
          const Gap(12),
          Expanded(
            child: _ActionBtn(
              icon: Icons.save_alt_rounded,
              label: 'Save Gallery',
              gradient: AppTheme.brandGradient,
              onTap: () => ref.read(editorProvider.notifier).saveImage(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filter Panel ──────────────────────────────────────────────────
class _FilterPanel extends ConsumerWidget {
  final EditorState state;
  const _FilterPanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = SnapFilter.all;

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: filters.length,
      itemBuilder: (_, i) {
        final isActive = state.activeFilter == filters[i];
        return FilterChipWidget(
          filter: filters[i],
          isActive: isActive,
          thumbnail: state.originalImage,
          onTap: () =>
              ref.read(editorProvider.notifier).applyFilter(filters[i]),
        );
      },
    );
  }
}

// ── Adjust Panel ──────────────────────────────────────────────────
class _AdjustPanel extends ConsumerWidget {
  final EditorState state;
  const _AdjustPanel({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          AdjustmentSlider(
            label: 'Brightness',
            icon: Icons.brightness_6_rounded,
            value: state.brightness,
            min: -1.0,
            max: 1.0,
            onChanged: (v) =>
                ref.read(editorProvider.notifier).setBrightness(v),
          ),
          AdjustmentSlider(
            label: 'Contrast',
            icon: Icons.contrast_rounded,
            value: state.contrast,
            min: -1.0,
            max: 1.0,
            onChanged: (v) => ref.read(editorProvider.notifier).setContrast(v),
          ),
          AdjustmentSlider(
            label: 'Saturation',
            icon: Icons.water_drop_rounded,
            value: state.saturation,
            min: -1.0,
            max: 1.0,
            onChanged: (v) =>
                ref.read(editorProvider.notifier).setSaturation(v),
          ),
          AdjustmentSlider(
            label: 'Warmth',
            icon: Icons.wb_sunny_rounded,
            value: state.warmth,
            min: -1.0,
            max: 1.0,
            onChanged: (v) => ref.read(editorProvider.notifier).setWarmth(v),
          ),
        ],
      ),
    );
  }
}

class _CropPanel extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratios = ['Free', '1:1', '4:3', '16:9', '3:4', '9:16'];
    final ratioVals = [0.0, 1.0, 4/3, 16/9, 3/4, 9/16];
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: ratios.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () {
          if (i > 0) {
            ref.read(editorProvider.notifier).cropImage(ratioVals[i]);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cropped to ${ratios[i]}'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: i == 0 ? AppTheme.accent.withOpacity(0.15) : AppTheme.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: i == 0 ? AppTheme.accent : AppTheme.border,
              width: i == 0 ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.crop_rounded,
                  color: i == 0 ? AppTheme.accent : AppTheme.text3, size: 22),
              const Gap(4),
              Text(ratios[i],
                  style: GoogleFonts.dmSans(
                      fontSize: 10,
                      color: i == 0 ? AppTheme.accent : AppTheme.text2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MorePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tools = [
      ('Vignette', Icons.vignette_rounded),
      ('Blur', Icons.blur_on_rounded),
      ('Sharpen', Icons.deblur_rounded),
      ('Noise', Icons.grain_rounded),
      ('Tint', Icons.colorize_rounded),
    ];
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: tools.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${tools[i].$1} feature coming soon!'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          width: 72,
          height: 80,
          margin: const EdgeInsets.only(right: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tools[i].$2, color: AppTheme.accentSecondary, size: 24),
              const Gap(6),
              Text(tools[i].$1,
                  style: GoogleFonts.dmSans(fontSize: 10, color: AppTheme.text2)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistogramWidget extends StatelessWidget {
  final Uint8List imageData;
  const _HistogramWidget({required this.imageData});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 48,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: _HistogramPainter()),
    );
  }
}

class _HistogramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1;
    for (int i = 0; i < 20; i++) {
      final h = (size.height *
          (0.2 + 0.6 * (i % 5 == 0 ? 1 : (i % 3 == 0 ? 0.6 : 0.3))));
      canvas.drawLine(
        Offset(i * (size.width / 20), size.height),
        Offset(i * (size.width / 20), size.height - h),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  const _TopBtn({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: AppTheme.text1, size: 20),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const Gap(10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
