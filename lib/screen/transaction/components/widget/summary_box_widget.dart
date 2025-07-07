import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SummaryBoxWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final bool isWidthExpanded;
  final VoidCallback? onTap;
  const SummaryBoxWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    required this.isWidthExpanded,
    this.onTap,
  });

  @override
  State<SummaryBoxWidget> createState() => _SummaryBoxWidgetState();
}

class _SummaryBoxWidgetState extends State<SummaryBoxWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        } else {
          null;
        }
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(14.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: 14),
              Icon(
                widget.icon,
                size: 32,
                color: Theme.of(context).colorScheme.secondary,
              ),
              SizedBox(height: 14),
              SizedBox(
                child: Text(
                  widget.subtitle,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
