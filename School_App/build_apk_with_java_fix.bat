@echo off
echo ================================
echo    SCHOOL APP APK BUILDER
echo    (Java Compatibility Fix)
echo ================================
echo.

cd /d "d:\Qder\School_App"

echo Checking Java version...
java -version
echo.

echo Setting JAVA_HOME for Gradle compatibility...
set JAVA_HOME=D:\Andriod Studio\jbr
set PATH=%JAVA_HOME%\bin;%PATH%

echo Using Android Studio's bundled JDK...
echo JAVA_HOME: %JAVA_HOME%
echo.

echo Cleaning project...
flutter clean

echo Getting dependencies...
flutter pub get

echo.
echo Building APK (Debug mode)...
echo This may take 5-15 minutes on first build...
echo.

flutter build apk --debug --verbose

if exist "build\app\outputs\flutter-apk\app-debug.apk" (
    echo.
    echo ================================
    echo       ✅ SUCCESS!
    echo ================================
    echo.
    echo APK built successfully!
    echo Location: build\app\outputs\flutter-apk\app-debug.apk
    echo.
    explorer "build\app\outputs\flutter-apk"
) else (
    echo.
    echo ================================
    echo       ❌ BUILD FAILED
    echo ================================
    echo.
    echo Local build failed due to environment issues.
    echo Please use the cloud build methods in:
    echo GUARANTEED_APK_METHODS.md
    echo.
    echo Recommended: GitHub Codespaces or Codemagic
)

echo.
pause