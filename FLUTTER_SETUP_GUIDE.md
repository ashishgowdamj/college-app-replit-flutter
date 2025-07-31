# Flutter Project Setup & Troubleshooting Guide

## Common Gradle Build Error Solutions

### 1. Prerequisites Check
Before running the project, ensure you have:
- **Flutter SDK**: 3.10.0 or higher
- **Android Studio**: Latest version with Android SDK
- **Java JDK**: Version 11 or higher
- **Android SDK**: API level 34
- **Android Build Tools**: 34.0.0

### 2. Environment Setup
```bash
# Check Flutter installation
flutter doctor

# Accept Android licenses
flutter doctor --android-licenses

# Check Java version (should be 11+)
java -version
```

### 3. Clean and Rebuild Steps
```bash
# Clean Flutter project
flutter clean

# Get dependencies
flutter pub get

# Clean Android build
cd android && ./gradlew clean && cd ..

# Rebuild the project
flutter build apk --debug
```

### 4. Common Error Fixes

#### Error: "Could not resolve all files for configuration"
**Solution**: Update Gradle wrapper and dependencies
```bash
cd android
./gradlew wrapper --gradle-version=8.3
./gradlew clean
cd ..
flutter clean && flutter pub get
```

#### Error: "Minimum supported Gradle version is X.X"
**Solution**: Update `android/gradle/wrapper/gradle-wrapper.properties`
```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.3-all.zip
```

#### Error: "Android Gradle Plugin version X requires Java X"
**Solution**: 
1. Install Java 11+ (recommended: OpenJDK 17)
2. Set JAVA_HOME environment variable
3. Update Android Studio to use the correct JDK

#### Error: "Unsupported class file major version"
**Solution**: Check Java compatibility
```bash
# Set Java 17 (recommended)
export JAVA_HOME=/path/to/java17
# Or for Windows:
# set JAVA_HOME=C:\Program Files\Java\jdk-17
```

#### Error: "Flutter SDK not found"
**Solution**: 
1. Install Flutter SDK
2. Add to PATH: `export PATH="$PATH:[PATH_TO_FLUTTER_GIT_DIRECTORY]/bin"`
3. Run `flutter doctor` to verify

### 5. Android Studio Configuration
1. Open Android Studio
2. Go to File → Settings → Build → Build Tools → Gradle
3. Set Gradle JVM to Java 11+
4. Go to SDK Manager → SDK Tools
5. Install:
   - Android SDK Build-Tools 34.0.0
   - Android SDK Platform-Tools
   - Android SDK Tools
   - CMake
   - NDK (Side by side)

### 6. VS Code / Cursor AI Setup
1. Install Flutter extension
2. Install Dart extension
3. Open Command Palette (Ctrl+Shift+P)
4. Run "Flutter: New Project" to verify setup
5. Set Flutter SDK path in settings

### 7. Project-Specific Fixes Applied

✅ **Fixed compileSdk and targetSdk**: Set to 34 (latest stable)
✅ **Fixed minSdk**: Set to 21 (compatible with most devices)
✅ **Updated Gradle version**: 8.3 (latest stable)
✅ **Updated Android Gradle Plugin**: 8.1.0
✅ **Updated Kotlin version**: 1.8.22
✅ **Added Kotlin configurations**: Fixed compatibility issues
✅ **Added ProGuard rules**: For release builds
✅ **Updated package names**: Changed to com.collegecampus.app
✅ **Added multiDex support**: For larger app sizes
✅ **Optimized Gradle properties**: Better build performance

### 8. Running the Project

#### For Web Development (Recommended for testing):
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```

#### For Android Development:
```bash
# Connect Android device or start emulator
flutter devices

# Run on connected device
flutter run

# Or build APK
flutter build apk --debug
```

#### For iOS Development (macOS only):
```bash
# Open iOS project in Xcode first
open ios/Runner.xcworkspace

# Then run
flutter run -d ios
```

### 9. Verification Commands
```bash
# Check Flutter setup
flutter doctor -v

# Check connected devices
flutter devices

# Check Gradle version
cd android && ./gradlew --version && cd ..

# Test build without running
flutter build apk --debug --verbose
```

### 10. If Still Having Issues

1. **Delete build folders**:
   ```bash
   rm -rf build/
   rm -rf android/build/
   rm -rf android/app/build/
   ```

2. **Reset Flutter**:
   ```bash
   flutter clean
   flutter pub cache repair
   flutter pub get
   ```

3. **Check logs**:
   ```bash
   flutter run --verbose
   ```

4. **Create new project** and copy source files:
   ```bash
   flutter create test_project
   # Copy lib/ folder to new project
   ```

## Backend Setup (Node.js)

### Running the Backend Server
```bash
# Install dependencies
npm install

# Start development server
npm run dev

# The API will be available at http://localhost:5000
```

### Environment Variables
```bash
# Copy environment template
cp .env.example .env

# Add your database URL
DATABASE_URL=postgresql://username:password@localhost:5432/college_campus
```

## Complete Development Workflow

1. **Backend First**: 
   ```bash
   npm install && npm run dev
   ```

2. **Flutter Web** (for quick testing):
   ```bash
   flutter run -d web-server --web-port 3000
   ```

3. **Flutter Mobile** (for full testing):
   ```bash
   flutter run
   ```

The Flutter app will connect to the backend API at `http://localhost:5000` for data.

---

**Need Help?** 
- Check `flutter doctor` output first
- Review Android Studio SDK Manager settings
- Verify Java version compatibility
- Try web version first if mobile build fails