# PDFix — Complete User Guide & Manual

Welcome to **PDFix**, your fast, all-in-one, 100% offline PDF powerhouse for Android. All operations take place locally on your phone's processor — your files are never uploaded to the cloud or shared with third parties.

---

## 📑 Table of Contents
1. [Installation & Getting Started](#1-installation--getting-started)
2. [Compress PDF Files](#2-compress-pdf-files)
3. [Merge Multiple PDFs](#3-merge-multiple-pdfs)
4. [Split PDF Pages](#4-split-pdf-pages)
5. [Convert Images to PDF](#5-convert-images-to-pdf)
6. [Convert PDF to Images](#6-convert-pdf-to-images)
7. [Rotate PDF Pages](#7-rotate-pdf-pages)
8. [Watermark Documents](#8-watermark-documents)
9. [Sign Documents by Hand](#9-sign-documents-by-hand)
10. [Password Protection & Unlocking](#10-password-protection--unlocking)
11. [Security & Privacy Center](#11-security--privacy-center)
12. [Saving & Direct Sharing](#12-saving--direct-sharing)
13. [Frequently Asked Questions (FAQ)](#13-frequently-asked-questions-faq)

---

## 1. Installation & Getting Started

### Installing the App on Android
1. Download the latest APK from the `output_apk` folder or [GitHub Releases](https://github.com/khim1999/pdfix/releases):
   - **`PDFix_arm64.apk`** *(Recommended)*: Ultra-lean 9 MB build for modern phones (Samsung, Google Pixel, Xiaomi, Oppo, etc.).
   - **`PDFix_Universal.apk`**: Compatible with any Android device running Android 7.0 (Nougat) or newer.
2. Open the downloaded APK on your phone.
3. If prompted by Android, tap **Settings** and enable **"Allow from this source"**.
4. Tap **Install** and open **PDFix**.

---

## 2. Compress PDF Files
> **Goal**: Dramatically reduce file size while preserving clear, readable text.

### How to use:
1. Tap **Compress PDF** on the home screen.
2. Tap **Select PDF Document** (pick from your recent documents or browse device files).
3. Choose your desired compression level:
   - 🔘 **Extreme compression** (`−85%` size reduction):  
     *Best when you must fit under strict email or portal upload limits (e.g., 2 MB).*
   - 🔘 **Recommended compression** (`−75%` size reduction • *Default*):  
     *Balanced print-grade quality. Adobe-level sharp text outlines with 75–85% smaller file size.*
   - 🔘 **Less compression** (`−50%` size reduction):  
     *Highest visual fidelity for documents containing detailed photos or artwork.*
4. Tap **Compress PDF**.
5. When finished, you will see your file size before and after, along with the percentage saved.
6. Tap **Share** or **Save** to export your new document.

> [!TIP]
> **Guaranteed Anti-Inflation**: PDFix guarantees that a compressed file will **never** be larger than the original input document.

---

## 3. Merge Multiple PDFs
> **Goal**: Combine multiple PDF reports, receipts, or notes into a single document.

### How to use:
1. Tap **Merge PDF** on the home screen.
2. Tap **Add PDF** to pick your first file.
3. Tap **Add PDF** again to add more files (select as many as you need).
4. Reorder documents by dragging the reorder handles if needed.
5. Tap **Merge Files**.
6. Your merged document is saved instantly with best-stream compression.

---

## 4. Split PDF Pages
> **Goal**: Extract specific pages or separate a large document into individual files.

### How to use:
1. Tap **Split PDF** and select your document.
2. Select your split mode:
   - **Page Ranges**: Enter custom ranges separated by commas (e.g. `1-3, 5, 7-10`).
   - **Every Page**: Breaks every single page into its own standalone PDF file.
   - **Every N Pages**: Splits document into chunks of N pages (e.g., every 2 pages).
3. Tap **Split PDF**.
4. Tap any created part to preview or share it individually, or tap **Save All to Folder**.

---

## 5. Convert Images to PDF
> **Goal**: Turn camera photos, invoices, IDs, or receipts into a clean PDF document.

### How to use:
1. Tap **Images to PDF** on the home screen.
2. Tap **Choose Images** and pick photos from your photo gallery.
3. Review the selected images in the list.
4. Tap **Convert to PDF**.
5. PDFix compiles your photos into a standardized, compressed A4 PDF document.

---

## 6. Convert PDF to Images
> **Goal**: Save pages of a PDF as individual high-resolution JPEG images.

### How to use:
1. Tap **PDF to Images** and pick your PDF.
2. Tap **Convert to Images**.
3. PDFix streams through each page and exports high-definition JPEG files to your storage.
4. You can share images directly or open them in your photo gallery.

---

## 7. Rotate PDF Pages
> **Goal**: Fix documents or scans that were saved sideways or upside-down.

### How to use:
1. Tap **Rotate Pages** and pick your file.
2. Select your rotation angle:
   - **90°** (Clockwise quarter-turn)
   - **180°** (Upside down flip)
   - **270°** (Counter-clockwise quarter-turn)
3. Tap **Rotate Pages**. The corrected PDF is saved immediately.

---

## 8. Watermark Documents
> **Goal**: Stamp a security or confidentiality notice across all pages.

### How to use:
1. Tap **Watermark** and select your PDF document.
2. Type your watermark text (e.g., `CONFIDENTIAL`, `DRAFT`, `COPY`, or your company name).
3. Tap **Apply Watermark**.
4. PDFix applies a semi-transparent angled text stamp across every page without obscuring underlying content.

---

## 9. Sign Documents by Hand
> **Goal**: Sign contracts, agreements, or forms directly with your finger or stylus.

### How to use:
1. Tap **Sign Document** and choose your PDF file.
2. Select the page number where you want your signature placed.
3. Draw your signature in the signature pad using your finger or stylus.
   - If you make a mistake, tap **Clear** and redraw.
4. Tap **Apply Signature**.
5. Your signature is embedded onto the document with high resolution.

---

## 10. Password Protection & Unlocking
> **Goal**: Encrypt confidential documents with AES-256 or remove password restrictions.

### Protecting a PDF:
1. Tap **Protect PDF** and select your file.
2. Enter your desired password.
3. Tap **Encrypt & Save**. The document is secured with military-grade AES-256 encryption.

### Unlocking a PDF:
1. Tap **Unlock PDF** and select the protected document.
2. Enter the current password.
3. Tap **Remove Password**. The restriction is stripped, allowing easy editing and printing.

---

## 11. Security & Privacy Center

Access the Security Center by tapping the **Security & Privacy** pill at the top of the home screen.

### Features:
- **4-Digit PIN App Lock**:
  - Enable to require a secure PIN each time PDFix opens.
  - Automatically locks as soon as the app is switched or sent to the background.
  - Uses cryptographic salted SHA-256 hashing.
- **Anti-Spy Shield (`FLAG_SECURE`)**:
  - Prevents screenshot and screen recording tools from capturing your sensitive documents.
  - Blanks out app preview in the Android task switcher (recents screen).
- **Storage & Cache Shredder**:
  - View real-time disk cache usage.
  - Tap **Wipe Cache & Temp Files** to permanently shred temporary working files.

---

## 12. Saving & Direct Sharing

When any PDF operation is finished, you can:
- **Open**: Preview the document in the built-in PDF viewer.
- **Save to Device**: Pick any folder on your phone or SD card to store the file permanently.
- **Direct Share**: One-tap native sharing to:
  - ✈️ **Telegram**
  - 💬 **WhatsApp**
  - 💼 **Microsoft Teams**
  - ✉️ **Microsoft Outlook**
  - 📤 **Android System Share Sheet** (Gmail, Drive, Bluetooth, etc.)

---

## 13. Frequently Asked Questions (FAQ)

#### Q: Does PDFix upload my files to the internet?
**A: No.** PDFix operates 100% offline. All conversions, compression, and encryption happen strictly inside your phone's processor. No internet connection is ever required.

#### Q: Why does PDF compression make text look sharp instead of blurry?
**A: Native Print Rendering.** PDFix uses Android's native subpixel anti-aliasing engine (`RENDER_MODE_FOR_PRINT`). This optimizes font hints and vector paths so text remains sharp and legible even at high compression ratios.

#### Q: Can I cancel a long operation?
**A: Yes.** A live **Cancel** button appears during operations. Tapping Cancel safely stops processing at the current page boundary without leaving partial or corrupted files.

#### Q: Where are my processed files stored?
**A: App Documents Directory.** Processed files are saved under `PDFix/` in your app storage and listed under **Recent Files** on the home screen. You can also save them to your `Download` or `Documents` folder at any time.

