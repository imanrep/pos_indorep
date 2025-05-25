import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:pos_indorep/screen/management/components/helpers/image_picker_result.dart';

class ImagePickerHelperWeb {
  Future<PickedImageResult?> pickAndProcessImage(BuildContext context) async {
    Uint8List? imageBytes;
    String? fileName;
    // Pick file
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;
      final name = result.files.single.name;

      // Create a blob URL
      final blob = html.Blob([bytes]);
      final blobUrl = html.Url.createObjectUrl(blob);

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: blobUrl,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          WebUiSettings(
            context: context,
          ),
        ],
      );

      html.Url.revokeObjectUrl(blobUrl); // Clean up

      if (croppedFile != null) {
        imageBytes = await croppedFile.readAsBytes();
        fileName = name;
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
}
