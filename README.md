# Smart Event Check-in App

A comprehensive, production-ready Flutter mobile application for event check-in management with QR code generation and scanning capabilities.

## Features

### 🎯 Three User Roles

#### 1. Attendee
- **Event Discovery**: Browse upcoming events with real-time data.
- **Registration**: Seamlessly register for events.
- **My Tickets**: View purchased/registered tickets.
- **QR Tickets**: Generate dynamic QR codes for check-in.
- **Profile**: Manage personal details and quick access to tickets.

#### 2. Event Staff
- **QR Scanner**: Fast and reliable ticket scanning using `mobile_scanner`.
- **Validation Logic**: Instant feedback (Valid/Invalid/Duplicate).
- **Scan History**: View local history of recent scans.
- **Stats**: Daily check-in counters.

#### 3. Admin
- **Dashboard**: High-level analytics (Total Events, Active Check-ins, Attendance Rates).
- **Event Management**: Create, Edit, and Delete events with form validation.
- **Live Monitoring**: Track check-ins in real-time.
- **Reporting**: Export attendee lists and stats to CSV.

## Tech Stack

- **Framework**: Flutter 3.16+
- **State Management**: Provider (ChangeNotifier)
- **Routing**: GoRouter (Deep linking support)
- **QR Integration**: 
  - `qr_flutter` (Generation)
  - `mobile_scanner` (Scanning)
- **Networking**: `http` with Custom Interceptors
- **Utils**: `intl` (Date formatting), `file_saver` (Exports)
- **UI**: Material 3 Design, Custom Gradients, Responsive Layouts

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # Main app widget (Global Providers)
├── core/
│   ├── theme/               # Theme configuration (Colors, TextStyles)
│   ├── constants/           # App constants & API Endpoints
│   ├── utils/               # Validators & Formatters
│   ├── widgets/             # Reusable widgets (Buttons, Cards, Inputs)
│   └── routes/              # AppRouter configuration
├── data/
│   ├── models/              # Data models (Event, Ticket, User)
│   ├── services/            # ApiService, Storage
│   └── repositories/        # EventRepo, TicketRepo, StaffRepo, AdminRepo
└── features/
    ├── auth/                # Login, Register
    ├── attendee/            # Home, Events List, Details, Tickets, Profile
    ├── staff/               # Dashboard, Scanner, History
    └── admin/               # Dashboard, Event Mgmt, Analytics
```

## Getting Started

### Prerequisites

- Flutter SDK 3.16+
- Dart 3.2+
- Android Studio / VS Code
- Android Device/Emulator (Min SDK 21)
- iOS Device/Simulator (iOS 12+)

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd "SMART EVENT CHECK-IN APP"
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

## Configuration

### API Configuration
Update `lib/core/constants/api_constants.dart` with your backend URL:
```dart
static const String baseUrl = 'https://your-api.com/api/v1';
```

### Permissions
The app strictly requires camera usage for the Staff role.

**Android** (`AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to scan ticket QR codes.</string>
```

## Features Implementation Status

### ✅ Completed Features
- **Authentication**: Login/Logout/Register with Token Management.
- **Attendee Flow**: Browse -> Register -> Ticket -> QR.
- **Staff Flow**: Dashboard -> Scan -> Validate -> History.
- **Admin Flow**: Dashboard -> CRUD Events -> Analytics -> Export.
- **UI/UX**: Polished Material 3 design with dark mode compatibility foundations.

### 🚀 Future Enhancements
- Offline Mode (Local Database sync).
- Push Notifications for event updates.
- Payment Gateway integration for paid tickets.
- Advanced Analytics Charts.

## Contributing

1. Fork the project.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

## License

This project is licensed under the MIT License.
