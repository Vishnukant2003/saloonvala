# 🧪 Flutter App Testing Guide

## 📋 Prerequisites

### 1. Install Flutter SDK

**Download Flutter:**
- Visit: https://flutter.dev/docs/get-started/install
- Download Flutter SDK for your OS
- Extract to a folder (e.g., `C:\flutter`)

**Add to PATH:**
```bash
# Add Flutter bin directory to your PATH
# Windows: Add C:\flutter\bin to System Environment Variables
```

**Verify Installation:**
```bash
flutter doctor
```

### 2. Install Dependencies

**Install Required Tools:**
- ✅ Flutter SDK
- ✅ Android Studio (for Android)
- ✅ Xcode (for iOS - Mac only)
- ✅ VS Code or Android Studio (IDE)
- ✅ Chrome (for web testing)

---

## 🚀 Quick Start - Testing Steps

### Step 1: Navigate to Flutter App Directory

```bash
cd flutter-app
```

### Step 2: Get Dependencies

```bash
flutter pub get
```

This will install all packages from `pubspec.yaml`.

### Step 3: Check Flutter Setup

```bash
flutter doctor
```

Make sure all checks pass (or at least Android/iOS toolchain is ready).

### Step 4: Configure API Base URL

**Edit:** `flutter-app/lib/utils/constants.dart`

Update the API base URL:
```dart
const String apiBaseUrl = 'YOUR_BACKEND_URL'; // e.g., 'http://localhost:8080'
```

### Step 5: Run the App

**For Android:**
```bash
flutter run
```

**For Web:**
```bash
flutter run -d chrome
```

**For iOS (Mac only):**
```bash
flutter run -d ios
```

---

## 🧪 Testing Different Platforms

### 1. Test on Android

**Requirements:**
- Android Studio installed
- Android device connected OR emulator running

**Steps:**
```bash
cd flutter-app
flutter pub get
flutter run
```

**Or use Android Studio:**
1. Open `flutter-app` folder in Android Studio
2. Click "Run" button
3. Select device/emulator

### 2. Test on Web

**Run:**
```bash
cd flutter-app
flutter pub get
flutter run -d chrome
```

**Or:**
```bash
flutter run -d web-server --web-port 8080
```

### 3. Test on iOS (Mac only)

**Requirements:**
- Mac with Xcode installed
- iOS Simulator or device

**Run:**
```bash
cd flutter-app
flutter pub get
flutter run -d ios
```

---

## ⚙️ Configuration

### 1. Update API Base URL

**File:** `flutter-app/lib/utils/constants.dart`

```dart
// Change this to your backend URL
const String apiBaseUrl = 'http://localhost:8080'; // Local
// OR
const String apiBaseUrl = 'https://your-backend.railway.app'; // Production
```

### 2. Enable Web Support (if testing on web)

**Check if web is enabled:**
```bash
flutter config --enable-web
```

**Create web folder (if not exists):**
```bash
flutter create --platforms=web .
```

---

## 🔧 Troubleshooting

### Issue: Flutter not found
**Solution:**
- Add Flutter to PATH
- Restart terminal/IDE

### Issue: Packages not installing
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: API connection failed
**Solution:**
- Check API base URL in `constants.dart`
- Ensure backend is running
- Check CORS settings (for web)

### Issue: Build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

---

## 📱 Testing Checklist

### Authentication Flow
- [ ] Main screen loads
- [ ] Login screen works
- [ ] Register screen works
- [ ] Welcome screen appears
- [ ] Navigation to dashboard works

### User Dashboard
- [ ] Dashboard loads
- [ ] Categories display
- [ ] Search works
- [ ] Navigation works

### Shop Dashboard
- [ ] Dashboard loads
- [ ] Statistics display
- [ ] Quick actions work
- [ ] Navigation works

### Admin Panel
- [ ] Admin login works
- [ ] Dashboard loads
- [ ] Sidebar navigation works
- [ ] All screens accessible

---

## 🎯 Quick Test Commands

```bash
# 1. Navigate to app
cd flutter-app

# 2. Get dependencies
flutter pub get

# 3. Check setup
flutter doctor

# 4. Run on Android
flutter run

# 5. Run on Web
flutter run -d chrome

# 6. Run in debug mode
flutter run --debug

# 7. Run in release mode
flutter run --release

# 8. Build APK
flutter build apk

# 9. Build Web
flutter build web
```

---

## 🔗 API Configuration

### Update Backend URL

**File:** `flutter-app/lib/utils/constants.dart`

```dart
// Local Development
const String apiBaseUrl = 'http://localhost:8080';

// Production (Railway)
const String apiBaseUrl = 'https://your-app.railway.app';

// With port
const String apiBaseUrl = 'http://localhost:8080/api';
```

### Test API Connection

Make sure your Spring Boot backend is:
- ✅ Running
- ✅ Accessible at the configured URL
- ✅ CORS enabled (for web testing)

---

## 📝 Next Steps

1. ✅ Install Flutter SDK
2. ✅ Run `flutter pub get`
3. ✅ Configure API URL
4. ✅ Run `flutter run`
5. ✅ Test all screens
6. ✅ Connect to backend

---

**Ready to test! Follow the steps above to run your Flutter app!** 🚀

