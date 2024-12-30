import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';

class MenuListView extends StatelessWidget {
  final List<Menu> menus;
  final Function(Menu) onItemTap;

  const MenuListView({
    super.key,
    required this.menus,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(8.0),
      itemCount: menus.length,
      itemBuilder: (context, index) {
        final item = menus[index];
        return ListTile(
          onTap: () => onItemTap(item),
          title: Text(item.title),
          subtitle: Text(Helper.rupiahFormatter(item.price)),
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(item.image)),
        );
      },
    );
  }
}
