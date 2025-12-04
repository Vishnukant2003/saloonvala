# 🔥 CRITICAL: Enable Phone Authentication in Firebase Console

## The Error You're Seeing:
```
CONFIGURATION_NOT_FOUND
[SmsRetrieverHelper] SMS verification code request failed
```

## ✅ Solution: Enable Phone Authentication

Even though you've added SHA fingerprints, **Phone Authentication must be explicitly enabled** in Firebase Console.

### Step-by-Step Instructions:

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Select your project: **saloonvala-b2f13**

2. **Navigate to Authentication**
   - Click on **"Authentication"** in the left sidebar
   - If you don't see it, click the **"Build"** section first

3. **Enable Phone Sign-in Method**
   - Click on **"Sign-in method"** tab (at the top)
   - Find **"Phone"** in the list of providers
   - Click on **"Phone"** to open its settings

4. **Enable Phone Authentication**
   - Toggle the **"Enable"** switch to **ON** (it should turn blue/green)
   - **IMPORTANT**: Leave "Phone numbers for testing" empty for now (or add test numbers)
   - Click **"Save"** button

5. **Wait 1-2 minutes**
   - Firebase needs a moment to propagate the changes

6. **Download Updated google-services.json (Optional but Recommended)**
   - Go to **Project Settings** → **Your apps** → **Android app**
   - Click **"Download google-services.json"**
   - Replace the file in `mobile-app/app/google-services.json`

7. **Rebuild Your App**
   ```bash
   cd D:\saloonvala-main\mobile-app
   gradlew.bat clean
   gradlew.bat installDebug
   ```

## Visual Guide:

```
Firebase Console
├── Authentication (left sidebar)
    ├── Sign-in method (tab)
        ├── Phone (click to open)
            ├── Enable toggle → ON
            ├── Save button
```

## After Enabling:

Once Phone Authentication is enabled, you should see:
- ✅ No more `CONFIGURATION_NOT_FOUND` errors
- ✅ OTP SMS will be sent to your phone number
- ✅ The RecaptchaActivity will work properly

## Test Phone Numbers (Optional):

For development, you can add test phone numbers:
1. In Phone settings, scroll to **"Phone numbers for testing"**
2. Click **"Add phone number"**
3. Add: `+918149230130` with OTP: `123456`
4. These will work without sending real SMS

## Still Not Working?

If you still get errors after enabling:
1. **Verify** Phone Authentication is enabled (toggle is ON)
2. **Check** SHA fingerprints are still there
3. **Download** fresh `google-services.json`
4. **Clean rebuild**: `gradlew.bat clean installDebug`
5. **Wait** 2-3 minutes for Firebase to sync

