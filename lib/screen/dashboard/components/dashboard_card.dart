import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String performance;
  final IconData? icon;
  final bool isWidthExpanded;
  final VoidCallback? onTap;
  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.performance,
    this.icon,
    required this.isWidthExpanded,
    this.onTap,
  });

  @override
  State<DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<DashboardCard> {
  Color getPerformanceColor(BuildContext context) {
    if (widget.performance.trim() == '0' ||
        widget.performance.trim() == '0%' ||
        widget.performance.trim() == '0.0') {
      return Colors.grey;
    } else if (widget.performance.startsWith('-')) {
      return Theme.of(context).colorScheme.error;
    } else {
      return Colors.green.withAlpha(255);
    }
  }

  Color getPerformanceBgColor() {
    if (widget.performance.trim() == '0' ||
        widget.performance.trim() == '0%' ||
        widget.performance.trim() == '0.0') {
      return Colors.grey.withOpacity(0.1);
    } else if (widget.performance.startsWith('-')) {
      return Colors.red.withOpacity(0.1);
    } else {
      return Colors.green.withOpacity(0.1);
    }
  }

  IconData getPerformanceIcon() {
    if (widget.performance.trim() == '0' ||
        widget.performance.trim() == '0%' ||
        widget.performance.trim() == '0.0') {
      return Icons.remove;
    } else if (widget.performance.startsWith('-')) {
      return Icons.trending_down_rounded;
    } else {
      return Icons.trending_up_rounded;
    }
  }

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: widget.isWidthExpanded ? 24.0 : 16.0, vertical: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withValues(alpha: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: getPerformanceBgColor(),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6.0, vertical: 4.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            getPerformanceIcon(),
                            size: 14,
                            color: getPerformanceColor(context),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.performance,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 9,
                              color: getPerformanceColor(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14),
              SizedBox(
                child: Text(
                  widget.title,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              SizedBox(height: 8),
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
              const SizedBox(height: 14),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Lihat Detail >',
                    style: GoogleFonts.inter(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
