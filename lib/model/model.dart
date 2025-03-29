import 'package:pos_indorep/services/irepbe_services.dart';

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

  OptionValue copyWith({String? optionValueName, int? optionValuePrice}) {
    return OptionValue(
      optionValueName: optionValueName ?? this.optionValueName,
      optionValueId: optionValueId,
      optionValuePrice: optionValuePrice ?? this.optionValuePrice,
      isSelected: isSelected,
    );
  }

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

  OptionMenuIrep copyWith({
    bool? available,
    int? optionId,
    String? optionName,
    String? optionType,
    List<OptionValue>? optionValue,
  }) {
    return OptionMenuIrep(
      available: available ?? this.available,
      optionId: optionId ?? this.optionId,
      optionName: optionName ?? this.optionName,
      optionType: optionType ?? this.optionType,
      optionValue: optionValue ?? this.optionValue,
    );
  }

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

  factory MenuIrep.fromMap(Map<String, dynamic> data, String baseUrl) {
    return MenuIrep(
      menuType: data['menu_type'],
      menuName: data['menu_name'],
      menuImage: '$baseUrl/pic/${data['menu_image']}.png',
      menuPrice: data['menu_price'],
      menuId: data['menu_id'],
      menuNote: data['menu_note'],
      available: data['available'],
      option: data['option'] != null
          ? List<OptionMenuIrep>.from(
              data['option'].map((x) => OptionMenuIrep.fromMap(x)),
            )
          : null,
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
  double addOnPrice = 0;
  List<OrderItem> orderItem = [];

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
    _addOrderItem();
    _calculateSubTotal();
  }

  /// **Recalculate subtotal including selected add-ons**
  void _calculateSubTotal() {
    addOnPrice = selectedOptions
        .expand((option) => option.optionValue)
        .where((optVal) => optVal.isSelected)
        .fold(0, (sum, optVal) => sum + optVal.optionValuePrice);

    subTotal = (menuPrice.toDouble() + addOnPrice) * qty;
  }

  void _addOrderItem() {
    orderItem = selectedOptions
        .expand((option) => option.optionValue)
        .where((optVal) => optVal.isSelected)
        .map((optVal) => OrderItem(
              id: optVal.optionValueId,
              qty: qty,
              note: notes,
            ))
        .toList();
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

class QrisOrderResponse {
  final String message;
  final int orderID;
  final String qris;
  final bool success;
  final int total;

  QrisOrderResponse({
    required this.message,
    required this.orderID,
    required this.qris,
    required this.success,
    required this.total,
  });

  factory QrisOrderResponse.fromJson(Map<String, dynamic> json) {
    return QrisOrderResponse(
      message: json['message'],
      orderID: json['orderID'],
      qris: json['qris'],
      success: json['success'],
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'orderID': orderID,
      'qris': qris,
      'success': success,
      'total': total,
    };
  }
}

class OrderItem {
  final int id;
  final int qty;
  final String note;

  OrderItem({
    required this.id,
    required this.qty,
    required this.note,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      qty: json['qty'],
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qty': qty,
      'note': note,
    };
  }
}

class QrisOrderRequest {
  final List<OrderItem> orders;
  final String payment;
  final String source;

  QrisOrderRequest({
    required this.orders,
    required this.payment,
    required this.source,
  });

  factory QrisOrderRequest.fromJson(Map<String, dynamic> json) {
    return QrisOrderRequest(
      orders: (json['orders'] as List<dynamic>)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      payment: json['payment'],
      source: json['source'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders.map((order) => order.toJson()).toList(),
      'payment': payment,
      'source': source,
    };
  }
}

class AddMenuRequest {
  int? menuId;
  final String menuType;
  final String menuName;
  final String menuImage;
  final int menuPrice;
  final String menuNote;
  final bool menuAvailable;

  AddMenuRequest({
    this.menuId = 0,
    required this.menuType,
    required this.menuName,
    required this.menuImage,
    required this.menuPrice,
    required this.menuNote,
    required this.menuAvailable,
  });

  factory AddMenuRequest.fromJson(Map<String, dynamic> json) {
    return AddMenuRequest(
      menuId: json['menu_id'],
      menuType: json['menu_type'],
      menuName: json['menu_name'],
      menuImage: json['menu_image'],
      menuPrice: json['menu_price'],
      menuNote: json['menu_note'],
      menuAvailable: json['menu_available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'menu_type': menuType,
      'menu_name': menuName,
      'menu_image': menuImage,
      'menu_price': menuPrice,
      'menu_note': menuNote,
      'menu_available': menuAvailable,
    };
  }
}

class AddMenuResponse {
  final int menuId;
  final String message;
  final bool success;

  AddMenuResponse({
    required this.menuId,
    required this.message,
    required this.success,
  });

  factory AddMenuResponse.fromJson(Map<String, dynamic> json) {
    return AddMenuResponse(
      menuId: json['menu_id'],
      message: json['message'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'message': message,
      'success': success,
    };
  }
}

class EditMenuResponse {
  final String message;
  final bool success;

  EditMenuResponse({
    required this.message,
    required this.success,
  });

  factory EditMenuResponse.fromJson(Map<String, dynamic> json) {
    return EditMenuResponse(
      message: json['message'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}

class AddOptionRequest {
  int? menuId;
  final String optionName;
  final String optionType;
  final bool optionAvailable;

  AddOptionRequest({
    this.menuId = 0,
    required this.optionName,
    required this.optionType,
    required this.optionAvailable,
  });

  factory AddOptionRequest.fromJson(Map<String, dynamic> json) {
    return AddOptionRequest(
      menuId: json['menu_id'],
      optionName: json['option_name'],
      optionType: json['option_type'],
      optionAvailable: json['option_available'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'option_name': optionName,
      'option_type': optionType,
      'option_available': optionAvailable,
    };
  }
}

class AddOptionResponse {
  final String message;
  final int optionId;
  final bool success;

  AddOptionResponse({
    required this.message,
    required this.optionId,
    required this.success,
  });

  factory AddOptionResponse.fromJson(Map<String, dynamic> json) {
    return AddOptionResponse(
      message: json['message'],
      optionId: json['option_id'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'option_id': optionId,
      'success': success,
    };
  }
}

class AddOptionValueRequest {
  final int menuOptionId;
  final String optionValueName;
  final int amount;

  AddOptionValueRequest({
    required this.menuOptionId,
    required this.optionValueName,
    required this.amount,
  });

  factory AddOptionValueRequest.fromJson(Map<String, dynamic> json) {
    return AddOptionValueRequest(
      menuOptionId: json['menu_option_id'],
      optionValueName: json['option_value_name'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_option_id': menuOptionId,
      'option_value_name': optionValueName,
      'amount': amount,
    };
  }
}

class EditOptionRequest {
  final int id;
  final String optionName;
  final String optionType;
  final bool optionAvailable;

  EditOptionRequest({
    required this.id,
    required this.optionName,
    required this.optionType,
    required this.optionAvailable,
  });

  factory EditOptionRequest.fromJson(Map<String, dynamic> json) {
    return EditOptionRequest(
      id: json['id'],
      optionName: json['option_name'],
      optionType: json['option_type'],
      optionAvailable: json['option_available'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_name': optionName,
      'option_type': optionType,
      'option_available': optionAvailable,
    };
  }
}

class EditOptionValueRequest {
  final int id;
  final String optionValueName;
  final int amount;

  EditOptionValueRequest({
    required this.id,
    required this.optionValueName,
    required this.amount,
  });

  factory EditOptionValueRequest.fromJson(Map<String, dynamic> json) {
    return EditOptionValueRequest(
      id: json['id'],
      optionValueName: json['option_value_name'],
      amount: json['amount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'option_value_name': optionValueName,
      'amount': amount,
    };
  }
}

class AddOptionValueResponse {
  final String message;
  final bool success;

  AddOptionValueResponse({
    required this.message,
    required this.success,
  });

  factory AddOptionValueResponse.fromJson(Map<String, dynamic> json) {
    return AddOptionValueResponse(
      message: json['message'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}

class DefaultResponse {
  final String message;
  final bool success;

  DefaultResponse({
    required this.message,
    required this.success,
  });

  factory DefaultResponse.fromJson(Map<String, dynamic> json) {
    return DefaultResponse(
      message: json['message'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'success': success,
    };
  }
}
