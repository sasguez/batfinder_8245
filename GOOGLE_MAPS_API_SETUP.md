# Google Maps API Setup for BatFinder

## 🔍 Current Status

The BatFinder application is fully functional with the following features:
- ✅ Complete database schema with test data
- ✅ Incident reporting and management
- ✅ User profiles (ciudadano, autoridad, ONG)
- ✅ Alert system and notifications
- ✅ Chat functionality
- ✅ Analytics dashboard

## ⚠️ Google Maps API Key Issue

**Current Error**: Invalid Google Maps API key causing console warnings

**Impact**: The map features require a valid Google Maps API key to display maps properly in production.

## 📋 MVP Considerations

Since this is an MVP (Minimum Viable Product), you have two options:

### Option 1: Continue with Mock Data (Recommended for MVP)
The application works fully with test database data. Map functionality can be demonstrated using:
- Static map images
- Location coordinates from test data
- Map-like UI components without actual Google Maps integration

### Option 2: Add Production Google Maps API Key

If you want to enable real Google Maps functionality:

## 🔧 How to Add Google Maps API Key

### Step 1: Get API Key from Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing project
3. Enable these APIs:
   - Maps SDK for Android
   - Maps SDK for iOS
   - Maps JavaScript API
   - Places API (optional, for location search)
4. Go to "Credentials" section
5. Create API Key
6. Restrict API key (recommended):
   - Set application restrictions (HTTP referrers, IP addresses, or app IDs)
   - Set API restrictions (only enable Maps SDK and Places API)

### Step 2: Replace API Keys in Project Files

Replace `YOUR_GOOGLE_MAPS_API_KEY_HERE` in these files:

#### Android Configuration
**File**: `android/app/src/main/AndroidManifest.xml`
```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_ACTUAL_API_KEY_HERE"/>
```

#### iOS Configuration  
**File**: `ios/Runner/AppDelegate.swift`
```swift
GMSServices.provideAPIKey("YOUR_ACTUAL_API_KEY_HERE")
```

**File**: `ios/Runner/Info.plist`
```xml
<key>GOOGLE_MAPS_API_KEY</key>
<string>YOUR_ACTUAL_API_KEY_HERE</string>
```

#### Web Configuration
**File**: `web/flutter_plugins.js`
```javascript
script.src = 'https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_API_KEY_HERE&libraries=places';
```

### Step 3: Environment Variables (Recommended for Security)

Instead of hardcoding API keys, use environment variables:

1. Create `.env` file (already exists in project):
```
GOOGLE_MAPS_API_KEY=your_actual_api_key_here
```

2. Add `.env` to `.gitignore` (protect your keys)

3. Access in Dart code:
```dart
const String apiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
```

## 🚀 Next Steps

1. **For MVP Testing**: Continue using the app with test data - all features work
2. **For Production**: Follow steps above to add real Google Maps API key
3. **Cost Consideration**: Google Maps API has usage limits and costs - plan accordingly

## 📊 Current Test Data

The database includes:
- 5 test users (María, Roberto, Comandante López, Director García, Ana Rodríguez)
- Multiple incident reports with locations
- Comments and media attachments
- Community engagement metrics
- Response time benchmarks

All features are fully functional with this test data.

## 💡 Recommendations

- Test the app thoroughly with existing test data
- Add Google Maps API key only when ready for production deployment
- Monitor API usage and costs before going live
- Consider map alternatives (Mapbox, OpenStreetMap) for cost optimization

## 🔒 Security Notes

- NEVER commit API keys to Git
- Use environment variables for sensitive data
- Restrict API keys to specific domains/apps
- Monitor API usage in Google Cloud Console
- Rotate keys periodically for security