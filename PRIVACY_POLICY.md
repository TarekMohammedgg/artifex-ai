# Privacy Policy for Artifex Photo Editor

**Last Updated:** November 16, 2026

**Artifex Photo Editor** ("we", "our", or "us") values your privacy and is dedicated to protecting your personal information. This Privacy Policy outlines our practices regarding data collection, processing, and usage when you use our mobile application.

---

## 1. Information Collection and Handling

### a) On-Device Photo Processing
- **Image Editing & Local Filters**: All basic photo editing, cropping, color grading filters, bokeh blur effects, and on-device text overlays are processed locally directly on your device. We do not transfer, view, or store your private personal photos on our servers without your express action.
- **Smart OCR Text Scanner**: Our text recognition feature operates via Google ML Kit on-device machine learning APIs. Text extracted from your documents, signs, or images is processed on-device and remains confidential on your phone.

### b) AI Background Removal
- If you opt to use cloud-accelerated AI background removal (e.g. Remove.bg or custom API), the chosen image is securely transmitted over HTTPS for the singular purpose of separating the foreground subject from the background, and returned directly to your app. Images are not retained or used for AI training.

### c) Device Permissions
- **Camera (`android.permission.CAMERA`)**: Requested solely when you explicitly tap the camera option within the app to take a live photo for editing.
- **Photo Picker**: We use the native Android Photo Picker (`image_picker`), ensuring the app accesses only the specific photos you select, without requiring broad access to your entire device storage or media library.
- **Internet (`android.permission.INTERNET`)**: Used to access AI background removal services and fetch occasional app updates/configurations via Firebase.

---

## 2. Third-Party Services
Our app integrates trusted third-party SDKs that operate in compliance with Google Play Developer Policies:
- **Google Firebase**: Used for basic app performance monitoring and app stability.
- **Google ML Kit**: On-device text recognition.

We do not sell, rent, trade, or monetize your personal photos or biometric data under any circumstances.

---

## 3. Data Retention and Deletion
Since we do not maintain user accounts or persistent remote storage of your edited photos, all edits remain on your local device storage. You can delete or manage any saved images at any time via your device's default Gallery or File Manager.

---

## 4. Children's Privacy
Artifex Photo Editor is intended for general audiences aged 13 and older. We do not knowingly collect personal identifiable information from children under 13.

---

## 5. Contact Us
If you have any questions or concerns regarding this Privacy Policy, please contact us at:
- **Email:** `support@artifex.ai` or through our developer contact details on Google Play Console.
