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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.shadowSm,
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: const Icon(Icons.settings_outlined,
                  color: AppTheme.text1, size: 20),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.surfaceGradient,
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
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: _avatarPath != null 
                              ? DecorationImage(image: FileImage(File(_avatarPath!)), fit: BoxFit.cover)
                              : null,
                            gradient: _avatarPath == null ? AppTheme.brandGradient : null,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accent.withOpacity(0.3),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: _avatarPath == null ? Center(
                            child: Text(_userName.isNotEmpty ? _userName[0].toUpperCase() : 'S',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w800,
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
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: AppTheme.brandGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: AppTheme.shadowSm,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(16),
                Text(
                  _userName,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const Gap(4),
                Text(
                  _userEmail,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Gap(12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: AppTheme.shadowSm,
                  ),
                  child: Text(
                    '✨ PRO MEMBER',
                    style: GoogleFonts.syne(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1),
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
      ('Filters\nUsed', '24'), 
      ('Collages\nMade', '$collagesMade'),
      ('AI\nMagic', '12'),  
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.shadowSm,
        border: Border.all(color: AppTheme.border, width: 1),
      ),
      child: Row(
        children: stats
            .map((s) => Expanded(
                  child: Column(
                    children: [
                      Text(
                        s.$2,
                        style: GoogleFonts.syne(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.text1,
                        ),
                      ),
                      const Gap(6),
                      Text(
                        s.$1,
                        style: GoogleFonts.dmSans(
                            fontSize: 10, color: AppTheme.text2, height: 1.4, fontWeight: FontWeight.w600),
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
      ('🔥', 'Streak', '7 days'),
      ('🎨', 'Artist', '50 edits'),
      ('⚡', 'Magic', '25 AI'),
      ('🏆', 'Legend', 'Top 1%'),
      ('📸', 'Pro', 'Active'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Gap(16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: badges.length,
              itemBuilder: (_, i) {
                final isSpecial = i == 0 || i == 3;
                return Container(
                  width: 90,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSpecial ? AppTheme.accent.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.shadowSm,
                    border: Border.all(
                      color: isSpecial ? AppTheme.accent.withOpacity(0.2) : AppTheme.border,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        badges[i].$1,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const Gap(6),
                      Text(
                        badges[i].$2,
                        style: GoogleFonts.dmSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        badges[i].$3,
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.text2,
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
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.text2,
                letterSpacing: 0.5),
          ),
          const Gap(12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppTheme.shadowSm,
              border: Border.all(color: AppTheme.border, width: 1),
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
                            horizontal: 20, vertical: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: item.iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(item.icon,
                                  color: item.iconColor, size: 20),
                            ),
                            const Gap(16),
                            Expanded(
                              child: Text(
                                item.label,
                                style: GoogleFonts.dmSans(
                                    fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.text1),
                              ),
                            ),
                            if (item.badge != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.brandGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.badge!,
                                  style: GoogleFonts.syne(
                                      fontSize: 9,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            const Gap(8),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppTheme.text3, size: 20),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(
                          height: 0,
                          thickness: 1,
                          color: AppTheme.border,
                          indent: 76),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sign out successful')),
          );
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.1), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              const Gap(10),
              Text(
                'Sign Out',
                style: GoogleFonts.syne(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
            iconColor: AppTheme.accent,
            onTap: _editProfile),
        _MenuItem(
            icon: Icons.workspace_premium_rounded,
            label: 'Upgrade to Pro',
            iconColor: AppTheme.accentSecondary,
            badge: 'PRO',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pro subscription coming soon')));
            }),
        _MenuItem(
            icon: Icons.cloud_upload_outlined,
            label: 'Cloud Backup',
            iconColor: AppTheme.accentTertiary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cloud backup syncing...')));
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
            iconColor: AppTheme.accentSecondary,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appearance settings opening...')));
            }),
      ];

  List<_MenuItem> _supportItems(BuildContext context) => [
        _MenuItem(
            icon: Icons.help_outline_rounded,
            label: 'Help Center',
            iconColor: AppTheme.accentTertiary,
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
