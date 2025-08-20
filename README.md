# College Connect – Flutter App (with optional Node backend and web client)

A mobile-first Flutter application for searching, comparing, and reviewing colleges in India. Designed for fast navigation and instant detail rendering.

## Features

- **Search & Filter** colleges by course type, state, and fees
- **Instant detail load** from Search → Detail (optimistic render + background refresh)
- **Compare** colleges side-by-side
- **Reviews & Placements** tabs
- **Favorites** (watchlist)

## Repo layout

```
.
├── lib/                  # Flutter app source (main codebase)
│   ├── models/
│   ├── screens/
│   ├── services/
│   └── main.dart
├── server/               # Node.js (TypeScript) API server (optional for local dev)
├── client/               # Optional web client (React/Vite) – not required to run Flutter app
├── assets/               # Images, fonts
├── android/ | ios/ | macos/  # Platform folders
├── web/                  # Flutter web support
├── shared/               # Shared types (TS)
├── README.md
└── pubspec.yaml
```

## Requirements

- Flutter 3.16+ (Dart 3)
- Node.js 18+ (only if you run the local server in `server/`)

## Environment

Copy `.env.example` to `.env` and fill values as needed. The Flutter app uses a platform-aware base URL during development:

- Android emulator: `http://10.0.2.2:<port>`
- iOS simulator / desktop: `http://127.0.0.1:<port>` or `http://localhost:<port>`

Confirm the port your local server uses (commonly 3000).

## Install dependencies

```bash
flutter pub get

# Optional – backend
cd server && npm install
```

## Run

Flutter (choose your target):

```bash
# Android emulator
flutter run -d emulator-5554

# iOS simulator
flutter run -d ios

# Web
flutter run -d chrome
```

Backend (optional):

```bash
cd server
npm run dev
```

## Build

```bash
# Android APK
flutter build apk --release

# iOS (requires Xcode setup)
flutter build ios --release

# Web
flutter build web --release
```

## Configuration notes

- The app optimizes perceived speed by passing the selected `College` through route extras from `Search` to `Detail`, then fetching fresh details/reviews in the background. Backend logic and DB are unchanged.
- If you run on Android emulator and your API is on localhost, use `10.0.2.2` instead of `localhost`.
- Ensure CORS is enabled on your local API if testing Flutter Web.

## Troubleshooting

- **Detail feels slow on device**: Verify base URL per platform (Android: `10.0.2.2`). Confirm server is running and reachable.
- **No data / timeouts**: Lower dev timeouts in `ApiService`, or ensure the local API is up. Consider mock data for demos.
- **Web build blank**: Clear `build/` and browser cache; check console for CORS or mixed content issues.
- **iOS build issues**: Run `cd ios && pod install`; open the workspace in Xcode.

## License

MIT. See `LICENSE`.

## Acknowledgments

- Inspired by CollegeDunia and Shiksha
- Built with Flutter (Material 3), Provider, go_router
