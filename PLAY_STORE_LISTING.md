# Google Play Store Listing & Submission Kit for PDFix

This document contains everything needed to publish **PDFix** to the Google Play Store in real life. All assets, keys, and descriptions are prepared and located in `E:\pdfix\play_store_assets\`.

---

## 1. Store Listing Metadata

### App Title (Max 30 characters)
```text
PDFix: All-in-One PDF Tool
```

### Short Description (Max 80 characters)
```text
Edit, compress, merge, split, encrypt & convert PDFs 100% offline & securely.
```

### Full Description (Max 4,000 characters)
```text
PDFix is the powerful, privacy-first, 100% offline PDF powerhouse designed to make managing documents fast, secure, and effortless.

Unlike cloud-based PDF tools that upload your confidential documents to external servers, PDFix processes every single byte locally on your device hardware. Your contracts, bank statements, personal notes, and photos NEVER leave your phone.

⚡ CORE FEATURES:

• COMPRESS PDF: Dramatically reduce PDF file sizes with balanced, strong, or custom compression presets without losing visual clarity. Perfect for email attachments and messaging apps.

• MERGE PDF: Combine multiple PDF files into one neat document in seconds. Drag and reorder pages effortlessly.

• SPLIT PDF: Extract specific pages, split by ranges, or save individual chapters as new documents.

• IMAGES TO PDF: Convert multiple photos (JPG, PNG) into a high-quality, professional PDF document.

• PDF TO IMAGES: Extract high-resolution images from any PDF page.

• ROTATE & ORGANIZE: Fix upside-down or sideways pages with 90° and 180° rotation tools.

• WATERMARK & SIGN: Stamp custom text or confidentiality watermarks onto your documents.

• ENCRYPT PDF (AES-256): Add military-grade password protection to keep sensitive PDFs safe.

🛡️ BUILT-IN SECURITY & PRIVACY SUITE:

• 4-Digit PIN App Lock: Keep PDFix locked with a secure PIN. Automatically locks when you minimize or switch apps.
• Anti-Spy Privacy Shield (FLAG_SECURE): Prevents unauthorized screenshots, screen recording, and obscures sensitive PDF previews in Android's recent apps switcher.
• Storage & Cache Shredder: Easily wipe temporary processing cache files with one tap to save device storage and protect sensitive data.
• Direct Sharing: Send documents directly to Telegram, Microsoft Teams, Microsoft Outlook, and WhatsApp without third-party intermediate servers.

🔒 100% OFFLINE COMMITMENT:
No subscriptions, no cloud accounts, no ads, and no tracking. Everything runs directly on your Android device.

