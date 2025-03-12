import 'package:flutter/material.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';

class MenuListView extends StatelessWidget {
  final List<MenuIrep> menus;
  final Function(MenuIrep) onItemTap;

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
          title: Text(item.menuName),
          subtitle: Text(Helper.rupiahFormatter(item.menuPrice.toDouble())),
          leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(item.menuImage)),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
