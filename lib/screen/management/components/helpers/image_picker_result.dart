import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_indorep/screen/management/components/helpers/image_picker_helper.dart';

class PickedImageResult {
  final Uint8List bytes;
  final String name;

  PickedImageResult({required this.bytes, required this.name});
}

class ImagePickerUnified {
  static final ImagePickerHelper _helper = ImagePickerHelper();

  static Future<PickedImageResult?> pickAndProcessImage(BuildContext context) {
    return _helper.pickAndProcessImage(context);
  }

  static Future<String> uploadImageToFirebase(
      String category, String name, PickedImageResult image) async {
    return (await _helper.uploadImageToFirebase(category, name, image)) ?? '';
  }
}
