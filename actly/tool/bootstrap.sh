#!/usr/bin/env bash
set -euo pipefail

flutter create \
  --platforms=android,ios \
  --org com.actly.app \
  --project-name actly \
  .
flutter pub get
dart format lib test
flutter analyze
flutter test
