import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/core/constant.dart';

class ImageDetailScreen extends StatefulWidget {
  final File? imageFile;
  final String? heroTag;

  const ImageDetailScreen({super.key, this.imageFile, this.heroTag});

  @override
  State<ImageDetailScreen> createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  late AnimationController _uiCtrl;
  late Animation<double> _uiOpacity;
  bool _uiVisible = true;
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    _uiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _uiOpacity = CurvedAnimation(parent: _uiCtrl, curve: Curves.easeInOut);
    _uiCtrl.value = 1.0;
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _uiCtrl.dispose();
    super.dispose();
  }

  void _toggleUI() {
    setState(() => _uiVisible = !_uiVisible);
    if (_uiVisible) {
      _uiCtrl.forward();
    } else {
      _uiCtrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main image with pinch-to-zoom
          GestureDetector(
            onTap: _toggleUI,
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformCtrl,
                minScale: 0.8,
                maxScale: 5.0,
                child: widget.imageFile != null
                    ? Hero(
                        tag: widget.heroTag ?? 'image',
                        child:
                            Image.file(widget.imageFile!, fit: BoxFit.contain),
                      )
                    : Container(
                        color: AppTheme.card,
                        width: double.infinity,
                        height: 300,
                        child: const Icon(Icons.image_rounded,
                            color: AppTheme.text3, size: 64),
                      ),
              ),
            ),
          ),

          // Top bar
          FadeTransition(
            opacity: _uiOpacity,
            child: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _CircleBtn(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    _CircleBtn(
                      icon: _isFavourite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: _isFavourite ? Colors.red : Colors.white,
                      onTap: () => setState(() => _isFavourite = !_isFavourite),
                    ),
                    const Gap(8),
                    _CircleBtn(
                      icon: Icons.share_rounded,
                      onTap: () {},
                    ),
                    const Gap(8),
                    _CircleBtn(
                      icon: Icons.more_horiz_rounded,
                      onTap: () => _showOptionsSheet(context),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom bar
          FadeTransition(
            opacity: _uiOpacity,
            child: Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.imageFile?.path.split('/').last ?? 'Photo',
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}  ·  4.2 MB  ·  3024×4032',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: Colors.white60),
                    ),
                    const Gap(16),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.tune_rounded,
                            label: 'Edit',
                            gradient: AppTheme.accentGradient,
                            onTap: () => Navigator.pushNamed(
                              context,
                              '/editor',
                              arguments: {'imageFile': widget.imageFile},
                            ),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.auto_awesome_rounded,
                            label: 'AI Enhance',
                            gradient: const LinearGradient(
                              colors: [Color(0xFFC77DFF), Color(0xFF7B2FBE)],
                            ),
                            onTap: () => Navigator.pushNamed(context, '/ai'),
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: _ActionBtn(
                            icon: Icons.grid_view_rounded,
                            label: 'Collage',
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentBlue, Color(0xFF0077B6)],
                            ),
                            onTap: () =>
                                Navigator.pushNamed(context, '/collage'),
                          ),
                        ),
                      ],
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

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.border,
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Gap(20),
            ...[
              (Icons.download_rounded, 'Save to Gallery', AppTheme.success),
              (Icons.copy_rounded, 'Copy Image', AppTheme.accentBlue),
              (Icons.info_outline_rounded, 'Image Info', AppTheme.text2),
              (Icons.delete_outline_rounded, 'Delete', Colors.red),
            ].map((item) => GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.border, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(item.$1, color: item.$3, size: 20),
                        const Gap(14),
                        Text(item.$2,
                            style: GoogleFonts.dmSans(
                                fontSize: 14, color: AppTheme.text1)),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12, width: 0.5),
        ),
        child: Icon(icon, color: iconColor ?? Colors.white, size: 18),
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            gradient: gradient, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const Gap(4),
            Text(label,
                style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
