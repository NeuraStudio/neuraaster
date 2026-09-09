#!/usr/bin/env bash
set -euo pipefail
flutter pub get
echo "NeuraAster dependencies resolved."
echo "Run: flutter run"
echo "Release: flutter build apk --release"
