import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/provider/web/warnet_dashboard_provider.dart';
import 'package:provider/provider.dart';

class WebDashboardCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  // final String performance;
  final IconData? icon;
  final bool isWidthExpanded;
  final VoidCallback? onTap;
  const WebDashboardCard({
    super.key,
    required this.title,
    this.subtitle,
    // required this.performance,
    this.icon,
    required this.isWidthExpanded,
    this.onTap,
  });

  @override
  State<WebDashboardCard> createState() => _WebDashboardCardState();
}

class _WebDashboardCardState extends State<WebDashboardCard> {
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Card(
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: widget.isWidthExpanded ? 12.0 : 12.0,
                vertical: 12.0),
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
                        color: IndorepColor.primary.withValues(alpha: 0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          widget.icon,
                          size: 24,
                          color: IndorepColor.primary,
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
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Consumer<WarnetDashboardProvider>(
                    builder: (context, provider, child) {
                  return provider.isSummaryItemLoading
                      ? CupertinoActivityIndicator()
                      : SizedBox(
                          child: Text(
                            widget.subtitle ?? 'Tidak ada data tersedia',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        );
                }),
                const SizedBox(height: 14),
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        icon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lihat Detail',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              FluentIcons.open_in_new_window,
                              size: 18,
                            ),
                          ],
                        ),
                        onPressed: () {
                          if (widget.onTap != null) {
                            widget.onTap!();
                          } else {
                            null;
                          }
                        })),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
