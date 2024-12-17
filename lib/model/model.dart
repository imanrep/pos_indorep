class Menu {
  final String menuId;
  final String title;
  final String category;
  final List<String> tag;
  final String image;
  final String desc;
  final double price;
  List<Option>? option;

  Menu({
    required this.menuId,
    required this.title,
    required this.category,
    required this.tag,
    required this.image,
    required this.desc,
    required this.price,
    this.option,
  });
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
  int qty;
  String notes;
  SelectedOption? selectedOption;
  double subTotal;

  Cart({
    required this.cartId,
    required String menuId,
    required String title,
    required String category,
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
