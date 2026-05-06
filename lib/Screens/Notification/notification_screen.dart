import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gap/gap.dart';
import 'package:snapcraft/core/constant.dart';
import 'package:snapcraft/widget/gradient_text.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_Notif> _notifications = [
    _Notif(
      icon: Icons.auto_awesome_rounded,
      iconColor: AppTheme.accentSecondary,
      title: 'AI Enhancement Ready',
      body: 'Your photo has been enhanced. Check the results!',
      time: 'Just now',
      isNew: true,
    ),
    _Notif(
      icon: Icons.save_alt_rounded,
      iconColor: AppTheme.success,
      title: 'Photo Saved',
      body: 'Edited_photo_042.jpg was saved to your gallery.',
      time: '5 min ago',
      isNew: true,
    ),
    _Notif(
      icon: Icons.workspace_premium_rounded,
      iconColor: AppTheme.accent,
      title: 'Upgrade to Pro',
      body: 'Unlock unlimited AI enhancements & premium filters.',
      time: '1 hour ago',
      isNew: true,
    ),
    _Notif(
      icon: Icons.tips_and_updates_rounded,
      iconColor: AppTheme.accentTertiary,
      title: 'Tip of the Day',
      body:
          'Try combining the Vintage filter with a warm tone for a film look.',
      time: '3 hours ago',
      isNew: false,
    ),
    _Notif(
      icon: Icons.grid_view_rounded,
      iconColor: AppTheme.accentSecondary,
      title: 'Collage Exported',
      body: 'Your 2×2 collage was saved successfully.',
      time: 'Yesterday',
      isNew: false,
    ),
    _Notif(
      icon: Icons.star_rounded,
      iconColor: Colors.amber,
      title: 'Achievement Unlocked!',
      body:
          'You\'ve earned the 🔥 Hot Streak badge for editing 7 days in a row!',
      time: '2 days ago',
      isNew: false,
    ),
    _Notif(
      icon: Icons.system_update_rounded,
      iconColor: AppTheme.text2,
      title: 'App Updated',
      body: 'SnapCraft v1.0.1 is available with new filters and bug fixes.',
      time: '3 days ago',
      isNew: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final newNotifs = _notifications.where((n) => n.isNew).toList();
    final oldNotifs = _notifications.where((n) => !n.isNew).toList();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (newNotifs.isNotEmpty) ...[
                    _buildSectionLabel('New', count: newNotifs.length),
                    const Gap(8),
                    ...newNotifs.asMap().entries.map((e) => _NotifCard(
                          notif: e.value,
                          onDismiss: () =>
                              setState(() => _notifications.remove(e.value)),
                        )),
                    const Gap(16),
                  ],
                  if (oldNotifs.isNotEmpty) ...[
                    _buildSectionLabel('Earlier'),
                    const Gap(8),
                    ...oldNotifs.map((n) => _NotifCard(
                          notif: n,
                          onDismiss: () =>
                              setState(() => _notifications.remove(n)),
                        )),
                  ],
                  const Gap(100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final newCount = _notifications.where((n) => n.isNew).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
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
            'Notifications',
            gradient: AppTheme.brandGradient,
            style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          if (newCount > 0) ...[
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$newCount',
                style: GoogleFonts.syne(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() {
              for (final n in _notifications) n.isNew = false;
            }),
            child: Text(
              'Mark all read',
              style: GoogleFonts.dmSans(
                  fontSize: 12, color: AppTheme.accentSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, {int? count}) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.syne(
              fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.text2),
        ),
        if (count != null) ...[
          const Gap(6),
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
                color: AppTheme.accent, shape: BoxShape.circle),
            child: Center(
              child: Text(
                '$count',
                style: GoogleFonts.syne(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  final _Notif notif;
  final VoidCallback onDismiss;

  const _NotifCard({required this.notif, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.title + notif.time),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notif.isNew ? AppTheme.card : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: notif.isNew
                ? notif.iconColor.withOpacity(0.2)
                : AppTheme.border,
            width: 0.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: notif.iconColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(notif.icon, color: notif.iconColor, size: 20),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: GoogleFonts.syne(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.text1,
                          ),
                        ),
                      ),
                      if (notif.isNew)
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppTheme.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const Gap(3),
                  Text(
                    notif.body,
                    style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppTheme.text2, height: 1.4),
                  ),
                  const Gap(5),
                  Text(
                    notif.time,
                    style:
                        GoogleFonts.dmSans(fontSize: 11, color: AppTheme.text3),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Notif {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String time;
  bool isNew;

  _Notif({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.time,
    required this.isNew,
  });
}
