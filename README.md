# 🪥 SmileTrack — Brushing Habit Management App

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey)](#)

**SmileTrack** is an offline-first oral hygiene tracking application built with Flutter. It helps users build and maintain consistent oral care routines with a guided 2-minute brushing timer, morning & evening habit tracking, custom notification reminders, and comprehensive calendar analytics.

---

## ✨ Features

- **⏱️ Guided 2-Minute Brushing Timer**
  - Quadrant-by-quadrant brushing guidance (Top Left, Top Right, Bottom Left, Bottom Right).
  - Smooth animations, visual progress indicators, and session completion celebrations.
  - Automatically identifies and logs **Morning** vs. **Evening** sessions based on time of day.

- **🔥 Habit & Streak Tracking**
  - Daily Morning & Evening brushing checklist.
  - Current streak and best streak counters.
  - Interactive monthly calendar with color-coded daily status (Both sessions, One session, or Missed).

- **🔔 Smart Push Notifications & Reminders**
  - Real local push notifications powered by `flutter_local_notifications` and exact alarm scheduling.
  - Custom reminder times for both morning (e.g., 8:00 AM) and evening (e.g., 9:30 PM).
  - Timezone-aware scheduling (`timezone` package) ensuring alerts fire at the correct local minute.
  - One-tap "Send Test Alert" to verify permissions and notifications instantly.

- **🔐 Local SQLite Database & Authentication**
  - Offline-first architecture using `sqflite`.
  - Secure email registration with OTP verification.
  - Fully functional **Forgot Password** workflow with 6-digit OTP reset directly updating SQLite.
  - Persistent login sessions that survive app restarts.

- **🌍 Preferences & Personalization**
  - Searchable country picker with real national emoji flags.
  - Automatic timezone synchronization.
  - Dynamic app themes (Mint Green, Ocean Blue, Coral Pink).
  - Dark mode support.

- **🤖 AI Dental Quizzes & Hygiene Tips**
  - Daily oral care trivia and tips.
  - Optional Google Gemini AI integration for interactive dental hygiene quizzes.

---

## 🛠️ Tech Stack & Architecture

- **Framework**: [Flutter](https://flutter.dev) (Dart 3.x)
- **State Management**: [Riverpod](https://riverpod.dev) (`flutter_riverpod`)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Local Database**: [SQLite](https://pub.dev/packages/sqflite) (`sqflite` + `path`)
- **Local Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) with Android exact alarm scheduling
- **Timezone Management**: [timezone](https://pub.dev/packages/timezone)
- **Animations**: `flutter_animate`, `lottie`
- **AI Integration**: `google_generative_ai` (Gemini API)

---

## 📂 Project Structure

```
smiletrack/
├── android/                  # Android native project & manifest configurations
├── ios/                      # iOS native project
├── lib/
│   ├── core/
│   │   ├── constants/        # Route names, country list with flags
│   │   ├── services/         # SQLite DatabaseHelper, NotificationService
│   │   └── theme/            # AppTheme, color schemes, typography
│   ├── features/
│   │   ├── auth/             # Login, Register, Forgot Password, OTP screens & repo
│   │   ├── brushing/         # Timer screen, session models & brushing repository
│   │   ├── home/             # Dashboard, streak cards, monthly calendar
│   │   ├── settings/         # Reminders, Country picker, theme & password settings
│   │   └── tips/             # Dental hygiene articles & tips
│   ├── shared/               # Shared widgets and global Riverpod providers
│   └── main.dart             # Application entrypoint & initialization
├── .env                      # Environment configuration (API keys)
└── pubspec.yaml              # Dependencies and project metadata
```

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (>= 3.0.0)
- Android Studio / Xcode
- Java Development Kit (JDK 17 recommended)
- Connected Android device or Emulator

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/SmileTrack-BrushingHabitManagementApp.git
cd SmileTrack-BrushingHabitManagementApp/smiletrack
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Configure Environment Variables
Create or verify the `.env` file in the `smiletrack/` root directory:
```env
# Google Gemini API Key (optional, for AI dental quizzes)
GEMINI_API_KEY=YOUR_GEMINI_API_KEY_HERE

APP_ENV=development
APP_NAME=SmileTrack
```

### 4. Run the Application
Launch the app on your connected device or emulator:
```bash
flutter run --dart-define-from-file=.env --android-skip-build-dependency-validation
```

---

## 📦 Building Android APKs

### Option 1: Release APK *(Recommended for sharing)*
Builds an optimized, production-ready APK:
```bash
flutter build apk --release --dart-define-from-file=.env --android-skip-build-dependency-validation
```
📂 **Output:** `build/app/outputs/flutter-apk/app-release.apk`

---

### Option 2: Split-Per-ABI APK *(Smaller download size)*
Builds separate APKs for specific CPU architectures (e.g. `arm64-v8a` for modern devices), reducing size to ~15–20 MB:
```bash
flutter build apk --split-per-abi --dart-define-from-file=.env --android-skip-build-dependency-validation
```
📂 **Output:** `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`

---

### Option 3: Debug APK *(Quick testing)*
```bash
flutter build apk --debug --dart-define-from-file=.env --android-skip-build-dependency-validation
```
📂 **Output:** `build/app/outputs/flutter-apk/app-debug.apk`

---

### Installing the APK via ADB:
```bash
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

---

## 📄 License
This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
