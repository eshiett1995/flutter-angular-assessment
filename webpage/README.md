# Internal Tools Dashboard

This is the Angular + Tailwind CSS Internal Tools Dashboard component of the Flutter Coding Assessment.

## Overview

This Angular 16+ application provides an internal tools dashboard with three main components:
- **Ticket Viewer**: View and filter support tickets
- **Knowledgebase Editor**: Markdown editor with live preview
- **Live Logs Panel**: Real-time system logs simulation

## Prerequisites

- Node.js (v16 or higher)
- npm or yarn

## Setup

1. Install dependencies:
```bash
npm install
```

## Development Server

Start the development server:

```bash
npm run start
```

Or alternatively:
```bash
npm start
```

The application will be available at `http://localhost:4200/`.

**Important for Flutter WebView Integration:**
- The server is configured to listen on `0.0.0.0:4200` to allow access from Flutter WebView
- For Android emulators, use `http://10.0.2.2:4200`
- For iOS simulators, use `http://localhost:4200`
- For physical devices, use your machine's local IP address (e.g., `http://192.168.1.x:4200`)

## Features

### Ticket Viewer
- Table view of support tickets with ID, Subject, Status, and Created At columns
- Filter by status: All, Open, In Progress, Closed
- Status badges with color coding

### Knowledgebase Editor
- Markdown editor with syntax highlighting
- Live preview mode
- Toggle between edit and preview modes
- Save functionality (simulated)

### Live Logs Panel
- Real-time log simulation with random events
- Auto-scroll to latest logs
- Color-coded log levels (INFO, WARN, ERROR, DEBUG)
- Clear logs functionality
- Toggle auto-scroll on/off

## Responsive Design

- Fully responsive layout with mobile hamburger menu
- Tailwind CSS for consistent styling
- Mobile-first approach with breakpoints

## Build

Build for production:

```bash
npm run build
```

The build artifacts will be stored in the `dist/` directory.

## Testing

Run unit tests:

```bash
npm test
```

## Technical Stack

- **Framework**: Angular 16.2.16
- **Styling**: Tailwind CSS 3.4.0
- **Routing**: Angular Router
- **Language**: TypeScript 5.2.2

## Flutter Integration

This dashboard is designed to be embedded in a Flutter app via WebView:
- Use `webview_flutter` package in Flutter
- Load the Angular app using the HTTP server URL
- Ensure the Angular server is running before launching the Flutter app
- The dashboard is fully responsive and works well in WebView contexts
