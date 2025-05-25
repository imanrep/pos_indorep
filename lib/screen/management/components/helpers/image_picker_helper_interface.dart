import 'package:flutter/material.dart';
import 'image_picker_result.dart';

abstract class ImagePickerHelperBase {
  Future<PickedImageResult?> pickAndProcessImage(BuildContext context);
  Future<String?> uploadImageToFirebase(PickedImageResult image);
}
