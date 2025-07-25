#!/bin/bash
set -e

APP_NAME="ScreenshotForChat"
VERSION="1.0.0"

echo "🔧 Building ${APP_NAME} with Swift Package Manager..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf .build/release
rm -rf dist/

# Resolve dependencies and build with SPM
echo "📦 Resolving dependencies..."
swift package resolve

echo "🔨 Building release binary..."
swift build -c release

# Verify binary exists
BINARY_PATH=".build/release/${APP_NAME}"
if [ ! -f "${BINARY_PATH}" ]; then
    echo "❌ Build failed - binary not found at ${BINARY_PATH}"
    exit 1
fi

# Create .app bundle structure
echo "📱 Creating .app bundle..."
APP_BUNDLE="dist/${APP_NAME}.app"
mkdir -p "${APP_BUNDLE}/Contents/MacOS"
mkdir -p "${APP_BUNDLE}/Contents/Resources"

# Copy binary
cp "${BINARY_PATH}" "${APP_BUNDLE}/Contents/MacOS/"

# Copy Info.plist
if [ -f "Resources/Info.plist" ]; then
    cp "Resources/Info.plist" "${APP_BUNDLE}/Contents/"
else
    echo "❌ Info.plist not found in Resources/"
    exit 1
fi

# Copy app icon
if [ -f "Resources/ScreenshotForChat.icns" ]; then
    echo "🎨 Copying app icon..."
    cp "Resources/ScreenshotForChat.icns" "${APP_BUNDLE}/Contents/Resources/"
else
    echo "⚠️ App icon not found - run Scripts/setup-icons.sh first"
fi

# Copy menu bar icons
if [ -f "Resources/menubar_16x16.png" ]; then
    echo "🔍 Copying menu bar icons..."
    cp "Resources/menubar_"*.png "${APP_BUNDLE}/Contents/Resources/"
else
    echo "⚠️ Menu bar icons not found - run Scripts/setup-icons.sh first"
fi

# Copy entitlements if they exist (for code signing)
if [ -f "Resources/ScreenshotForChat.entitlements" ]; then
    cp "Resources/ScreenshotForChat.entitlements" "${APP_BUNDLE}/Contents/"
fi

# Copy KeyboardShortcuts resource bundle
KEYBOARD_SHORTCUTS_BUNDLE=".build/arm64-apple-macosx/release/KeyboardShortcuts_KeyboardShortcuts.bundle"
if [ -d "${KEYBOARD_SHORTCUTS_BUNDLE}" ]; then
    echo "📚 Copying KeyboardShortcuts resource bundle..."
    cp -r "${KEYBOARD_SHORTCUTS_BUNDLE}" "${APP_BUNDLE}/Contents/"
fi

# Make binary executable
chmod +x "${APP_BUNDLE}/Contents/MacOS/${APP_NAME}"

echo "✅ Build complete!"
echo "📱 App bundle: $(pwd)/${APP_BUNDLE}"
echo "📋 Binary size: $(du -h "${BINARY_PATH}" | cut -f1)"
echo ""
echo "🚀 To run: open ${APP_BUNDLE}"
echo "📋 To install: cp -r ${APP_BUNDLE} /Applications/"