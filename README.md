# Flutter Coding Assessment - Messaging App with Embedded Internal Tools Dashboard

This project contains a Flutter messaging application with an embedded Angular dashboard, built as part of a coding assessment.

## Project Structure

```
.
├── flutter_app/          # Flutter messaging app
│   ├── lib/
│   │   ├── models/       # Data models
│   │   ├── screens/      # UI screens
│   │   ├── services/     # Business logic services
│   │   └── main.dart     # Entry point
│   └── pubspec.yaml      # Flutter dependencies
├── webpage/              # Angular dashboard app
│   ├── src/
│   │   └── app/
│   │       ├── ticket-viewer/         # Support tickets component
│   │       ├── knowledgebase-editor/  # Knowledge base editor
│   │       └── live-logs/             # Live system logs
│   └── package.json
└── README.md             # This file
```

## Features

### Flutter Messaging App
- ✅ Native Flutter messaging interface with chat bubbles
- ✅ Incoming/outgoing message differentiation
- ✅ Timestamps on all messages
- ✅ Auto-scroll to latest messages
- ✅ Text input with send button
- ✅ Simulated support agent responses
- ✅ Clear messages functionality
- ✅ **Message persistence** (messages saved locally using SharedPreferences)
- ✅ **Emoji support** with emoji picker (tap emoji button to open picker)
- ✅ **Image message support** (choose from gallery or take photo)
- ✅ **Image persistence** (images saved to app storage and persist across restarts)
- ✅ **Notification badge** for unread messages (shows count on Messages tab)
- ✅ **Dark mode support** with theme toggle in app bar
- ✅ **Theme synchronization** with embedded Angular dashboard
- ✅ Embedded WebView for Angular dashboard
- ✅ Bottom navigation between Messages and Dashboard

### Angular Internal Tools Dashboard
- ✅ Ticket Viewer with filterable support tickets (Open, In Progress, Closed)
- ✅ Knowledge Base Editor with Markdown editing and live preview
- ✅ Live Logs Panel with simulated real-time log updates
- ✅ **Dark mode support** with theme toggle in sidebar
- ✅ **Theme synchronization** with Flutter app (receives theme changes from Flutter)
- ✅ Fully responsive design with Tailwind CSS (mobile-optimized)
- ✅ Sidebar navigation between modules
- ✅ Modern, clean UI design

## Prerequisites

### For Flutter App
- Flutter SDK (3.0.0 or higher)
- Dart SDK (comes with Flutter)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio with Flutter plugins

### For Angular Dashboard
- Node.js (v16 or higher)
- npm (comes with Node.js)
- Angular CLI (will be installed automatically)

## Setup Instructions

### 1. Angular Dashboard Setup

1. Navigate to the webpage directory:
```bash
cd webpage
```

2. Install dependencies:
```bash
npm install
```

3. Start the Angular development server:
```bash
npm start
```

**Note:** If port 4200 is already in use, you can either:
- Kill the process using port 4200: `kill -9 $(lsof -ti:4200)`
- Use an alternative port: `npm run start:alt` (uses port 4201)
  - If using port 4201, update the URL in `flutter_app/lib/screens/dashboard_screen.dart` from `:4200` to `:4201`

The Angular app will be available at `http://localhost:4200`

**Important:** Keep this server running while using the Flutter app, as the WebView needs to access it.

### 2. Flutter App Setup

1. Navigate to the Flutter app directory:
```bash
cd flutter_app
```

2. Get Flutter dependencies:
```bash
flutter pub get
```

3. **iOS Setup (if running on iOS):**
   If you encounter iOS project errors, regenerate the iOS project:
   ```bash
   rm -rf ios
   flutter create . --platforms=ios
   ./setup_ios.sh  # Updates Info.plist for WebView networking
   ```

4. Run the app:

   **For Android:**
   ```bash
   flutter run
   ```
   Or use Android Studio to run the app.

   **For iOS (macOS only):**
   ```bash
   flutter run
   ```
   Or use Xcode to run the app.

   **For Web:**
   ```bash
   flutter run -d chrome
   ```

## Platform-Specific Notes

