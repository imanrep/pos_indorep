import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:provider/provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildCategoryButton(context, menuProvider, "All"),
            ...menuProvider.allCategories.map((category) {
              return _buildCategoryButton(context, menuProvider, category);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryButton(
      BuildContext context, MenuProvider menuProvider, String category) {
    bool isSelected = menuProvider.selectedCategory == category;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: OutlinedButton(
        onPressed: () {
          menuProvider.filterMenusByCategory(category);
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected
              ? Colors.deepPurple
              : Colors.transparent, // Fill color if selected
          foregroundColor:
              isSelected ? Colors.white : IndorepColor.primary, // Text color
          side: BorderSide(color: IndorepColor.primary), // Border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        child: Text(
          category[0].toUpperCase() + category.substring(1),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
