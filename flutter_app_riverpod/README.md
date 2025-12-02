# Messaging App - Riverpod Implementation

This is the **Riverpod-based implementation** of the messaging app, demonstrating modern state management using Riverpod.

## Overview

This implementation refactors the original reactive programming approach (`flutter_app/`) to use Riverpod for state management. Both implementations have identical features and functionality, allowing you to compare different state management approaches.

## Key Differences from `flutter_app/`

- **State Management**: Uses Riverpod providers instead of StreamController/ChangeNotifier
- **No `setState()` calls**: UI state managed through `StateProvider`
- **Provider-based architecture**: All state managed through providers in `lib/providers/`
- **Better dependency injection**: Providers can watch and depend on other providers
- **Built-in debugging**: `ProviderObserver` for monitoring provider lifecycle
- **Auto-dispose**: UI-only providers automatically clean up when not in use

## State Management Features

- **StateNotifierProvider**: For message and theme state management
- **StateProvider**: For UI state (emoji picker visibility, tab navigation)
- **AsyncValue**: Elegant handling of loading, error, and data states
- **Provider dependencies**: Providers can watch and react to other providers
- **Separated concerns**: `lastViewedTimestamp` extracted into its own provider

## Getting Started

See the main [README.md](../README.md) for complete setup instructions and project overview.

## Quick Start

1. Install dependencies:
```bash
flutter pub get
```

2. Make sure the Angular dashboard is running (see main README)

3. Run the app:
```bash
flutter run
```

For detailed setup instructions, troubleshooting, and feature documentation, please refer to the main [README.md](../README.md) in the project root.
