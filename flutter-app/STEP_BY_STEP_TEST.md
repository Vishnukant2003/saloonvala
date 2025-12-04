# 🧪 Step-by-Step Testing Guide

## 🎯 Simple 5-Step Process

### Step 1: Check if Flutter is Installed

**Open terminal/command prompt and run:**
```bash
flutter --version
```

**If Flutter is NOT installed:**
1. Go to: https://flutter.dev/docs/get-started/install
2. Download Flutter SDK
3. Extract to a folder (e.g., `C:\flutter`)
4. Add `C:\flutter\bin` to your system PATH
5. Restart terminal
6. Run `flutter --version` again to verify

---

### Step 2: Navigate to Flutter App Folder

```bash
cd D:\saloonvala-main\flutter-app
```

**Or if you're already in the project root:**
```bash
cd flutter-app
```

---

### Step 3: Install Dependencies

```bash
flutter pub get
```

**This will:**
- Download all required packages
- Install them in your project
- Take 1-2 minutes

**Expected output:**
```
Running "flutter pub get" in flutter-app...
Resolving dependencies...
Got dependencies!
```

---

### Step 4: Configure API URL (Optional)

**Current API URL is:** `https://admin.saloonvala.in/`

**To change it (for local testing):**
1. Open: `lib/utils/constants.dart`
2. Find: `static const String apiBaseUrl = 'https://admin.saloonvala.in/';`
3. Change to: `static const String apiBaseUrl = 'http://localhost:8080';`
4. Save file

**Note:** Make sure your Spring Boot backend is running if using localhost!

---

### Step 5: Run the App!

**Option A: Web (Easiest - Recommended!)**

```bash
flutter run -d chrome
```

**This will:**
- Build the Flutter app
- Open Chrome browser
- Launch the app in the browser
- Show you the Main screen

**Option B: Android**

```bash
flutter run
```

**Requirements:**
- Android Studio installed
- Android emulator running OR device connected

---

## ✅ What to Expect

When you run `flutter run -d chrome`:

1. ✅ Flutter starts building
2. ✅ "Building web application..." appears
3. ✅ Chrome browser opens automatically
4. ✅ App loads in the browser
5. ✅ Main screen appears with login/register buttons

---

## 🧪 Testing Checklist

Once the app is running:

### Test Basic Navigation
- [ ] Main screen shows correctly
- [ ] Click "User Login" → Login screen opens
- [ ] Click "Shop Owner Login" → Login screen opens
- [ ] Click back button → Returns to main screen

### Test Authentication
- [ ] Enter mobile number in login
- [ ] Click login button
- [ ] See welcome screen (after successful login)
- [ ] Dashboard loads

### Test Dashboards
- [ ] User dashboard displays all sections
- [ ] Shop dashboard displays statistics
- [ ] Navigation between screens works

### Test Admin Panel
- [ ] Navigate to admin login
- [ ] Login screen appears
- [ ] After login, admin dashboard shows

---

## 🛠️ Troubleshooting

### Problem: "flutter: command not found"
**Solution:**
- Flutter is not installed or not in PATH
- Install Flutter and add to PATH
- Restart terminal

### Problem: "Error: No pubspec.yaml file found"
**Solution:**
- You're not in the correct directory
- Run: `cd flutter-app` first

### Problem: "Packages not found"
**Solution:**
```bash
flutter clean
flutter pub get
```

### Problem: "API connection failed"
**Solution:**
1. Check API URL in `lib/utils/constants.dart`
2. Ensure backend server is running
3. Check internet connection

### Problem: "Build failed"
**Solution:**
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter run -d chrome
```

---

## 💡 Tips for Testing

### 1. Use Web First (Easiest!)
```bash
flutter run -d chrome
```
- No emulator needed
- Fastest startup
- Easy debugging

### 2. Hot Reload
- Press `r` in terminal → Reloads code instantly
- Press `R` → Full restart
- Press `q` → Quit app

### 3. View Errors
- Check terminal output for errors
- Use browser DevTools (F12) for web
- Check console logs

### 4. Test API Calls
- Open browser DevTools (F12)
- Go to "Network" tab
- See all API requests/responses

---

## 📋 Complete Test Command Sequence

```bash
# 1. Check Flutter
flutter --version

# 2. Go to app folder
cd flutter-app

# 3. Install packages
flutter pub get

# 4. Check setup
flutter doctor

# 5. Run on web
flutter run -d chrome
```

---

## 🎯 Expected Result

**After running `flutter run -d chrome`:**

1. ✅ Terminal shows: "Building web application..."
2. ✅ Chrome browser opens
3. ✅ URL shows: `http://localhost:xxxxx`
4. ✅ App displays in browser
5. ✅ You see the Main screen with buttons

---

## 🚀 Quick Start Commands

**Copy and paste these commands:**

```bash
cd flutter-app
flutter pub get
flutter run -d chrome
```

**That's it! App will open in Chrome!** 🎉

---

## 📝 Next Steps After Testing

1. ✅ Verify all screens load
2. ✅ Test navigation
3. ✅ Test API calls (if backend running)
4. ✅ Test on Android/iOS
5. ✅ Fix any issues found

---

**Ready to test? Run these commands now!**

```bash
cd flutter-app
flutter pub get
flutter run -d chrome
```

**Your Flutter app will open in Chrome!** 🚀

