import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> saveImageToGallery(Uint8List imageBytes) async {
  try {
    if (await _checkAndRequestStoragePermission() == false) {
      return false;
    }

    final result = await ImageGallerySaver.saveImage(
      imageBytes,
      quality: 100,
      name: "receipt_${DateTime.now().millisecondsSinceEpoch}",
    );

    return result['isSuccess'] ?? false;
  } catch (e) {
    print('Error saving image to gallery: $e');
    return false;
  }
}

Future<bool> _checkAndRequestStoragePermission() async {
  bool result = true;

  final status = await Permission.storage.status;

  if (status.isDenied) {
    final requestStatus = await Permission.storage.request();
    result = requestStatus.isGranted;
  } else if (status.isPermanentlyDenied) {
    result = false;
  }

  return result;
}