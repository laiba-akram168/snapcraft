import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  String _fileSize = '';
  String _fileDate = '';

  @override
  void initState() {
    super.initState();
    _uiCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _uiOpacity = CurvedAnimation(parent: _uiCtrl, curve: Curves.easeInOut);
    _uiCtrl.value = 1.0;

    _loadFileStats();
    _loadFavouriteStatus();
  }

  void _loadFileStats() {
    if (widget.imageFile != null && widget.imageFile!.existsSync()) {
      final stat = widget.imageFile!.statSync();
      final sizeMb = stat.size / (1024 * 1024);
      _fileSize = '${sizeMb.toStringAsFixed(1)} MB';
      final modified = stat.modified;
      _fileDate = '${modified.day}/${modified.month}/${modified.year}';
    }
  }

  Future<void> _loadFavouriteStatus() async {
    if (widget.imageFile == null) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFavourite = prefs.getBool('fav_${widget.imageFile!.path}') ?? false;
    });
  }

  Future<void> _toggleFavourite() async {
    if (widget.imageFile == null) return;
    final newStatus = !_isFavourite;
    setState(() {
      _isFavourite = newStatus;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fav_${widget.imageFile!.path}', newStatus);
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
                      onTap: _toggleFavourite,
                    ),
                    const Gap(8),
                    _CircleBtn(
                      icon: Icons.share_rounded,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sharing coming soon!')),
                        );
                      },
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

          // Bottom bar panel
          FadeTransition(
            opacity: _uiOpacity,
            child: Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.imageFile?.path.split('/').last ??
                                        'Photo',
                                    style: GoogleFonts.syne(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Gap(4),
                                  Text(
                                    '$_fileDate  ·  $_fileSize',
                                    style: GoogleFonts.dmSans(
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.7),
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.imageFile?.path
                                        .split('.')
                                        .last
                                        .toUpperCase() ??
                                    'JPG',
                                style: GoogleFonts.dmSans(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const Gap(24),
                        Row(
                          children: [
                            _DetailActionBtn(
                              icon: Icons.tune_rounded,
                              label: 'Edit',
                              color: Colors.white,
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/editor',
                                arguments: {'imageFile': widget.imageFile},
                              ),
                            ),
                            const Gap(12),
                            _DetailActionBtn(
                              icon: Icons.auto_awesome_rounded,
                              label: 'AI Magic',
                              color: AppTheme.accent,
                              onTap: () => Navigator.pushNamed(context, '/ai'),
                            ),
                            const Gap(12),
                            _DetailActionBtn(
                              icon: Icons.grid_view_rounded,
                              label: 'Collage',
                              color: AppTheme.accentSecondary,
                              onTap: () =>
                                  Navigator.pushNamed(context, '/collage'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
              (
                Icons.download_rounded,
                'Save a Copy',
                AppTheme.success,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Copy saved to gallery!')),
                  );
                  Navigator.pop(context);
                }
              ),
              (
                Icons.info_outline_rounded,
                'Image Info',
                AppTheme.text2,
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Path: ${widget.imageFile?.path}')),
                  );
                  Navigator.pop(context);
                }
              ),
              (
                Icons.delete_outline_rounded,
                'Delete',
                Colors.red,
                () {
                  if (widget.imageFile != null &&
                      widget.imageFile!.existsSync()) {
                    widget.imageFile!.deleteSync();
                  }
                  Navigator.pop(context); // Close sheet
                  Navigator.pop(context); // Close detail screen
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image deleted')),
                  );
                }
              ),
            ].map((item) => GestureDetector(
                  onTap: item.$4,
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

class _DetailActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _DetailActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color:
                color == Colors.white ? Colors.white : color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  color == Colors.white ? Colors.white : color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: color == Colors.white ? AppTheme.text1 : color,
                  size: 20),
              const Gap(6),
              Text(
                label,
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: color == Colors.white ? AppTheme.text1 : color,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
