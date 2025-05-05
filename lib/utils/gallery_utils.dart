import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

/// Saves image bytes to the device's gallery.
///
/// Takes a [Uint8List] of image bytes and saves it to the device's gallery.
/// Returns true if the save was successful, false otherwise.
Future<bool> saveImageToGallery(Uint8List imageBytes) async {
  try {
    // First check if we have storage permission on Android
    if (await _checkAndRequestStoragePermission() == false) {
      return false;
    }

    // Save the image to gallery
    final result = await ImageGallerySaver.saveImage(
      imageBytes,
      quality: 100,
      name: "receipt_${DateTime.now().millisecondsSinceEpoch}",
    );

    // The result is a Map containing 'isSuccess' boolean
    return result['isSuccess'] ?? false;
  } catch (e) {
    print('Error saving image to gallery: $e');
    return false;
  }
}

/// Checks and requests storage permission if needed.
///
/// Returns true if permission is granted, false otherwise.
Future<bool> _checkAndRequestStoragePermission() async {
  // On Android, we need to check for storage permission
  // On iOS, no runtime permission is needed for gallery
  bool result = true;

  // Check the current platform and request permissions accordingly
  final status = await Permission.storage.status;

  if (status.isDenied) {
    // Request permission
    final requestStatus = await Permission.storage.request();
    result = requestStatus.isGranted;
  } else if (status.isPermanentlyDenied) {
    // Permission permanently denied, can only be granted from settings
    result = false;
  }

  return result;
}