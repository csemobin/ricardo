@echo off
echo Running Flutter Gen Commands...
echo.
fvm dart pub global activate flutter_gen
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter pub run build_runner build
echo.
echo All commands completed!