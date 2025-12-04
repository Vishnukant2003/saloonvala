# 🚀 Quick Start Guide

## Step 1: Install Flutter (if not installed)

```bash
# Check if Flutter is installed
flutter doctor

# If not installed, download from:
# https://docs.flutter.dev/get-started/install
```

## Step 2: Navigate to Flutter App

```bash
cd flutter-app
```

## Step 3: Install Dependencies

```bash
flutter pub get
```

## Step 4: Run the App

```bash
# Run on connected device/emulator
flutter run

# Or build APK
flutter build apk
```

## ✅ What You'll See

The **User Dashboard** screen with:
- Welcome section
- Search bar
- Categories
- Trending services
- Quick actions
- Offers
- Bookings list
- Nearby salons

## 🔧 Configuration

### Update API URL (if needed)
Edit: `lib/utils/constants.dart`
```dart
static const String apiBaseUrl = 'https://your-api-url.com/';
```

### Firebase Setup (Optional)
1. Create Firebase project
2. Add `firebase_options.dart`
3. Uncomment Firebase init in `main.dart`

## 📱 Testing

- **Android**: Use Android Studio emulator or physical device
- **iOS**: Use Xcode simulator (Mac only)
- **Both platforms from one codebase!**

## 🎉 Success!

You now have a Flutter app running with:
- ✅ Pure Dart code (no XML!)
- ✅ User Dashboard working
- ✅ Connected to your backend API
- ✅ Ready to add more screens

---

**Next**: Add authentication screens, booking flow, etc. All in Dart! 🎯

