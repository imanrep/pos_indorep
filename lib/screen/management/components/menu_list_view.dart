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
          leading: CircleAvatar(
            backgroundColor: Colors.transparent,
            child: Image.network(
              item.menuImage,
              height: 100,
              width: double.infinity,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  'assets/images/default-menu.png', // Your default image path
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.fitHeight,
                );
              },
            ),
          ),
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
