#!/bin/sh

PROJECT_DIR=""
SCHEME_NAME=""
WORKSPACE_NAME=""

cd "$PROJECT_DIR"

pod install

xctool \
  -workspace "$WORKSPACE_NAME.xcworkspace" \
  -scheme "$SCHEME_NAME" \
  build-tests

xctool \
  -workspace "$WORKSPACE_NAME.xcworkspace" \
  -scheme "$SCHEME_NAME" \
  -sdk iphonesimulator \
  -reporter junit:build/unit-tests/test-results-ios8.xml \
  -destination "platform=iOS Simulator,name=iPad Retina,OS=latest" \
  run-tests \
  -test-sdk iphonesimulator8.1