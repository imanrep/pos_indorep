import 'package:flutter/material.dart';
import 'image_picker_result.dart';
import 'image_picker_helper_interface.dart';

class ImagePickerHelper implements ImagePickerHelperBase {
  @override
  Future<PickedImageResult?> pickAndProcessImage(BuildContext context) {
    throw UnimplementedError('Not supported on this platform.');
  }

  @override
  Future<String> uploadImageToFirebase(PickedImageResult image) {
    throw UnimplementedError('Not supported on this platform.');
  }
}
