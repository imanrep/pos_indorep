import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/screen/management/components/edit_option_dialog.dart';

class OptionEditorWidget extends StatefulWidget {
  final OptionMenuIrep option;
  final Function(OptionMenuIrep) onOptionChanged;
  final Function(int) onOptionValueDeleted;
  final Function(OptionMenuIrep) onDelete;

  const OptionEditorWidget({
    Key? key,
    required this.option,
    required this.onOptionChanged,
    required this.onOptionValueDeleted,
    required this.onDelete,
  }) : super(key: key);

  @override
  _OptionEditorWidgetState createState() => _OptionEditorWidgetState();
}

class _OptionEditorWidgetState extends State<OptionEditorWidget> {
  String optionTypeString() {
    if (widget.option.optionType == "Checkbox") {
      return "Opsional";
    } else if (widget.option.optionType == "Radio") {
      return "Wajib";
    } else {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                  '${widget.option.optionName} - ${optionTypeString()} (${widget.option.optionValue.length})',
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return EditOptionDialog(
                          onOptionValueDeleted: (int optionValueId) {
                            widget.onOptionValueDeleted(optionValueId);
                          },
                          option: widget.option,
                          onOptionChanged: (OptionMenuIrep option) {
                            widget.onOptionChanged(option);
                          },
                        );
                      },
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  widget.onDelete(widget.option);
                },
              ),
            ],
          ),
          ...widget.option.optionValue.map((optionValue) {
            if (widget.option.optionType == "Checkbox") {
              return ListTile(
                leading: Icon(Icons.check_box_outline_blank_rounded),
                title: Text(
                    "${optionValue.optionValueName} (+${Helper.rupiahFormatter(optionValue.optionValuePrice.toDouble())})",
                    style: GoogleFonts.inter(fontSize: 14)),
              );
            } else if (widget.option.optionType == "Radio") {
              return ListTile(
                leading: Icon(Icons.radio_button_off_rounded),
                title: Text(
                    "${optionValue.optionValueName} (+${Helper.rupiahFormatter(optionValue.optionValuePrice.toDouble())})",
                    style: GoogleFonts.inter(fontSize: 14)),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
