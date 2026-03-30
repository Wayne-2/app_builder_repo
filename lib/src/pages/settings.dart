import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:pacervtu/constants.dart';
import 'package:pacervtu/src/components/useravatar.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(255, 255, 255, 1),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppData.appTheme.withAlpha(100),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(44, 158, 158, 158),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  UserAvatar(name: "Frederick Solomon",),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Frederick Solomon",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Fredmon667@gmail.com",
                          style: GoogleFonts.inter(
                            color: const Color.fromARGB(255, 112, 112, 112),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.edit_outlined, color: Colors.grey[600]),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              'App Settings',
              style: GoogleFonts.urbanist(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _SettingTile(
              icon: LucideIcons.user,
              title: 'Personal Information',
              onTap: () {},
            ),
            _SettingTile(
              icon: LucideIcons.shield,
              title: 'Security & Privacy',
              onTap: () {},
            ),
            _SettingTile(
              icon: LucideIcons.bell,
              title: 'Notifications',
              onTap: () {},
            ),
            _SettingTile(
              icon: LucideIcons.helpCircle,
              title: 'Help & Support',
              onTap: () {},
            ),
            _SettingTile(
              icon: LucideIcons.info,
              title: 'About Our app',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(LucideIcons.logOut, color: Colors.red),
              label: Text(
                'Logout',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey[800], size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
