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

class OptionValue {
  final String optionValueName;
  final int optionValueId;
  final int optionValuePrice;
  bool isSelected;

  OptionValue({
    required this.optionValueName,
    required this.optionValueId,
    required this.optionValuePrice,
    this.isSelected = false,
  });

  factory OptionValue.fromMap(Map<String, dynamic> data) {
    return OptionValue(
      optionValueName: data['option_value_name'],
      optionValueId: data['option_value_name_id'],
      optionValuePrice: data['option_value_price'],
      isSelected: false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'option_value_name': optionValueName,
      'option_value_name_id': optionValueId,
      'option_value_price': optionValuePrice,
    };
  }
}

class OptionMenuIrep {
  final String optionName;
  final List<OptionValue> optionValue;
  final int optionId;
  final String optionType;
  final bool available;
  bool isSelected = false;

  // New properties for tracking selections
  OptionValue? selectedValue; // For radio-type options
  List<OptionValue> selectedValues = []; // For checkbox-type options

  OptionMenuIrep({
    required this.optionName,
    required this.optionValue,
    required this.optionId,
    required this.optionType,
    required this.available,
    this.selectedValue,
    List<OptionValue>? selectedValues,
  }) : selectedValues = selectedValues ?? [];

  factory OptionMenuIrep.fromMap(Map<String, dynamic> data) {
    return OptionMenuIrep(
      optionName: data['option_name'],
      optionValue: List<OptionValue>.from(
          data['option_value'].map((x) => OptionValue.fromMap(x))),
      optionId: data['option_id'],
      optionType: data['option_type'],
      available: data['available'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'option_name': optionName,
      'option_value': optionValue.map((x) => x.toMap()).toList(),
      'option_id': optionId,
      'option_type': optionType,
      'available': available,
      'selected_value': selectedValue?.toMap(),
      'selected_values': selectedValues.map((x) => x.toMap()).toList(),
    };
  }
}

class MenuIrep {
  final String menuType;
  final String menuName;
  final String menuImage;
  final int menuPrice;
  final int menuId;
  final String menuNote;
  final bool available;
  final List<OptionMenuIrep>? option;

  MenuIrep({
    required this.menuType,
    required this.menuName,
    required this.menuImage,
    required this.menuPrice,
    required this.menuId,
    required this.menuNote,
    required this.available,
    required this.option,
  });

  factory MenuIrep.fromMap(Map<String, dynamic> data) {
    const String baseUrl = 'http://192.168.5.254:8085/pic/';
    return MenuIrep(
      menuType: data['menu_type'],
      menuName: data['menu_name'],
      menuImage: '${baseUrl + data['menu_image']}.png',
      menuPrice: data['menu_price'],
      menuId: data['menu_id'],
      menuNote: data['menu_note'],
      available: data['available'],
      option: List<OptionMenuIrep>.from(
          data['option'].map((x) => OptionMenuIrep.fromMap(x))),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'menu_type': menuType,
      'menu_name': menuName,
      'menu_image': menuImage,
      'menu_price': menuPrice,
      'menu_id': menuId,
      'menu_note': menuNote,
      'available': available,
      'option': option?.map((x) => x.toMap()).toList(),
    };
  }
}

class CartItem extends MenuIrep {
  final String cartId;
  final int createdAt;
  int qty;
  String notes;
  double subTotal;
  double addOnPrice = 0; // Store additional price from selected options

  // Store selected options
  List<OptionMenuIrep> selectedOptions;

  CartItem({
    required this.cartId,
    required this.createdAt,
    required bool available,
    required int menuId,
    required String title,
    required String category,
    required String image,
    required String desc,
    required double price,
    List<OptionMenuIrep>? option,
    List<OptionMenuIrep>? selectedOptions,
    this.qty = 1,
    this.notes = '',
  })  : subTotal = price * qty,
        selectedOptions = selectedOptions ?? [],
        super(
          menuType: category,
          menuName: title,
          menuImage: image,
          menuPrice: price.toInt(),
          menuId: menuId,
          menuNote: desc,
          available: available,
          option: option ?? [],
        ) {
    _calculateSubTotal(); // Calculate subtotal including add-ons
  }

  /// **Recalculate subtotal including selected add-ons**
  void _calculateSubTotal() {
    addOnPrice = selectedOptions
        .expand((option) => option.optionValue)
        .where((optVal) => optVal.isSelected)
        .fold(0, (sum, optVal) => sum + optVal.optionValuePrice);

    subTotal = (menuPrice.toDouble() + addOnPrice) * qty;
  }

  /// **Update quantity and recalculate subtotal**
  void updateQty(int newQty) {
    qty = newQty;
    _calculateSubTotal();
  }

  /// **Update selected options and recalculate subtotal**
  void updateSelectedOptions(List<OptionMenuIrep> newOptions) {
    selectedOptions = newOptions;
    _calculateSubTotal();
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      cartId: data['cartId'],
      createdAt: data['createdAt'],
      available: data['available'],
      menuId: data['menuId'],
      title: data['title'],
      category: data['category'],
      image: data['image'],
      desc: data['desc'],
      price: data['price'].toDouble(),
      qty: data['qty'],
      notes: data['notes'],
      selectedOptions: List<OptionMenuIrep>.from(
        (data['selectedOptions'] ?? []).map((x) => OptionMenuIrep.fromMap(x)),
      ),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'cartId': cartId,
      'createdAt': createdAt,
      'available': available,
      'menuId': menuId,
      'title': menuName,
      'category': menuType,
      'image': menuImage,
      'desc': menuNote,
      'price': menuPrice,
      'qty': qty,
      'notes': notes,
      'selectedOptions': selectedOptions.map((x) => x.toMap()).toList(),
      'subTotal': subTotal,
      'addOnPrice': addOnPrice, // Store add-on price separately
    };
  }
}

class TransactionModel {
  final String nama;
  final String transactionId;
  final int transactionDate;
  final List<CartItem> cart;
  final double total;
  final String paymentMethod;
  TransactionModel({
    required this.nama,
    required this.transactionId,
    required this.transactionDate,
    required this.cart,
    required this.total,
    required this.paymentMethod,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> data) {
    return TransactionModel(
      nama: data['nama'],
      transactionId: data['transactionId'],
      transactionDate: data['transactionDate'],
      cart: List<CartItem>.from(
          data['cart'].map((x) => CartItem.fromMap(x)).toList()),
      total: data['total'].toDouble(),
      paymentMethod: data['paymentMethod'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'transactionId': transactionId,
      'transactionDate': transactionDate,
      'cart': cart.map((x) => x.toMap()).toList(),
      'total': total,
      'paymentMethod': paymentMethod,
    };
  }
}
