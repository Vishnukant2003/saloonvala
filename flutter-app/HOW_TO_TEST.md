# 🧪 How to Test the Flutter App - Step by Step

## 🚀 Quick Start (Fastest Method)

### Option 1: Test on Web (Easiest - No Emulator Needed!)

```bash
# 1. Navigate to Flutter app
cd flutter-app

# 2. Install dependencies
flutter pub get

# 3. Run on Chrome browser
flutter run -d chrome
```

**That's it!** The app will open in Chrome browser! 🎉

---

## 📋 Complete Testing Guide

### Step 1: Check Flutter Installation

**First, verify Flutter is installed:**

```bash
flutter doctor
```

**If Flutter is not installed:**
1. Download from: https://flutter.dev/docs/get-started/install
2. Extract and add to PATH
3. Run `flutter doctor` again

**Expected output:**
```
✓ Flutter (Channel stable, ...)
✓ Android toolchain (for Android)
✓ Chrome (for web)
```

---

### Step 2: Install Dependencies

```bash
cd flutter-app
flutter pub get
```

This installs all packages from `pubspec.yaml`:
- provider (state management)
- http (API calls)
- shared_preferences (storage)
- geolocator (location)
- etc.

---

### Step 3: Configure API URL

**Current API URL:** Already set to `https://admin.saloonvala.in/`

**To change it, edit:** `lib/utils/constants.dart`

```dart
class AppConstants {
  static const String apiBaseUrl = 'YOUR_BACKEND_URL';
  // Current: 'https://admin.saloonvala.in/'
}
```

**Options:**
- Local: `http://localhost:8080`
- Production: `https://admin.saloonvala.in/`
- Railway: `https://your-app.railway.app`

---

### Step 4: Run the App

#### A. Test on Web (Recommended for Quick Testing)

```bash
flutter run -d chrome
```

**Benefits:**
- ✅ No emulator needed
- ✅ Fast startup
- ✅ Easy to debug
- ✅ Hot reload works

#### B. Test on Android

**Requirements:**
- Android Studio installed
- Android emulator running OR device connected

**Run:**
```bash
flutter run
```

**Or in Android Studio:**
1. Open `flutter-app` folder
2. Click "Run" button
3. Select device

#### C. Test on iOS (Mac only)

**Requirements:**
- Mac with Xcode
- iOS Simulator

**Run:**
```bash
flutter run -d ios
```

---

## 🔧 Testing Features

### Test Authentication
1. ✅ App opens → Main screen shows
2. ✅ Click "User Login" → Login screen opens
3. ✅ Enter mobile number → OTP/Login works
4. ✅ After login → Welcome screen → Dashboard

### Test User Dashboard
1. ✅ Dashboard loads
2. ✅ Welcome message shows
3. ✅ Categories display
4. ✅ Search bar works
5. ✅ Navigation works

### Test Shop Dashboard
1. ✅ Login as shop owner
2. ✅ Shop dashboard loads
3. ✅ Statistics show
4. ✅ Quick actions work

### Test Admin Panel
1. ✅ Navigate to `/admin-login`
2. ✅ Login screen shows
3. ✅ Enter credentials
4. ✅ Admin dashboard loads
5. ✅ Sidebar navigation works

---

## 🛠️ Troubleshooting

### Issue: "flutter: command not found"
**Solution:**
```bash
# Add Flutter to PATH
# Windows: Add C:\flutter\bin to System Environment Variables
# Restart terminal
flutter doctor
```

### Issue: "Packages not found"
**Solution:**
```bash
flutter clean
flutter pub get
```

### Issue: "API connection failed"
**Solution:**
1. Check API URL in `lib/utils/constants.dart`
2. Ensure backend server is running
3. Check internet connection
4. Verify CORS settings (for web)

### Issue: "Web not enabled"
**Solution:**
```bash
flutter config --enable-web
flutter create --platforms=web .
```

### Issue: Build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter doctor
```

---

## 📱 Platform-Specific Testing

### Web Testing (Easiest!)
```bash
# Run in Chrome
flutter run -d chrome

# Run in Edge
flutter run -d edge

# Run in Web Server (access from any browser)
flutter run -d web-server --web-port 8080
```

### Android Testing
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Build APK
flutter build apk
```

### iOS Testing (Mac)
```bash
# List available devices
flutter devices

# Run on simulator
flutter run -d ios

# Run on specific device
flutter run -d <device-id>
```

---

## ✅ Testing Checklist

### Basic Functionality
- [ ] App launches without errors
- [ ] Main screen displays correctly
- [ ] Navigation works
- [ ] All screens are accessible
- [ ] UI looks correct

### Authentication
- [ ] Login screen works
- [ ] Register screen works
- [ ] Welcome screen shows
- [ ] Dashboard loads after login

### User Features
- [ ] User dashboard loads
- [ ] Categories display
- [ ] Search works
- [ ] Profile screen works
- [ ] Bookings screen works

### Shop Features
- [ ] Shop dashboard loads
- [ ] Statistics display
- [ ] Quick actions work
- [ ] Management screens accessible

### Admin Panel
- [ ] Admin login works
- [ ] Dashboard loads
- [ ] All admin screens accessible
- [ ] Data tables display

---

## 🎯 Quick Test Commands

```bash
# 1. Go to app directory
cd flutter-app

# 2. Get dependencies
flutter pub get

# 3. Check setup
flutter doctor

# 4. Run on web (easiest!)
flutter run -d chrome

# 5. Run on Android
flutter run

# 6. Run in debug mode
flutter run --debug

# 7. Run in release mode
flutter run --release

# 8. Hot reload (press 'r' in terminal)
# 9. Hot restart (press 'R' in terminal)
# 10. Quit (press 'q' in terminal)
```

---

## 🔍 Debugging Tips

### Enable Debug Mode
```bash
flutter run --debug
```

### View Logs
- Android: `flutter logs`
- Or check console output

### Hot Reload
- Press `r` in terminal → Reloads code
- Press `R` in terminal → Full restart
- Press `q` → Quit app

---

## 📝 Step-by-Step Test Flow

### Complete Test Process:

1. **Setup (One Time)**
   ```bash
   # Install Flutter SDK
   # Add to PATH
   flutter doctor
   ```

2. **Prepare App**
   ```bash
   cd flutter-app
   flutter pub get
   ```

3. **Configure API**
   - Edit `lib/utils/constants.dart`
   - Set `apiBaseUrl` to your backend URL

4. **Start Backend** (in separate terminal)
   ```bash
   cd ../backend
   mvn spring-boot:run
   ```

5. **Run Flutter App**
   ```bash
   flutter run -d chrome  # Web - easiest!
   ```

6. **Test Features**
   - Navigate through all screens
   - Test authentication
   - Test API calls
   - Verify UI

---

## 🎯 Expected Results

When you run `flutter run -d chrome`:

1. ✅ App builds successfully
2. ✅ Chrome browser opens
3. ✅ Main screen appears
4. ✅ All navigation works
5. ✅ UI looks beautiful
6. ✅ Hot reload works (press 'r')

---

## 💡 Pro Tips

1. **Web is fastest** - Use Chrome for quick testing
2. **Hot Reload** - Make changes and press 'r' to see instantly
3. **Debug Console** - Check terminal for errors
4. **Network Tab** - Check browser DevTools for API calls

---

## 📞 Need Help?

### Check Flutter Setup
```bash
flutter doctor -v
```

### Check Dependencies
```bash
flutter pub get
flutter pub outdated
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

---

**Ready to test! Follow the steps above and your Flutter app will run!** 🚀

**Start with:** `flutter run -d chrome` (easiest way!)

