# Receipt Scanner (iFISH)

A Flutter application for scanning and saving receipts to your device's gallery. The app is localized for both English and Turkish languages.

## Demo

<video width="100%">
  <source src="assets/screen-record/screen-record.webm" type="video/webm">
  Your browser does not support the video tag.
</video>

## Features

- **Receipt Scanning**: Uses camera to capture and scan receipts
- **Multiple Images**: Support for scanning and saving multiple receipts in a session
- **Gallery Integration**: Automatically saves scanned receipts to device gallery
- **Multilingual Support**: Full localization for English and Turkish languages
- **Error Handling**: Comprehensive error reporting and debugging information
- **Permission Management**: Proper handling of camera and storage permissions

## Getting Started

### Prerequisites

- Flutter (Latest stable version recommended)
- Android Studio / Xcode
- A physical device or emulator with camera capabilities

### Installation

1. Clone the repository:
```bash
git clone git@github.com:coskuntekin/ifish.git
cd ifish
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

The project follows a standard Flutter architecture:

```
lib/
├── main.dart            # Application entry point
├── screens/             # UI screens
│   ├── home_screen.dart    # Main app screen
│   ├── camera_screen.dart  # Camera and scanning functionality
├── utils/               # Utility functions
│   ├── permission_utils.dart # Permission handling
│   ├── gallery_utils.dart # Gallery handling
├── l10n/                # Localization
    ├── app_en.arb          # English strings
    ├── app_tr.arb          # Turkish strings
```

## Dependencies

The app uses several key packages:

- `cunning_document_scanner`: For receipt scanning functionality
- `image_gallery_saver`: To save scanned receipts to the gallery (local plugin)
- `permission_handler`: To manage camera and storage permissions
- `flutter_riverpod`: For state management
- `flutter_localizations`: For multilingual support

## Local Plugin

This project uses a local plugin for saving images to the gallery:

```
local_plugins/
└── image_gallery_saver/  # Plugin for saving images to gallery
```

## App Workflow

1. The user launches the app and sees the home screen
2. The user taps on "Scan Receipt" after granting camera permission
3. The camera screen opens allowing the user to scan up to 5 receipts
4. After scanning, the user can review the captured images
5. The user confirms and the images are saved to the gallery
6. A success/failure message is displayed

## Error Handling

The app includes comprehensive error handling for:
- Permission issues
- Image capture failures
- Gallery saving problems

Detailed debug information is available when saving fails.

## Internationalization

The app supports both English and Turkish languages with strings defined in ARB files.

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.