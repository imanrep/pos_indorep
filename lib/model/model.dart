class Category {
  final String categoryId;
  final int createdAt;

  Category({
    required this.categoryId,
    required this.createdAt,
  });

  factory Category.fromMap(Map<String, dynamic> data) {
    return Category(
      categoryId: data['categoryId'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'createdAt': createdAt,
    };
  }
}

class Menu {
  final bool available;
  final String menuId;
  final String title;
  final Category category;
  final List<String> tag;
  final String image;
  final String desc;
  final double price;
  final int createdAt;
  List<Option>? option;

  Menu({
    required this.available,
    required this.menuId,
    required this.title,
    required this.category,
    required this.tag,
    required this.image,
    required this.desc,
    required this.price,
    required this.createdAt,
    this.option,
  });

  factory Menu.fromMap(Map<String, dynamic> data) {
    return Menu(
      available: data['available'],
      menuId: data['menuId'],
      title: data['title'],
      category: Category.fromMap(data['category']),
      tag: List<String>.from(data['tag']),
      image: data['image'],
      desc: data['desc'],
      price: data['price'].toDouble(),
      createdAt: data['createdAt'],
      option: data['option'] != null
          ? List<Option>.from(
              data['option'].map((x) => Option.fromMap(x)).toList())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'available': available,
      'menuId': menuId,
      'title': title,
      'category': category.toMap(),
      'tag': tag,
      'image': image,
      'desc': desc,
      'price': price,
      'createdAt': createdAt,
      'option': option?.map((opt) => opt.toMap()).toList(),
    };
  }
}

class Option {
  final String optionId;
  final String title;
  final String type;
  final List<String> options;

  Option({
    required this.optionId,
    required this.title,
    required this.type,
    required this.options,
  });

  factory Option.fromMap(Map<String, dynamic> data) {
    return Option(
      optionId: data['optionId'],
      title: data['title'],
      type: data['type'],
      options: List<String>.from(data['options']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'optionId': optionId,
      'title': title,
      'type': type,
      'options': options,
    };
  }
}

class SelectedOption {
  final String selectedOptionId;
  final String title;
  final String selected;

  SelectedOption({
    required this.selectedOptionId,
    required this.title,
    required this.selected,
  });
}

class Cart extends Menu {
  final String cartId;
  final int createdAt;
  int qty;
  String notes;
  SelectedOption? selectedOption;
  double subTotal;

  Cart({
    required this.cartId,
    required this.createdAt,
    required bool available,
    required String menuId,
    required String title,
    required Category category,
    required List<String> tag,
    required String image,
    required String desc,
    required double price,
    List<Option>? option,
    this.qty = 1,
    this.notes = '',
    this.selectedOption,
  })  : subTotal = price * qty,
        super(
          available: available,
          createdAt: createdAt,
          menuId: menuId,
          title: title,
          category: category,
          tag: tag,
          image: image,
          desc: desc,
          price: price,
          option: option,
        );

  void updateQty(int newQty) {
    qty = newQty;
    subTotal = price * qty;
  }
}
