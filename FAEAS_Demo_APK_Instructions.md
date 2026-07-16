# FAEAS Demo APK - Build Instructions

## Current Status
I've successfully modified the Flutter app to bypass authentication for demo purposes:

### Changes Made:
1. **Removed Authentication Flow**: App now starts directly on the home screen
2. **Mock Data Integration**: Uses mock data instead of API calls
3. **Demo Report Submission**: Report form works with simulated success messages
4. **Updated App Identity**: Changed to "FAEAS Demo" with package name `com.faeas.demo`

### Build Issue:
The APK build is failing due to Android NDK license requirements. This is a common issue that can be resolved by:

## Option 1: Accept Android SDK Licenses (Recommended)
```bash
# Find your Android SDK path (usually):
# Windows: C:\Users\[username]\AppData\Local\Android\Sdk
# Mac: ~/Library/Android/sdk
# Linux: ~/Android/Sdk

# Run sdkmanager to accept licenses:
sdkmanager --licenses
# Type 'y' for each license prompt
```

## Option 2: Install Android Studio (Easiest)
1. Download and install Android Studio
2. Open Android Studio
3. Go to SDK Manager and accept all licenses
4. This will automatically configure everything needed

## Option 3: Manual APK Build
After resolving the license issue, run:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## Demo Features Available:
- ✅ Home dashboard with weather and alerts
- ✅ Disaster reporting form (simulated submission)
- ✅ Community feed with mock disaster reports
- ✅ Map screen (placeholder)
- ✅ NGO dashboard
- ✅ Profile and settings screens
- ✅ AI chatbot screen (placeholder)
- ✅ Responsive design for tablets

## What Your Friend Can Test:
1. Navigate through all screens using bottom navigation
2. Submit disaster reports (will show success message)
3. View community feed with sample disaster reports
4. Experience the UI/UX design
5. Test responsive layout on different screen sizes

## Note:
This is a demo version with mock data. The actual backend integration and real-time features are not included in this build.