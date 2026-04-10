# PowerShell script to run integration test and collect screenshots
# Usage: Open PowerShell in repository root and run: .\tools\run_screenshots.ps1

# Ensure Flutter is on PATH
flutter pub get

# Run the integration test (connected device/emulator required)
flutter test integration_test/screenshots_test.dart -d flutter-tester

# Note: On real devices use: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screenshots_test.dart

Write-Host "Screenshots (if any) will be saved by integration_test binding in the test output directory."
