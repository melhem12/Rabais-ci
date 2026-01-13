# Rabais CI - Mobile Application

A Flutter mobile application with beautiful animations and enhanced UI/UX design.

## Features

- 🎨 **Beautiful Animations**: Smooth fade-in, slide-in, and scale animations throughout the app
- 💳 **Wallet Management**: Track coins, coupons, and balance in CFA
- 🎫 **Coupons System**: Browse and manage vouchers with advanced filtering
- 🤝 **Partners Directory**: Discover merchant partners and their offers
- 👤 **User Profile**: Manage profile with image upload and password change
- 🎯 **Professional Design**: Modern, polished UI with gradient backgrounds and smooth transitions

## Technologies

- Flutter
- Dart
- BLoC Pattern for State Management
- Material Design 3

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / Xcode (for mobile development)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/melhem12/Rabais-ci.git
cd Rabais-ci
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Build

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release --no-codesign
```

## Project Structure

```
lib/
├── core/           # Core utilities, constants, theme
├── data/           # Data layer (repositories, datasources)
├── domain/         # Domain layer (entities, use cases)
└── presentation/   # UI layer (pages, widgets, BLoCs)
```

## License

This project is private and proprietary.

## Author

melhem12
