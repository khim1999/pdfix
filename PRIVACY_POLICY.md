# Privacy Policy for PDFix

*Last Updated: October 20, 2026*

**PDFix** ("we", "our", or "the App") is developed and published by **TTFC**. We are deeply committed to respecting and protecting your privacy. This Privacy Policy explains how PDFix operates with respect to your documents, data, and device permissions.

---

### Summary (The Short Version)
- **100% On-Device Processing**: Every PDF operation (compressing, merging, splitting, converting, encrypting, viewing) executes locally on your device.
- **Zero Cloud Uploads**: Your files, pages, and images are **never** uploaded to our servers or any cloud service.
- **Zero Personal Data Collection**: We do not collect names, email addresses, phone numbers, IP addresses, or device identifiers.
- **Zero Third-Party Telemetry / Trackers**: PDFix contains no advertising SDKs, no analytics trackers, and no user profiling.
- **Privacy-First Features**: Built-in 4-digit PIN lock, Anti-Spy screenshot blocking (`FLAG_SECURE`), and one-tap Cache Shredder.

---

### 1. Information We Do Not Collect
Unlike typical cloud PDF converters, PDFix functions entirely offline:
- **Document Content**: When you open, edit, compress, or convert a PDF, all processing is performed on your device CPU/memory.
- **Personal Information**: We do not ask for registration, sign-ups, or login credentials.
- **Device Identifiers**: We do not read or store advertising IDs, IMEI, or hardware serial numbers.
- **Location Data**: We do not collect or request GPS or network location.

---

### 2. Permissions & How They Are Used
PDFix only requests permissions strictly necessary to read and save PDF files on your device:
- **Storage / Photos & Media (`READ_EXTERNAL_STORAGE` / Android Media Store)**: Required exclusively to let you browse, select, and view your PDF files and images, and to save converted/compressed documents back to your device storage.
- **Internet (`INTERNET`)**: Only used if you explicitly trigger system updates or if system networking components require network availability. No documents or telemetry are transmitted.
- **Queries (`<queries>`)**: Used solely on Android 11+ to verify whether official client apps (such as Telegram, Microsoft Teams, Microsoft Outlook, or WhatsApp) are installed on your device when you tap "Direct Share".

---

### 3. Sharing Your Documents
PDFix never shares your documents automatically or behind the scenes.
- When you tap **Direct Share** to send a file to Telegram, Microsoft Teams, Outlook, or another app, PDFix packages your document into Android's secure `FileProvider` URI and passes it directly to the official target app via the Android operating system.
- Once transferred, the document is governed by the privacy policy of the respective recipient application.

---

### 4. Built-in Security & Storage Shredder
PDFix provides dedicated client-side security tools:
- **App Lock (4-Digit PIN)**: Secured using salted SHA-256 cryptographic hashing. The PIN and salt are stored strictly in your app's private sandbox storage and never transmitted.
- **Anti-Spy Screen (`FLAG_SECURE`)**: Prevents hardware screenshots, screen video recordings, and obscures recent app switcher previews.
- **Storage & Cache Shredder**: PDF processing generates transient cache files in your app sandbox. You can permanently shred these temporary files on demand or configure automatic cleanup upon app launch.

---

### 5. Third-Party Services
PDFix contains **NO** third-party advertising SDKs, tracking libraries, or analytic frameworks (no Google Firebase Analytics, no Facebook SDK, no Adjust, no AppsFlyer).

---

### 6. Children's Privacy (COPPA & GDPR-K)
PDFix does not collect any personal information from anyone, including children under the age of 13.

---

### 7. Changes to This Privacy Policy
We may update our Privacy Policy periodically. Any changes will be posted within the app and repository with an updated "Last Updated" date.

---

### 8. Contact Us
If you have any questions or feedback regarding this Privacy Policy, please contact:
- **Developer**: TTFC
- **Email**: support@ttfc-pdfix.local / privacy@ttfc.com
- **Application**: PDFix (Package: `com.ttfc.pdfix`)

