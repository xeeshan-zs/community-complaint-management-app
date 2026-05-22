@echo off
title Community Complaint Management App - Launcher
color 0A

echo.
echo  ╔═══════════════════════════════════════════════════════════╗
echo  ║     COMMUNITY COMPLAINT MANAGEMENT APP                   ║
echo  ║     BSIT-6 Final Lab Exam  ^|  Roll Number: 11249          ║
echo  ║     Student: Kafeel Khan                                 ║
echo  ╚═══════════════════════════════════════════════════════════╝
echo.
echo  [*] Booting Flutter Windows Desktop App...
echo  [*] Powered by Puro Flutter SDK Manager (v3.44.0 stable)
echo.

:: Locate Puro executable
set PURO_EXE=C:\Users\Shani\AppData\Local\Microsoft\WinGet\Packages\pingbird.Puro_Microsoft.Winget.Source_8wekyb3d8bbwe\puro.exe

:: Check if puro exists
if not exist "%PURO_EXE%" (
    echo  [ERROR] Puro not found at expected path:
    echo          %PURO_EXE%
    echo.
    echo  Please install Puro via: winget install pingbird.Puro
    echo  Then re-run this script.
    pause
    exit /b 1
)

echo  [OK] Puro found. Launching app...
echo  [*]  App will open in a phone-style window. Enjoy!
echo.
echo  ─────────────────────────────────────────────────────────────
echo  [!]  The app starts in SANDBOX (Offline) Mode by default.
echo  [!]  Tap the Settings icon in the app to enable Cloud Sync.
echo  ─────────────────────────────────────────────────────────────
echo.

:: Run the Flutter Windows desktop app
"%PURO_EXE%" flutter run -d windows

echo.
echo  [*] App closed. Press any key to exit...
pause > nul
