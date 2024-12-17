# QRCodeReader

A powerful Swift package that provides a simple and customizable QR code and barcode scanning experience using VisionKit framework.

## Features

- Supports QR code and barcode scanning.
- Provides an overlay with customizable color and corner styles.
- Configurable instruction text, padding, and window size for the scanner overlay.
- Simple integration with UIViewController.
- Uses Apple's VisionKit framework for accurate and high-performance scanning.

## Requirements

- iOS 16.0 or later
- Swift 5.7 or later
- UIKit and VisionKit frameworks

## Installation

QRCodeReader can be added to your project using Swift Package Manager (SPM).

### Step 1: Add the Package

1. In Xcode, go to **File > Add Packages...**.
2. Enter the package URL for the QRCodeReader repository.
3. Select the appropriate version and add the package to your target.

### Step 2: Import the Package

```swift
import QRCodeReader
```
## Usage

### 1. Check Scanner Availability

Ensure the device supports and has access to the scanner.

```swift
let qrReader = QRCodeReader()

if qrReader.isScanningAvailable() {
    print("QR Scanner is available!")
} else {
    print("QR Scanner is not supported on this device.")
}
```
### 2. Present the Scanner

To present the scanner, call the `presentScanner(from:completion:)` method from any `UIViewController`. This method will display the QR code or barcode scanner view and pass the scanned code back through the completion handler.

Example:

```swift
let qrReader = QRCodeReader()

qrReader.presentScanner(from: self) { scannedCode in
    print("Scanned Code: \(scannedCode)")
}
```
### 3. Customize the Scanner

The scanner appearance and behavior can be customized using the following properties:

- `overlayColor`: The color of the scanner overlay.
- `cornerColor`: The color of the scanner corners.
- `instructionText`: Instructional text displayed on the scanner.
- `padding`: Padding around the scanner frame.
- `windowSize`: Size of the scanner window.

Example:

```swift
qrReader.overlayColor = UIColor.black.withAlphaComponent(0.6)
qrReader.cornerColor = .systemBlue
qrReader.instructionText = "Place the QR code inside the frame"
qrReader.padding = 10
qrReader.windowSize = 300
```
### Delegate Callbacks

QRCodeReader uses delegate methods to notify about scan completion or cancellation.

#### Handle Scan Results

```swift
func qrScanner(didScanCode code: String) {
    print("Scanned QR/Barcode: \(code)")
}
```

#### Handle Cancellation

```swift
func qrScannerDidCancel() {
    print("QR Scanner was cancelled.")
}
```
