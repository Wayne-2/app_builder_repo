import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pacervtu/constants.dart';

class UserAvatar extends StatelessWidget {
  final String name;
  final double size;

  const UserAvatar({
    super.key,
    required this.name,
    this.size = 48,
  });


  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(name);

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: AppData.lightTheme,
      child: Text(
        initials,
        style: GoogleFonts.roboto(
          color: AppData.appTheme,
          fontWeight: FontWeight.w500,
          fontSize: size * 0.4,
          shadows: [
            Shadow(
              offset: const Offset(0.5, 0.5),
              color: Colors.black.withOpacity(0.2),
              blurRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
