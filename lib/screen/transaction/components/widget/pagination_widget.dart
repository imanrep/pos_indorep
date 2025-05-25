import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChanged;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  Widget _buildPageButton({
    required Widget child,
    required bool isActive,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? IndorepColor.primary.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? IndorepColor.primary : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: child,
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];

    // Always show page 1
    pages.add(
      _buildPageButton(
        isActive: currentPage == 1,
        onTap: currentPage == 1 ? null : () => onPageChanged(1),
        child: Text(
          '1',
          style: TextStyle(
            color: currentPage == 1 ? IndorepColor.primary : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );

    // If currentPage is far from 1, show ellipsis after page 1
    if (currentPage > 3) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '...',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Show currentPage if it's not 1 or last
    if (currentPage != 1 && currentPage != totalPages) {
      pages.add(
        _buildPageButton(
          isActive: true,
          onTap: () => onPageChanged(currentPage),
          child: Text(
            '$currentPage',
            style: TextStyle(
              color: IndorepColor.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Show up to 2 next pages after currentPage, but not beyond totalPages-1
    for (int i = 1; i <= 2; i++) {
      int page = currentPage + i;
      if (page < totalPages) {
        pages.add(
          _buildPageButton(
            isActive: false,
            onTap: () => onPageChanged(page),
            child: Text(
              '$page',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }

    // Show ellipsis if there are more pages between the last shown and the last page
    if (currentPage + 2 < totalPages - 1) {
      pages.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '...',
            style:
                TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Show last page if it's not already shown
    if (totalPages > 1 && currentPage != totalPages) {
      pages.add(
        _buildPageButton(
          isActive: false,
          onTap: () => onPageChanged(totalPages),
          child: Text(
            '$totalPages',
            style: TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildPageButton(
          isActive: false,
          onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
          child: const Icon(
            Icons.chevron_left,
            size: 20,
            color: IndorepColor.primary,
          ),
        ),
        ..._buildPageNumbers(),
        _buildPageButton(
          isActive: false,
          onTap: currentPage < totalPages
              ? () => onPageChanged(currentPage + 1)
              : null,
          child: const Icon(
            Icons.chevron_right,
            size: 20,
            color: IndorepColor.primary,
          ),
        ),
      ],
    );
  }
}