### Android
- The app uses `http://10.0.2.2:4200` to access the host machine's localhost from the Android emulator
- Make sure the Angular server is running on your host machine
- Internet permission is configured in `AndroidManifest.xml`
- Cleartext traffic (HTTP) is enabled for localhost connections (required for development)
- Network security config allows HTTP connections to localhost and 10.0.2.2

### iOS
- The app uses `http://localhost:4200` for iOS simulators
- Make sure the Angular server is running
- For physical devices, you may need to use your computer's local IP address instead of localhost

### Web
- Works best with Chrome/Edge browsers
- The WebView will directly access `http://localhost:4200`

## Using the App

### Messages Screen
1. Type a message in the input field
2. Tap the send button or press Enter
3. Wait for the simulated support agent response (appears after ~1.5 seconds)
4. Messages automatically scroll to show the latest
5. **Add emojis**: Tap the emoji button (😊) to open the emoji picker and insert emojis into your message
6. **Send images**: Tap the image button (📷) to:
   - Choose an image from your gallery
   - Take a photo with your camera
7. Images display in message bubbles and persist across app restarts
8. **Notification badge**: When you receive new agent messages while on the Dashboard, a red badge with the unread count appears on the Messages tab
9. The badge automatically clears when you view the Messages screen
10. Use the trash icon in the app bar to clear all messages
11. Toggle dark mode using the sun/moon icon in the app bar

### Dashboard Screen
1. Navigate to the Dashboard tab using bottom navigation
2. The Angular dashboard will load in a WebView
3. If you see an error, make sure the Angular server is running on port 4200
4. Use the refresh button to reload the dashboard
5. Toggle dark mode using the sun/moon icon in the app bar (syncs with Angular dashboard)
6. Navigate between different sections using the sidebar:
   - **Ticket Viewer**: View and filter support tickets
   - **Knowledge Base Editor**: Edit articles with Markdown support
   - **Live Logs**: Monitor real-time system logs
7. Toggle dark mode in Angular using the theme button in the sidebar

## Troubleshooting

### iOS Project Errors

If you get errors like "Unable to read project 'Runner.xcodeproj'" or "The project 'Runner' is damaged":

1. Remove the iOS folder:
   ```bash
   cd flutter_app
   rm -rf ios
   ```

2. Regenerate iOS project:
   ```bash
   flutter create . --platforms=ios
   ```

3. Update Info.plist for WebView:
   ```bash
   ./setup_ios.sh
   ```

4. Try running again:
   ```bash
   flutter run
   ```

### Dashboard won't load in Flutter app

1. **Check Angular server is running:**
   ```bash
   cd webpage
   npm start
   ```

2. **Verify the URL:**
   - Android Emulator: Should use `10.0.2.2:4200`
   - iOS Simulator: Should use `localhost:4200`
   - Physical Device: May need your computer's IP address (e.g., `192.168.1.x:4200`)

3. **Check network permissions:**
   - Android: Internet permission and cleartext traffic are configured
   - iOS: App Transport Security settings allow HTTP (development only)

4. **For physical devices:**
   - Make sure your device is on the same network as your development machine
   - Use your computer's local IP address instead of localhost
   - Update the URL in `dashboard_screen.dart` if needed

5. **If you see `ERR_CLEARTEXT_NOT_PERMITTED`:**
   - Android: The network security config should allow cleartext traffic (already configured)
   - Make sure you've rebuilt the app after the manifest changes
   - Check that `network_security_config.xml` exists in `android/app/src/main/res/xml/`

### Angular build errors

If you encounter issues with the Angular project:
```bash
cd webpage
rm -rf node_modules package-lock.json
npm install
npm start
```

### Flutter dependencies issues

If Flutter packages don't install correctly:
```bash
cd flutter_app
flutter clean
flutter pub get
```

## Development Notes

### State Management
✅ **Approach**: The app uses Flutter's built-in reactive patterns without external state management libraries:
- **StreamController + StreamBuilder**: Used for message updates (reactive streams)
- **ChangeNotifier**: Used for theme management (observer pattern)
- **StatefulWidget + setState**: Used for local UI state
- **Singleton Pattern**: Services are singletons to maintain state across screen navigations

