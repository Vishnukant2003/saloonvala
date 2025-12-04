# 🚀 How to Run and Test the Flutter App

## ✅ Quick Start (3 Steps!)

### Step 1: Install Flutter
```bash
# Download Flutter from: https://flutter.dev/docs/get-started/install
# Extract and add to PATH

# Verify installation:
flutter doctor
```

### Step 2: Install Dependencies
```bash
cd flutter-app
flutter pub get
```

### Step 3: Run the App
```bash
# For Android (device/emulator)
flutter run

# For Web (browser)
flutter run -d chrome

# For iOS (Mac only)
flutter run -d ios
```

---

## ⚙️ Before Running - IMPORTANT!

### 1. Configure API URL

**Edit:** `lib/utils/constants.dart`

```dart
// Change this line to your backend URL:
const String apiBaseUrl = 'http://localhost:8080'; 
// OR your Railway/production URL
```

### 2. Start Backend Server

Make sure your Spring Boot backend is running:
```bash
# In backend directory
mvn spring-boot:run
# OR
./mvnw spring-boot:run
```

---

## 📱 Test on Different Platforms

### Android
```bash
flutter run
```
- Requires: Android Studio + Emulator or Device

### Web (Easiest for Quick Test!)
```bash
flutter run -d chrome
```
- Opens in Chrome browser
- Fastest way to test UI

### iOS (Mac only)
```bash
flutter run -d ios
```
- Requires: Xcode + Simulator

---

## 🔍 Testing Checklist

### ✅ Quick Tests
- [ ] App launches
- [ ] Main screen shows
- [ ] Login screen works
- [ ] Dashboard loads
- [ ] Navigation works

### ✅ Full Tests
- [ ] All screens accessible
- [ ] API calls work
- [ ] Data loads correctly
- [ ] Forms submit properly

---

## 🛠️ Common Issues & Fixes

**Issue: "Flutter not found"**
```bash
# Add Flutter to PATH, then:
flutter doctor
```

**Issue: "Packages missing"**
```bash
flutter clean
flutter pub get
```

**Issue: "API connection failed"**
- Check API URL in `constants.dart`
- Ensure backend is running
- Check network connection

---

## 📋 Complete Test Flow

```bash
# 1. Go to Flutter app folder
cd flutter-app

# 2. Install dependencies
flutter pub get

# 3. Check Flutter setup
flutter doctor

# 4. Start backend server (in another terminal)
cd ../backend
mvn spring-boot:run

# 5. Update API URL in constants.dart
# Set apiBaseUrl to 'http://localhost:8080'

# 6. Run Flutter app
flutter run -d chrome  # For web (easiest!)
# OR
flutter run            # For Android
```

---

## 🎯 Expected Behavior

### When You Run:
1. ✅ App builds successfully
2. ✅ Main screen appears
3. ✅ You can navigate to all screens
4. ✅ UI looks beautiful
5. ✅ All features work

---

## 💡 Tips

- **Web is fastest** - Use `flutter run -d chrome` for quick testing
- **Hot Reload** - Press `r` in terminal to hot reload
- **Hot Restart** - Press `R` in terminal to hot restart
- **Quit** - Press `q` to quit

---

**Ready to test! Follow the steps above!** 🚀

