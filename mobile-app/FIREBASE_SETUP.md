# Firebase Phone Authentication Setup Guide

## Error: CONFIGURATION_NOT_FOUND

This error occurs when Firebase Phone Authentication is not properly configured in your Firebase project.

## Steps to Fix:

### 1. Enable Phone Authentication in Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (or create a new one)
3. Navigate to **Authentication** → **Sign-in method**
4. Click on **Phone** provider
5. Click **Enable** toggle
6. Click **Save**

### 2. Add SHA-1 and SHA-256 Fingerprints

You need to add your app's SHA fingerprints to Firebase:

#### For Debug Build:
```bash
# Windows (PowerShell)
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Your Debug SHA Fingerprints:**
- **SHA-1**: `79:85:26:24:66:B7:DA:C8:09:E6:AF:D6:74:8E:45:A4:E6:6A:35:4E`
- **SHA-256**: `2B:2D:D5:2B:CC:93:3B:4F:59:C2:3F:E5:E8:BB:D6:9E:91:78:D0:72:BA:7C:AE:4F:2A:91:D4:F9:8A:2F:F9:1C`

#### For Release Build:
```bash
# If you have a release keystore
keytool -list -v -keystore your-release-key.keystore -alias your-key-alias
```

#### Add to Firebase:
1. Go to Firebase Console → **Project Settings** → **Your apps**
2. Click on your Android app
3. Scroll down to **SHA certificate fingerprints**
4. Click **Add fingerprint**
5. Paste your **SHA-1** and **SHA-256** values
6. Click **Save**

### 3. Verify google-services.json

1. Make sure `google-services.json` is in `mobile-app/app/` directory
2. The file should contain your Firebase project configuration
3. Verify the `package_name` in the file matches your app's package: `com.saloonvala.android`

### 4. Rebuild the App

After making changes:
```bash
cd D:\saloonvala-main\mobile-app
gradlew.bat clean
gradlew.bat installDebug
```

### 5. Test Phone Authentication

1. Use a test phone number (Firebase allows testing with specific numbers)
2. Or enable test mode in Firebase Console → Authentication → Settings → Phone numbers for testing

## Alternative: Use Test Phone Numbers

For development, you can add test phone numbers in Firebase Console:
1. Go to **Authentication** → **Settings** → **Phone numbers for testing**
2. Add test phone numbers with test OTP codes
3. These will work without actual SMS sending

## Common Issues:

- **CONFIGURATION_NOT_FOUND**: Phone Auth not enabled or SHA fingerprints not added
- **INVALID_PHONE_NUMBER**: Phone number format is incorrect
- **QUOTA_EXCEEDED**: Too many SMS requests (upgrade Firebase plan)

## Quick Test:

After setup, try with a test number:
- Phone: `+1 650-555-1234`
- OTP: `123456` (if test mode enabled)

