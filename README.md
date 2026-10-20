<p align="center">
  <img src="play_store_assets/feature_graphic_1024x500.png" alt="PDFix Banner" width="100%">
</p>

<h1 align="center">PDFix — All-in-One Offline PDF Powerhouse</h1>

<p align="center">
  <strong>Fast, private, and secure PDF tools right on your Android device. 100% On-Device. Zero Cloud.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" />
  <img src="https://img.shields.io/badge/Privacy-100%25%20Offline-brightgreen?style=for-the-badge" alt="Privacy" />
  <img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="License" />
</p>

---

## 🌟 Highlights

- **🔒 100% Offline & Private**: All document processing runs directly on device hardware. Zero telemetry, zero analytics, zero server uploads.
- **⚡ Comprehensive Toolset**:
  - **Compress PDF**: Dramatically reduce file size with Light, Balanced, Strong, and Custom presets.
  - **Merge PDF**: Combine multiple PDFs into a single document with smooth reordering.
  - **Split PDF**: Extract page ranges or individual pages effortlessly.
  - **Images to PDF**: Convert photos (JPEG, PNG) into polished PDF documents.
  - **PDF to Images**: Extract high-resolution images from any page.
  - **Rotate Pages**: Correct document orientation (90°, 180°, 270°).
  - **Watermark & Sign**: Add confidentiality stamps or signature overlays.
  - **Password Encryption**: AES-256 military-grade protection for confidential files.
- **🛡️ Built-in Security & Privacy Suite**:
  - **4-Digit PIN Lock**: Salted SHA-256 cryptographic protection that auto-locks when backgrounded.
  - **Anti-Spy Shield (`FLAG_SECURE`)**: Blocks hardware screenshots and blanks multitask task-switcher previews.
  - **Storage & Cache Shredder**: One-tap wipe of orphaned processing files.
- **🚀 Native Direct Sharing**:
  - One-tap direct sharing to **Telegram**, **Microsoft Teams**, **Microsoft Outlook**, and **WhatsApp** via native Android `FileProvider` intents.

---

## 📱 Screenshots

<p align="center">
  <img src="play_store_assets/screenshots/1_home_screen.png" width="22%" />
  <img src="play_store_assets/screenshots/2_security_hub.png" width="22%" />
  <img src="play_store_assets/screenshots/3_pin_lock.png" width="22%" />
  <img src="play_store_assets/screenshots/4_direct_share.png" width="22%" />
</p>

---

## 🛠️ Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev) (v3.19+ recommended)
- [Android Studio](https://developer.android.com/studio) with Android SDK API 35
- Java Development Kit (JDK 17+)

### Installation
```bash
# Clone the repository
git clone https://github.com/khim1999/pdfix.git
cd pdfix

# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run
```

---

## 📦 Building for Production

### Build Signed Android App Bundle (for Google Play Store)
```bash
flutter build appbundle --release
```
*Output: `build/app/outputs/bundle/release/app-release.aab`*

### Build Lean Architecture APKs
```bash
flutter build apk --release --split-per-abi
```
*Output: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`*

---

## 📄 Privacy Policy

PDFix values user trust above all else. Review our complete [Privacy Policy](PRIVACY_POLICY.md) or [HTML version](PRIVACY_POLICY.html).

---

## 📜 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
