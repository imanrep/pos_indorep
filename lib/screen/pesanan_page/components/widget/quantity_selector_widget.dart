import 'package:flutter/material.dart';

class QuantitySelectorWidget extends StatefulWidget {
  final int initialQty;
  final Function(int) onQtyChanged;

  const QuantitySelectorWidget({
    Key? key,
    this.initialQty = 1,
    required this.onQtyChanged,
  }) : super(key: key);

  @override
  _QuantitySelectorWidgetState createState() => _QuantitySelectorWidgetState();
}

class _QuantitySelectorWidgetState extends State<QuantitySelectorWidget> {
  late TextEditingController _controller;
  late int qty;

  @override
  void initState() {
    super.initState();
    qty = widget.initialQty;
    _controller = TextEditingController(text: qty.toString());
  }

  void _updateQty(int newQty) {
    if (newQty < 1) return;
    if (newQty > 99) return;

    setState(() {
      qty = newQty;
      _controller.text = qty.toString();
      widget.onQtyChanged(qty);
    });
  }

  void _onTextChanged(String value) {
    int? newQty = int.tryParse(value);
    if (newQty != null) {
      if (newQty < 1) {
        _updateQty(1);
      } else if (newQty > 99) {
        _updateQty(99);
      } else {
        _updateQty(newQty);
      }
    } else {
      _controller.text = qty.toString(); // Revert if invalid
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.remove, color: Colors.redAccent),
            onPressed: () => _updateQty(qty - 1),
          ),

          SizedBox(
            width: 20,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: _onTextChanged,
              decoration: InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),

          // Plus button
          IconButton(
            icon: Icon(Icons.add, color: Colors.green),
            onPressed: () => _updateQty(qty + 1),
          ),
        ],
      ),
    );
  }
}
