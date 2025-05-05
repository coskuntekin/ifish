import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<bool> requestCameraPermission(BuildContext context) async {
  PermissionStatus status = await Permission.camera.status;

  if (status.isGranted) {
    return true;
  }

  if (status.isDenied) {
    status = await Permission.camera.request();
    return status.isGranted;
  }

  if (status.isPermanentlyDenied) {
    final shouldOpenSettings = await _showPermissionDialog(context);

    if (shouldOpenSettings) {
      await openAppSettings();
      return await Permission.camera.status.isGranted;
    }

    return false;
  }

  return false;
}

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

  return result ?? false;
}