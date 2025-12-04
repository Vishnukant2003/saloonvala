# 🧪 Testing Guide - How to Test Your Flutter App

## ✅ Quick Answer: 3 Steps!

```bash
cd flutter-app
flutter pub get
flutter run -d chrome
```

**Done!** App opens in Chrome browser! 🎉

---

## 📋 Complete Testing Instructions

### Prerequisites

1. **Install Flutter SDK**
   - Download: https://flutter.dev/docs/get-started/install
   - Extract and add to PATH
   - Verify: `flutter doctor`

2. **Install Chrome** (for web testing - usually already installed)

3. **Start Backend** (optional - if testing API calls)
   - Run Spring Boot backend server

---

### Step-by-Step Test Process

#### Step 1: Check Flutter Installation

```bash
flutter doctor
```

**Should show:**
- ✅ Flutter SDK installed
- ✅ Chrome available
- ✅ Android toolchain (for Android testing)

#### Step 2: Navigate to App

```bash
cd flutter-app
```

#### Step 3: Install Dependencies

```bash
flutter pub get
```

**Installs all packages:**
- provider, http, shared_preferences, etc.

#### Step 4: Configure API URL (If Needed)

**File:** `lib/utils/constants.dart`

**Current:** `https://admin.saloonvala.in/`

**To change for local testing:**
```dart
static const String apiBaseUrl = 'http://localhost:8080';
```

#### Step 5: Run the App!

**Web (Recommended - Easiest!):**
```bash
flutter run -d chrome
```

**Android:**
```bash
flutter run
```
(Requires Android Studio + Emulator)

**iOS (Mac only):**
```bash
flutter run -d ios
```

---

## 🎯 What to Test

### Basic Tests
- ✅ App launches
- ✅ Main screen appears
- ✅ Navigation works
- ✅ All screens accessible

### Feature Tests
- ✅ Login/Register
- ✅ Dashboard loads
- ✅ Search works
- ✅ Booking flow
- ✅ Admin panel

---

## 🛠️ Troubleshooting

**"Flutter not found"**
→ Install Flutter and add to PATH

**"Packages missing"**
```bash
flutter clean
flutter pub get
```

**"API connection failed"**
→ Check API URL and ensure backend is running

**"Build errors"**
```bash
flutter clean
flutter pub upgrade
flutter pub get
```

---

## 💡 Tips

- **Web is fastest** - Use Chrome for quick testing
- **Hot Reload** - Press `r` to reload changes
- **Check Terminal** - Errors appear in console

---

## ✅ Expected Result

When you run `flutter run -d chrome`:

1. ✅ Builds successfully
2. ✅ Chrome opens
3. ✅ App displays
4. ✅ All features work

---

**Ready! Run these commands now:**

```bash
cd flutter-app
flutter pub get
flutter run -d chrome
```

**Your app will open!** 🚀

