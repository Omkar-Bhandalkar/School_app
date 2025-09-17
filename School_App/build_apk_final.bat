@echo off
echo ========================================
echo    SCHOOL APP APK BUILDER (FIXED)
echo ========================================
echo.

REM Use Java 17 for compatibility
set JAVA_HOME=C:\Program Files\Java\jdk-17.0.2
if not exist "%JAVA_HOME%" (
    echo Java 17 not found. Using system Java...
    set JAVA_HOME=C:\Program Files\Java\jdk-24
)

set PATH=%JAVA_HOME%\bin;%PATH%

echo Using Java:
java -version
echo.

cd /d "d:\Qder\School_App"

echo Cleaning...
flutter clean > nul 2>&1

echo Getting dependencies...
flutter pub get

echo.
echo Building APK (This may take 5-10 minutes)...
echo Please be patient...
echo.

REM Build with specific flags to avoid issues
flutter build apk --debug --target-platform=android-arm64 --no-tree-shake-icons --no-obfuscate

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo.
    echo ========================================
    echo       ✅ APK BUILD SUCCESSFUL!
    echo ========================================
    echo.
    echo 📱 APK Location: 
    echo d:\Qder\School_App\build\app\outputs\flutter-apk\app-debug.apk
    echo.
    echo 📊 File Size:
    dir "build\app\outputs\flutter-apk\app-debug.apk" | find "app-debug.apk"
    echo.
    echo 🚀 READY TO INSTALL ON YOUR PHONE!
    echo.
    echo Installation Steps:
    echo 1. Copy APK file to your phone
    echo 2. Enable "Install unknown apps" in phone settings
    echo 3. Tap APK file to install
    echo 4. Open School Management App
) else (
    echo.
    echo ========================================
    echo       ❌ BUILD FAILED
    echo ========================================
    echo.
    echo Please try alternative methods:
    echo 1. Use online build service (Codemagic.io)
    echo 2. Check Java/Android SDK installation
)

echo.
pause