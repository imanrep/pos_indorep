import 'package:pos_indorep/model/model.dart';

class ExampleData {
  List<Menu> exampleMenu = [
    Menu(
        available: true,
        menuId: 'MAK1',
        title: 'Bakmie Ayam Jawa Spesial Telur',
        category: 'Makanan',
        tag: ['Mie'],
        image:
            'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
        desc: 'Description for Menu 1',
        price: 10000,
        option: [
          Option(
            optionId: 'O1',
            title: 'Level Pedas',
            type: 'radio',
            options: ['1', '2', '3'],
          ),
        ]),
    Menu(
        available: true,
        menuId: 'MAK2',
        title: 'Nasi Goreng Bu Indah',
        category: 'Makanan',
        tag: ['Nasi'],
        image:
            'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
        desc: 'Description for Menu 2',
        price: 20000,
        option: [
          Option(
            optionId: 'O1',
            title: 'Level Pedas',
            type: 'radio',
            options: ['1', '2', '3'],
          ),
        ]),
    Menu(
        available: true,
        menuId: 'MAK3',
        title: 'Ayam Geprek',
        category: 'Makanan',
        tag: ['Ayam'],
        image:
            'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
        desc: 'Description for Menu 3',
        price: 30000,
        option: [
          Option(
            optionId: 'O1',
            title: 'Level Pedas',
            type: 'radio',
            options: ['1', '2', '3'],
          ),
        ]),
    Menu(
      available: true,
      menuId: 'MAK4',
      title: 'Pempek Palembang Khas Banyuwangi',
      category: 'Makanan',
      tag: ['Cemilan'],
      image:
          'https://www.bakmigm.com/cfind/source/thumb/images/menu/cover_w480_h480_1-bakmi-ayam.png',
      desc: 'Description for Menu 3',
      price: 30000,
    ),
  ];
}
