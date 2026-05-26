# Google Maps Setup Guide

## Why the map doesn't show on Android

The Google Maps API requires a valid API key for Android. Currently, your `android/local.properties` has a placeholder key that needs to be replaced with a real one.

## Steps to Fix

### 1. Get a Google Maps API Key

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Navigate to **APIs & Services** → **Credentials**
4. Click **Create Credentials** → **API Key**
5. Copy the generated API key

### 2. Enable Required APIs

In Google Cloud Console:
1. Go to **APIs & Services** → **Library**
2. Search for and enable:
   - **Maps SDK for Android** (required for mobile)
   - **Maps JavaScript API** (optional, for web)

### 3. Add API Key to Android

Open `android/local.properties` and replace the placeholder:

```properties
MAPS_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
```

### 4. (Optional) Restrict the API Key

For production, restrict your API key:
1. In Google Cloud Console → **Credentials**
2. Edit your API key
3. Under **Application restrictions**:
   - Choose **Android apps**
   - Add package name: `com.example.techserve_admin`
   - Add SHA-1 certificate fingerprint (get with `keytool` or `gradlew signingReport`)

### 5. Rebuild the App

```bash
flutter clean
flutter run
```

## For Web/Desktop

Edit `web/index.html` and replace `YOUR_API_KEY`:

```html
<script src="https://maps.googleapis.com/maps/api/js?key=YOUR_ACTUAL_KEY"></script>
```

## Troubleshooting

- **Map shows gray screen**: API key is invalid or not enabled
- **"This page can't load Google Maps correctly"**: Enable Maps SDK for Android
- **Map works on emulator but not real device**: Add SHA-1 fingerprint to API restrictions
- **Build fails**: Run `flutter clean` and rebuild

## Free Tier Limits

Google Maps offers $200/month free credit:
- ~28,000 map loads/month for free
- Plenty for development and small production deployments
