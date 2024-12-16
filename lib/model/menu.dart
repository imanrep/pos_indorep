class Menu {
  final String title;
  final String category;
  final List<String> tag;
  final String image;
  final String desc;
  final int price;
  Option? option;

  Menu({
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
  final String title;
  final List<String> options;

  Option({
    required this.title,
    required this.options,
  });
}
