# Messaging App

A Flutter messaging application with an embedded Angular dashboard for internal tools. This app provides a support chat interface with message persistence and integrates an Angular web application via WebView.

## Features

### 📱 Messaging Screen
- **Chat Interface**: Clean, modern chat UI with message bubbles
- **Message Persistence**: Messages are automatically saved and restored using SharedPreferences
- **Auto-scroll**: Automatically scrolls to the latest message
- **Agent Simulation**: Simulated agent responses with random helpful messages
- **Clear Messages**: Option to clear all messages with confirmation dialog
- **Message Timestamps**: Each message displays its timestamp in HH:mm format

### 📊 Dashboard Screen
- **WebView Integration**: Embedded Angular application via WebView
- **Platform Support**: Handles different localhost URLs for Android and iOS
- **Error Handling**: Robust error handling with retry logic (up to 3 attempts)
- **Loading States**: Visual feedback during page loading
- **Refresh Functionality**: Manual refresh button to reload the dashboard

### 🏗️ Architecture
- **Clean Architecture**: Separated into models, screens, and services
- **State Management**: Stream-based state management for reactive UI updates
- **Service Layer**: Dedicated services for messaging and storage operations
- **Error Handling**: Comprehensive error handling throughout the app

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Node.js and npm (for Angular dashboard)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_app
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **iOS Setup** (if developing for iOS)
   ```bash
   ./setup_ios.sh
   ```
   Or manually update `ios/Runner/Info.plist` as described in [UPDATE_IOS.md](UPDATE_IOS.md)

4. **Run the app**
   ```bash
   flutter run
   ```

### Running the Angular Dashboard

To use the Dashboard screen, you need to run the Angular application:

```bash
cd webpage
npm install
npm start
```

The Angular app should be running on `http://localhost:4200`. The Flutter app will automatically connect to it.

**Note**: 
- On Android emulator, use `http://10.0.2.2:4200`
- On iOS simulator, use `http://localhost:4200`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── message.dart         # Message data model
├── screens/
│   ├── home_screen.dart     # Main navigation screen
│   ├── messages_screen.dart # Chat interface
│   └── dashboard_screen.dart # WebView dashboard
└── services/
    ├── message_service.dart # Message business logic
    └── storage_service.dart # Local storage operations
```

## Testing

Run the test suite:

```bash
flutter test
```

The test suite includes:
- Widget tests for UI components
- Service tests for message and storage operations
- Navigation tests
- Message sending and persistence tests

## Dependencies

- `webview_flutter`: WebView integration for Angular dashboard
- `shared_preferences`: Local message persistence
- `intl`: Date/time formatting
- `flutter_lints`: Code quality and linting

## Platform Support

- ✅ iOS
- ✅ Android
- ✅ Web (with limitations for WebView)

## Development

### Code Style

The project follows Flutter's recommended linting rules. Run:

```bash
flutter analyze
```

### Building

**Android APK:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
```

## Troubleshooting

### Dashboard Not Loading

1. Ensure the Angular app is running on port 4200
2. Check network connectivity
3. Verify platform-specific localhost URLs
4. Use the retry button (up to 3 attempts)
5. Check iOS Info.plist settings if on iOS

### Messages Not Persisting

- Check device storage permissions
- Verify SharedPreferences is working
- Check console for error messages

## License

This project is created for assessment purposes.