Download PDFix today and experience the ultimate offline PDF toolkit!
```

---

## 2. Store Visual Assets

Located in `E:\pdfix\play_store_assets\`:

| Asset | File Path | Specifications |
| :--- | :--- | :--- |
| **App Icon** | `E:\pdfix\play_store_assets\icon_512x512.png` | 512 x 512 PNG (32-bit color, no alpha transparency), Store-compliant |
| **Feature Graphic** | `E:\pdfix\play_store_assets\feature_graphic_1024x500.png` | 1024 x 500 PNG, high-res branded banner |
| **Screenshot 1** | `E:\pdfix\play_store_assets\screenshots\1_home_screen.png` | Home dashboard with all core tools |
| **Screenshot 2** | `E:\pdfix\play_store_assets\screenshots\2_security_hub.png` | Security Center & Storage Shredder |
| **Screenshot 3** | `E:\pdfix\play_store_assets\screenshots\3_pin_lock.png` | 4-Digit PIN Lock Screen |
| **Screenshot 4** | `E:\pdfix\play_store_assets\screenshots\4_direct_share.png` | Direct Share to Teams, Telegram, Outlook |

---

## 3. Production App Bundle (.aab)

The production signed Android App Bundle is generated and ready for upload:
- **Bundle File**: `E:\pdfix\output_apk\PDFix.aab` (also mirrored at `E:\pdfix\play_store_assets\PDFix.aab`)
- **Package Name / Application ID**: `com.ttfc.pdfix`
- **Version Name**: `1.0.0`
- **Version Code**: `1`
- **Target SDK**: Android API 35 (Latest Android 15 ready)
- **Minimum SDK**: Android API 21 (Supports 99%+ of all Android devices)

### Keystore Credentials (Keep Secure):
- **Keystore Path**: `E:\pdf_toolkit\android\app\upload-keystore.jks`
- **Configuration File**: `E:\pdf_toolkit\android\key.properties`
- **Key Alias**: `upload`
- **Store Password**: `PdfixSecure2026!`
- **Key Password**: `PdfixSecure2026!`

*(Note: Keep a secure backup of `upload-keystore.jks` and passwords. Google Play uses this key to verify all future app updates).*

---

## 4. Google Play Console Data Safety Form (Exact Answers)

When completing the mandatory **Data Safety** questionnaire in Google Play Console:

1. **Data collection and security**:
   - Does your app collect or share any of the required user data types? **NO**
   - Is all of the user data collected by your app encrypted in transit? **YES**
   - Do you provide a way for users to request that their data is deleted? **YES** (Via built-in Cache Shredder / Uninstall)

2. **Data types collected**:
   - Location: **None**
   - Personal info: **None**
   - Financial info: **None**
   - Health and fitness: **None**
   - Messages: **None**
   - Photos and videos: **None collected or sent to servers** (Local device processing only)
   - Audio files: **None**
   - Files and docs: **None collected or sent to servers**
   - Calendar / Contacts: **None**
   - App activity: **None**
   - Web browsing: **None**
   - App info and performance: **None**
   - Device or other IDs: **None**

3. **Data sharing**:
   - Does your app share any user data with other companies or organizations? **NO**

---

## 5. App Content & Policy Declarations

In the Google Play Console under **Policy > App content**:

- **Privacy Policy URL**: Host `E:\pdfix\PRIVACY_POLICY.html` on GitHub Pages (e.g., `https://<your-username>.github.io/pdfix/privacy`) and paste the URL.
- **Ads**: Select **"No, my app does not contain ads"**.
- **App Access**: Select **"All functionality is available without special access"**.
- **Content Rating**: Complete questionnaire. Since PDFix is a document utility with no user interaction or violent content, it will receive an **Everyone / PEGI 3** rating.
- **Target Audience & Content**: Target age group: **18 and over** or **13-17 and 18+**. "Could your store listing appeal to children?": **No**.
- **News Apps**: Select **"No"**.
- **COVID-19 Contact Tracing**: Select **"No"**.
- **Financial Features**: Select **"My app doesn't provide any financial features"**.
- **Government Apps**: Select **"No"**.

---

## 6. Step-by-Step Submission Walkthrough

1. Go to [Google Play Console](https://play.google.com/console) and log in with your Google Play Developer Account.
2. Click **Create app**:
   - App name: `PDFix: All-in-One PDF Tool`
   - Default language: `English (United States)`
   - App or game: `App`
   - Free or paid: `Free`
3. Complete the **Set up your app** tasks on the Dashboard (Privacy policy, Ads, Content rating, Target audience, Data safety).
4. Go to **Grow > Store presence > Main store listing**:
   - Paste the App title, Short description, and Full description from Section 1 above.
   - Upload `icon_512x512.png` under App icon.
   - Upload `feature_graphic_1024x500.png` under Feature graphic.
   - Upload the 4 screenshots from `E:\pdfix\play_store_assets\screenshots\`.
   - Click **Save**.
5. Go to **Release > Production** (or **Testing > Closed testing** for pre-launch test):
   - Click **Create new release**.
   - Under **App bundles**, drag and drop `E:\pdfix\output_apk\PDFix.aab`.
   - Release name will auto-populate as `1.0.0 (1)`.
   - Release notes: `Initial release of PDFix - All-in-One Offline PDF Tool.`
   - Click **Next** -> **Review release** -> **Start rollout to Production**!

