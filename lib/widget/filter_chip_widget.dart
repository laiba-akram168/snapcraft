// lib/widgets/filter_chip_widget.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/Screens/editor/editor_provider.dart';
import 'package:snapcraft/core/constant.dart';

class FilterChipWidget extends StatelessWidget {
  final SnapFilter filter;
  final bool isActive;
  final Uint8List? thumbnail;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.filter,
    required this.isActive,
    this.thumbnail,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        margin: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? AppTheme.accent : AppTheme.border,
                  width: isActive ? 2 : 0.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: thumbnail != null
                  ? ColorFiltered(
                      colorFilter: filter.colorFilter,
                      child: Image.memory(thumbnail!, fit: BoxFit.cover),
                    )
                  : Container(
                      color: AppTheme.card,
                      child: Center(
                          child: Text(filter.emoji,
                              style: const TextStyle(fontSize: 24))),
                    ),
            ),
            const Gap(5),
            Text(
              filter.name,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: isActive ? AppTheme.accent : AppTheme.text2,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// lib/widgets/adjustment_slider.dart
class AdjustmentSlider extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const AdjustmentSlider({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.text2, size: 16),
          const Gap(8),
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text2),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 2,
                activeTrackColor: AppTheme.accent,
                inactiveTrackColor: AppTheme.card,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                overlayColor: AppTheme.accent.withOpacity(0.2),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: 36,
            child: Text(
              '${(value * 100).round()}',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                color: value != 0 ? AppTheme.accent : AppTheme.text3,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
