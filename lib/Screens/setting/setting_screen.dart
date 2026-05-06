import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/gradient_text.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states
  bool _autoSave = true;
  bool _aiEnhancement = true;
  bool _hapticFeedback = true;
  bool _highQualityExport = false;
  bool _saveOriginal = true;
  bool _showWatermark = false;
  bool _darkMode = true;
  bool _analyticsEnabled = false;

  String _exportFormat = 'JPEG';
  String _exportQuality = 'High';
  String _defaultFilter = 'Original';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Artistic Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [Color(0xFFFFFAF8), Color(0xFFFFF0EA)],
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: Gap(80)), // Header space
                SliverToBoxAdapter(
                    child: _buildSection(
                  'Image Processing',
                  Icons.image_rounded,
                  AppTheme.accentSecondary,
                  [
                    _ToggleSetting(
                      label: 'Auto-save edits',
                      subtitle: 'Save a copy after every edit',
                      value: _autoSave,
                      icon: Icons.save_outlined,
                      onChanged: (v) => setState(() => _autoSave = v),
                    ),
                    _ToggleSetting(
                      label: 'AI Enhancement',
                      subtitle: 'Use AI for smart suggestions',
                      value: _aiEnhancement,
                      icon: Icons.auto_awesome_outlined,
                      onChanged: (v) => setState(() => _aiEnhancement = v),
                    ),
                    _ToggleSetting(
                      label: 'Save Original',
                      subtitle: 'Keep original alongside edited',
                      value: _saveOriginal,
                      icon: Icons.photo_library_outlined,
                      onChanged: (v) => setState(() => _saveOriginal = v),
                    ),
                    _ToggleSetting(
                      label: 'High Quality Export',
                      subtitle: 'Larger file sizes, max quality',
                      value: _highQualityExport,
                      icon: Icons.high_quality_rounded,
                      onChanged: (v) => setState(() => _highQualityExport = v),
                    ),
                  ],
                )),
                SliverToBoxAdapter(
                    child: _buildSection(
                  'Export Settings',
                  Icons.file_upload_outlined,
                  AppTheme.accentTertiary,
                  [
                    _DropdownSetting(
                      label: 'Export Format',
                      icon: Icons.image_outlined,
                      value: _exportFormat,
                      options: ['JPEG', 'PNG', 'HEIC', 'WEBP'],
                      onChanged: (v) => setState(() => _exportFormat = v!),
                    ),
                    _DropdownSetting(
                      label: 'Export Quality',
                      icon: Icons.high_quality_outlined,
                      value: _exportQuality,
                      options: ['Low', 'Medium', 'High', 'Maximum'],
                      onChanged: (v) => setState(() => _exportQuality = v!),
                    ),
                    _DropdownSetting(
                      label: 'Default Filter',
                      icon: Icons.auto_fix_high_outlined,
                      value: _defaultFilter,
                      options: ['Original', 'Sepia', 'Vintage', 'Cool', 'Warm'],
                      onChanged: (v) => setState(() => _defaultFilter = v!),
                    ),
                    _ToggleSetting(
                      label: 'Add Watermark',
                      subtitle: 'Add SnapCraft branding on export',
                      value: _showWatermark,
                      icon: Icons.branding_watermark_outlined,
                      onChanged: (v) => setState(() => _showWatermark = v),
                    ),
                  ],
                )),
                SliverToBoxAdapter(
                    child: _buildSection(
                  'App Settings',
                  Icons.phone_android_rounded,
                  AppTheme.accent,
                  [
                    _ToggleSetting(
                      label: 'Dark Mode',
                      subtitle: 'System-wide dark appearance',
                      value: _darkMode,
                      icon: Icons.dark_mode_outlined,
                      onChanged: (v) => setState(() => _darkMode = v),
                    ),
                    _ToggleSetting(
                      label: 'Haptic Feedback',
                      subtitle: 'Vibrate on interactions',
                      value: _hapticFeedback,
                      icon: Icons.vibration_rounded,
                      onChanged: (v) => setState(() => _hapticFeedback = v),
                    ),
                    _ToggleSetting(
                      label: 'Analytics',
                      subtitle: 'Help improve SnapCraft',
                      value: _analyticsEnabled,
                      icon: Icons.bar_chart_rounded,
                      onChanged: (v) => setState(() => _analyticsEnabled = v),
                    ),
                  ],
                )),
                SliverToBoxAdapter(
                    child: _buildSection(
                  'Storage',
                  Icons.storage_rounded,
                  const Color(0xFF3DDC84),
                  [
                    _ActionSetting(
                      label: 'Clear Cache',
                      subtitle: '47.2 MB used',
                      icon: Icons.cleaning_services_rounded,
                      iconColor: Colors.orange,
                      actionLabel: 'Clear',
                      onTap: () => _showClearCacheDialog(),
                    ),
                    _ActionSetting(
                      label: 'Clear All Edits',
                      subtitle: '234 edited files',
                      icon: Icons.delete_sweep_rounded,
                      iconColor: Colors.red,
                      actionLabel: 'Delete',
                      onTap: () {},
                    ),
                  ],
                )),
                SliverToBoxAdapter(child: _buildVersionInfo()),
                const SliverToBoxAdapter(child: Gap(100)),
              ],
            ),
          ),

          // Header
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
    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 20,
          right: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppTheme.text1, size: 18),
                  ),
                ),
                const Gap(16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Settings',
                      style: GoogleFonts.syne(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.text1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'Preferences & Account',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppTheme.text2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
      String title, IconData icon, Color color, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const Gap(10),
              Text(
                title.toUpperCase(),
                style: GoogleFonts.syne(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.text2,
                    letterSpacing: 1.2),
              ),
            ],
          ),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                )
              ],
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: Column(
              children: children
                  .asMap()
                  .entries
                  .map((e) => Column(
                        children: [
                          e.value,
                          if (e.key < children.length - 1)
                            const Divider(
                                height: 0,
                                thickness: 1,
                                color: AppTheme.border,
                                indent: 56),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'SnapCraft v1.0.0',
            style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.text3),
          ),
          const Gap(4),
          Text(
            'Made with ❤️ in Flutter',
            style: GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear Cache?',
          style: GoogleFonts.syne(
              fontWeight: FontWeight.w700, color: AppTheme.text1),
        ),
        content: Text(
          'This will delete 47.2 MB of cached data.',
          style: GoogleFonts.dmSans(color: AppTheme.text2),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: AppTheme.text2)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Clear',
                style: GoogleFonts.syne(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Setting Widgets ───────────────────────────────────────────────
class _ToggleSetting extends StatelessWidget {
  final String label;
  final String? subtitle;
  final bool value;
  final IconData icon;
  final ValueChanged<bool> onChanged;

  const _ToggleSetting({
    required this.label,
    this.subtitle,
    required this.value,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: value ? AppTheme.accentSecondary.withOpacity(0.1) : AppTheme.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                color: value ? AppTheme.accentSecondary : AppTheme.text3,
                size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style:
                      GoogleFonts.dmSans(fontSize: 15, color: AppTheme.text1, fontWeight: FontWeight.w600),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style:
                        GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.accentSecondary,
          ),
        ],
      ),
    );
  }
}

class _DropdownSetting extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  const _DropdownSetting({
    required this.label,
    required this.icon,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accentTertiary, size: 20),
          const Gap(14),
          Expanded(
            child: Text(label,
                style: GoogleFonts.dmSans(fontSize: 14, color: AppTheme.text1)),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            dropdownColor: AppTheme.card,
            underline: const SizedBox.shrink(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.text3, size: 18),
            style: GoogleFonts.dmSans(
                fontSize: 13, color: AppTheme.accentSecondary),
            items: options
                .map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o,
                          style: GoogleFonts.dmSans(
                              fontSize: 13, color: AppTheme.text1)),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionSetting extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final String actionLabel;
  final VoidCallback onTap;

  const _ActionSetting({
    required this.label,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.dmSans(
                        fontSize: 14, color: AppTheme.text1)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: AppTheme.text3)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: iconColor.withOpacity(0.3), width: 0.5),
              ),
              child: Text(
                actionLabel,
                style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
