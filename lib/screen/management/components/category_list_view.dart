import 'package:flutter/material.dart';
import 'package:pos_indorep/screen/management/components/category_card.dart';

class CategoryListView extends StatelessWidget {
  final List<String> categories;
  final Function(String) onCategoryTap;

  const CategoryListView({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 45.0, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: CategoryCard(
              category: category,
              onTap: () => onCategoryTap(category),
            ),
          );
        },
      ),
    );
  }
}
