# VTS_IOS

![iOS Tests](https://github.com/vmudinas/VTS_IOS/workflows/iOS%20Tests/badge.svg)

A SwiftUI iOS application for managing payments, issues, and uploading videos.

## Project Overview

VTS_IOS is an iOS application that demonstrates the use of SwiftUI to create a user-friendly interface for managing payments, creating issues, and uploading videos. The app includes authentication, and a tabbed interface for accessing different features.

## Features

### Authentication
- Login with username and password
- Default credentials: admin/admin

### Payments
- View upcoming payments scheduled by administrators
- Payment details include amount, due date, description, and payment status
- Process payments using Stripe, PayPal, or Apple Pay
- Set up recurring payments with flexible scheduling options
- Receive automated reminders for upcoming payments
- Process full or partial refunds for completed payments

### Issues
- Create new issues with title and description
- View existing issues with status indicators
- Issues can be in various states: Open, In Progress, Resolved, Closed
- Advanced maintenance tracking features:
  - Priority levels (Low, Medium, High, Urgent) with estimated response times
  - Recurring maintenance tasks with configurable frequencies
  - Contractor service integration for specialized maintenance
  - Cost tracking with estimated and actual costs
  - Detailed task notes and completion tracking
  - Ability to skip occurrences for recurring maintenance

### Messages
- Direct messaging system between landlords and tenants
- Conversation view with real-time message status (read/unread)
- Support for creating new conversations
- Message history tracking
- Notification for new messages

### Documents
- Upload and manage important documents (leases, move-in checklists, renewal agreements)
- E-sign documents directly in the app
- Track signature status (pending, signed, rejected)
- Secure document storage and management
- Organize documents by type and related property

### Video Upload
- Upload videos from camera or photo library
- Add title and description to uploaded videos
- View list of previously uploaded videos with status indicators
- Monitor upload progress

### History
- View chronological history of all user activities
- Activities are grouped by date
- Activity types include Payments, Issues, Video Uploads, and Documents

### User Profile
- View user information
- Logout functionality

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

### Continuous Integration/Continuous Deployment

This project uses GitHub Actions for CI/CD. The workflow:
- Automatically builds and tests the app on every PR and push to main
- Provides test results and code coverage reports
- Ensures code quality before merging

For more details, see [CI/CD Documentation](.github/workflows/README.md).

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
- `MainView.swift` - Main view that handles authentication state
- `LoginView.swift` - User login interface
- `ContentView.swift` - TabView container for main app functionality
- `PaymentsView.swift` - View for displaying upcoming payments
- `IssuesView.swift` - View for creating and viewing issues
- `DocumentsView.swift` - View for document management and e-signing
- `VideoUploadView.swift` - View for uploading and viewing videos
- `HistoryView.swift` - View for displaying user activity history
- `Models.swift` - Data models (Payment, Issue, Document, Video, HistoryItem)
- `MockServices.swift` - Mock services for simulating backend interactions
- `UserAuthentication.swift` - Authentication management
- `Assets.xcassets` - Asset catalog for images and app icons
- `LaunchScreen.storyboard` - Launch screen configuration
- `Info.plist` - Application configuration settings

## Backend Requirements

To fully support this application, the backend should implement the following APIs:

### Authentication API
- `POST /api/auth/login` - Authenticate user with username and password
- `POST /api/auth/logout` - End user session

### Payments API
- `GET /api/payments` - Get list of upcoming payments for the authenticated user
- `GET /api/payments/{id}` - Get details of a specific payment
- `PUT /api/payments/{id}/pay` - Mark a payment as paid
- `POST /api/payments/{id}/refund` - Process refund for a payment
- `POST /api/payments/recurring` - Set up recurring payment
- `PUT /api/payments/{id}/recurring/cancel` - Cancel a recurring payment

### Issues API
- `GET /api/issues` - Get list of issues
- `GET /api/issues/{id}` - Get details of a specific issue
- `POST /api/issues` - Create a new issue
- `PUT /api/issues/{id}` - Update an existing issue
- `PUT /api/issues/{id}/status` - Update issue status
- `POST /api/issues/{id}/contractors` - Assign contractor to an issue
- `PUT /api/issues/{id}/costs` - Update cost estimates and actual costs
- `POST /api/issues/{id}/notes` - Add notes to an issue
- `PUT /api/issues/{id}/skip` - Skip next occurrence of a recurring issue

### Messages API
- `GET /api/messages` - Get list of messages for the authenticated user
- `GET /api/messages/{id}` - Get details of a specific message
- `POST /api/messages` - Send a new message
- `PUT /api/messages/{id}/read` - Mark a message as read
- `GET /api/messages/conversations` - Get list of conversations
- `GET /api/messages/conversations/{userId}` - Get conversation with a specific user

### Video API
- `GET /api/videos` - Get list of uploaded videos
- `GET /api/videos/{id}` - Get details of a specific video
- `POST /api/videos` - Upload a new video (multipart form data)
- `GET /api/videos/{id}/stream` - Stream a video

### History API
- `GET /api/history` - Get user activity history
- `GET /api/history/{id}` - Get details of a specific history item

### Documents API
- `GET /api/documents` - Get list of documents
- `GET /api/documents/{id}` - Get details of a specific document
- `POST /api/documents` - Upload a new document (multipart form data)
- `PUT /api/documents/{id}/sign` - E-sign a document
- `PUT /api/documents/{id}/reject` - Reject a document signature request
- `GET /api/documents/download/{id}` - Download document file

### Data Models

**Payment**
```json
{
  "id": "string",
  "amount": "number",
  "dueDate": "date",
  "description": "string",
  "assignedTo": "string",
  "isPaid": "boolean",
  "paymentMethod": "string",
  "isRecurring": "boolean",
  "paymentFrequency": "string",
  "hasRefund": "boolean",
  "refundAmount": "number",
  "nextDueDate": "date"
}
```

**Issue**
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "createdDate": "date",
  "status": "string",
  "createdBy": "string",
  "priority": "string",
  "assignedTo": "string",
  "imageURLs": ["string"],
  "isRecurring": "boolean",
  "recurringFrequency": "string",
  "nextDueDate": "date",
  "contractorId": "string",
  "estimatedCost": "number",
  "actualCost": "number",
  "completionDate": "date",
  "skipNextOccurrence": "boolean",
  "notes": "string",
  "propertyId": "string"
}
```

**Contractor**
```json
{
  "id": "string",
  "name": "string",
  "company": "string",
  "specialties": ["string"],
  "email": "string",
  "phone": "string",
  "hourlyRate": "number",
  "isPreferred": "boolean",
  "rating": "number"
}
```

**Video**
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "uploadDate": "date",
  "duration": "number",
  "url": "string",
  "uploadStatus": "string"
}
```

**Message**
```json
{
  "id": "string",
  "sender": "string",
  "recipient": "string",
  "content": "string",
  "timestamp": "date",
  "isRead": "boolean",
  "attachmentURLs": ["string"]
}
```

**HistoryItem**
```json
{
  "id": "string",
  "activityType": "string",
  "description": "string",
  "date": "date",
  "relatedItemId": "string"
}
```

**Document**
```json
{
  "id": "string",
  "title": "string",
  "description": "string",
  "documentType": "string",
  "uploadDate": "date",
  "fileURL": "string",
  "signatureStatus": "string",
  "signedDate": "date",
  "signedBy": "string",
  "relatedEntityId": "string"
}
```

## Dependencies

This project uses the following third-party dependencies:

- **Stripe SDK** - For processing credit card payments securely
- **PayPal SDK** - For processing PayPal payments
- **Apple Pay** - Using Apple's native payment system

These dependencies can be installed using Swift Package Manager or CocoaPods. Configuration details are included in the project settings.

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
