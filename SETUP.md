# RABAIS CI Mobile App - Manual Setup Steps

## 1. Install Dependencies
```bash
flutter pub get
```

## 2. Generate Code (Run these commands after adding new dependencies)
```bash
# Generate freezed files
flutter pub run build_runner build --delete-conflicting-outputs

# Generate localization files
flutter pub run intl_utils:generate

# Generate injectable files (when adding new services)
flutter pub run build_runner build --delete-conflicting-outputs
```

## 3. Platform-specific Setup

### Android
- Add internet permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
```

### iOS
- Add camera usage description in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan QR codes</string>
```

## 4. Environment Configuration
- Update `lib/core/constants/app_constants.dart` with your actual API base URL
- Configure staging/production environments as needed

## 5. Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run widget tests
flutter test test/widget_test.dart
```

## 6. Build Commands
```bash
# Debug build
flutter run

# Release build
flutter build apk --release
flutter build ios --release
```

## 7. Code Generation Commands
- Always run `flutter pub run build_runner build --delete-conflicting-outputs` after:
  - Adding new freezed models
  - Adding new injectable services
  - Modifying existing generated files

## 8. Localization Commands
- Run `flutter pub run intl_utils:generate` after:
  - Adding new strings to .arb files
  - Modifying existing localization files
  - Adding new languages
