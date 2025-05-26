# VTS_IOS

A simple iOS application built with SwiftUI that displays a welcome message.

## Project Overview

VTS_IOS is a basic iOS application that demonstrates the use of SwiftUI to create a simple user interface with a globe icon and welcome text. This project serves as a starting point for iOS development with SwiftUI.

## Requirements

### Software Requirements
- **macOS:** macOS Monterey (12.0) or later
- **Xcode:** Xcode 14.3 or later
- **iOS SDK:** iOS 16.0 or later
- **Swift:** Swift 5.0

### Hardware Requirements
- **Development Machine:** Mac computer with Apple Silicon or Intel processor
- **Device/Simulator:** iPhone or iPad running iOS 16.0 or later
- **Processor Support:** armv7 or newer

## Setting Up the Development Environment

1. **Install Xcode**
   - Download and install Xcode from the [Mac App Store](https://apps.apple.com/us/app/xcode/id497799835?mt=12) or from [Apple's Developer website](https://developer.apple.com/xcode/)
   - Ensure you have Xcode 14.3 or later

2. **Clone the Repository**
   ```bash
   git clone https://github.com/vmudinas/VTS_IOS.git
   cd VTS_IOS
   ```

3. **Open the Project**
   - Double-click on `VTS_IOS.xcodeproj` or open it from Xcode
   - Alternatively, use the command line:
     ```bash
     open VTS_IOS.xcodeproj
     ```

## Building and Running the App

### Running in Development Mode

1. **Select a Simulator or Device**
   - From the Xcode toolbar, select an iOS simulator or a connected iOS device

2. **Build and Run**
   - Click the "Play" button (▶️) in the Xcode toolbar or press `Cmd+R`
   - Alternatively, select "Run" from the "Product" menu

3. **Debug Mode**
   - To run in debug mode, use `Cmd+B` to build and then `Cmd+R` to run
   - Add breakpoints by clicking on line numbers in the code editor

### Running on a Physical Device

1. **Apple Developer Account**
   - For running on a physical device, you may need an Apple Developer account
   - Free accounts allow limited development and testing capabilities

2. **Device Setup**
   - Connect your iOS device to your Mac via USB
   - Trust the computer on your iOS device if prompted
   - Select your device from the device list in Xcode

3. **Signing Configuration**
   - In Xcode, select the project in the Navigator
   - Select the "Signing & Capabilities" tab
   - Choose a team for signing (with your Apple ID)
   - If needed, update the bundle identifier to be unique

## Project Structure

- `AppDelegate.swift` - Application delegate for app lifecycle events
- `SceneDelegate.swift` - Scene delegate for UI lifecycle events
- `ContentView.swift` - Main SwiftUI view defining the user interface
- `Assets.xcassets` - Asset catalog for images and app icons
- `LaunchScreen.storyboard` - Launch screen configuration
- `Info.plist` - Application configuration settings

## Dependencies

This project does not use any third-party dependencies or package managers like CocoaPods, Carthage, or Swift Package Manager. It is a self-contained project using only Apple's standard iOS frameworks.

## Licenses

This project does not require any special licenses beyond standard Apple Developer Program terms. It uses only the standard iOS SDK and SwiftUI framework provided by Apple.

## Supported Devices

- iPhone (iOS 16.0+)
- iPad (iOS 16.0+)
- Supports both portrait and landscape orientations

## Troubleshooting

- **Build Errors:** Ensure you're using the correct Xcode version (14.3+)
- **Simulator Issues:** Try resetting the simulator (Device Menu > Erase All Content and Settings)
- **Device Connection Problems:** Check USB cable connection and device trust settings

## Contact Information

For questions or support, please create an issue on the GitHub repository.