This lightweight approach works well for the app's current scope and avoids unnecessary dependencies. For larger projects with more complex state requirements, consider using **Riverpod** or **Provider** for better dependency injection, state organization, and testability.

### Message Persistence
✅ **Implemented**: Messages are automatically saved to local storage using SharedPreferences and restored when the app is reopened. Messages persist across app restarts. The service uses a singleton pattern to maintain state across screen navigations.

**Image Persistence**: Images are saved to the app's documents directory (`messages_images/`) and persist across app restarts. Image paths are stored as relative paths in SharedPreferences and reconstructed when loading to handle app container UUID changes.

### Dark Mode & Theme Synchronization
✅ **Implemented**: Both Flutter and Angular apps support dark mode with synchronized themes:
- **Flutter**: Toggle dark mode using the sun/moon icon in the app bar (available on both Messages and Dashboard screens)
- **Angular**: Toggle dark mode using the theme button in the sidebar navigation
- **Synchronization**: When you change the theme in Flutter, it automatically syncs to the embedded Angular dashboard via JavaScript injection
- **Persistence**: Theme preferences are saved locally and persist across app restarts

### Emoji & Image Message Support
✅ **Implemented**: 
- **Emoji Picker**: Tap the emoji button in the input area to open a full emoji picker. Select emojis to insert into your messages. Emoji messages display with larger font size for better visibility.
- **Image Messages**: 
  - Choose images from your device gallery
  - Take photos directly with the camera
  - Images are displayed in message bubbles (200x200px, rounded corners)
  - Images are automatically saved to app storage for persistence
  - Images persist across app restarts
- **Permissions**: 
  - Android: Camera and storage permissions configured
  - iOS: Camera and photo library usage descriptions added

### Notification Badge for Unread Messages
✅ **Implemented**: 
- **Unread Count Tracking**: Tracks agent messages received after the last time you viewed the Messages screen
- **Badge Display**: Shows a red notification badge with the unread count on the Messages tab in the bottom navigation
- **Auto-Clear**: Badge automatically clears when you navigate to the Messages screen
- **Persistence**: Last viewed timestamp is saved, so the badge persists across app restarts
- **Real-time Updates**: Badge updates immediately when new agent messages arrive

### Additional Bonus Features
The following features can be added as further enhancements:
- Message search functionality
- Two-way theme synchronization (Angular → Flutter)
- Image compression/optimization
- Video message support
- Push notifications for new messages
- Message reactions/emojis

## Technical Stack

### Flutter App
- **Framework**: Flutter 3.0+
- **State Management**: 
  - Built-in reactive patterns (StreamController + StreamBuilder, ChangeNotifier)
  - No external state management libraries (works well for this app's scope)
  - Singleton pattern for service instances
  - For larger projects, consider Riverpod or Provider
- **WebView**: webview_flutter package with JavaScript injection for theme sync
- **Local Storage**: shared_preferences (for message and theme persistence)
- **Theme Management**: Custom ThemeService with light/dark theme support
- **Emoji Support**: emoji_picker_flutter package
- **Image Support**: image_picker package for gallery and camera access
- **File Management**: path_provider and path packages for image storage

### Angular Dashboard
- **Framework**: Angular 16+
- **Styling**: Tailwind CSS with dark mode support (class-based)
- **Theme Management**: ThemeService with localStorage persistence and Flutter event listeners
- **Routing**: Angular Router
- **HTTP Server**: Angular CLI dev server (ng serve)

## Submission

This project meets all the requirements specified in the assessment:
- ✅ Fully native Flutter messaging interface
- ✅ Embedded Angular dashboard in WebView
- ✅ Ticket Viewer with filters
- ✅ Knowledge Base Editor with preview
- ✅ Live Logs with simulated real-time updates
- ✅ Responsive design
- ✅ Clean code architecture
- ✅ Comprehensive setup documentation

**Additional Features Implemented:**
- ✅ Dark mode support (Flutter & Angular)
- ✅ Theme synchronization between Flutter and Angular
- ✅ Emoji picker and emoji message support
- ✅ Image message support (gallery & camera)
- ✅ Message and image persistence
- ✅ Notification badge for unread messages
- ✅ Mobile-responsive Angular dashboard

## License

This project is created for assessment purposes.

