import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Requests camera permission from the user.
///
/// This function checks the current permission status and handles different scenarios:
/// - If permission is already granted, returns true
/// - If permission is denied, requests it from the user
/// - If permission is permanently denied, shows a dialog suggesting to open app settings
///
/// Returns a Future<bool> that resolves to true if permission is granted, false otherwise.
Future<bool> requestCameraPermission(BuildContext context) async {
  // Check the current status of camera permission
  PermissionStatus status = await Permission.camera.status;

  // If already granted, return true
  if (status.isGranted) {
    return true;
  }

  // If permission is denied but not permanently, request it
  if (status.isDenied) {
    status = await Permission.camera.request();
    // Return true if the user granted permission after request
    return status.isGranted;
  }

  // If permission is permanently denied, show a dialog
  if (status.isPermanentlyDenied) {
    final shouldOpenSettings = await _showPermissionDialog(context);

    // If user agreed to open settings
    if (shouldOpenSettings) {
      await openAppSettings();
      // We can't know the result after returning from settings,
      // so we check the permission status again
      return await Permission.camera.status.isGranted;
    }

    // User declined to open settings
    return false;
  }

  // Handle other cases (restricted, limited, etc.)
  return false;
}

/// Shows a dialog explaining why the app needs camera permission
/// and suggesting the user to open app settings.
///
/// Returns a Future<bool> that resolves to true if the user agrees to open settings.
Future<bool> _showPermissionDialog(BuildContext context) async {
  final localizations = AppLocalizations.of(context);

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(localizations?.cameraPermissionRequiredTitle ?? 'Camera Permission Required'),
        content: Text(
          localizations?.cameraPermissionRequired ??
          'Camera permission is required to scan receipts. Please enable camera permission in settings.'
        ),
        actions: <Widget>[
          TextButton(
            child: Text(localizations?.cancel ?? 'Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: Text(localizations?.openSettings ?? 'Open Settings'),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  // Return false if the dialog was dismissed without selecting an option
  return result ?? false;
}