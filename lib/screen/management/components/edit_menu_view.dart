// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:pos_indorep/helper/helper.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:pos_indorep/provider/main_provider.dart';
import 'package:pos_indorep/screen/management/components/add_option_dialog.dart';
import 'package:pos_indorep/screen/management/components/widget/option_editor_widget.dart';
import 'package:provider/provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:collection/collection.dart';

class EditMenuView extends StatefulWidget {
  final MenuIrep menu;

  const EditMenuView({
    super.key,
    required this.menu,
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
  late List<OptionMenuIrep> localOptions;
  String? imageUrl;

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

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    priceController.dispose();
    availableNotifier.dispose();
    super.dispose();
  }

  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);

  //   if (pickedFile != null) {
  //     final file = File(pickedFile.path);
  //     final fileName = pickedFile.name;
  //     final storageRef =
  //         FirebaseStorage.instance.ref().child('menu_images/$fileName');
  //     final uploadTask = storageRef.putFile(file);
  //     final snapshot = await uploadTask.whenComplete(() => {});
  //     final downloadUrl = await snapshot.ref.getDownloadURL();
  //     debugPrint(downloadUrl);
  //     setState(() {
  //       imageUrl = downloadUrl;
  //     });
  //   }
  // }

  Future<void> _updateMenu(AddMenuRequest newMenu,
      List<OptionMenuIrep> originalOptions, MenuProvider provider) async {
    EditMenuResponse res = await provider.editMenu(newMenu);
    if (res.success) {
      _handleOptions(originalOptions, provider);
    }
  }

  Future<void> _addNewMenu(
      AddMenuRequest newMenu, MenuProvider provider) async {
    AddMenuResponse res = await provider.addMenu(newMenu);
    if (res.success) {
      _addOptionsToMenu(res.menuId, provider);
    }
  }

  void _handleOptions(
      List<OptionMenuIrep> originalOptions, MenuProvider provider) {
    List<OptionMenuIrep> newOptions = _getNewOptions(originalOptions, provider);
    List<OptionMenuIrep> editedOptions = _getEditedOptions(originalOptions);
    List<OptionMenuIrep> deletedOptions = _getDeletedOptions(originalOptions);

    // Process deletions
    for (var option in deletedOptions) {
      provider.deleteOption(option.optionId);
    }

    // Process new additions
    for (var option in newOptions) {
      _addOptionToMenu(widget.menu.menuId, option, provider);
    }

    // Process edits
    for (var option in editedOptions) {
      _editOption(option, provider);
    }
  }

  List<OptionMenuIrep> _getNewOptions(
      List<OptionMenuIrep> originalOptions, MenuProvider provider) {
    return localOptions
        .where((option) =>
            !originalOptions.any((orig) => orig.optionId == option.optionId))
        .toList();
  }

  List<OptionMenuIrep> _getEditedOptions(List<OptionMenuIrep> originalOptions) {
    return localOptions.where((option) {
      OptionMenuIrep? original = originalOptions
          .firstWhereOrNull((orig) => orig.optionId == option.optionId);

      if (original == null) return false;

      return original.optionName != option.optionName ||
          original.optionType != option.optionType ||
          original.available != option.available;
    }).toList();
  }

  List<OptionMenuIrep> _getDeletedOptions(
      List<OptionMenuIrep> originalOptions) {
    return originalOptions
        .where((original) => !localOptions
            .any((current) => current.optionId == original.optionId))
        .toList();
  }

  Future<void> _addOptionsToMenu(int menuId, MenuProvider provider) async {
    for (var option in localOptions) {
      await _addOptionToMenu(menuId, option, provider);
    }
  }

  Future<void> _addOptionToMenu(
      int menuId, OptionMenuIrep option, MenuProvider provider) async {
    AddOptionResponse res = await provider.addOption(AddOptionRequest(
      menuId: menuId,
      optionName: option.optionName,
      optionType: option.optionType,
      optionAvailable: option.available,
    ));

    if (res.success) {
      for (var optVal in option.optionValue) {
        await provider.addOptionValue(AddOptionValueRequest(
          menuOptionId: menuId,
          optionValueName: optVal.optionValueName,
          amount: optVal.optionValuePrice,
        ));
      }
    }
  }

  Future<void> _editOption(OptionMenuIrep option, MenuProvider provider) async {
    await provider.editOption(EditOptionRequest(
      id: option.optionId,
      optionName: option.optionName,
      optionType: option.optionType,
      optionAvailable: option.available,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(builder: (context, provider, child) {
      return Scaffold(
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
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
                  )),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () async {
                  context.loaderOverlay.show();
                  print(widget.menu.menuId);
                  var mainProvider =
                      Provider.of<MainProvider>(context, listen: false);

                  AddMenuRequest newMenu = AddMenuRequest(
                    menuId: widget.menu.menuId,
                    menuType: categoryController.text,
                    menuName: titleController.text,
                    menuImage:
                        titleController.text.toLowerCase().replaceAll(' ', '-'),
                    menuPrice: int.tryParse(priceController.text
                            .replaceAll(RegExp(r'[^0-9]'), '')) ??
                        0,
                    menuNote: descController.text,
                    menuAvailable: availableNotifier.value,
                  );

                  List<OptionMenuIrep> originalOptions =
                      widget.menu.option ?? [];

                  if (widget.menu.menuId != 0) {
                    await _updateMenu(newMenu, originalOptions, provider);
                  } else {
                    await _addNewMenu(newMenu, provider);
                  }

                  provider.clearSelectedMenu();
                  context.loaderOverlay.hide();
                },
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8.0),
                    Text('Simpan',
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
                      ? Center(
                          child: Image.network(
                            widget.menu.menuImage,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.fitHeight,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/default-menu.png',
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.fitHeight,
                              );
                            },
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Container(
                            height: 200,
                            color: Colors.black.withOpacity(0.4),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.upload_file_rounded),
                                    onPressed: () {},
                                    iconSize: 34,
                                  ),
                                  Text('Tambah Gambar',
                                      style: GoogleFonts.inter()),
                                ],
                              ),
                            ),
                          ),
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
                        labelText: 'Harga', labelStyle: GoogleFonts.inter()),
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
