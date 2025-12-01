# iOS Setup Instructions

After running `flutter create . --platforms=ios`, you need to update the Info.plist to allow WebView to connect to localhost.

## Quick Fix

Run this script:
```bash
./setup_ios.sh
```

## Manual Fix

Edit `ios/Runner/Info.plist` and add this XML block **before the closing `</dict></plist>` tags**:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

The file should look something like this at the end:
```xml
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsLocalNetworking</key>
        <true/>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
```

This allows the WebView to connect to `http://localhost:4200` for the Angular dashboard.

