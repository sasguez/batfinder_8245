# BatFinder App Icon Update Instructions

## Current Status
The BatFinder purple bat logo (`assets/images/batfinder-1768513763769.png`) has been integrated into the splash screen and app branding has been updated across all platforms.

## Updating the APK/App Icon

To replace the app icon with the BatFinder logo, you have two options:

### Option 1: Using flutter_launcher_icons (Recommended)

1. **Add the package to your `pubspec.yaml`:**
```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/batfinder-1768513763769.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/images/batfinder-1768513763769.png"
```

2. **Run the icon generator:**
```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

3. **Rebuild your app:**
```bash
flutter clean
flutter build apk --release  # For Android
flutter build ios --release  # For iOS
```

### Option 2: Manual Icon Generation

1. **Prepare icon sizes:**
   - Use an online tool like [App Icon Generator](https://www.appicon.co/) or [MakeAppIcon](https://makeappicon.com/)
   - Upload `assets/images/batfinder-1768513763769.png`
   - Download the generated icon sets

2. **Replace Android icons:**
   - Replace files in `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - Icon sizes needed: mdpi (48px), hdpi (72px), xhdpi (96px), xxhdpi (144px), xxxhdpi (192px)

3. **Replace iOS icons:**
   - Replace files in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
   - Update `Contents.json` with proper icon references
   - Icon sizes needed: 20px, 29px, 40px, 58px, 60px, 76px, 80px, 87px, 120px, 152px, 167px, 180px, 1024px

4. **Rebuild your app:**
```bash
flutter clean
flutter build apk --release  # For Android
flutter build ios --release  # For iOS
```

## Verification

After updating the icon:
1. Uninstall the old app from your device
2. Install the newly built APK/IPA
3. Check the app icon on your home screen
4. Verify the icon appears correctly in the app switcher

## Notes
- The splash screen already uses the new BatFinder logo
- All app names have been updated to "BatFinder" across platforms
- The icon background is white to ensure the purple bat logo stands out
- For best results, ensure the logo PNG has transparent background or white background