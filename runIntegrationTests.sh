#!/bin/bash

DEVICE="iPad Air"
VERSION=7.0

OUTPUT_DIR="build/integration-tests"
mkdir -p "$OUTPUT_DIR"

PROJECT_DIR=""
SCHEME_NAME=""
WORKSPACE_NAME=""

cd "$PROJECT_DIR"

pod install	

"Pods/Subliminal/Supporting Files/CI/subliminal-test" \
    -workspace "$WORKSPACE_NAME.xcworkspace" \
    -scheme "$SCHEME_NAME" \
    -sim_device "$DEVICE" \
    -sim_version "$VERSION" \
    -output "$OUTPUT_DIR"