// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pacervtu/constants.dart';

class IconAction extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback? onTap;
  final double size;

  const IconAction({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 60,
  });

  @override
  Widget build(BuildContext context) {
    final Color filledColor = AppData.appTheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              color: filledColor.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppData.appTheme,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
             icon,
             width: 26,
             height: 26,
             colorFilter: const ColorFilter.mode(AppData.appTheme, BlendMode.srcIn),
          )),
          SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          )
        ],
      ),
    );
  }
}
