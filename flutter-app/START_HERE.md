# 🚀 START HERE - How to Test the Flutter App

## ⚡ Quick Test (3 Commands!)

```bash
# 1. Go to Flutter app folder
cd flutter-app

# 2. Install packages
flutter pub get

# 3. Run on web (easiest!)
flutter run -d chrome
```

**That's it!** App opens in Chrome! 🎉

---

## 📋 What You Need

### Prerequisites:
1. ✅ Flutter SDK installed
   - Download: https://flutter.dev/docs/get-started/install
   - Add to PATH
   - Verify: `flutter doctor`

2. ✅ Chrome browser (for web testing)
   - Already installed on most systems

---

## 🎯 Test Steps

### Step 1: Install Flutter (If Not Installed)

**Windows:**
1. Download Flutter SDK
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to PATH
4. Run `flutter doctor`

**Mac/Linux:**
```bash
# Download and extract
# Add to PATH in ~/.bashrc or ~/.zshrc
export PATH="$PATH:/path/to/flutter/bin"
```

### Step 2: Get Dependencies

```bash
cd flutter-app
flutter pub get
```

This installs all required packages.

### Step 3: Configure API (Optional)

**Current API URL:** `https://admin.saloonvala.in/`

**To change:** Edit `lib/utils/constants.dart`
```dart
static const String apiBaseUrl = 'YOUR_URL';
```

### Step 4: Run!

```bash
# Web (Easiest - Recommended!)
flutter run -d chrome

# Android
flutter run

# iOS (Mac only)
flutter run -d ios
```

---

## ✅ What to Expect

When you run `flutter run -d chrome`:

1. ✅ Builds the app
2. ✅ Opens Chrome browser
3. ✅ Shows Main screen
4. ✅ All navigation works
5. ✅ Beautiful UI displays

---

## 🐛 Common Issues

**"Flutter not found"**
- Add Flutter to PATH
- Restart terminal

**"Packages missing"**
```bash
flutter clean
flutter pub get
```

**"API error"**
- Check API URL in `constants.dart`
- Ensure backend is running

---

## 💡 Tips

- **Web is fastest** - Use `flutter run -d chrome`
- **Hot Reload** - Press `r` to reload
- **Hot Restart** - Press `R` to restart
- **Quit** - Press `q` to quit

---

## 📝 Full Guide

See `HOW_TO_TEST.md` for detailed instructions.

---

**Ready? Run these commands:**

```bash
cd flutter-app
flutter pub get
flutter run -d chrome
```

**App will open in Chrome!** 🚀

