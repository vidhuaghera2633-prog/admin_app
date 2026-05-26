# TechServe Admin Dashboard

A complete Flutter admin dashboard for field-service / complaint-management.

## Setup

1. Install Flutter SDK: https://docs.flutter.dev/get-started/install
2. Run `flutter pub get`
3. For Android map support, add this to `android/local.properties`:
    - `MAPS_API_KEY=YOUR_ANDROID_MAPS_API_KEY`
4. Run `flutter run -d chrome` (web), or `flutter run` for desktop/mobile

### Android Google Maps setup

To display the map on Android, add your Google Maps key in `android/local.properties`:

```properties
MAPS_API_KEY=YOUR_ANDROID_MAPS_API_KEY
```

**📋 See [GOOGLE_MAPS_SETUP.md](GOOGLE_MAPS_SETUP.md) for detailed step-by-step instructions.**

Then rebuild the app with `flutter clean` and `flutter run`. Without this key, the map will show a warning overlay on mobile.

## Required packages (pubspec.yaml)
- go_router: ^14.0.0
- fl_chart: ^0.68.0
- google_fonts: ^6.2.1
- intl: ^0.19.0
- provider: ^6.1.2
- flutter_animate: ^4.5.0

## Login Credentials
- Email: admin@techserve.com
- Password: admin123
- Any 6-digit OTP code will work in demo mode

## Features
✅ Login Screen with 2FA OTP
✅ Adaptive Sidebar (Desktop/Tablet/Mobile)
✅ Dashboard with KPI cards, Charts (fl_chart), Heatmap, Recent Complaints
✅ Complaints List with search, filter, sort, assign, reject
✅ Complaint Detail with tabs (Overview, Activity, Parts, History)
✅ Technician Management with form sheet (add/edit/delete)
✅ Scheduling (Week/By Technician/List views)
✅ Reports & Analytics (4 tabs with charts)
✅ Settings (Company/SLA/Notifications/Users/Templates/Security)
✅ Material 3, Indigo brand color, Google Fonts (Inter)
✅ Provider state management
✅ Mock data (6 complaints, 5 technicians, 5 scheduled jobs)
✅ Responsive breakpoints: <600px, 600-900px, >900px

## File Structure
lib/
├── main.dart
├── router.dart
├── theme/app_theme.dart
├── models/{complaint,technician,scheduled_job}.dart
├── data/mock_data.dart
├── providers/{auth,complaints,technicians}_provider.dart
├── widgets/shared_widgets.dart
└── screens/
    ├── login/
    ├── layout/ (adaptive_scaffold, sidebar, header_bar)
    ├── dashboard/
    ├── complaints/
    ├── technicians/
    ├── scheduling/
    ├── reports/
    └── settings/
