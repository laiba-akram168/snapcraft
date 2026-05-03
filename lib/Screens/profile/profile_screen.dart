import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snapcraft/Screens/gallery/provider/gallery_provider.dart';
import 'package:snapcraft/core/constant.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _avatarCtrl;
  late Animation<double> _avatarScale;

  String _userName = 'Snapcraft User';
  String _userEmail = 'user@snapcraft.app';
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _avatarScale =
        CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut);
    _avatarCtrl.forward();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Snapcraft User';
      _userEmail = prefs.getString('user_email') ?? 'user@snapcraft.app';
      _avatarPath = prefs.getString('avatar_path');
    });
  }

  Future<void> _updateAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('avatar_path', picked.path);
      setState(() {
        _avatarPath = picked.path;
      });
    }
  }

  Future<void> _editProfile() async {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Edit Profile', style: GoogleFonts.syne(color: AppTheme.text1)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: AppTheme.text1),
              decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppTheme.text3)),
            ),
            TextField(
              controller: emailCtrl,
              style: const TextStyle(color: AppTheme.text1),
              decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: AppTheme.text3)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', nameCtrl.text);
      await prefs.setString('user_email', emailCtrl.text);
      setState(() {
        _userName = nameCtrl.text;
        _userEmail = emailCtrl.text;
      });
    }
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(context),
          SliverToBoxAdapter(child: _buildStats()),
          SliverToBoxAdapter(child: _buildAchievements()),
          SliverToBoxAdapter(
              child: _buildMenuSection('Account', _accountItems(context))),
          SliverToBoxAdapter(
              child: _buildMenuSection('Preferences', _prefItems(context))),
          SliverToBoxAdapter(
              child: _buildMenuSection('Support', _supportItems(context))),
          SliverToBoxAdapter(child: _buildSignOut()),
          const SliverToBoxAdapter(child: Gap(100)),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.bg,
      expandedHeight: 240,
      pinned: true,
      elevation: 0,
      leading: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.border, width: 0.5),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: AppTheme.text2, size: 18),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1A0A2E), AppTheme.bg],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(20),
                // Avatar with ring
                ScaleTransition(
                  scale: _avatarScale,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: _updateAvatar,
                        child: Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: _avatarPath != null 
                              ? DecorationImage(image: FileImage(File(_avatarPath!)), fit: BoxFit.cover)
                              : null,
                            gradient: _avatarPath == null ? const LinearGradient(
                              colors: [AppTheme.accent, AppTheme.accentPurple],
                            ) : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentPurple.withOpacity(0.35),
                                blurRadius: 24,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: _avatarPath == null ? Center(
                            child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                )),
                          ) : null,
                        ),
                      ),
                      // Edit badge
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _updateAvatar,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppTheme.accentPurple,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.bg, width: 2),
                            ),
                            child: const Icon(Icons.edit_rounded,
                                color: Colors.white, size: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(14),
                Text(
                  _userName,
                  style: GoogleFonts.syne(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.text1),
                ),
                const Gap(4),
                Text(
                  _userEmail,
                  style:
                      GoogleFonts.dmSans(fontSize: 13, color: AppTheme.text2),
                ),
                const Gap(10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accentPurple]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '✨ Pro Member',
                    style: GoogleFonts.syne(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    final galleryState = ref.watch(galleryProvider);
    int photosEdited = 0;
    int collagesMade = 0;

    galleryState.whenData((files) {
      photosEdited = files.where((f) => f.path.contains('snapcraft_') && !f.path.contains('collage')).length;
      collagesMade = files.where((f) => f.path.contains('snapcraft_collage_')).length;
    });

    final stats = [
      ('Photos\nEdited', '$photosEdited'),
      ('Filters\nUsed', '24'), // Mock dynamic logic
      ('Collages\nMade', '$collagesMade'),
      ('AI\nEnhanced', '12'),  // Mock dynamic logic
    ];

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border, width: 0.5),
      ),
      child: Row(
        children: stats
            .map((s) => Expanded(
                  child: Column(
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (bounds) =>
                            AppTheme.brandGradient.createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                        child: Text(
                          s.$2,
                          style: GoogleFonts.syne(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ),
                      const Gap(4),
                      Text(
                        s.$1,
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: AppTheme.text2, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildAchievements() {
    final badges = [
      ('🔥', 'Hot Streak', '7 days'),
      ('🎨', 'Artist', '50 edits'),
      ('⚡', 'AI Power', '25 AI'),
      ('🏆', 'Pro', 'Upgrade'),
      ('📸', 'Sharpshooter', '100 photos'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.text1),
          ),
          const Gap(12),
          SizedBox(
            height: 86,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final isLocked = i == 3;
                return Container(
                  width: 74,
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isLocked ? AppTheme.surface : AppTheme.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isLocked
                          ? AppTheme.border
                          : AppTheme.accentPurple.withOpacity(0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLocked ? '🔒' : badges[i].$1,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const Gap(4),
                      Text(
                        badges[i].$2,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          color: isLocked ? AppTheme.text3 : AppTheme.text2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        badges[i].$3,
                        style: GoogleFonts.syne(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color:
                              isLocked ? AppTheme.text3 : AppTheme.accentPurple,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.text2),
          ),
          const Gap(10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border, width: 0.5),
            ),
            child: Column(
              children: items.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: item.onTap,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: item.iconColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item.icon,
                                  color: item.iconColor, size: 18),
                            ),
                            const Gap(14),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.dmSans(
                                    fontSize: 14, color: AppTheme.text1),
                              ),
                            ),
                            if (item.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.accent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: GoogleFonts.syne(
                                      fontSize: 10,
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                            const Gap(4),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.text3, size: 18),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(
                          height: 0,
                          thickness: 0.5,
                          color: AppTheme.border,
                          indent: 66),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOut() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign out successful')),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.withOpacity(0.2), width: 0.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red, size: 18),
              const Gap(8),
              Text(
                'Sign Out',
                style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_MenuItem> _accountItems(BuildContext context) => [
        _MenuItem(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            iconColor: AppTheme.accentPurple,
            onTap: _editProfile),
        _MenuItem(
            icon: Icons.workspace_premium_rounded,
            label: 'Upgrade to Pro',
            iconColor: AppTheme.accent,
            badge: 'PRO',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pro subscription coming soon')));
            }),
        _MenuItem(
            icon: Icons.cloud_upload_outlined,
            label: 'Cloud Backup',
            iconColor: AppTheme.accentBlue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloud backup syncing...')));
            }),
        _MenuItem(
            icon: Icons.devices_rounded,
            label: 'Connected Devices',
            iconColor: const Color(0xFF3DDC84),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Showing connected devices')));
            }),
      ];

  List<_MenuItem> _prefItems(BuildContext context) => [
        _MenuItem(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            iconColor: AppTheme.accent,
            onTap: () => Navigator.pushNamed(context, '/notifications')),
        _MenuItem(
            icon: Icons.settings_outlined,
            label: 'App Settings',
            iconColor: AppTheme.text2,
            onTap: () => Navigator.pushNamed(context, '/settings')),
        _MenuItem(
            icon: Icons.color_lens_outlined,
            label: 'Appearance',
            iconColor: AppTheme.accentPurple,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appearance settings opening...')));
            }),
        _MenuItem(
            icon: Icons.storage_outlined,
            label: 'Storage & Cache',
            iconColor: const Color(0xFF3DDC84),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cache cleared (142MB freed)')));
            }),
      ];

  List<_MenuItem> _supportItems(BuildContext context) => [
        _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help Center',
            iconColor: AppTheme.accentBlue,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Help Center')));
            }),
        _MenuItem(
            icon: Icons.bug_report_outlined,
            label: 'Report a Bug',
            iconColor: Colors.orange,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bug report drafted')));
            }),
        _MenuItem(
            icon: Icons.info_outline_rounded,
            label: 'About SnapCraft',
            iconColor: AppTheme.text2,
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SnapCraft',
                applicationVersion: '1.0.0 Pro',
                applicationIcon: const Icon(Icons.camera_rounded, size: 40, color: AppTheme.accent),
              );
            }),
      ];
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color iconColor;
  final String? badge;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.iconColor,
    this.badge,
    required this.onTap,
  });
}
