import 'package:flutter/material.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:receipt_scanner/utils/permission_utils.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:io';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<String> _scannedDocumentPaths = [];
  bool _isScanning = false;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.cameraScreenTitle),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      ),
      body: _buildContent(localizations),
    );
  }

  Widget _buildContent(AppLocalizations localizations) {
    if (_scannedDocumentPaths.isNotEmpty) {
      return _buildScannedImagesView(localizations);
    }

    if (_isScanning) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(localizations.scanning),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startScanning,
              child: Text(localizations.tryAgain),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.document_scanner_outlined,
            size: 100,
            color: Colors.grey,
          ),
          const SizedBox(height: 24),
          Text(
            localizations.tapToScanReceipt,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.camera_alt),
            label: Text(localizations.scanButton),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannedImagesView(AppLocalizations localizations) {
    return Column(
      children: [
        Expanded(
          child:
              _scannedDocumentPaths.length == 1
                  ? Image.file(
                    File(_scannedDocumentPaths.first),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          localizations.imageLoadError(error.toString()),
                        ),
                      );
                    },
                  )
                  : GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                    itemCount: _scannedDocumentPaths.length,
                    itemBuilder: (context, index) {
                      return Image.file(
                        File(_scannedDocumentPaths[index]),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(Icons.broken_image, size: 48),
                          );
                        },
                      );
                    },
                  ),
        ),
        if (_isSaving)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 8),
                Text(localizations.savingReceipts),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startScanning,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(localizations.scanNew),
                ),
                ElevatedButton.icon(
                  onPressed: _saveAndFinish,
                  icon: const Icon(Icons.check),
                  label: Text(localizations.confirm),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Future<void> _saveAndFinish() async {
    if (_scannedDocumentPaths.isEmpty) return;

    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _isSaving = true;
    });

    int successCount = 0;
    String debugInfo = "";

    for (final path in _scannedDocumentPaths) {
      try {
        print("Attempting to save image from path: $path");
        debugInfo += "Path: $path\n";

        final file = File(path);
        final exists = await file.exists();
        debugInfo += "File exists: $exists\n";

        if (!exists) {
          print("File does not exist: $path");
          continue;
        }

        final fileSize = await file.length();
        debugInfo += "File size: $fileSize bytes\n";
        print("File size: $fileSize bytes");

        final bytes = await file.readAsBytes();
        debugInfo += "Bytes read: ${bytes.length}\n";

        if (bytes.isEmpty) {
          print("Empty bytes read from file: $path");
          continue;
        }

        final result = await ImageGallerySaver.saveImage(
          bytes,
          quality: 100,
          name: "receipt_${DateTime.now().millisecondsSinceEpoch}",
        );

        debugInfo += "Save result: $result\n";
        print("Gallery save result: $result");

        final success = result['isSuccess'] ?? false;
        if (success) {
          successCount++;
        } else {
          print("Failed to save to gallery: ${result['errorMessage']}");
        }
      } catch (e, stackTrace) {
        print("Error saving image at path $path: $e");
        print("Stack trace: $stackTrace");
        debugInfo += "Error: $e\n";
      }
    }

    if (mounted) {
      setState(() {
        _isSaving = false;
      });

      String message;
      if (successCount > 0) {
        message = localizations.receiptsSaved(successCount);
      } else {
        message = localizations.saveFailed;
        print("Debug info for failed save: $debugInfo");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.saveFailedDetails),
            action: SnackBarAction(
              label: localizations.errorDetails,
              onPressed: () {
                showDialog(
                  context: context,
                  builder:
                      (context) => AlertDialog(
                        title: Text(localizations.errorDetails),
                        content: SingleChildScrollView(child: Text(debugInfo)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(localizations.ok),
                          ),
                        ],
                      ),
                );
              },
            ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      Navigator.pop(context);
    }
  }

  Future<void> _startScanning() async {
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _errorMessage = null;
      _isScanning = true;
    });

    try {
      final hasPermission = await requestCameraPermission(context);

      if (!hasPermission) {
        setState(() {
          _errorMessage = localizations.cameraPermissionRequired;
          _isScanning = false;
        });
        return;
      }

      final List<String> pictures =
          await CunningDocumentScanner.getPictures(
            noOfPages: 5,
            isGalleryImportAllowed: true,
          ) ??
          [];

      if (mounted) {
        setState(() {
          _scannedDocumentPaths = pictures;
          _isScanning = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '${localizations.scanningError}: ${e.toString()}';
          _isScanning = false;
        });
      }
    }
  }
}
