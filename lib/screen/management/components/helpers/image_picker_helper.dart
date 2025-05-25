import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_indorep/screen/management/components/helpers/image_picker_result.dart';
export 'package:pos_indorep/screen/management/components/helpers/image_picker_helper_stub.dart'
    if (dart.library.html) 'image_picker_helper_web.dart'
    if (dart.library.io) 'image_picker_helper.dart';

class ImagePickerHelper {
  Future<PickedImageResult?> pickAndProcessImage(BuildContext context) async {
    Uint8List? imageBytes;
    String? fileName;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final cropped = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(lockAspectRatio: true),
          WebUiSettings(context: context),
        ],
      );

      if (cropped != null) {
        imageBytes = await cropped.readAsBytes();
        fileName = pickedFile.name;
      }
    }

    if (imageBytes == null) return null;

    // Resize to 150x150
    final decodedImage = img.decodeImage(imageBytes);
    if (decodedImage == null) return null;

    final resized = img.copyResize(decodedImage, width: 250, height: 250);
    final resizedBytes = Uint8List.fromList(img.encodeJpg(resized));

    return PickedImageResult(
      bytes: resizedBytes,
      name: fileName!,
    );
  }

  Future<String?> uploadImageToFirebase(
      String category, String name, PickedImageResult image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child("menu-picture/$category/${image.name}");

    final uploadTask = imageRef.putData(image.bytes);
    final snapshot = await uploadTask.whenComplete(() {});
    return await snapshot.ref.getDownloadURL();
  }
}
