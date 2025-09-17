@echo off
echo ========================================
echo    SCHOOL APP APK BUILDER - FAST
echo ========================================
echo.

REM Set environment variables
set JAVA_HOME=C:\Program Files\Java\jdk-24
set ANDROID_HOME=C:\Users\HP\AppData\Local\Android\sdk
set PATH=%JAVA_HOME%\bin;%ANDROID_HOME%\platform-tools;%PATH%

echo Current Java Version:
java -version
echo.

echo Current Flutter Version:
flutter --version
echo.

cd /d "d:\Qder\School_App"

echo Cleaning previous builds...
flutter clean
echo.

echo Getting dependencies...
flutter pub get
echo.

echo Building APK (Debug - Fast)...
flutter build apk --debug --target-platform=android-arm64
echo.

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo ========================================
    echo       APK BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo APK Location: d:\Qder\School_App\build\app\outputs\flutter-apk\app-debug.apk
    echo File Size:
    dir "build\app\outputs\flutter-apk\app-debug.apk"
    echo.
    echo READY TO INSTALL ON YOUR PHONE!
) else (
    echo ========================================
    echo       BUILD FAILED - TRY ONLINE
    echo ========================================
    echo.
    echo Please use online build services:
    echo 1. codemagic.io
    echo 2. flutlab.io
    echo 3. GitHub Actions
)

echo.
pause