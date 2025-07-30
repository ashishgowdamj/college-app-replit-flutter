# College Campus - College Comparison & Ranking Platform

A comprehensive mobile-first Flutter application for college search, comparison, and ranking in India. Inspired by platforms like College Duniya and Shiksha, this app helps students make informed decisions about their higher education.

## Features

- **College Search & Discovery**: Browse and search through top colleges across India
- **Advanced Filtering**: Filter by course type, location, fees, entrance exams, and more
- **College Comparison**: Side-by-side comparison of up to 4 colleges
- **Entrance Exam Information**: Comprehensive details about JEE, NEET, CAT, and other exams
- **College Rankings**: View colleges ranked by various criteria
- **Detailed College Profiles**: Complete information including courses, fees, placements, and reviews
- **Favorites & Watchlist**: Save colleges for later comparison
- **Rank Predictor**: Estimate admission chances based on exam scores

## Architecture

### Frontend (Flutter)
- **Framework**: Flutter for cross-platform mobile and web development
- **Language**: Dart with strong typing and null safety
- **Routing**: go_router for declarative navigation
- **State Management**: Provider pattern for reactive state management
- **UI Design**: Material Design with custom components and modern styling
- **HTTP Client**: Dio for robust API communication
- **Platform Support**: Android, iOS, and Web from a single codebase

### Backend (Node.js + Express)
- **Runtime**: Node.js with Express.js framework
- **Language**: TypeScript for type safety
- **Database**: PostgreSQL with Drizzle ORM
- **Database Provider**: Neon Database (serverless PostgreSQL)
- **API Design**: RESTful APIs with consistent error handling

## Getting Started

### Prerequisites
- Flutter SDK (3.0 or higher)
- Node.js (18 or higher)
- PostgreSQL database (or Neon Database account)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/college-campus.git
   cd college-campus
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Install Node.js dependencies**
   ```bash
   npm install
   ```

4. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Add your DATABASE_URL and other required variables
   ```

5. **Run database migrations**
   ```bash
   npm run db:migrate
   ```

### Running the Application

#### Flutter Web Development
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```

#### Backend API Server
```bash
npm run dev
```

The Flutter app will be available at `http://localhost:3000` and the API server at `http://localhost:5000`.

### Building for Production

#### Flutter Web Build
```bash
flutter build web --release
```

#### Flutter Mobile Build
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## Project Structure

```
college-campus/
├── lib/                    # Flutter source code
│   ├── models/            # Data models (College, Course, Exam, etc.)
│   ├── screens/           # App screens (Home, Search, Compare, etc.)
│   ├── widgets/           # Reusable UI components
│   ├── services/          # API services and data layer
│   └── main.dart          # App entry point
├── server/                # Node.js backend
│   ├── index.ts           # Server entry point
│   ├── routes.ts          # API routes
│   └── storage.ts         # Data storage layer
├── shared/                # Shared types and schemas
│   └── schema.ts          # Database schema and types
├── android/               # Android-specific files
├── ios/                   # iOS-specific files
├── web/                   # Web-specific files
└── pubspec.yaml           # Flutter dependencies
```

## API Endpoints

- `GET /api/colleges` - List colleges with filtering and search
- `GET /api/colleges/:id` - Get college details
- `GET /api/colleges/:id/reviews` - Get college reviews
- `GET /api/exams` - List entrance exams
- `POST /api/comparisons` - Save college comparisons

## Technologies Used

### Frontend
- Flutter & Dart
- go_router for navigation
- Provider for state management
- Dio for HTTP requests
- Material Design components

### Backend
- Node.js & Express.js
- TypeScript
- PostgreSQL with Drizzle ORM
- Neon Database
- Zod for validation

### Development Tools
- Vite for development server
- ESBuild for building
- Flutter DevTools
- Dart Analysis Server

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by College Duniya and Shiksha platforms
- Built with Flutter for cross-platform development
- Uses Material Design for consistent UI/UX  
- Powered by modern web technologies
