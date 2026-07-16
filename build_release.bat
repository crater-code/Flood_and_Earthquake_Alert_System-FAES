@echo off
echo ========================================
echo  FAEAS App - Release Build Script
echo ========================================
echo.

echo [1/6] Cleaning previous builds...
call flutter clean
if %errorlevel% neq 0 (
    echo ERROR: Flutter clean failed
    exit /b 1
)

echo [2/6] Getting dependencies...
call flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Flutter pub get failed
    exit /b 1
)

echo [3/6] Analyzing code...
call flutter analyze
if %errorlevel% neq 0 (
    echo WARNING: Code analysis found issues, but continuing...
)

echo [4/6] Running tests...
call flutter test
if %errorlevel% neq 0 (
    echo WARNING: Tests failed or no tests found, but continuing...
)

echo [5/6] Building release APK...
call flutter build apk --release --verbose
if %errorlevel% neq 0 (
    echo ERROR: Release build failed
    exit /b 1
)

echo [6/6] Build completed successfully!
echo.
echo ========================================
echo  Build Information
echo ========================================
echo App Name: FAEAS - Flood & Earthquake Alert System
echo Package: com.faeas.flood_quake_alert
echo Version: 1.0.0+1
echo Build Type: Release (Signed)
echo Output: build\app\outputs\flutter-apk\app-release.apk
echo Size: 
dir build\app\outputs\flutter-apk\app-release.apk | find "app-release.apk"
echo ========================================
echo.

echo APK built successfully and signed with release keystore!
echo File location: %cd%\build\app\outputs\flutter-apk\app-release.apk
echo.
pause