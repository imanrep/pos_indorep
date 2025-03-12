import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';

class OptionSelectionWidget extends StatefulWidget {
  final OptionMenuIrep option;
  final Function(OptionMenuIrep) onOptionChanged;

  const OptionSelectionWidget({
    Key? key,
    required this.option,
    required this.onOptionChanged,
  }) : super(key: key);

  @override
  _OptionSelectionWidgetState createState() => _OptionSelectionWidgetState();
}

class _OptionSelectionWidgetState extends State<OptionSelectionWidget> {
  void _handleCheckboxChanged(bool? newValue, OptionValue optionValue) {
    setState(() {
      optionValue.isSelected = newValue ?? false;
    });

    // Notify parent widget (AddItemDialog) of the change
    widget.onOptionChanged(widget.option);
  }

  void _handleRadioChanged(OptionValue selectedValue) {
    setState(() {
      for (var value in widget.option.optionValue) {
        value.isSelected = value == selectedValue;
      }
    });

    // Notify parent widget (AddItemDialog) of the change
    widget.onOptionChanged(widget.option);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.option.optionName,
            style: TextStyle(fontWeight: FontWeight.bold)),
        ...widget.option.optionValue.map((optionValue) {
          if (widget.option.optionType == "Checkbox") {
            return CheckboxListTile(
              title: Text(
                  "${optionValue.optionValueName} (+${optionValue.optionValuePrice})"),
              value: optionValue.isSelected,
              onChanged: (bool? newValue) =>
                  _handleCheckboxChanged(newValue, optionValue),
            );
          } else if (widget.option.optionType == "Radio") {
            return RadioListTile<OptionValue>(
              title: Text(
                  "${optionValue.optionValueName} (+${optionValue.optionValuePrice})"),
              value: optionValue,
              groupValue: widget.option.optionValue
                  .firstWhere((value) => value.isSelected,
                      orElse: () => OptionValue(
                            optionValueName: '',
                            optionValueId: -1,
                            optionValuePrice: 0,
                          )),
              onChanged: (OptionValue? selectedValue) {
                if (selectedValue != null) {
                  _handleRadioChanged(selectedValue);
                }
              },
            );
          }
          return SizedBox.shrink();
        }).toList(),
      ],
    );
  }
}
