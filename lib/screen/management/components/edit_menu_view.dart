// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/management/components/add_option_dialog.dart';
import 'package:pos_indorep/screen/management/components/helpers/edit_menu_view_helpers.dart';
import 'package:pos_indorep/screen/management/components/helpers/image_picker_result.dart';
import 'package:pos_indorep/screen/management/components/widget/option_editor_widget.dart';
import 'package:provider/provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';

class EditMenuView extends StatefulWidget {
  final MenuIrep menu;
  final Function(bool) isMenuModified;

  const EditMenuView({
    super.key,
    required this.menu,
    required this.isMenuModified,
  });

  @override
  State<EditMenuView> createState() => _EditMenuViewState();
}

class _EditMenuViewState extends State<EditMenuView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController titleController;
  late TextEditingController categoryController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late ValueNotifier<bool> availableNotifier;
  String? imageUrl;

  List<OptionMenuIrep> localOptions = [];
  List<OptionMenuIrep> updatedOptions = [];
  List<int> deletedOptionValueIds = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  @override
  void didUpdateWidget(EditMenuView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.menu != oldWidget.menu) {
      _initializeFields();
      // _isMenuModified();
    }
  }

  void _initializeFields() {
    final NumberFormat formatter =
        NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0);
    titleController = TextEditingController(text: widget.menu.menuName);
    categoryController = TextEditingController(text: widget.menu.menuType);
    descController = TextEditingController(text: widget.menu.menuNote);
    priceController =
        TextEditingController(text: formatter.format(widget.menu.menuPrice));
    availableNotifier = ValueNotifier(widget.menu.available);
    imageUrl = widget.menu.menuImage;
    localOptions = widget.menu.option != null
        ? widget.menu.option!
            .map((option) => OptionMenuIrep(
                  available: option.available,
                  optionId: option.optionId,
                  optionName: option.optionName,
                  optionType: option.optionType,
                  optionValue: option.optionValue
                      .map((optVal) => OptionValue(
                            optionValueName: optVal.optionValueName,
                            optionValueId: optVal.optionValueId,
                            optionValuePrice: optVal.optionValuePrice,
                            isSelected: optVal.isSelected,
                          ))
                      .toList(),
                ))
            .toList()
        : [];
  }

  void _handleOptionChanged(OptionMenuIrep updatedOption) {
    setState(() {
      int index = localOptions
          .indexWhere((opt) => opt.optionId == updatedOption.optionId);
      if (index != -1) {
        localOptions[index] = updatedOption;
      }
    });
  }

  void _handleOptionValueDeleted(int optionValueId) {
    setState(() {
      deletedOptionValueIds.add(optionValueId);
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    availableNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(builder: (context, provider, child) {
      return Scaffold(
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.menu.menuId != 0
                  ? ElevatedButton(
                      onPressed: () async {
                        var res = await provider.deleteMenu(widget.menu.menuId);
                        if (res.success) {
                          provider.clearSelectedMenu();
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.redAccent),
                          SizedBox(width: 8.0),
                          Text('Hapus',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              )),
                        ],
                      ))
                  : SizedBox(),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () async {
                  context.loaderOverlay.show();
                  var mainProvider =
                      Provider.of<MainProvider>(context, listen: false);

                  AddMenuRequest newMenu = AddMenuRequest(
                    menuId: widget.menu.menuId,
                    menuType: categoryController.text,
                    menuName: titleController.text,
                    menuImage: imageUrl != null && imageUrl!.isNotEmpty
                        ? imageUrl!
                        : widget.menu.menuImage,
                    menuPrice: int.tryParse(priceController.text
                            .replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0,
                    menuNote: descController.text,
                    menuAvailable: availableNotifier.value,
                  );

                  if (widget.menu.menuId != 0) {
                    await EditMenuViewHelpers.updateMenu(
                        newMenu,
                        widget.menu.option!,
                        localOptions,
                        deletedOptionValueIds,
                        provider);
                  } else {
                    await EditMenuViewHelpers.addNewMenu(
                        newMenu, localOptions, provider);
                  }

                  provider.clearSelectedMenu();
                  context.loaderOverlay.hide();
                },
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8.0),
                    Text(widget.menu.menuId != 0 ? 'Simpan' : 'Tambah Menu',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ],
                ),
              )
            ],
          ),
        ],
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  imageUrl != null && imageUrl!.isNotEmpty
                      ? Column(
                          children: [
                            Center(
                              child: ClipOval(
                                child: Image.network(
                                  imageUrl!,
                                  height: 200,
                                  width: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default-menu.png',
                                      height: 200,
                                      width: 200,
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Align(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    String category = categoryController.text;
                                    String name = titleController.text;
                                    final image = await ImagePickerUnified
                                        .pickAndProcessImage(context);
                                    if (image != null) {
                                      final url = await ImagePickerUnified
                                          .uploadImageToFirebase(
                                              category, name, image);
                                      print("Uploaded image URL: $url");
                                      setState(() {
                                        imageUrl = url;
                                      });
                                    }
                                  },
                                  label: Text('Upload Gambar',
                                      style: GoogleFonts.inter()),
                                  icon: Icon(Icons.upload_file_rounded),
                                )),
                          ],
                        )
                      : Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Container(
                                height: 200,
                                color: Colors.black.withOpacity(0.4),
                              ),
                            ),
                            SizedBox(height: 8.0),
                            Align(
                                alignment: Alignment.center,
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    String category = categoryController.text;
                                    String name = titleController.text;
                                    final image = await ImagePickerUnified
                                        .pickAndProcessImage(context);
                                    if (image != null) {
                                      final url = await ImagePickerUnified
                                          .uploadImageToFirebase(
                                              category, name, image);
                                      print("Uploaded image URL: $url");
                                      setState(() {
                                        imageUrl = url;
                                      });
                                    }
                                  },
                                  label: Text('Upload Gambar',
                                      style: GoogleFonts.inter()),
                                  icon: Icon(Icons.upload_file_rounded),
                                )),
                          ],
                        ),
                  ValueListenableBuilder<bool>(
                    valueListenable: availableNotifier,
                    builder: (context, available, child) {
                      return SwitchListTile(
                        title: Text('Menu Tersedia',
                            style:
                                GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        value: available,
                        onChanged: (value) {
                          availableNotifier.value = value;
                        },
                      );
                    },
                  ),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(
                        labelText: 'Nama', labelStyle: GoogleFonts.inter()),
                    onSaved: (value) {
                      titleController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan nama menu';
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: categoryController.text.isNotEmpty
                        ? categoryController.text
                        : null,
                    decoration: InputDecoration(
                        labelText: 'Kategori', labelStyle: GoogleFonts.inter()),
                    items: provider.allCategories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                            category[0].toUpperCase() + category.substring(1)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoryController.text = value!;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Pilih kategori';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      categoryController.text = value!;
                    },
                  ),
                  TextFormField(
                    controller: descController,
                    decoration: InputDecoration(
                        labelText: 'Deskripsi',
                        labelStyle: GoogleFonts.inter()),
                    onSaved: (value) {
                      descController.text = value!;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan deskripsi';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                        labelText: 'Harga',
                        labelStyle: GoogleFonts.inter(),
                        counterText: ""),
                    maxLength: 8,
                    keyboardType: TextInputType.number,
                    inputFormatters: [RupiahFormatter()],
                    onSaved: (value) {
                      double rawValue = double.tryParse(
                              value!.replaceAll(RegExp(r'[^0-9]'), '')) ??
                          0.0;
                      priceController.text = rawValue.toString();
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan harga';
                      }
                      if (double.tryParse(
                              value.replaceAll(RegExp(r'[^0-9]'), '')) ==
                          null) {
                        return 'Masukkan harga yang valid';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    children: [
                      Text("Pilihan Tambahan (${localOptions.length})",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AddOptionDialog(
                                onOptionAdded: (newOption) {
                                  setState(() {
                                    localOptions.add(newOption);
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  if (localOptions.isNotEmpty) ...[
                    SizedBox(height: 8),
                    ...localOptions.map((option) {
                      return OptionEditorWidget(
                        option: option,
                        onOptionValueDeleted: _handleOptionValueDeleted,
                        onOptionChanged: _handleOptionChanged,
                        onDelete: (deletedOption) {
                          setState(() {
                            localOptions.remove(deletedOption);
                          });
                        },
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
