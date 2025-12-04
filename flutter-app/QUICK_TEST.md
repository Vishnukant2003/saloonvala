# ⚡ Quick Test Guide - 5 Minutes!

## 🚀 Fastest Way to Test

### 1️⃣ Install Flutter (First Time Only)
```bash
# Download: https://flutter.dev/docs/get-started/install
# Verify:
flutter doctor
```

### 2️⃣ Get Dependencies
```bash
cd flutter-app
flutter pub get
```

### 3️⃣ Configure API URL
**Edit:** `lib/utils/constants.dart`
```dart
const String apiBaseUrl = 'http://localhost:8080'; // Your backend URL
```

### 4️⃣ Run on Web (Easiest!)
```bash
flutter run -d chrome
```

**That's it!** App opens in Chrome browser! 🎉

---

## 📱 Alternative: Android

```bash
flutter run
```
(Requires Android Studio + Emulator)

---

## ✅ What to Test

1. ✅ App opens
2. ✅ Main screen shows
3. ✅ Can navigate to screens
4. ✅ UI looks good
5. ✅ Buttons work

---

**Quick test in 5 minutes!** 🚀

