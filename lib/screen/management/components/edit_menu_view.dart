import 'package:flutter/material.dart';
import 'package:pos_indorep/model/model.dart';

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
  late TextEditingController imageController;
  late TextEditingController descController;
  late TextEditingController priceController;
  late ValueNotifier<bool> availableNotifier;

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
    categoryController = TextEditingController(text: widget.menu.category);
    tagController = TextEditingController(text: widget.menu.tag.join(', '));
    imageController = TextEditingController(text: widget.menu.image);
    descController = TextEditingController(text: widget.menu.desc);
    priceController = TextEditingController(text: widget.menu.price.toString());
    availableNotifier = ValueNotifier(widget.menu.available);
  }

  @override
  void dispose() {
    titleController.dispose();
    categoryController.dispose();
    tagController.dispose();
    imageController.dispose();
    descController.dispose();
    priceController.dispose();
    availableNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: availableNotifier,
                builder: (context, available, child) {
                  return SwitchListTile(
                    title: Text('Available'),
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
              TextFormField(
                controller: categoryController,
                decoration: InputDecoration(labelText: 'Category'),
                onSaved: (value) {
                  categoryController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a category';
                  }
                  return null;
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
                controller: imageController,
                decoration: InputDecoration(labelText: 'Image URL'),
                onSaved: (value) {
                  imageController.text = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
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
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    // Call the onSave callback with the updated menu
                    // widget.onSave(Menu(
                    //   available: availableNotifier.value,
                    //   menuId: widget.menu.menuId,
                    //   title: titleController.text,
                    //   category: categoryController.text,
                    //   tag: tagController.text.split(',').map((e) => e.trim()).toList(),
                    //   image: imageController.text,
                    //   desc: descController.text,
                    //   price: double.parse(priceController.text),
                    //   option: widget.menu.option,
                    // ));
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
