#!/bin/bash

# Script to update iOS Info.plist for WebView networking support

IOS_INFO_PLIST="ios/Runner/Info.plist"

if [ ! -f "$IOS_INFO_PLIST" ]; then
    echo "Error: $IOS_INFO_PLIST not found. Please run 'flutter create . --platforms=ios' first."
    exit 1
fi

echo "Updating Info.plist for WebView networking support..."

# Check if NSAppTransportSecurity already exists
if /usr/libexec/PlistBuddy -c "Print :NSAppTransportSecurity" "$IOS_INFO_PLIST" >/dev/null 2>&1; then
    echo "NSAppTransportSecurity already exists, updating..."
    /usr/libexec/PlistBuddy -c "Set :NSAppTransportSecurity:NSAllowsLocalNetworking true" "$IOS_INFO_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsLocalNetworking bool true" "$IOS_INFO_PLIST"
    
    /usr/libexec/PlistBuddy -c "Set :NSAppTransportSecurity:NSAllowsArbitraryLoads true" "$IOS_INFO_PLIST" 2>/dev/null || \
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "$IOS_INFO_PLIST"
else
    echo "Adding NSAppTransportSecurity..."
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity dict" "$IOS_INFO_PLIST"
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsLocalNetworking bool true" "$IOS_INFO_PLIST"
    /usr/libexec/PlistBuddy -c "Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true" "$IOS_INFO_PLIST"
fi

echo "✅ Info.plist updated successfully!"
echo ""
echo "You can now run: flutter run"

