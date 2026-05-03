import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/core/constant.dart';

class SnapCard extends StatefulWidget {
  final File imageFile;
  final VoidCallback? onTap;

  const SnapCard({super.key, required this.imageFile, this.onTap});

  @override
  State<SnapCard> createState() => _SnapCardState();
}

class _SnapCardState extends State<SnapCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  bool _isFavourite = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border, width: 0.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Image
              Image.file(widget.imageFile,
                  fit: BoxFit.cover, width: double.infinity),

              // Bottom overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Today',
                          style: GoogleFonts.dmSans(
                              fontSize: 11, color: Colors.white70),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => _isFavourite = !_isFavourite),
                        child: Icon(
                          _isFavourite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _isFavourite ? Colors.red : Colors.white70,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Edit badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentPurple.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.auto_fix_high_rounded,
                          color: Colors.white, size: 9),
                      const Gap(3),
                      Text('AI',
                          style: GoogleFonts.syne(
                              fontSize: 9,
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
