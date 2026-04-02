# Smart Event Frontend (Flutter) 📱

A high-performance, Material 3 Flutter application for event attendees, staff, and administrators. 

---

## 🛠️ Key Features

### 🔔 Real-time Notification Center
Attendees receive instant alerts if their registered events are updated or changed. A persistent badge indicates unread messages.

### 🎫 Interactive "My Tickets"
Attendees can browse their registrations and **Cancel/Delete** tickets directly from the mobile app.

### 📶 Offline-Ready Event Lists
The app caches event details for quick lookup, ensuring a smooth experience even in spotty network conditions.

### 🛡️ Privacy First (State Reset)
The app's memory is completely wiped on logout, ensuring that no ticket or notification data is visible to the next user on the same device.

---

## 📂 Project Structure

```
frontend/lib/
├── core//               # Logic, Routing, Constants, Theme
├── data//               # Models (Event, Ticket, Notification, User), Repositories
└── features//
    ├── auth//           # Login, Register flows
    ├── attendee//       # Home, Events List, Tickets, Notifications
    ├── staff//           # QR Scanner, History, Stats
    └── admin//           # Dashboard, Analytics, CRUD Events
```

---

## ⚙️ Configuration

### API IP Address
Update `lib/core/constants/api_constants.dart` with your Server IP:

```dart
static const String baseUrl = 'http://192.168.x.x:3000/api'; // Physical Device
// OR
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android Emulator
```

---

## 🚀 Getting Started

1.  `flutter pub get`
2.  `flutter run`

---

## 📦 Features Implementation Status

-   [x] **Authentication**: Login/Logout/Register with Privacy Reset.
-   [x] **Attendee Flow**: Home -> Register -> Ticket -> **Delete Ticket**.
-   [x] **Staff Flow**: Dashboard -> Scan -> Validate -> History.
-   [x] **Admin Flow**: Dashboard -> CRUD Events -> Analytics -> Export.
-   [x] **Smart Notifications**: Notification Center + Badge System.

---

## 📜 License
Licensed under the **MIT License**.
