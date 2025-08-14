import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MemberInfoContainer extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  const MemberInfoContainer(
      {super.key,
      required this.title,
      required this.subtitle,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.inter()),
            const SizedBox(height: 2),
            Text(subtitle,
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600, color: color.withValues())),
          ],
        ),
      ),
    );
  }
}
