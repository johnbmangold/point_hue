# PointHue

Capture and store colors from the real world with ease. PointHue uses your camera to detect colors in real-time, allowing you to build and organize your personal color library.

## ✨ Features

- **Real-time Detection**: Capture colors instantly using your device's camera.
- **Color Library**: Save your favorite colors to a persistent library.
- **Detailed Insights**: View Hex, RGB, and other color details for every captured hue.
- **Modern UI**: A sleek, responsive interface built with `FlexColorScheme` and Material 3.
- **Dynamic Theming**: Support for light and dark modes based on system settings.

## 🛠 Tech Stack

- **Flutter**: Cross-platform UI toolkit.
- **Riverpod**: Robust reactive state management.
- **GoRouter**: Declarative routing for Flutter.
- **Freezed & Riverpod Generator**: Type-safe code generation for models and providers.
- **Camera**: Powerful camera integration for real-time processing.
- **FlexColorScheme**: Advanced theming system with beautiful color palettes.
- **Shorebird**: Seamless over-the-air updates.

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (version ^3.10.8)
- [Dart SDK](https://dart.dev/get-started/sdk/install)

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/johnmangold/point_hue.git
   cd point_hue
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate code:**
   Generate the necessary code-generated files (Riverpod, Freezed, etc.):
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🏗 Build & Development

PointHue relies heavily on code generation. If you make changes to models or providers, ensure you run the generator:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
