@echo off
echo Creating School Management App APK...
echo.

cd /d "d:\Qder\School_App"

echo Step 1: Cleaning previous builds...
flutter clean
echo.

echo Step 2: Getting dependencies...
flutter pub get
echo.

echo Step 3: Building APK...
flutter build apk --debug --no-shrink
echo.

echo APK Creation Complete!
echo.
echo Your APK file location:
echo d:\Qder\School_App\build\app\outputs\flutter-apk\app-debug.apk
echo.
pause