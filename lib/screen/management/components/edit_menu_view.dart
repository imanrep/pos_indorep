import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_indorep/model/model.dart';
import 'package:provider/provider.dart';
import 'package:pos_indorep/provider/menu_provider.dart';
import 'package:uuid/uuid.dart';

class EditMenuView extends StatefulWidget {
  final Menu menu;

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
  late TextEditingController tagController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late ValueNotifier<bool> availableNotifier;
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
    titleController = TextEditingController(text: widget.menu.title);
    categoryController =
        TextEditingController(text: widget.menu.category.categoryId);
    tagController = TextEditingController(text: widget.menu.tag.join(', '));
    descController = TextEditingController(text: widget.menu.desc);
    priceController = TextEditingController(text: widget.menu.price.toString());
    availableNotifier = ValueNotifier(widget.menu.available);
    imageUrl = widget.menu.image;
  }

  @override
  void dispose() {
    titleController.dispose();
    tagController.dispose();
    descController.dispose();
    priceController.dispose();
    availableNotifier.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final fileName = pickedFile.name;
      final storageRef =
          FirebaseStorage.instance.ref().child('menu_images/$fileName');
      final uploadTask = storageRef.putFile(file);
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint(downloadUrl);
      setState(() {
        imageUrl = downloadUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MenuProvider>(builder: (context, provider, child) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                imageUrl != null && imageUrl!.isNotEmpty
                    ? Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            imageUrl!,
                            height: 200,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Container(
                          height: 200,
                          color: Colors.grey[200],
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.upload_file_rounded),
                                  onPressed: _pickImage,
                                  iconSize: 34,
                                ),
                                Text('Tambah Gambar'),
                              ],
                            ),
                          ),
                        ),
                      ),
                ValueListenableBuilder<bool>(
                  valueListenable: availableNotifier,
                  builder: (context, available, child) {
                    return SwitchListTile(
                      title: Text('Aktif'),
                      value: available,
                      onChanged: (value) {
                        availableNotifier.value = value;
                      },
                    );
                  },
                ),
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                  onSaved: (value) {
                    titleController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: categoryController.text.isNotEmpty
                      ? categoryController.text
                      : null,
                  decoration: InputDecoration(labelText: 'Category'),
                  items: provider.allCategories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.categoryId,
                      child: Text(category.categoryId[0].toUpperCase() +
                          category.categoryId.substring(1)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      categoryController.text = value!;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    categoryController.text = value!;
                  },
                ),
                TextFormField(
                  controller: tagController,
                  decoration:
                      InputDecoration(labelText: 'Tags (comma separated)'),
                  onSaved: (value) {
                    tagController.text = value!;
                  },
                ),
                TextFormField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                  onSaved: (value) {
                    descController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) {
                    priceController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          String menuId = Uuid().v4();
                          _formKey.currentState!.save();
                          debugPrint(widget.menu.menuId);
                          debugPrint(widget.menu.category.categoryId);
                          Menu currentMenu = Menu(
                            available: availableNotifier.value,
                            createdAt: DateTime.now().millisecondsSinceEpoch,
                            menuId: menuId,
                            title: titleController.text,
                            category: Category(
                              categoryId: categoryController.text,
                              createdAt: widget.menu.category.createdAt,
                            ),
                            tag: tagController.text
                                .split(',')
                                .map((e) => e.trim())
                                .toList(),
                            image: imageUrl ?? '',
                            desc: descController.text,
                            price: double.parse(priceController.text),
                            option: widget.menu.option,
                          );
                          provider.addMenu(currentMenu);
                        }
                      },
                      child: Text('Simpan'),
                    ),
                    ElevatedButton(
                        onPressed: () async {
                          await provider.deleteMenu(widget.menu);
                          provider.clearSelectedMenu();
                        },
                        child: Text('Hapus')),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
